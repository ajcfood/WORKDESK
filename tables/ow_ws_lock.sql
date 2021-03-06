DROP TABLE WORKDESK.OW_WS_LOCK CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_LOCK
(
  SET_WRKSHT_NUM    NUMBER(7)                   NOT NULL,
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

COMMENT ON TABLE WORKDESK.OW_WS_LOCK IS 'This table shows when there is a lock on a worksheet. ';

COMMENT ON COLUMN WORKDESK.OW_WS_LOCK.SET_WRKSHT_NUM IS 'Worksheet Number';

COMMENT ON COLUMN WORKDESK.OW_WS_LOCK.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.OW_WS_LOCK.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.OW_WS_LOCK.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.OW_WS_LOCK.LAST_UPDATED_BY IS 'User id    of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_LOCK ON WORKDESK.OW_WS_LOCK
(SET_WRKSHT_NUM)
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

ALTER TABLE WORKDESK.OW_WS_LOCK ADD (
  CONSTRAINT PK_OW_WS_LOCK
  PRIMARY KEY
  (SET_WRKSHT_NUM)
  USING INDEX WORKDESK.PK_OW_WS_LOCK
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_LOCK FOR WORKDESK.OW_WS_LOCK;


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_LOCK TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_LOCK TO PUBLIC;
