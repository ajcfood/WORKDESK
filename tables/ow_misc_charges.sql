DROP TABLE WORKDESK.OW_MISC_CHARGES CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_MISC_CHARGES
(
  MISC_CHARGE_ID    NUMBER,
  TK_OW             NUMBER(7)                   NOT NULL,
  LINE_NUM          NUMBER(5),
  CHARGES           VARCHAR2(2000 BYTE),
  TK_CHG_TYPE       NUMBER,
  COST              NUMBER(13,2),
  CURRENCY          VARCHAR2(10 BYTE),
  PER               VARCHAR2(10 BYTE),
  TOTAL             NUMBER,
  CREATED_DATE      DATE,
  CREATED_BY        VARCHAR2(30 BYTE),
  LAST_UPDATE_DATE  DATE,
  LAST_UPDATE_BY    VARCHAR2(30 BYTE)
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


CREATE UNIQUE INDEX WORKDESK.OW_MISC_CHARGES_PK ON WORKDESK.OW_MISC_CHARGES
(MISC_CHARGE_ID)
LOGGING
TABLESPACE WORKDESK_DATA
PCTFREE    10
INITRANS   2
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
           );

ALTER TABLE WORKDESK.OW_MISC_CHARGES ADD (
  CONSTRAINT OW_MISC_CHARGES_PK
  PRIMARY KEY
  (MISC_CHARGE_ID)
  USING INDEX WORKDESK.OW_MISC_CHARGES_PK
  ENABLE VALIDATE);


CREATE INDEX WORKDESK.IDX_TK_OW_MISC_CHARGES ON WORKDESK.OW_MISC_CHARGES
(TK_OW)
LOGGING
TABLESPACE WORKDESK_DATA
PCTFREE    10
INITRANS   2
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
           );

DROP SEQUENCE WORKDESK.OW_MISC_CHARGES_SEQ;

CREATE SEQUENCE WORKDESK.OW_MISC_CHARGES_SEQ
  START WITH 197
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER
  NOKEEP
  GLOBAL;


CREATE OR REPLACE TRIGGER WORKDESK.OW_MISC_CHARGES_TR_BIU BEFORE INSERT or UPDATE
 ON WORKDESK.OW_MISC_CHARGES  
   FOR EACH ROW
DECLARE  
    V_USER VARCHAR2(30) := NVL(v('APP_USER'),USER);
    V_DATE DATE := SYSDATE;
BEGIN
    IF INSERTING THEN
        IF :NEW.MISC_CHARGE_ID IS NULL THEN
            :NEW.MISC_CHARGE_ID := OW_MISC_CHARGES_SEQ.NEXTVAL;
        END IF;
        :NEW.CREATED_DATE := V_DATE;
        :NEW.CREATED_BY := V_USER;
    ELSE
        :NEW.LAST_UPDATE_DATE := V_DATE;
        :NEW.LAST_UPDATE_BY := V_USER;
    END IF;
END;
/


ALTER TABLE WORKDESK.OW_MISC_CHARGES ADD (
  CONSTRAINT OW_MISC_CHARGES_R01 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET (TK_OW)
  ON DELETE CASCADE
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_MISC_CHARGES TO OMS;
