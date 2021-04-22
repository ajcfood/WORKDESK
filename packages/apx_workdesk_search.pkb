DROP PACKAGE BODY WORKDESK.APX_WORKDESK_SEARCH;

CREATE OR REPLACE PACKAGE BODY WORKDESK."APX_WORKDESK_SEARCH" AS
    FUNCTION GET_TEMPLATE_URL(P_TK_OW IN NUMBER,
                              P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                              P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS
        V_PAGE_ID NUMBER := 31;
    BEGIN
        IF NVL(P_NEW_SYSTEM,'N') = 'N' THEN
            V_PAGE_ID := 31;
        END IF;    
    
        RETURN APEX_PAGE.GET_URL(P_PAGE => V_PAGE_ID,
                                 P_CLEAR_CACHE => V_PAGE_ID,
                                 P_ITEMS => 'P'||V_PAGE_ID||'_TK_OW,P'||V_PAGE_ID||'_CURRENT_PO_FLAG',
                                 P_VALUES => P_TK_OW||','||P_CURRENT_PO_FLAG);
    END;                            
                              
    FUNCTION GET_WORKSHEET_URL(P_TK_OW IN NUMBER,
                               P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                               P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS
        V_PAGE_ID NUMBER := 12;
    BEGIN
        IF NVL(P_NEW_SYSTEM,'N') = 'N' THEN
            V_PAGE_ID := 8050;
        END IF;    
    
        RETURN APEX_PAGE.GET_URL(P_PAGE => V_PAGE_ID,
                                 P_CLEAR_CACHE => V_PAGE_ID,
                                 P_ITEMS => 'P'||V_PAGE_ID||'_TK_OW,P'||V_PAGE_ID||'_CURRENT_PO_FLAG',
                                 P_VALUES => P_TK_OW||','||P_CURRENT_PO_FLAG);                           
    END;                           
                               
    FUNCTION GET_CONTRACT_URL(P_TK_OW IN NUMBER,
                              P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                              P_TK_CONTRACT IN NUMBER DEFAULT NULL,
                              P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2 AS 
        V_PAGE_ID NUMBER := 8040;
    BEGIN
        IF NVL(P_NEW_SYSTEM,'N') = 'N' THEN
            V_PAGE_ID := 8060;
        END IF;    
    
        RETURN APEX_PAGE.GET_URL(P_PAGE => V_PAGE_ID,
                                 P_CLEAR_CACHE => V_PAGE_ID,
                                 P_ITEMS => 'P'||V_PAGE_ID||'_TK_OW,P'||V_PAGE_ID||'_TK_CONTRACT,P'||V_PAGE_ID||'_CURRENT_PO_FLAG',
                                 P_VALUES => P_TK_OW||','||P_TK_CONTRACT||',Y');                                               
    END;

    FUNCTION GET_WORKSHEET_SEARCH_QUERY(P_TK_EMPLOYEE IN NUMBER,
                                        P_TYPE IN VARCHAR2,
                                        P_STATUS IN VARCHAR2,
                                        P_WORKSHEET_NUMBER IN NUMBER,
                                        P_SUPPLIER IN VARCHAR2,
                                        P_DESTINATION_COUNTRY IN VARCHAR2,
                                        P_DESTINATION_REGION IN VARCHAR2,
                                        P_PURCHASER IN VARCHAR2,
                                        P_PRODUCT_DESCRIPTION IN VARCHAR2,
                                        P_DAYS IN NUMBER) RETURN VARCHAR2 AS
                                        
        V_SQL VARCHAR2(32767) := NULL;
        V_URL VARCHAR2(2000) := NULL;
    BEGIN
        CASE WHEN P_TYPE = 'WORKSHEET' THEN
                V_URL := 'WORKDESK.APX_WORKDESK_SEARCH.GET_WORKSHEET_URL(P_TK_OW => OW.TK_OW,
                                                                         P_NEW_SYSTEM => OW.NEW_OW)';
             WHEN P_TYPE = 'TEMPLATE' THEN
                V_URL := 'WORKDESK.APX_WORKDESK_SEARCH.GET_TEMPLATE_URL(P_TK_OW => OW.TK_OW,
                                                                        P_NEW_SYSTEM => OW.NEW_OW)';
             
             ELSE NULL;
        END CASE;
        
        
        V_SQL := 'SELECT  OW.CREATION_DATE, ';
        IF P_TYPE = 'TEMPLATE' THEN
            V_SQL := V_SQL||' ''<a href="''||'||V_URL||'||''">''||OW.DESCRIPTION||''</a>'' AS PO, ';
        ELSE
            V_SQL := V_SQL||' ''<a href="''||'||V_URL||'||''">''||OW.SET_WRKSHT_NUM||''</a>'' AS PO, ';
        END IF ;
        V_SQL := V_SQL||'(SELECT INITCAP(VE.VENDOR_NAME) FROM PO_VENDORS VE WHERE VENDOR_ID = NVL(ORD.VENDOR_ID,1)) AS SUPPLIER,
                          ''<a href="''||'||V_URL||'||''">''||APX_UTIL_PKG.CONVERT_INITCAP(WORKDESK.APX_ADM_PO.GET_PRODUCT_LIST_OFFER_LIST(OW.TK_OW,1))||''</a>'' AS PRODUCT,
                          (SELECT INITCAP((A.FIRST_NAME || '' '' || A.LAST_NAME)) 
                             FROM EMPLOYEE_TYPE T JOIN EMP_TYPE_CODES C ON C.TK_EMP_TYPE = T.TK_EMP_TYPE 
                                                  JOIN A_EMPLOYEE A ON T.TK_EMPLOYEE = A.TK_EMPLOYEE
                            WHERE A.TK_EMPLOYEE = ORD.TK_EMP_TRADER
                              AND EMP_TYPE_ID   = ''TRADER''
                              AND STATUS = ''A''
                              AND FIRST_NAME IS NOT NULL) AS PURCHASER,
                           CASE WHEN OW.STATUS = ''PUBLISHED'' THEN ''<p class="published">Published</p>'' ELSE ''Draft'' END STATUS,
                           CASE WHEN OW.STATUS = ''PUBLISHED'' THEN OW.LAST_UPDATE_DATE ELSE NULL END PUBLISH_DATE,
                           NULL AS CONTRACT,
                           NULL AS "expand",
                           (NVL(F.EXCHANGE_RATE,0) * NVL(F.EXCHANGE_AMOUNT,0)) as "Total Value USD", 
                           WORKDESK.APX_WOKDSK_PO_TOOLKIT.F_CALCULATE_WEIGHT_LBS(ORD.TK_OW)  as "Weight LBs",
                           OW.DESCRIPTION AS DESCRIPTION
                      FROM WORKDESK.OW_WORKSHEET OW JOIN WORKDESK.OW_PUR_ORD ORD ON OW.TK_OW = ORD.TK_OW 
                                                    JOIN WORKDESK.OW_WS_FOREX F ON OW.TK_OW = F.TK_OW       
                     WHERE OW.TYPE = '''||P_TYPE||''' 
                       AND NOT EXISTS (SELECT 1 
                                         FROM OW_CONTRACT_WORKSHEET
                                        WHERE TK_OW = OW.TK_OW)';
                                        
        IF P_TYPE = 'TEMPLATE' THEN
            V_SQL := V_SQL||' AND NOT EXISTS (SELECT 1 FROM WORKDESK.OW_CONTRACT WHERE TEMPLATE_TK_OW =  OW.TK_OW) ';
        END IF;
            
        IF P_TYPE = 'WORKSHEET' AND P_STATUS IS NULL THEN
            IF P_WORKSHEET_NUMBER IS NOT NULL THEN 
                V_SQL := V_SQL||' AND (OW.OWNER = '||P_TK_EMPLOYEE||' OR OW.STATUS = ''PUBLISHED'') AND OW.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
            ELSE
                V_SQL := V_SQL||' AND OW.OWNER = '||P_TK_EMPLOYEE;
            END IF;
        ELSE
             V_SQL := V_SQL||' AND OW.OWNER = '||P_TK_EMPLOYEE;
             V_SQL := V_SQL||' AND OW.STATUS = '''||P_STATUS||''' ';
             IF P_WORKSHEET_NUMBER IS NOT NULL THEN
                 V_SQL := V_SQL||' AND OW.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
             END IF;
        END IF;
        
        IF P_SUPPLIER IS NOT NULL THEN
            V_SQL := V_SQL||' AND NVL(ORD.VENDOR_ID,1) IN ('||REPLACE(P_SUPPLIER,':',',')||') ';
        END IF;
        
        IF P_DESTINATION_COUNTRY IS NOT NULL THEN
            V_SQL := V_SQL||' AND NVL(OW.DEST_TK_CNTRY,1) IN ('||REPLACE(P_DESTINATION_COUNTRY,':',',')||') ';
        END IF;
        
        IF P_PURCHASER IS NOT NULL THEN 
            V_SQL := V_SQL||' AND NVL(ORD.TK_EMP_TRADER,1) IN ('||REPLACE(P_PURCHASER,':',',')||') ';
        END IF;
        
        IF P_DAYS IS NOT NULL THEN
            V_SQL := V_SQL||' AND TRUNC(OW.CREATION_DATE) > (TRUNC(SYSDATE) - '||P_DAYS||') ';
        END IF;
   
        IF P_DESTINATION_REGION IS NOT NULL THEN
            V_SQL := V_SQL||' AND EXISTS (SELECT 1 
                                            FROM RGN_CNTRY RC 
                                           WHERE ACTIVE_CLOSED = ''A''
                                             AND TK_RGN IN ('||REPLACE(P_DESTINATION_REGION,':',',')||') 
                                             AND TK_CNTRY = OW.DEST_TK_CNTRY)';
        END IF;
        
        /*IF P_PRODUCT_DESCRIPTION IS NOT NULL THEN
             V_SQL := V_SQL||' AND EXISTS (SELECT 1 
                                             FROM WORKDESK.OW_PO_PRD_LINE PPL
                                            WHERE PPL.TK_OW = OW.TK_OW 
                                              AND PPL.TK_PRD IN (SELECT COLUMN_VALUE 
                                                                   FROM TABLE(APX_OW_UTIL_PKG.SEARCH_PRODUCTS('''||P_PRODUCT_DESCRIPTION||''')))) ';
        
        END IF;
        */
        RETURN V_SQL;
    END;
    
    FUNCTION GET_CONTRACT_SEARCH_QUERY(P_TK_EMPLOYEE IN NUMBER,
                                       P_STATUS IN VARCHAR2,
                                       P_WORKSHEET_NUMBER IN NUMBER,
                                       P_SUPPLIER IN VARCHAR2,
                                       P_DESTINATION_COUNTRY IN VARCHAR2,
                                       P_DESTINATION_REGION IN VARCHAR2,
                                       P_PURCHASER IN VARCHAR2,
                                       P_PRODUCT_DESCRIPTION IN VARCHAR2,
                                       P_DAYS IN NUMBER) RETURN VARCHAR2 AS
        V_SQL VARCHAR2(32767) := NULL;
        V_SQL_FILTER VARCHAR2(32767) := ' 1 = 1 ';
        V_SQL_INNER_FILTER VARCHAR2(32767) := NULL;
        V_URL VARCHAR2(2000) := NULL;
    BEGIN 
        V_URL := 'WORKDESK.APX_WORKDESK_SEARCH.GET_CONTRACT_URL(P_TK_OW => OW.TK_OW,
                                                                P_TK_CONTRACT => CO.TK_CONTRACT,
                                                                P_NEW_SYSTEM => OW.NEW_OW)';
        IF P_STATUS IS NULL THEN
            IF P_WORKSHEET_NUMBER IS NOT NULL THEN
                V_SQL_FILTER := V_SQL_FILTER||' AND (OW.OWNER = '||P_TK_EMPLOYEE||' OR OW.STATUS = ''PUBLISHED'') AND OW.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
                V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND (OW1.OWNER = '||P_TK_EMPLOYEE||' OR OW1.STATUS = ''PUBLISHED'') AND OW1.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
            ELSE
                V_SQL_FILTER := V_SQL_FILTER||' AND OW.OWNER = '||P_TK_EMPLOYEE;
                V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND OW1.OWNER = '||P_TK_EMPLOYEE;
            END IF;
        ELSE
            V_SQL_FILTER := V_SQL_FILTER||' AND OW.OWNER = '||P_TK_EMPLOYEE;
            V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND OW1.OWNER = '||P_TK_EMPLOYEE;
            
            V_SQL_FILTER := V_SQL_FILTER||' AND OW.STATUS = '''||P_STATUS||''' ';
            V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND OW1.STATUS = '''||P_STATUS||''' ';
            
            IF P_WORKSHEET_NUMBER IS NOT NULL THEN
                V_SQL_FILTER := V_SQL_FILTER||' AND OW.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
                V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND OW1.SET_WRKSHT_NUM = '||P_WORKSHEET_NUMBER;
            END IF;
        END IF;
                     
        IF P_SUPPLIER IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND NVL(ORD.VENDOR_ID,1) IN ('||REPLACE(P_SUPPLIER,':',',')||') ';
            
            V_SQL_INNER_FILTER :=  V_SQL_INNER_FILTER||' AND NVL(ORD1.VENDOR_ID,1) IN ('||REPLACE(P_SUPPLIER,':',',')||') ';
        END IF;
        
        IF P_DESTINATION_COUNTRY IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND NVL(OW.DEST_TK_CNTRY,1) IN ('||REPLACE(P_DESTINATION_COUNTRY,':',',')||') ';
            
            V_SQL_INNER_FILTER :=  V_SQL_INNER_FILTER||' AND NVL(OW1.DEST_TK_CNTRY,1) IN ('||REPLACE(P_DESTINATION_COUNTRY,':',',')||') ';
        END IF;
        
        IF P_DESTINATION_REGION IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND EXISTS (SELECT 1
                                                          FROM RGN_CNTRY RC 
                                                          WHERE ACTIVE_CLOSED = ''A''
                                                            AND NVL(OW.DEST_TK_CNTRY,1) = RC.TK_CNTRY
                                                            AND TK_RGN IN ('||REPLACE(P_DESTINATION_REGION,':',',')||')) '; 
        
            V_SQL_INNER_FILTER :=  V_SQL_INNER_FILTER||' AND EXISTS (SELECT 1
                                                                       FROM RGN_CNTRY RC1 
                                                                      WHERE RC1.ACTIVE_CLOSED = ''A''
                                                                        AND NVL(OW1.DEST_TK_CNTRY,1) = RC1.TK_CNTRY
                                                                        AND RC1.TK_RGN IN ('||REPLACE(P_DESTINATION_REGION,':',',')||'))';    
        END IF;
        
        IF P_DAYS IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND TRUNC(OW.CREATION_DATE) > (TRUNC(SYSDATE) - '||P_DAYS||') ';  
            
            V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND TRUNC(OW1.CREATION_DATE) > (TRUNC(SYSDATE) - '||P_DAYS||') '; 
        END IF;
        
        IF P_PURCHASER IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND  NVL(ORD.TK_EMP_TRADER,1)  IN ('||REPLACE(P_PURCHASER,':',',')||') ';
            
            V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND NVL(ORD1.TK_EMP_TRADER,1) IN ('||REPLACE(P_PURCHASER,':',',')||') ';
        END IF;
        /*
        IF P_PRODUCT_DESCRIPTION IS NOT NULL THEN
            V_SQL_FILTER := V_SQL_FILTER||' AND EXISTS (SELECT 1 
                                                          FROM WORKDESK.OW_PO_PRD_LINE PPL
                                                         WHERE PPL.TK_OW = OW.TK_OW 
                                                           AND PPL.TK_PRD IN (SELECT COLUMN_VALUE 
                                                                                FROM TABLE(APX_OW_UTIL_PKG.SEARCH_PRODUCTS('''||P_PRODUCT_DESCRIPTION||''')))) ';
            V_SQL_INNER_FILTER := V_SQL_INNER_FILTER||' AND EXISTS (SELECT 1 
                                                                      FROM WORKDESK.OW_PO_PRD_LINE PPL1
                                                                     WHERE PPL1.TK_OW = OW1.TK_OW 
                                                                       AND PPL1.TK_PRD IN (SELECT COLUMN_VALUE 
                                                                                            FROM TABLE(APX_OW_UTIL_PKG.SEARCH_PRODUCTS('''||P_PRODUCT_DESCRIPTION||''')))) ';
        END IF;
        */
                                   
        V_SQL := 'SELECT CO.CREATION_DATE,
                         ''<a href="''||'||V_URL||'||''">''||WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.OW_RETURN_POs(CO.TK_CONTRACT)||''</a>'' AS PO,
                         (SELECT INITCAP(VE.VENDOR_NAME) FROM PO_VENDORS VE WHERE VENDOR_ID = NVL(ORD.VENDOR_ID,1)) AS SUPPLIER,
                         ''<a href="''||'||V_URL||'||''">''||APX_UTIL_PKG.CONVERT_INITCAP(WORKDESK.APX_ADM_PO.GET_PRODUCT_LIST_OFFER_LIST(OW.TK_OW,1))||''</a>'' AS PRODUCT,
                          (SELECT INITCAP((A.FIRST_NAME || '' '' || A.LAST_NAME)) 
                             FROM EMPLOYEE_TYPE T JOIN EMP_TYPE_CODES C ON C.TK_EMP_TYPE = T.TK_EMP_TYPE 
                                                  JOIN A_EMPLOYEE A ON T.TK_EMPLOYEE = A.TK_EMPLOYEE
                            WHERE A.TK_EMPLOYEE = ORD.TK_EMP_TRADER
                              AND EMP_TYPE_ID   = ''TRADER''
                              AND STATUS = ''A''
                              AND FIRST_NAME IS NOT NULL) AS PURCHASER,
                         CASE WHEN CO.STATUS = ''PUBLISHED'' THEN ''<p class="published">Published</p>'' ELSE ''Draft'' END STATUS,
                         CASE WHEN CO.STATUS = ''PUBLISHED'' THEN CO.LAST_UPDATE_DATE ELSE NULL END PUBLISH_DATE,    
                         (SELECT COUNT(1)
                            FROM WORKDESK.OW_CONTRACT_WORKSHEET 
                           WHERE TK_CONTRACT = CO.TK_CONTRACT)||''<b> POs</b>'' AS CONTRACT,
                         ''<span class="fa fa-chevron-right offer-chevron" onclick="showDetail(''||CO.TK_CONTRACT||'',this);" ></span>
                           <span class="TK_OFFER" style="display:none">''||CO.TK_CONTRACT||''</span>'' AS "expand", 
                         WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.TOTAL_VALUE_USD(CO.TK_CONTRACT) AS "Total Value USD", 
                         WORKDESK.APX_WOKDSK_CONTRACT_TOOLKIT.SUM_LBS_CONTRACT(CO.TK_CONTRACT) AS "Weight LBs",
                         CO.NAME AS DESCRIPTION 
                    FROM WORKDESK.OW_CONTRACT CO JOIN WORKDESK.OW_WORKSHEET OW ON CO.TEMPLATE_TK_OW = OW.TK_OW
                                                 JOIN WORKDESK.OW_PUR_ORD ORD ON OW.TK_OW = ORD.TK_OW  
                     AND OW.TYPE = ''TEMPLATE'' 
                     AND (('||V_SQL_FILTER||')
                           OR EXISTS (SELECT 1
                                        FROM WORKDESK.OW_CONTRACT_WORKSHEET CW1 JOIN WORKDESK.OW_PUR_ORD ORD1 ON ORD1.TK_OW = CW1.TK_OW
                                                                                JOIN WORKDESK.OW_WORKSHEET OW1 ON OW1.TK_OW = CW1.TK_OW
                                                WHERE CW1.TK_CONTRACT = CO.TK_CONTRACT '||V_SQL_INNER_FILTER||')
                          )';
        RETURN V_SQL;
    END;         
    FUNCTION COUNT_WORKSHEETS(P_TK_EMPLOYEE IN NUMBER,
                              P_TYPE IN VARCHAR2,
                              P_STATUS IN VARCHAR2,
                              P_WORKSHEET_NUMBER IN NUMBER,
                              P_SUPPLIER IN VARCHAR2,
                              P_DESTINATION_COUNTRY IN VARCHAR2,
                              P_DESTINATION_REGION IN VARCHAR2,
                              P_PURCHASER IN VARCHAR2,
                              P_PRODUCT_DESCRIPTION IN VARCHAR2,
                              P_DAYS IN NUMBER) RETURN NUMBER AS
                              
        V_RETURN NUMBER := 0;
    BEGIN
        RETURN V_RETURN;
    END;                                                                                            
END APX_WORKDESK_SEARCH;
/
