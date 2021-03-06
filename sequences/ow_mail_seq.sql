DROP SEQUENCE WORKDESK.OW_MAIL_SEQ;

CREATE SEQUENCE WORKDESK.OW_MAIL_SEQ
  START WITH 1106
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  NOCACHE
  NOORDER
  NOKEEP
  GLOBAL;


GRANT ALTER, SELECT ON WORKDESK.OW_MAIL_SEQ TO ATISPROD;

GRANT ALTER, SELECT ON WORKDESK.OW_MAIL_SEQ TO OMS;
