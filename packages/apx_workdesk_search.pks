DROP PACKAGE WORKDESK.APX_WORKDESK_SEARCH;

CREATE OR REPLACE PACKAGE WORKDESK."APX_WORKDESK_SEARCH" AS
    FUNCTION GET_TEMPLATE_URL(P_TK_OW IN NUMBER,
                              P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                              P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
    
    FUNCTION GET_WORKSHEET_URL(P_TK_OW IN NUMBER,
                               P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                               P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;
                               
    FUNCTION GET_CONTRACT_URL(P_TK_OW IN NUMBER,
                              P_CURRENT_PO_FLAG IN VARCHAR2 DEFAULT 'Y',
                              P_TK_CONTRACT IN NUMBER DEFAULT NULL,
                              P_NEW_SYSTEM IN VARCHAR2 DEFAULT 'N') RETURN VARCHAR2;                          

    FUNCTION GET_WORKSHEET_SEARCH_QUERY(P_TK_EMPLOYEE IN NUMBER,
                                        P_TYPE IN VARCHAR2,
                                        P_STATUS IN VARCHAR2,
                                        P_WORKSHEET_NUMBER IN NUMBER,
                                        P_SUPPLIER IN VARCHAR2,
                                        P_DESTINATION_COUNTRY IN VARCHAR2,
                                        P_DESTINATION_REGION IN VARCHAR2,
                                        P_PURCHASER IN VARCHAR2,
                                        P_PRODUCT_DESCRIPTION IN VARCHAR2,
                                        P_DAYS IN NUMBER) RETURN VARCHAR2;
                                        
    FUNCTION GET_CONTRACT_SEARCH_QUERY(P_TK_EMPLOYEE IN NUMBER,
                                       P_STATUS IN VARCHAR2,
                                       P_WORKSHEET_NUMBER IN NUMBER,
                                       P_SUPPLIER IN VARCHAR2,
                                       P_DESTINATION_COUNTRY IN VARCHAR2,
                                       P_DESTINATION_REGION IN VARCHAR2,
                                       P_PURCHASER IN VARCHAR2,
                                       P_PRODUCT_DESCRIPTION IN VARCHAR2,
                                       P_DAYS IN NUMBER) RETURN VARCHAR2;      
                                       
    FUNCTION COUNT_WORKSHEETS(P_TK_EMPLOYEE IN NUMBER,
                              P_TYPE IN VARCHAR2,
                              P_STATUS IN VARCHAR2,
                              P_WORKSHEET_NUMBER IN NUMBER,
                              P_SUPPLIER IN VARCHAR2,
                              P_DESTINATION_COUNTRY IN VARCHAR2,
                              P_DESTINATION_REGION IN VARCHAR2,
                              P_PURCHASER IN VARCHAR2,
                              P_PRODUCT_DESCRIPTION IN VARCHAR2,
                              P_DAYS IN NUMBER) RETURN NUMBER;                                                              
END APX_WORKDESK_SEARCH;
/
