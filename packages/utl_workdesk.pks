DROP PACKAGE WORKDESK.UTL_WORKDESK;

CREATE OR REPLACE PACKAGE WORKDESK."UTL_WORKDESK" 
is
PROCEDURE needs_margin_approval
(
  worksheet_id        IN number,
  profit              IN number, 
  exchange_rate       IN number,
  weight              IN number,
  uom                 IN varchar2,
  gp_margin           IN number, 
  sales_trader_id     IN number,
  needs_approval      OUT varchar2,
  reason_for_approval OUT varchar2
);
PROCEDURE email_managers
(
  worksheet_id        IN number,
  email               OUT varchar2
);
PROCEDURE UTL_OW_TEMPLATE_COPY_BY_USER
(
  p_owner              IN numeric,
  p_new_owner          IN numeric,
  p_Fec_Des            IN DATE,
  p_Fec_Has             IN DATE
);
FUNCTION FORMAT_NUMBER(P_NUMBER IN NUMBER) RETURN VARCHAR2;
end;
/


GRANT EXECUTE ON WORKDESK.UTL_WORKDESK TO OMS;

GRANT EXECUTE ON WORKDESK.UTL_WORKDESK TO PUBLIC;
