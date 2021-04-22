DROP TABLE WORKDESK.OW_SO_TRADER_EXCLUSIONS CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_SO_TRADER_EXCLUSIONS
(
  TK_EMP_TRADER  NUMBER(15)
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


GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_SO_TRADER_EXCLUSIONS TO OMS;