DROP TABLE WORKDESK.OW_WS_STATUS CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_STATUS
(
  STATUS            VARCHAR2(30 BYTE)           NOT NULL,
  DESCR             VARCHAR2(64 BYTE),
  SEQ               NUMBER                      NOT NULL,
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

COMMENT ON TABLE WORKDESK.OW_WS_STATUS IS 'This table includes status for Worksheets.';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.STATUS IS 'Status';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.DESCR IS 'Status description.';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.SEQ IS 'This is the sequence in which statuses should be sorted when displayed';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.OW_WS_STATUS.LAST_UPDATED_BY IS 'User id of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_STATUS ON WORKDESK.OW_WS_STATUS
(STATUS)
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

ALTER TABLE WORKDESK.OW_WS_STATUS ADD (
  CONSTRAINT PK_OW_STATUS
  PRIMARY KEY
  (STATUS)
  USING INDEX WORKDESK.PK_OW_STATUS
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_STATUS FOR WORKDESK.OW_WS_STATUS;


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_STATUS TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_STATUS TO PUBLIC;
