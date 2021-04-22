DROP SEQUENCE WORKDESK.SEQ_OW_TK;

CREATE SEQUENCE WORKDESK.SEQ_OW_TK
  START WITH 2130534
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
  NOKEEP
  GLOBAL;


CREATE OR REPLACE PUBLIC SYNONYM SEQ_OW_TK FOR WORKDESK.SEQ_OW_TK;


GRANT SELECT ON WORKDESK.SEQ_OW_TK TO PUBLIC WITH GRANT OPTION;
