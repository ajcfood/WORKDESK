DROP TABLE WORKDESK.OW_DOCUMENT_FIELD CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_DOCUMENT_FIELD
(
  DOCUMENT_ID       VARCHAR2(30 BYTE)           NOT NULL,
  FIELD_ID          VARCHAR2(30 BYTE)           NOT NULL,
  CASE              VARCHAR2(30 BYTE)           NOT NULL,
  CREATION_DATE     DATE                        NOT NULL,
  CREATED_BY        NUMBER(15)                  NOT NULL,
  LAST_UPDATE_DATE  DATE,
  LAST_UPDATED_BY   NUMBER(15),
  FIELD_TYPE        VARCHAR2(30 BYTE)           DEFAULT 'TEXT'
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


CREATE UNIQUE INDEX WORKDESK.PK_OW_DOCUMENT_FIELD ON WORKDESK.OW_DOCUMENT_FIELD
(DOCUMENT_ID, FIELD_ID)
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

ALTER TABLE WORKDESK.OW_DOCUMENT_FIELD ADD (
  CONSTRAINT PK_OW_DOCUMENT_FIELD
  PRIMARY KEY
  (DOCUMENT_ID, FIELD_ID)
  USING INDEX WORKDESK.PK_OW_DOCUMENT_FIELD
  ENABLE VALIDATE);


CREATE OR REPLACE PUBLIC SYNONYM OW_DOCUMENT_FIELD FOR WORKDESK.OW_DOCUMENT_FIELD;


ALTER TABLE WORKDESK.OW_DOCUMENT_FIELD ADD (
  CONSTRAINT FK_OW_DOCUMENT 
  FOREIGN KEY (DOCUMENT_ID) 
  REFERENCES WORKDESK.OW_DOCUMENT (DOCUMENT_ID)
  ENABLE VALIDATE
,  CONSTRAINT FK_OW_DOCUMENT_FIELD 
  FOREIGN KEY (FIELD_ID) 
  REFERENCES WORKDESK.OW_FIELD (FIELD_ID)
  ENABLE VALIDATE
,  CONSTRAINT FK_OW_DOC_FIELD_CASE 
  FOREIGN KEY (CASE) 
  REFERENCES WORKDESK.OW_FIELD_CASE (CASE)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_DOCUMENT_FIELD TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_DOCUMENT_FIELD TO PUBLIC;