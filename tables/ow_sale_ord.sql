DROP TABLE WORKDESK.OW_SALE_ORD CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_SALE_ORD
(
  TK_OW                 NUMBER(7)               NOT NULL,
  CUST_ACCOUNT_ID       NUMBER(22),
  SALE_TERMS_DESCR      VARCHAR2(50 BYTE),
  SHIP_PERIOD_DESCR     VARCHAR2(25 BYTE),
  ARRIVAL_PERIOD_DESCR  VARCHAR2(25 BYTE),
  CONTACT               VARCHAR2(100 BYTE),
  CUST_ORD_NUM          VARCHAR2(50 BYTE),
  PAY_TERM_ID           NUMBER(7),
  SALE_CONTRACT_DATE    DATE,
  TK_EMP_TRADER         NUMBER(15),
  TK_EMP_TRF            NUMBER(15),
  TRANSIT_DAYS          NUMBER(5),
  PRODUCT_DAYS          NUMBER(5),
  PERCENT_DOWN          NUMBER(7,3),
  DAE                   NUMBER(8,2),
  CURRENCY_CODE         VARCHAR2(15 BYTE),
  EXCHANGE_RATE         NUMBER(13,7),
  EXP_ORIG_TK_CNTRY     NUMBER(5)
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

COMMENT ON TABLE WORKDESK.OW_SALE_ORD IS 'This table includes Purchase header information for all Worksheets/Templates created through Order Workdesk.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.TK_OW IS 'This is the id for the Worksheet/Template.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.CUST_ACCOUNT_ID IS 'Customer - This is the ID of the customer';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.SALE_TERMS_DESCR IS 'Sale Terms - This is the description of the sale terms.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.SHIP_PERIOD_DESCR IS 'For Shipment';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.ARRIVAL_PERIOD_DESCR IS 'For Arrival';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.CONTACT IS 'This is the Customer Contact for the Order.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.CUST_ORD_NUM IS 'Cust Ref # - This is the customer reference number.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.PAY_TERM_ID IS 'Sale Pay Terms - This is the ID of the sale terms (Wire Transfer in Advance, Open Account, etc.).';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.SALE_CONTRACT_DATE IS 'Contract Date - Date of the sale contract';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.TK_EMP_TRADER IS 'Seller Id';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.TK_EMP_TRF IS 'Traffic Cordinator Id';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.TRANSIT_DAYS IS 'Transit Days';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.PRODUCT_DAYS IS 'Product Days we get to pay from the Supplier';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.PERCENT_DOWN IS 'Sale % Down - Sale percent required prior to loading.';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.DAE IS 'DAE ';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.CURRENCY_CODE IS 'Sale Price Curr';

COMMENT ON COLUMN WORKDESK.OW_SALE_ORD.EXCHANGE_RATE IS 'Rate ';


CREATE UNIQUE INDEX WORKDESK.PK_OW_SALE_ORD ON WORKDESK.OW_SALE_ORD
(TK_OW)
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

ALTER TABLE WORKDESK.OW_SALE_ORD ADD (
  CONSTRAINT PK_OW_SALE_ORD
  PRIMARY KEY
  (TK_OW)
  USING INDEX WORKDESK.PK_OW_SALE_ORD
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_SALE_ORD FOR WORKDESK.OW_SALE_ORD;


ALTER TABLE WORKDESK.OW_SALE_ORD ADD (
  CONSTRAINT FK_OW_SALE_ORD_WORKSHEET 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET (TK_OW)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SALE_ORD TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SALE_ORD TO PUBLIC;
