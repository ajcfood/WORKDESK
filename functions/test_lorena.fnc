DROP FUNCTION WORKDESK.TEST_LORENA;

CREATE OR REPLACE FUNCTION WORKDESK.TEST_LORENA (P_SET_WRKSHT_NUM IN NUMBER,
                                                 P_TYPE IN VARCHAR2)

RETURN VARCHAR2 IS
tmpVar NUMBER;

BEGIN

    IF P_TYPE = 'PEPITO' THEN
    
    SELECT 1 
    Into tmpVar
    from dual;
    
    RETURN 'HOLA QUE TAL';
    
    END IF;
    
   EXCEPTION
     WHEN OTHERS THEN
     dbms_output.put_line ('ERROR!!!!!!!!!!!!! ' || sqlerrm);   
END TEST_LORENA; 
/
