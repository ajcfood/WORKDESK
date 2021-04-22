DROP TABLE WORKDESK.OW_SALE_ALLOC_PUB CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_SALE_ALLOC_PUB
(
  TK_OW              NUMBER(7)                  NOT NULL,
  LINE_NUM           NUMBER(5)                  NOT NULL,
  PO_SET_WRKSHT_NUM  NUMBER(7),
  TK_INV_LOT         NUMBER(8)
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

COMMENT ON TABLE WORKDESK.OW_SALE_ALLOC_PUB IS 'This table includes allocations for lines for published Worksheets/Templates created through Order Workdesk.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_SALE_ALLOC_PUB ON WORKDESK.OW_SALE_ALLOC_PUB
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

ALTER TABLE WORKDESK.OW_SALE_ALLOC_PUB ADD (
  CONSTRAINT PK_OW_SALE_ALLOC_PUB
  PRIMARY KEY
  (TK_OW, LINE_NUM)
  USING INDEX WORKDESK.PK_OW_SALE_ALLOC_PUB
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_SALE_ALLOC_PUB FOR WORKDESK.OW_SALE_ALLOC_PUB;


ALTER TABLE WORKDESK.OW_SALE_ALLOC_PUB ADD (
  CONSTRAINT FK_OW_SALE_ALLOC_PUB_SO_PRD_LN 
  FOREIGN KEY (TK_OW, LINE_NUM) 
  REFERENCES WORKDESK.OW_SO_PRD_LINE_PUB (TK_OW, LINE_NUM)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SALE_ALLOC_PUB TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SALE_ALLOC_PUB TO PUBLIC;
