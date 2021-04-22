DROP TABLE WORKDESK.CM_DOC_PARTY CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.CM_DOC_PARTY
(
  TK_DOC_PARTY      NUMBER(7)                   NOT NULL,
  CUST_ACCT_ID      NUMBER(15)                  NOT NULL,
  DEST_TK_CNTRY     NUMBER(5),
  PARTY_ROLE        VARCHAR2(32 BYTE)           NOT NULL,
  NAME              VARCHAR2(100 BYTE)          NOT NULL,
  ATTN_TO           VARCHAR2(100 BYTE),
  ADDRESS_LINE1     VARCHAR2(100 BYTE),
  ADDRESS_LINE2     VARCHAR2(100 BYTE),
  ADDRESS_LINE3     VARCHAR2(100 BYTE),
  ADDRESS_LINE4     VARCHAR2(100 BYTE),
  CITY              VARCHAR2(25 BYTE),
  STATE             VARCHAR2(25 BYTE),
  POSTAL_CODE       VARCHAR2(25 BYTE),
  PROVINCE          VARCHAR2(25 BYTE),
  COUNTRY           VARCHAR2(25 BYTE),
  AREA_CODE         VARCHAR2(10 BYTE),
  PHONE             VARCHAR2(15 BYTE),
  FAX_AREA_CODE     VARCHAR2(10 BYTE),
  FAX               VARCHAR2(15 BYTE),
  EMAIL             VARCHAR2(40 BYTE),
  INACTIVE_ON       DATE,
  LAST_UPDATE_DATE  DATE,
  LAST_UPDATED_BY   NUMBER,
  CREATION_DATE     DATE                        NOT NULL,
  CREATED_BY        NUMBER                      NOT NULL
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

COMMENT ON TABLE WORKDESK.CM_DOC_PARTY IS 'This table contains doc parties for all customers.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.TK_DOC_PARTY IS 'The unique id of the doc party.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.CUST_ACCT_ID IS 'The customer with which this doc party is associated.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.DEST_TK_CNTRY IS 'The destination country for which this doc party is designated.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.PARTY_ROLE IS 'The role the doc party.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.NAME IS 'The name the doc party.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.ADDRESS_LINE3 IS 'The third address line of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.ADDRESS_LINE4 IS 'The fourth address line of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.CITY IS 'The city of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.STATE IS 'The state of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.POSTAL_CODE IS 'The postal code of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.PROVINCE IS 'The province of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.COUNTRY IS 'The country of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.PHONE IS 'The phone number of the doc party address.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.EMAIL IS 'The email address of the doc party.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.INACTIVE_ON IS 'The date on which this doc party was inactivated.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.LAST_UPDATE_DATE IS 'Date when record was last updated.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.LAST_UPDATED_BY IS 'User id of the person that last updated the record.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.CREATION_DATE IS 'Date when record was created.';

COMMENT ON COLUMN WORKDESK.CM_DOC_PARTY.CREATED_BY IS 'User id   of the person that created the record.';


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.CM_DOC_PARTY TO OMS;
