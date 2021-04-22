DROP TABLE WORKDESK.OW_WS_TRANSFER CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_TRANSFER
(
  TK_EMP_TRANSFER_TO  NUMBER(15)                NOT NULL,
  CREATION_DATE       DATE                      NOT NULL,
  CREATED_BY          NUMBER(15)                NOT NULL,
  LAST_UPDATE_DATE    DATE,
  LAST_UPDATED_BY     NUMBER(15),
  TK_TRANSFER         NUMBER(15)                NOT NULL,
  EDITED              VARCHAR2(1 BYTE)          DEFAULT 'N'                   NOT NULL,
  TK_OW               NUMBER(7)                 NOT NULL,
  INIT_TK_OW          NUMBER(7)                 NOT NULL,
  STATUS              VARCHAR2(30 BYTE)         NOT NULL
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

COMMENT ON TABLE WORKDESK.OW_WS_TRANSFER IS 'This table includes the worksheet numbers that have been transferred from one user to another in Order Workdesk.';

COMMENT ON COLUMN WORKDESK.OW_WS_TRANSFER.TK_EMP_TRANSFER_TO IS 'User id   of the person that the worksheet was transferred to';

COMMENT ON COLUMN WORKDESK.OW_WS_TRANSFER.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.OW_WS_TRANSFER.CREATED_BY IS 'User id   of the person that created the record.';

COMMENT ON COLUMN WORKDESK.OW_WS_TRANSFER.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.OW_WS_TRANSFER.LAST_UPDATED_BY IS 'User id    of the person that last updated the record.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_TRANSFER ON WORKDESK.OW_WS_TRANSFER
(TK_TRANSFER)
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

ALTER TABLE WORKDESK.OW_WS_TRANSFER ADD (
  CONSTRAINT PK_OW_WS_TRANSFER
  PRIMARY KEY
  (TK_TRANSFER)
  USING INDEX WORKDESK.PK_OW_WS_TRANSFER
  ENABLE VALIDATE);


CREATE INDEX WORKDESK.I_OW_WS_TRANSFER_INIT_TK_OW ON WORKDESK.OW_WS_TRANSFER
(INIT_TK_OW)
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

CREATE INDEX WORKDESK.I_OW_WS_TRANSFER_TK_OW ON WORKDESK.OW_WS_TRANSFER
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

CREATE OR REPLACE PUBLIC SYNONYM OW_WS_TRANSFER FOR WORKDESK.OW_WS_TRANSFER;


ALTER TABLE WORKDESK.OW_WS_TRANSFER ADD (
  CONSTRAINT FK_OW_WS_TRANSFER_STATUS 
  FOREIGN KEY (STATUS) 
  REFERENCES WORKDESK.OW_TRANSFER_STATUS (STATUS)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_TRANSFER TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_TRANSFER TO PUBLIC;
