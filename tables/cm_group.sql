DROP TABLE WORKDESK.CM_GROUP CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.CM_GROUP
(
  TK_GROUP          NUMBER(7)                   NOT NULL,
  NAME              VARCHAR2(64 BYTE)           NOT NULL,
  DESCR             VARCHAR2(128 BYTE)          NOT NULL,
  ACTIVE            VARCHAR2(1 BYTE)            DEFAULT 'Y'                   NOT NULL,
  CREATION_DATE     DATE                        NOT NULL,
  CREATED_BY        NUMBER(15)                  NOT NULL,
  LAST_UPDATE_DATE  DATE,
  LAST_UPDATED_BY   NUMBER(15)
)
TABLESPACE CM_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
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

COMMENT ON TABLE WORKDESK.CM_GROUP IS 'This table contains internal AJC workgroups.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.TK_GROUP IS 'The unique system id of the group.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.NAME IS 'Display name of the group.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.DESCR IS 'Group description.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.CM_GROUP.LAST_UPDATED_BY IS 'User id of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_CM_GROUP ON WORKDESK.CM_GROUP
(TK_GROUP)
LOGGING
TABLESPACE CM_INDEX
PCTFREE    10
INITRANS   2
MAXTRANS   255
STORAGE    (
            INITIAL          1M
            NEXT             1M
            MINEXTENTS       1
            MAXEXTENTS       UNLIMITED
            PCTINCREASE      0
            FREELISTS        1
            FREELIST GROUPS  1
            BUFFER_POOL      DEFAULT
           );

ALTER TABLE WORKDESK.CM_GROUP ADD (
  CONSTRAINT PK_CM_GROUP
  PRIMARY KEY
  (TK_GROUP)
  USING INDEX WORKDESK.PK_CM_GROUP
  ENABLE VALIDATE);


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.CM_GROUP TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.CM_GROUP TO PUBLIC;