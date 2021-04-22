DROP TRIGGER WORKDESK.CONTRACT_B2B;

CREATE OR REPLACE TRIGGER WORKDESK.CONTRACT_B2B
  BEFORE UPDATE OF status ON WORKDESK.OW_CONTRACT FOR EACH ROW
WHEN (
NEW.status = 'PUBLISHED'
      )
DECLARE

v_cust number;
v_vendor number;

BEGIN

  select distinct so.cust_account_id
  into v_cust
  from ow_sale_ord so, ow_contract_worksheet cw
  where so.tk_ow = cw.tk_ow 
  and cw.tk_contract = :NEW.tk_contract
  and rownum = 1;
  
  select distinct po.vendor_id
  into v_vendor
  from ow_pur_ord po, ow_contract_worksheet cw
  where po.tk_ow = cw.tk_ow 
  and cw.tk_contract = :NEW.tk_contract
  and rownum = 1;
 
  if v_cust > 0 and v_vendor > 0 then      
      RAISE_APPLICATION_ERROR(-20001, 'You can not publish a BACK TO BACK Contract. Please clear either the Purchase or Sale information.');
  end if;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, sqlerrm || ' - TK_CONTRACT: ' || :NEW.tk_contract || ' - CUSTOMER: ' || v_cust || ' - VENDOR: ' ||v_vendor);
END;
/
