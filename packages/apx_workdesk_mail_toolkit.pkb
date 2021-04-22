DROP PACKAGE BODY WORKDESK.APX_WORKDESK_MAIL_TOOLKIT;

CREATE OR REPLACE PACKAGE BODY WORKDESK.APX_WORKDESK_MAIL_TOOLKIT AS
PROCEDURE CHECK_SEND_WORKDESK_EMAILS 
IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'CHECK_SEND_WORKDESK_EMAILS';
    v_table             VARCHAR2(100)   := 'OW_MAIL';
    v_starttime         TIMESTAMP;
    v_message           CLOB;
    v_error             NUMBER := 0;
    v_prev_tk_ow        NUMBER := 0;
    v_prev_version_num  NUMBER := 0;
    CURSOR C_UNSENT_EMAILS IS
        SELECT TK_OW, VERSION_NUM, NOTIFICATION_TYPE, SUBJECT, NOTES, TK_EMPLOYEE_FROM
        FROM OW_MAIL
        WHERE IS_PROCESSED = 0     
        ORDER BY TK_OW, VERSION_NUM  
        FOR UPDATE SKIP LOCKED ;        
BEGIN
    --Logging Begin
    n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    FOR c_rec IN C_UNSENT_EMAILS
    LOOP
        IF (v_prev_tk_ow <> c_rec.tk_ow) THEN
            BUILD_WORKDESK_EMAILS(c_rec.tk_employee_from,c_rec.version_num,c_rec.tk_ow,c_rec.notification_type,c_rec.subject,c_rec.notes,v_error);
            
            IF v_error = 0 THEN        
                UPDATE OW_MAIL SET IS_PROCESSED = 1, PROCESSED_ON = sysdate 
                WHERE TK_OW = c_rec.tk_ow;      
            ELSE
                UPDATE OW_MAIL SET IS_PROCESSED = -1, PROCESSED_ON = sysdate 
                WHERE TK_OW = c_rec.tk_ow;                     
            END IF;
            v_error      := 0;
            v_prev_tk_ow := c_rec.tk_ow;
        END IF;      
    END LOOP;    
    apex_mail.push_queue;
    COMMIT;   

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(n_NEW_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);         
END CHECK_SEND_WORKDESK_EMAILS;

PROCEDURE BUILD_WORKDESK_EMAILS(p_tk_employee_from NUMBER,p_version_id NUMBER, p_tk_ow NUMBER, p_notification_type VARCHAR2, p_subject VARCHAR2, p_notes VARCHAR2, p_error OUT NUMBER)
IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'BUILD_WORKDESK_EMAILS';
    v_table             VARCHAR2(100)   := 'OW_MAIL';
    v_starttime         TIMESTAMP;
    v_inner_message     CLOB;
    v_message           CLOB;
    v_worksheets        CLOB;    
    v_mail              VARCHAR2(500);
    v_name              VARCHAR2(500); 
    mail_id             NUMBER := 0;  
    p_employee_to_name  VARCHAR2(500);
    p_employee_to_mail  VARCHAR2(500);
    v_notes             VARCHAR2(4000);
    v_mail_file_id      NUMBER;
    v_file_error        NUMBER;
    v_set_wrksht_num    VARCHAR2(100);
    v_database          VARCHAR2(100)   := NULL;
    v_testlistaddresses VARCHAR2(2000);
    v_published_by      VARCHAR2(2000);
    v_sent_on           VARCHAR2(2000);    
    v_contract_num      NUMBER;
    
    CURSOR C_WORKSHEETS_IN_CONTRACT IS
        SELECT ('Worksheet #'||wrk.SET_WRKSHT_NUM||', version '||wrk.VERSION_NUM) worksheet_desc
        FROM OW_CONTRACT cont, OW_CONTRACT_WORKSHEET con_wk, OW_WORKSHEET wrk
        WHERE cont.TEMPLATE_TK_OW = p_tk_ow
        AND cont.TK_CONTRACT = con_wk.TK_CONTRACT
        AND wrk.TK_OW = con_wk.TK_OW
        ORDER BY wrk.SET_WRKSHT_NUM asc;       
BEGIN
    --Logging Begin
    n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    --Get Publisher Name
    SELECT full_name
    into v_published_by
    FROM A_EMPLOYEE
    WHERE TK_EMPLOYEE = p_tk_employee_from;

    --Sent on
    SELECT 'Message sent on '||TRIM(INITCAP(to_char(sysdate,'DAY')))||', '||TRIM(INITCAP(to_char(sysdate,'MONTH')))||to_char(sysdate,'dd')||', '||to_char(sysdate,'YYYY')||' at '||to_char(sysdate,'HH:MI:SS AM')
    into v_sent_on
    FROM DUAL;    
    
    --Get SET_WRKSHT_NUM 
    SELECT to_char(SET_WRKSHT_NUM)
    into v_set_wrksht_num
    FROM OW_WORKSHEET
    WHERE TK_OW = p_tk_ow;    
    
    --If its a contract, get CONTRACT NUMBER
    IF p_notification_type = 'CONTRACT' THEN
        SELECT TK_CONTRACT
        into v_contract_num
        FROM OW_CONTRACT
        WHERE TEMPLATE_TK_OW = p_tk_ow;        
    END IF;
    
    --Get Database
    SELECT NAME INTO V_DATABASE FROM V$DATABASE;
    
    --Get template
    SELECT HTML_CODE
    into v_message
    FROM workdesk.OW_MAIL_TEMPLATE
    WHERE TEMPLATE_ID = 'WORKDESK_TRANSFER';
       
    --Get test mails
    v_testlistaddresses := oms.get_setting_variables ('DEFAULT.Workdesk.PublishSendEmail.TestListAddresses');
    --Get Email data
    SELECT listagg(lower(emp1.email),',') within group(order by emp1.email) csv  
    into p_employee_to_mail
    --FROM OW_MAIL MAIL, A_EMPLOYEE emp1 /*Workaround for Sales Email, developing LDAP updates*/
    FROM OW_MAIL MAIL,(select decode(upper(email),'CAESALES@AJCFOOD.COM','CAESALES@AJC.LOCAL',email) EMAIL,tk_employee from A_EMPLOYEE) EMP1 
    where tk_ow               = p_tk_ow
    and version_num           = p_version_id
    and mail.tk_employee_to = emp1.tk_employee
    and upper(emp1.email) <> 'ORDERENTRY@AJCFOOD.COM';
    
    SELECT DISTINCT(mail_file_id)
    into v_mail_file_id
    FROM OW_MAIL MAIL
    where tk_ow               = p_tk_ow
    and version_num           = p_version_id;   
        
    CASE p_notification_type
        WHEN 'CONTRACT' THEN
            FOR c_rec IN C_WORKSHEETS_IN_CONTRACT 
            LOOP
                v_worksheets := v_worksheets || c_rec.worksheet_desc ||'<br>';
            END LOOP;
            v_inner_message := 'Hello,<br><br>'||
                               v_published_by ||' has published Contract #'||v_contract_num||' and has specified you as a recipient.<br>'||
                               '%CUSTOM_NOTES%'||
                               '<br>This contract contains the following worksheets:<br><br>'||
                               v_worksheets||'<br>'||                                
                               'THIS IS AN AUTOMATIC NOTIFICATION. DO NOT REPLY.<br><br>'
                               --||v_sent_on
                               ;             
        WHEN 'WORKSHEET' THEN
            v_inner_message := 'Hello,<br><br>'||
                                v_published_by ||' has published Worksheet #'||v_set_wrksht_num||' and has specified you as a recipient.<br>'||
                                '%CUSTOM_NOTES%'||
                                '<br>THIS IS AN AUTOMATIC NOTIFICATION. DO NOT REPLY.<br><br>';            
    END CASE;
    if p_notes is not null then v_notes := '<br>'||p_notes||'<br>';end if;
    v_message := REPLACE(v_message,'%MESSAGE%',v_inner_message);
    v_message := REPLACE(v_message,'%CUSTOM_NOTES%',nvl(v_notes,''));
    
    --Email send
    IF (v_database <> 'PROD') THEN        
    -- ::::::::::::::DEVELOPMENT / QA EMAIL TEST SEND ::::::::::::::
        SELECT (CASE v_database WHEN 'FINUPG1' THEN 'QA' WHEN 'FINUPG2' THEN 'DEV' ELSE v_database END) into v_database FROM DUAL;
                
        mail_id := APEX_MAIL.SEND(
                            p_to        => v_testlistaddresses,
                            p_from      => 'orderworkdesk@ajc.bz',
                            p_subj      => NVL(p_subject,'Worksheet '|| initcap(p_notification_type)||' #' || p_tk_ow || ' ver '||p_version_id||' Published')|| ' - WORKDESK ' || v_database,
                            p_body      => v_message,
                            p_body_html => v_message
                            ); 
    ELSE
        -- ::::::::::::::PROD EMAIL SEND ::::::::::::::
        mail_id := APEX_MAIL.SEND(
                            p_to        => 'orderentry@ajcfood.com',
                            p_cc        => p_employee_to_mail,
                            p_from      => 'orderworkdesk@ajc.bz',
                            p_bcc       => v_TestListAddresses,
                            p_subj      => NVL(p_subject,'Worksheet '|| initcap(p_notification_type)||' #' || p_tk_ow || ' ver '||p_version_id||' Published'),
                            p_body      => v_message,
                            p_body_html => v_message
                            );        
    END IF;                        
                        
    /*Email File Attach*/
    ATTACH_FILES(mail_id, v_mail_file_id, v_file_error, n_NEW_EXECUTION_ID);
    p_error := v_file_error;                             
EXCEPTION
    WHEN OTHERS THEN
        p_error := 1;    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(n_NEW_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);         
END BUILD_WORKDESK_EMAILS;


PROCEDURE ATTACH_FILES(p_mail_id NUMBER, p_file_id NUMBER,p_error OUT NUMBER, pEXECUTION_ID IN NUMBER default -1)
AS      
    v_starttime_proc    TIMESTAMP;
    v_proc              VARCHAR2(100)   := 'ATTACH_FILES';
    v_table             VARCHAR2(100)   := NULL;
    
    CURSOR C_FILES_TO_ATTACH IS    
        SELECT OUTPUT_BLOB,FILENAME,MIME_TYPE 
        FROM OW_MAIL_FILE
        WHERE MAIL_FILE_ID = p_file_id;   
BEGIN
    v_starttime_proc := CURRENT_TIMESTAMP;        
  
    FOR reg_files IN C_FILES_TO_ATTACH
    LOOP
        APEX_MAIL.ADD_ATTACHMENT(
                    p_mail_id    => p_mail_id,
                    p_attachment => reg_files.OUTPUT_BLOB,
                    p_filename   => reg_files.FILENAME,
                    p_mime_type  => reg_files.MIME_TYPE);
    END LOOP;
    p_error := 0; 
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        p_error := 1;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM , SQLCODE ,v_starttime_proc,CURRENT_TIMESTAMP, null, null);        
END ATTACH_FILES;
END APX_WORKDESK_MAIL_TOOLKIT;
/


GRANT EXECUTE ON WORKDESK.APX_WORKDESK_MAIL_TOOLKIT TO OMS;
