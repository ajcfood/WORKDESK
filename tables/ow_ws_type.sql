DROP TABLE WORKDESK.OW_WS_TYPE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_TYPE
(
  TYPE              VARCHAR2(30 BYTE)           NOT NULL,
  DESCR             VARCHAR2(64 BYTE),
  CREATION_DATE     DATE                        NOT NULL,
  CREATED_BY        NUMBER(15)                  NOT NULL,
  LAST_UPDATE_DATE  DATE,
  LAST_UPDATED_BY   NUMBER(15)
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

COMMENT ON TABLE WORKDESK.OW_WS_TYPE IS 'This table includes the notes for Worksheets.';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.TYPE IS 'Type of worksheet';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.DESCR IS 'Worksheet type description.';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.OW_WS_TYPE.LAST_UPDATED_BY IS 'User id of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_TYPE ON WORKDESK.OW_WS_TYPE
(TYPE)
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

ALTER TABLE WORKDESK.OW_WS_TYPE ADD (
  CONSTRAINT PK_OW_WS_TYPE
  PRIMARY KEY
  (TYPE)
  USING INDEX WORKDESK.PK_OW_WS_TYPE
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_TYPE FOR WORKDESK.OW_WS_TYPE;


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_TYPE TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_TYPE TO PUBLIC;
