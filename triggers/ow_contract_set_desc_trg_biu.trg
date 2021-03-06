DROP TRIGGER WORKDESK.OW_CONTRACT_SET_DESC_TRG_BIU;

CREATE OR REPLACE TRIGGER WORKDESK.OW_CONTRACT_SET_DESC_TRG_BIU 
    BEFORE UPDATE OR INSERT ON WORKDESK.OW_CONTRACT FOR EACH ROW
DECLARE
    V_CONTRACT_NAME OW_CONTRACT.NAME%TYPE;
BEGIN
    IF TRIM(:NEW.NAME) IS NULL THEN
    
        SELECT DESCRIPTION
          INTO V_CONTRACT_NAME
          FROM OW_WORKSHEET
         WHERE TK_OW = :NEW.TEMPLATE_TK_OW;
    
    
        :NEW.NAME := V_CONTRACT_NAME;
    END IF;     
END OW_CONTRACT_SET_DESC_TRG_BIU;
/
