DROP PACKAGE BODY WORKDESK.APX_WOKDSK_PO_TOOLKIT;

CREATE OR REPLACE PACKAGE BODY WORKDESK.APX_WOKDSK_PO_TOOLKIT AS 
FUNCTION IS_CURRENT_PO(
p_TK_PO             NUMBER,
p_VERS_NUM          NUMBER
)RETURN VARCHAR2
IS
   v_max_vers   NUMBER; 
BEGIN
    SELECT MAX(version_num)
    into v_max_vers
    FROM WORKDESK.OW_WORKSHEET_pub
    WHERE set_wrksht_num = p_TK_PO;
    
    IF v_max_vers = p_VERS_NUM THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;
EXCEPTION WHEN OTHERS THEN RETURN 'N';    
END IS_CURRENT_PO;
FUNCTION PO_WAS_PUBLISHED(
p_SET_WRKSHT_NUM NUMBER
)RETURN BOOLEAN
IS
    v_publishes NUMBER;
BEGIN
    select COUNT(1)
    into v_publishes
    from WORKDESK.OW_WORKSHEET_PUB ws
    where set_wrksht_num = p_SET_WRKSHT_NUM;
    IF v_publishes = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION WHEN OTHERS THEN RETURN FALSE;
END PO_WAS_PUBLISHED;
PROCEDURE SAVE_PO(
p_TK_OW                  NUMBER,
p_NEW_TK                 NUMBER,
p_LAST_UPDATED_BY        NUMBER,
p_TYPE                   VARCHAR2,   
p_DESCRIPTION            IN OUT VARCHAR2,  
p_VERSION_NUM            NUMBER,           
p_STATUS                 VARCHAR2,   
p_DEST_TK_CNTRY          NUMBER,
p_INSP_TK_CNTRY          NUMBER,
p_PLANT                  VARCHAR2,
p_CO_TK_ORG              NUMBER,
p_CURRENCY_CODE          IN OUT VARCHAR2,   
p_WT_UOM                 VARCHAR2,                  
p_CREATED_BY             NUMBER,                     
p_OWNER                  NUMBER,
p_DEST_PORT              NUMBER,
p_NOTIFY_SUBJECT         VARCHAR2,
p_ODS                    VARCHAR2,   
p_POSITION_PURCHASE      VARCHAR2,    
p_PURCHASE_DECISION      VARCHAR2,  
p_PROVINCE               IN OUT NUMBER, 
p_NOTE_SUPPLIER          VARCHAR2,
p_NOTE_INTERNAL          VARCHAR2,
p_BANK_DESCR             VARCHAR2,
p_EXCHANGE_RATE          NUMBER,
p_EXCHANGE_AMOUNT        NUMBER,
p_CONTRACT_NUMBER        VARCHAR2,
p_VALUATION_DATE         DATE,
p_LINE_NUM               NUMBER,        
p_PUR_PRICE_CASE         NUMBER,
p_PUR_PRICE_WT           NUMBER,
p_PUR_PRICE_UOM          VARCHAR2,
p_VENDOR_ID              NUMBER,
p_INCOTERM               VARCHAR2,
p_SHIP_DATE              VARCHAR2,     
p_SUPPLIER_REF           VARCHAR2,
p_PURCHASE_DATE          DATE,
p_DISCOUNT               NUMBER,
p_PURCHASE_PAYMENT_TERMS VARCHAR2,
p_LOGISTICS_COORDINATOR  NUMBER,
p_PURCHASER              NUMBER,
p_SET_WRKSHT_NUM         IN OUT NUMBER,
P_NEW_TK_OW              OUT NUMBER,
P_ORIGIN_COUNTRY         NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID         IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'SAVE_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_working_TK        NUMBER;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    --Checking if its a new Draft or an existing one to call insert or update
    
    

    IF p_TK_OW IS NULL THEN
    
        
        
        WORKDESK.APX_WOKDSK_PO_DML.OW_WORKSHEET_INSERT
        (
         p_NEW_TK
        ,p_TYPE              
        ,p_DESCRIPTION       
        ,p_VERSION_NUM       
        ,p_STATUS            
        ,p_DEST_TK_CNTRY     
        ,p_INSP_TK_CNTRY     
        ,p_PLANT             
        ,p_CO_TK_ORG         
        ,p_CURRENCY_CODE     
        ,p_WT_UOM                   
        ,p_CREATED_BY                
        ,p_OWNER             
        ,p_DEST_PORT         
        ,p_NOTIFY_SUBJECT    
        ,p_ODS               
        ,p_POSITION_PURCHASE 
        ,p_PURCHASE_DECISION 
        ,p_PROVINCE               
        ,p_NOTE_SUPPLIER
        ,p_NOTE_INTERNAL              
        ,p_BANK_DESCR        
        ,p_EXCHANGE_RATE     
        ,p_EXCHANGE_AMOUNT   
        ,p_CONTRACT_NUMBER   
        ,p_VALUATION_DATE    
        ,p_LINE_NUM          
        ,p_PUR_PRICE_CASE    
        ,p_PUR_PRICE_WT      
        ,p_PUR_PRICE_UOM  
        ,p_VENDOR_ID          
        ,p_INCOTERM           
        ,p_SHIP_DATE          
        ,p_SUPPLIER_REF       
        ,p_PURCHASE_DATE      
        ,p_DISCOUNT           
        ,p_PURCHASE_PAYMENT_TERMS  
        ,p_LOGISTICS_COORDINATOR   
        ,p_PURCHASER                          
        ,p_SET_WRKSHT_NUM  
        ,p_new_TK_OW  
        ,P_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID      
        );
    ELSE
        
        
        WORKDESK.APX_WOKDSK_PO_DML.OW_WORKSHEET_UPDATE
        (
         p_TK_OW            
        ,p_TYPE             
        ,p_DESCRIPTION      
        ,p_DEST_TK_CNTRY    
        ,p_INSP_TK_CNTRY    
        ,p_PLANT            
        ,p_CO_TK_ORG        
        ,p_CURRENCY_CODE    
        ,p_WT_UOM                  
        ,p_LAST_UPDATED_BY 
        ,p_DEST_PORT        
        ,p_NOTIFY_SUBJECT   
        ,p_ODS              
        ,p_POSITION_PURCHASE
        ,p_PURCHASE_DECISION
        ,p_PROVINCE                
        ,p_NOTE_SUPPLIER
        ,p_NOTE_INTERNAL            
        ,p_BANK_DESCR       
        ,p_EXCHANGE_RATE    
        ,p_EXCHANGE_AMOUNT  
        ,p_CONTRACT_NUMBER  
        ,p_VALUATION_DATE   
        ,p_VENDOR_ID               
        ,p_INCOTERM                
        ,p_SHIP_DATE               
        ,p_SUPPLIER_REF            
        ,p_PURCHASE_DATE           
        ,p_DISCOUNT                
        ,p_PURCHASE_PAYMENT_TERMS  
        ,p_LOGISTICS_COORDINATOR   
        ,p_PURCHASER
        ,P_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID
        );   
        p_new_TK_OW      := p_TK_OW;  
        
        SELECT SET_WRKSHT_NUM into p_SET_WRKSHT_NUM FROM OW_WORKSHEET WHERE TK_OW = p_TK_OW; 
        
    END IF;   
   
    COMMIT;      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END SAVE_PO;
PROCEDURE PUBLISH_PO(p_TK_OW NUMBER, p_LAST_UPDATED_BY NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'PUBLISH_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    UPDATE OW_WORKSHEET SET
         STATUS             = 'PUBLISHED'
        ,LAST_UPDATE_DATE   = SYSDATE
        ,LAST_UPDATED_BY    = p_LAST_UPDATED_BY
    WHERE TK_OW = p_TK_OW;
    
   
    
    --Insert Version in Publish Table
    APX_WOKDSK_PO_DML.OW_WORKSHEET_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);      
    APX_WOKDSK_PO_DML.OW_WS_NOTE_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_FOREX_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PUR_ORD_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_PRD_LINE_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_PRD_LINE_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);    
    
    --Insert OW Sale Ord DUMMY Record
    APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY_PUB(p_TK_OW, n_NEW_EXECUTION_ID);
    -------------------------
    APX_WOKDSK_PO_DML.OW_WS_NOTIFY_C_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_RECIP_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_MSC_CHRG_PUB_INSERT(p_TK_OW, n_NEW_EXECUTION_ID);
    
     COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END PUBLISH_PO;

PROCEDURE UNPUBLISH_PO(
    p_TK_OW             NUMBER, 
    p_LAST_UPDATED_BY   NUMBER,
    pEXECUTION_ID       IN NUMBER default -1
) AS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'UNPUBLISH_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_new_tk            NUMBER;
    v_old_tk            NUMBER;
    v_set_wrksht_num    NUMBER;
    v_version_num       NUMBER;
    v_notify_subject    VARCHAR2(100)   := NULL;
    v_notify_sub_old    VARCHAR2(100)   := NULL;
    v_notify_sub_new    VARCHAR2(100)   := NULL;

BEGIN
        
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
    into   v_new_tk 
    FROM DUAL;
    
    SELECT SET_WRKSHT_NUM,
           TK_OW,
           version_num
    INTO   v_set_wrksht_num,
           v_old_tk,
           v_version_num
    FROM   OW_WORKSHEET
    WHERE  TK_OW = p_TK_OW;
    
    GET_NOTIFY_SUBJECT_PO(p_TK_OW,v_notify_subject,v_notify_sub_new,v_notify_sub_old,pEXECUTION_ID);

    COPY_WORKSHEET_DATA(p_TK_OW => p_TK_OW, 
                        p_Type  => 'WORKSHEET',
                        p_NEW_TK_OW => v_new_tk,
                        p_NEW_WORKSHEET_NUM => v_set_wrksht_num, 
                        p_TK_EMPLOYEE => p_LAST_UPDATED_BY);

    IF v_notify_subject != v_notify_sub_old AND v_notify_sub_old IS NOT NULL THEN
      v_notify_sub_new := v_notify_sub_old;
    END IF;

    UPDATE OW_WORKSHEET 
    SET    version_num = v_version_num + 1,
           notify_subject = v_notify_sub_new
    WHERE  TK_OW = v_new_tk;
    
    --IF THE WORSHEET IS PART OF A CONTRACT WE HAVE TO UPDATE TK_OW WITH THE NEW ONE
    UPDATE OW_CONTRACT_WORKSHEET
       SET TK_OW = v_new_tk
     WHERE TK_OW = p_TK_OW;
     
    DELETE_PO(P_SET_WRKSHT_NUM => v_set_wrksht_num,
              p_LAST_UPDATED_BY => p_LAST_UPDATED_BY,
              pEXECUTION_ID => -1,
              p_TK_OW => v_old_tk);
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' ||CONST_PACKAGE_NAME);        
END UNPUBLISH_PO;

PROCEDURE DELETE_PO(
P_SET_WRKSHT_NUM    NUMBER,
p_LAST_UPDATED_BY   NUMBER,
pEXECUTION_ID       IN NUMBER default -1,
p_TK_OW             NUMBER DEFAULT NULL
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'DELETE_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    a_worksheet arrayofWorksheets;
    v_TK_OW     NUMBER;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    BEGIN
        SELECT TK_OW
        bulk collect into a_worksheet
        FROM OW_WORKSHEET
        WHERE SET_WRKSHT_NUM = P_SET_WRKSHT_NUM
        AND   TK_OW = NVL(p_TK_OW,TK_OW);    
    EXCEPTION WHEN NO_DATA_FOUND THEN
        a_worksheet := NULL;    
    END;
    
    IF p_TK_OW IS NULL THEN
      SELECT TK_OW
      into v_TK_OW
      FROM OW_WORKSHEET
      WHERE SET_WRKSHT_NUM = P_SET_WRKSHT_NUM;
    ELSE
      v_TK_OW := p_TK_OW;
    END IF;  
    
    --ow_sale_alloc
    DELETE ow_sale_alloc where tk_ow = p_TK_OW;
    
    --  ow_so_prd_line   
    DELETE  ow_so_prd_line where tk_ow = p_TK_OW;
    
    --Delete Notes
    APX_WOKDSK_PO_DML.OW_WS_NOTE_DELETE(v_TK_OW, n_NEW_EXECUTION_ID);
        
    --Delete Foreign Echange Information
    APX_WOKDSK_PO_DML.OW_WS_FOREX_DELETE(v_TK_OW, n_NEW_EXECUTION_ID);
    
    --Delete Products
    APX_WOKDSK_PO_DML.OW_PO_PRD_LINE_DELETE(v_TK_OW, n_NEW_EXECUTION_ID);
    
    --Delete Products Line
    DELETE OW_WS_PRD_LINE WHERE TK_OW = v_TK_OW;
    
    --Delete OW Sale Ord DUMMY Record
    APX_WOKDSK_PO_DML.OW_SALE_ORD_DELETE(v_TK_OW, n_NEW_EXECUTION_ID);
    
    --Delete Purchaser
    DELETE OW_PUR_ORD WHERE TK_OW = v_TK_OW;
    
    DELETE FROM WORKDESK.OW_PO_PRD_PLANTS WHERE TK_OW = v_TK_OW;
                 
    DELETE OW_MISC_CHARGES WHERE TK_OW MEMBER OF a_worksheet;
    
    APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_DELETE(a_worksheet);  
    
    APX_WOKDSK_PO_DML.OW_WS_NOTIFY_COMMENTS_DELETE(p_TK_OW);
    
    -- OW_EMPLOYEE_WS_LIST
    APX_WOKDSK_PO_DML.OW_EMPLOYEE_WS_LIST_DELETE(p_TK_OW);
                
    --OW_WS_ACCRUAL
    APX_WOKDSK_PO_DML.OW_WS_ACCRUAL_DELETE(p_TK_OW);
               
    --OW_WS_LC
    APX_WOKDSK_PO_DML.OW_WS_LC_DELETE(p_TK_OW);
        
    --Delete Worksheet
    APX_WOKDSK_PO_DML.OW_WORKSHEET_DELETE(v_TK_OW, n_NEW_EXECUTION_ID);
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        WORKDESK.interal_log_error('DEL 5',SYSDATE,SQLERRM);
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END DELETE_PO;


PROCEDURE GET_LAST_PUBLISHED_PO_DATA(
p_VENDOR_ID              NUMBER, 
p_TK_USER                NUMBER,
p_PURCHASER              OUT NUMBER, 
p_INCOTERM               OUT VARCHAR2, 
p_CO_TK_ORG              OUT NUMBER,
p_LOGISTICS_COORDINATOR  OUT NUMBER,
p_PURCHASE_PAYMENT_TERMS OUT VARCHAR2,
p_CURRENCY_CODE          OUT VARCHAR2,
p_ORIGIN_COUNTRY         OUT NUMBER,
p_DEST_PORT              OUT NUMBER,
pEXECUTION_ID            IN NUMBER default -1
) IS
	n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'GET_LAST_PUBLISHED_PO_DATA';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
BEGIN
	
	--Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
	IF P_VENDOR_ID IS NOT NULL THEN
	
        -- GET DEFAULT PURCHASER FOR THE SELECTED VENDOR_ID
        BEGIN
            SELECT DESCRIPTION
              into p_PURCHASE_PAYMENT_TERMS
              FROM PO_VENDORS V JOIN AP_TERMS_TL T ON V.TERMS_ID = T.TERM_ID
             WHERE VENDOR_ID = P_VENDOR_ID;
        EXCEPTION WHEN NO_DATA_FOUND THEN 
            p_PURCHASE_PAYMENT_TERMS := NULL;
        END;

        -- SELECT LAST PUBLISHED PO DATA
        BEGIN
            SELECT SUBT.TK_EMP_TRADER 
                  ,SUBT.PURCHASE_TERMS_DESCR 
                  ,SUBT.CO_TK_ORG 
                  ,SUBT.TK_EMP_TRF
                  ,SUBT.CURRENCY_CODE
                  ,SUBT.ORIG_TK_CNTRY
                  ,SUBT.DEST_PORT
             into p_PURCHASER            
                 ,p_INCOTERM             
                 ,p_CO_TK_ORG            
                 ,p_LOGISTICS_COORDINATOR
                 ,p_CURRENCY_CODE   
                 ,p_ORIGIN_COUNTRY
                 ,p_DEST_PORT
           FROM (SELECT  PUR_ORD.TK_EMP_TRADER 
                        ,PUR_ORD.PURCHASE_TERMS_DESCR 
                        ,WRKSH.CO_TK_ORG 
                        ,PUR_ORD.TK_EMP_TRF
                        ,PUR_ORD.CURRENCY_CODE
                        ,WRKSH.ORIG_TK_CNTRY
                        ,WRKSH.DEST_PORT
                        ,ROW_NUMBER() OVER (ORDER BY CREATION_DATE DESC) AS ROWNUMBER
                  FROM OW_WORKSHEET WRKSH, OW_PUR_ORD_PUB PUR_ORD
                  WHERE WRKSH.TK_OW       = PUR_ORD.TK_OW
                  AND   WRKSH.STATUS      = 'PUBLISHED'  
                  AND   WRKSH.NEW_OW      = 'Ý'   
                  AND   WRKSH.CREATED_BY  = p_TK_USER
                  AND   PUR_ORD.VENDOR_ID = p_VENDOR_ID) SUBT
            WHERE ROWNUMBER = 1; 
        EXCEPTION WHEN NO_DATA_FOUND THEN
            p_PURCHASER              := NULL; 
            p_INCOTERM               := NULL; 
            p_CO_TK_ORG              := NULL; 
            p_LOGISTICS_COORDINATOR  := NULL; 
            p_CURRENCY_CODE          := NULL; 
            p_ORIGIN_COUNTRY         := NULL; 
            p_DEST_PORT              := NULL; 
        END;
    ELSE
        p_PURCHASER              := NULL; 
        p_INCOTERM               := NULL; 
        p_CO_TK_ORG              := NULL; 
        p_LOGISTICS_COORDINATOR  := NULL; 
        p_PURCHASE_PAYMENT_TERMS := NULL; 
        p_CURRENCY_CODE          := NULL; 
        p_ORIGIN_COUNTRY         := NULL; 
        p_DEST_PORT              := NULL;
    END IF;    
EXCEPTION WHEN OTHERS THEN
	OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
	OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END GET_LAST_PUBLISHED_PO_DATA;

PROCEDURE SEND_TRANSFER_EMAIL
(
    p_WORKSHEET_NUM          NUMBER,
    p_OWNER                  VARCHAR2,
    p_NEW_OWNER              VARCHAR2,
    pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'SEND_TRANSFER_EMAIL';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_message           CLOB;
    mail_id             NUMBER := 0;
    v_inner_message     VARCHAR2(4000);    
    v_owner_name        VARCHAR2(500);
    v_new_owner_name    VARCHAR2(500);
    v_owner_mail        VARCHAR2(500);
    v_new_owner_mail    VARCHAR2(500);
    
BEGIN
    SELECT INITCAP(FULL_NAME),lower(email)
    into v_owner_name,v_owner_mail
    FROM A_EMPLOYEE
    WHERE TK_EMPLOYEE = p_OWNER;

    SELECT INITCAP(FULL_NAME),lower(email)
    into v_new_owner_name,v_new_owner_mail
    FROM A_EMPLOYEE
    WHERE TK_EMPLOYEE = p_NEW_OWNER;
    
    SELECT HTML_CODE
    into v_message
    FROM oms.EML_MAIL_TEMPLATE
    WHERE TEMPLATE_ID = 'WORKDESK_TRANSFER'; 
    
    v_inner_message := 'Hello '|| p_NEW_OWNER ||'!<br><br>This is an automated Email to inform that ' || v_owner_name || ' transfered the Worksheet #'||p_WORKSHEET_NUM || 'to you.<br><br>Please Click Here to view it.';
    
    v_message := REPLACE(v_message,'%MESSAGE%',v_inner_message);

    --Email send
    mail_id := APEX_MAIL.SEND(
                        p_to        => 'msantiagoqajcfood.com',--v_owner_mail||','||v_new_owner_mail,
                        p_from      => 'no-reply@ajcfood.com',
                        p_subj      => 'WORKDESK: Worksheet #' || p_WORKSHEET_NUM ||' transfer notification',
                        p_body      => v_message,
                        p_body_html => v_message
                        ); 
    apex_mail.push_queue;
    COMMIT;                            
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);     
END SEND_TRANSFER_EMAIL;

PROCEDURE COPY_WORKSHEET_DATA(p_TK_OW NUMBER, p_Type VARCHAR2,p_NEW_TK_OW NUMBER,p_NEW_WORKSHEET_NUM NUMBER, p_TK_EMPLOYEE NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'COPY_WORKSHEET_DATA';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_new_tk_ow         NUMBER;
    V_NEW_OW            OW_WORKSHEET.NEW_OW%TYPE;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    -- get new_ow from original worksheet
    SELECT NEW_OW
      INTO V_NEW_OW
     FROM OW_WORKSHEET
    WHERE TK_OW = P_TK_OW;
    
    --Insert Version in Publish Table
    APX_WOKDSK_PO_DML.OW_WORKSHEET_COPY_INSERT(p_TK_OW,p_Type,p_NEW_TK_OW,p_NEW_WORKSHEET_NUM, p_TK_EMPLOYEE, n_NEW_EXECUTION_ID);      
    APX_WOKDSK_PO_DML.OW_WS_NOTE_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_FOREX_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PUR_ORD_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_PRD_LINE_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, V_NEW_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_WS_LINE_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_PRD_PLANTS_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    --Insert OW Sale Ord DUMMY Record
    APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_MSC_CHRG_COPY_INS(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    
    APX_WOKDSK_PO_DML.OW_WS_NOTIFY_COMM_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END COPY_WORKSHEET_DATA;


PROCEDURE COPY_WORKSHEET_DATA_PUB(p_TK_OW NUMBER, p_Type VARCHAR2,p_NEW_TK_OW NUMBER,p_NEW_WORKSHEET_NUM NUMBER, p_TK_EMPLOYEE NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'COPY_WORKSHEET_DATA_PUB';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_new_tk_ow         NUMBER;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    --Insert Version in Publish Table
    APX_WOKDSK_PO_DML.OW_WORKSHEET_COPY_INSERT_PUB(p_TK_OW,p_Type,p_NEW_TK_OW,p_NEW_WORKSHEET_NUM, p_TK_EMPLOYEE, n_NEW_EXECUTION_ID);      
    APX_WOKDSK_PO_DML.OW_WS_NOTE_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_FOREX_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PUR_ORD_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_PRD_LINE_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_WS_LINE_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_PO_PLANTS_COPY_INSERT_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    --Insert OW Sale Ord DUMMY Record
    APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    
    APX_WOKDSK_PO_DML.OW_WS_MSC_CHRG_COPY_INS_PUB(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    APX_WOKDSK_PO_DML.OW_WS_RECIP_PUB_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    
    APX_WOKDSK_PO_DML.OW_WS_NOTIFY_C_PUB_COPY_INSERT(p_TK_OW, p_NEW_TK_OW, n_NEW_EXECUTION_ID);
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END COPY_WORKSHEET_DATA_PUB;

FUNCTION CALCULATE_PUR_EXT(p_per VARCHAR2,p_weight NUMBER,p_uom VARCHAR2,p_cases NUMBER,p_pur_price NUMBER) RETURN NUMBER
IS
    v_purext_num    NUMBER;
    v_multiplier    NUMBER;
    v_purext_chr    VARCHAR2(50);
BEGIN
    BEGIN
        SELECT MULTIPLIER
        into v_multiplier 
        FROM MEASURE_CONVERSION
        WHERE FROM_UOM = p_uom
        AND   TO_UOM   = p_per;     
    EXCEPTION WHEN NO_DATA_FOUND THEN
        v_multiplier := 1;
    END;
    IF p_per <> 'CS' THEN 
        IF (p_per = 'UOM') THEN
            v_purext_num := NVL(p_pur_price,0) * NVL(p_weight,0);
        ELSE
            v_purext_num := v_multiplier * NVL(p_pur_price,0) * NVL(p_weight,0);
        END IF;
    ELSE
      v_purext_num := NVL(p_pur_price,0) * NVL(p_cases,0);
    END IF;
    
    RETURN v_purext_num;   

END CALCULATE_PUR_EXT;

FUNCTION FORMAT_PUR_EXT(p_pur_ext in NUMBER) RETURN VARCHAR2 is
    v_formatted_pur_ext varchar2(50);
BEGIN
    v_formatted_pur_ext := TO_CHAR(p_pur_ext,'FM999G999G999G999G990D999');
    
    IF p_pur_ext - trunc(p_pur_ext) = 0 THEN
        v_formatted_pur_ext := SUBSTR(v_formatted_pur_ext,0,length(v_formatted_pur_ext) - 1);
    END IF;
    
    return v_formatted_pur_ext;
END;
    
----------------------------------------------------------------
FUNCTION F_CALCULATE_WEIGHT_LBS(p_tk_ow NUMBER) RETURN number
IS
v_weight_lbs  number;
BEGIN
    BEGIN
        select sum(nvl(weight_lbs,0))
        into v_weight_lbs 
        from OW_WS_PRD_LINE line 
        where tk_ow = p_tk_ow;
   
    EXCEPTION WHEN NO_DATA_FOUND THEN
        v_weight_lbs  := 0;
    END;
    
    RETURN nvl(v_weight_lbs,0);    

END F_CALCULATE_WEIGHT_LBS;
FUNCTION PO_SET_NOTIFY_SUBJECT(
    p_SET_WRKSHT_NUM NUMBER,
    p_VERSION_NUM  NUMBER
)RETURN VARCHAR2
IS
BEGIN
    RETURN 'Worksheet #'||TO_CHAR(p_SET_WRKSHT_NUM)||', version '||TO_CHAR(p_VERSION_NUM)||' Published';

END PO_SET_NOTIFY_SUBJECT;

FUNCTION PO_SET_SUPPLIER_DESCRIPTION(
    p_SET_WRKSHT_NUM NUMBER
)RETURN VARCHAR2
IS
BEGIN
    RETURN 'Worksheet #'|| p_SET_WRKSHT_NUM;

END PO_SET_SUPPLIER_DESCRIPTION;
-----------------------------------------------------------------------------
PROCEDURE VALIDATE_STATUS_PUBLISH_PO(p_TK_OW NUMBER,p_txt IN OUT VARCHAR2,p_topub IN OUT VARCHAR2, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'VALIDATE_STATUS_PUBLISH_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    
    v_inco      VARCHAR2(200);
    v_loca      VARCHAR2(200);
    v_ship      VARCHAR2(200);
    v_priced_in  VARCHAR2(200);
    v_comp          NUMBER;
    v_supplier      NUMBER;
    v_description VARCHAR2(200);
    v_txt         VARCHAR2(2000);    
    v_topub         VARCHAR2(2):='Y';    
    v_line_ok VARCHAR2(2):='Y';
    v_cabecera VARCHAR2(2):='Y';
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;

v_txt :=' ';

SELECT dest_port LOCATION,description,currency_code PRICED_IN,CO_TK_ORG COMPANY_NRO
INTO v_loca,v_description,v_priced_in,v_comp
FROM OW_WORKSHEET
WHERE TK_OW=p_TK_OW;

SELECT VENDOR_ID SUPPLIER_ID ,PICKUP_PERIOD_DESCR SHIP_DATE, PURCHASE_TERMS_DESCR
INTO v_supplier,v_ship,v_inco
FROM OW_pur_ord
WHERE TK_OW=p_TK_OW;

dbms_output.put_line('Datos wokrsheet:  v_inco '||v_inco||
    ' v_loca '||v_loca||      
    ' v_ship '||v_ship||      
    ' v_priced_in   '||v_priced_in||
    ' v_comp  '||v_comp||         
    ' v_supplier  '||v_supplier||    
    ' v_description  '||v_description||' p_topub: '||v_topub);


IF v_loca IS NULL THEN
  v_txt := v_txt||' Location ';
  v_topub :='N';
  v_cabecera :='N';
END IF;
IF v_description IS NULL THEN
  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
  v_txt := v_txt||' Description ';
  v_topub :='N';
  v_cabecera :='N';
END IF;

IF v_priced_in IS NULL THEN
  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
   v_line_ok :='N';
  v_txt := v_txt||' Priced_in ';
  v_topub :='N';
  v_cabecera :='N';
END IF;
IF v_comp IS NULL THEN
  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
  v_txt := v_txt||' Company ';
  v_topub :='N';
  v_cabecera :='N';
END IF;

IF v_supplier IS NULL THEN
  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
  v_txt := v_txt||' Supplier ';
  v_topub :='N';
  v_cabecera :='N';
END IF;

IF v_ship IS NULL THEN  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
  v_txt := v_txt||' Ship Date ';
  v_topub :='N';
  v_cabecera :='N';
END IF;

IF v_inco IS NULL THEN
  IF  v_cabecera ='N' THEN
  v_txt := v_txt||', ';  
  END IF;
  v_txt := v_txt||' Incoterm ';
  v_topub :='N';
  v_cabecera :='N';
END IF;

  IF  v_cabecera ='N' THEN
  v_txt := v_txt||' NULL.  ';
  END IF;

for r_line in (select ws.line_num, ws.WEIGHT,ws.WT_UOM, po.TK_PRD,po.PUR_PRICE_WT,po.PUR_PRICE_UOM
 from ow_ws_prd_line ws ,ow_po_prd_line po
 where po.tk_ow = ws.tk_ow
 and po.tk_ow = p_tk_ow
 and po.line_num=ws.line_num)
loop

IF r_line.WEIGHT IS NULL THEN
  v_line_ok :='N';
  v_topub :='N';
END IF;
IF r_line.WT_UOM IS NULL THEN
  v_line_ok :='N';
  v_topub :='N';
END IF;
IF r_line.TK_PRD IS NULL THEN
  v_line_ok :='N';
  v_topub :='N';
END IF;
IF r_line.PUR_PRICE_WT IS NULL THEN
  v_line_ok :='N';
  v_topub :='N';
END IF;
IF r_line.PUR_PRICE_UOM IS NULL THEN
  v_line_ok :='N';
  v_topub :='N';
END IF;



end loop;


IF v_line_ok ='N' THEN
    v_txt := v_txt||' There are lines with missing product, weight and/or price. ';
END IF;
p_txt := v_txt;                     
p_topub := v_topub;    
    
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'APX_WOKDSK_PO_TOOLKIT');
END VALIDATE_STATUS_PUBLISH_PO;


-----------------------------------------------------------------------------

/* Misc Charges Procedures */

PROCEDURE PO_WS_LOAD_MISC_CHARGES(P_TK_OW NUMBER, 
                                  pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'PO_WS_LOAD_MISC_CHARGES';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
    v_starttime         TIMESTAMP := CURRENT_TIMESTAMP;
    V_COLLECTION_NAME   VARCHAR2(50) := 'OW_MISC_CHARGES';
    V_MEMBER_COUNT NUMBER := 0;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    
    IF NOT APEX_COLLECTION.COLLECTION_EXISTS(V_COLLECTION_NAME) THEN
        APEX_COLLECTION.CREATE_COLLECTION(V_COLLECTION_NAME);
    END IF;  
    
    APEX_COLLECTION.DELETE_MEMBERS(P_COLLECTION_NAME => V_COLLECTION_NAME,
                                   P_ATTR_NUMBER     => 1,
                                   P_ATTR_VALUE      => P_TK_OW);  
    
    IF P_TK_OW IS NOT NULL THEN
        FOR C1 IN (SELECT MISC_CHARGE_ID,
                          CHARGES,
                          TK_CHG_TYPE,
                          COST,
                          CURRENCY,
                          PER,
                          TOTAL
                     FROM WORKDESK.OW_MISC_CHARGES
                    WHERE TK_OW = P_TK_OW
                     ORDER BY LINE_NUM ASC) LOOP
                     
                     APEX_COLLECTION.ADD_MEMBER(P_COLLECTION_NAME => V_COLLECTION_NAME,
                                                P_N001 => C1.MISC_CHARGE_ID,
                                                P_C001 => P_TK_OW,
                                                P_C002 => C1.CHARGES,
                                                P_N002 => C1.TK_CHG_TYPE,
                                                P_N003 => C1.COST,
                                                P_C003 => C1.CURRENCY,
                                                P_C004 => C1.PER,
                                                P_N004 => C1.TOTAL);
        
            V_MEMBER_COUNT := V_MEMBER_COUNT + 1;
        END LOOP;
    END IF;
    IF V_MEMBER_COUNT = 0 THEN
    
         APEX_COLLECTION.ADD_MEMBER(P_COLLECTION_NAME => V_COLLECTION_NAME,
                                    P_N001 => NULL,
                                    P_C001 => P_TK_OW,
                                    P_C002 => NULL,
                                    P_N002 => NULL,
                                    P_N003 => NULL,
                                    P_C003 => MISC_CHARGES_CURRENCY_DEF,
                                    P_C004 => MISC_CHARGES_PER_DEF,
                                    P_N004 => TO_NUMBER(MISC_CHARGES_TOTAL_DEF));
    END IF;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'APX_WOKDSK_PO_TOOLKIT');
END PO_WS_LOAD_MISC_CHARGES;

PROCEDURE PO_WS_SAVE_MISC_CHARGES(P_TK_OW NUMBER, 
                                  pEXECUTION_ID IN NUMBER default -1) IS
    V_COUNTER NUMBER := 1;
    V_MISC_CHARGE_ID VARCHAR2(50);
    V_CHARGES WORKDESK.OW_MISC_CHARGES.CHARGES%TYPE;
    V_TK_CHG_TYPE WORKDESK.OW_MISC_CHARGES.TK_CHG_TYPE%TYPE;
    V_COST WORKDESK.OW_MISC_CHARGES.COST%TYPE;
    V_CURRENCY WORKDESK.OW_MISC_CHARGES.CURRENCY%TYPE;
    V_PER WORKDESK.OW_MISC_CHARGES.PER%TYPE;
    V_TOTAL WORKDESK.OW_MISC_CHARGES.TOTAL%TYPE;
    V_COLLECTION_NAME VARCHAR2(50) := 'OW_MISC_CHARGES';
    N_NEW_EXECUTION_ID  NUMBER;
    V_PROC              VARCHAR2(100)   := 'PO_WS_SAVE_MISC_CHARGES';
    V_TABLE             VARCHAR2(100)   := 'OW_MISC_CHARGES';
    V_STARTTIME         TIMESTAMP := CURRENT_TIMESTAMP;
begin
     --Logging Begin
    IF PEXECUTION_ID = -1 THEN
        N_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        N_NEW_EXECUTION_ID := PEXECUTION_ID;
    END IF;
    
    -- process tabular form and insert in a collection
    APEX_COLLECTION.DELETE_MEMBERS(P_COLLECTION_NAME => V_COLLECTION_NAME,
                                   P_ATTR_NUMBER     => 1,
                                   P_ATTR_VALUE      => P_TK_OW);
    
    FOR I IN 1..APEX_APPLICATION.G_F11.COUNT
    LOOP
        V_MISC_CHARGE_ID := TO_NUMBER(APEX_APPLICATION.G_F10(I));
        V_CHARGES := TRIM(APEX_APPLICATION.G_F11(I));
        V_TK_CHG_TYPE := TO_NUMBER(APEX_APPLICATION.G_F12(I));
        V_COST := TO_NUMBER(REPLACE(APEX_APPLICATION.G_F13(I),',',NULL));
        V_CURRENCY := APEX_APPLICATION.G_F14(I);
        V_PER := APEX_APPLICATION.G_F15(I);
        V_TOTAL := TO_NUMBER(REPLACE(APEX_APPLICATION.G_F16(I),',',NULL));
        
        IF V_CHARGES IS NOT NULL OR V_COST IS NOT NULL OR NULLIF(V_CURRENCY,MISC_CHARGES_CURRENCY_DEF) IS NOT NULL OR NULLIF(V_PER,MISC_CHARGES_PER_DEF) IS NOT NULL THEN
        
             
             APEX_COLLECTION.ADD_MEMBER(P_COLLECTION_NAME => V_COLLECTION_NAME,
                                        P_N001 => V_MISC_CHARGE_ID,
                                        P_C001 => P_TK_OW,
                                        P_C002 => V_CHARGES,
                                        P_N002 => V_TK_CHG_TYPE,
                                        P_N003 => V_COST,
                                        P_C003 => V_CURRENCY,
                                        P_C004 => V_PER,
                                        P_N004 => V_TOTAL,
                                        P_N005 => V_COUNTER);
              
             V_COUNTER := V_COUNTER + 1;
              
         END IF;  
    END LOOP;
    
    
    -- delete erased members
    DELETE WORKDESK.OW_MISC_CHARGES 
      WHERE MISC_CHARGE_ID NOT IN (SELECT N001 
                                     FROM APEX_COLLECTIONS 
                                    WHERE COLLECTION_NAME = V_COLLECTION_NAME 
                                      AND N001 IS NOT NULL)
       AND TK_OW = P_TK_OW;
       
   FOR C1 IN (SELECT N001 AS MISC_CHARGE_ID,
                     C002 AS CHARGES,
                     N002 AS TK_CHG_TYPE,
                     N003 AS COST,
                     C003 AS CURRENCY,
                     C004 AS PER,
                     N004 AS TOTAL,
                     N005 AS COUNTER
                FROM APEX_COLLECTIONS 
               WHERE COLLECTION_NAME = V_COLLECTION_NAME
                 AND C001 = P_TK_OW) LOOP
                
       IF C1.MISC_CHARGE_ID IS NULL THEN
       
           WORKDESK.APX_WOKDSK_PO_DML.OW_WS_MISC_CHARGES_INSERT(P_TK_OW => P_TK_OW,
                                                                P_LINE_NUM => C1.COUNTER,
                                                                P_CHARGES => C1.CHARGES,
                                                                P_TK_CHG_TYPE => C1.TK_CHG_TYPE,
                                                                P_COST => C1.COST,
                                                                P_CURRENCY => C1.CURRENCY,
                                                                P_PER => C1.PER,
                                                                P_TOTAL => C1.TOTAL);
                                                                
       ELSE
           WORKDESK.APX_WOKDSK_PO_DML.OW_WS_MISC_CHARGES_UPDATE(P_MISC_CHARGE_ID => C1.MISC_CHARGE_ID,
                                                                P_LINE_NUM => C1.COUNTER,
                                                                P_CHARGES => C1.CHARGES,
                                                                P_TK_CHG_TYPE => C1.TK_CHG_TYPE,
                                                                P_COST => C1.COST,
                                                                P_CURRENCY => C1.CURRENCY,
                                                                P_PER => C1.PER,
                                                                P_TOTAL => C1.TOTAL); 
       
       END IF;
   END LOOP; 
   
   -- if contract then copy to worksheets
   
    FOR C1 IN (SELECT CW.TK_OW 
                 FROM OW_CONTRACT_WORKSHEET CW JOIN OW_CONTRACT C ON C.TK_CONTRACT = CW.TK_CONTRACT
                                               JOIN OW_WORKSHEET WS ON WS.TK_OW = CW.TK_OW
                WHERE C.TEMPLATE_TK_OW = P_TK_OW
                  AND WS.STATUS <> 'PUBLISHED')  LOOP
                
            APX_WOKDSK_PO_DML.OW_WS_MISC_CHARGES_DELETE(C1.TK_OW);
            
            APX_WOKDSK_PO_DML.OW_WS_MSC_CHRG_COPY_INS(P_TK_OW,C1.TK_OW);
               
    END LOOP; 
    
              
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'APX_WOKDSK_PO_TOOLKIT');
END PO_WS_SAVE_MISC_CHARGES;    

FUNCTION  PO_WS_GET_MISC_CHARGES_QUERY(P_TK_OW NUMBER, 
                                       pEXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 IS
    V_SQL VARCHAR2(4000) := NULL;
    N_NEW_EXECUTION_ID  NUMBER;
    V_PROC              VARCHAR2(100)   := 'PO_WS_GET_MISC_CHARGES_QUERY';
    V_TABLE             VARCHAR2(100)   := 'OW_MISC_CHARGES';
    V_STARTTIME         TIMESTAMP := CURRENT_TIMESTAMP;
    V_COLLECTION_NAME VARCHAR2(50) := 'OW_MISC_CHARGES';
BEGIN
    --Logging Begin
    IF PEXECUTION_ID = -1 THEN
        N_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        N_NEW_EXECUTION_ID := PEXECUTION_ID;
    END IF;
    
    V_SQL := 'SELECT APEX_ITEM.HIDDEN(10,N001)||
                     APEX_ITEM.TEXT(p_idx => 11, p_value=>C002, p_attributes => ''class="text_field apex-item-text ajc-tabular-required" field-name="Cost Description" data-name="misc-charges-cost-desc"'',p_size => 30) AS COST_DESCRIPTION,
                     APEX_ITEM.SELECT_LIST_FROM_LOV_XL(p_idx => 12,
                                                      p_value=> N002, 
                                                      p_lov =>''MISC_CHARGES_TYPES_LOV'', 
                                                      p_attributes => ''class="selectlist apex-item-select" field-name="Currency or %" data-name="misc-charges-type" '',
                                                      p_show_null => ''YES'',
                                                      p_null_value => NULL,
                                                      p_null_text => NULL) AS COST_TYPE,
                     APEX_ITEM.TEXT(p_idx => 13, p_value=>N003, p_attributes => ''class="text_field apex-item-text ajc-tabular-required ajc-tabular-numeric" field-name="Cost" data-name="misc-charges-cost"'',p_size => 12) AS COST,
                     APEX_ITEM.SELECT_LIST_FROM_LOV_XL(p_idx => 14,
                                                      p_value=> C003, 
                                                      p_lov =>''MISC_CHARGES_CURRENCIES_LOV'', 
                                                      p_attributes => ''class="selectlist apex-item-select ajc-tabular-required" field-name="Currency or %" data-name="misc-charges-currency" data-default-value="'||MISC_CHARGES_CURRENCY_DEF||'" style="min-width: 50px;"'',
                                                      p_show_null => ''YES'',
                                                      p_null_value => NULL,
                                                      p_null_text => NULL) AS CURRENCY,
                     APEX_ITEM.SELECT_LIST_FROM_LOV_XL(p_idx => 15, 
                                                       p_value=> C004, 
                                                       p_lov => ''MISC_CHARGES_UOM_LOV'', 
                                                       p_attributes => ''class="selectlist apex-item-select ''||CASE WHEN C003 = ''%'' THEN ''ajc-tabular-hidden'' ELSE NULL END||''" field-name="Per" data-default-value="'||MISC_CHARGES_PER_DEF||'" data-name="misc-charges-per" '',
                                                       p_show_null => ''YES'',
                                                       p_null_value => NULL,
                                                       p_null_text => NULL) AS UOM,
                     ''<span class="currency-symbol currency-tabular">$ </span>''||APEX_ITEM.TEXT(p_idx => 16, p_value=>N004, p_attributes => ''class="text_field apex-item-text ajc-tabular-numeric ajc-tabular-readonly" field-name="Cost" data-name="misc-charges-total" data-default-value="'||MISC_CHARGES_TOTAL_DEF||'" readonly="true"'',p_size => 14) AS TOTAL,                                  
                     NULL CLEAN_FIELDS,
                     NULL DELETE_COL
               FROM APEX_COLLECTIONS
              WHERE COLLECTION_NAME = '''||V_COLLECTION_NAME||''' ';
              
        IF P_TK_OW IS NULL THEN
            V_SQL := V_SQL || ' AND C001 IS NULL ';
        ELSE
            V_SQL := V_SQL || ' AND C001 = '||P_TK_OW;
        END IF;     
        
        RETURN V_SQL; 
              
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL); 
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'APX_WOKDSK_PO_TOOLKIT');

END PO_WS_GET_MISC_CHARGES_QUERY;
/* End Misc Charges Procedures */

PROCEDURE SAVE_RECIPIENTS(p_TK_OW  in NUMBER,
                          p_mail_oe IN VARCHAR2,
                          p_mail_traffic IN VARCHAR2,
                          p_mail_credit IN VARCHAR2,
                          p_mail_sale IN VARCHAR2 ,
                          p_note  IN VARCHAR2, 
                          pEXECUTION_ID IN NUMBER default -1)
IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'SAVE_RECIPIENTS';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT';
    v_starttime         TIMESTAMP;
    
    v_inco      VARCHAR2(200);
    v_comp          NUMBER;
    v_txt VARCHAR2(2000);
BEGIN
    --CREDIT
    --ORDERENTRY
    --SALES
    --TRAFFIC
    
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
  
    delete from workdesk.ow_ws_recipient  where tk_ow = p_tk_ow;
    
    for r in (SELECT tk_employee,full_name
              FROM   a_employee
              WHERE  INSTR(p_mail_oe,':'||tk_employee||':')>0)
    loop

      APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_INSERT(p_tk_ow,'ORDERENTRY',r.tk_employee);

    end Loop;

    for r in (SELECT tk_employee,full_name
              FROM   a_employee
              WHERE  INSTR(p_mail_traffic,':'||tk_employee||':')>0)
    loop

      APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_INSERT(p_tk_ow,'TRAFFIC',r.tk_employee);

    end Loop;
    
    for r in (SELECT tk_employee,full_name
              FROM   a_employee
              WHERE  INSTR(p_mail_credit,':'||tk_employee||':')>0)
    loop

      APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_INSERT(p_tk_ow,'CREDIT',r.tk_employee);
        
    end Loop;    
   
    for r in (SELECT tk_employee,full_name
              FROM   a_employee
              WHERE  INSTR(p_mail_sale,':'||tk_employee||':')>0)
    loop

      APX_WOKDSK_PO_DML.OW_WS_RECIPIENT_INSERT(p_tk_ow,'SALES',r.tk_employee);
    
    end Loop;
    
    
    --INSERT COMMENTS
    DELETE FROM OW_WS_NOTIFY_COMMENTS where tk_ow = p_tk_ow;
    
    IF p_tk_ow IS NOT NULL AND p_note IS NOT NULL THEN
      
      APX_WOKDSK_PO_DML.OW_WS_NOTIFY_COMMENTS_INSERT(p_tk_ow,p_note);
      
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
END;

PROCEDURE GET_NOTIFY_SUBJECT_PO(p_TK_OW                  IN NUMBER,
                                p_NOTIFY_SUBJECT         OUT VARCHAR2,
                                p_NOTIFY_SUBJ_NEW        OUT VARCHAR2,
                                p_NOTIFY_SUBJ_OLD        OUT VARCHAR2,
                                pEXECUTION_ID            IN NUMBER default -1)
IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'GET_NOTIFY_SUBJECT_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
BEGIN    
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
     
    
    BEGIN
      SELECT PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM),
             PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM+1),
             NOTIFY_SUBJECT
      INTO   p_NOTIFY_SUBJECT,
             p_NOTIFY_SUBJ_NEW,
             p_NOTIFY_SUBJ_OLD
      FROM   OW_WORKSHEET
      WHERE TK_OW = p_TK_OW;
    EXCEPTION 
      WHEN NO_DATA_FOUND THEN
        p_NOTIFY_SUBJECT := NULL;
        p_NOTIFY_SUBJ_NEW := NULL;
        p_NOTIFY_SUBJ_OLD := NULL;
    END;
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END GET_NOTIFY_SUBJECT_PO;

FUNCTION GET_PRODUCT_RECORDS_JSON(
P_TK_OW            IN NUMBER,
P_EXECUTION_ID     IN NUMBER default -1
) RETURN CLOB AS
v_tk_ow        number;
  cursor products(c_tk_ow number) is
      select a.line_num,
             b.cases,
             b.weight,
             b.wt_uom,
             a.tk_prd,
             a.packaging,
             b.pur_descr,
             decode(a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as purprice,
             a.pur_price_uom,
             workdesk.apx_wokdsk_po_toolkit.format_pur_ext(workdesk.apx_wokdsk_po_toolkit.calculate_pur_ext(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as purext,
             a.sup_desc_flag
        from workdesk.ow_po_prd_line a left join workdesk.ow_ws_prd_line b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
       where a.tk_ow = c_tk_ow
       UNION
       select a.line_num,
              b.cases,
              b.weight,
              b.wt_uom,
              a.tk_prd,
              a.packaging,
              b.pur_descr,
              decode(a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt) as purprice,
              a.pur_price_uom,
              workdesk.apx_wokdsk_po_toolkit.format_pur_ext(workdesk.apx_wokdsk_po_toolkit.calculate_pur_ext(a.pur_price_uom,b.weight,b.wt_uom,b.cases,decode (a.pur_price_uom, 'CS', a.pur_price_case, a.pur_price_wt))) as purext,
              a.sup_desc_flag
       from   workdesk.ow_po_prd_line_pub a left join workdesk.ow_ws_prd_line_pub b on a.tk_ow = b.tk_ow and a.line_num = b.line_num
       where  a.tk_ow = c_tk_ow
       AND    NOT EXISTS(SELECT 1
                         from   workdesk.ow_po_prd_line a2
                         where  a2.tk_ow = c_tk_ow)
       order by 1;
                     
  products_r products%rowtype;               
                     
  cursor product_plants(c_tk_ow number,c_line_num number) is
      select tk_prd_plant
       from workdesk.ow_po_prd_plants  
       where tk_ow = c_tk_ow
         and line_num = c_line_num
       order by tk_ow,line_num;  
           
  product_plants_r product_plants%rowtype;
  n_NEW_EXECUTION_ID  NUMBER;
  v_proc              VARCHAR2(100)   := 'GET_NOTIFY_SUBJECT_PO';
  v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
  v_starttime         TIMESTAMP;
  v_clob_json         CLOB;
begin

    --Logging Begin
    IF P_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := P_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    v_tk_ow := P_TK_OW;
    
    apex_json.initialize_clob_output;
    apex_json.open_array;
        
    open products(v_tk_ow);
    loop
        fetch products into products_r;
        exit when products%notfound;
            
        apex_json.open_object;
        apex_json.write('id',products_r.line_num);
        apex_json.write('case',products_r.cases);
        apex_json.write('weight',products_r.weight);
        apex_json.write('units',products_r.wt_uom);
        apex_json.write('product',products_r.tk_prd);
        apex_json.write('packaging',products_r.packaging);
        apex_json.write('supplierDescription',products_r.pur_descr);
        apex_json.open_array('plants');
            
        open product_plants(v_tk_ow,products_r.line_num);
            
        loop
            fetch product_plants into product_plants_r;
            exit when product_plants%notfound;
            apex_json.write(product_plants_r.tk_prd_plant);
        end loop;
            
        close product_plants;
            
        apex_json.close_array;
        apex_json.write('purPrice',products_r.purprice);
        apex_json.write('per',products_r.pur_price_uom);
        apex_json.write('purExt',products_r.purext);
        apex_json.write('prod_desc_modified',products_r.sup_desc_flag);
        apex_json.close_object;
            
    end loop;    
    close products;
    
    apex_json.close_array;
        
    v_clob_json := apex_json.get_clob_output;
  
    apex_json.free_output;
    
    RETURN v_clob_json;
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(P_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(P_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END;

FUNCTION MAIL_PREV_PO_INFO(
p_VENDOR_ID             IN NUMBER,
p_ORIGIN_COUNTRY        IN VARCHAR2,
p_TK_USER               IN NUMBER,
pEXECUTION_ID            IN NUMBER default -1

) RETURN CLOB AS

  n_NEW_EXECUTION_ID  NUMBER;
  v_proc              VARCHAR2(100)   := 'MAIL_PREV_PO_INFO';
  v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
  v_starttime         TIMESTAMP;
  v_mail_TRAFFIC      VARCHAR2(1000);
  v_mail_CREDIT       VARCHAR2(1000);
  v_mail_SALE         VARCHAR2(1000);
  v_flag              VARCHAR2(1);
  v_tk_ow             number;
  v_clob_json         CLOB;
    
BEGIN    

  --Logging Begin
  IF pEXECUTION_ID = -1 THEN
      n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
  ELSE 
      n_NEW_EXECUTION_ID := pEXECUTION_ID;
  END IF;
  v_starttime := CURRENT_TIMESTAMP;
  --Logging End

  v_flag := 'N';
  
  apex_json.initialize_clob_output;

  BEGIN       
   SELECT SUBT.TK_OW,
          'Y'
     INTO V_TK_OW,
          v_flag
     FROM (SELECT PUR_ORD.TK_OW 
           FROM   OW_WORKSHEET_PUB WRKSH, 
                  OW_PUR_ORD PUR_ORD
           WHERE  WRKSH.TK_OW       = PUR_ORD.TK_OW
           AND    WRKSH.STATUS      = 'PUBLISHED'
           AND    WRKSH.NEW_OW      = 'Y'     
           AND    PUR_ORD.VENDOR_ID = p_VENDOR_ID
           AND    WRKSH.ORIG_TK_CNTRY = p_ORIGIN_COUNTRY
           AND    WRKSH.CREATED_BY  = p_TK_USER
           ORDER BY CREATION_DATE DESC) SUBT
     WHERE ROWNUM = 1;       
   
  EXCEPTION WHEN NO_DATA_FOUND THEN
       
    apex_json.open_object;
    apex_json.write('TRAFFIC','');
    apex_json.write('CREDIT','');
    apex_json.write('SALES','');
    apex_json.write('SET','N');
    apex_json.close_object;
        
  END;
      
  IF v_flag = 'Y' THEN
  
    BEGIN
                    
      SELECT LISTAGG(CASE WHEN RECIPIENT_TYPE = 'TRAFFIC' THEN TK_EMPLOYEE ELSE NULL END,':') WITHIN GROUP (ORDER BY tk_ow),
             LISTAGG(CASE WHEN RECIPIENT_TYPE = 'CREDIT' THEN TK_EMPLOYEE ELSE NULL END,':') WITHIN GROUP (ORDER BY tk_ow),
             LISTAGG(CASE WHEN RECIPIENT_TYPE = 'SALES' THEN TK_EMPLOYEE ELSE NULL END,':') WITHIN GROUP (ORDER BY tk_ow)
      INTO   v_mail_traffic,
             v_mail_credit,
             v_mail_sale
      FROM   WORKDESK.OW_WS_RECIPIENT_PUB 
      WHERE  tk_ow = v_TK_OW;
      
      apex_json.open_object;
      apex_json.write('TRAFFIC',v_mail_traffic);
      apex_json.write('CREDIT',v_mail_credit);
      apex_json.write('SALES',v_mail_sale);
      apex_json.write('SET',v_flag);
      apex_json.close_object;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

  END IF;
        
  v_clob_json := apex_json.get_clob_output;
  
  apex_json.free_output;
    
  RETURN v_clob_json;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'WORKDESK.APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'WORKDESK.APX_WOKDSK_PO_TOOLKIT'); 
END MAIL_PREV_PO_INFO;

PROCEDURE INSERTA_ATISPROD_WORKSHEET(p_TK_OW      IN NUMBER,
                  p_SET_WRKSHT_NUM        IN NUMBER,
                  pEXECUTION_ID            IN NUMBER default -1)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'INSERTA_ATISPROD_WORKSHEET';
    v_table             VARCHAR2(100)   := 'ATISPROD.WORKSHEET ';
    v_starttime         TIMESTAMP;
BEGIN    
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
     
    
    BEGIN
              INSERT INTO ATISPROD.WORKSHEET (
                        TK_WRKSHT_NUM,
                        SET_WRKSHT_NUM,
                        SET_WRKSHT_SEQ,
                        CO_TK_ORG,
                        CREATE_DATE,
                        SYS_CREATE_DATE,
                        WKSHT_STATUS,
                        TK_EMP_TRADER,
                        TK_IRATE,
                        SHORT_SALE_FLAG,
                        LAST_UPDATE_DATE,
                        SYSTEM_ORIGIN,
                        SEND_TO_OTM)
            SELECT W.SET_WRKSHT_NUM,
                   W.SET_WRKSHT_NUM,
                   0,
                   W.CO_TK_ORG,
                   SYSDATE,
                   SYSDATE,
                   'RES',
                   WPO.TK_EMP_TRADER,
                   265,
                   'N',
                   SYSDATE,
                   'ATIS',
                   'Y'
             FROM OW_WORKSHEET W JOIN OW_PUR_ORD WPO ON WPO.TK_OW = W.TK_OW
             WHERE NOT EXISTS (SELECT *
                                       FROM ATISPROD.WORKSHEET a where a.SET_WRKSHT_NUM = p_SET_WRKSHT_NUM)
              AND W.TK_OW = p_TK_OW;
              COMMIT;
    END;
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END INSERTA_ATISPROD_WORKSHEET;

END APX_WOKDSK_PO_TOOLKIT;
/


GRANT EXECUTE ON WORKDESK.APX_WOKDSK_PO_TOOLKIT TO OMS;
