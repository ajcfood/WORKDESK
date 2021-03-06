DROP TABLE WORKDESK.OW_MAIL CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_MAIL
(
  MAIL_ID            NUMBER(15)                 DEFAULT "WORKDESK"."OW_MAIL_SEQ"."NEXTVAL" NOT NULL,
  TK_EMPLOYEE_FROM   NUMBER(15)                 NOT NULL,
  TK_EMPLOYEE_TO     NUMBER(15)                 NOT NULL,
  TK_OW              NUMBER(15)                 NOT NULL,
  NOTIFICATION_TYPE  VARCHAR2(32 BYTE)          NOT NULL,
  MAIL_FILE_ID       NUMBER(15)                 NOT NULL,
  IS_PROCESSED       NUMBER(1)                  NOT NULL,
  PROCESSED_ON       DATE,
  SUBJECT            VARCHAR2(1000 BYTE),
  NOTES              VARCHAR2(4000 BYTE),
  CREATED_DATE       DATE                       NOT NULL,
  CREATED_BY         VARCHAR2(30 BYTE)          NOT NULL,
  VERSION_NUM        NUMBER
)
TABLESPACE WORKDESK_DATA
PCTUSED    40
PCTFREE    10
INITRANS   1
MAXTRANS   255
STORAGE    (
            INITIAL          40K
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


GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, READ, DEBUG, FLASHBACK ON WORKDESK.OW_MAIL TO ATISPROD;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, READ, DEBUG, FLASHBACK ON WORKDESK.OW_MAIL TO OMS;
