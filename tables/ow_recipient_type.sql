DROP TABLE WORKDESK.OW_RECIPIENT_TYPE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_RECIPIENT_TYPE
(
  TYPE              VARCHAR2(56 BYTE)           NOT NULL,
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


CREATE UNIQUE INDEX WORKDESK.PK_OW_RECIPIENT_TYPE ON WORKDESK.OW_RECIPIENT_TYPE
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

ALTER TABLE WORKDESK.OW_RECIPIENT_TYPE ADD (
  CONSTRAINT PK_OW_RECIPIENT_TYPE
  PRIMARY KEY
  (TYPE)
  USING INDEX WORKDESK.PK_OW_RECIPIENT_TYPE
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_RECIPIENT_TYPE FOR WORKDESK.OW_RECIPIENT_TYPE;


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_RECIPIENT_TYPE TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_RECIPIENT_TYPE TO PUBLIC;
