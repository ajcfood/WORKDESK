DROP TABLE WORKDESK.OW_CONTRACT CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_CONTRACT
(
  TK_CONTRACT          NUMBER(7)                NOT NULL,
  NAME                 VARCHAR2(256 BYTE)       NOT NULL,
  TEMPLATE_TK_OW       NUMBER(7)                NOT NULL,
  STATUS               VARCHAR2(30 BYTE)        NOT NULL,
  LAST_PUBLISHED_DATE  DATE,
  OWNER                NUMBER(15)               NOT NULL,
  CREATION_DATE        DATE                     NOT NULL,
  CREATED_BY           NUMBER(15)               NOT NULL,
  LAST_UPDATE_DATE     DATE,
  LAST_UPDATED_BY      NUMBER(15),
  ODS                  VARCHAR2(1 BYTE)         DEFAULT 'N'                   NOT NULL,
  NEW_OW               CHAR(1 BYTE)
)
TABLESPACE WORKDESK_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             40K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           )
LOGGING 
NOCOMPRESS 
NOCACHE;

COMMENT ON TABLE WORKDESK.OW_CONTRACT IS 'This table represents a contract (group of worksheets)';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.TK_CONTRACT IS 'This is the id of the contract';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.NAME IS 'This is the name of the contract';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.TEMPLATE_TK_OW IS 'This is the id of the template used in the contract';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.LAST_PUBLISHED_DATE IS 'This is the date when the contract was last published';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.OWNER IS 'This is employee id of the owner of the contract';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.OW_CONTRACT.LAST_UPDATED_BY IS 'User id of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_CONTRACT ON WORKDESK.OW_CONTRACT
(TK_CONTRACT)
LOGGING
TABLESPACE WORKDESK_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             40K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE WORKDESK.OW_CONTRACT ADD (
  CONSTRAINT PK_OW_CONTRACT
  PRIMARY KEY
  (TK_CONTRACT)
  USING INDEX WORKDESK.PK_OW_CONTRACT
  ENABLE VALIDATE);


CREATE INDEX WORKDESK.OW_CONTRACT_IDX1 ON WORKDESK.OW_CONTRACT
(TEMPLATE_TK_OW)
LOGGING
TABLESPACE WORKDESK_DATA
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          40K
            NEXT             40K
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );

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


CREATE OR REPLACE PUBLIC SYNONYM OW_CONTRACT FOR WORKDESK.OW_CONTRACT;


ALTER TABLE WORKDESK.OW_CONTRACT ADD (
  CONSTRAINT FK_OW_CONTRACT_STATUS 
  FOREIGN KEY (STATUS) 
  REFERENCES WORKDESK.OW_WS_STATUS (STATUS)
  ENABLE VALIDATE
,  CONSTRAINT FK_OW_CONTRACT_TK_OW 
  FOREIGN KEY (TEMPLATE_TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET (TK_OW)
  DISABLE NOVALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_CONTRACT TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_CONTRACT TO PUBLIC;
