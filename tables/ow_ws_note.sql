DROP TABLE WORKDESK.OW_WS_NOTE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_NOTE
(
  TK_OW  NUMBER(7)                              NOT NULL,
  TYPE   VARCHAR2(30 BYTE)                      NOT NULL,
  NOTE   VARCHAR2(2500 BYTE)                    NOT NULL
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

COMMENT ON TABLE WORKDESK.OW_WS_NOTE IS 'This table includes the notes for Worksheets.';

COMMENT ON COLUMN WORKDESK.OW_WS_NOTE.TK_OW IS 'Worksheet Number to identify the Worksheet.';

COMMENT ON COLUMN WORKDESK.OW_WS_NOTE.TYPE IS 'Type of note (Customer, Supplier, Internal)';

COMMENT ON COLUMN WORKDESK.OW_WS_NOTE.NOTE IS 'Note';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_NOTE ON WORKDESK.OW_WS_NOTE
(TK_OW, TYPE)
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

ALTER TABLE WORKDESK.OW_WS_NOTE ADD (
  CONSTRAINT PK_OW_WS_NOTE
  PRIMARY KEY
  (TK_OW, TYPE)
  USING INDEX WORKDESK.PK_OW_WS_NOTE
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_NOTE FOR WORKDESK.OW_WS_NOTE;


ALTER TABLE WORKDESK.OW_WS_NOTE ADD (
  CONSTRAINT FK_OW_NOTE_TYPE_WORKSHEET 
  FOREIGN KEY (TYPE) 
  REFERENCES WORKDESK.OW_NOTE_TYPE (TYPE)
  ENABLE VALIDATE
,  CONSTRAINT FK_OW_WS_NOTE 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET (TK_OW)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_NOTE TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_NOTE TO PUBLIC;
