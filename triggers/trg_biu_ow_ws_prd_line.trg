DROP TRIGGER WORKDESK.TRG_BIU_OW_WS_PRD_LINE;

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
