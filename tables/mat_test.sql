DROP TABLE WORKDESK.MAT_TEST CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.MAT_TEST
(
  LALA  VARCHAR2(100 BYTE)
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


GRANT INSERT ON WORKDESK.MAT_TEST TO ATISPROD;

GRANT INSERT ON WORKDESK.MAT_TEST TO OMS;