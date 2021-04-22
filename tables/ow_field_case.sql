DROP TABLE WORKDESK.OW_FIELD_CASE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_FIELD_CASE
(
  CASE              VARCHAR2(30 BYTE)           NOT NULL,
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


CREATE UNIQUE INDEX WORKDESK.PK_OW_FIELD_CASE ON WORKDESK.OW_FIELD_CASE
(CASE)
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

ALTER TABLE WORKDESK.OW_FIELD_CASE ADD (
  CONSTRAINT PK_OW_FIELD_CASE
  PRIMARY KEY
  (CASE)
  USING INDEX WORKDESK.PK_OW_FIELD_CASE
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_FIELD_CASE FOR WORKDESK.OW_FIELD_CASE;


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_FIELD_CASE TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_FIELD_CASE TO PUBLIC;
