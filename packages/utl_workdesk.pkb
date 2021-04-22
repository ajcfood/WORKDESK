DROP PACKAGE BODY WORKDESK.UTL_WORKDESK;

CREATE OR REPLACE PACKAGE BODY WORKDESK."UTL_WORKDESK" 
is
PROCEDURE needs_margin_approval
(
  worksheet_id        IN number,
  profit              IN number, 
  exchange_rate       IN number,
  weight              IN number,
  uom                 IN varchar2,
  gp_margin           IN number, 
  sales_trader_id     IN number,
  needs_approval      OUT varchar2,
  reason_for_approval OUT varchar2
)
IS
  l_reason1 boolean := FALSE;
  l_reason2 boolean := FALSE;
  l_reason3 boolean := FALSE;
  l_gp      number;
  l_gp_mt   number;
  l_gp_p    number;
  l_gp_calc number;
  l_to_mt   number;
  l_1st_ex  boolean := FALSE;
  l_2nd_ex  boolean := FALSE;
  l_so_ex   number;
  l_po_ex   number;
  l_su_ex   number;
BEGIN
  -- 1st exclusion
  SELECT COUNT(*)
    INTO l_so_ex
    FROM ow_so_trader_exclusions
   WHERE tk_emp_trader = sales_trader_id;
  IF l_so_ex > 0 THEN
    l_1st_ex := TRUE;
  END IF; 
  -- 2nd exclusion
  IF NOT l_1st_ex THEN
    --
    SELECT COUNT(*)
      INTO l_po_ex
      FROM ow_sale_alloc a,
           worksheet b, 
           ow_po_trader_exclusions c
     WHERE a.po_set_wrksht_num = b.set_wrksht_num
       AND b.tk_emp_po_trader = c.tk_emp_trader
       AND a.tk_ow = worksheet_id;
    --
    SELECT COUNT(*)
      INTO l_su_ex
      FROM ow_sale_alloc a,
           worksheet b, 
           ow_supplier_exclusions c
     WHERE a.po_set_wrksht_num = b.set_wrksht_num
       AND b.prdvnd_vendor_id = c.vendor_id
       AND a.tk_ow = worksheet_id;
    --
    IF l_po_ex > 0 OR l_su_ex > 0 THEN
      l_2nd_ex := TRUE;  
    END IF;         
  END IF;
  -- 1st reason for approval. 
  IF NOT l_1st_ex AND NOT l_2nd_ex THEN
    BEGIN
      SELECT gp, gp_mt, gp_p 
        INTO l_gp, l_gp_mt, l_gp_p
        FROM ow_approval_treshold;
    END;
    IF profit < l_gp THEN
      l_reason1 := TRUE;
    END IF;
  -- 2nd reason for approval.
    IF uom = 'MT' THEN
      IF weight = 0 THEN
        l_gp_calc := profit;
      ELSE   
        l_gp_calc := profit / weight;
      END IF;  
    ELSE
      BEGIN
        SELECT multiplier
          INTO l_to_mt
          FROM measure_conversion
         WHERE from_uom = uom
           AND to_uom = 'MT';
      END;
      IF (weight * l_to_mt) = 0 THEN
        l_gp_calc := profit;
      ELSE 
        l_gp_calc := profit / (weight * l_to_mt);
      END IF;  
    END IF;
    IF l_gp_calc < l_gp_mt THEN
      l_reason2 := TRUE;
    END IF;
  -- 3rd reason for approval
    IF gp_margin < l_gp_p THEN
      l_reason3 := TRUE;
    END IF;
  END IF;
  IF l_reason1 OR
     l_reason2 OR
     l_reason3 THEN
    needs_approval := 'Y';
    IF l_reason1 THEN
      reason_for_approval := reason_for_approval || 'Gross profit on this worksheet is below gp threshold of - $' || to_char (l_gp) || '. ';
    END IF;
    IF l_reason2 THEN
      reason_for_approval := reason_for_approval || 'Gross profit per metric ton on this worksheet is below gp/mt threshold of $' || to_char(l_gp_mt) || '/mt. ';
    END IF;
    IF l_reason3 THEN
      reason_for_approval := reason_for_approval || 'Gross profit margin on this worksheet is below the GP margin threshold of ' || to_char(l_gp_p) || '%.';
    END IF;
  ELSE
    needs_approval := 'N';
    reason_for_approval := NULL;            
  END IF;
END;
--
PROCEDURE email_managers
(
  worksheet_id        IN number,
  email               OUT varchar2
) IS
  ws_rgn_id region.rgn_id%TYPE;
BEGIN
  BEGIN 
    SELECT region.rgn_id
      INTO ws_rgn_id 
      FROM region, 
           rgn_cntry, 
           country, 
           ow_worksheet 
     WHERE ow_worksheet.dest_tk_cntry = country.tk_cntry
       AND country.tk_cntry = rgn_cntry.tk_cntry
       AND rgn_cntry.tk_rgn = region.tk_rgn
       AND rgn_cntry.active_closed = 'A'
       AND ow_worksheet.tk_ow = worksheet_id;
  EXCEPTION
    WHEN OTHERS THEN
      ws_rgn_id := NULL;       
  END;
  IF ws_rgn_id IS NOT NULL THEN
    BEGIN
      SELECT m_email
        INTO email
        FROM email_by_region
       WHERE rgn_id = ws_rgn_id;
    EXCEPTION
      WHEN OTHERS THEN
        email := NULL;    
    END;
  ELSE
    email := NULL;
  END IF;     
END;

PROCEDURE UTL_OW_TEMPLATE_COPY_BY_USER
(
  p_owner              IN numeric,
  p_new_owner          IN numeric,
  p_Fec_Des            IN DATE,
  p_Fec_Has             IN DATE
) IS 
            v_description     OW_WORKSHEET.DESCRIPTION%TYPE ;
              v_new_tk_ow integer :=0;
              v_new_worksheet_num integer :=0;
              CURSOR cTemplates IS
              select TK_OW as tk_ow
            from ow_worksheet
            where type = 'TEMPLATE'
            and created_by = p_owner -- de quien inicialmente Lindsey
            and tk_ow not in (select template_tk_ow from ow_contract)
            and last_update_date >= p_Fec_Des
            and last_update_date <= p_Fec_Has
            and new_ow is null;
                tempRow cTemplates%ROWTYPE;
        BEGIN
           FOR tempRow IN cTemplates
           LOOP
               
                --GENERAR UN NUEVO TK
                SELECT WORKDESK.SEQ_OW_TK.NEXTVAL into v_new_tk_ow FROM DUAL;
                SELECT ATISPROD.SEQ_WORKSHEET.NEXTVAL into v_new_worksheet_num FROM DUAL;
                -- Description Rule
                BEGIN
                    SELECT 'NEW '||DESCRIPTION into v_description
                    FROM OW_WORKSHEET  
                    WHERE TK_OW = tempRow.tk_ow;
                  Exception when no_data_found then v_description  := APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(v_new_worksheet_num);
                End;

               WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(tempRow.tk_ow, 'TEMPLATE',v_new_tk_ow, v_new_worksheet_num, 16816);
                --Actualizo el Owner
                    update ow_worksheet set created_by = owner, owner = p_new_owner, description = v_description where tk_ow = v_new_tk_ow;
                --Actualizo la descripcion
                commit;
           END LOOP;    
        END;

        FUNCTION FORMAT_NUMBER(P_NUMBER IN NUMBER) RETURN VARCHAR2 IS
            V_FORMATTED_NUMBER VARCHAR2(50);
        BEGIN
            V_FORMATTED_NUMBER := TO_CHAR(P_NUMBER,'FM999G999G999G999G990D999');
            
            IF P_NUMBER - TRUNC(P_NUMBER) = 0 THEN
                V_FORMATTED_NUMBER := SUBSTR(V_FORMATTED_NUMBER,0,LENGTH(V_FORMATTED_NUMBER) - 1);
            END IF;
            
            RETURN V_FORMATTED_NUMBER;
        END;
end;
/


GRANT EXECUTE ON WORKDESK.UTL_WORKDESK TO OMS;

GRANT EXECUTE ON WORKDESK.UTL_WORKDESK TO PUBLIC;
