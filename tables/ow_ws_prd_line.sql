DROP TABLE WORKDESK.OW_WS_PRD_LINE CASCADE CONSTRAINTS;

CREATE TABLE WORKDESK.OW_WS_PRD_LINE
(
  TK_OW           NUMBER(7)                     NOT NULL,
  LINE_NUM        NUMBER(5)                     NOT NULL,
  CASES           NUMBER(9),
  WEIGHT          NUMBER(12,4),
  WT_UOM          VARCHAR2(6 BYTE),
  SELL_DESCR      VARCHAR2(255 BYTE),
  PUR_DESCR       VARCHAR2(255 BYTE),
  PROPRIETARY     VARCHAR2(1 BYTE),
  TK_SUP_OFFERLN  NUMBER(15),
  WEIGHT_LBS      NUMBER(20)
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

COMMENT ON TABLE WORKDESK.OW_WS_PRD_LINE IS 'This table includes all product lines for Worksheets/Templates created through Order Workdesk.';

COMMENT ON COLUMN WORKDESK.OW_WS_PRD_LINE.TK_OW IS 'This is the id for the Worksheet/Template.';

COMMENT ON COLUMN WORKDESK.OW_WS_PRD_LINE.LINE_NUM IS 'This is the worksheet line number.';


CREATE UNIQUE INDEX WORKDESK.PK_OW_WS_PRD_LINE ON WORKDESK.OW_WS_PRD_LINE
(TK_OW, LINE_NUM)
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

ALTER TABLE WORKDESK.OW_WS_PRD_LINE ADD (
  CONSTRAINT PK_OW_WS_PRD_LINE
  PRIMARY KEY
  (TK_OW, LINE_NUM)
  USING INDEX WORKDESK.PK_OW_WS_PRD_LINE
  ENABLE VALIDATE);


CREATE OR REPLACE TRIGGER WORKDESK."TRG_BIU_OW_WS_PRD_LINE"
before insert or update  ON WORKDESK.OW_WS_PRD_LINE
for each row
declare
v_multiplier number;

begin


begin 
        select multiplier
        into v_multiplier
        from measure_conversion conv 
        where  :new.wt_uom = conv.from_uom 
        and to_uom = 'LB';
exception
 when no_data_found then
     v_multiplier:=1;
end;

if :NEW.WEIGHT is not null then

:NEW.WEIGHT_LBS:=  :NEW.WEIGHT * v_multiplier;--:NEW.MULTIPLIER;
end if;
end;
/


CREATE OR REPLACE PUBLIC SYNONYM OW_WS_PRD_LINE FOR WORKDESK.OW_WS_PRD_LINE;


ALTER TABLE WORKDESK.OW_WS_PRD_LINE ADD (
  CONSTRAINT FK_OW_WS_PRD_LINE_WORKSHEET 
  FOREIGN KEY (TK_OW) 
  REFERENCES WORKDESK.OW_WORKSHEET (TK_OW)
  ENABLE VALIDATE);

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_PRD_LINE TO OMS;

GRANT DELETE, INSERT, SELECT, UPDATE ON WORKDESK.OW_WS_PRD_LINE TO PUBLIC;
