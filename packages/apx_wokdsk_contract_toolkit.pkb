DROP PACKAGE BODY WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT;

CREATE OR REPLACE PACKAGE BODY WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT AS

CONST_PACKAGE_NAME CONSTANT VARCHAR2(100) := 'APX_WOKDSK_CONTRACT_TOOLKIT';

PROCEDURE OW_CREATE_CONTRACT(
p_NAME               VARCHAR2,   
p_OWNER              NUMBER,
p_AMOUNT             NUMBER,
p_NEW_TK_OW          OUT NUMBER, -- TK - RELATION WITH OW_WORKSEET TABLE
p_NEW_TK_CONTRACT_ID OUT NUMBER,
p_SUPPLIER           NUMBER,
p_DESCRIPTION        VARCHAR2,
p_EXECUTION_ID       IN NUMBER default -1
)is
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_CREATE_CONTRACT';
    v_table             VARCHAR2(100)   := 'OW_CONTRACT';
    v_starttime         TIMESTAMP;

    v_TK_OW          NUMBER;
    v_TK_CONTRACT_ID NUMBER;
    
    V_PURCHASER      OW_PUR_ORD.TK_EMP_TRADER%TYPE;
    V_INCOTERM       OW_PUR_ORD.PURCHASE_TERMS_DESCR%TYPE;
    V_CO_TK_ORG      OW_WORKSHEET.CO_TK_ORG%TYPE;
    V_LOGISTICS_COORDINATOR OW_PUR_ORD.TK_EMP_TRADER%TYPE;
    V_CURRENCY_CODE  OW_PUR_ORD.CURRENCY_CODE%TYPE;
    V_PURCHASE_PAYMENT_TERMS OW_PUR_ORD.PURCHASE_TERMS_DESCR%TYPE;
    V_ORIGIN_COUNTRY OW_WORKSHEET.ORIG_TK_CNTRY%TYPE;
    V_DEST_PORT OW_WORKSHEET.DEST_PORT%TYPE;

BEGIN
    --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    --Generate tk_ow 
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
    into v_TK_OW
    FROM DUAL; 
    
    p_NEW_TK_OW :=  v_TK_OW;

    --Generate tk_contract_id 
    SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL" 
    into v_TK_CONTRACT_ID
    FROM DUAL;    
 
    p_NEW_TK_CONTRACT_ID := v_TK_CONTRACT_ID;
    
    -- get last PO published data
     WORKDESK.APX_WOKDSK_PO_TOOLKIT.GET_LAST_PUBLISHED_PO_DATA(
        p_VENDOR_ID              => p_SUPPLIER, 
        p_TK_USER                => p_OWNER,
        p_PURCHASER              => V_PURCHASER, 
        p_INCOTERM               => V_INCOTERM, 
        p_CO_TK_ORG              => V_CO_TK_ORG,
        p_LOGISTICS_COORDINATOR  => V_LOGISTICS_COORDINATOR,
        p_PURCHASE_PAYMENT_TERMS => V_PURCHASE_PAYMENT_TERMS,
        p_CURRENCY_CODE          => V_CURRENCY_CODE,
        p_ORIGIN_COUNTRY         => V_ORIGIN_COUNTRY,
        p_DEST_PORT              => V_DEST_PORT);
 
    --Create the contract inside ow_worksheet
 
    APX_WOKDSK_PO_DML.OW_WORKSHEET_INSERT_CONTRACT(p_TK_OW               => v_TK_OW,
                                                   p_TK_CONTRACT_ID      => v_TK_CONTRACT_ID,
                                                   p_NAME                => p_NAME,   
                                                   p_STATUS              => 'UNPUBLISHED',
                                                   p_OWNER               => p_OWNER,
                                                   p_TYPE                => 'TEMPLATE',
                                                   p_LAST_PUBLISHED_DATE => NULL,   
                                                   p_CREATION_DATE       => SYSDATE, 
                                                   p_CREATED_BY          => p_OWNER, 
                                                   p_ODS                 => 'N',
                                                   p_DESCRIPTION         => p_DESCRIPTION,
                                                   p_CO_TK_ORG           => V_CO_TK_ORG,
                                                   p_ORIG_TK_CNTRY       => V_ORIGIN_COUNTRY,
                                                   p_DEST_PORT           => V_DEST_PORT);
    --Create a new contract
    APX_WOKDSK_PO_DML.OW_CONTRACT_INSERT(v_TK_OW , v_TK_CONTRACT_ID, p_NAME, 'UNPUBLISHED', p_OWNER, SYSDATE,SYSDATE, p_OWNER, 'N');
                                                 
    APX_WOKDSK_PO_DML.OW_PUR_ORD_INSERT(p_TK_OW                  => v_TK_OW,
                                        p_USER                   => p_OWNER,
                                        p_VENDOR_ID              => p_SUPPLIER,
                                        p_INCOTERM               => V_INCOTERM,
                                        p_SHIP_DATE              => NULL,     
                                        p_SUPPLIER_REF           => NULL,
                                        p_PURCHASE_PAYMENT_TERMS => V_PURCHASE_PAYMENT_TERMS, 
                                        p_PURCHASE_DATE          => NULL,
                                        p_PURCHASER              => V_PURCHASER,
                                        p_LOGISTICS_COORDINATOR  => V_LOGISTICS_COORDINATOR,
                                        p_DISCOUNT               => NULL,
                                        p_CURRENCY_CODE          => V_CURRENCY_CODE,  
                                        p_EXCHANGE_RATE          => NULL,
                                        p_LOCATION_CONTACT       => NULL);
    
    APX_WOKDSK_PO_DML.OW_WS_FOREX_INSERT( v_TK_OW, NULL, NULL,NULL, NULL, sysdate);
    
    --Insert OW Sale Ord DUMMY Record
    APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(v_TK_OW, n_NEW_EXECUTION_ID);
    --Create the POs 
    --Debo insertar en la ow_worksheet y en
    FOR i IN 1..p_AMOUNT LOOP
  
        --Generate tk_ow 
        SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
          INTO v_TK_OW
          FROM DUAL; 
    
        APX_WOKDSK_PO_DML.OW_WORKSHEET_INSERT_CONTRACT(p_TK_OW               => v_TK_OW,
                                                       p_TK_CONTRACT_ID      => v_TK_CONTRACT_ID,
                                                       p_NAME                => p_NAME,   
                                                       p_STATUS              => 'UNPUBLISHED',
                                                       p_OWNER               => p_OWNER,
                                                       p_TYPE                => 'WORKSHEET',
                                                       p_LAST_PUBLISHED_DATE => NULL,   
                                                       p_CREATION_DATE       => SYSDATE, 
                                                       p_CREATED_BY          => p_OWNER, 
                                                       p_ODS                 => 'N',
                                                       p_DESCRIPTION         => p_DESCRIPTION,
                                                       p_CO_TK_ORG           => V_CO_TK_ORG,
                                                       p_ORIG_TK_CNTRY       => V_ORIGIN_COUNTRY,
                                                       p_DEST_PORT           => V_DEST_PORT);

      
        APX_WOKDSK_PO_DML.OW_PUR_ORD_INSERT(p_TK_OW                  => v_TK_OW,
                                            p_USER                   => p_OWNER,
                                            p_VENDOR_ID              => p_SUPPLIER,
                                            p_INCOTERM               => V_INCOTERM,
                                            p_SHIP_DATE              => NULL,     
                                            p_SUPPLIER_REF           => NULL,
                                            p_PURCHASE_PAYMENT_TERMS => V_PURCHASE_PAYMENT_TERMS, 
                                            p_PURCHASE_DATE          => NULL,
                                            p_PURCHASER              => V_PURCHASER,
                                            p_LOGISTICS_COORDINATOR  => V_LOGISTICS_COORDINATOR,
                                            p_DISCOUNT               => NULL,
                                            p_CURRENCY_CODE          => V_CURRENCY_CODE,  
                                            p_EXCHANGE_RATE          => NULL,
                                            p_LOCATION_CONTACT       => NULL);         
                                                                                   
        APX_WOKDSK_PO_DML.OW_WS_FOREX_INSERT( v_TK_OW, NULL, NULL,NULL, NULL, sysdate);

                                                    
        INSERT INTO OW_CONTRACT_WORKSHEET (TK_CONTRACT,TK_OW,CREATION_DATE,CREATED_BY, LAST_UPDATE_DATE, LAST_UPDATED_BY,INIT_TK_OW)
                                   VALUES (V_TK_CONTRACT_ID,V_TK_OW, SYSDATE,P_OWNER, NULL, NULL,V_TK_OW );
     
        --Insert OW Sale Ord DUMMY Record
        APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(v_TK_OW, n_NEW_EXECUTION_ID);
  
  
    END LOOP;


    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_CREATE_CONTRACT;


PROCEDURE OW_COPY_CONTRACT(
p_TK_ORI_CONTRACT    NUMBER,
p_NAME               VARCHAR2,   
p_OWNER              NUMBER,
p_AMOUNT             NUMBER,
p_NEW_TK_OW          OUT NUMBER, -- TK - RELATION WITH OW_WORKSEET TABLE
p_NEW_TK_CONTRACT_ID OUT NUMBER,
p_EXECUTION_ID       IN NUMBER default -1
) IS
        n_NEW_EXECUTION_ID      NUMBER;
        v_starttime             TIMESTAMP;
        v_proc                  VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_COPY_CONTRACT';
        v_table                 VARCHAR2(100)   := 'COPY CONTRACT PROCESS';        
        
        v_TK_OW                 NUMBER; 
        v_TK_CONTRACT_ID        NUMBER;
        v_original_worksheet    NUMBER;
        v_first_tk_ow           NUMBER;
        v_set_wrksht_num        NUMBER;
         contract_not_exist EXCEPTION;
        PRAGMA exception_init( contract_not_exist, -20001 );

BEGIN

   --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
     BEGIN
      --Get tk_ow from original contract
        SELECT TEMPLATE_TK_OW
          INTO v_original_worksheet
          FROM workdesk.ow_contract
         WHERE  TK_CONTRACT = p_TK_ORI_CONTRACT;

     EXCEPTION
        WHEN OTHERS THEN
          RAISE contract_not_exist;
     END;    
      

--Generate NEW tk_ow 
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
    into v_TK_OW
    FROM DUAL; 
    
 p_NEW_TK_OW :=  v_TK_OW;
 
--Generate a new wrksht_num
    SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
      INTO v_set_wrksht_num
      FROM DUAL; 
   
--Generate NEW tk_contract_id 
    SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL"
    into v_TK_CONTRACT_ID
    FROM DUAL;    
 
    p_NEW_TK_CONTRACT_ID := v_TK_CONTRACT_ID;
 
    WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => v_original_worksheet,
                                                       p_Type  => 'TEMPLATE',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID);

    WORKDESK.APX_WOKDSK_PO_DML.OW_CONTRACT_INSERT(p_NEW_TK_OW , p_NEW_TK_CONTRACT_ID, p_NAME, 'UNPUBLISHED', p_OWNER, SYSDATE,SYSDATE, p_OWNER, 'N');

 --GET FIRST TK_OW FROM ow_contract_worksheet
    SELECT tk_ow 
      INTO v_first_tk_ow
      FROM workdesk.ow_contract_worksheet 
     WHERE tk_contract = p_TK_ORI_CONTRACT
       AND rownum = 1 
     ORDER BY tk_ow DESC;
     
     
    FOR i IN 1..p_AMOUNT LOOP
    
      --Generate NEW tk_ow 
      SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
      into v_TK_OW
      FROM DUAL; 
                  
      --Generate a new wrksht_num
      SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
        INTO v_set_wrksht_num
        FROM DUAL;
        
       WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => v_first_tk_ow,
                                                       p_Type  => 'WORKSHEET',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID); 
              
      WORKDESK.APX_WOKDSK_PO_DML.OW_CONT_WORKSHEET_INSERT(P_NEW_TK_OW  => v_TK_OW,
                                                          P_NEW_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                          P_OWNER => p_OWNER);
    END LOOP;

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_COPY_CONTRACT;

PROCEDURE OW_COPY_CONTRACT_EXAC(
p_TK_ORI_CONTRACT    NUMBER,
p_OWNER              NUMBER,
p_NEW_TK_OW          OUT NUMBER, -- TK - RELATION WITH OW_WORKSEET TABLE
p_NEW_TK_CONTRACT_ID OUT NUMBER,
p_EXECUTION_ID       IN NUMBER default -1
) IS
        n_NEW_EXECUTION_ID      NUMBER;
        v_starttime             TIMESTAMP;
        v_proc                  VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_COPY_CONTRACT_EXAC';
        v_table                 VARCHAR2(100)   := 'COPY CONTRACT PROCESS';        
        
        v_TK_OW                 NUMBER; 
        v_TK_CONTRACT_ID        NUMBER;
        v_original_worksheet    NUMBER;
        v_first_tk_ow           NUMBER;
        v_set_wrksht_num        NUMBER;
         contract_not_exist EXCEPTION;
        PRAGMA exception_init( contract_not_exist, -20001 );

BEGIN

   --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
     BEGIN
      --Get tk_ow from original contract
        SELECT TEMPLATE_TK_OW
          INTO v_original_worksheet
          FROM workdesk.ow_contract
         WHERE  TK_CONTRACT = p_TK_ORI_CONTRACT;

     EXCEPTION
        WHEN OTHERS THEN
          RAISE contract_not_exist;
     END;    
      

--Generate NEW tk_ow 
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
    into v_TK_OW
    FROM DUAL; 
    
 p_NEW_TK_OW :=  v_TK_OW;
 
--Generate a new wrksht_num
    SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
      INTO v_set_wrksht_num
      FROM DUAL; 
   
--Generate NEW tk_contract_id 
    SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL"  
    into v_TK_CONTRACT_ID
    FROM DUAL;    
 
    p_NEW_TK_CONTRACT_ID := v_TK_CONTRACT_ID;
    
   
    WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => v_original_worksheet,
                                                       p_Type  => 'TEMPLATE',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID);
 
    WORKDESK.APX_WOKDSK_PO_DML.OW_CONTRACT_COPY_INSERT(P_TK_ORI_CONTRACT => p_TK_ORI_CONTRACT,
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       P_NEW_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                       P_OWNER => p_OWNER);

                
             
 --GET FIRST TK_OW FROM ow_contract_worksheet
    SELECT tk_ow 
      INTO v_first_tk_ow
      FROM workdesk.ow_contract_worksheet 
     WHERE tk_contract = p_TK_ORI_CONTRACT
       AND rownum = 1 
     ORDER BY tk_ow DESC;
     
    
    FOR r1 IN (SELECT TK_OW
               FROM   ow_contract_worksheet
               WHERE  TK_CONTRACT = p_TK_ORI_CONTRACT)  
    LOOP
    
       --Generate NEW tk_ow 
       SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
       into v_TK_OW
       FROM DUAL; 
                      
       --Generate a new wrksht_num
       SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
         INTO v_set_wrksht_num
         FROM DUAL; 

      WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => r1.TK_OW,
                                                       p_Type  => 'WORKSHEET',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID);
                    
      
      WORKDESK.APX_WOKDSK_PO_DML.OW_CONT_WORKSHEET_INSERT(P_NEW_TK_OW  => v_TK_OW,
                                                          P_NEW_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                          P_OWNER => p_OWNER);     
      
    END LOOP;

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM||' - '||DBMS_UTILITY.format_error_backtrace||' - v_original_worksheet '||v_original_worksheet, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_COPY_CONTRACT_EXAC;

PROCEDURE CREATE_CONTRACT_FROM_TEMPLATE(p_TK_OW                NUMBER,
                                        p_NAME               VARCHAR2,   
                                        p_OWNER              NUMBER,
                                        p_AMOUNT             NUMBER,
                                        p_NEW_TK_OW          OUT NUMBER, -- TK - RELATION WITH OW_WORKSEET TABLE
                                        p_NEW_TK_CONTRACT_ID OUT NUMBER,
                                        p_EXECUTION_ID       IN NUMBER default -1
                                        ) 
 IS
  n_NEW_EXECUTION_ID      NUMBER;
  v_starttime             TIMESTAMP;
  v_proc                  VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.CREATE_CONTRACT_FROM_TEMPLATE';
  v_table                 VARCHAR2(100)   := 'COPY CONTRACT PROCESS';        
        
  v_TK_OW                 NUMBER; 
  v_TK_CONTRACT_ID        NUMBER;
  v_original_worksheet    NUMBER;
  v_set_wrksht_num        NUMBER;

BEGIN

   --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

     v_original_worksheet := p_TK_OW; 

  --Generate NEW tk_ow 
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
    into v_TK_OW
    FROM DUAL; 
    
  p_NEW_TK_OW :=  v_TK_OW;
 
  --Generate a new wrksht_num
    SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
      INTO v_set_wrksht_num
      FROM DUAL; 
   
  --Generate NEW tk_contract_id 
    SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL"  
    into v_TK_CONTRACT_ID
    FROM DUAL;    
 
    p_NEW_TK_CONTRACT_ID := v_TK_CONTRACT_ID;
 
   WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => v_original_worksheet,
                                                       p_Type  => 'TEMPLATE',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID);  

    WORKDESK.APX_WOKDSK_PO_DML.OW_CONTRACT_INSERT(p_TK_OW => v_TK_OW,
                                                  p_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                  p_NAME  => p_NAME,
                                                  p_STATUS => 'UNPUBLISHED',
                                                  p_OWNER => p_OWNER,
                                                  p_LAST_PUBLISHED_DATE => SYSDATE,
                                                  p_CREATION_DATE => SYSDATE,
                                                  p_CREATED_BY => p_OWNER,
                                                  p_ODS => 'N');
   
     
    FOR i IN 1..p_AMOUNT LOOP
    
      --Generate NEW tk_ow 
      SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
      into v_TK_OW
      FROM DUAL; 
                  
      --Generate a new wrksht_num
      SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
        INTO v_set_wrksht_num
        FROM DUAL; 

      WORKDESK.APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(p_TK_OW => v_original_worksheet,
                                                       p_Type  => 'WORKSHEET',
                                                       P_NEW_TK_OW  => v_TK_OW,
                                                       p_NEW_WORKSHEET_NUM  => v_set_wrksht_num,
                                                       p_TK_EMPLOYEE => p_OWNER,
                                                       pEXECUTION_ID => n_NEW_EXECUTION_ID);
              
      WORKDESK.APX_WOKDSK_PO_DML.OW_CONT_WORKSHEET_INSERT(P_NEW_TK_OW  => v_TK_OW,
                                                          P_NEW_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                          P_OWNER => p_OWNER);
      
    END LOOP;

    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END CREATE_CONTRACT_FROM_TEMPLATE;


PROCEDURE OW_DELETE_CONTRACT(
p_TK_CONTRACT    NUMBER,
p_OWNER          NUMBER,
p_EXECUTION_ID       IN NUMBER default -1
) IS

    n_NEW_EXECUTION_ID      NUMBER;
    v_starttime             TIMESTAMP;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_DELETE_CONTRACT';
    v_table             VARCHAR2(100)   := 'DELETED CONTRACT PROCESS'; 
    v_template_tk_ow    NUMBER := NULL;
    v_set_wrksht_num    NUMBER;
    
BEGIN

    --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End


  SELECT TEMPLATE_TK_OW 
  INTO   v_template_tk_ow
  FROM   WORKDESK.OW_CONTRACT
  WHERE  TK_CONTRACT = P_TK_CONTRACT;
  
  FOR r1 IN (SELECT TK_OW 
             FROM WORKDESK.OW_CONTRACT_WORKSHEET
             WHERE  TK_CONTRACT = P_TK_CONTRACT)
  LOOP
    SELECT SET_WRKSHT_NUM
    INTO   v_set_wrksht_num
    FROM   OW_WORKSHEET
    WHERE  TK_OW = r1.TK_OW;
  
    DELETE FROM WORKDESK.OW_CONTRACT_WORKSHEET
    WHERE  TK_OW = r1.TK_OW;

    APX_WOKDSK_PO_TOOLKIT.DELETE_PO(P_SET_WRKSHT_NUM => v_set_wrksht_num,
                                    p_LAST_UPDATED_BY => p_OWNER,
                                    pEXECUTION_ID => -1,
                                    p_TK_OW => r1.TK_OW);
  END LOOP;

  SELECT SET_WRKSHT_NUM
  INTO   v_set_wrksht_num
  FROM   OW_WORKSHEET
  WHERE  TK_OW = v_template_tk_ow; 

  APX_WOKDSK_PO_TOOLKIT.DELETE_PO(P_SET_WRKSHT_NUM => v_set_wrksht_num,
                                  p_LAST_UPDATED_BY => p_OWNER,
                                  pEXECUTION_ID => -1,
                                  p_TK_OW => v_template_tk_ow);
  
  DELETE FROM WORKDESK.OW_CONTRACT
  WHERE  TK_CONTRACT = P_TK_CONTRACT;

EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_DELETE_CONTRACT;


FUNCTION OW_RETURN_POs (p_TK_CONTRACT NUMBER,
                        p_EXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 is

    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_RETURN_POs';
    v_table             VARCHAR2(100)   := 'workdesk.ow_contract_worksheet and workdesk.ow_worksheet';
    v_starttime         TIMESTAMP;
    
    v_min_tk_ow NUMBER;
    v_max_tk_ow NUMBER;
    
BEGIN

    --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
     
    SELECT min(ow.set_wrksht_num), max(ow.set_wrksht_num)
      INTO v_min_tk_ow, v_max_tk_ow 
      FROM workdesk.ow_contract_worksheet con,  workdesk.ow_worksheet ow
     WHERE con.tk_contract = p_TK_CONTRACT
       AND con.tk_ow = ow.tk_ow; 
     
    IF v_min_tk_ow =  v_max_tk_ow THEN
    
        RETURN v_min_tk_ow;
        
    ELSE
    
        RETURN v_min_tk_ow||' / '||SUBSTR(v_max_tk_ow,-4);
        
    END IF;     
        

EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_RETURN_POs;


FUNCTION OW_AOP_RETURN_POs (p_TK_CONTRACT NUMBER,
                        p_EXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 is

    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_AOP_RETURN_POs';
    v_table             VARCHAR2(100)   := 'workdesk.ow_contract_worksheet and workdesk.ow_worksheet';
    v_starttime         TIMESTAMP;
    
    v_min_tk_ow NUMBER;
    v_max_tk_ow NUMBER;
    
BEGIN
     
    SELECT min(ow.set_wrksht_num), max(ow.set_wrksht_num)
      INTO v_min_tk_ow, v_max_tk_ow 
      FROM workdesk.ow_contract_worksheet con,  workdesk.ow_worksheet ow
     WHERE con.tk_contract = p_TK_CONTRACT
       AND con.tk_ow = ow.tk_ow; 
     
    IF v_min_tk_ow =  v_max_tk_ow THEN
    
        RETURN v_min_tk_ow;
        
    ELSE
    
        RETURN v_min_tk_ow||' through '||v_max_tk_ow;
        
    END IF;     
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(p_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_AOP_RETURN_POs;

PROCEDURE SAVE_CONTRACT_PO(
p_TK_OW               NUMBER,
p_TK_CONTRACK         NUMBER,
p_LAST_UPDATED_BY     NUMBER,
p_TYPE                VARCHAR2,   
p_DESCRIPTION         IN OUT VARCHAR2,  
p_VERSION_NUM         NUMBER,           
p_STATUS              VARCHAR2,   
p_DEST_TK_CNTRY       NUMBER,
p_INSP_TK_CNTRY       NUMBER,
p_PLANT               VARCHAR2,
p_CO_TK_ORG           NUMBER,
p_CURRENCY_CODE       IN OUT VARCHAR2,   
p_WT_UOM              VARCHAR2,                  
p_CREATED_BY          NUMBER,                     
p_OWNER               NUMBER,
p_DEST_PORT           VARCHAR2,
p_NOTIFY_SUBJECT      VARCHAR2,
p_ODS                 VARCHAR2,   
p_POSITION_PURCHASE   VARCHAR2,    
p_PURCHASE_DECISION   VARCHAR2,  
p_PROVINCE            IN OUT NUMBER, 
p_NOTE_SUPPLIER       VARCHAR2,
p_NOTE_INTERNAL       VARCHAR2,
p_BANK_DESCR          VARCHAR2,
p_EXCHANGE_RATE       NUMBER,
p_EXCHANGE_AMOUNT     NUMBER,
p_CONTRACT_NUMBER     VARCHAR2,
p_VALUATION_DATE      DATE,
p_LINE_NUM            NUMBER,        
p_PUR_PRICE_CASE      NUMBER,
p_PUR_PRICE_WT        NUMBER,
p_PUR_PRICE_UOM       VARCHAR2,
p_VENDOR_ID         NUMBER,
p_INCOTERM          VARCHAR2,
p_SHIP_DATE         VARCHAR2,     
p_SUPPLIER_REF      VARCHAR2,
p_PURCHASE_DATE     DATE,
p_DISCOUNT          NUMBER,
p_PURCHASE_PAYMENT_TERMS VARCHAR2,
p_LOGISTICS_COORDINATOR NUMBER,
p_PURCHASER             NUMBER,
p_SET_WRKSHT_NUM      IN OUT NUMBER,
p_new_TK_OW           OUT NUMBER,
p_ORIGIN_COUNTRY         NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID         IN NUMBER default -1

) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.SAVE_CONTRACT_PO';
    v_table             VARCHAR2(100)   := 'WORKDESK.OW_CONTRACT_WORKSHEET and WORKDESK.APX_WOKDSK_PO_DML.OW_WORKSHEET_UPDATE';
    v_starttime         TIMESTAMP;
    
    v_tk_worksheet      NUMBER;
    v_notify_subject    VARCHAR2(100)   := NULL;
    v_notify_sub_old    VARCHAR2(100)   := NULL;
    v_notify_sub_new    VARCHAR2(100)   := NULL;

   CURSOR c_WORSHEET_TKs
   IS
     SELECT TK_OW FROM workdesk.ow_contract_worksheet WHERE tk_contract = p_TK_CONTRACK;
     
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
        
        /* Agregado Contract Name Fix - Mariano Mangiafico 19-01-2021 */
        IF P_TYPE = 'TEMPLATE' THEN
            OW_UPDATE_CONTRACT_HEADER(P_TK_CONTRACT => p_TK_CONTRACK,
                                      P_CONTRACT_NAME => p_DESCRIPTION,
                                      pEXECUTION_ID  => n_NEW_EXECUTION_ID);
        END IF;
        /* Fin Agregado Contract Name Fix - Mariano Mangiafico 19-01-2021 */
         
        --Contract is a worksheet with type TEMPLATE
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
        ,p_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID
        );   
       
    OPEN c_WORSHEET_TKs;
    LOOP
    
    FETCH c_WORSHEET_TKs INTO v_tk_worksheet;
    
    EXIT WHEN c_WORSHEET_TKs%notfound;
    
            WORKDESK.APX_WOKDSK_PO_DML.OW_WORKSHEET_UPDATE
        (
         v_tk_worksheet            
        ,'WORKSHEET'             
        ,p_DESCRIPTION||' '||TO_CHAR(SYSDATE,'DD-MON-YYYY') --  Agregado Contract Name Fix - Mariano Mangiafico 19-01-2021     
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
        ,p_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID
        );  
     
    END LOOP; 
    
    CLOSE c_WORSHEET_TKs;
    
    COMMIT;         
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END SAVE_CONTRACT_PO;

PROCEDURE SAVE_CONTRACT_PO_CONTRACT(
p_TK_OW               NUMBER,
p_TK_CONTRACK         NUMBER,
p_LAST_UPDATED_BY     NUMBER,
p_TYPE                VARCHAR2,   
p_DESCRIPTION         IN OUT VARCHAR2,  
p_VERSION_NUM         NUMBER,           
p_STATUS              VARCHAR2,   
p_DEST_TK_CNTRY       NUMBER,
p_INSP_TK_CNTRY       NUMBER,
p_PLANT               VARCHAR2,
p_CO_TK_ORG           NUMBER,
p_CURRENCY_CODE       IN OUT VARCHAR2,   
p_WT_UOM              VARCHAR2,                  
p_CREATED_BY          NUMBER,                     
p_OWNER               NUMBER,
p_DEST_PORT           VARCHAR2,
p_NOTIFY_SUBJECT      VARCHAR2,
p_ODS                 VARCHAR2,   
p_POSITION_PURCHASE   VARCHAR2,    
p_PURCHASE_DECISION   VARCHAR2,  
p_PROVINCE            IN OUT NUMBER, 
p_NOTE_SUPPLIER       VARCHAR2,
p_NOTE_INTERNAL       VARCHAR2,
p_BANK_DESCR          VARCHAR2,
p_EXCHANGE_RATE       NUMBER,
p_EXCHANGE_AMOUNT     NUMBER,
p_CONTRACT_NUMBER     VARCHAR2,
p_VALUATION_DATE      DATE,
p_LINE_NUM            NUMBER,        
p_PUR_PRICE_CASE      NUMBER,
p_PUR_PRICE_WT        NUMBER,
p_PUR_PRICE_UOM       VARCHAR2,
p_VENDOR_ID         NUMBER,
p_INCOTERM          VARCHAR2,
p_SHIP_DATE         VARCHAR2,     
p_SUPPLIER_REF      VARCHAR2,
p_PURCHASE_DATE     DATE,
p_DISCOUNT          NUMBER,
p_PURCHASE_PAYMENT_TERMS VARCHAR2,
p_LOGISTICS_COORDINATOR NUMBER,
p_PURCHASER             NUMBER,
p_SET_WRKSHT_NUM      IN OUT NUMBER,
p_new_TK_OW           OUT NUMBER,
p_ORIGIN_COUNTRY         NUMBER,
p_LOCATION_CONTACT       VARCHAR2,
pEXECUTION_ID         IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.SAVE_CONTRACT_PO_CONTRACT';
    v_table             VARCHAR2(100)   := 'workdesk.ow_contract_worksheet and WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.OW_WORKSHEET_UPDATE_CONTRACT';
    v_starttime         TIMESTAMP;
    v_notify_subject    VARCHAR2(100)   := NULL;
    v_notify_sub_old    VARCHAR2(100)   := NULL;
    v_notify_sub_new    VARCHAR2(100)   := NULL;
    
    v_tk_worksheet      NUMBER;

   CURSOR c_WORSHEET_TKs
   IS
     SELECT TK_OW FROM workdesk.ow_contract_worksheet WHERE tk_contract = p_TK_CONTRACK;
     
BEGIN
    
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
      
        
        --Contract is a worksheet with type TEMPLATE
        WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.OW_WORKSHEET_UPDATE_CONTRACT
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
        ,p_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID
        );
        
        /* Agregado Contract Name Fix - Mariano Mangiafico 19-01-2021 */
        IF P_TYPE = 'TEMPLATE' THEN
            OW_UPDATE_CONTRACT_HEADER(P_TK_CONTRACT => p_TK_CONTRACK,
                                      P_CONTRACT_NAME => p_DESCRIPTION,
                                      pEXECUTION_ID  => n_NEW_EXECUTION_ID);
        END IF;
        /* Fin Agregado Contract Name Fix - Mariano Mangiafico 19-01-2021 */  
      
    OPEN c_WORSHEET_TKs;
    LOOP
    
    FETCH c_WORSHEET_TKs INTO v_tk_worksheet;
    
    EXIT WHEN c_WORSHEET_TKs%notfound;
    ------------------------------------
    APX_WOKDSK_PO_TOOLKIT.GET_NOTIFY_SUBJECT_PO(v_tk_worksheet,v_notify_subject,v_notify_sub_new,v_notify_sub_old,pEXECUTION_ID);
    
    /*IF v_notify_subject != v_notify_sub_old AND v_notify_sub_old IS NOT NULL THEN
      v_notify_sub_new := v_notify_sub_old;
    END IF;*/
    -------------------------------------    
            WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.OW_WORKSHEET_UPDATE_CONTRACT
        (
         v_tk_worksheet            
        ,'WORKSHEET'             
        ,p_DESCRIPTION
        ,p_DEST_TK_CNTRY    
        ,p_INSP_TK_CNTRY    
        ,p_PLANT            
        ,p_CO_TK_ORG        
        ,p_CURRENCY_CODE    
        ,p_WT_UOM                  
        ,p_LAST_UPDATED_BY 
        ,p_DEST_PORT        
        ,v_notify_subject --p_NOTIFY_SUBJECT   
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
        ,p_ORIGIN_COUNTRY
        ,p_LOCATION_CONTACT
        ,n_NEW_EXECUTION_ID
        );  
     
    END LOOP; 
    
    CLOSE c_WORSHEET_TKs;
    
    COMMIT;      
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END SAVE_CONTRACT_PO_CONTRACT;


PROCEDURE OW_WORKSHEET_UPDATE_CONTRACT(
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
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_WORKSHEET_UPDATE_CONTRACT';
    v_table             VARCHAR2(100)   := 'Update OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_type              VARCHAR2(100);
    v_description       VARCHAR2(500); 
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
        ,PROVINCE          = p_PROVINCE   
        ,ORIG_TK_CNTRY     = P_ORIGIN_COUNTRY
    WHERE TK_OW = p_TK_OW;
    
      --Update Notes, ONLY TEMPLATE, IF WORKSHEET UPDATE FROM PAGE 40 ON CHANGE NOTES
    SELECT TYPE 
    INTO v_type
    FROM workdesk.ow_worksheet w 
    WHERE  w.tk_ow=p_tk_ow;
    
    
    IF v_type = 'TEMPLATE' THEN
      APX_WOKDSK_PO_DML.OW_WS_NOTE_UPDATE(p_TK_OW, p_NOTE_SUPPLIER, p_NOTE_INTERNAL, n_NEW_EXECUTION_ID);
    END IF;
    --Update Foreign Echange Information
    APX_WOKDSK_PO_DML.OW_WS_FOREX_UPDATE(p_TK_OW, p_BANK_DESCR, p_EXCHANGE_RATE,p_EXCHANGE_AMOUNT, p_CONTRACT_NUMBER,p_VALUATION_DATE, n_NEW_EXECUTION_ID);
    
 
    
    --Update Purchaser table 
    OW_PUR_ORD_UPDATE_CONTRACT(p_TK_OW, p_LAST_UPDATED_BY, p_VENDOR_ID, p_INCOTERM, p_SHIP_DATE, p_SUPPLIER_REF, p_PURCHASE_PAYMENT_TERMS, p_PURCHASE_DATE, p_PURCHASER, p_LOGISTICS_COORDINATOR, 
                      p_DISCOUNT, p_CURRENCY_CODE, p_EXCHANGE_RATE,p_LOCATION_CONTACT, n_NEW_EXECUTION_ID);   
    
         
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', '1.An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);     
END OW_WORKSHEET_UPDATE_CONTRACT;

PROCEDURE CONTRACT_WORKSHEETS_UPDATE(
p_supplier_ref varchar2,
p_ship_date varchar2,
p_tk_ow number,
p_tk_contract number

)IS

  n_NEW_EXECUTION_ID      NUMBER;
  v_starttime             TIMESTAMP;
  v_proc                  VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.CONTRACT_WORKSHEETS_UPDATE';
  v_table                 VARCHAR2(100)   := 'WORKDESK.OW_PUR_ORD'; 

  v_supplier_ref varchar2(400):=NULL;
  v_ship_date varchar2(400):=NULL;
  v_tk_ow number:=NULL;
  v_tk_contract number:=NULL;

BEGIN

        SELECT PO.VND_ORD_NUM
              ,PO.PICKUP_PERIOD_DESCR
          INTO V_SUPPLIER_REF
              ,V_SHIP_DATE
        FROM WORKDESK.OW_PUR_ORD PO
        WHERE PO.TK_OW= P_TK_OW 
          and ROWNUM=1;
          
        /*Validacion de cambios en ambos items en pagina contra los valores en base de datos, luego update*/
            IF (P_SUPPLIER_REF <> V_SUPPLIER_REF)  AND (p_ship_date <> v_ship_date) 
             
            THEN
            /* ---------:::NEED REVISION::: 
                UPDATE OW_PUR_ORD SET
                      VND_ORD_NUM          = p_SUPPLIER_REF  
                     ,PICKUP_PERIOD_DESCR  = p_SHIP_DATE             
                WHERE TK_OW = p_TK_OW
                 AND tk_OW in (select w.tk_ow 
                                from workdesk.ow_contract_worksheet w 
                                    ,WORKDESK.OW_WORKSHEET pw
                                where PW.TK_OW = W.TK_OW
                                and   pw.status <> 'PUBLISHED'
                                AND   w.TK_CONTRACT = p_tk_contract);
            */NULL;                    
            ELSIF (P_SUPPLIER_REF <> V_SUPPLIER_REF) AND (P_SHIP_DATE = V_SHIP_DATE)  
               THEN
                /* ---------:::NEED REVISION:::   
                   UPDATE OW_PUR_ORD SET
                      VND_ORD_NUM = p_SUPPLIER_REF  
                WHERE TK_OW = p_TK_OW
                  AND tk_OW in (select w.tk_ow 
                                        from workdesk.ow_contract_worksheet w 
                                            ,WORKDESK.OW_WORKSHEET pw
                                        where PW.TK_OW = W.TK_OW
                                        and   pw.status <> 'PUBLISHED'
                                        AND   w.TK_CONTRACT = p_tk_contract);
                */NULL;         
            ELSIF (P_SUPPLIER_REF = V_SUPPLIER_REF) AND (P_SHIP_DATE <> V_SHIP_DATE)  
              THEN 
                /* ---------:::NEED REVISION:::
                 UPDATE OW_PUR_ORD SET
                     PICKUP_PERIOD_DESCR  = p_SHIP_DATE             
                WHERE TK_OW = p_TK_OW
                  AND tk_OW in (select w.tk_ow 
                                from workdesk.ow_contract_worksheet w 
                                            ,WORKDESK.OW_WORKSHEET pw
                                        where PW.TK_OW = W.TK_OW
                                        and   pw.status <> 'PUBLISHED'
                                        AND   w.TK_CONTRACT = p_tk_contract);
                */NULL;
            END IF;
END CONTRACT_WORKSHEETS_UPDATE;/*proceso de actualizacion de los valores de ship_date y tk_ow*/

PROCEDURE OW_PUR_ORD_UPDATE_CONTRACT(
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
p_tk_contract            NUMBER, 
pEXECUTION_ID            IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_PUR_ORD_UPDATE_CONTRACT';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD';
    V_SUPPLIER_REF      OW_PUR_ORD.VND_ORD_NUM%TYPE;
    V_SHIP_DATE         OW_PUR_ORD.PICKUP_PERIOD_DESCR%TYPE;  
    v_starttime         TIMESTAMP;
    v_count_contract    NUMBER := 0;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
           
        SELECT COUNT(1)
          INTO V_COUNT_CONTRACT
          FROM OW_CONTRACT
         WHERE TEMPLATE_TK_OW = P_TK_OW;
         
        UPDATE OW_PUR_ORD SET
                 VENDOR_ID            = p_VENDOR_ID
                ,PURCHASE_TERMS_DESCR = p_INCOTERM                        
                ,PAY_TERM_DESCR       = p_PURCHASE_PAYMENT_TERMS    
                ,PURCHASE_DATE        = p_PURCHASE_DATE             
                ,TK_EMP_TRADER        = NVL(p_PURCHASER,p_USER)                
                ,TK_EMP_TRF           = p_LOGISTICS_COORDINATOR     
                ,DISCOUNT_RATE        = p_DISCOUNT                  
                ,CURRENCY_CODE        = p_CURRENCY_CODE             
                ,EXCHANGE_RATE        = p_EXCHANGE_RATE    
                ,CONTACT              = p_LOCATION_CONTACT  
           WHERE TK_OW = p_TK_OW;
        /* Mariano Mangiafico 27-01-2021 - Only update if its a contract */ 
        IF  V_COUNT_CONTRACT > 0 THEN
        
            UPDATE OW_PUR_ORD 
               SET VND_ORD_NUM  = P_SUPPLIER_REF, 
                   PICKUP_PERIOD_DESCR = P_SHIP_DATE 
             WHERE TK_OW = P_TK_OW;
        
        END IF;
           
    COMMIT;      
    
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_PUR_ORD_UPDATE_CONTRACT;


PROCEDURE PUBLISH_CONTRACT_PO(p_TK_CONTRAC NUMBER, 
                              p_LAST_UPDATED_BY NUMBER, 
                              pEXECUTION_ID IN NUMBER default -1) IS
                              
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.PUBLISH_CONTRACT_PO';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET AND OW_CONTRACT_WORKSHEET AND OW_CONTRACT';
    v_starttime         TIMESTAMP;
    
       v_tk_worksheet      NUMBER;

   CURSOR c_WORSHEET_TKs
   IS
     SELECT cw.TK_OW 
       FROM workdesk.ow_contract_worksheet cw, ow_worksheet ow 
      WHERE cw.tk_contract = p_TK_CONTRAC
        AND ow.status <> 'PUBLISHED'
        AND cw.tk_ow = ow.tk_ow;

BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
   
    UPDATE ow_contract
       SET STATUS = 'PUBLISHED',
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATED_BY    = p_LAST_UPDATED_BY
     WHERE TK_CONTRACT = p_TK_CONTRAC;
     
    
    OPEN c_WORSHEET_TKs;
    LOOP
    
    FETCH c_WORSHEET_TKs INTO v_tk_worksheet;
    
    EXIT WHEN c_WORSHEET_TKs%notfound;

      APX_WOKDSK_PO_TOOLKIT.PUBLISH_PO(v_tk_worksheet,p_LAST_UPDATED_BY, n_NEW_EXECUTION_ID);
         
    END LOOP; 
    
    CLOSE c_WORSHEET_TKs;
    
    
    COMMIT;
    
        

EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END PUBLISH_CONTRACT_PO;

PROCEDURE UNPUBLISH_CONTRACT(p_TK_CONTRACT NUMBER, p_LAST_UPDATED_BY NUMBER, pEXECUTION_ID IN NUMBER default -1) AS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.UNPUBLISH_CONTRACT';
    v_table             VARCHAR2(100)   := 'UPDATE OW_CONTRACT AND UPDATE OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_new_tk            NUMBER;

    v_tk_worksheet      NUMBER;
    v_template_tk_ow    NUMBER;
    v_notify_subject    VARCHAR2(100)   := NULL;
    v_notify_sub_old    VARCHAR2(100)   := NULL;
    v_notify_sub_new    VARCHAR2(100)   := NULL;
    v_orig_tk_cntry     NUMBER; 
    v_contract_name     ow_contract.name%type;
    V_VERSION           number; 

   CURSOR c_WORSHEET_TKs
   IS
     SELECT cw.TK_OW 
       FROM workdesk.ow_contract_worksheet cw, ow_worksheet ow 
      WHERE cw.tk_contract = p_TK_CONTRACT
       -- AND ow.status <> 'PUBLISHED'
        AND cw.tk_ow = ow.tk_ow;

BEGIN
    
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
  
    UPDATE ow_contract
       SET STATUS = 'UNPUBLISHED',
           LAST_UPDATE_DATE   = SYSDATE,
           LAST_UPDATED_BY    = p_LAST_UPDATED_BY,
           OWNER = p_LAST_UPDATED_BY
     WHERE TK_CONTRACT = p_TK_CONTRACT;
    
  
    OPEN c_WORSHEET_TKs;
    LOOP
    
    FETCH c_WORSHEET_TKs INTO v_tk_worksheet;
    
    EXIT WHEN c_WORSHEET_TKs%notfound;
    
      APX_WOKDSK_PO_TOOLKIT.UNPUBLISH_PO(v_tk_worksheet,p_LAST_UPDATED_BY,pEXECUTION_ID);
      
    END LOOP; 
    
    CLOSE c_WORSHEET_TKs;
    
    SELECT TEMPLATE_TK_OW , name
    INTO   v_template_tk_ow, v_contract_name
    FROM   ow_contract
    WHERE  TK_CONTRACT = p_TK_CONTRACT;
    
    /* JP
    APX_WOKDSK_PO_TOOLKIT.GET_NOTIFY_SUBJECT_PO(v_template_tk_ow,v_notify_subject,v_notify_sub_new,v_notify_sub_old,pEXECUTION_ID);
    
    IF v_notify_subject != v_notify_sub_old AND v_notify_sub_old IS NOT NULL THEN
      v_notify_sub_new := v_notify_sub_old;
    END IF;*/
    ----------------------
      SELECT VERSION_NUM + 1
         INTO   V_VERSION
         FROM   OW_WORKSHEET
        WHERE TK_OW = v_template_tk_ow;
      
      
      v_notify_sub_new := 'Contract - '||v_contract_name||', version '||TO_CHAR(V_VERSION)||' Published';
    
    -----------------------
    
    v_orig_tk_cntry := APX_WOKDSK_PO_DML.GET_ORIG_TK_CNTRY(v_template_tk_ow);
    
    UPDATE OW_WORKSHEET
    SET    NEW_OW = 'Y',
           VERSION_NUM = VERSION_NUM + 1,
           NOTIFY_SUBJECT = v_notify_sub_new,
           OWNER = p_LAST_UPDATED_BY,
           ORIG_TK_CNTRY = v_orig_tk_cntry
    WHERE TK_OW = (SELECT TEMPLATE_TK_OW 
                     FROM ow_contract
                    WHERE TK_CONTRACT = p_TK_CONTRACT);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);        
END UNPUBLISH_CONTRACT;

FUNCTION CONTRACT_WAS_PUBLISHED(
p_TK_CONTRACT NUMBER
)RETURN BOOLEAN AS 

  n_NEW_EXECUTION_ID      NUMBER;
  v_starttime             TIMESTAMP;
  v_proc                  VARCHAR2(100)   := 'FUNCTION CONTRACT_WAS_PUBLISHED';
  v_table                 VARCHAR2(100)   := 'WORKDESK.OW_CONTRACT'; 
 
  v_publishes NUMBER;
 
BEGIN

 v_starttime := CURRENT_TIMESTAMP;

 SELECT COUNT(1)
   INTO v_publishes
   FROM WORKDESK.ow_contract co
  WHERE tk_contract = p_TK_CONTRACT
    AND status = 'PUBLISHED';
    
    IF v_publishes = 0 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
    
EXCEPTION 
    WHEN OTHERS THEN 
         OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(-1, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);        
         RETURN FALSE;
END CONTRACT_WAS_PUBLISHED;

FUNCTION OW_RETURN_PROD (p_TK_OW NUMBER,
                         p_MAX_PRODUCT IN NUMBER DEFAULT NULL,
                         p_EXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 AS
                         
 v_starttime TIMESTAMP;
 v_proc      VARCHAR2(100)   := 'FUNCTION OW_RETURN_PROD';
 v_table     VARCHAR2(100)   := 'PUR_DESCR'; 
 
 v_return    VARCHAR2(4000);
 v_count     number :=0;

    CURSOR c_products IS
        SELECT PUR_DESCR as buy_descr
          FROM ow_ws_prd_line
         WHERE TK_OW = p_TK_OW
           AND ROWNUM < nvl(p_max_product,ROWNUM)+1;  
        

BEGIN

    FOR rec IN c_products LOOP
        IF (v_count = 0) then
            v_return := rec.buy_descr;
        else
            if (v_count < p_max_product) then
                v_return := v_return || '</br>'|| rec.buy_descr;
            end if;
        end if;
        v_count := v_count + 1;
    END LOOP;

    if (v_count > p_max_product) then
        v_return := v_return || '<br/>and '||to_char(v_count-p_max_product) ||' more...';

    end if;

    return v_return;
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(-1, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);                            
END OW_RETURN_PROD;


PROCEDURE OW_CREATE_WS(p_TK_CONTRACT NUMBER,
                     p_AMOUNT NUMBER,
                     p_EXECUTION_ID       IN NUMBER default -1)is
   
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'APX_WOKDSK_CONTRACT_TOOLKIT.OW_CREATE_WS';
    v_table             VARCHAR2(100)   := 'OW_PUR_ORD AND OW_WORKSHEET AND OW_CONTRACT';
    v_starttime         TIMESTAMP;

    v_TK_OW          NUMBER;
    v_TK_CONTRACT_ID NUMBER;
    
p_NAME VARCHAR2(200);
p_OWNER NUMBER;
p_DESCRIPTION VARCHAR2(200);
p_SUPPLIER NUMBER;
v_TEMPLATE_TK_OW          NUMBER;
BEGIN
    --Logging Begin
    IF p_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := p_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End

    SELECT C.NAME,W.DESCRIPTION,W.OWNER,O.VENDOR_ID,C.TEMPLATE_TK_OW
    INTO P_NAME,P_DESCRIPTION,P_OWNER,P_SUPPLIER,V_TEMPLATE_TK_OW
    FROM OW_PUR_ORD O,ow_worksheet W,ow_contract C
    WHERE C.TK_CONTRACT=P_TK_CONTRACT
    AND W.TK_OW=C.TEMPLATE_TK_OW
    AND O.TK_OW=W.TK_OW;

  v_TK_CONTRACT_ID:=P_TK_CONTRACT;
  
  FOR i IN 1..p_AMOUNT LOOP
  
 --Generate tk_ow 
    SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
      INTO v_TK_OW
      FROM DUAL; 
    
        WORKDESK.APX_WOKDSK_PO_DML.OW_WORKSHEET_INSERT_CONTRACT(v_TK_OW,v_TK_CONTRACT_ID,p_NAME,'UNPUBLISHED',p_OWNER,'WORKSHEET',NULL,  SYSDATE,p_OWNER,'N',p_DESCRIPTION,NULL,NULL,NULL);
                                                              
        WORKDESK.APX_WOKDSK_PO_DML.OW_PUR_ORD_COPY_INSERT(V_TEMPLATE_TK_OW, v_TK_OW);
                
        WORKDESK.APX_WOKDSK_PO_DML.OW_WS_FOREX_COPY_INSERT(V_TEMPLATE_TK_OW, v_TK_OW);

        WORKDESK.APX_WOKDSK_PO_DML.OW_PO_PRD_LINE_COPY_INSERT(V_TEMPLATE_TK_OW, v_TK_OW);
          
        WORKDESK.APX_WOKDSK_PO_DML.OW_PO_WS_LINE_COPY_INSERT(V_TEMPLATE_TK_OW, v_TK_OW);
       
        WORKDESK.APX_WOKDSK_PO_DML.OW_PO_PRD_PLANTS_COPY_INSERT(V_TEMPLATE_TK_OW, v_TK_OW);
           
        WORKDESK.APX_WOKDSK_PO_DML.OW_CONT_WORKSHEET_INSERT(P_NEW_TK_OW  => v_TK_OW,
                                                            P_NEW_TK_CONTRACT_ID  => v_TK_CONTRACT_ID,
                                                            P_OWNER => p_OWNER);
  
  END LOOP;


COMMIT;
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(p_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        --OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END OW_CREATE_WS;

PROCEDURE OW_CONTRACT_OWNER_UPDATE(
p_TK_CONTRACT                  NUMBER,
p_TK_CURRENT_OWNER                NUMBER,
p_TK_NEW_OWNER                    NUMBER, 
pEXECUTION_ID                  IN NUMBER default -1
) IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_CONTRACT_OWNER_UPDATE';
    v_table             VARCHAR2(100)   := 'OW_CONTRACT and OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_status            VARCHAR2(20);
    v_tk_worksheet_id   NUMBER;
BEGIN
    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    --GET CONTRACT STATUS and tk_ow
    SELECT status , template_tk_ow 
      INTO v_status, v_tk_worksheet_id
      FROM OW_CONTRACT
     WHERE tk_contract = p_TK_CONTRACT;

    
    --CHANGE CONTRACR OWNER
    UPDATE OW_CONTRACT
       SET OWNER        = P_TK_NEW_OWNER,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY  = P_TK_CURRENT_OWNER
    WHERE tk_contract = P_TK_CONTRACT;
    
    
    --CHANGE OWNER FOR ALL WORKSHEET
    UPDATE WORKDESK.OW_WORKSHEET 
       SET OWNER        = P_TK_NEW_OWNER,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY  = P_TK_CURRENT_OWNER
    WHERE  TK_OW = v_tk_worksheet_id OR TK_OW IN (SELECT tk_ow FROM ow_contract_worksheet WHERE tk_contract = p_TK_CONTRACT);
    
     
    IF v_status = 'PUBLISHED' THEN 

        UPDATE WORKDESK.OW_WORKSHEET_PUB  
       SET OWNER        = P_TK_NEW_OWNER,
       LAST_UPDATE_DATE = SYSDATE,
       LAST_UPDATED_BY  = P_TK_CURRENT_OWNER
    WHERE  TK_OW = v_tk_worksheet_id OR TK_OW IN (SELECT tk_ow FROM ow_contract_worksheet WHERE tk_contract = p_TK_CONTRACT);
    
    END IF;
    
    COMMIT;        

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);      
END OW_CONTRACT_OWNER_UPDATE;


/***************************************************************
*
*  VALIDATE_MATCH_PRD
*
*  Last Modify 06/01/2021   Pablo Flores 
*              28/01/2021   Pablo Flores 
*
*/ 
FUNCTION VALIDATE_MATCH_PRD (p_TK_CONTRACT  NUMBER,
                             p_TK_OW        NUMBER,
                             pEXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 AS
                             
 n_NEW_EXECUTION_ID     NUMBER;
 v_proc                 VARCHAR2(100)   := 'VALIDATE_MATCH_PRD';
 v_table                VARCHAR2(100)   := 'OW_WORKSHEET AND OW_CONTRACT AND OW_PO_PRD_LINE';
 v_starttime            TIMESTAMP;
 v_status               ow_contract.status%TYPE;
 v_template_tk_ow       ow_contract.template_tk_ow%TYPE;
 v_tk_prd_worksheet     ow_po_prd_line.tk_prd%TYPE;
 v_tk_prd_contract      ow_po_prd_line.tk_prd%TYPE; 
 v_amount_prd_contract  NUMBER;
 v_amount_prd_worksheet NUMBER;
 v_return               VARCHAR2(100);
 
BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
    
    SELECT status, template_tk_ow
      INTO v_status, v_template_tk_ow
      FROM OW_CONTRACT
     WHERE TK_CONTRACT = p_TK_CONTRACT;

    IF v_status = 'UNPUBLISHED' THEN

        --contract product amount
        BEGIN             
            SELECT count(1)
              INTO v_amount_prd_contract
              FROM ow_po_prd_line
             WHERE tk_ow = v_template_tk_ow;
        EXCEPTION WHEN NO_DATA_FOUND THEN
           v_amount_prd_contract:=0;
        END;         
    
        --worksheet product amount 
        BEGIN        
            SELECT count(1)
              INTO v_amount_prd_worksheet
              FROM ow_po_prd_line
             WHERE tk_ow = p_TK_OW;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_amount_prd_worksheet:=0;
        END;

        -- valida que la cantidades sean iguales
        IF v_amount_prd_contract <> v_amount_prd_worksheet THEN
        
            v_return := 'Product(s)';
           
        ELSE -- valida que los productos sean los mismos

            v_return := NULL;   --default
            
            FOR l_TK_PRD IN (SELECT TK_PRD, LINE_NUM     --recorre prod contract     
                               FROM ow_po_prd_line
                              WHERE tk_ow = v_template_tk_ow)
            LOOP
                    --worksheet product  
                    BEGIN
                      SELECT tk_prd      
                        INTO v_tk_prd_worksheet
                        FROM OW_PO_PRD_LINE
                       WHERE TK_PRD = l_TK_PRD.TK_PRD --busca un prod worksheet
                         AND TK_OW = P_TK_OW
                         AND LINE_NUM = l_TK_PRD.LINE_NUM;   -- evita too many 
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                       v_return := 'Product(s)';
                       EXIT;  --fin de loop --> no existe el prd en worksheet
                    END;
             
            END LOOP l_TK_PRD;
            
        END IF;
            
    ELSE --PUBLISHED

        --contract product amount
        BEGIN             
            SELECT count(1)
              INTO v_amount_prd_contract
              FROM ow_po_prd_line
             WHERE tk_ow = v_template_tk_ow;
        EXCEPTION WHEN NO_DATA_FOUND THEN
           v_amount_prd_contract:=0;
        END;         
    
        --worksheet product amount 
        BEGIN        
            SELECT count(1)
              INTO v_amount_prd_worksheet
              FROM ow_po_prd_line_pub
             WHERE tk_ow = p_TK_OW;
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_amount_prd_worksheet:=0;
        END;

        -- valida que la cantidades sean iguales
        IF v_amount_prd_contract <> v_amount_prd_worksheet THEN
        
            v_return := 'Product(s)';
           
        ELSE -- valida que los productos sean los mismos

            v_return := NULL;   --default
            
            FOR l_TK_PRD IN (SELECT TK_PRD, LINE_NUM     --recorre prod contract     
                               FROM ow_po_prd_line
                              WHERE tk_ow = v_template_tk_ow)
            LOOP
                    --worksheet product  
                    BEGIN
                      SELECT tk_prd      
                        INTO v_tk_prd_worksheet
                        FROM OW_PO_PRD_LINE_pub
                       WHERE TK_PRD = l_TK_PRD.TK_PRD --busca un prod worksheet
                         AND tk_ow = P_TK_OW
                         AND LINE_NUM = l_TK_PRD.LINE_NUM;   -- evita too many 
                    EXCEPTION WHEN NO_DATA_FOUND THEN
                       v_return := 'Product(s)';
                       EXIT;  --fin de loop --> no existe el prd en worksheet
                    END;

             
            END LOOP l_TK_PRD;
            
            
        END IF;

    END IF;

return v_return;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;


/***************************************************************
*
*  TOTAL_VALUE_USD
*
*  Last Modify 15/01/2021   Pablo Flores 
*
*/ 
FUNCTION TOTAL_VALUE_USD (p_TK_CONTRACT  NUMBER,
                          pEXECUTION_ID IN NUMBER default -1) RETURN NUMBER AS
                             
 n_NEW_EXECUTION_ID        NUMBER;
 v_proc                    VARCHAR2(100)   := 'TOTAL_VALUE_USD';
 v_table                   VARCHAR2(100)   := 'OW_WS_FOREX AND OW_CONTRACT_WORKSHEET';
 v_starttime               TIMESTAMP;
 v_totalvalueusd NUMBER:=0;

BEGIN
  
  v_starttime := CURRENT_TIMESTAMP;
  
  SELECT 
         SUM(nvl(F.exchange_rate,0) * nvl(F.exchange_amount,0)) INTO v_totalvalueusd
    FROM workdesk.ow_ws_forex F
   WHERE F.tk_ow IN (SELECT CON.tk_ow FROM workdesk.ow_contract_worksheet CON WHERE CON.tk_contract = p_tk_contract );
  
  RETURN v_totalvalueusd;
  
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;


/***************************************************************
*
*  VALIDATE_MATCH_NOTES
*
*  Last Modify 30/12/2020   Pablo Flores 
*              28/01/2021   Pablo Flores 
*
*/ 
FUNCTION VALIDATE_MATCH_NOTES (p_TK_CONTRACT  NUMBER,
                               p_TK_OW        NUMBER,
                               pEXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 AS
                             
 n_NEW_EXECUTION_ID        NUMBER;
 v_proc                    VARCHAR2(100)   := 'VALIDATE_MATCH_NOTES';
 v_table                   VARCHAR2(100)   := 'OW_WS_NOTE AND OW_CONTRACT';
 v_starttime               TIMESTAMP;
 v_status                  ow_contract.status%TYPE;
 v_template_tk_ow          ow_contract.template_tk_ow%TYPE;
 v_type_ws_note_supplier_c ow_ws_note.note%TYPE;
 v_type_ws_note_internal_c ow_ws_note.note%TYPE; 
 v_type_ws_note_supplier_w ow_ws_note.note%TYPE;
 v_type_ws_note_internal_w ow_ws_note.note%TYPE;  
 v_return                  VARCHAR2(100);
 
BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
    
    SELECT status, template_tk_ow
      INTO v_status, v_template_tk_ow
      FROM OW_CONTRACT
     WHERE TK_CONTRACT = p_TK_CONTRACT;

    IF v_status = 'UNPUBLISHED' THEN
 
        -- OBTENER EL STRING DE LAS NOTAS POR TYPE, PRIMERO SUPPLIER Y DESPUES LAS INTERNAS, SI YA UNA TIENE DIFERENCIAS--> RETORNAL EL TEXTO

        BEGIN -- trae nota de contrato supplier
        
            SELECT note 
              INTO v_type_ws_note_supplier_c
              FROM OW_WS_NOTE
             WHERE TYPE = 'SUPPLIER'
               AND TK_OW = V_TEMPLATE_TK_OW;
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_supplier_c := 'SUPPLIER_C';
        END;            
    
    
        BEGIN -- trae nota de worksheet supplier     
        
            SELECT note 
              INTO v_type_ws_note_internal_c
              FROM OW_WS_NOTE
             WHERE TYPE = 'SUPPLIER'
               AND TK_OW = P_TK_OW;
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_internal_c := 'SUPPLIER_C';
        END;            
    
        
        BEGIN -- trae nota de contrato internal   
        
            SELECT note 
              INTO v_type_ws_note_supplier_w
              FROM OW_WS_NOTE
             WHERE TYPE = 'INTERNAL'
               AND TK_OW = V_TEMPLATE_TK_OW;       
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_supplier_w := 'INTERNAL_C';
        END;
    
    
        BEGIN -- trae nota de worksheet internal
        
            SELECT note 
              INTO v_type_ws_note_internal_w
              FROM OW_WS_NOTE
             WHERE TYPE = 'INTERNAL'
               AND TK_OW = P_TK_OW;       
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_internal_w := 'INTERNAL_C';
        END;         
         
     
        IF v_type_ws_note_supplier_c <> v_type_ws_note_internal_c OR
           v_type_ws_note_supplier_w <> v_type_ws_note_internal_w THEN
         
           --v_return := 'Note(s) do not match contract';
           v_return := 'Note(s)';
            
        ELSE
           v_return := NULL;
        END IF;
     
     
    ELSE  /* Publish */

              -- OBTENER EL STRING DE LAS NOTAS POR TYPE, PRIMERO SUPPLIER Y DESPUES LAS INTERNAS, SI YA UNA TIENE DIFERENCIAS--> RETORNAL EL TEXTO

        BEGIN -- trae nota de contrato supplier
        
            SELECT note 
              INTO v_type_ws_note_supplier_c
              FROM OW_WS_NOTE
             WHERE TYPE = 'SUPPLIER'
               AND TK_OW = V_TEMPLATE_TK_OW;
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_supplier_c := 'SUPPLIER_C';
        END;            
    
    
        BEGIN -- trae nota de worksheet supplier     
        
            SELECT note 
              INTO v_type_ws_note_internal_c
              FROM OW_WS_NOTE_PUB
             WHERE TYPE = 'SUPPLIER'
               AND TK_OW = P_TK_OW;
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_internal_c := 'SUPPLIER_C';
        END;            
    
        
        BEGIN -- trae nota de contrato internal   
        
            SELECT note 
              INTO v_type_ws_note_supplier_w
              FROM OW_WS_NOTE
             WHERE TYPE = 'INTERNAL'
               AND TK_OW = V_TEMPLATE_TK_OW;       
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_supplier_w := 'INTERNAL_C';
        END;
    
    
        BEGIN -- trae nota de worksheet internal
        
            SELECT note 
              INTO v_type_ws_note_internal_w
              FROM OW_WS_NOTE_PUB
             WHERE TYPE = 'INTERNAL'
               AND TK_OW = P_TK_OW;       
               
        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_type_ws_note_internal_w := 'INTERNAL_C';
        END;         
         
     
        IF v_type_ws_note_supplier_c <> v_type_ws_note_internal_c OR
           v_type_ws_note_supplier_w <> v_type_ws_note_internal_w THEN
         
           v_return := 'Note(s)';
            
        ELSE
           v_return := NULL;
        END IF;

    END IF;

return v_return;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;

/***************************************************************
*
*  VALIDATE_MATCH_PAYMENT_TERMS
*
*  Last Modify 05/01/2021   Pablo Flores 
*              28/01/2021   Pablo Flores
*
*/ 
FUNCTION VALIDATE_MATCH_PAYMENT_TERMS (p_TK_CONTRACT  NUMBER,
                                       p_TK_OW        NUMBER,
                                       pEXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 AS
                             
 n_NEW_EXECUTION_ID         NUMBER;
 v_proc                     VARCHAR2(100)   := 'VALIDATE_MATCH_PAYMENT_TERMS';
 v_table                    VARCHAR2(100)   := 'OW_WS_NOTE AND OW_CONTRACT';
 v_starttime                TIMESTAMP;
 v_status                   ow_contract.status%TYPE;
 v_template_tk_ow           ow_contract.template_tk_ow%TYPE;
 v_pay_term_descr_contract  ow_pur_ord.pay_term_descr%TYPE;
 v_pay_term_descr_worksheet ow_pur_ord.pay_term_descr%TYPE; 
 v_return                   VARCHAR2(100);
 
BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
    
    SELECT status, template_tk_ow
      INTO v_status, v_template_tk_ow
      FROM OW_CONTRACT
     WHERE TK_CONTRACT = p_TK_CONTRACT;

    IF v_status = 'UNPUBLISHED' THEN
 
        -- OBTENER EL STRING DE pay_term, PRIMERO contrato Y DESPUES worksheet, SI TIENE DIFERENCIAS--> RETORNAL EL TEXTO

        BEGIN -- trae pay_term de contrato 
        
            SELECT NVL(pay_term_descr,'is_null')
              INTO v_pay_term_descr_contract
              FROM OW_PUR_ORD
             WHERE TK_OW = v_template_tk_ow;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_pay_term_descr_contract := 'OW_PUR_ORD';
        END;            
              
   
        BEGIN  -- trae pay_term de contrato worksheet
        
            SELECT NVL(pay_term_descr,'is_null')
              INTO v_pay_term_descr_worksheet
              FROM OW_PUR_ORD             
             WHERE TK_OW = p_tk_ow;       

        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_pay_term_descr_worksheet := 'OW_PUR_ORD';
        END;         

     
        IF v_pay_term_descr_contract <> v_pay_term_descr_worksheet THEN
           v_return := 'Purchase Payment Terms';           
        ELSE
           v_return := NULL;
        END IF;
     
     
    ELSE /* PUBLISHED */
    
   
        BEGIN -- trae pay_term de contrato 
        
            SELECT NVL(pay_term_descr,'is_null')
              INTO v_pay_term_descr_contract
              FROM OW_PUR_ORD
             WHERE TK_OW = v_template_tk_ow;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_pay_term_descr_contract := 'OW_PUR_ORD_PUB';
        END;            
        
        BEGIN -- trae pay_term de contrato worksheet      
        
            SELECT NVL(pay_term_descr,'is_null')
              INTO v_pay_term_descr_worksheet
              FROM OW_PUR_ORD_PUB             
             WHERE TK_OW = p_tk_ow;

        EXCEPTION WHEN NO_DATA_FOUND THEN
            v_pay_term_descr_worksheet := 'OW_PUR_ORD_PUB';
        END;            
                   
    
        IF v_pay_term_descr_contract <> v_pay_term_descr_worksheet THEN         
           v_return := 'Purchase Payment Terms';         
        ELSE
           v_return := NULL;
        END IF;

    END IF;

return v_return;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;

/***************************************************************
*
*  VALIDATE_MATCH_EXCEPTIONS
*
*  Last Modify 27/01/2021   Pablo Flores 
*              28/01/2021   Pablo Flores 
*
*/ 
FUNCTION VALIDATE_MATCH_EXCEPTIONS (p_TK_CONTRACT  NUMBER,
                                       p_TK_OW        NUMBER,
                                       pEXECUTION_ID IN NUMBER default -1) RETURN VARCHAR2 AS
                             
 n_NEW_EXECUTION_ID         NUMBER;
 v_proc                     VARCHAR2(100)   := 'VALIDATE_MATCH_EXCEPTIONS';
 v_table                    VARCHAR2(100)   := 'CALL FUNCTION VALIDATE_MATCH_NOTES AND VALIDATE_MATCH_PAYMENT_TERMS AND VALIDATE_MATCH_PRD';
 v_starttime                TIMESTAMP;
 v_MATCH_NOTES              VARCHAR2(50)    := NULL;
 v_MATCH_PAYMENT            VARCHAR2(50)    := NULL;
 v_MATCH_PRD                VARCHAR2(50)    := NULL;
 v_return                   VARCHAR2(200);
 
BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
    /*llama todas la funciones de VALIDATE_MATCH_xxxxx */
    v_MATCH_NOTES := APX_WOKDSK_CONTRACT_TOOLKIT.VALIDATE_MATCH_NOTES (p_TK_CONTRACT, p_TK_OW, pEXECUTION_ID); 
    v_MATCH_PAYMENT := APX_WOKDSK_CONTRACT_TOOLKIT.VALIDATE_MATCH_PAYMENT_TERMS (p_TK_CONTRACT, p_TK_OW, pEXECUTION_ID);
    v_MATCH_PRD := APX_WOKDSK_CONTRACT_TOOLKIT.VALIDATE_MATCH_PRD (p_TK_CONTRACT, p_TK_OW, pEXECUTION_ID);
    
    
    /*concatena, separando con coma*/
    v_return := v_MATCH_NOTES; 
    
    IF LENGTH(v_return) > 0 AND LENGTH(v_MATCH_PAYMENT) > 0 THEN
        v_return := v_return || ', ' || v_MATCH_PAYMENT;
    ELSIF LENGTH(v_MATCH_PAYMENT) > 0 THEN
        v_return :=  v_MATCH_PAYMENT;
    END IF;    
    
    IF LENGTH(v_return) > 0 AND LENGTH(v_MATCH_PRD) > 0 THEN
        v_return := v_return || ', ' || v_MATCH_PRD;  
    ELSIF LENGTH(v_MATCH_PRD) > 0 THEN
        v_return :=  v_MATCH_PRD;
    END IF;      
 
    IF LENGTH(v_return) > 0 THEN
        v_return := v_return || ' do not match contract';  
    END IF; 
 

return v_return;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;


-------------------------------------------
FUNCTION SUM_LBS_CONTRACT (p_TK_CONTRACT  NUMBER,
                             pEXECUTION_ID IN NUMBER default -1) RETURN number AS
                             
 n_NEW_EXECUTION_ID     NUMBER;
 v_proc                 VARCHAR2(100)   := 'SUM_LBS_CONTRACT';
 v_table                VARCHAR2(100)   := 'ow_contract_worksheet';
 v_starttime            TIMESTAMP;
 v_status               ow_contract.status%TYPE;
 v_template_tk_ow       ow_contract.template_tk_ow%TYPE;
 v_amount_prd_contract  NUMBER;
 v_amount_prd_worksheet NUMBER;
 v_return               VARCHAR2(100);
 v_total                NUMBER;
BEGIN

    --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    
    v_total:=0;
   
    FOR R in (select WORKDESK.APX_WOKDSK_PO_TOOLKIT.f_calculate_weight_lbs(tk_ow) tl_worksheet_lbs
                from workdesk.ow_contract_worksheet 
                where tk_contract=p_tk_contract)
    loop
         v_total:=v_total+r.tl_worksheet_lbs;
    end loop;
       
return v_total;

EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;

/* Agregado Fix Contract Name - Mariano Mangiafico 19-1-2021 */                             
                             
PROCEDURE  OW_UPDATE_CONTRACT_HEADER(P_TK_CONTRACT IN NUMBER,
                                     P_CONTRACT_NAME IN VARCHAR2,
                                     pEXECUTION_ID       IN NUMBER default -1) AS
    n_NEW_EXECUTION_ID     NUMBER;
    v_proc                 VARCHAR2(100)   := 'OW_UPDATE_CONTRACT_HEADER';
    v_table                VARCHAR2(100)   := 'ow_contract';
    v_starttime            TIMESTAMP;
BEGIN
     --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
      
    UPDATE OW_CONTRACT SET NAME = P_CONTRACT_NAME
     WHERE TK_CONTRACT = P_TK_CONTRACT;
         
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
    --    OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
END;                                                                  
/* Fin Agregado Fix Contract Name - Mariano Mangiafico 19-1-2021 */

FUNCTION GET_WORKSHEET_RECORDS_JSON(
P_TK_CONTRACT      IN NUMBER,
P_EXECUTION_ID     IN NUMBER default -1
) RETURN CLOB AS
    v_prod_match   varchar2(100);
    v_note_match   varchar2(100);
    v_payment_match   varchar2(100);
    v_topub varchar2(10);
    v_txt varchar2(2000);
    v_pub_txt varchar2(2000);
    v_status varchar2(100);
    v_exceptions varchar2(500) := null;
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'GET_WORKSHEET_RECORDS_JSON';
    v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
    v_starttime         TIMESTAMP;
    v_clob_json         CLOB;
BEGIN

    --Logging Begin
    IF P_EXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := P_EXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
     
  apex_json.initialize_clob_output;
  apex_json.open_array;
          
  for r1 in (select ow.set_wrksht_num as po,
                  ord.tk_ow,
                  ord.pickup_period_descr,
                  ord.vnd_ord_num,
                  ow.status||case when ow.status = 'PUBLISHED' then ' on '||to_char(ow.last_update_date,'mm/dd/yyyy') else null end  as status,
                  ow.owner
             from workdesk.ow_worksheet ow,
                  workdesk.ow_pur_ord ord ,
                  workdesk.ow_ws_forex f
              where  ow.type = 'WORKSHEET'
              and    ow.tk_ow = ord.tk_ow 
              and    ow.tk_ow = f.tk_ow(+)
              and    ow.tk_ow in (select con.tk_ow 
                                    from workdesk.ow_contract_worksheet con 
                                   where con.tk_contract = P_TK_CONTRACT)
              order by 1 asc)
  loop
              
      workdesk.apx_wokdsk_po_toolkit.validate_status_publish_po(r1.tk_ow,v_txt,v_topub); 
      v_status:= r1.status;--||' Publish?: '||v_topub;
      if v_topub='N' then
          v_pub_txt:= v_txt;
      else
          v_pub_txt:= null;
      end if;
              
      --Validate products between contract and worksheet and Validate notes between contract and worksheet and Validate payment terms between contract and worksheet
      v_exceptions := workdesk.apx_wokdsk_contract_toolkit.VALIDATE_MATCH_EXCEPTIONS(P_TK_CONTRACT, r1.tk_ow);
              
      apex_json.open_object;
      apex_json.write('tkow',r1.tk_ow);
      apex_json.open_object('action');
          apex_json.write('label',to_char(r1.po));
      apex_json.close_object;
      apex_json.write('PO',r1.po);
      apex_json.write('ship_date',r1.pickup_period_descr);
      apex_json.write('supplier',r1.vnd_ord_num);
      apex_json.write('status',v_status);
      apex_json.write('owner',r1.owner);
      apex_json.write('exceptions',v_exceptions);
      apex_json.close_object;
          
          
  end loop;
          
  apex_json.close_array;
          
  v_clob_json := apex_json.get_clob_output;
  
  apex_json.free_output;
  
  RETURN v_clob_json;     
EXCEPTION
    WHEN OTHERS THEN    
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(P_EXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(P_EXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
END;

END;
/


GRANT EXECUTE ON WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT TO OMS;
