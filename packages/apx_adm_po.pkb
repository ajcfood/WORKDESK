DROP PACKAGE BODY WORKDESK.APX_ADM_PO;

CREATE OR REPLACE PACKAGE BODY WORKDESK."APX_ADM_PO" AS 

  FUNCTION Get_Product_List_Offer_List(
                p_ow_tk IN NUMBER,
                p_max_product IN NUMBER DEFAULT NULL,
                p_status IN VARCHAR2 DEFAULT 'ACTIVE'
                )RETURN VARCHAR2

IS
    v_return    VARCHAR2(4000);
    v_count     number :=0;

      CURSOR c_products IS   
        SELECT  buy_descr
          FROM product 
        WHERE tk_prd in ( select tk_prd from workdesk.ow_po_prd_line where tk_ow = p_ow_tk);
        
BEGIN

    FOR rec IN c_products LOOP
        IF (v_count = 0) then
            v_return := rec.buy_descr;
        else
            if (v_count < p_max_product) then
                v_return := v_return || '</br>'|| rec.buy_descr;
            end if;
        end if;
        v_count := v_count + 1;
    END LOOP;

    if (v_count > p_max_product) then
        v_return := v_return || '<br/>and '||to_char(v_count-p_max_product) ||' more...';

    end if;

    return v_return;

END Get_Product_List_Offer_List;


END APX_ADM_PO;
/


GRANT EXECUTE ON WORKDESK.APX_ADM_PO TO OMS;
