DROP TABLE WORKDESK.OW_DOCUMENT CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_DOCUMENT
(
  DOCUMENT_ID       VARCHAR2(30 BYTE)           NOT NULL,
  TYPE              VARCHAR2(56 BYTE)           NOT NULL,
  DESCR             VARCHAR2(256 BYTE)          NOT NULL,
  FILE_NAME         VARCHAR2(256 BYTE)          NOT NULL,
  TITLE             VARCHAR2(256 BYTE)          NOT NULL,
  ACTIVE            VARCHAR2(1 BYTE)            NOT NULL,
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


CREATE UNIQUE INDEX WORKDESK.PK_OW_DOCUMENT ON WORKDESK.OW_DOCUMENT
(DOCUMENT_ID)
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

ALTER TABLE WORKDESK.OW_DOCUMENT ADD (
  CONSTRAINT PK_OW_DOCUMENT
  PRIMARY KEY
  (DOCUMENT_ID)
  USING INDEX WORKDESK.PK_OW_DOCUMENT
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_DOCUMENT FOR WORKDESK.OW_DOCUMENT;


ALTER TABLE WORKDESK.OW_DOCUMENT ADD (
  CONSTRAINT FK_OW_TYPE_DOCUMENT 
  FOREIGN KEY (TYPE) 
  REFERENCES WORKDESK.OW_DOCUMENT_TYPE (TYPE)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_DOCUMENT TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_DOCUMENT TO PUBLIC;
