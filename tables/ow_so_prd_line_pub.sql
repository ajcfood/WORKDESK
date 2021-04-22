DROP TABLE WORKDESK.OW_SO_PRD_LINE_PUB CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_SO_PRD_LINE_PUB
(
  TK_OW            NUMBER(7)                    NOT NULL,
  LINE_NUM         NUMBER(5)                    NOT NULL,
  SELL_PRICE_CASE  NUMBER(15,7),
  SELL_PRICE_WT    NUMBER(15,7),
  SELL_PRICE_UOM   VARCHAR2(6 BYTE)
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

COMMENT ON TABLE WORKDESK.OW_SO_PRD_LINE_PUB IS 'This table includes all product lines for published Worksheets/Templates created through Order Workdesk.';

COMMENT ON COLUMN WORKDESK.OW_SO_PRD_LINE_PUB.TK_OW IS 'This is the id for the worksheet.';

COMMENT ON COLUMN WORKDESK.OW_SO_PRD_LINE_PUB.LINE_NUM IS 'This is the worksheet line number.';

COMMENT ON COLUMN WORKDESK.OW_SO_PRD_LINE_PUB.SELL_PRICE_CASE IS 'This is the price per case.';

COMMENT ON COLUMN WORKDESK.OW_SO_PRD_LINE_PUB.SELL_PRICE_WT IS 'This is the price per UOM (other than case)';

COMMENT ON COLUMN WORKDESK.OW_SO_PRD_LINE_PUB.SELL_PRICE_UOM IS 'Selling Price UOM';


CREATE UNIQUE INDEX WORKDESK.PK_OW_SO_PRD_LINE_PUB ON WORKDESK.OW_SO_PRD_LINE_PUB
(TK_OW, LINE_NUM)
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

ALTER TABLE WORKDESK.OW_SO_PRD_LINE_PUB ADD (
  CONSTRAINT PK_OW_SO_PRD_LINE_PUB
  PRIMARY KEY
  (TK_OW, LINE_NUM)
  USING INDEX WORKDESK.PK_OW_SO_PRD_LINE_PUB
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_SO_PRD_LINE_PUB FOR WORKDESK.OW_SO_PRD_LINE_PUB;


ALTER TABLE WORKDESK.OW_SO_PRD_LINE_PUB ADD (
  CONSTRAINT FK_OW_SO_PRD_LINE_PUB_SALE_ORD 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_SALE_ORD_PUB (TK_OW)
  ENABLE VALIDATE
,  CONSTRAINT FK_OW_WS_SO_PRD_LINE_PUB 
  FOREIGN KEY (TK_OW, LINE_NUM) 
  REFERENCES WORKDESK.OW_WS_PRD_LINE_PUB (TK_OW, LINE_NUM)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SO_PRD_LINE_PUB TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SO_PRD_LINE_PUB TO PUBLIC;
