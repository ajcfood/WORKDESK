DROP SEQUENCE WORKDESK.SEQ_OW_TK_CONTRACT_TRANSFER;

CREATE SEQUENCE WORKDESK.SEQ_OW_TK_CONTRACT_TRANSFER
  START WITH 130
  MAXVALUE 999999999999999999999999999
  MINVALUE 1
  NOCYCLE
  CACHE 20
  NOORDER
  NOKEEP
  GLOBAL;


CREATE OR REPLACE PUBLIC SYNONYM SEQ_OW_TK_CONTRACT_TRANSFER FOR WORKDESK.SEQ_OW_TK_CONTRACT_TRANSFER;


GRANT SELECT ON WORKDESK.SEQ_OW_TK_CONTRACT_TRANSFER TO PUBLIC;