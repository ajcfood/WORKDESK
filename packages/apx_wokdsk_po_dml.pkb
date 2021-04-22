DROP PACKAGE BODY WORKDESK.APX_WOKDSK_PO_DML;

CREATE OR REPLACE PACKAGE BODY WORKDESK.APX_WOKDSK_PO_DML AS 
PROCEDURE OW_SALE_ORD_INSERT_DUMMY_PUB(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_SALE_ORD_INSERT_DUMMY_PUB';
    v_table             VARCHAR2(100)   := 'OW_SALE_ORD';
    v_starttime         TIMESTAMP;
    v_status            VARCHAR2(20);
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    INSERT INTO OW_SALE_ORD_PUB
       (TK_OW, CUST_ACCOUNT_ID, PAY_TERM_ID, SALE_CONTRACT_DATE, TK_EMP_TRADER, 
        TK_EMP_TRF, TRANSIT_DAYS, PRODUCT_DAYS, PERCENT_DOWN, DAE, 
        CURRENCY_CODE, EXCHANGE_RATE)
     Values 
        (p_TK_OW, 0, 0, TRUNC(SYSDATE), 0, 0, 0, 0, 0, 0, 'USD', 1);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_SALE_ORD_INSERT_DUMMY_PUB;
PROCEDURE OW_SALE_ORD_INSERT_DUMMY(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_SALE_ORD_INSERT_DUMMY';
    v_table             VARCHAR2(100)   := 'OW_SALE_ORD';
    v_starttime         TIMESTAMP;
    v_status            VARCHAR2(20);
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    INSERT INTO OW_SALE_ORD
       (TK_OW, CUST_ACCOUNT_ID, PAY_TERM_ID, SALE_CONTRACT_DATE, TK_EMP_TRADER, 
        TK_EMP_TRF, TRANSIT_DAYS, PRODUCT_DAYS, PERCENT_DOWN, DAE, 
        CURRENCY_CODE, EXCHANGE_RATE)
     Values 
        (p_TK_OW, 0, 0, TRUNC(SYSDATE), 0, 0, 0, 0, 0, 0, 'USD', 1);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_SALE_ORD_INSERT_DUMMY;
PROCEDURE OW_SALE_ORD_DELETE(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_SALE_ORD_DELETE';
    v_table             VARCHAR2(100)   := 'OW_SALE_ORD';
    v_starttime         TIMESTAMP;
    v_status            VARCHAR2(20);
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    DELETE OW_SALE_ORD WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_SALE_ORD_DELETE;
PROCEDURE OW_WORKSHEET_OWNER_UPDATE(
p_TK_OW                  NUMBER,
p_TK_OWNER               NUMBER, 
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_OWNER_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_status            VARCHAR2(20);
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT STATUS 
    into v_status
    FROM OW_WORKSHEET
    WHERE TK_OW = p_TK_OW;

    UPDATE WORKDESK.OW_WORKSHEET 
    SET OWNER = p_TK_OWNER 
    WHERE  TK_OW = p_TK_OW;
    
    IF v_status = 'PUBLISHED' THEN 
        UPDATE WORKDESK.OW_WORKSHEET_PUB 
        SET OWNER = p_TK_OWNER 
        WHERE  TK_OW = p_TK_OW;    
    END IF;
    
    COMMIT;        

EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);         
END OW_WORKSHEET_OWNER_UPDATE;

PROCEDURE OW_PUR_ORD_PUB_DELETE(
p_TK_OW             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET_PUB';
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
    
    DELETE OW_PUR_ORD_PUB WHERE TK_OW = p_TK_OW;    
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_PUR_ORD_PUB_DELETE;
PROCEDURE OW_PUR_ORD_DELETE(
p_TK_OW             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_DELETE';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
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
    
    DELETE OW_PUR_ORD WHERE TK_OW = p_TK_OW; 
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_PUR_ORD_DELETE;
PROCEDURE OW_PUR_ORD_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD_PUB';
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
    
    INSERT INTO OW_PUR_ORD_PUB
    (
         TK_OW                        
        ,VENDOR_ID                     
        ,PURCHASE_TERMS_DESCR          
        ,PICKUP_PERIOD_DESCR           
        ,CONTACT                       
        ,VND_ORD_NUM                   
        ,PAY_TERM_DESCR                
        ,PURCHASE_DATE                 
        ,TK_EMP_TRADER                 
        ,TK_EMP_TRF                    
        ,DISCOUNT_RATE                 
        ,CURRENCY_CODE                 
        ,EXCHANGE_RATE                 
    )
    SELECT 
         TK_OW                        
        ,VENDOR_ID                     
        ,PURCHASE_TERMS_DESCR          
        ,PICKUP_PERIOD_DESCR           
        ,CONTACT                       
        ,VND_ORD_NUM                   
        ,PAY_TERM_DESCR                
        ,PURCHASE_DATE                 
        ,TK_EMP_TRADER                 
        ,TK_EMP_TRF                    
        ,DISCOUNT_RATE                 
        ,CURRENCY_CODE                 
        ,EXCHANGE_RATE 
    FROM OW_PUR_ORD
    WHERE TK_OW = p_TK_OW; 
    COMMIT;      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PUR_ORD_PUB_INSERT;
PROCEDURE OW_WS_NOTE_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE_PUB';
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

    INSERT INTO OW_WS_NOTE_PUB
    (
         TK_OW
        ,TYPE
        ,NOTE                
    )
    SELECT 
         TK_OW
        ,TYPE
        ,NOTE 
    FROM OW_WS_NOTE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;     
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_NOTE_PUB_INSERT;

PROCEDURE OW_WS_PRD_LINE_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_PRD_LINE_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_PRD_LINE_PUB';
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
    
    INSERT INTO OW_WS_PRD_LINE_PUB
    (
        TK_OW      
        ,LINE_NUM           
        ,CASES              
        ,WEIGHT             
        ,WT_UOM             
        ,SELL_DESCR         
        ,PUR_DESCR          
        ,PROPRIETARY                          
    )
    SELECT 
        TK_OW      
        ,LINE_NUM           
        ,CASES              
        ,WEIGHT             
        ,WT_UOM             
        ,SELL_DESCR         
        ,PUR_DESCR          
        ,PROPRIETARY  
    FROM OW_WS_PRD_LINE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_PRD_LINE_PUB_INSERT;




PROCEDURE OW_PO_PRD_LINE_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE_PUB';
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
    
    INSERT INTO OW_PO_PRD_LINE_PUB
    (
        TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,CREATED_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_BY
        ,PER
        ,PACKAGING
        ,PRD_BUY_DESCR
        ,SUP_DESC_FLAG
    )
    SELECT 
        TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,CREATED_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_BY
        ,PER
        ,PACKAGING
        ,PRD_BUY_DESCR
        ,SUP_DESC_FLAG
    FROM OW_PO_PRD_LINE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_PRD_LINE_PUB_INSERT;

PROCEDURE OW_WS_FOREX_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX_PUB';
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
    
    INSERT INTO OW_WS_FOREX_PUB
    (
         TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE                
    )
    SELECT 
         TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE   
    FROM OW_WS_FOREX
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_FOREX_PUB_INSERT; 
PROCEDURE OW_WORKSHEET_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET_PUB';
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

    INSERT INTO OW_WORKSHEET_PUB
    (
        TK_OW             
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM       
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE     
        ,CREATED_BY        
        ,LAST_UPDATE_DATE  
        ,LAST_UPDATED_BY   
        ,INIT_TK_OW        
        ,OWNER             
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,ORIG_TK_CNTRY
        ,NEW_OW
    )
    SELECT 
        TK_OW             
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM     
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE     
        ,CREATED_BY        
        ,LAST_UPDATE_DATE  
        ,LAST_UPDATED_BY   
        ,INIT_TK_OW        
        ,OWNER             
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,ORIG_TK_CNTRY
        ,'Y'
    FROM OW_WORKSHEET
    WHERE TK_OW = p_TK_OW; 
    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WORKSHEET_PUB_INSERT;
PROCEDURE OW_WORKSHEET_DELETE(p_TK_OW NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_DELETE';
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
    
    DELETE OW_WORKSHEET WHERE TK_OW = p_TK_OW;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WORKSHEET_DELETE; 
PROCEDURE OW_WS_FOREX_PUB_DELETE(p_a_worksheet arrayofWorksheets, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX_PUB';
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
    DELETE OW_WS_FOREX_PUB WHERE TK_OW MEMBER OF p_a_worksheet;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_FOREX_PUB_DELETE; 
PROCEDURE OW_WS_NOTE_PUB_DELETE(p_a_worksheet arrayofWorksheets, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE_PUB';
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
    DELETE OW_WS_NOTE_PUB WHERE TK_OW MEMBER OF p_a_worksheet;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_NOTE_PUB_DELETE; 
PROCEDURE OW_PO_PRD_LINE_PUB_DELETE(p_a_worksheet arrayofWorksheets, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE_PUB';
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
    DELETE OW_PO_PRD_LINE_PUB WHERE TK_OW MEMBER OF p_a_worksheet;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_PO_PRD_LINE_PUB_DELETE; 
PROCEDURE OW_PO_PRD_LINE_DELETE(p_TK_OW NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_DELETE';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE';
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
    DELETE OW_PO_PRD_LINE WHERE TK_OW = p_TK_OW;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_PO_PRD_LINE_DELETE;
PROCEDURE OW_WS_NOTE_DELETE(p_TK_OW NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE';
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
    DELETE OW_WS_NOTE WHERE TK_OW = p_TK_OW;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_NOTE_DELETE;
PROCEDURE OW_WS_FOREX_DELETE(p_TK_OW NUMBER, pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX';
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
    DELETE OW_WS_FOREX WHERE TK_OW = p_TK_OW;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_FOREX_DELETE;
PROCEDURE OW_WS_NOTE_UPDATE(
p_TK_OW             NUMBER, 
p_NOTE_SUPPLIER     VARCHAR2, 
p_NOTE_INTERNAL     VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) 
IS
    p_exists            NUMBER;
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE';
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
  
    SELECT COUNT(1) 
    into p_exists 
    FROM OW_WS_NOTE 
    WHERE TK_OW = p_TK_OW
    AND TYPE = 'SUPPLIER';
       
    IF p_exists > 0 THEN  
        IF p_NOTE_SUPPLIER IS NOT NULL THEN 
            UPDATE OW_WS_NOTE set
                NOTE = p_NOTE_SUPPLIER
            WHERE TK_OW = p_TK_OW
            AND TYPE = 'SUPPLIER'; 
        ELSE
            DELETE OW_WS_NOTE WHERE TK_OW = p_TK_OW AND TYPE = 'SUPPLIER';
        END IF;
    ELSE
        IF p_NOTE_SUPPLIER IS NOT NULL THEN    
            INSERT INTO OW_WS_NOTE (TK_OW, TYPE, NOTE) values (p_TK_OW, 'SUPPLIER', p_NOTE_SUPPLIER);
        END IF; 
    END IF;
    
    SELECT COUNT(1) 
    into p_exists 
    FROM OW_WS_NOTE 
    WHERE TK_OW = p_TK_OW
    AND TYPE = 'INTERNAL';
  
    IF p_exists > 0 THEN   
        IF p_NOTE_INTERNAL IS NOT NULL THEN     
            UPDATE OW_WS_NOTE set
                NOTE = p_NOTE_INTERNAL
            WHERE TK_OW = p_TK_OW
            AND TYPE = 'INTERNAL'; 
        ELSE
            DELETE OW_WS_NOTE WHERE TK_OW = p_TK_OW AND TYPE = 'INTERNAL';
        END IF;
    ELSE
        IF p_NOTE_INTERNAL IS NOT NULL THEN    
            INSERT INTO OW_WS_NOTE (TK_OW, TYPE, NOTE) values (p_TK_OW, 'INTERNAL', p_NOTE_INTERNAL);
        END IF; 
    END IF;    
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_NOTE_UPDATE;
PROCEDURE OW_WS_FOREX_UPDATE(
p_TK_OW             NUMBER,         
p_BANK_DESCR        VARCHAR2,
p_EXCHANGE_RATE     NUMBER,
p_EXCHANGE_AMOUNT   NUMBER,
p_CONTRACT_NUMBER   VARCHAR2,
p_VALUATION_DATE    DATE,
pEXECUTION_ID       IN NUMBER default -1
) IS
    v_forex_total_value NUMBER;
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX';
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

    UPDATE OW_WS_FOREX set
         BANK_DESCR      = p_BANK_DESCR
        ,EXCHANGE_RATE   = NVL(p_EXCHANGE_RATE,1)
        ,EXCHANGE_AMOUNT = NVL(p_EXCHANGE_AMOUNT,0)
        ,CONTRACT_NUMBER = p_CONTRACT_NUMBER
        ,VALUATION_DATE  = p_VALUATION_DATE
    WHERE TK_OW = p_TK_OW; 
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_FOREX_UPDATE;
PROCEDURE OW_WORKSHEET_UPDATE(
p_TK_OW             NUMBER, 
p_TYPE              VARCHAR2,   
p_DESCRIPTION       VARCHAR2,           
p_DEST_TK_CNTRY     NUMBER,
p_INSP_TK_CNTRY     NUMBER,
p_PLANT             VARCHAR2,
p_CO_TK_ORG         NUMBER,
p_CURRENCY_CODE     VARCHAR2,   
p_WT_UOM            VARCHAR2,                  
p_LAST_UPDATED_BY   NUMBER,
p_DEST_PORT         NUMBER,
p_NOTIFY_SUBJECT    VARCHAR2,
p_ODS               VARCHAR2,   
p_POSITION_PURCHASE VARCHAR2,    
p_PURCHASE_DECISION VARCHAR2,  
p_PROVINCE          NUMBER,
p_NOTE_SUPPLIER     VARCHAR2,
p_NOTE_INTERNAL     VARCHAR2,
p_BANK_DESCR        VARCHAR2,
p_EXCHANGE_RATE     NUMBER,
p_EXCHANGE_AMOUNT   NUMBER,
p_CONTRACT_NUMBER   VARCHAR2,
p_VALUATION_DATE    DATE,
p_VENDOR_ID         NUMBER,
p_INCOTERM          VARCHAR2,
p_SHIP_DATE         VARCHAR2,     
p_SUPPLIER_REF      VARCHAR2,
p_PURCHASE_DATE     DATE,
p_DISCOUNT          NUMBER,
p_PURCHASE_PAYMENT_TERMS VARCHAR2,
p_LOGISTICS_COORDINATOR NUMBER,
p_PURCHASER             NUMBER,
P_ORIGIN_COUNTRY         NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_UPDATE';
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
    UPDATE OW_WORKSHEET set                    
         TYPE              = p_TYPE             
        ,DESCRIPTION       = p_DESCRIPTION     
        ,DEST_TK_CNTRY     = p_DEST_TK_CNTRY
        ,INSP_TK_CNTRY     = p_INSP_TK_CNTRY
        ,PLANT             = p_PLANT
        ,CO_TK_ORG         = p_CO_TK_ORG
        ,CURRENCY_CODE     = p_CURRENCY_CODE
        ,WT_UOM            = p_WT_UOM
        ,LAST_UPDATE_DATE  = SYSDATE
        ,LAST_UPDATED_BY   = p_LAST_UPDATED_BY  
        ,DEST_PORT         = p_DEST_PORT   
        ,NOTIFY_SUBJECT    = p_NOTIFY_SUBJECT  
        ,ODS               = p_ODS   
        ,POSITION_PURCHASE = p_POSITION_PURCHASE   
        ,PURCHASE_DECISION = p_PURCHASE_DECISION   
        ,PROVINCE          = NVL(p_PROVINCE,0)   
        ,ORIG_TK_CNTRY     = P_ORIGIN_COUNTRY
    WHERE TK_OW = p_TK_OW;

    --Update Notes
    OW_WS_NOTE_UPDATE(p_TK_OW, p_NOTE_SUPPLIER, p_NOTE_INTERNAL, n_NEW_EXECUTION_ID);
    --Update Foreign Echange Information
    OW_WS_FOREX_UPDATE(p_TK_OW, p_BANK_DESCR, p_EXCHANGE_RATE,p_EXCHANGE_AMOUNT, p_CONTRACT_NUMBER,p_VALUATION_DATE, n_NEW_EXECUTION_ID);
    --Update Purchaser table 
    OW_PUR_ORD_UPDATE(p_TK_OW, p_LAST_UPDATED_BY, p_VENDOR_ID, p_INCOTERM, p_SHIP_DATE, p_SUPPLIER_REF, p_PURCHASE_PAYMENT_TERMS, p_PURCHASE_DATE, p_PURCHASER, p_LOGISTICS_COORDINATOR, 
                      p_DISCOUNT, p_CURRENCY_CODE, p_EXCHANGE_RATE,p_LOCATION_CONTACT, n_NEW_EXECUTION_ID);    

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);     
END OW_WORKSHEET_UPDATE;
PROCEDURE OW_WORKSHEET_INSERT(
p_NEW_TK            NUMBER,
p_TYPE              VARCHAR2,   
p_DESCRIPTION       IN OUT VARCHAR2,  
p_VERSION_NUM       NUMBER,           
p_STATUS            VARCHAR2,   
p_DEST_TK_CNTRY     NUMBER,
p_INSP_TK_CNTRY     NUMBER,
p_PLANT             VARCHAR2,
p_CO_TK_ORG         NUMBER,
p_CURRENCY_CODE     IN OUT VARCHAR2,   
p_WT_UOM            VARCHAR2,                  
p_CREATED_BY        NUMBER,                     
p_OWNER             NUMBER,
p_DEST_PORT         NUMBER,
p_NOTIFY_SUBJECT    VARCHAR2,
p_ODS               VARCHAR2,   
p_POSITION_PURCHASE VARCHAR2,    
p_PURCHASE_DECISION VARCHAR2,  
p_PROVINCE          IN OUT NUMBER,
p_NOTE_SUPPLIER     VARCHAR2,
p_NOTE_INTERNAL     VARCHAR2,
p_BANK_DESCR        VARCHAR2,
p_EXCHANGE_RATE     NUMBER,
p_EXCHANGE_AMOUNT   NUMBER,
p_CONTRACT_NUMBER   VARCHAR2,
p_VALUATION_DATE    DATE,
p_LINE_NUM          NUMBER,        
p_PUR_PRICE_CASE    NUMBER,
p_PUR_PRICE_WT      NUMBER,
p_PUR_PRICE_UOM     VARCHAR2,
p_VENDOR_ID         NUMBER,
p_INCOTERM          VARCHAR2,
p_SHIP_DATE         VARCHAR2,     
p_SUPPLIER_REF      VARCHAR2,
p_PURCHASE_DATE     DATE,
p_DISCOUNT          NUMBER,
p_PURCHASE_PAYMENT_TERMS VARCHAR2, 
p_LOGISTICS_COORDINATOR NUMBER,
p_PURCHASER             NUMBER,
p_SET_WRKSHT_NUM    IN OUT NUMBER,
p_new_TK_OW         OUT NUMBER,
P_ORIGIN_COUNTRY         NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_notify_subject    VARCHAR2(1000)  := NULL;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_set_wrksht_num    NUMBER := NULL;
    v_tk_ow             NUMBER := NULL;
    v_init_tk_ow        NUMBER := NULL;    
BEGIN 
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    IF p_NEW_TK IS NULL THEN
        SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
        into v_tk_ow
        FROM DUAL;  
    ELSE
        v_tk_ow := p_NEW_TK;
    END IF;    
    
    p_new_TK_OW := v_tk_ow;
    
    --Check if we are creating a New Worksheet or a New Version
    IF p_SET_WRKSHT_NUM IS NULL THEN
        --NEW WORKSHEET
        SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
        into v_set_wrksht_num
        FROM DUAL;
        
        v_init_tk_ow := v_tk_ow;
    ELSE
        --New version of existing Worksheet
        v_set_wrksht_num := p_SET_WRKSHT_NUM;
        
        SELECT INIT_TK_OW 
        into v_init_tk_ow
        FROM OW_WORKSHEET 
        WHERE SET_WRKSHT_NUM = p_SET_WRKSHT_NUM;        
        
    END IF;
    p_SET_WRKSHT_NUM := v_set_wrksht_num;
    v_notify_subject := REPLACE(p_NOTIFY_SUBJECT, '@WORKSHEET_NUMBER@' , v_set_wrksht_num);
    
--    --Setting default values if the user leaves them blank
--    IF p_DESCRIPTION IS NULL THEN
--        p_DESCRIPTION := APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(v_set_wrksht_num);
--    END IF;
    
    IF p_PROVINCE IS NULL THEN
        p_PROVINCE  := 0;
    END IF;
    
    IF p_CURRENCY_CODE IS NULL THEN
        p_CURRENCY_CODE  := 'USD';
    END IF;
    
    --Insert into Worksheet Table
    INSERT INTO OW_WORKSHEET (
         TK_OW                   
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM              
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE           
        ,CREATED_BY             
        ,INIT_TK_OW              
        ,OWNER             
        ,DEST_PORT         
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,ORIG_TK_CNTRY 
        ,NEW_OW
    )
    values
    (
         v_tk_ow 
        ,p_TYPE             
        ,p_DESCRIPTION 
        ,v_set_wrksht_num       
        ,p_VERSION_NUM          
        ,p_STATUS               
        ,p_DEST_TK_CNTRY        
        ,p_INSP_TK_CNTRY        
        ,p_PLANT                
        ,p_CO_TK_ORG            
        ,p_CURRENCY_CODE        
        ,p_WT_UOM  
        ,SYSDATE             
        ,p_CREATED_BY 
        ,v_init_tk_ow          
        ,p_OWNER                
        ,p_DEST_PORT            
        ,v_notify_subject       
        ,p_ODS                  
        ,p_POSITION_PURCHASE    
        ,p_PURCHASE_DECISION    
        ,p_PROVINCE   
        ,P_ORIGIN_COUNTRY      
        ,'Y'    
        );

    --Insert OW Sale Ord DUMMY Record
    OW_SALE_ORD_INSERT_DUMMY(v_tk_ow,n_NEW_EXECUTION_ID);
    --Insert Notes
    OW_WS_NOTE_INSERT(v_tk_ow, p_NOTE_SUPPLIER, p_NOTE_INTERNAL, n_NEW_EXECUTION_ID);
    --Insert Foreign Echange Information
    OW_WS_FOREX_INSERT(v_tk_ow, p_BANK_DESCR, p_EXCHANGE_RATE,p_EXCHANGE_AMOUNT, p_CONTRACT_NUMBER,p_VALUATION_DATE, n_NEW_EXECUTION_ID);    
    --Insert Purchaser table 
    OW_PUR_ORD_INSERT(v_tk_ow, p_CREATED_BY, p_VENDOR_ID, p_INCOTERM, p_SHIP_DATE, p_SUPPLIER_REF, p_PURCHASE_PAYMENT_TERMS, p_PURCHASE_DATE, p_PURCHASER, p_LOGISTICS_COORDINATOR, 
                      p_DISCOUNT, p_CURRENCY_CODE, p_EXCHANGE_RATE,p_LOCATION_CONTACT, n_NEW_EXECUTION_ID);
    
    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WORKSHEET_INSERT;
PROCEDURE OW_PUR_ORD_UPDATE(
p_TK_OW                  NUMBER,
p_USER                   NUMBER,
p_VENDOR_ID              NUMBER,
p_INCOTERM               VARCHAR2,
p_SHIP_DATE              VARCHAR2,     
p_SUPPLIER_REF           VARCHAR2,
p_PURCHASE_PAYMENT_TERMS VARCHAR2, 
p_PURCHASE_DATE          DATE,
p_PURCHASER              NUMBER,
p_LOGISTICS_COORDINATOR  NUMBER,
p_DISCOUNT               NUMBER,
p_CURRENCY_CODE          VARCHAR2,  
p_EXCHANGE_RATE          NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
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
    
    UPDATE OW_PUR_ORD SET
         VENDOR_ID            = p_VENDOR_ID--NVL(p_VENDOR_ID,p_USER) 
        ,PURCHASE_TERMS_DESCR = p_INCOTERM              
        ,PICKUP_PERIOD_DESCR  = p_SHIP_DATE             
        ,VND_ORD_NUM          = p_SUPPLIER_REF              
        ,PAY_TERM_DESCR       = p_PURCHASE_PAYMENT_TERMS    
        ,PURCHASE_DATE        = p_PURCHASE_DATE             
        ,TK_EMP_TRADER        = NVL(p_PURCHASER,p_USER)                
        ,TK_EMP_TRF           = p_LOGISTICS_COORDINATOR     
        ,DISCOUNT_RATE        = p_DISCOUNT                  
        ,CURRENCY_CODE        = p_CURRENCY_CODE             
        ,EXCHANGE_RATE        = p_EXCHANGE_RATE    
        ,CONTACT              = p_LOCATION_CONTACT     
    WHERE TK_OW = p_TK_OW;
    COMMIT;      
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_PUR_ORD_UPDATE;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_UPDATE
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/
PROCEDURE OW_WS_NOTIFY_COMMENTS_UPDATE(
p_TK_OW                  NUMBER,
p_NOTIFY_COMMENTS        VARCHAR2,     
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS';
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
        
    UPDATE OW_WS_NOTIFY_COMMENTS SET
           NOTIFY_COMMENTS=p_NOTIFY_COMMENTS
    WHERE TK_OW = p_TK_OW;
    COMMIT;      
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_COMMENTS_UPDATE;

/***************************************************************
*
*  OW_WS_RECIPIENT_UPDATE
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/
PROCEDURE OW_WS_RECIPIENT_UPDATE(
p_TK_OW                  NUMBER,
p_RECIPIENT_TYPE         VARCHAR2,
p_TK_EMPLOYEE            NUMBER,
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT';
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
    
    UPDATE OW_WS_RECIPIENT 
    SET RECIPIENT_TYPE = P_RECIPIENT_TYPE,
        TK_EMPLOYEE = P_TK_EMPLOYEE
    WHERE TK_OW = p_TK_OW;
    COMMIT;  
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_UPDATE;



PROCEDURE OW_PUR_ORD_INSERT(
p_TK_OW                  NUMBER,
p_USER                   NUMBER,
p_VENDOR_ID              NUMBER,
p_INCOTERM               VARCHAR2,
p_SHIP_DATE              VARCHAR2,     
p_SUPPLIER_REF           VARCHAR2,
p_PURCHASE_PAYMENT_TERMS VARCHAR2, 
p_PURCHASE_DATE          DATE,
p_PURCHASER              NUMBER,
p_LOGISTICS_COORDINATOR  NUMBER,
p_DISCOUNT               NUMBER,
p_CURRENCY_CODE          VARCHAR2,  
p_EXCHANGE_RATE          NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
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
    
    INSERT INTO OW_PUR_ORD
    (
         TK_OW               
        ,VENDOR_ID           
        ,PURCHASE_TERMS_DESCR
        ,PICKUP_PERIOD_DESCR             
        ,VND_ORD_NUM             
        ,PAY_TERM_DESCR          
        ,PURCHASE_DATE           
        ,TK_EMP_TRADER           
        ,TK_EMP_TRF              
        ,DISCOUNT_RATE           
        ,CURRENCY_CODE           
        ,EXCHANGE_RATE    
        ,CONTACT       
    ) VALUES
    (
         p_TK_OW                 
        ,p_VENDOR_ID
        ,p_INCOTERM              
        ,p_SHIP_DATE         
        ,p_SUPPLIER_REF          
        ,p_PURCHASE_PAYMENT_TERMS
        ,p_PURCHASE_DATE         
        ,NVL(p_PURCHASER,p_USER)             
        ,p_LOGISTICS_COORDINATOR 
        ,p_DISCOUNT              
        ,p_CURRENCY_CODE         
        ,p_EXCHANGE_RATE  
        ,p_LOCATION_CONTACT           
    );          
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_PUR_ORD_INSERT;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_INSERT
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_COMMENTS_INSERT(
p_TK_OW                  NUMBER,
p_NOTIFY_COMMENTS        VARCHAR2,  
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS';
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
    
    INSERT INTO OW_WS_NOTIFY_COMMENTS (TK_OW, NOTIFY_COMMENTS ) VALUES
    (  p_TK_OW, NVL(p_NOTIFY_COMMENTS,' ')  );          
    -- COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_COMMENTS_INSERT;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMEN_PUB_INSERT
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_COMMEN_PUB_INSERT(
p_TK_OW                  NUMBER,
p_NOTIFY_COMMENTS        VARCHAR2,  
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMEN_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_PUB';
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
    
    INSERT INTO OW_WS_NOTIFY_COMMENTS_PUB (TK_OW, NOTIFY_COMMENTS ) VALUES
    (  p_TK_OW, NVL(p_NOTIFY_COMMENTS,' ')  );          
    -- COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_COMMEN_PUB_INSERT;


PROCEDURE OW_WS_NOTE_INSERT(
p_TK_OW             NUMBER, 
p_NOTE_SUPPLIER     VARCHAR2, 
p_NOTE_INTERNAL     VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE';
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
    
    IF p_NOTE_SUPPLIER IS NOT NULL THEN
        INSERT INTO OW_WS_NOTE (TK_OW, TYPE, NOTE) values (p_TK_OW, 'SUPPLIER', p_NOTE_SUPPLIER);    
    END IF;
    
    IF p_NOTE_INTERNAL IS NOT NULL THEN
        INSERT INTO OW_WS_NOTE (TK_OW, TYPE, NOTE) values (p_TK_OW, 'INTERNAL', p_NOTE_INTERNAL);    
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTE_INSERT;
PROCEDURE OW_PO_PRD_LINE_INSERT(
p_TK_OW           NUMBER,        
p_LINE_NUM        NUMBER,        
p_PUR_PRICE_CASE  NUMBER,
p_PUR_PRICE_WT    NUMBER,
p_PUR_PRICE_UOM   VARCHAR2,
p_CURRENCY_CODE   VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE';
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
    INSERT INTO OW_PO_PRD_LINE (TK_OW, LINE_NUM, PUR_PRICE_CASE, PUR_PRICE_WT, PUR_PRICE_UOM, CURRENCY_CODE) 
    values
    (p_TK_OW, p_LINE_NUM, p_PUR_PRICE_CASE, p_PUR_PRICE_WT, p_PUR_PRICE_UOM, p_CURRENCY_CODE);  
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);   
END OW_PO_PRD_LINE_INSERT;
PROCEDURE OW_WS_FOREX_INSERT(
p_TK_OW            NUMBER,         
p_BANK_DESCR       VARCHAR2,
p_EXCHANGE_RATE    NUMBER,
p_EXCHANGE_AMOUNT  NUMBER,
p_CONTRACT_NUMBER  VARCHAR2,
p_VALUATION_DATE   DATE,
pEXECUTION_ID       IN NUMBER default -1
) IS
    v_forex_total_value NUMBER;
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX';
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

    INSERT INTO OW_WS_FOREX(TK_OW, BANK_DESCR, EXCHANGE_RATE, EXCHANGE_AMOUNT, CONTRACT_NUMBER, VALUATION_DATE) 
    values
    (p_TK_OW, p_BANK_DESCR, NVL(p_EXCHANGE_RATE,1), NVL(p_EXCHANGE_AMOUNT,0), p_CONTRACT_NUMBER, p_VALUATION_DATE);
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END OW_WS_FOREX_INSERT;

PROCEDURE OW_CONTRACT_INSERT(
p_TK_OW  NUMBER,
p_TK_CONTRACT_ID NUMBER,
p_NAME VARCHAR2,   
p_STATUS VARCHAR2,
p_OWNER NUMBER,
p_LAST_PUBLISHED_DATE DATE,   
p_CREATION_DATE DATE, 
p_CREATED_BY NUMBER, 
p_ODS VARCHAR2,
pEXECUTION_ID       IN NUMBER default -1
) IS

  n_NEW_EXECUTION_ID      NUMBER;
  v_starttime             TIMESTAMP;
  v_proc                  VARCHAR2(100)   := 'OW_CONTRACT_INSERT';
  v_table                 VARCHAR2(100)   := 'INSERT workdesk.ow_contract'; 
 

BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    INSERT INTO workdesk.ow_contract (tk_contract  ,name    ,template_tk_ow, status,   OWNER,   last_published_date, CREATION_DATE, CREATED_BY, last_update_date, last_updated_by, ods, NEW_OW) 
    VALUES   (p_TK_CONTRACT_ID, p_NAME,p_TK_OW , p_STATUS, p_OWNER, NULL, SYSDATE, p_OWNER, SYSDATE, p_OWNER ,'N', 'Y');


EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);     
END OW_CONTRACT_INSERT;

PROCEDURE OW_WORKSHEET_INSERT_CONTRACT(
p_TK_OW NUMBER,
p_TK_CONTRACT_ID NUMBER,
p_NAME VARCHAR2,   
p_STATUS VARCHAR2,
p_OWNER NUMBER,
p_TYPE VARCHAR2,
p_LAST_PUBLISHED_DATE DATE,   
p_CREATION_DATE DATE, 
p_CREATED_BY NUMBER, 
p_ODS VARCHAR2,
p_DESCRIPTION VARCHAR2,
p_CO_TK_ORG NUMBER,
p_ORIG_TK_CNTRY NUMBER,
p_DEST_PORT NUMBER,
pEXECUTION_ID       IN NUMBER default -1
)  IS

    n_NEW_EXECUTION_ID  NUMBER;
    v_notify_subject    VARCHAR2(1000)  := NULL;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_INSERT_CONTRACT';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_set_wrksht_num    NUMBER := NULL;
    v_tk_ow             NUMBER := NULL;
    v_init_tk_ow        NUMBER := NULL;  

--    v_DESCRIPTION       VARCHAR2(100);    
BEGIN 

NULL;
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
      INTO v_set_wrksht_num
      FROM DUAL;
       
--        v_DESCRIPTION := APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(v_set_wrksht_num);
    
    
    --Insert into Worksheet Table
    INSERT INTO OW_WORKSHEET (
         TK_OW                   
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM              
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE           
        ,CREATED_BY             
        ,INIT_TK_OW              
        ,OWNER             
        ,DEST_PORT         
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,ORIG_TK_CNTRY
        ,PROVINCE
        ,NEW_OW
    )
    values
    (
         p_TK_OW 
        ,p_TYPE             
        ,p_DESCRIPTION 
        ,v_set_wrksht_num       
        ,1          
        ,p_STATUS               
        ,''        
        ,''        
        ,''                
        ,NVL(p_CO_TK_ORG,3)           
        ,'USD'        
        ,'LB'  
        ,SYSDATE             
        ,p_CREATED_BY 
        ,p_TK_OW          
        ,p_OWNER                
        ,p_DEST_PORT           
        ,v_notify_subject       
        ,p_ODS                  
        ,'N'    
        ,'UNPOSITIONED' 
        ,p_ORIG_TK_CNTRY    
        ,0
        ,'Y'
        );

     COMMIT; 
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WORKSHEET_INSERT_CONTRACT;

PROCEDURE OW_CONT_WORKSHEET_INSERT(
P_NEW_TK_OW          NUMBER,
P_NEW_TK_CONTRACT_ID NUMBER,
P_OWNER              NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_CONT_WORKSHEET_INSERT';
    v_table             VARCHAR2(100)   := 'OW_CONTRACT_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_desc              varchar2(100)   :=NULL;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    INSERT INTO ow_contract_worksheet (tk_contract,tk_ow,creation_date,created_by, last_update_date, last_updated_by,init_tk_ow)
      VALUES (P_NEW_TK_CONTRACT_ID,P_NEW_TK_OW, SYSDATE,P_OWNER, NULL, NULL,P_NEW_TK_OW);

    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN   

        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_CONT_WORKSHEET_INSERT;

PROCEDURE OW_CONTRACT_COPY_INSERT(
P_TK_ORI_CONTRACT    NUMBER, 
P_NEW_TK_OW          NUMBER,
P_NEW_TK_CONTRACT_ID NUMBER,
P_OWNER              NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_CONTRACT_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_CONTRACT';
    v_starttime         TIMESTAMP;
    v_desc              varchar2(100)   :=NULL;
    v_desc_new          varchar2(300)   :=NULL;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    SELECT DESCRIPTION
    INTO   v_desc_new
    FROM OW_WORKSHEET
    WHERE TK_OW = P_NEW_TK_OW;
    
    INSERT INTO workdesk.ow_contract(TK_CONTRACT,NAME,TEMPLATE_TK_OW,STATUS,LAST_PUBLISHED_DATE,OWNER,CREATION_DATE,CREATED_BY,LAST_UPDATE_DATE,LAST_UPDATED_BY,ODS,NEW_OW) 
    SELECT P_NEW_TK_CONTRACT_ID ,v_desc_new, P_NEW_TK_OW ,'UNPUBLISHED', NULL ,P_OWNER, SYSDATE ,P_OWNER,NULL,NULL,ODS ,'Y'
    FROM   workdesk.ow_contract
    WHERE  tk_contract = P_TK_ORI_CONTRACT;

    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN   

        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_CONTRACT_COPY_INSERT;

PROCEDURE OW_WORKSHEET_COPY_INSERT(
p_TK_OW             NUMBER, 
p_Type              VARCHAR2,
P_NEW_TK_OW         NUMBER,
p_NEW_WORKSHEET_NUM NUMBER,
p_TK_EMPLOYEE       NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_desc_ori          varchar2(300)   :=NULL;
    v_desc_set          varchar2(300)   :=NULL;
    v_desc_new          varchar2(300)   :=NULL;
    v_orig_tk_cntry     NUMBER;
    v_notify_sub_set    varchar2(300)   :=NULL;
    v_notify_sub_old    varchar2(300)   :=NULL;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT DESCRIPTION,
           APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(SET_WRKSHT_NUM),
           APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(p_NEW_WORKSHEET_NUM),
           GET_ORIG_TK_CNTRY(p_TK_OW),
           APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM),
           NVL(NOTIFY_SUBJECT,APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM))
    INTO   v_desc_ori,
           v_desc_set,
           v_desc_new,
           v_orig_tk_cntry,
           v_notify_sub_set,
           v_notify_sub_old
    FROM OW_WORKSHEET
    WHERE TK_OW = p_TK_OW;
    WORKDESK.interal_log_error('copy w',SYSDATE,1,v_desc_ori);
    WORKDESK.interal_log_error('copy w',SYSDATE,1,v_desc_set);
    IF v_desc_ori <> v_desc_set THEN
      v_desc_new := v_desc_ori;
    END IF;
    
    IF v_notify_sub_old = v_notify_sub_set THEN
      v_notify_sub_old := NULL;
    END IF;    
    
    INSERT INTO OW_WORKSHEET
    (
        TK_OW             
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM       
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE     
        ,CREATED_BY        
        ,LAST_UPDATE_DATE  
        ,LAST_UPDATED_BY   
        ,INIT_TK_OW        
        ,OWNER             
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,ORIG_TK_CNTRY
        ,NEW_OW
        ,TK_SUP_OFFER
    )
    SELECT 
        P_NEW_TK_OW             
        ,p_Type              
        ,v_desc_new       
        ,p_NEW_WORKSHEET_NUM    
        ,1       
        ,'UNPUBLISHED'            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,SYSDATE     
        ,CREATED_BY        
        ,NULL  
        ,NULL   
        ,INIT_TK_OW        
        ,p_TK_EMPLOYEE             
        ,NVL(v_notify_sub_old,APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(p_NEW_WORKSHEET_NUM, 1))
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,v_orig_tk_cntry
        ,'Y'
        ,TK_SUP_OFFER
    FROM OW_WORKSHEET
    WHERE TK_OW = p_TK_OW; 

    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN   

        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WORKSHEET_COPY_INSERT;

PROCEDURE OW_WS_NOTE_COPY_INSERT(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE';
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

    INSERT INTO OW_WS_NOTE
    (
         TK_OW
        ,TYPE
        ,NOTE                
    )
    SELECT 
         P_NEW_TK_OW
        ,TYPE
        ,NOTE 
    FROM OW_WS_NOTE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;     
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_NOTE_COPY_INSERT;

PROCEDURE OW_WS_FOREX_COPY_INSERT(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX';
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
    
    INSERT INTO OW_WS_FOREX
    (
         TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE                
    )
    SELECT 
         P_NEW_TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE   
    FROM OW_WS_FOREX
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_FOREX_COPY_INSERT;

PROCEDURE OW_PUR_ORD_COPY_INSERT(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
    v_starttime         TIMESTAMP;
    V_PAYMENT  VARCHAR2(100);
    V_NEW_SET_WRKSHT_NUM OW_WORKSHEET.SET_WRKSHT_NUM%TYPE;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT SET_WRKSHT_NUM
      INTO V_NEW_SET_WRKSHT_NUM
      FROM OW_WORKSHEET
     WHERE TK_OW = P_NEW_TK_OW;
    
    SELECT PAY_TERM_DESCR                
     INTO V_PAYMENT   
    FROM OW_PUR_ORD
    WHERE TK_OW = p_TK_OW; 
    
    INSERT INTO OW_PUR_ORD
    (
         TK_OW                        
        ,VENDOR_ID                     
        ,PURCHASE_TERMS_DESCR          
        ,PICKUP_PERIOD_DESCR           
        ,CONTACT                       
        ,VND_ORD_NUM                   
        ,PAY_TERM_DESCR                
        ,PURCHASE_DATE                 
        ,TK_EMP_TRADER                 
        ,TK_EMP_TRF                    
        ,DISCOUNT_RATE                 
        ,CURRENCY_CODE                 
        ,EXCHANGE_RATE                 
    )
    SELECT 
         P_NEW_TK_OW                        
        ,ORD.VENDOR_ID                     
        ,ORD.PURCHASE_TERMS_DESCR          
        ,ORD.PICKUP_PERIOD_DESCR           
        ,ORD.CONTACT                       
        ,ORD.VND_ORD_NUM                   
        ,ORD.PAY_TERM_DESCR                
        ,CASE WHEN W.SET_WRKSHT_NUM = V_NEW_SET_WRKSHT_NUM 
            THEN ORD.PURCHASE_DATE 
            ELSE TRUNC(SYSDATE) 
         END                
        ,ORD.TK_EMP_TRADER                 
        ,ORD.TK_EMP_TRF                    
        ,ORD.DISCOUNT_RATE                 
        ,ORD.CURRENCY_CODE                 
        ,ORD.EXCHANGE_RATE 
    FROM OW_PUR_ORD ORD JOIN OW_WORKSHEET W ON W.TK_OW = ORD.TK_OW
    WHERE ORD.TK_OW = p_TK_OW; 
    COMMIT;      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PUR_ORD_COPY_INSERT;
 

PROCEDURE OW_PO_PRD_LINE_COPY_INSERT(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
p_NEW_OW        VARCHAR2 DEFAULT 'Y',
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE';
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
    
    INSERT INTO OW_PO_PRD_LINE
    (
        TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,PER
        ,SUP_DESC_FLAG
        ,CREATED_DATE
        ,CREATED_BY 
        ,PACKAGING             
    )
    SELECT 
         P_NEW_TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,PER
        ,CASE WHEN p_NEW_OW IS NULL THEN 'Y' ELSE NULL END -- WORKSHEETS GENERATED IN THE OLD SYSTEM WILL ALWAYS HAVE THIS FLAG IN YES SINCE THERE IS NO TK_PRD
        ,SYSDATE
        ,CREATED_BY
        ,PACKAGING
    FROM OW_PO_PRD_LINE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_PRD_LINE_COPY_INSERT;

PROCEDURE OW_PO_WS_LINE_COPY_INSERT(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_WS_LINE_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_PRD_LINE';
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
    
    INSERT INTO OW_WS_PRD_LINE
    (
        TK_OW, 
        LINE_NUM,
        CASES,
        WEIGHT,
        WT_UOM,
        SELL_DESCR,
        PUR_DESCR,
        PROPRIETARY,
        TK_SUP_OFFERLN         
    )
    SELECT 
         P_NEW_TK_OW,
         LINE_NUM,
         CASES,
         WEIGHT,
         WT_UOM,
         SELL_DESCR,
         PUR_DESCR,
         PROPRIETARY ,
         TK_SUP_OFFERLN 
    FROM OW_WS_PRD_LINE
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_WS_LINE_COPY_INSERT;

PROCEDURE OW_PO_PRD_PLANTS_COPY_INSERT(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_PLANTS_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_PLANTS';
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
    
    INSERT INTO OW_PO_PRD_PLANTS
    (
        TK_OW
        ,LINE_NUM
        ,TK_PRD_PLANT         
    )
    SELECT 
        P_NEW_TK_OW
        ,LINE_NUM
        ,TK_PRD_PLANT
    FROM OW_PO_PRD_PLANTS
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_PRD_PLANTS_COPY_INSERT;

--

PROCEDURE OW_WORKSHEET_COPY_INSERT_PUB(
p_TK_OW             NUMBER, 
p_Type              VARCHAR2,
P_NEW_TK_OW         NUMBER,
p_NEW_WORKSHEET_NUM NUMBER,
p_TK_EMPLOYEE       NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_desc_ori          varchar2(300)   :=NULL;
    v_desc_set          varchar2(300)   :=NULL;
    v_desc_new          varchar2(300)   :=NULL;
    v_orig_tk_cntry  NUMBER;
    v_notify_sub_set    varchar2(300)   :=NULL;
    v_notify_sub_old    varchar2(300)   :=NULL;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT DESCRIPTION,
           APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(SET_WRKSHT_NUM),
           APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(p_NEW_WORKSHEET_NUM),
           GET_ORIG_TK_CNTRY(p_TK_OW),
           APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM),
           NVL(NOTIFY_SUBJECT,APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(SET_WRKSHT_NUM, VERSION_NUM))
    INTO   v_desc_ori,
           v_desc_set,
           v_desc_new,
           v_orig_tk_cntry,
           v_notify_sub_set,
           v_notify_sub_old
    FROM OW_WORKSHEET
    WHERE TK_OW = p_TK_OW;
    
    IF v_desc_ori <> v_desc_set THEN
      v_desc_new := v_desc_ori;
    END IF; 
    
    IF v_notify_sub_old = v_notify_sub_set THEN
      v_notify_sub_old := NULL;
    END IF;
    
    INSERT INTO OW_WORKSHEET
    (
        TK_OW             
        ,TYPE              
        ,DESCRIPTION       
        ,SET_WRKSHT_NUM    
        ,VERSION_NUM       
        ,STATUS            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,CREATION_DATE     
        ,CREATED_BY        
        ,LAST_UPDATE_DATE  
        ,LAST_UPDATED_BY   
        ,INIT_TK_OW        
        ,OWNER             
        ,NOTIFY_SUBJECT    
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,ORIG_TK_CNTRY
        ,NEW_OW
    )
    SELECT 
        P_NEW_TK_OW             
        ,p_Type              
        ,v_desc_new       
        ,p_NEW_WORKSHEET_NUM    
        ,1       
        ,'UNPUBLISHED'            
        ,DEST_TK_CNTRY     
        ,INSP_TK_CNTRY     
        ,PLANT             
        ,CO_TK_ORG         
        ,CURRENCY_CODE     
        ,WT_UOM            
        ,SYSDATE     
        ,CREATED_BY        
        ,NULL  
        ,NULL   
        ,INIT_TK_OW        
        ,p_TK_EMPLOYEE             
        ,NVL(v_notify_sub_old,APX_WOKDSK_PO_TOOLKIT.PO_SET_NOTIFY_SUBJECT(p_NEW_WORKSHEET_NUM, 1))    
        ,ODS               
        ,DEST_PORT         
        ,POSITION_PURCHASE 
        ,PURCHASE_DECISION 
        ,PROVINCE
        ,v_orig_tk_cntry
        ,'Y'
    FROM OW_WORKSHEET_PUB
    WHERE TK_OW = p_TK_OW; 

    COMMIT;  
EXCEPTION
    WHEN OTHERS THEN   

        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WORKSHEET_COPY_INSERT_PUB;

PROCEDURE OW_WS_NOTE_COPY_INSERT_PUB(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTE_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTE';
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

    INSERT INTO OW_WS_NOTE
    (
         TK_OW
        ,TYPE
        ,NOTE                
    )
    SELECT 
         P_NEW_TK_OW
        ,TYPE
        ,NOTE 
    FROM OW_WS_NOTE_PUB
    WHERE TK_OW = p_TK_OW; 
    COMMIT;     
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_NOTE_COPY_INSERT_PUB;

PROCEDURE OW_WS_FOREX_COPY_INSERT_PUB(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_FOREX_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_WS_FOREX';
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
    
    INSERT INTO OW_WS_FOREX
    (
         TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE                
    )
    SELECT 
         P_NEW_TK_OW
        ,BANK_DESCR
        ,EXCHANGE_RATE
        ,EXCHANGE_AMOUNT
        ,CONTRACT_NUMBER
        ,VALUATION_DATE   
    FROM OW_WS_FOREX_PUB
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_WS_FOREX_COPY_INSERT_PUB;

PROCEDURE OW_PUR_ORD_COPY_INSERT_PUB(
p_TK_OW         NUMBER, 
P_NEW_TK_OW     NUMBER,
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PUR_ORD_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
    v_starttime         TIMESTAMP;
    V_NEW_SET_WRKSHT_NUM OW_WORKSHEET.SET_WRKSHT_NUM%TYPE;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
     SELECT SET_WRKSHT_NUM
      INTO V_NEW_SET_WRKSHT_NUM
      FROM OW_WORKSHEET
     WHERE TK_OW = P_NEW_TK_OW;
    
    INSERT INTO OW_PUR_ORD
    (
         TK_OW                        
        ,VENDOR_ID                     
        ,PURCHASE_TERMS_DESCR          
        ,PICKUP_PERIOD_DESCR           
        ,CONTACT                       
        ,VND_ORD_NUM                   
        ,PAY_TERM_DESCR                
        ,PURCHASE_DATE                 
        ,TK_EMP_TRADER                 
        ,TK_EMP_TRF                    
        ,DISCOUNT_RATE                 
        ,CURRENCY_CODE                 
        ,EXCHANGE_RATE                 
    )
    SELECT 
         P_NEW_TK_OW                        
        ,ORD.VENDOR_ID                     
        ,ORD.PURCHASE_TERMS_DESCR          
        ,ORD.PICKUP_PERIOD_DESCR           
        ,ORD.CONTACT                       
        ,ORD.VND_ORD_NUM                   
        ,ORD.PAY_TERM_DESCR                
        ,CASE WHEN W.SET_WRKSHT_NUM = V_NEW_SET_WRKSHT_NUM 
            THEN ORD.PURCHASE_DATE 
            ELSE TRUNC(SYSDATE) 
         END                
        ,ORD.TK_EMP_TRADER                 
        ,ORD.TK_EMP_TRF                    
        ,ORD.DISCOUNT_RATE                 
        ,ORD.CURRENCY_CODE                 
        ,ORD.EXCHANGE_RATE 
    FROM OW_PUR_ORD_PUB ORD JOIN OW_WORKSHEET_PUB W ON W.TK_OW = ORD.TK_OW
    WHERE ORD.TK_OW = p_TK_OW;  
    COMMIT;      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PUR_ORD_COPY_INSERT_PUB;
 

PROCEDURE OW_PO_PRD_LINE_COPY_INSERT_PUB(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_LINE_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_LINE';
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
    
    INSERT INTO OW_PO_PRD_LINE
    (
        TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,CREATED_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_BY
        ,PER
        ,PACKAGING
        ,PRD_BUY_DESCR
        ,SUP_DESC_FLAG
    )
    SELECT 
         P_NEW_TK_OW
        ,LINE_NUM
        ,PUR_PRICE_CASE
        ,PUR_PRICE_WT
        ,PUR_PRICE_UOM
        ,CURRENCY_CODE
        ,TK_PRD
        ,SYSDATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_BY
        ,PER
        ,PACKAGING
        ,PRD_BUY_DESCR
        ,SUP_DESC_FLAG
    FROM OW_PO_PRD_LINE_PUB
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_PRD_LINE_COPY_INSERT_PUB;

PROCEDURE OW_PO_WS_LINE_COPY_INSERT_PUB(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_WS_LINE_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_WS_PRD_LINE';
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
    
    INSERT INTO OW_WS_PRD_LINE
    (
        TK_OW, 
        LINE_NUM,
        CASES,
        WEIGHT,
        WT_UOM,
        SELL_DESCR,
        PUR_DESCR,
        PROPRIETARY         
    )
    SELECT 
         P_NEW_TK_OW,
         LINE_NUM,
         CASES,
         WEIGHT,
         WT_UOM,
         SELL_DESCR,
         PUR_DESCR,
         PROPRIETARY  
    FROM OW_WS_PRD_LINE_PUB
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_WS_LINE_COPY_INSERT_PUB;

PROCEDURE OW_PO_PLANTS_COPY_INSERT_PUB(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PLANTS_COPY_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_PLANTS';
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
    
    INSERT INTO OW_PO_PRD_PLANTS
    (
        TK_OW
        ,LINE_NUM
        ,TK_PRD_PLANT         
    )
    SELECT 
        P_NEW_TK_OW
        ,LINE_NUM
        ,TK_PRD_PLANT
    FROM OW_PO_PRD_PLANTS
    WHERE TK_OW = p_TK_OW; 
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);    
END OW_PO_PLANTS_COPY_INSERT_PUB;

/* Misc Charges Procedures */

PROCEDURE OW_WS_MISC_CHARGES_INSERT(
p_TK_OW             NUMBER,  
p_LINE_NUM          NUMBER,       
p_CHARGES           VARCHAR2,
p_TK_CHG_TYPE       NUMBER,
p_COST              NUMBER,
p_CURRENCY          VARCHAR2,
p_PER               VARCHAR2,
p_TOTAL             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MISC_CHARGES_INSERT';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    INSERT INTO OW_MISC_CHARGES (TK_OW, 
                                 LINE_NUM, 
                                 CHARGES, 
                                 TK_CHG_TYPE, 
                                 COST, 
                                 CURRENCY, 
                                 PER,
                                 TOTAL) 
    VALUES
    (p_TK_OW, 
     p_LINE_NUM, 
     p_CHARGES, 
     p_TK_CHG_TYPE, 
     p_COST, 
     p_CURRENCY, 
     p_PER,
     p_TOTAL);  
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MISC_CHARGES_INSERT; 

PROCEDURE OW_MISC_CHARGES_DELETE(
p_MISC_CHARGE_ID    NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS  
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_MISC_CHARGES_DELETE';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    
    DELETE OW_MISC_CHARGES 
     WHERE MISC_CHARGE_ID = p_MISC_CHARGE_ID;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_MISC_CHARGES_DELETE;   

PROCEDURE OW_WS_MISC_CHARGES_DELETE(
p_TK_OW             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS  
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MISC_CHARGES_DELETE';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    
    DELETE OW_MISC_CHARGES 
     WHERE TK_OW = p_TK_OW;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MISC_CHARGES_DELETE;     

PROCEDURE OW_WS_MISC_CHARGES_UPDATE(
    p_MISC_CHARGE_ID    NUMBER,         
    p_LINE_NUM          NUMBER,       
    p_CHARGES           VARCHAR2,
    p_TK_CHG_TYPE       NUMBER,
    p_COST              NUMBER,
    p_CURRENCY          VARCHAR2,
    p_PER               VARCHAR2,
    p_TOTAL             NUMBER,
    pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MISC_CHARGES_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    
    UPDATE OW_MISC_CHARGES
        SET LINE_NUM = p_LINE_NUM,
            CHARGES = p_CHARGES,
            TK_CHG_TYPE = p_TK_CHG_TYPE,
            COST = p_COST,
            CURRENCY = p_CURRENCY,
            PER = p_PER,
            TOTAL = p_TOTAL
     WHERE MISC_CHARGE_ID = P_MISC_CHARGE_ID; 
     
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MISC_CHARGES_UPDATE;   

PROCEDURE OW_WS_MSC_CHRG_COPY_INS(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MSC_CHRG_COPY_INS';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    INSERT INTO OW_MISC_CHARGES
    (TK_OW,
     LINE_NUM,
     CHARGES,
     TK_CHG_TYPE,
     COST,
     CURRENCY,
     PER,
     TOTAL)
     SELECT P_NEW_TK_OW,
            LINE_NUM,
            CHARGES,
            TK_CHG_TYPE,
            COST,
            CURRENCY,
            PER,
            TOTAL
       FROM OW_MISC_CHARGES
      WHERE TK_OW = p_TK_OW;
      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MSC_CHRG_COPY_INS; 

PROCEDURE OW_WS_MSC_CHRG_COPY_INS_PUB(
p_TK_OW         NUMBER,
P_NEW_TK_OW     NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MSC_CHRG_COPY_INS_PUB';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
    v_starttime         TIMESTAMP;    
BEGIN
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    INSERT INTO OW_MISC_CHARGES
    (TK_OW,
     LINE_NUM,
     CHARGES,
     TK_CHG_TYPE,
     COST,
     CURRENCY,
     PER,
     TOTAL)
     SELECT P_NEW_TK_OW,
            LINE_NUM,
            CHARGES,
            TK_CHG_TYPE,
            COST,
            CURRENCY,
            PER,
            TOTAL
       FROM OW_MISC_CHARGES_PUB
      WHERE TK_OW = p_TK_OW;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MSC_CHRG_COPY_INS_PUB; 

PROCEDURE OW_WS_MSC_CHRG_PUB_INSERT(
p_TK_OW         NUMBER, 
pEXECUTION_ID   IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MSC_CHRG_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    
    INSERT INTO OW_MISC_CHARGES_PUB
    (TK_OW,
     LINE_NUM,
     CHARGES,
     TK_CHG_TYPE,
     COST,
     CURRENCY,
     PER,
     TOTAL)
     SELECT TK_OW,
            LINE_NUM,
            CHARGES,
            TK_CHG_TYPE,
            COST,
            CURRENCY,
            PER,
            TOTAL
       FROM OW_MISC_CHARGES
      WHERE TK_OW = p_TK_OW;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MSC_CHRG_PUB_INSERT;

PROCEDURE OW_WS_MSC_CHRG_PUB_DELETE(p_a_worksheet arrayofWorksheets, 
                                    pEXECUTION_ID IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_MSC_CHRG_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_MISC_CHARGES';
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
    
    DELETE OW_MISC_CHARGES_PUB WHERE TK_OW MEMBER OF p_a_worksheet;
        
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_MSC_CHRG_PUB_DELETE;

PROCEDURE OW_WS_RECIPIENT_INSERT(
p_TK_OW           NUMBER,
p_RECIPIENT_TYPE  VARCHAR2,
p_TK_EMPLOYEE     NUMBER, 
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT';
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
    
    INSERT INTO OW_WS_RECIPIENT(TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE)
    VALUES(p_TK_OW, p_RECIPIENT_TYPE, p_TK_EMPLOYEE);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_INSERT;


/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_COPY_INSERT
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_COMM_COPY_INSERT(
p_TK_OW           NUMBER,
p_NEW_TK_OW       NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMM_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS';
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
    
    INSERT INTO OW_WS_NOTIFY_COMMENTS (TK_OW, NOTIFY_COMMENTS) 
    SELECT p_NEW_TK_OW, NOTIFY_COMMENTS FROM OW_WS_NOTIFY_COMMENTS WHERE  TK_OW = p_TK_OW;   
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_COMM_COPY_INSERT;

PROCEDURE OW_WS_NOTIFY_C_PUB_INSERT(
p_TK_OW           NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_C_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_PUB';
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
    
    INSERT INTO OW_WS_NOTIFY_COMMENTS_PUB (TK_OW, NOTIFY_COMMENTS) 
    SELECT TK_OW, NOTIFY_COMMENTS FROM OW_WS_NOTIFY_COMMENTS WHERE  TK_OW = p_TK_OW;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_C_PUB_INSERT;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_PUB_COPY_INSERT
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_C_PUB_COPY_INSERT(
p_TK_OW           NUMBER,
p_NEW_TK_OW       NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_C_PUB_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS';
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
    
    INSERT INTO OW_WS_NOTIFY_COMMENTS (TK_OW, NOTIFY_COMMENTS) 
    SELECT p_NEW_TK_OW, NOTIFY_COMMENTS FROM OW_WS_NOTIFY_COMMENTS_PUB WHERE  TK_OW = p_TK_OW;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_NOTIFY_C_PUB_COPY_INSERT;


PROCEDURE OW_WS_RECIPIENT_COPY_INSERT(
p_TK_OW           NUMBER,
p_NEW_TK_OW       NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT';
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
    
    INSERT INTO OW_WS_RECIPIENT(TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE)
    SELECT p_NEW_TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE
    FROM   OW_WS_RECIPIENT
    WHERE  TK_OW = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_COPY_INSERT;

PROCEDURE OW_WS_RECIP_PUB_INSERT(
p_TK_OW           NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIP_PUB_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT_PUB';
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
    
    INSERT INTO OW_WS_RECIPIENT_PUB(TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE)
    SELECT TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE
    FROM   OW_WS_RECIPIENT
    WHERE  TK_OW = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIP_PUB_INSERT;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_DELETE
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_COMMENTS_DELETE( 
p_TK_OW             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS';
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
    DELETE FROM OW_WS_NOTIFY_COMMENTS WHERE TK_OW = p_TK_OW; 

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_NOTIFY_COMMENTS_DELETE;

/***************************************************************
*
*  OW_WS_NOTIFY_COMMENTS_PUB_DELETE
*
*  Last Modify 09/02/2021   Pablo Flores 
*
*/ 
PROCEDURE OW_WS_NOTIFY_COMMEN_PUB_DELETE( 
p_TK_OW             NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMEN_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_NOTIFY_COMMENTS_PUB';
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
    DELETE FROM OW_WS_NOTIFY_COMMENTS_PUB WHERE TK_OW = p_TK_OW; 

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_WS_NOTIFY_COMMEN_PUB_DELETE;

PROCEDURE OW_WS_RECIPIENT_DELETE(p_a_worksheet arrayofWorksheets,
                                 pEXECUTION_ID  IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT';
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
    
    DELETE OW_WS_RECIPIENT WHERE TK_OW MEMBER OF p_a_worksheet;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_DELETE;

PROCEDURE OW_WS_RECIPIENT_INSERT_PUB(
p_TK_OW           NUMBER,
p_RECIPIENT_TYPE  VARCHAR2,
p_TK_EMPLOYEE     NUMBER, 
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_INSERT_PUB';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT_PUB';
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
    
    INSERT INTO OW_WS_RECIPIENT_PUB(TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE)
    VALUES(p_TK_OW, p_RECIPIENT_TYPE, p_TK_EMPLOYEE);
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_INSERT_PUB;

PROCEDURE OW_WS_RECIP_PUB_COPY_INSERT(
p_TK_OW           NUMBER,
p_NEW_TK_OW       NUMBER,
pEXECUTION_ID  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIP_PUB_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT_PUB';
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
    
    INSERT INTO OW_WS_RECIPIENT(TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE)
    SELECT p_NEW_TK_OW, RECIPIENT_TYPE, TK_EMPLOYEE
    FROM   OW_WS_RECIPIENT_PUB
    WHERE  TK_OW = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIP_PUB_COPY_INSERT;

PROCEDURE OW_WS_RECIPIENT_PUB_DELETE(p_a_worksheet arrayofWorksheets,
                                 pEXECUTION_ID  IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_RECIPIENT_PUB_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_RECIPIENT_PUB';
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
    
    DELETE OW_WS_RECIPIENT_PUB WHERE TK_OW MEMBER OF p_a_worksheet;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_RECIPIENT_PUB_DELETE;

PROCEDURE OW_EMPLOYEE_WS_LIST_DELETE(p_TK_OW NUMBER,
                                     pEXECUTION_ID  IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_EMPLOYEE_WS_LIST_DELETE';
    v_table             VARCHAR2(100)   := 'OW_EMPLOYEE_WS_LIST';
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
    
    delete OW_EMPLOYEE_WS_LIST where tk_ow = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_EMPLOYEE_WS_LIST_DELETE;

PROCEDURE OW_WS_ACCRUAL_DELETE(p_TK_OW NUMBER,
                               pEXECUTION_ID  IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_ACCRUAL_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_ACCRUAL';
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
    
    delete OW_WS_ACCRUAL where tk_ow = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_ACCRUAL_DELETE;

PROCEDURE OW_WS_LC_DELETE(p_TK_OW NUMBER,
                          pEXECUTION_ID  IN NUMBER default -1) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_WS_LC_DELETE';
    v_table             VARCHAR2(100)   := 'OW_WS_LC';
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
    
    delete OW_WS_LC where tk_ow = p_TK_OW;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WS_LC_DELETE;

FUNCTION GET_ORIG_TK_CNTRY(
p_TK_OW             IN NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) RETURN NUMBER AS

  n_NEW_EXECUTION_ID  NUMBER;
  v_proc              VARCHAR2(100)   := 'GET_ORIG_TK_CNTRY';
  v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
  v_starttime         TIMESTAMP;
  v_orig_tk_cntry     NUMBER := NULL;
  v_province          NUMBER := NULL;
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
    SELECT w.orig_tk_cntry,
           w.province
    INTO   v_orig_tk_cntry,
           v_province
    from   OW_worksheet w
    WHERE  w.tk_ow = p_TK_OW;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v_orig_tk_cntry := NULL;
  END;

  IF v_orig_tk_cntry IS NULL and v_province IS NOT NULL THEN
    BEGIN
      SELECT p.tk_cntry
      INTO   v_orig_tk_cntry
      from   province p
      WHERE p.tk_province = v_province;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_orig_tk_cntry := NULL;
    END;
  END IF;
    
  RETURN v_orig_tk_cntry;

EXCEPTION
  WHEN OTHERS THEN    
    OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, 'WORKDESK.APX_WOKDSK_PO_TOOLKIT', v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
    OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || 'WORKDESK.APX_WOKDSK_PO_TOOLKIT'); 
END GET_ORIG_TK_CNTRY;

END APX_WOKDSK_PO_DML;
/


GRANT EXECUTE ON WORKDESK.APX_WOKDSK_PO_DML TO OMS;
