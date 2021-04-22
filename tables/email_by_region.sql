DROP TABLE WORKDESK.EMAIL_BY_REGION CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.EMAIL_BY_REGION
(
  RGN_ID   VARCHAR2(4 BYTE),
  M_EMAIL  VARCHAR2(500 BYTE)
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


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.EMAIL_BY_REGION TO OMS;