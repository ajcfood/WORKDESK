DROP TRIGGER WORKDESK.CONTRACT_CREDIT_HOLD;

CREATE OR REPLACE TRIGGER WORKDESK.CONTRACT_CREDIT_HOLD
 BEFORE 
 UPDATE
 ON WORKDESK.OW_CONTRACT  REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
WHEN (
NEW.status = 'PUBLISHED'
      )
DECLARE

v_cust number;
v_crdit_hold Varchar2(5);

BEGIN

  select distinct so.cust_account_id
  into v_cust
  from ow_sale_ord so, ow_contract_worksheet cw
  where so.tk_ow = cw.tk_ow
  and cw.tk_contract = :NEW.tk_contract
  and rownum = 1;

  if v_cust > 0  then

    select credit_hold
    into v_crdit_hold
    from apps_orafsys.HZ_CUSTOMER_PROFILES
    where cust_account_id = v_cust
    AND ROWNUM = 1;

    if v_crdit_hold = 'Y' then
      RAISE_APPLICATION_ERROR(-20999, 'The customer you want to use was put on hold by the credit department.');
    end if;
  end if;

EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, sqlerrm || ' - TK_CONTRACT: ' || :NEW.tk_contract || ' - CUSTOMER: ' || v_cust);
END;
/
