DROP PACKAGE BODY WORKDESK.APX_WORKDESK_GET_OFFER;

CREATE OR REPLACE PACKAGE BODY WORKDESK."APX_WORKDESK_GET_OFFER" AS 

PROCEDURE OW_WORKSHEET_INSERT_FROM_OFFER
IS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'OW_PO_PRD_PLANTS_COPY_INSERT';
    v_table             VARCHAR2(100)   := 'OW_PO_PRD_PLANTS';
    v_starttime         TIMESTAMP;
    v_set_wrksht_num    NUMBER := NULL;
    v_tk_ow             NUMBER := NULL;  
    pEXECUTION_ID       number := -1;
BEGIN


 --Logging Begin
    IF pEXECUTION_ID = -1 THEN
        n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
    ELSE 
        n_NEW_EXECUTION_ID := pEXECUTION_ID;
    END IF;
    v_starttime := CURRENT_TIMESTAMP;
    --Logging End
    
    SELECT  "SEQ_OW_TK"."NEXTVAL" 
    into v_tk_ow
    FROM DUAL;  

    SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
    into v_set_wrksht_num
    FROM DUAL;
    
    -- Get Offer for test
    INSERT INTO OW_WORKSHEET(
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
        ,ORIG_TK_CNTRY  )
   SELECT 
        v_tk_ow                                
        ,'Worksheet'              
        ,null as DESCRIPTION       
        ,v_set_wrksht_num as  SET_WRKSHT_NUM    
        ,1               
        ,'Unpublished'            
        ,NULL as DEST_TK_CNTRY     
        ,NULL as INSP_TK_CNTRY     
        ,null as PLANT             
        ,null as CO_TK_ORG         
        ,HEAD.CURRENCY_CODE     
        ,'lb' as  WT_UOM            
        ,SYSDATE AS CREATION_DATE           
        ,HEAD.CREATED_BY             
        ,null as INIT_TK_OW              
        ,null as OWNER             
        ,null AS DEST_PORT         
        ,null AS NOTIFY_SUBJECT    
        ,'N' AS ODS               
        ,'N' AS POSITION_PURCHASE 
        ,'UNPOSITIONED' AS PURCHASE_DECISION 
        ,NULL AS PROVINCE
        ,LINE.TK_CNTRY
  from OMS.SUP_OFFER HEAD
    INNER JOIN OMS.SUP_OFFERLN LINE  ON LINE.TK_SUP_OFFER = HEAD.TK_SUP_OFFER 
    where HEAD.TK_SUP_OFFER = 1641;
    
COMMIT;  
EXCEPTION
    WHEN OTHERS THEN    
        ROLLBACK;
        OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
        OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);  
END OW_WORKSHEET_INSERT_FROM_OFFER;


END APX_WORKDESK_GET_OFFER;
/


GRANT EXECUTE ON WORKDESK.APX_WORKDESK_GET_OFFER TO OMS;
