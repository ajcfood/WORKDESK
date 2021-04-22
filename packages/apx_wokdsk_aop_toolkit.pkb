DROP PACKAGE BODY WORKDESK.APX_WOKDSK_AOP_TOOLKIT;

CREATE OR REPLACE PACKAGE BODY WORKDESK.APX_WOKDSK_AOP_TOOLKIT AS
PROCEDURE GET_UNIQUE_PER(p_tk_ow NUMBER,v_status VARCHAR2,v_per OUT VARCHAR2,v_per_flag OUT NUMBER)
IS
    v_num_of_per NUMBER := 0;
    
BEGIN
    IF v_status = 'UNPUBLISHED' THEN 
        SELECT COUNT(DISTINCT pur_price_uom)
        into v_num_of_per   
        FROM WORKDESK.OW_PO_PRD_LINE
        WHERE TK_OW = p_tk_ow;   
        
        IF v_num_of_per > 1 THEN
            v_per_flag := 1; 
        ELSE
            SELECT DISTINCT pur_price_uom
            into v_per   
            FROM WORKDESK.OW_PO_PRD_LINE
            WHERE TK_OW = p_tk_ow;     
            v_per_flag := 0;
        END IF;
    ELSIF v_status = 'PUBLISHED' THEN
        SELECT COUNT(DISTINCT pur_price_uom)
        into v_num_of_per   
        FROM WORKDESK.OW_PO_PRD_LINE_PUB
        WHERE TK_OW = p_tk_ow;   
        
        IF v_num_of_per > 1 THEN
            v_per_flag := 1; 
        ELSE
            SELECT DISTINCT pur_price_uom
            into v_per   
            FROM WORKDESK.OW_PO_PRD_LINE_PUB
            WHERE TK_OW = p_tk_ow;     
            v_per_flag := 0;
        END IF;    
    END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
    v_per_flag := 1;
END GET_UNIQUE_PER;
PROCEDURE GET_UNIQUE_UOM(p_tk_ow NUMBER,v_status VARCHAR2,v_uom OUT VARCHAR2,v_uom_flag OUT NUMBER)
IS
    v_num_of_uom NUMBER := 0;
    
BEGIN
    IF v_status = 'UNPUBLISHED' THEN 
        SELECT COUNT(DISTINCT WT_UOM)
        into v_num_of_uom   
        FROM WORKDESK.OW_WS_PRD_LINE
        WHERE TK_OW = p_tk_ow;   
        
        IF v_num_of_uom > 1 THEN
            v_uom_flag := 1; 
        ELSE
            SELECT DISTINCT WT_UOM
            into v_uom   
            FROM WORKDESK.OW_WS_PRD_LINE
            WHERE TK_OW = p_tk_ow;     
            v_uom_flag := 0;
        END IF;
    ELSIF v_status = 'PUBLISHED' THEN
        SELECT COUNT(DISTINCT WT_UOM)
        into v_num_of_uom   
        FROM WORKDESK.OW_WS_PRD_LINE_PUB
        WHERE TK_OW = p_tk_ow;   
        
        IF v_num_of_uom > 1 THEN
            v_uom_flag := 1; 
        ELSE
            SELECT DISTINCT WT_UOM
            into v_uom   
            FROM WORKDESK.OW_WS_PRD_LINE_PUB
            WHERE TK_OW = p_tk_ow;     
            v_uom_flag := 0;
        END IF;    
    END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
    v_uom_flag := 1;
END GET_UNIQUE_UOM;
FUNCTION RET_COLOR(p_vers NUMBER,p_color VARCHAR2 DEFAULT '#E7E6E6') RETURN VARCHAR2
IS
BEGIN
    IF p_vers = 0 THEN
        RETURN p_color;
    ELSE
        RETURN '#FFFF00';
    END IF;
END RET_COLOR;
FUNCTION GET_MISC_CHARGES_CONTRACT (p_tk_ow NUMBER) RETURN sys_refcursor
IS
    v_pre_version_num NUMBER;
    v_set_wrksht_num  NUMBER; 
    v_status          VARCHAR2(30);
    rf_cur            sys_refcursor; 
BEGIN

    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;  
    IF v_status = 'UNPUBLISHED' THEN 
        open rf_cur for
            SELECT misc.LINE_NUM AS "MISC_L", upper(misc.CHARGES) AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost) AS "MISC_COS"
            , misc.currency AS "MISC_CU", misc.per AS "MISC_PE", WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.total) AS "MISC_TO"
                    ,'#E7E6E6' AS "MISC_CH_cell_background_color"
                    ,'#E7E6E6' AS "MISC_TY_cell_background_color"
                    ,'#E7E6E6' AS "MISC_COS_cell_background_color"
                    ,'#E7E6E6' AS "MISC_CU_cell_background_color"
                    ,'#E7E6E6' AS "MISC_PE_cell_background_color"
                    ,'#E7E6E6' AS "MISC_TO_cell_background_color"
                    ,'#E7E6E6' AS "MISC_FI_cell_background_color"
            ,CASE 
                WHEN misc.currency = '$' THEN  
                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                WHEN misc.currency = '%' THEN 
                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                ELSE NULL 
            END AS "MISC_FI"                    
            FROM OW_MISC_CHARGES MISC, MISC_CHG_TYPE m_types, ow_worksheet we
            WHERE misc.tk_ow     = p_tk_ow
            AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE   
            AND we.tk_ow         = misc.tk_ow 
            AND misc.total       > 0
            order by 1 asc;   
    ELSIF v_status = 'PUBLISHED' THEN  
        BEGIN            
            SELECT set_wrksht_num
            into v_set_wrksht_num
            FROM OW_WORKSHEET_PUB
            WHERE tk_ow = p_tk_ow;

            SELECT max(version_num)-1 
            into v_pre_version_num
            FROM OW_WORKSHEET_PUB
            WHERE set_wrksht_num = v_set_wrksht_num;
        EXCEPTION WHEN OTHERS THEN
           v_set_wrksht_num  := NULL;
           v_pre_version_num := 0;
        END;                                                    
        open rf_cur for                                                                   
            SELECT 
             new_ver.MISC_L   AS "MISC_L" 
            ,upper(new_ver.MISC_CH)  AS "MISC_CH"
            ,CASE WHEN nvl(new_ver.MISC_CH,' ') <> nvl(old_ver.MISC_CH,' ') THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_CH_cell_background_color"
            ,new_ver.MISC_TY  AS "MISC_TY"
            ,CASE WHEN nvl(new_ver.MISC_TY,' ') <> nvl(old_ver.MISC_TY,' ') THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_TY_cell_background_color"
            ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.MISC_COS) AS "MISC_COS"
            ,CASE WHEN nvl(new_ver.MISC_COS,0)  <> nvl(old_ver.MISC_COS,0)  THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_COS_cell_background_color"
            ,new_ver.MISC_CU  AS "MISC_CU"
            ,CASE WHEN nvl(new_ver.MISC_CU,' ') <> nvl(old_ver.MISC_CU,' ') THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_CU_cell_background_color"
            ,new_ver.MISC_PE  AS "MISC_PE"
            ,CASE WHEN nvl(new_ver.MISC_PE,' ') <> nvl(old_ver.MISC_PE,' ') THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_PE_cell_background_color"
            ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.MISC_TO)  AS "MISC_TO"
            ,CASE WHEN nvl(new_ver.MISC_TO,0)   <> nvl(old_ver.MISC_TO,0)   THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_TO_cell_background_color"
            ,new_ver.MISC_FI  AS "MISC_FI"
            ,CASE WHEN nvl(new_ver.MISC_FI,' ') <> nvl(old_ver.MISC_FI,' ') THEN RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "MISC_FI_cell_background_color"
            FROM 
                ( 
                    SELECT misc.LINE_NUM AS "MISC_L", misc.CHARGES AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", misc.cost AS "MISC_COS", misc.currency AS "MISC_CU", misc.per AS "MISC_PE", misc.total AS "MISC_TO"
                            ,CASE 
                                WHEN misc.currency = '$' THEN  
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                                WHEN misc.currency = '%' THEN 
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                                ELSE NULL 
                            END AS "MISC_FI"                     
                    FROM OW_MISC_CHARGES_PUB MISC, MISC_CHG_TYPE m_types, ow_worksheet_pub we
                    WHERE misc.tk_ow = p_tk_ow
                    AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE
                    AND we.tk_ow         = misc.tk_ow 
                    AND misc.total       > 0                   
                )new_ver left join (  
                    SELECT misc.LINE_NUM AS "MISC_L", misc.CHARGES AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", misc.cost AS "MISC_COS", misc.currency AS "MISC_CU", misc.per AS "MISC_PE", misc.total AS "MISC_TO"
                            ,CASE 
                                WHEN misc.currency = '$' THEN  
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                                WHEN misc.currency = '%' THEN 
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                                ELSE NULL 
                            END AS "MISC_FI"                                        
                    FROM OW_MISC_CHARGES_PUB MISC, MISC_CHG_TYPE m_types, ow_worksheet_pub we
                    WHERE misc.tk_ow in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num and version_num = v_pre_version_num)
                    AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE
                    AND we.tk_ow         = misc.tk_ow 
                    AND misc.total       > 0                                       
                )old_ver
            --on new_ver.MISC_TY = old_ver.MISC_TY /*Producto cartesiano reportado por Beth*/
            on new_ver.MISC_L = old_ver.MISC_L        
            order by 1 asc;                      
    END IF;
   
    RETURN rf_cur;
END GET_MISC_CHARGES_CONTRACT;
FUNCTION GET_DATES_FOR_CONTRACT(p_tk_contract NUMBER,p_status VARCHAR2) RETURN sys_refcursor
IS
    rf_cur   sys_refcursor; 
BEGIN
    IF p_tk_contract <> 0 THEN
        IF p_status = 'UNPUBLISHED' THEN 
        open rf_cur for
            SELECT OW.SET_WRKSHT_NUM as "PO", UPPER(ORD.PICKUP_PERIOD_DESCR) as "DATE"
            FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW, OW_PUR_ORD ORD
            WHERE WS.TK_CONTRACT = p_tk_contract 
            AND WS.TK_OW = OW.TK_OW
            AND ORD.TK_OW = OW.TK_OW
            order by OW.SET_WRKSHT_NUM asc; 
        ELSIF p_status = 'PUBLISHED' THEN
        open rf_cur for   
            SELECT OW.SET_WRKSHT_NUM as "PO", UPPER(ORD.PICKUP_PERIOD_DESCR) as "DATE"
            FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET_PUB OW, OW_PUR_ORD_PUB ORD
            WHERE WS.TK_CONTRACT = p_tk_contract 
            AND WS.TK_OW = OW.TK_OW
            AND ORD.TK_OW = OW.TK_OW
            order by OW.SET_WRKSHT_NUM asc; 
        end if;
    ELSE
        open rf_cur for SELECT SYSDATE as "USER" FROM DUAL;
    END IF;
    RETURN rf_cur;
END;
FUNCTION GET_MISC_CHARGES (p_tk_ow NUMBER,p_set_wrksht_num NUMBER,p_status VARCHAR2,p_pre_version_num NUMBER) RETURN sys_refcursor
IS
    v_status  VARCHAR2(30);
    rf_cur   sys_refcursor; 
BEGIN

    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;  
    IF v_status = 'UNPUBLISHED' THEN 
        open rf_cur for
            SELECT misc.LINE_NUM AS "MISC_L", upper(misc.CHARGES) AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost) AS "MISC_COS"
            , misc.currency AS "MISC_CU", misc.per AS "MISC_PE", WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.total) AS "MISC_TO"
                    ,'#E7E6E6' AS "MISC_CH_cell_background_color"
                    ,'#E7E6E6' AS "MISC_TY_cell_background_color"
                    ,'#E7E6E6' AS "MISC_COS_cell_background_color"
                    ,'#E7E6E6' AS "MISC_CU_cell_background_color"
                    ,'#E7E6E6' AS "MISC_PE_cell_background_color"
                    ,'#E7E6E6' AS "MISC_TO_cell_background_color"
                    ,'#E7E6E6' AS "MISC_FI_cell_background_color"
            ,CASE 
                WHEN misc.currency = '$' THEN  
                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                WHEN misc.currency = '%' THEN 
                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                ELSE NULL 
            END AS "MISC_FI"                    
            FROM OW_MISC_CHARGES MISC, MISC_CHG_TYPE m_types, ow_worksheet we
            WHERE misc.tk_ow     = p_tk_ow
            AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE   
            AND we.tk_ow         = misc.tk_ow 
            AND misc.total       > 0
            order by 1 asc;   
    ELSIF v_status = 'PUBLISHED' THEN                                                  
        open rf_cur for                                                                   
            SELECT 
             new_ver.MISC_L   AS "MISC_L" 
            ,upper(new_ver.MISC_CH)  AS "MISC_CH"
            ,CASE WHEN nvl(new_ver.MISC_CH,' ') <> nvl(old_ver.MISC_CH,' ') THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END AS "MISC_CH_cell_background_color"
            ,new_ver.MISC_TY  AS "MISC_TY"
            ,CASE WHEN nvl(new_ver.MISC_TY,' ') <> nvl(old_ver.MISC_TY,' ') THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END AS "MISC_TY_cell_background_color"
            ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.MISC_COS) AS "MISC_COS"
            ,CASE WHEN nvl(new_ver.MISC_COS,0) <> nvl(old_ver.MISC_COS,0) THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END   AS "MISC_COS_cell_background_color"
            ,new_ver.MISC_CU  AS "MISC_CU"
            ,CASE WHEN nvl(new_ver.MISC_CU,' ') <> nvl(old_ver.MISC_CU,' ') THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END AS "MISC_CU_cell_background_color"
            ,new_ver.MISC_PE  AS "MISC_PE"
            ,CASE WHEN nvl(new_ver.MISC_PE,' ') <> nvl(old_ver.MISC_PE,' ') THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END AS "MISC_PE_cell_background_color"
            ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.MISC_TO)  AS "MISC_TO"
            ,CASE WHEN nvl(new_ver.MISC_TO,0) <> nvl(old_ver.MISC_TO,0) THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END     AS "MISC_TO_cell_background_color"
            ,new_ver.MISC_FI  AS "MISC_FI"
            ,CASE WHEN nvl(new_ver.MISC_FI,' ') <> nvl(old_ver.MISC_FI,' ') THEN RET_COLOR(p_pre_version_num) ELSE '#E7E6E6' END AS "MISC_FI_cell_background_color"
            FROM 
                ( 
                    SELECT misc.LINE_NUM AS "MISC_L", misc.CHARGES AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", misc.cost AS "MISC_COS", misc.currency AS "MISC_CU", misc.per AS "MISC_PE", misc.total AS "MISC_TO"
                            ,CASE 
                                WHEN misc.currency = '$' THEN  
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                                WHEN misc.currency = '%' THEN 
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                                ELSE NULL 
                            END AS "MISC_FI"                     
                    FROM OW_MISC_CHARGES_PUB MISC, MISC_CHG_TYPE m_types, ow_worksheet_pub we
                    WHERE misc.tk_ow = p_tk_ow
                    AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE
                    AND we.tk_ow         = misc.tk_ow 
                    AND misc.total       > 0                   
                )new_ver left join (  
                    SELECT misc.LINE_NUM AS "MISC_L", misc.CHARGES AS "MISC_CH", m_types.chg_type_id AS "MISC_TY", misc.cost AS "MISC_COS", misc.currency AS "MISC_CU", misc.per AS "MISC_PE", misc.total AS "MISC_TO"
                            ,CASE 
                                WHEN misc.currency = '$' THEN  
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||' '|| we.currency_code || (CASE WHEN misc.per is not null then ('/' || misc.per) else '' end)
                                WHEN misc.currency = '%' THEN 
                                    WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(misc.cost)||'%'
                                ELSE NULL 
                            END AS "MISC_FI"                                        
                    FROM OW_MISC_CHARGES_PUB MISC, MISC_CHG_TYPE m_types, ow_worksheet_pub we
                    WHERE misc.tk_ow in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = p_set_wrksht_num and version_num = p_pre_version_num)
                    AND misc.TK_CHG_TYPE = m_types.TK_CHG_TYPE
                    AND we.tk_ow         = misc.tk_ow 
                    AND misc.total       > 0                                       
                )old_ver
            --on new_ver.MISC_TY = old_ver.MISC_TY /*Producto cartesiano reportado por Beth*/
            on new_ver.MISC_L = old_ver.MISC_L        
            order by 1 asc;                      
    END IF;
   
    RETURN rf_cur;
END GET_MISC_CHARGES;
FUNCTION GET_CONTRACT_AND_WRKSHT_DATA (p_tk_ow NUMBER) RETURN sys_refcursor
IS
    v_pre_version_num         NUMBER;
    v_set_wrksht_num          NUMBER;  
    v_has_misc_charges        VARCHAR2(500);
    v_has_misc_charges_prev   VARCHAR2(500); 
    v_status                  VARCHAR2(30);
    rf_cur                    sys_refcursor;

    v_usd_total               NUMBER;
    v_total_cases             NUMBER;    
    v_total_weight            NUMBER;   
    v_total_price             NUMBER;
    v_total_pur               NUMBER;
    v_grand_total             NUMBER;
    v_exchange_rate_num       NUMBER; 
    v_prev_tk_ow              NUMBER;
    v_grand_total_CHNG        VARCHAR2(1000);    
    v_total_cases_CHNG        VARCHAR2(1000);
    v_total_weight_CHNG       VARCHAR2(1000);
    v_total_price_CHNG        VARCHAR2(1000);
    v_total_pur_CHNG          VARCHAR2(1000);
    v_usd_total_CHNG          VARCHAR2(1000);         
    v_misc_change             VARCHAR2(1000);
    v_bank_descr              VARCHAR2(500);
    v_exchange_rate           VARCHAR2(500);
    v_valuation_date          VARCHAR2(500);
    v_contract_number         VARCHAR2(500);
    v_exchange_rate_CHNG      VARCHAR2(500);
BEGIN
    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;
    
    GET_TOTALS(
         p_tk_ow
        ,v_status
        ,v_total_cases     
        ,v_total_weight   
        ,v_total_price
        ,v_total_pur
        );
              
    IF v_status = 'UNPUBLISHED' THEN 
    --Misc charges changes
        SELECT to_char(sum(total))
        into v_has_misc_charges
        FROM OW_MISC_CHARGES
        WHERE TK_OW = p_tk_ow;
        
        v_grand_total :=  v_has_misc_charges + v_total_pur;
        v_usd_total := v_exchange_rate_num * v_grand_total;

        open rf_cur for
        select  
                 SET_WRKSHT_NUM                                                                                                       AS PO_NUMBER
                ,CASE WHEN NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY)),' ') <> NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY)),' ') THEN	
                    NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY)),' ')|| '/' ||NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY)),' ')
                 ELSE
                    NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY)),' ')
                 END AS CO_FOR_EU
                ,v_status                                                                                                             AS V_STATUS
                ,OW.CO_TK_ORG                                                                                                          
                ,v_has_misc_charges                                                                                                   AS MISC_YN
                ,OW.CURRENCY_CODE                                                                                                     AS CURR1
                ,to_char(PUR.PURCHASE_DATE,'DD-MON-YYYY')                                                                             AS PO_DATE
                ,UPPER(PUR.PICKUP_PERIOD_DESCR)                                                                                              AS P_DATE
                ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID)                                                              AS PO_SUP
                ,GET_DEF_COUNTRY_NAME(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY)))                               AS INSP_FOR
                ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY))                                                     AS INSP_FOM
                ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY))                                                     AS DES_CM
                ,APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR)                                                        AS PO_TERMS
                ,GET_DEF_COUNTRY_NAME(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY)))                               AS DES_CO
                ,PUR.PAY_TERM_DESCR                                                                                                   AS PO_PAY_T
                ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'SUPPLIER'))                                           AS S_NOTES
                ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'INTERNAL'))                                           AS I_NOTES
                ,PUR.TK_EMP_TRADER                                                                                                  
                ,PUR.TK_EMP_TRF                                                                                                     
                ,UPPER(PUR.CONTACT)                                                                                                          AS PO_LOC_C
                ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(OW.DEST_PORT))                                                                   AS D_PORT
                ,TO_CHAR(VERSION_NUM)                                                                                                 AS VER
                ,UPPER(FORX.BANK_DESCR)                                                                                                      AS BANK
                ,FORX.EXCHANGE_RATE                                                                                                   AS RATE
                ,to_char((NVL(FORX.EXCHANGE_RATE,1))*(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))) AS US_TOT_V
                ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_CASES'))                               AS TOTAL_CASES
                ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_WEIGHT'))                              AS TOTAL_WEIGHT                                                
                ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))                               AS TOTAL_PRICE                                                           
                ,to_char(VALUATION_DATE,'DD-MON-YY')                                                                                  AS VAL_DATE
                ,UPPER(CONTRACT_NUMBER)                                                                                                      AS CONT_NUM
                ,UPPER(initcap(EMP1.FULL_NAME))                                                                                              AS PO_TR_N
                ,UPPER(EMP1.PHONE)                                                                                                           AS PO_TRADER_PHONE                                 
                ,UPPER(lower(EMP1.EMAIL))                                                                                                    AS PO_TRADER_EMAIL
                ,UPPER(initcap(EMP2.FULL_NAME))                                                                                              AS PO_TRF_N
                ,UPPER(EMP2.PHONE)                                                                                                           AS PO_TRAFFIC_PHONE
                ,UPPER(lower(EMP2.EMAIL))                                                                                                    AS PO_TRAFFIC_EMAIL
                ,UPPER(comp.co_name)                                                                                                         AS C_NAME  
                ,UPPER(comp.addr1)                                                                                                           AS COMPANY_ADDRESS1
                ,UPPER(comp.city)                                                                                                            AS COMPANY_CITY  
                ,UPPER(comp.state)                                                                                                           AS COMPANY_STATE 
                ,UPPER(comp.zip)                                                                                                             AS COMPANY_ZIP   
                ,UPPER(comp.cntry_name)                                                                                                      AS COMPANY_COUNTRY
                ,'http://'||comp.termsconditionurl                                                                                    AS TC_URL
                ,case when (to_char(v_total_cases))=0 THEN '' ELSE (to_char(v_total_cases)) END                                       AS TOT_C
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)                                                        AS TOT_W                  
                ,case when (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)))='0' THEN '' ELSE (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight))) END AS TOT_W
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_price)                                                         AS TOT_P
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_pur)                                                           AS TOT_PUR  
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_has_misc_charges)                                                    AS MISC_Y
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total)                                                         AS G_TOTAL
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total)                                                         AS G_TOTAL
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total)                                                           AS US_TOT_V
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total) else '-' end  AS G_TOTALH                                        
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total) else '-' end    AS US_TOT_V                        
                ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(p_tk_ow, v_status, 'SUPPLIER')                                    AS S_NOTES
                ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(p_tk_ow, v_status, 'INTERNAL')                                    AS I_NOTES  
                ,UPPER(workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(ow.orig_tk_cntry))                                                   AS V_OR_CO
                ,UPPER(workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(ow.province))                                                       AS V_PROV
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_UOM_FOR_TOTALS(p_tk_ow,v_status)                                                        AS UOM_TOT               
        from OW_WORKSHEET OW,WORKDESK.OW_PUR_ORD PUR, OW_WS_FOREX FORX, A_EMPLOYEE EMP1, A_EMPLOYEE EMP2,
        (SELECT * FROM COMPANY comp, country coun WHERE comp.tk_cntry = coun.tk_cntry) COMP                                    
        WHERE OW.tk_ow         = PUR.tk_ow 
        AND   OW.tk_ow         = p_tk_ow
        AND   OW.tk_ow         = FORX.tk_ow (+)
        AND   PUR.TK_EMP_TRADER = EMP1.TK_EMPLOYEE (+)
        AND   PUR.TK_EMP_TRF    = EMP2.TK_EMPLOYEE (+)
        AND   OW.CO_TK_ORG      = comp.tk_org (+)                              
        ;                                    
    ELSIF v_status = 'PUBLISHED' THEN
        SELECT SET_WRKSHT_NUM
        into v_set_wrksht_num
        FROM WORKDESK.OW_WORKSHEET_PUB
        WHERE tk_ow = p_tk_ow;
        
        SELECT VERSION_NUM -1
        into v_pre_version_num
        FROM WORKDESK.OW_WORKSHEET
        WHERE SET_WRKSHT_NUM = V_SET_WRKSHT_NUM;    
        BEGIN
            begin
                select tk_ow into v_prev_tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num and version_num = v_pre_version_num;
            exception when no_data_found then
                v_prev_tk_ow :=0;
            end;
            IF v_prev_tk_ow > 0 THEN
                GET_TOTALS(
                 v_prev_tk_ow
                ,'PUBLISHED'
                ,v_total_cases_CHNG     
                ,v_total_weight_CHNG   
                ,v_total_price_CHNG
                ,v_total_pur_CHNG
                ); 
                IF v_total_cases_CHNG  <> v_total_cases  THEN v_total_cases_CHNG  := '#FFFF00'; ELSE v_total_cases_CHNG := '#FFFFFF'; END IF; 
                IF v_total_weight_CHNG <> v_total_weight THEN v_total_weight_CHNG := '#FFFF00'; ELSE v_total_weight_CHNG := '#FFFFFF'; END IF;
                IF v_total_price_CHNG  <> v_total_price  THEN v_total_price_CHNG  := '#FFFF00';v_usd_total_CHNG := '#FFFF00';v_grand_total_CHNG:= '#FFFF00'; ELSE v_total_price_CHNG := '#FFFFFF'; v_usd_total_CHNG := '#FFFFFF';v_grand_total_CHNG:= '#FFFFFF'; END IF;
                IF v_total_pur_CHNG    <> v_total_pur    THEN v_total_pur_CHNG    := '#FFFF00'; ELSE v_total_pur_CHNG := '#FFFFFF'; END IF;
            ELSE
                v_total_cases_CHNG  := '#FFFFFF';                
                v_total_weight_CHNG := '#FFFFFF';            
                v_total_price_CHNG  := '#FFFFFF';            
                v_total_pur_CHNG    := '#FFFFFF';
                v_usd_total_CHNG    := '#FFFFFF';
                v_grand_total_CHNG  := '#FFFFFF';                      
            END IF;     
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_total_cases_CHNG  := '#FFFFFF';   
            v_total_weight_CHNG := '#FFFFFF';  
            v_total_price_CHNG  := '#FFFFFF';   
            v_usd_total_CHNG    := '#FFFFFF';
            v_grand_total_CHNG  := '#FFFFFF';
        END; 
        BEGIN
            SELECT 
                 BANK_DESCR
                ,EXCHANGE_RATE
                ,NVL(EXCHANGE_RATE,1)
                ,VALUATION_DATE
                ,CONTRACT_NUMBER
            into   
                 v_bank_descr
                ,v_exchange_rate
                ,v_exchange_rate_num
                ,v_valuation_date 
                ,v_contract_number           
            FROM OW_WS_FOREX
            WHERE TK_OW = p_tk_ow;  
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_bank_descr     := NULL;
            v_exchange_rate  := NULL;
            v_valuation_date := NULL;
        END;  
        BEGIN
            SELECT CASE WHEN EXCHANGE_RATE <> v_exchange_rate         THEN '#FFFF00' ELSE '#FFFFFF' END
            into  v_exchange_rate_CHNG               
            FROM OW_WS_FOREX_PUB
            WHERE TK_OW = ( SELECT tk_ow 
                            FROM WORKDESK.OW_WORKSHEET_PUB 
                            WHERE SET_WRKSHT_NUM      = v_set_wrksht_num
                            AND   VERSION_NUM         = v_pre_version_num); 
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            IF v_pre_version_num <> 0 THEN
                v_exchange_rate_CHNG      := '#FFFF00';
            ELSE
                v_exchange_rate_CHNG      := '#FFFFFF';                           
            END IF;       
        END;

        --Misc charges changes
        SELECT new_ver.total,CASE WHEN nvl(new_ver.total,0) <> nvl(old_ver.total,0) THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END 
        into v_has_misc_charges,v_has_misc_charges_prev
        FROM 
            (SELECT to_char(nvl(sum(total),0)) total
             FROM OW_MISC_CHARGES_PUB
             WHERE TK_OW = p_tk_ow)new_ver,    
            (SELECT to_char(nvl(sum(total),0)) total
             FROM OW_MISC_CHARGES_PUB
             WHERE TK_OW in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num and version_num = v_pre_version_num))old_ver;  
        --Misc charges changes 
        --CHECK FOR UPDATES IN PREVIOUS VERSION    
                
        v_grand_total :=  v_has_misc_charges + v_total_pur;
        v_usd_total := v_exchange_rate_num * v_grand_total;

        IF v_has_misc_charges_prev = '#FFFF00' OR v_total_pur_CHNG = '#FFFF00' THEN
            v_grand_total_CHNG := '#FFFF00';
        ELSE
            v_grand_total_CHNG := '#FFFFFF';
        END IF; 

        IF v_exchange_rate_CHNG = '#FFFF00' OR v_grand_total_CHNG = '#FFFF00' THEN
            v_usd_total_CHNG   := '#FFFF00'; 
        ELSE
            v_usd_total_CHNG   := '#FFFFFF';
        END IF;        

        IF v_has_misc_charges_prev = '#FFFFFF' THEN
            v_misc_change := '#FFFFFF';
        ELSE
            v_misc_change := '#FFFF00';
        END IF;            
        
        BEGIN            
            SELECT set_wrksht_num
            into v_set_wrksht_num
            FROM OW_WORKSHEET_PUB
            WHERE tk_ow = p_tk_ow;

            SELECT max(version_num)-1 
            into v_pre_version_num
            FROM OW_WORKSHEET_PUB
            WHERE set_wrksht_num = v_set_wrksht_num;
        EXCEPTION WHEN OTHERS THEN
           v_set_wrksht_num  := NULL;
           v_pre_version_num := 0;
        END;

        open rf_cur for                                                                   
        SELECT 
                 CASE WHEN NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(new_ver.DES_CO)),' ') <> NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(new_ver.INSP_FOR)),' ') THEN	
                    NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(new_ver.DES_CO)),' ')|| '/' ||NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(new_ver.INSP_FOR)),' ')
                 ELSE
                    NVL(UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(new_ver.DES_CO)),' ')
                 END AS CO_FOR_EU        
                ,UPPER(v_status) AS "V_STATUS"
                ,UPPER(new_ver.PO_PAY_T)  AS "PO_PAY_T"
                ,CASE WHEN nvl(new_ver.PO_PAY_T,' ') <> nvl(old_ver.PO_PAY_T,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_PAY_T_cell_background_color"        
                ,UPPER(new_ver.INSP_FOR)  AS "INSP_FOR"
                ,CASE WHEN nvl(new_ver.INSP_FOR,' ') <> nvl(old_ver.INSP_FOR,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "INSP_FOR_cell_background_color"        
                ,UPPER(new_ver.D_PORT)  AS "D_PORT"
                ,CASE WHEN nvl(new_ver.D_PORT,' ')   <> nvl(old_ver.D_PORT,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "D_PORT_cell_background_color"        
                --
                ,UPPER(new_ver.INSP_FOM)  AS "INSP_FOM"
                ,CASE WHEN nvl(new_ver.INSP_FOR,' ') <> nvl(old_ver.INSP_FOR,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "INSP_FOM_cell_background_color"
                ,UPPER(new_ver.DES_CM)  AS "DES_CM"
                ,CASE WHEN nvl(new_ver.DES_CO,' ')   <> nvl(old_ver.DES_CO,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "DES_CM_cell_background_color"
                --
                ,UPPER(new_ver.DES_CO)  AS "DES_CO"
                ,CASE WHEN nvl(new_ver.DES_CO,' ')   <> nvl(old_ver.DES_CO,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "DES_CO_cell_background_color"        
                ,UPPER(new_ver.PO_SUP)  AS "PO_SUP"
                ,CASE WHEN nvl(new_ver.PO_SUP,' ')   <> nvl(old_ver.PO_SUP,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_SUP_cell_background_color"                
                ,UPPER(new_ver.PO_LOC_C)  AS "PO_LOC_C"
                ,CASE WHEN nvl(new_ver.PO_LOC_C,' ') <> nvl(old_ver.PO_LOC_C,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_LOC_C_cell_background_color"                
                ,UPPER(new_ver.PO_TERMS)  AS "PO_TERMS"
                ,CASE WHEN nvl(new_ver.PO_TERMS,' ') <> nvl(old_ver.PO_TERMS,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_TERMS_cell_background_color"       
                ,UPPER(new_ver.P_DATE)  AS "P_DATE"
                ,CASE WHEN nvl(new_ver.P_DATE,' ')   <> nvl(old_ver.P_DATE,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "P_DATE_cell_background_color"
                ,UPPER(new_ver.PO_TR_N)  AS "PO_TR_N"
                ,CASE WHEN nvl(new_ver.PO_TR_N,' ')  <> nvl(old_ver.PO_TR_N,' ')  THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_TR_N_cell_background_color"
                ,UPPER(new_ver.PO_DATE)  AS "PO_DATE"
                ,CASE WHEN nvl(new_ver.PO_DATE,' ')  <> nvl(old_ver.PO_DATE,' ')  THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_DATE_cell_background_color"
                ,UPPER(new_ver.C_NAME)  AS "C_NAME"
                ,CASE WHEN nvl(new_ver.C_NAME,' ')   <> nvl(old_ver.C_NAME,' ')   THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "C_NAME_cell_background_color"                                     
                ,UPPER(new_ver.PO_TRF_N)  AS "PO_TRF_N"
                ,CASE WHEN nvl(new_ver.PO_TRF_N,' ') <> nvl(old_ver.PO_TRF_N,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "PO_TRF_N_cell_background_color"        
                ,UPPER(new_ver.BANK)  AS "BANK"
                ,CASE WHEN nvl(new_ver.BANK,' ')     <> nvl(old_ver.BANK,' ')     THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "BANK_cell_background_color"        
                ,UPPER(new_ver.RATE)  AS "RATE"
                ,CASE WHEN nvl(new_ver.RATE,0)       <> nvl(old_ver.RATE,0)       THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "RATE_cell_background_color"                                        
                ,UPPER(new_ver.VAL_DATE)  AS "VAL_DATE"
                ,CASE WHEN nvl(new_ver.VAL_DATE,' ') <> nvl(old_ver.VAL_DATE,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "VAL_DATE_cell_background_color"
                ,UPPER(new_ver.CONT_NUM)  AS "CONT_NUM"
                ,CASE WHEN nvl(new_ver.CONT_NUM,' ') <> nvl(old_ver.CONT_NUM,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "CONT_NUM_cell_background_color"
                ,UPPER(new_ver.US_TOT_V)  AS "US_TOT_V"
                --,CASE WHEN nvl(new_ver.US_TOT_V,0)       <> nvl(old_ver.US_TOT_V,0)       THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "US_TOT_V_cell_background_color"
                ,UPPER(new_ver.CURR1)  AS "CURR1"
                ,CASE WHEN nvl(new_ver.CURR1,' ') <> nvl(old_ver.CURR1,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "CURR1_cell_background_color"
                ,v_has_misc_charges                                                AS MISC_YN
                ,case when (to_char(v_total_cases))=0 THEN '' ELSE (to_char(v_total_cases)) END                                             AS TOT_C
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)      AS TOT_W
                ,case when (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)))='0' THEN '' ELSE (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight))) END AS TOT_W                  
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_price)       AS TOT_P
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_pur)         AS TOT_PUR  
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_has_misc_charges)  AS MISC_Y
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total)       AS G_TOTAL
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total)       AS G_TOTAL                                
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total) else '-' end  AS G_TOTALH                                        
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total) else '-' end    AS US_TOT_V                                                
                --,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total)         AS US_TOT_V     
                ,v_total_cases_CHNG                                                 AS "TOT_C_cell_background_color"                    
                ,v_total_weight_CHNG                                                AS "TOT_W_cell_background_color" 
                ,v_total_pur_CHNG                                                   AS "TOT_PUR_cell_background_color"                         
                ,v_misc_change                                                      AS "MISC_Y_cell_background_color"                         
                ,v_grand_total_CHNG                                                 AS "G_TOTAL_cell_background_color"
--                ,v_grand_total_CHNG                                                 AS "G_TOTALH_cell_background_color"
--                ,v_usd_total_CHNG                                                   AS "US_TOT_V_cell_background_color"  
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then v_grand_total_CHNG else '#FFFFFF' end  AS "G_TOTALH_cell_background_color"                                      
                ,case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then v_usd_total_CHNG else '#FFFFFF' end    AS "US_TOT_V_cell_background_color"                           
                ,UPPER(new_ver.S_NOTES)                                                    AS  S_NOTES  
                ,UPPER(new_ver.I_NOTES)                                                    AS  I_NOTES
                ,CASE WHEN nvl(new_ver.S_NOTES,' ') <> nvl(old_ver.S_NOTES,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "S_NOTES_cell_background_color"
                ,CASE WHEN nvl(new_ver.I_NOTES,' ') <> nvl(old_ver.I_NOTES,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "I_NOTES_cell_background_color"
                ,UPPER(new_ver.V_OR_CO)                                                    AS V_OR_CO
                ,UPPER(new_ver.V_PROV)                                                     AS V_PROV
                ,CASE WHEN nvl(new_ver.V_OR_CO,' ') <> nvl(old_ver.V_OR_CO,' ')    THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "V_OR_CO_cell_background_color"
                ,CASE WHEN nvl(new_ver.V_PROV,' ')      <> nvl(old_ver.V_PROV,' ') THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END AS "V_PROV_cell_background_color"
                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_UOM_FOR_TOTALS(p_tk_ow,v_status)                                                        AS UOM_TOT                                                                                                                                    
        FROM (
                select  
                     SET_WRKSHT_NUM                                                                                                       AS PO_NUMBER
                    ,OW.CO_TK_ORG                                                                                                          
                    ,OW.CURRENCY_CODE                                                                                                     AS CURR1
                    ,to_char(PUR.PURCHASE_DATE,'DD-MON-YYYY')                                                                             AS PO_DATE
                    ,PUR.PICKUP_PERIOD_DESCR                                                                                              AS P_DATE
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID)                                                              AS PO_SUP
                    ,GET_DEF_COUNTRY_NAME(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY))                                      AS INSP_FOR
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR)                                                        AS PO_TERMS
                    ,GET_DEF_COUNTRY_NAME(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY))                                      AS DES_CO
                    ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY))                                                     AS INSP_FOM
                    ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY))                                                     AS DES_CM                    
                    ,PUR.PAY_TERM_DESCR                                                                                                   AS PO_PAY_T
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'SUPPLIER')                                           AS S_NOTES
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'INTERNAL')                                           AS I_NOTES
                    ,PUR.TK_EMP_TRADER                                                                                                  
                    ,PUR.TK_EMP_TRF                                                                                                     
                    ,PUR.CONTACT                                                                                                          AS PO_LOC_C
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(OW.DEST_PORT)                                                                   AS D_PORT
                    ,TO_CHAR(VERSION_NUM)                                                                                                 AS VER
                    ,FORX.BANK_DESCR                                                                                                      AS BANK
                    ,FORX.EXCHANGE_RATE                                                                                                   AS RATE
                    ,to_char((NVL(FORX.EXCHANGE_RATE,1))*(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))) AS US_TOT_V
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_CASES'))                               AS TOTAL_CASES
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_WEIGHT'))                              AS TOTAL_WEIGHT
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))                               AS TOTAL_PRICE                                                           
                    ,to_char(VALUATION_DATE,'DD-MON-YY')                                                                                  AS VAL_DATE
                    ,CONTRACT_NUMBER                                                                                                      AS CONT_NUM
                    ,initcap(EMP1.FULL_NAME)                                                                                              AS PO_TR_N
                    ,initcap(EMP2.FULL_NAME)                                                                                              AS PO_TRF_N
                    ,comp.co_name                                                                                                         AS C_NAME  
                    ,'http://'||comp.termsconditionurl                                                                                    AS TC_URL
                    ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(ow.orig_tk_cntry)                                                   AS V_OR_CO
                    ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(ow.province)                                                       AS V_PROV                                       
                from OW_WORKSHEET_PUB OW,WORKDESK.OW_PUR_ORD_PUB PUR, OW_WS_FOREX_PUB FORX, A_EMPLOYEE EMP1, A_EMPLOYEE EMP2,
                (SELECT * FROM COMPANY comp, country coun WHERE comp.tk_cntry = coun.tk_cntry) COMP
                WHERE OW.tk_ow         = PUR.tk_ow     
                AND   OW.tk_ow         = p_tk_ow
                AND   OW.tk_ow         = FORX.tk_ow (+)
                AND   PUR.TK_EMP_TRADER = EMP1.TK_EMPLOYEE (+)
                AND   PUR.TK_EMP_TRF    = EMP2.TK_EMPLOYEE (+)   
                AND   OW.CO_TK_ORG      = comp.tk_org (+)  
            )new_ver left join (
                select  
                     SET_WRKSHT_NUM                                                                                                       AS PO_NUMBER
                    ,OW.CO_TK_ORG                                                                                                          
                    ,OW.CURRENCY_CODE                                                                                                     AS CURR1
                    ,to_char(PUR.PURCHASE_DATE,'DD-MON-YYYY')                                                                             AS PO_DATE
                    ,PUR.PICKUP_PERIOD_DESCR                                                                                              AS P_DATE
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID)                                                              AS PO_SUP
                    ,GET_DEF_COUNTRY_NAME(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY))                                      AS INSP_FOR
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR)                                                        AS PO_TERMS
                    ,GET_DEF_COUNTRY_NAME(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY))                                      AS DES_CO
                    ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.INSP_TK_CNTRY))                                                     AS INSP_FOM
                    ,UPPER(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(OW.DEST_TK_CNTRY))                                                     AS DES_CM                    
                    ,PUR.PAY_TERM_DESCR                                                                                                   AS PO_PAY_T
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'SUPPLIER')                                           AS S_NOTES
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(OW.tk_ow, ow.status, 'INTERNAL')                                           AS I_NOTES
                    ,PUR.TK_EMP_TRADER                                                                                                  
                    ,PUR.TK_EMP_TRF                                                                                                     
                    ,PUR.CONTACT                                                                                                          AS PO_LOC_C
                    ,APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(OW.DEST_PORT)                                                                   AS D_PORT
                    ,TO_CHAR(VERSION_NUM)                                                                                                 AS VER
                    ,FORX.BANK_DESCR                                                                                                      AS BANK
                    ,FORX.EXCHANGE_RATE                                                                                                   AS RATE
                    ,to_char((NVL(FORX.EXCHANGE_RATE,1))*(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))) AS US_TOT_V
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_CASES'))                               AS TOTAL_CASES
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_WEIGHT'))                              AS TOTAL_WEIGHT
                    ,to_char(APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_TOTALS(OW.tk_ow, ow.status,'TOTAL_PRICE'))                               AS TOTAL_PRICE                                                           
                    ,to_char(VALUATION_DATE,'DD-MON-YY')                                                                                  AS VAL_DATE
                    ,CONTRACT_NUMBER                                                                                                      AS CONT_NUM
                    ,initcap(EMP1.FULL_NAME)                                                                                              AS PO_TR_N
                    ,initcap(EMP2.FULL_NAME)                                                                                              AS PO_TRF_N
                    ,comp.co_name                                                                                                         AS C_NAME  
                    ,'http://'||comp.termsconditionurl                                                                                    AS TC_URL     
                    ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(ow.orig_tk_cntry)                                                   AS V_OR_CO
                    ,workdesk.APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(ow.province)                                                       AS V_PROV                                    
                from OW_WORKSHEET_PUB OW,WORKDESK.OW_PUR_ORD_PUB PUR, OW_WS_FOREX_PUB FORX, A_EMPLOYEE EMP1, A_EMPLOYEE EMP2,
                (SELECT * FROM COMPANY comp, country coun WHERE comp.tk_cntry = coun.tk_cntry) COMP
                WHERE OW.tk_ow         = PUR.tk_ow     
                AND   OW.tk_ow         in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num and version_num = v_pre_version_num)
                AND   OW.tk_ow         = FORX.tk_ow (+)
                AND   PUR.TK_EMP_TRADER = EMP1.TK_EMPLOYEE (+)
                AND   PUR.TK_EMP_TRF    = EMP2.TK_EMPLOYEE (+)   
                AND   OW.CO_TK_ORG      = comp.tk_org (+) 
            )old_ver
                on new_ver.PO_NUMBER = old_ver.PO_NUMBER;                         
    END IF;
    RETURN rf_cur;
END GET_CONTRACT_AND_WRKSHT_DATA;
FUNCTION GET_CONTRACT_PRINT_QUERY(p_tk_contract NUMBER) RETURN CLOB 
/************************************************************
* Build a Query ONLY for Email attachment
************************************************************/
IS
    v_sql CLOB;
BEGIN     
--select OW.SET_WRKSHT_NUM AS PO_NUMBER,(CASE WHEN ow.version_num IS NOT NULL THEN ' - Ver: ' || ow.version_num END) as VER,]' ||
    v_sql := q'[select 'Contacts' as "filename",
             cursor ( 
                    select cursor(
                    select OW.SET_WRKSHT_NUM AS PO_NUMBER,(CASE WHEN ow.version_num IS NOT NULL THEN CASE WHEN ow.status = 'PUBLISHED' THEN ' - Ver: ' || ow.version_num ELSE '' END END) as VER,]' ||                                  
                                 '(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_INNER_QUERY_CONTRACT(ws.tk_ow))                     as ALL_INFO, '        ||                                                                  
                                 '(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_MISC_CHARGES_CONTRACT(ws.tk_ow))                    as MISC,'             ||                                                                                                   
                                 '(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_AND_WRKSHT_DATA(ws.tk_ow))                 as DATA1 '            ||--Data of Worksheets inside contract                                                                
                    q'[ from ow_contract_worksheet ws, OW_WORKSHEET OW
                    where ws.tk_contract =]' ||p_tk_contract ||               
                    q'[ AND ws.tk_ow = OW.tk_ow) as "worksheet" from dual
                    ) as "data"   
            from dual]'; 
   
    RETURN v_sql;

END GET_CONTRACT_PRINT_QUERY;
FUNCTION GET_CONTRACT_PRINT_QUERY_REST(p_tk_contract NUMBER,p_tk_ow NUMBER) RETURN CLOB 
/************************************************************
* Build a Query for all the Contract documents EXCEPT for the Email attachment
************************************************************/
IS
    v_sql CLOB;
BEGIN     
    v_sql := q'[select 'Contacts' as "filename",
             cursor ( 
                    select cursor(
                    select OW.SET_WRKSHT_NUM AS PO_NUMBER,(CASE WHEN ow.version_num IS NOT NULL THEN CASE WHEN ow.status = 'PUBLISHED' THEN ' - Ver: ' || ow.version_num ELSE '' END END) as VER,]' ||                                                                                                    
                                 '(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_MISC_CHARGES_CONTRACT(ws.tk_ow))                     as MISC'            ||                                                                                                   
                                 ',(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_CONTRACT_AND_WRKSHT_DATA('||p_tk_ow||'))             as DATA1 '           ||--Data of Worksheets inside contract                                  
                                 ',(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_INNER_QUERY_CONTRACT_POS('||p_tk_ow||','||p_tk_contract||'))  as POS '             ||--List of Worksheets in contract
                                 --',(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_INNER_QUERY_CONTRACT_POS(ws.tk_ow,ws.tk_contract))  as POS '             ||--List of Worksheets in contract
  --                               ',(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_INNER_QUERY_CONTRACT_PROD(ws.tk_ow))                as CON_PRD '         ||--List of Products in contract                                 
                    q'[ from ow_contract_worksheet ws, OW_WORKSHEET OW
                    where ws.tk_contract =]' ||p_tk_contract ||               
                    q'[ AND ws.tk_ow = OW.tk_ow) as "worksheet" from dual
                    ) as "data"   
            from dual]'; 
   
    RETURN v_sql;

END GET_CONTRACT_PRINT_QUERY_REST;
FUNCTION GET_PO_PRINT_QUERY(
p_tk_ow             NUMBER,
p_query_type        VARCHAR2,
p_tk_contract       NUMBER default null
) RETURN CLOB IS
/************************************************************
* Build a Query ONLY for Worksheets
************************************************************/
    v_purchase_date           DATE; 
    v_ship_date               VARCHAR2(500);
    v_contact                 VARCHAR2(500);
    v_vendor_id               VARCHAR2(500);
    v_tk_cntry                VARCHAR2(500);
    v_tk_cntry_mail           VARCHAR2(500);
    v_incoterm                VARCHAR2(500);
    v_dest_country            VARCHAR2(500);
    v_dest_country_mail       VARCHAR2(500);
    v_pur_terms               VARCHAR2(500);
    v_notes                   VARCHAR2(5000);
    v_notes_internal          VARCHAR2(5000);
    v_dest_port               VARCHAR2(500);
    v_bank_descr              VARCHAR2(500);
    v_exchange_rate           VARCHAR2(500);
    v_valuation_date          VARCHAR2(500);
    v_contract_number         VARCHAR2(500);
    v_uom                     VARCHAR2(100);
    v_uom_flag                NUMBER;   
    v_or_co                   VARCHAR2(500);
    v_prov                    VARCHAR2(500); 
    
    v_version                 VARCHAR2(20);
    
    v_exchange_rate_num       NUMBER; 
    v_tk_org                  NUMBER;     
    v_tk_emp_purchaser        NUMBER;
    v_tk_emp_coordinator      NUMBER;
    v_set_wrksht_num          NUMBER;   
    v_pre_version_num         NUMBER;
    
    v_usd_total               NUMBER;
    v_total_cases             NUMBER;    
    v_total_weight            NUMBER;   
    v_total_price             NUMBER;
    v_total_pur               NUMBER;
    v_grand_total             NUMBER;
 
    v_or_co_CHNG              VARCHAR2(1000);
    v_prov_CHNG               VARCHAR2(1000);
    v_grand_total_CHNG        VARCHAR2(1000); 
    v_tk_org_CHNG             VARCHAR2(1000);
    v_currency_code_CHNG      VARCHAR2(1000);
    v_purchase_date_CHNG      VARCHAR2(1000);
    v_ship_date_CHNG          VARCHAR2(1000);
    v_vendor_id_CHNG          VARCHAR2(1000);
    v_tk_cntry_CHNG           VARCHAR2(1000);
    v_incoterm_CHNG           VARCHAR2(1000);
    v_dest_country_CHNG       VARCHAR2(1000);
    v_pur_terms_CHNG          VARCHAR2(1000);
    v_notes_CHNG              VARCHAR2(1000);
    v_notes_internal_CHNG     VARCHAR2(1000);
    v_tk_emp_purchaser_CHNG   VARCHAR2(1000);
    v_tk_emp_coordinator_CHNG VARCHAR2(1000);
    v_contact_CHNG            VARCHAR2(1000);
    v_dest_port_CHNG          VARCHAR2(1000); 
    v_bank_descr_CHNG         VARCHAR2(1000);
    v_exchange_rate_CHNG      VARCHAR2(1000);
    v_exchange_rate_num_CHNG  VARCHAR2(1000);  
    v_valuation_date_CHNG     VARCHAR2(1000);
    v_contract_number_CHNG    VARCHAR2(1000);  
    v_prev_tk_ow              VARCHAR2(1000);
    v_total_cases_CHNG        VARCHAR2(1000);
    v_total_weight_CHNG       VARCHAR2(1000);
    v_total_price_CHNG        VARCHAR2(1000);
    v_total_pur_CHNG          VARCHAR2(1000);
    v_usd_total_CHNG          VARCHAR2(1000);         
    v_misc_change             VARCHAR2(1000);
    v_countries_text_eur      VARCHAR2(1000);
    
    v_has_misc_charges        VARCHAR2(500);
    v_has_misc_charges_prev   VARCHAR2(500);    
    v_currency_code           VARCHAR2(500); 
    v_name_purchaser          VARCHAR2(500);
    v_phone_purchaser         VARCHAR2(500);
    v_email_purchaser         VARCHAR2(500);
    v_name_coordinator        VARCHAR2(500);
    v_phone_coordinator       VARCHAR2(500);
    v_email_coordinator       VARCHAR2(500);  
           
    v_company_tc_url          VARCHAR2(500);
    v_company_zip             VARCHAR2(20);
    v_company_name            VARCHAR2(200);
    v_company_address         VARCHAR2(200);
    v_company_city            VARCHAR2(200);
    v_company_state           VARCHAR2(200);
    v_company_country         VARCHAR2(200);
    v_status                  VARCHAR2(20);     
    v_sql                     CLOB;
    
    v_min_tk                  NUMBER;
    v_max_tk                  NUMBER;
    v_c_wt_cnt                NUMBER;
    v_final_contract_tk       VARCHAR2(200);
    
BEGIN

    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;  

    IF v_status = 'UNPUBLISHED' THEN
    --Misc charges changes
        SELECT to_char(nvl(sum(total),0)) total
        into v_has_misc_charges
        FROM OW_MISC_CHARGES
        WHERE TK_OW = p_tk_ow;
            
        BEGIN
            SELECT 
                 BANK_DESCR
                ,EXCHANGE_RATE
                ,NVL(EXCHANGE_RATE,1)
                ,VALUATION_DATE
                ,CONTRACT_NUMBER
            into   
                 v_bank_descr
                ,v_exchange_rate
                ,v_exchange_rate_num
                ,v_valuation_date 
                ,v_contract_number           
            FROM OW_WS_FOREX
            WHERE TK_OW = p_tk_ow;  
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_bank_descr     := NULL;
            v_exchange_rate  := NULL;
            v_valuation_date := NULL;
        END; 
        SELECT 
             SET_WRKSHT_NUM
            ,WORK.CO_TK_ORG
            ,WORK.CURRENCY_CODE
            ,PUR.PURCHASE_DATE
            ,PUR.PICKUP_PERIOD_DESCR
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.INSP_TK_CNTRY)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.DEST_TK_CNTRY)
            ,PUR.PAY_TERM_DESCR
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(P_TK_OW, v_status, 'SUPPLIER')
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(P_TK_OW, v_status, 'INTERNAL')
            ,PUR.TK_EMP_TRADER
            ,PUR.TK_EMP_TRF
            ,PUR.CONTACT
            ,APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(WORK.DEST_PORT)
            ,null--TO_CHAR(VERSION_NUM)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(orig_tk_cntry)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(province)
        into 
             v_set_wrksht_num
            ,v_tk_org
            ,v_currency_code
            ,v_purchase_date
            ,v_ship_date
            ,v_vendor_id
            ,v_tk_cntry
            ,v_incoterm
            ,v_dest_country
            ,v_pur_terms
            ,v_notes
            ,v_notes_internal
            ,v_tk_emp_purchaser
            ,v_tk_emp_coordinator
            ,v_contact
            ,v_dest_port
            ,v_version
            ,v_or_co
            ,v_prov
         FROM WORKDESK.OW_WORKSHEET WORK,WORKDESK.OW_PUR_ORD PUR
         WHERE WORK.tk_ow = PUR.tk_ow
         AND   WORK.tk_ow = p_tk_ow;     
    ELSIF v_status = 'PUBLISHED' THEN        
        BEGIN
            SELECT 
                 BANK_DESCR
                ,EXCHANGE_RATE
                ,NVL(EXCHANGE_RATE,1)
                ,VALUATION_DATE
                ,CONTRACT_NUMBER
            into   
                 v_bank_descr
                ,v_exchange_rate
                ,v_exchange_rate_num
                ,v_valuation_date 
                ,v_contract_number              
            FROM OW_WS_FOREX_PUB
            WHERE TK_OW = p_tk_ow;  
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_bank_descr     := NULL;
            v_exchange_rate  := NULL;
            v_valuation_date := NULL;
        END;     
        SELECT 
             SET_WRKSHT_NUM
            ,WORK.CO_TK_ORG
            ,WORK.CURRENCY_CODE
            ,PUR.PURCHASE_DATE
            ,PUR.PICKUP_PERIOD_DESCR
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.INSP_TK_CNTRY)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.DEST_TK_CNTRY)
            ,PUR.PAY_TERM_DESCR
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(P_TK_OW, v_status, 'SUPPLIER')
            ,APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(P_TK_OW, v_status, 'INTERNAL')
            ,PUR.TK_EMP_TRADER
            ,PUR.TK_EMP_TRF
            ,PUR.CONTACT
            ,APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(WORK.DEST_PORT)
            ,TO_CHAR(VERSION_NUM)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(orig_tk_cntry)
            ,APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(province)            
        into 
             v_set_wrksht_num
            ,v_tk_org   
            ,v_currency_code             
            ,v_purchase_date         
            ,v_ship_date             
            ,v_vendor_id             
            ,v_tk_cntry              
            ,v_incoterm              
            ,v_dest_country          
            ,v_pur_terms  
            ,v_notes           
            ,v_notes_internal       
            ,v_tk_emp_purchaser      
            ,v_tk_emp_coordinator
            ,v_contact   
            ,v_dest_port
            ,v_version 
            ,v_or_co
            ,v_prov                                    
         FROM WORKDESK.OW_WORKSHEET_PUB WORK,WORKDESK.OW_PUR_ORD_PUB PUR
         WHERE WORK.tk_ow = PUR.tk_ow
         AND   WORK.tk_ow = p_tk_ow;
        
--        if v_version is not null then v_version := ' - Ver: ' || v_version;
--        end if;
        
        if v_version is not null then 
                v_version := ' - Ver: ' || v_version;
        end if;        
        
        SELECT VERSION_NUM -1
        into v_pre_version_num
        FROM WORKDESK.OW_WORKSHEET
        WHERE SET_WRKSHT_NUM = V_SET_WRKSHT_NUM;
     
    END IF;
    
    GET_EMPLOYEE_DATA(v_tk_emp_purchaser,v_name_purchaser,v_phone_purchaser,v_email_purchaser);
    GET_EMPLOYEE_DATA(v_tk_emp_coordinator,v_name_coordinator,v_phone_coordinator,v_email_coordinator);
    GET_COMPANY_DATA(
         v_tk_org          
        ,v_company_name    
        ,v_company_address 
        ,v_company_city    
        ,v_company_state   
        ,v_company_zip     
        ,v_company_country
        ,v_company_tc_url
        );
    GET_TOTALS(
         p_tk_ow
        ,v_status
        ,v_total_cases     
        ,v_total_weight   
        ,v_total_price
        ,v_total_pur
        ,p_tk_contract
        );          

    --CHECK FOR UPDATES IN PREVIOUS VERSION
    IF  v_status = 'PUBLISHED' THEN
        BEGIN
            SELECT                         
                 CASE WHEN nvl(WORK.CO_TK_ORG,0) <> v_tk_org                                                                           THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN WORK.CURRENCY_CODE <> v_currency_code                                                                       THEN '#FFFF00' ELSE '#FFFFFF' END 
                ,CASE WHEN PUR.PURCHASE_DATE <> v_purchase_date                                                                        THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(PUR.PICKUP_PERIOD_DESCR,' ') <> v_ship_date                                                             THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NAME(PUR.VENDOR_ID),' ') <> v_vendor_id                             THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.INSP_TK_CNTRY),' ') <> v_tk_cntry                          THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_INCOTERM(PUR.PURCHASE_TERMS_DESCR),' ') <> v_incoterm                        THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(WORK.DEST_TK_CNTRY),' ') <> v_dest_country                      THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(PUR.PAY_TERM_DESCR,' ')  <> v_pur_terms                                                                 THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(WORK.tk_ow, 'PUBLISHED', 'SUPPLIER'),' ') <> v_notes          THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_SUPPLIER_NOTES(WORK.tk_ow, 'PUBLISHED', 'INTERNAL'),' ') <> v_notes_internal THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(PUR.TK_EMP_TRADER,0) <> v_tk_emp_purchaser                                                              THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(PUR.TK_EMP_TRF,0) <> v_tk_emp_coordinator                                                               THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(PUR.CONTACT,' ') <> v_contact                                                                           THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_DEST_PORT(WORK.DEST_PORT),' ') <> v_dest_port                                THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_COUNTRY_NAME(orig_tk_cntry),' ')<> v_or_co                                   THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN nvl(APX_WOKDSK_AOP_TOOLKIT.GET_PROVINCE_NAME(province),' ') <> v_prov                                       THEN '#FFFF00' ELSE '#FFFFFF' END                
            into          
                 v_tk_org_CHNG
                ,v_currency_code_CHNG
                ,v_purchase_date_CHNG
                ,v_ship_date_CHNG
                ,v_vendor_id_CHNG
                ,v_tk_cntry_CHNG      
                ,v_incoterm_CHNG
                ,v_dest_country_CHNG
                ,v_pur_terms_CHNG
                ,v_notes_CHNG
                ,v_notes_internal_CHNG
                ,v_tk_emp_purchaser_CHNG
                ,v_tk_emp_coordinator_CHNG
                ,v_contact_CHNG
                ,v_dest_port_CHNG  
                ,v_or_co_CHNG
                ,v_prov_CHNG                                           
            FROM WORKDESK.OW_WORKSHEET_PUB WORK,WORKDESK.OW_PUR_ORD_PUB PUR
            WHERE WORK.tk_ow          = PUR.tk_ow
            AND   WORK.SET_WRKSHT_NUM = v_set_wrksht_num
            AND   VERSION_NUM         = v_pre_version_num;                       
               
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_tk_org_CHNG             := '#FFFFFF';
            v_currency_code_CHNG      := '#FFFFFF';
            v_purchase_date_CHNG      := '#FFFFFF';
            v_ship_date_CHNG          := '#FFFFFF';
            v_vendor_id_CHNG          := '#FFFFFF';
            v_tk_cntry_CHNG           := '#FFFFFF';
            v_incoterm_CHNG           := '#FFFFFF';
            v_dest_country_CHNG       := '#FFFFFF';
            v_pur_terms_CHNG          := '#FFFFFF';
            v_notes_CHNG              := '#FFFFFF';
            v_notes_internal_CHNG     := '#FFFFFF';
            v_tk_emp_purchaser_CHNG   := '#FFFFFF';
            v_tk_emp_coordinator_CHNG := '#FFFFFF';
            v_contact_CHNG            := '#FFFFFF';
            v_dest_port_CHNG          := '#FFFFFF';
            v_or_co_CHNG              := '#FFFFFF';
            v_prov_CHNG               := '#FFFFFF';           
        END;  
        BEGIN
            SELECT 
                 CASE WHEN NVL(BANK_DESCR,' ')      <> v_bank_descr               THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN EXCHANGE_RATE            <> v_exchange_rate            THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN NVL(EXCHANGE_RATE,1)     <> v_exchange_rate            THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN VALUATION_DATE  <> v_valuation_date           THEN '#FFFF00' ELSE '#FFFFFF' END
                ,CASE WHEN NVL(CONTRACT_NUMBER,' ') <> v_contract_number          THEN '#FFFF00' ELSE '#FFFFFF' END
            into   
                 v_bank_descr_CHNG
                ,v_exchange_rate_CHNG
                ,v_exchange_rate_num_CHNG
                ,v_valuation_date_CHNG
                ,v_contract_number_CHNG              
            FROM OW_WS_FOREX_PUB
            WHERE TK_OW = ( SELECT tk_ow 
                            FROM WORKDESK.OW_WORKSHEET_PUB 
                            WHERE SET_WRKSHT_NUM      = v_set_wrksht_num
                            AND   VERSION_NUM         = v_pre_version_num);  
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            IF v_pre_version_num <> 0 THEN
                v_bank_descr_CHNG         := '#FFFF00';
                v_exchange_rate_CHNG      := '#FFFF00';
                v_exchange_rate_num_CHNG  := '#FFFF00';
                v_valuation_date_CHNG     := '#FFFF00';
                v_contract_number_CHNG    := '#FFFF00';
            ELSE
                v_bank_descr_CHNG         := '#FFFFFF';
                v_exchange_rate_CHNG      := '#FFFFFF';
                v_exchange_rate_num_CHNG  := '#FFFFFF';
                v_valuation_date_CHNG     := '#FFFFFF';
                v_contract_number_CHNG    := '#FFFFFF';
            
            END IF;
        END;    
        BEGIN
            SELECT tk_ow
            into v_prev_tk_ow 
            FROM WORKDESK.OW_WORKSHEET_PUB 
            WHERE SET_WRKSHT_NUM      = v_set_wrksht_num
            AND   VERSION_NUM         = v_pre_version_num;
            GET_TOTALS(
             v_prev_tk_ow
            ,'PUBLISHED'
            ,v_total_cases_CHNG     
            ,v_total_weight_CHNG   
            ,v_total_price_CHNG
            ,v_total_pur_CHNG
            ); 
            IF v_total_cases_CHNG  <> v_total_cases  THEN v_total_cases_CHNG  := '#FFFF00'; ELSE v_total_cases_CHNG := '#FFFFFF'; END IF; 
            IF v_total_weight_CHNG <> v_total_weight THEN v_total_weight_CHNG := '#FFFF00'; ELSE v_total_weight_CHNG := '#FFFFFF'; END IF;
            IF v_total_price_CHNG  <> v_total_price  THEN v_total_price_CHNG  := '#FFFF00';v_usd_total_CHNG := '#FFFF00';v_grand_total_CHNG:= '#FFFF00'; ELSE v_total_price_CHNG := '#FFFFFF'; v_usd_total_CHNG := '#FFFFFF';v_grand_total_CHNG:= '#FFFFFF'; END IF;
            IF v_total_pur_CHNG    <> v_total_pur    THEN v_total_pur_CHNG    := '#FFFF00'; ELSE v_total_pur_CHNG := '#FFFFFF'; END IF;     
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            v_total_cases_CHNG  := '#FFFFFF';   
            v_total_weight_CHNG := '#FFFFFF';  
            v_total_price_CHNG  := '#FFFFFF';   
            v_usd_total_CHNG    := '#FFFFFF';
            v_grand_total_CHNG  := '#FFFFFF';
        END;  
        --Misc charges changes
        SELECT new_ver.total,CASE WHEN nvl(new_ver.total,0) <> nvl(old_ver.total,0) THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num,'#FFFFFF') ELSE '#FFFFFF' END 
        into v_has_misc_charges,v_has_misc_charges_prev
        FROM 
            (SELECT to_char(nvl(sum(total),0)) total
             FROM OW_MISC_CHARGES_PUB
             WHERE TK_OW = p_tk_ow)new_ver,    
            (SELECT to_char(nvl(sum(total),0)) total
             FROM OW_MISC_CHARGES_PUB
             WHERE TK_OW in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num  and version_num = v_pre_version_num))old_ver;  
        --Misc charges changes             
    END IF;
    
    --CHECK FOR UPDATES IN PREVIOUS VERSION

    v_grand_total :=  v_has_misc_charges + v_total_pur;
    v_usd_total := v_exchange_rate_num * v_grand_total;

    IF v_has_misc_charges_prev = '#FFFF00' OR v_total_pur_CHNG = '#FFFF00' THEN
        v_grand_total_CHNG := '#FFFF00';
    ELSE
        v_grand_total_CHNG := '#FFFFFF';
    END IF; 

    IF v_exchange_rate_CHNG = '#FFFF00' OR v_grand_total_CHNG = '#FFFF00' THEN
        v_usd_total_CHNG   := '#FFFF00'; 
    ELSE
        v_usd_total_CHNG   := '#FFFFFF';
    END IF;

--    IF v_total_price_CHNG = '#FFFF00' THEN
--        v_grand_total_CHNG := '#FFFF00';
--        v_usd_total_CHNG   := '#FFFF00';
--    ELSIF v_has_misc_charges_prev = '#FFFF00' THEN
--        v_grand_total_CHNG := '#FFFF00';
--        v_usd_total_CHNG   := '#FFFF00';        
--    END IF;
    
    IF v_has_misc_charges_prev = '#FFFFFF' THEN
        v_misc_change := '#FFFFFF';
    ELSE
        v_misc_change := '#FFFF00';
    END IF;

    --Get UOM 
    GET_UNIQUE_UOM(p_tk_ow,v_status,v_uom,v_uom_flag);
    
    --Get PER
    GET_UNIQUE_PER(p_tk_ow,v_status,v_uom,v_uom_flag);          

    --Get more info if its contract information // Template ID 9 forward
    IF p_tk_contract is not null then
        BEGIN
            IF  v_status = 'PUBLISHED' THEN
                SELECT DISTINCT(COUNT(OW.SET_WRKSHT_NUM))
                into v_c_wt_cnt
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET_PUB OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW;            
                
                SELECT MIN(OW.SET_WRKSHT_NUM) 
                into v_min_tk
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET_PUB OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW;

                SELECT MAX(OW.SET_WRKSHT_NUM) 
                into v_max_tk
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET_PUB OW
                WHERE WS.TK_CONTRACT = p_tk_contract
                AND WS.TK_OW = OW.TK_OW;
             ELSIF v_status = 'UNPUBLISHED' THEN   
                SELECT DISTINCT(COUNT(OW.SET_WRKSHT_NUM))
                into v_c_wt_cnt
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW;            
                
                SELECT MIN(OW.SET_WRKSHT_NUM) 
                into v_min_tk
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW;

                SELECT MAX(OW.SET_WRKSHT_NUM) 
                into v_max_tk
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW
                WHERE WS.TK_CONTRACT = p_tk_contract
                AND WS.TK_OW = OW.TK_OW;            
            END IF;
            IF v_min_tk <> v_max_tk THEN
                v_final_contract_tk := to_char(v_min_tk) ||' through '||to_char(v_max_tk);
            ELSE
                v_final_contract_tk := to_char(v_min_tk);
            END IF;              
            
        EXCEPTION WHEN OTHERS THEN
            v_final_contract_tk := null;
        END;
    END IF; 
    --https://ajcict.atlassian.net/browse/OW-370
    v_dest_country_mail := v_dest_country;
    v_tk_cntry_mail     := v_tk_cntry;
    v_tk_cntry          := GET_DEF_COUNTRY_NAME(v_tk_cntry);
    v_dest_country      := GET_DEF_COUNTRY_NAME(v_dest_country);
    -- This is to replace text in AJC Purchase Confirmation Europe Document
    IF replace(v_tk_cntry,'''','''''') <> replace(v_dest_country,'''','''''') THEN
        v_countries_text_eur := replace(v_dest_country,'''','''''') || '/' || replace(v_tk_cntry,'''','''''');  
    ELSE
        v_countries_text_eur := replace(v_dest_country,'''','''''');
    END IF;

    CASE p_query_type
        WHEN 'PO' THEN
            v_sql:= q'[select 'Contacts' as "filename", 
                     cursor ( select ]' ||             
                    '''' || UPPER(v_countries_text_eur                    )  || '''' || ' AS CO_FOR_EU,'                       ||
                    '''' || UPPER(v_or_co                                 )  || '''' || ' AS V_OR_CO,'                         ||
                    '''' || UPPER(v_prov                                  )  || '''' || ' AS V_PROV,'                          ||
                    '''' || UPPER(v_or_co_CHNG                            )  || '''' || ' AS "V_OR_CO_cell_background_color",' ||
                    '''' || UPPER(v_prov_CHNG                             )  || '''' || ' AS "V_PROV_cell_background_color",'  ||                                                            
                    '''' || UPPER(v_status                                )  || '''' || ' AS V_STATUS,'                        ||
                    '''' || UPPER(v_c_wt_cnt                              )  || '''' || ' AS C_WT_CNT,'                        ||
                    '''' || v_final_contract_tk                              || '''' || ' AS PO_NUMBERS,'                      ||
                    '''' || UPPER(v_uom_flag                              )  || '''' || ' AS UOM_F,'                           ||
                    '''' || UPPER(v_uom                                   )  || '''' || ' AS UOM_T,'                           ||
                    '''' || UPPER(replace(v_bank_descr,'''','''''')       )  || '''' || ' AS BANK,'                            ||
                    '''' || UPPER(v_bank_descr_CHNG                       )  || '''' || ' AS "BANK_cell_background_color",'                       ||
                    '''' || UPPER(replace(v_currency_code,'''','''''')    )  || '''' || ' AS CURR1,'                           ||
                    '''' || UPPER(v_has_misc_charges                      )  || '''' || ' AS MISC_YN,'                         ||                    
                    '''' || UPPER(v_grand_total_CHNG                      )  || '''' || ' AS "G_TOTAL_cell_background_color",' ||
                    --'''' || UPPER(v_grand_total_CHNG)                        || '''' || ' AS "G_TOTALH_cell_background_color",' ||
                    '''' || UPPER(v_misc_change                           )  || '''' || ' AS "MISC_Y_cell_background_color",'  ||                    
                    '''' || UPPER(v_currency_code_CHNG                    )  || '''' || ' AS "CURR1_cell_background_color",'   ||
                    --'''' || UPPER(v_usd_total_CHNG)                          || '''' || ' AS "US_TOT_V_cell_background_color",'||                    
                    '''' || case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then v_usd_total_CHNG else '#FFFFFF'   end || '''' || ' AS "US_TOT_V_cell_background_color",'  || 
                    '''' || case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then v_grand_total_CHNG else '#FFFFFF' end || '''' || ' AS "G_TOTALH_cell_background_color",'  ||                                                                                
                    '''' || UPPER(replace(v_contract_number,'''','''''')  )  || '''' || ' AS CONT_NUM,'                        ||
                    '''' || UPPER(v_contract_number_CHNG                  )  || '''' || ' AS "CONT_NUM_cell_background_color",'||
                    '''' || UPPER(replace(v_exchange_rate,'''','''''')    )  || '''' || ' AS RATE,'                            ||
                    '''' || UPPER(v_exchange_rate_CHNG                    )  || '''' || ' AS "RATE_cell_background_color",'                       ||
                    '''' || UPPER(replace(v_valuation_date,'''','''''')   )  || '''' || ' AS VAL_DATE,'                        ||
                    '''' || UPPER(v_valuation_date_CHNG                   )  || '''' || ' AS "VAL_DATE_cell_background_color",'                   ||                               
                    '''' || UPPER(replace(v_company_name,'''','''''')     )  || '''' || ' AS C_NAME,'                          ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_NAME_cell_background_color",'  ||
                    '''' || UPPER(replace(v_company_address,'''','''''')  )  || '''' || ' AS C_ADD1,'                          ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_ADD1_cell_background_color",'  ||
                    '''' || UPPER(replace(v_company_city,'''','''''')     )  || '''' || ' AS C_CITY,'                          ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_CITY_cell_background_color",'  ||
                    '''' || UPPER(replace(v_company_state,'''','''''')    )  || '''' || ' AS C_STATE,'                         ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_STATE_cell_background_color",' ||
                    '''' || UPPER(replace(v_company_zip,'''','''''')      )  || '''' || ' AS C_ZIP,'                           ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_ZIP_cell_background_color",'   ||
                    '''' || UPPER(replace(v_company_country,'''','''''')  )  || '''' || ' AS C_CTRY,'                          ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS "C_CTRY_cell_background_color",'  ||
                    '''' || UPPER(replace(v_vendor_id,'''','''''')        )  || '''' || ' AS PO_SUP,'                          ||
                    '''' || UPPER(v_vendor_id_CHNG                        )  || '''' || ' AS "PO_SUP_cell_background_color",'  ||
                    '''' || UPPER(replace(v_tk_cntry,'''',''''''))           || '''' || ' AS INSP_FOR,'                        ||
                    '''' || UPPER(v_tk_cntry_CHNG                         )  || '''' || ' AS "INSP_FOR_cell_background_color",'||
                    '''' || UPPER(replace(v_incoterm,'''','''''')         )  || '''' || ' AS PO_TERMS,'                        ||  
                    '''' || UPPER(v_incoterm_CHNG                         )  || '''' || ' AS PO_TERMS_CHNG,'                   ||
                    '''' || UPPER(replace(v_name_purchaser,'''','''''')   )  || '''' || ' AS PO_TR_N,'                         ||
                    '''' || UPPER(v_tk_emp_purchaser_CHNG                 )  || '''' || ' AS "PO_TR_N_cell_background_color",' ||
                    '''' || UPPER(replace(v_phone_purchaser,'''','''''')  )  || '''' || ' AS PO_TR_P,'                         ||                   
                    '''' || UPPER(v_tk_emp_purchaser_CHNG                 )  || '''' || ' AS "PO_TR_P_cell_background_color",' ||
                    '''' || UPPER(replace(v_email_purchaser,'''','''''')  )  || '''' || ' AS PO_TR_E,'                         ||                  
                    '''' || UPPER(v_tk_emp_purchaser_CHNG                 )  || '''' || ' AS "PO_TR_E_cell_background_color",' || 
                    '''' || UPPER(replace(v_name_coordinator,'''','''''') )  || '''' || ' AS PO_TRF_N,'                        ||                 
                    '''' || UPPER(v_tk_emp_coordinator_CHNG               )  || '''' || ' AS "PO_TRF_N_cell_background_color",'||
                    '''' || UPPER(replace(v_phone_coordinator,'''',''''''))  || '''' || ' AS PO_TRF_P,'                        ||                   
                    '''' || UPPER(v_tk_emp_coordinator_CHNG               )  || '''' || ' AS "PO_TRF_P_cell_background_color",'||
                    '''' || UPPER(replace(v_email_coordinator,'''',''''''))  || '''' || ' AS PO_TRF_E,'                        ||                   
                    '''' || UPPER(v_tk_emp_coordinator_CHNG               )  || '''' || ' AS "PO_TRF_E_cell_background_color",'||
                    '''' || UPPER(replace(v_pur_terms,'''','''''')        )  || '''' || ' AS PO_PAY_T,'                        || 
                    '''' || UPPER(v_pur_terms_CHNG                        )  || '''' || ' AS "PO_PAY_T_cell_background_color",'||
                    '''' || (replace(v_company_tc_url,'''','''''')   )       || '''' || ' AS TC_URL,'                          ||
                    '''' || UPPER(v_tk_org_CHNG                           )  || '''' || ' AS TC_URL_CHNG,'                     ||
                    '''' || UPPER(replace(v_dest_country,'''','''''')     )  || '''' || ' AS DES_CO,'                          ||
                    '''' || UPPER(v_dest_country_CHNG                     )  || '''' || ' AS "DES_CO_cell_background_color",'  ||                    
                    '''' || UPPER(replace(v_dest_country_mail,'''',''''''))  || '''' || ' AS DES_CM,'                          ||
                    '''' || UPPER(v_dest_country_CHNG                     )  || '''' || ' AS "DES_CM_cell_background_color",'  ||                    
                    '''' || UPPER(replace(v_tk_cntry_mail,'''',''''''))      || '''' || ' AS INSP_FOM,'                        ||
                    '''' || UPPER(v_tk_cntry_CHNG                         )  || '''' || ' AS "INSP_FOM_cell_background_color",'||                                                            
                    '''' || UPPER(replace(v_set_wrksht_num,'''','''''')   )  || '''' || ' AS PO_NUMBER,'                       ||            
                    '''' || UPPER(replace(v_notes,'''','''''')            )  || '''' || ' AS S_NOTES,'                         || 
                    '''' || UPPER(v_notes_CHNG                            )  || '''' || ' AS "S_NOTES_cell_background_color",' ||
                    '''' || UPPER(replace(v_notes_internal,'''','''''')   )  || '''' || ' AS I_NOTES,'                         ||
                    '''' || UPPER(v_notes_internal_CHNG                   )  || '''' || ' AS "I_NOTES_cell_background_color",' ||                        
                    '''' || UPPER(replace(v_contact,'''','''''')          )  || '''' || ' AS PO_LOC_C,'                        ||
                    '''' || UPPER(v_contact_CHNG                          )  || '''' || ' AS "PO_LOC_C_cell_background_color",'||
                    '''' || UPPER(replace(v_dest_port,'''','''''')        )  || '''' || ' AS D_PORT,'                          ||
                    '''' || UPPER(v_dest_port_CHNG                        )  || '''' || ' AS "D_PORT_cell_background_color",'  ||
                    '''' || UPPER(replace(v_ship_date,'''','''''')        )  || '''' || ' AS P_DATE,'                          || 
                    '''' || UPPER(v_ship_date_CHNG                        )  || '''' || ' AS "P_DATE_cell_background_color",'  || 
                    '''' || UPPER(replace(v_version,'''','''''')          )  || '''' || ' AS VER,'                             ||                    
                    '''' || UPPER(to_char(v_purchase_date,'DD-MON-YYYY')  )  || '''' || ' AS PO_DATE,'                         ||
                    '''' || UPPER(v_purchase_date_CHNG                    )  || '''' || ' AS PO_DATE_CHNG,'                    ||                    
                    '''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_UOM_FOR_TOTALS(p_tk_ow,v_status)                        || '''' || ' AS UOM_TOT,'  ||                                        
                    '''' || case when (to_char(v_total_cases))=0 THEN '' ELSE (to_char(v_total_cases)) END              || '''' || ' AS TOT_C,'    ||
                    '''' || v_total_cases_CHNG                        || '''' || ' AS "TOT_C_cell_background_color",'   ||                    
                    '''' || v_total_weight_CHNG                       || '''' || ' AS "TOT_W_cell_background_color",'   ||                                           
                    '''' || case when (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)))='0' THEN '' ELSE (to_char(WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight))) END              || '''' || ' AS TOT_W,'    ||                    
                    --'''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_weight)                               || '''' || ' AS TOT_W,'    ||                                          
                    '''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_price)                                || '''' || ' AS TOT_P,'    ||
                    '''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_total_pur)                                  || '''' || ' AS TOT_PUR,'  ||  
                    '''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_has_misc_charges)                           || '''' || ' AS MISC_Y,'   ||                    
                    '''' || case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total) else '-' end || '''' || ' AS G_TOTALH,'  ||                                        
                    '''' || case when nvl(trim(replace(v_exchange_rate,'''','''''')),1) <> 1 then WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total) else '-' end || '''' || ' AS US_TOT_V,'  ||
                    '''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_grand_total)                                || '''' || ' AS G_TOTAL,'  ||
                    --'''' || WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(v_usd_total)                                  || '''' || ' AS US_TOT_V,' ||                                      
                    '''' || v_total_pur_CHNG                                                                            || '''' || ' AS "TOT_PUR_cell_background_color",' ||                                                              
             'cursor( '||replace(GET_INNER_QUERY(p_tk_ow,v_set_wrksht_num,v_status,v_pre_version_num),'  ',' ') ||') as ALL_INFO '                  ||
             ',WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_MISC_CHARGES('||p_tk_ow||','||v_set_wrksht_num||','''||v_status||''','||nvl(v_pre_version_num,1)||')' 
             || ' as MISC' ||                           
             ',WORKDESK.APX_WOKDSK_AOP_TOOLKIT.GET_DATES_FOR_CONTRACT('||NVL(p_tk_contract,0)||','''||v_status||''')' || ' as CON_DATES' ||                                        
              q'[ from dual ) as "data"
                from dual ]';  
        WHEN 'CONTRACT' THEN
            NULL;
        END CASE;
    
    IF v_status = 'PUBLISHED' THEN
        v_sql := REPLACE(v_sql,'OW_PO_PRD_LINE','OW_PO_PRD_LINE_PUB');
        v_sql := REPLACE(v_sql,'OW_WS_PRD_LINE','OW_WS_PRD_LINE_PUB');
    END IF;

    RETURN v_sql;

END GET_PO_PRINT_QUERY;
FUNCTION GET_DEF_COUNTRY_NAME(p_country_name VARCHAR2) RETURN VARCHAR2
--Retreives desired Country name https://ajcict.atlassian.net/browse/OW-370
IS
    v_ctry VARCHAR2(50);
BEGIN
    CASE UPPER(p_country_name)
        WHEN 'CHINA'         THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';     
        WHEN 'NORTH CHINA'   THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        WHEN 'CHINA NORTH'   THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        WHEN 'CENTRAL CHINA' THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        WHEN 'CHINA CENTRAL' THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        WHEN 'SOUTH CHINA'   THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        WHEN 'CHINA SOUTH'   THEN v_ctry:= 'PEOPLE''S REPUBLIC OF CHINA';
        ELSE v_ctry:=p_country_name;
    END CASE;  
    RETURN v_ctry;
END GET_DEF_COUNTRY_NAME;
FUNCTION FORMAT_PRICE_DECIMALS(p_pur_ext in NUMBER) RETURN VARCHAR2 is
    v_formatted_pur_ext varchar2(50);
BEGIN
    v_formatted_pur_ext := to_char(p_pur_ext, 'FM999,999,999,999,990.0099999');
    
    IF p_pur_ext - trunc(p_pur_ext) = 0 THEN
        --NO DECIMALS / NO CHANGES
        v_formatted_pur_ext := to_char(p_pur_ext, 'FM999,999,999,999,990');            
    END IF;    
        
    return v_formatted_pur_ext;
END;
FUNCTION GET_CONTRACT_TOTALS(
    p_tk_ow        NUMBER,
    p_status       VARCHAR2,
    p_total        VARCHAR2       
) RETURN NUMBER
IS   
    v_total_cases    NUMBER; 
    v_total_weight   NUMBER; 
    v_total_price    NUMBER;  
    v_number_of_uoms NUMBER;
BEGIN

    IF p_status = 'UNPUBLISHED' THEN
        SELECT  
               SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
             , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
             , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
             , count(distinct(pur_price_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332
        into v_total_cases, v_total_weight, v_total_price, v_number_of_uoms          
        from workdesk.OW_PO_PRD_LINE a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
        where a.tk_ow = p_tk_ow
        order by a.tk_ow, a.line_num;
    ELSIF p_status = 'PUBLISHED' THEN
        SELECT  
               SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
             , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
             , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
             , count(distinct(pur_price_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332
        into v_total_cases, v_total_weight, v_total_price, v_number_of_uoms          
        from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
        where a.tk_ow = p_tk_ow
        order by a.tk_ow, a.line_num;
    
    END IF;
    IF v_number_of_uoms > 1 THEN v_total_weight := 0; END IF; --https://ajcict.atlassian.net/browse/OW-332
    CASE p_total
        WHEN 'TOTAL_CASES' THEN RETURN v_total_cases;
        WHEN 'TOTAL_WEIGHT' THEN RETURN v_total_weight;
        WHEN 'TOTAL_PRICE' THEN RETURN v_total_price;
    END CASE;
    
EXCEPTION WHEN NO_DATA_FOUND THEN
    RETURN 0;
END GET_CONTRACT_TOTALS ;
FUNCTION GET_UOM_FOR_TOTALS(
    p_tk_ow        NUMBER,
    p_status       VARCHAR2      
) RETURN VARCHAR2
-- This Functions retreives de UOM for the totals ONLY if all the products has the same, if not it will return ' ' https://ajcict.atlassian.net/browse/OW-410
IS   
    v_uom VARCHAR2(10);
BEGIN
    IF p_status = 'UNPUBLISHED' THEN
        BEGIN
            SELECT distinct(WT_uom)
            into v_uom          
            from workdesk.OW_PO_PRD_LINE a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow = p_tk_ow;        
        EXCEPTION WHEN OTHERS THEN
            RETURN ' ';
        END;
    ELSIF p_status = 'PUBLISHED' THEN
        BEGIN    
            SELECT distinct(WT_uom)
            into v_uom           
            from workdesk.OW_PO_PRD_LINE a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow = p_tk_ow;
        EXCEPTION WHEN OTHERS THEN
            RETURN ' ';
        END;    
    END IF;
    RETURN v_uom;
EXCEPTION WHEN OTHERS THEN
    RETURN ' ';
END GET_UOM_FOR_TOTALS ;  
PROCEDURE GET_TOTALS(
    p_tk_ow        NUMBER,
    p_status       VARCHAR2,
    v_total_cases  OUT NUMBER,    
    v_total_weight OUT NUMBER,   
    v_total_price  OUT NUMBER,
    v_total_pur    OUT NUMBER,
    p_tk_contract      NUMBER default null         
)IS
    v_number_of_uoms NUMBER;
BEGIN
    IF p_tk_contract IS NULL THEN
        IF p_status = 'UNPUBLISHED' THEN
            SELECT  
                   SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
                 , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
                 , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
                 , SUM(NVL(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)),0)) as PUR
                 , count(distinct(WT_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332
            into v_total_cases, v_total_weight, v_total_price, v_total_pur, v_number_of_uoms         
            from workdesk.OW_PO_PRD_LINE a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow = p_tk_ow
            order by a.tk_ow, a.line_num;
        ELSIF p_status = 'PUBLISHED' THEN
            SELECT  
                   SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
                 , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
                 , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
                 , SUM(NVL(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)),0)) as PUR
                 , count(distinct(WT_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332          
            into v_total_cases, v_total_weight, v_total_price, v_total_pur, v_number_of_uoms          
            from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow = p_tk_ow
            order by a.tk_ow, a.line_num;    
        END IF;
    ELSE --Calculate Contract totals
        IF p_status = 'UNPUBLISHED' THEN
            SELECT  
                   SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
                 , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
                 , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
                 , SUM(NVL(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)),0)) as PUR
                 , count(distinct(WT_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332
            into v_total_cases, v_total_weight, v_total_price, v_total_pur, v_number_of_uoms          
            from workdesk.OW_PO_PRD_LINE a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow in (
                SELECT DISTINCT(OW.tk_ow)
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW            
            )
            order by a.tk_ow, a.line_num;
        ELSIF p_status = 'PUBLISHED' THEN  
            SELECT  
                   SUM(NVL(b.cases,0))                                                          as TOTAL_CASES        
                 , SUM(NVL(b.weight,0))                                                         as TOTAL_WEIGHT            
                 , SUM(NVL(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt),0)) as TOTAL_PRICE
                 , SUM(NVL(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)),0)) as PUR
                 , count(distinct(WT_uom)) -- To see if the UOMs in the lines are the same. >1 says that they are not the same, so Total Weight must not be shown https://ajcict.atlassian.net/browse/OW-332             
            into v_total_cases, v_total_weight, v_total_price, v_total_pur, v_number_of_uoms          
            from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
            where a.tk_ow in (
                SELECT DISTINCT(OW.tk_ow)
                FROM   OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW
                WHERE WS.TK_CONTRACT = p_tk_contract 
                AND WS.TK_OW = OW.TK_OW            
            )
            order by a.tk_ow, a.line_num;         
        END IF;              
    END IF;        
    
    IF v_number_of_uoms > 1 THEN v_total_weight := 0; END IF; --https://ajcict.atlassian.net/browse/OW-332
    
EXCEPTION WHEN NO_DATA_FOUND THEN 
    v_total_cases  := 0; 
    v_total_weight := 0;
    v_total_price  := 0; 
END GET_TOTALS ; 
FUNCTION GET_INNER_QUERY(p_tk_ow NUMBER,p_set_wrksht_num NUMBER,p_status VARCHAR2,p_pre_version_num NUMBER) RETURN CLOB IS
    v_inner_query       CLOB;
    v_change_wildcard   VARCHAR2(3000); 
    v_change_wildcard_0 VARCHAR2(3000);    
BEGIN
    IF p_status <> 'PUBLISHED' THEN
        v_inner_query := q'[ select CASES,WEIGHT,UOM,upper(PRODUCT_DESC) as "PRD_DESC",PUR_PRICE as "P_PRICE",PER,PLANTS, :P12_PRICED_IN AS CURR, LINE, PRODUCT_CODE as "PRD_CODE", PUR 
                            from
                            (       
                                select  
                                       a.line_num + 1 as LINE
                                     , b.cases as CASES        
                                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(b.weight) as WEIGHT       
                                     , b.wt_uom as UOM          
                                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD) as PRODUCT_CODE     
                                     , b.PUR_DESCR as PRODUCT_DESC
                                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR_PRICE
                                     , a.pur_price_uom                                                  as PER          -- PER
                                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                                     , (select LISTAGG(prd.usda_plant, ',') 
                                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                                        where plant.tk_ow    = a.tk_ow 
                                        and prd.tk_prd_plant = plant.tk_prd_plant
                                        and plant.line_num   = a.line_num
                                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                                from workdesk.OW_PO_PRD_LINE a left join workdesk.OW_WS_PRD_LINE b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                                where a.tk_ow = %TK_OW%
                                order by a.line_num         
                                    )ORDER BY line asc ]';
    ELSE 
        v_inner_query := q'[ select 
                                 WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.PUR) as PUR
                                ,new_ver.CASES
                                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.WEIGHT) as WEIGHT
                                ,new_ver.UOM
                                ,upper(new_ver.PRODUCT_DESC) as "PRD_DESC"
                                ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.PUR_PRICE) as "P_PRICE"
                                ,new_ver.PER,new_ver.PLANTS
                                ,:P12_PRICED_IN AS CURR
                                ,new_ver.LINE
                                ,new_ver.PRODUCT_CODE as "PRD_CODE" 
                            ,%CHANGE_WILDCARD% 
                            from (
                                 select  
                                       a.line_num + 1 as LINE
                                     , b.cases as CASES        -- cases
                                     , b.weight as WEIGHT
                                     , b.wt_uom as UOM          -- uom
                                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD)            as PRODUCT_CODE     
                                     --,(select base_descr from product where tk_prd = a.tk_prd)          as PRODUCT_DESC -- supplier description 
                                     , b.PUR_DESCR as PRODUCT_DESC
                                     , decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as PUR_PRICE
                                     , a.pur_price_uom                                                  as PER          -- PER
                                     , workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR
                                     , (select LISTAGG(prd.usda_plant, ',') 
                                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                                        where plant.tk_ow    = a.tk_ow 
                                        and prd.tk_prd_plant = plant.tk_prd_plant
                                        and plant.line_num   = a.line_num
                                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                                from workdesk.OW_PO_PRD_LINE a left join workdesk.OW_WS_PRD_LINE b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                                where a.tk_ow = %TK_OW%  
                             )new_ver left join( 
                                 select  
                                       a.line_num + 1 as LINE
                                     , b.cases as CASES        -- cases
                                     , b.weight as WEIGHT
                                     , b.wt_uom as UOM          -- uom
                                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD)            as PRODUCT_CODE     
                                     , b.PUR_DESCR as PRODUCT_DESC 
                                     , decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as PUR_PRICE
                                     , a.pur_price_uom                                                  as PER          -- PER
                                     , (workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                                     , (select LISTAGG(prd.usda_plant, ',') 
                                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                                        where plant.tk_ow    = a.tk_ow 
                                        and prd.tk_prd_plant = plant.tk_prd_plant
                                        and plant.line_num   = a.line_num
                                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                                from workdesk.OW_PO_PRD_LINE a left join workdesk.OW_WS_PRD_LINE b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                                where a.tk_ow in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = %SET_WRKSHT_NUM% and version_num = %VERSION_NUM%)  
                            ) old_ver
                            --on new_ver.product_code = old_ver.product_code /*Producto cartesiano reportado por Beth*/
                            on new_ver.line = old_ver.line
                            ORDER BY line asc ]';                   
    END IF;

    v_change_wildcard_0 :='  
    ''#E7E6E6'' AS "CASES_cell_background_color",  
    ''#E7E6E6'' AS "WEIGHT_cell_background_color", 
    ''#E7E6E6'' AS "UOM_cell_background_color", 
    ''#E7E6E6'' AS "PRD_DESC_cell_background_color", 
    ''#E7E6E6'' AS "P_PRICE_cell_background_color", 
    ''#E7E6E6'' AS "PER_cell_background_color", 
    ''#E7E6E6'' AS "PLANTS_cell_background_color", 
    ''#E7E6E6'' AS "LINE_cell_background_color",
    ''#E7E6E6'' AS "PUR_cell_background_color",  
    ''#E7E6E6'' AS "PRD_CODE_cell_background_color"';
    v_change_wildcard :='  
    CASE WHEN nvl(new_ver.CASES,0)           <> nvl(old_ver.CASES,0)               THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "CASES_cell_background_color",  
    CASE WHEN nvl(new_ver.WEIGHT,0)          <> nvl(old_ver.WEIGHT,0)              THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "WEIGHT_cell_background_color", 
    CASE WHEN nvl(new_ver.UOM,'' '')         <> nvl(old_ver.UOM,'' '')             THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "UOM_cell_background_color", 
    CASE WHEN nvl(new_ver.PRODUCT_DESC,'' '')<> nvl(old_ver.PRODUCT_DESC,'' '')    THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "PRD_DESC_cell_background_color", 
    CASE WHEN nvl(new_ver.PUR_PRICE,0)       <> nvl(old_ver.PUR_PRICE,0)           THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "P_PRICE_cell_background_color", 
    CASE WHEN nvl(new_ver.PER,'' '')         <> nvl(old_ver.PER,'' '')             THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "PER_cell_background_color", 
    CASE WHEN nvl(new_ver.PLANTS,'' '')      <> nvl(old_ver.PLANTS,'' '')          THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "PLANTS_cell_background_color", 
    CASE WHEN nvl(new_ver.LINE,0)            <> nvl(old_ver.LINE,0)                THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "LINE_cell_background_color",
    CASE WHEN nvl(new_ver.PUR,0)             <> nvl(old_ver.PUR,0)                 THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "PUR_cell_background_color",  
    CASE WHEN nvl(new_ver.PRODUCT_CODE,0)    <> nvl(old_ver.PRODUCT_CODE,0)        THEN ''#FFFF00'' ELSE ''#E7E6E6'' END AS "PRD_CODE_cell_background_color"';

  
    IF p_pre_version_num =0 THEN
        v_inner_query := REPLACE(v_inner_query,'%CHANGE_WILDCARD%',v_change_wildcard_0);
    ELSE
        v_inner_query := REPLACE(v_inner_query,'%CHANGE_WILDCARD%',v_change_wildcard);
    END IF;
    
    v_inner_query := REPLACE(v_inner_query,'%TK_OW%',p_tk_ow);
    v_inner_query := REPLACE(v_inner_query,'%VERSION_NUM%',p_pre_version_num);
    v_inner_query := REPLACE(v_inner_query,'%SET_WRKSHT_NUM%',p_set_wrksht_num);
    RETURN v_inner_query;
END GET_INNER_QUERY; 
FUNCTION GET_INNER_QUERY_CONTRACT(p_tk_ow NUMBER) RETURN sys_refcursor 
IS
    v_inner_query       CLOB;
    v_change_wildcard   VARCHAR2(3000); 
    v_change_wildcard_0 VARCHAR2(3000); 
    v_pre_version_num   NUMBER;
    v_set_wrksht_num    NUMBER;  
    v_status            VARCHAR2(30);
    rf_cur              sys_refcursor;       
BEGIN
    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;
      
    IF v_status = 'UNPUBLISHED' THEN
        open rf_cur for
            select CASES,WEIGHT,UOM,upper(PRODUCT_DESC) as "PRD_DESC",PUR_PRICE as "P_PRICE",PER,UPPER(PLANTS) as "PLANTS"
            , LINE, PRODUCT_CODE as "PRD_CODE", PUR
            ,'#E7E6E6' AS "CASES_cell_background_color"  
            ,'#E7E6E6' AS "WEIGHT_cell_background_color" 
            ,'#E7E6E6' AS "UOM_cell_background_color"
            ,'#E7E6E6' AS "PRD_DESC_cell_background_color" 
            ,'#E7E6E6' AS "P_PRICE_cell_background_color" 
            ,'#E7E6E6' AS "PER_cell_background_color"
            ,'#E7E6E6' AS "PLANTS_cell_background_color" 
            ,'#E7E6E6' AS "LINE_cell_background_color"
            ,'#E7E6E6' AS "PUR_cell_background_color"  
            ,'#E7E6E6' AS "PRD_CODE_cell_background_color"             
            from
            (       
                select  
                       a.line_num + 1 as LINE
                     , b.cases as CASES        
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(b.weight) as WEIGHT       
                     , b.wt_uom as UOM          
                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD) as PRODUCT_CODE     
                     , b.PUR_DESCR as PRODUCT_DESC
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR_PRICE
                     , a.pur_price_uom                                                  as PER          -- PER
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                     , (select LISTAGG(prd.usda_plant, ',') 
                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                        where plant.tk_ow    = a.tk_ow 
                        and prd.tk_prd_plant = plant.tk_prd_plant
                        and plant.line_num   = a.line_num
                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                from workdesk.OW_PO_PRD_LINE a left join workdesk.OW_WS_PRD_LINE b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                where a.tk_ow = p_tk_ow
                order by a.line_num         
                    )ORDER BY line asc; 
    ELSE 
        BEGIN            
            SELECT set_wrksht_num
            into v_set_wrksht_num
            FROM OW_WORKSHEET_PUB
            WHERE tk_ow = p_tk_ow;

            SELECT max(version_num)-1 
            into v_pre_version_num
            FROM OW_WORKSHEET_PUB
            WHERE set_wrksht_num = v_set_wrksht_num;
        EXCEPTION WHEN OTHERS THEN
           v_set_wrksht_num  := NULL;
           v_pre_version_num := 0;
        END;    
        open rf_cur for
            select 
                     WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.PUR) as PUR
                    ,new_ver.CASES
                    ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.WEIGHT) as WEIGHT
                    ,new_ver.UOM
                    ,upper(new_ver.PRODUCT_DESC) as "PRD_DESC"
                    ,WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(new_ver.PUR_PRICE) as "P_PRICE"
                    ,new_ver.PER,upper(new_ver.PLANTS) as "PLANTS"
                    ,new_ver.LINE
                    ,new_ver.PRODUCT_CODE as "PRD_CODE" 
                    ,CASE WHEN nvl(new_ver.CASES,0)           <> nvl(old_ver.CASES,0)             THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "CASES_cell_background_color"  
                    ,CASE WHEN nvl(new_ver.WEIGHT,0)          <> nvl(old_ver.WEIGHT,0)            THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "WEIGHT_cell_background_color" 
                    ,CASE WHEN nvl(new_ver.UOM,' ')           <> nvl(old_ver.UOM,' ')             THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "UOM_cell_background_color"
                    ,CASE WHEN nvl(new_ver.PRODUCT_DESC,' ')  <> nvl(old_ver.PRODUCT_DESC,' ')    THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "PRD_DESC_cell_background_color" 
                    ,CASE WHEN nvl(new_ver.PUR_PRICE,0)       <> nvl(old_ver.PUR_PRICE,0)         THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "P_PRICE_cell_background_color" 
                    ,CASE WHEN nvl(new_ver.PER,' ')           <> nvl(old_ver.PER,' ')             THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "PER_cell_background_color"
                    ,CASE WHEN nvl(new_ver.PLANTS,' ')        <> nvl(old_ver.PLANTS,' ')          THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "PLANTS_cell_background_color" 
                    ,CASE WHEN nvl(new_ver.LINE,0)            <> nvl(old_ver.LINE,0)              THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "LINE_cell_background_color"
                    ,CASE WHEN nvl(new_ver.PUR,0)             <> nvl(old_ver.PUR,0)               THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "PUR_cell_background_color"  
                    ,CASE WHEN nvl(new_ver.PRODUCT_CODE,0)    <> nvl(old_ver.PRODUCT_CODE,0)      THEN APX_WOKDSK_AOP_TOOLKIT.RET_COLOR(v_pre_version_num) ELSE '#E7E6E6' END AS "PRD_CODE_cell_background_color" 
                from (
                     select  
                           a.line_num + 1 as LINE
                         , b.cases as CASES        -- cases
                         , b.weight as WEIGHT
                         , b.wt_uom as UOM          -- uom
                         ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD)            as PRODUCT_CODE     
                         , b.PUR_DESCR as PRODUCT_DESC
                         , decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as PUR_PRICE
                         , a.pur_price_uom                                                  as PER          -- PER
                         , workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR
                         , (select LISTAGG(prd.usda_plant, ',') 
                                WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                            from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                            where plant.tk_ow    = a.tk_ow 
                            and prd.tk_prd_plant = plant.tk_prd_plant
                            and plant.line_num   = a.line_num
                            group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                    from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                    where a.tk_ow = p_tk_ow  
                 )new_ver left join( 
                     select  
                           a.line_num + 1 as LINE
                         , b.cases as CASES        -- cases
                         , b.weight as WEIGHT
                         , b.wt_uom as UOM          -- uom
                         ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD)            as PRODUCT_CODE     
                         , b.PUR_DESCR as PRODUCT_DESC 
                         , decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as PUR_PRICE
                         , a.pur_price_uom                                                  as PER          -- PER
                         , (workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                         , (select LISTAGG(prd.usda_plant, ',') 
                                WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                            from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                            where plant.tk_ow    = a.tk_ow 
                            and prd.tk_prd_plant = plant.tk_prd_plant
                            and plant.line_num   = a.line_num
                            group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                    from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                    where a.tk_ow in (select tk_ow from workdesk.ow_worksheet_pub where set_wrksht_num = v_set_wrksht_num and version_num = v_pre_version_num)  
                ) old_ver
                --on new_ver.product_code = old_ver.product_code /*Producto cartesiano reportado por Beth*/
                on new_ver.line = old_ver.line
                ORDER BY line asc;                  
    END IF; 
    RETURN rf_cur;
END GET_INNER_QUERY_CONTRACT; 
FUNCTION GET_INNER_QUERY_CONTRACT_POS(p_tk_ow NUMBER, tk_contract NUMBER) RETURN sys_refcursor 
IS
    v_inner_query       CLOB;
    v_change_wildcard   VARCHAR2(3000); 
    v_change_wildcard_0 VARCHAR2(3000); 
    v_pre_version_num   NUMBER;
    v_set_wrksht_num    NUMBER;  
    v_status            VARCHAR2(30);
    rf_cur              sys_refcursor;       
BEGIN
    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;
      
    IF v_status = 'UNPUBLISHED' THEN 
        open rf_cur for
            SELECT OW.SET_WRKSHT_NUM as "SET_WRKSHT_NUM",PICKUP_PERIOD_DESCR as "PICKUP"
            FROM OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET OW, WORKDESK.OW_PUR_ORD  ORD 
            WHERE OW.TK_OW= ORD.TK_OW 
            AND WS.TK_CONTRACT = tk_contract
            AND OW.TK_OW= WS.TK_OW
            ORDER BY 1 ASC;
    ELSE   
        open rf_cur for
            SELECT OW.SET_WRKSHT_NUM as "SET_WRKSHT_NUM",PICKUP_PERIOD_DESCR as "PICKUP" 
            FROM OW_CONTRACT_WORKSHEET WS, OW_WORKSHEET_PUB OW, WORKDESK.OW_PUR_ORD_PUB  ORD 
            WHERE OW.TK_OW= ORD.TK_OW 
            AND WS.TK_CONTRACT = tk_contract
            AND OW.TK_OW= WS.TK_OW
            ORDER BY 1 ASC;
    END IF; 
    RETURN rf_cur;
END GET_INNER_QUERY_CONTRACT_POS; 
FUNCTION GET_INNER_QUERY_CONTRACT_PROD(p_tk_ow NUMBER) RETURN sys_refcursor 
IS
    v_inner_query       CLOB;
    v_change_wildcard   VARCHAR2(3000); 
    v_change_wildcard_0 VARCHAR2(3000); 
    v_pre_version_num   NUMBER;
    v_set_wrksht_num    NUMBER;  
    v_status            VARCHAR2(30);
    rf_cur              sys_refcursor;       
BEGIN
    SELECT STATUS
    into v_status
    FROM OW_WORKSHEET WORK
    WHERE WORK.TK_OW = p_tk_ow;
      
    IF v_status = 'UNPUBLISHED' THEN
        open rf_cur for
            select CASES,WEIGHT,UOM,PRODUCT_DESC as "PRD_DESC",PUR_PRICE as "P_PRICE",PER,PLANTS
            , LINE, PRODUCT_CODE as "PRD_CODE", PUR            
            from
            (       
                select  
                       a.line_num + 1 as LINE
                     , b.cases as CASES        
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(b.weight) as WEIGHT       
                     , b.wt_uom as UOM          
                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD) as PRODUCT_CODE     
                     , b.PUR_DESCR as PRODUCT_DESC
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR_PRICE
                     , a.pur_price_uom                                                  as PER          -- PER
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                     , (select LISTAGG(prd.usda_plant, ',') 
                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                        where plant.tk_ow    = a.tk_ow 
                        and prd.tk_prd_plant = plant.tk_prd_plant
                        and plant.line_num   = a.line_num
                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                from workdesk.OW_PO_PRD_LINE a left join workdesk.OW_WS_PRD_LINE b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                where a.tk_ow = p_tk_ow
                order by a.line_num         
                    )ORDER BY line asc; 
    ELSE 
        BEGIN            
            SELECT set_wrksht_num
            into v_set_wrksht_num
            FROM OW_WORKSHEET_PUB
            WHERE tk_ow = p_tk_ow;

            SELECT max(version_num)-1 
            into v_pre_version_num
            FROM OW_WORKSHEET_PUB
            WHERE set_wrksht_num = v_set_wrksht_num;
        EXCEPTION WHEN OTHERS THEN
           v_set_wrksht_num  := NULL;
           v_pre_version_num := 0;
        END;    
        open rf_cur for
            select CASES,WEIGHT,UOM,PRODUCT_DESC as "PRD_DESC",PUR_PRICE as "P_PRICE",PER,PLANTS
            , LINE, PRODUCT_CODE as "PRD_CODE", PUR            
            from
            (       
                select  
                       a.line_num + 1 as LINE
                     , b.cases as CASES        
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(b.weight) as WEIGHT       
                     , b.wt_uom as UOM          
                     ,(SELECT PRD_CODE FROM PRODUCT WHERE TK_PRD = a.TK_PRD) as PRODUCT_CODE     
                     , b.PUR_DESCR as PRODUCT_DESC
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt)) as PUR_PRICE
                     , a.pur_price_uom                                                  as PER          -- PER
                     , WORKDESK.APX_WOKDSK_AOP_TOOLKIT.FORMAT_PRICE_DECIMALS(workdesk.APX_WOKDSK_PO_TOOLKIT.CALCULATE_PUR_EXT(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as PUR
                     , (select LISTAGG(prd.usda_plant, ',') 
                            WITHIN GROUP (ORDER BY plant.tk_ow,plant.line_num) 
                        from workdesk.ow_po_prd_plants  plant, prd_plant prd  
                        where plant.tk_ow    = a.tk_ow 
                        and prd.tk_prd_plant = plant.tk_prd_plant
                        and plant.line_num   = a.line_num
                        group by plant.tk_ow,plant.line_num)                                         as PLANTS       --Plants  
                from workdesk.OW_PO_PRD_LINE_PUB a left join workdesk.OW_WS_PRD_LINE_PUB b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
                where a.tk_ow = p_tk_ow
                order by a.line_num         
                    )ORDER BY line asc;                 
    END IF; 
    RETURN rf_cur;
END GET_INNER_QUERY_CONTRACT_PROD; 
PROCEDURE GET_COMPANY_DATA(
    p_tk_org          NUMBER,
    p_company_name    OUT VARCHAR2,
    p_company_address OUT VARCHAR2,
    p_company_city    OUT VARCHAR2,
    p_company_state   OUT VARCHAR2,
    p_company_zip     OUT VARCHAR2,
    p_company_country OUT VARCHAR2,
    p_company_tc_url  OUT VARCHAR2 
) IS
BEGIN
    SELECT replace(comp.co_name,'''',''''''), comp.addr1, comp.city, comp.state,comp.zip, coun.cntry_name, 'http://'|| comp.termsconditionurl
    into p_company_name       
        ,p_company_address    
        ,p_company_city       
        ,p_company_state      
        ,p_company_zip        
        ,p_company_country 
        ,p_company_tc_url   
    FROM COMPANY comp, country coun
    WHERE comp.tk_cntry = coun.tk_cntry
    AND comp.tk_org =nvl(p_tk_org,3);  
EXCEPTION WHEN NO_DATA_FOUND THEN  
    p_company_name     := NULL;  
    p_company_address  := NULL;  
    p_company_city     := NULL;  
    p_company_state    := NULL;  
    p_company_zip      := NULL;  
    p_company_country  := NULL; 
    p_company_tc_url   := NULL;
END GET_COMPANY_DATA;
FUNCTION GET_SUPPLIER_NAME(
    p_vendor_id   NUMBER
)RETURN VARCHAR2 IS
    p_vendor_name VARCHAR2(500);
BEGIN
    SELECT VENDOR_NAME
    into p_vendor_name
    FROM PO_VENDORS
    WHERE VENDOR_TYPE_LOOKUP_CODE = 'SUPPLIER'
    AND VENDOR_ID =  p_vendor_id
    AND END_DATE_ACTIVE IS NULL 
        OR END_DATE_ACTIVE > SYSDATE;  
    RETURN p_vendor_name;

EXCEPTION WHEN NO_DATA_FOUND THEN  
    RETURN NULL; 
END GET_SUPPLIER_NAME;  

FUNCTION GET_SUPPLIER_NOTES(p_tk_ow NUMBER, p_status VARCHAR2, p_note_type VARCHAR2) RETURN VARCHAR2 IS
    p_note VARCHAR2(5000);
BEGIN

    IF p_status = 'UNPUBLISHED' THEN
        SELECT NOTE 
        into p_note
        FROM OW_WS_NOTE 
        WHERE TYPE = p_note_type
        AND TK_OW = p_tk_ow; 
    ELSIF p_status = 'PUBLISHED' THEN
        SELECT NOTE 
        into p_note
        FROM OW_WS_NOTE_PUB
        WHERE TYPE = p_note_type
        AND TK_OW = p_tk_ow;     
    END IF;
    
    RETURN p_note;  
EXCEPTION WHEN NO_DATA_FOUND THEN  
    RETURN NULL;     
END GET_SUPPLIER_NOTES;   

FUNCTION GET_DEST_PORT( p_tk_port VARCHAR2 ) RETURN VARCHAR2 IS
    v_port_name VARCHAR2(500);
BEGIN
    select INITCAP(port_name)
    into v_port_name
    from ports
    where tk_port = to_number(p_tk_port);
    RETURN v_port_name;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN  
        RETURN NULL; 
    WHEN OTHERS THEN --Fix Old Wordesk https://ajcict.atlassian.net/browse/OW-320 
        RETURN 'xYzA';     
END GET_DEST_PORT; 
FUNCTION GET_PROVINCE_NAME(
    p_tk_prov      VARCHAR2
)RETURN VARCHAR2 IS
    p_tk_prov_name VARCHAR2(500);
BEGIN
    select initcap(descr) d
    into p_tk_prov_name 
    from ATISPROD.PROVINCE p, country c
    where c.tk_cntry = p.tk_cntry
    AND p.TK_PROVINCE = to_number(p_tk_prov);
    RETURN p_tk_prov_name;
EXCEPTION WHEN NO_DATA_FOUND THEN  
    RETURN NULL; 
    WHEN OTHERS THEN --Fix Old Wordesk https://ajcict.atlassian.net/browse/OW-320 
        RETURN 'xYzA';      
END GET_PROVINCE_NAME;  
FUNCTION GET_COUNTRY_NAME(
    p_tk_cntry      VARCHAR2
)RETURN VARCHAR2 IS
    p_tk_cntry_name VARCHAR2(500);
BEGIN
    SELECT initcap(c.cntry_name) 
    into p_tk_cntry_name
    FROM country c, rgn_cntry rc
    WHERE c.tk_cntry  = rc.tk_cntry
    AND c.tk_cntry = to_number(p_tk_cntry) 
    AND active_closed = 'A' ; 
    RETURN p_tk_cntry_name;
EXCEPTION WHEN NO_DATA_FOUND THEN  
    RETURN NULL; 
    WHEN OTHERS THEN --Fix Old Wordesk https://ajcict.atlassian.net/browse/OW-320 
        RETURN 'xYzA';      
END GET_COUNTRY_NAME;   
FUNCTION GET_INCOTERM(
    p_incoterm      VARCHAR2
)RETURN VARCHAR2 IS
    p_incoterm_name VARCHAR2(5);
BEGIN
    select TERMS_CODE
    into p_incoterm_name
    from sale_purch_terms
    where descr <> 'DO NOT USE'
    AND SP_TERMS_ID = p_incoterm
    AND descr <> 'XXX';
    RETURN p_incoterm_name;
EXCEPTION WHEN NO_DATA_FOUND THEN  
    RETURN NULL; 
    WHEN OTHERS THEN --Fix Old Wordesk https://ajcict.atlassian.net/browse/OW-320
        RETURN 'xYzA';     
END GET_INCOTERM; 
FUNCTION GET_PURCHASE_TERMS(
    p_pur_terms        VARCHAR2    
)RETURN VARCHAR2 IS
    p_pur_terms_desc VARCHAR2(500);
BEGIN    
    SELECT DESCRIPTION
    into p_pur_terms_desc
    FROM AP_TERMS_TL
    WHERE ENABLED_FLAG ='Y'
    AND TERM_ID = to_number(p_pur_terms);  
    RETURN p_pur_terms_desc;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN  
        RETURN NULL; 
    WHEN OTHERS THEN --Fix Old Wordesk https://ajcict.atlassian.net/browse/OW-320
        RETURN 'xYzA';      
END GET_PURCHASE_TERMS; 
PROCEDURE GET_EMPLOYEE_DATA(
    p_tk    NUMBER, 
    p_name  OUT VARCHAR2,
    p_phone OUT VARCHAR2,
    p_mail  OUT VARCHAR2
)IS
BEGIN    
    SELECT initcap(FULL_NAME), lower(EMAIL), PHONE
    into p_name, p_mail, p_phone
    FROM A_EMPLOYEE
    WHERE TK_EMPLOYEE = p_tk;
    
    BEGIN
        IF p_phone IS NULL THEN
            SELECT PHONE_NUMBER
            into p_phone
            FROM OW_EMPLOYEE_DATA
            WHERE UPPER(EMAIL) = UPPER(p_mail);
        END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_phone := NULL;              
    END;
    
EXCEPTION WHEN NO_DATA_FOUND THEN  
    p_name  := NULL;
    p_phone := NULL;   
    p_mail  := NULL;      
END GET_EMPLOYEE_DATA; 

END APX_WOKDSK_AOP_TOOLKIT;
/


GRANT EXECUTE ON WORKDESK.APX_WOKDSK_AOP_TOOLKIT TO OMS;
