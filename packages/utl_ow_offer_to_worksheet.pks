DROP PACKAGE WORKDESK.UTL_OW_OFFER_TO_WORKSHEET;

CREATE OR REPLACE PACKAGE WORKDESK.UTL_OW_OFFER_TO_WORKSHEET 
AS 
CONST_PACKAGE_NAME CONSTANT VARCHAR2(100) := 'UTL_OW_OFFER_TO_WORKSHEET';


PROCEDURE CREATE_FROM_OFFER(
p_tk_sup_offer      NUMBER,
p_sp_terms_id        NUMBER,
p_tk_port            NUMBER,
p_tk_cntry           NUMBER,
p_tk_owner              NUMBER,
p_type           varchar2,
p_number_worksheets     NUMBER,
p_tk_ow             OUT NUMBER,
Err_MSG             OUT varchar
);
PROCEDURE OW_WORKSHEET_INSERT_PRODUCTS(
p_tk_ow             NUMBER,
p_tk_sup_offer      NUMBER,
p_tk_sup_offerln    NUMBER,
p_sp_terms_id        NUMBER,
p_tk_port            NUMBER,
p_uom               VARCHAR2,
p_tk_owner              NUMBER,
p_currency_code     VARCHAR2,
pEXECUTION_ID         IN NUMBER
);
PROCEDURE CREATE_FROM_OFFERLN(
        p_share_a_offerLNs   IN arrayofOFFERLN,
        p_sp_terms_id        NUMBER,
        p_tk_port            NUMBER,
        p_tk_cntry           NUMBER,
        p_tk_owner              NUMBER,
        p_type           varchar2,
        p_number_worksheets     NUMBER,
        p_tk_ow             OUT NUMBER,
        Err_MSG             OUT varchar2           
);
PROCEDURE CREATE_HEADERS_FROM_OFFERLN (
        p_tk_sup_offerln      NUMBER,
        p_sp_terms_id        NUMBER,
        p_tk_port            NUMBER,
        p_tk_cntry           NUMBER,
        p_tk_owner              NUMBER,
        p_type           varchar2,
        p_shipment      varchar2,
        p_tk_sup_offer         OUT NUMBER,  
        p_tk_ow                 OUT NUMBER
);
PROCEDURE OW_WORKSHEET_INSERT_PRODUCTLN(
        p_tk_ow             NUMBER,
        p_tk_sup_offerln    NUMBER,
        p_sp_terms_id        NUMBER,
        p_tk_port            NUMBER,
        p_uom               varchar2,
        p_tk_owner          number,
        p_currency_code     varchar2,
        pEXECUTION_ID         IN NUMBER,
        p_rownumber         number
); 

FUNCTION GET_PUR_DESCR(
p_tk_sup_offer      IN NUMBER,
p_tk_sup_offerln    IN NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) RETURN VARCHAR2;

END UTL_OW_OFFER_TO_WORKSHEET;
/


GRANT EXECUTE ON WORKDESK.UTL_OW_OFFER_TO_WORKSHEET TO OMS;
