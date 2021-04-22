DROP TRIGGER WORKDESK.WORKSHEET_B2B;

CREATE OR REPLACE TRIGGER WORKDESK.WORKSHEET_B2B
  BEFORE UPDATE OF status ON WORKDESK.OW_WORKSHEET FOR EACH ROW
WHEN (
NEW.status = 'PUBLISHED'
      )
DECLARE

v_cust number;
v_vendor number;

BEGIN

  select distinct cust_account_id
  into v_cust
  from ow_sale_ord
  where tk_ow = :NEW.tk_ow
  and rownum = 1;
  
  select distinct vendor_id
  into v_vendor
  from ow_pur_ord
  where tk_ow = :NEW.tk_ow
  and rownum = 1;
 
  if v_cust > 0 and v_vendor > 0 then
      RAISE_APPLICATION_ERROR(-20001, 'You can not publish a BACK TO BACK worksheet. Please clear either the Purchase or Sale information.');
  end if;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, sqlerrm || ' - TK_OW: ' || :NEW.tk_ow || ' - CUSTOMER: ' || v_cust || ' - VENDOR: ' ||v_vendor);
END;
/
