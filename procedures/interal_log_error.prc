DROP PROCEDURE WORKDESK.INTERAL_LOG_ERROR;

CREATE OR REPLACE PROCEDURE WORKDESK.interal_log_error
  (
    p_text in varchar2,
    p_date in date ,
    p_number in number default null,
    p_user in varchar2 default null
    )
IS
  pragma autonomous_transaction;

  l_nextval number;
BEGIN
    select interal_log_error_seq.nextval
    into l_nextval
    from dual;

   INSERT
     INTO TEST_INTERAL_LOG_ERROR
    (
      id_log,
      text_log,
      date_log,
      number_log,
      user_log
    )
    VALUES
    (
      l_nextval,
      p_text,
      p_date,
      p_number,
      p_user
    );
  COMMIT;

EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000, 'ERROR interal_log_error - '||SQLERRM);
END;
/


GRANT EXECUTE ON WORKDESK.INTERAL_LOG_ERROR TO OMS;
