DROP TABLE WORKDESK.OW_WS_LC_PUB CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_LC_PUB
(
  TK_OW               NUMBER(7)                 NOT NULL,
  LC_LATEST_SHIPMENT  VARCHAR2(25 BYTE),
  LC_PARTIAL          VARCHAR2(25 BYTE),
  LC_TOLERANCE        VARCHAR2(25 BYTE),
  LC_SIGNATURE        VARCHAR2(25 BYTE)
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

COMMENT ON TABLE WORKDESK.OW_WS_LC_PUB IS 'This table LC data for published Worksheets.';

COMMENT ON COLUMN WORKDESK.OW_WS_LC_PUB.LC_LATEST_SHIPMENT IS 'Latest Shpmt - Latest LC shipment date';

COMMENT ON COLUMN WORKDESK.OW_WS_LC_PUB.LC_PARTIAL IS 'Partial';

COMMENT ON COLUMN WORKDESK.OW_WS_LC_PUB.LC_TOLERANCE IS 'Tolerance';

COMMENT ON COLUMN WORKDESK.OW_WS_LC_PUB.LC_SIGNATURE IS 'Signature';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_LC_PUB ON WORKDESK.OW_WS_LC_PUB
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

ALTER TABLE WORKDESK.OW_WS_LC_PUB ADD (
  CONSTRAINT PK_OW_WS_LC_PUB
  PRIMARY KEY
  (TK_OW)
  USING INDEX WORKDESK.PK_OW_WS_LC_PUB
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_LC_PUB FOR WORKDESK.OW_WS_LC_PUB;


ALTER TABLE WORKDESK.OW_WS_LC_PUB ADD (
  CONSTRAINT FK_OW_WS_LC_PUB_WORKSHEET 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET_PUB (TK_OW)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_LC_PUB TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_LC_PUB TO PUBLIC;