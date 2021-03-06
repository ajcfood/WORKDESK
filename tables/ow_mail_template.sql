DROP TABLE WORKDESK.OW_MAIL_TEMPLATE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_MAIL_TEMPLATE
(
  MAIL_TEMPLATE_ID  NUMBER,
  TEMPLATE_ID       VARCHAR2(50 BYTE),
  HTML_CODE         CLOB
)
LOB (HTML_CODE) STORE AS BASICFILE (
  TABLESPACE  WORKDESK_DATA
  ENABLE      STORAGE IN ROW
  CHUNK       8192
  RETENTION
  NOCACHE
  LOGGING
      STORAGE    (
                  INITIAL          40K
                  NEXT             40K
                  MINEXTENTS       1
                  MAXEXTENTS       UNLIMITED
                  PCTINCREASE      0
                  FREELISTS        1
                  FREELIST GROUPS  1
                  BUFFER_POOL      DEFAULT
                 ))
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


GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, READ, DEBUG, FLASHBACK ON WORKDESK.OW_MAIL_TEMPLATE TO ATISPROD;

GRANT ALTER, DELETE, INDEX, INSERT, REFERENCES, SELECT, UPDATE, ON COMMIT REFRESH, QUERY REWRITE, READ, DEBUG, FLASHBACK ON WORKDESK.OW_MAIL_TEMPLATE TO OMS;
