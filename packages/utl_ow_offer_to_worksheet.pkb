DROP PACKAGE BODY WORKDESK.UTL_OW_OFFER_TO_WORKSHEET;

CREATE OR REPLACE PACKAGE BODY WORKDESK.UTL_OW_OFFER_TO_WORKSHEET AS 

PROCEDURE CREATE_FROM_OFFER (
        p_tk_sup_offer      NUMBER,
        p_sp_terms_id        NUMBER,
        p_tk_port            NUMBER,
        p_tk_cntry           NUMBER,
        p_tk_owner              NUMBER,
        p_type           varchar2,
        p_number_worksheets     NUMBER,
        p_tk_ow             OUT NUMBER,
        Err_MSG             OUT varchar
        )
        IS
            n_NEW_EXECUTION_ID      NUMBER;
            v_proc                  VARCHAR2(100)   := 'CREATE_FROM_OFFER';
            v_table                 VARCHAR2(100)   := 'OW_WORKSHEET';
            v_starttime             TIMESTAMP;
            v_set_wrksht_num        NUMBER := NULL;
            v_tk_ow                 NUMBER := NULL;  
            pEXECUTION_ID           number := -1;
            v_vendor_id             number:=0;
            v_province              number:=0;
            v_shipment              VARCHAR2(50):=NULL;
            v_count                 number:=0;
            v_payment_terms         OW_PUR_ORD.PAY_TERM_DESCR%type := NULL;
            v_uom                   varchar2(50) := NULL;
            v_currency_code         varchar2(15):= NULL;
            v_dest_port             varchar2(50):=p_tk_port;
            v_desc                  varchar2(500) := NULL;
            v_type                  varchar2(100);
            v_Name                  varchar2(500);
            v_tk_ow_new             NUMBER := NULL;  
            v_set_wrksht_num_new    NUMBER := NULL; 
            v_TK_CONTRACT_ID        NUMBER:= NULL; 
            v_CO_TK_ORG             OW_WORKSHEET.CO_TK_ORG%type := NULL;
            v_tk_emp_trf            OW_PUR_ORD.TK_EMP_TRF%type := NULL;
            var_PURCHASER               NUMBER:= NULL; 
            var_INCOTERM                VARCHAR2(100):= NULL; 
            var_CO_TK_ORG               NUMBER:= NULL; 
            var_LOGISTICS_COORDINATOR   NUMBER:= NULL; 
            var_PURCHASE_PAYMENT_TERMS  VARCHAR2(100):= NULL; 
            var_CURRENCY_CODE           VARCHAR2(100):= NULL; 
            var_ORIGIN_COUNTRY          NUMBER:= NULL; 
            var_DEST_PORT               NUMBER:= NULL; 
              
        BEGIN
                if (p_type = 'CONTRACT') then
                    v_type:='TEMPLATE';
                else
                    v_type:='WORKSHEET';
                end if;

            --Logging Begin
                IF pEXECUTION_ID = -1 THEN
                    n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
                ELSE 
                    n_NEW_EXECUTION_ID := pEXECUTION_ID;
                END IF;
                v_starttime := CURRENT_TIMESTAMP;
            --Logging End
            
            -- Sequence inc 
                SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
                into v_tk_ow
                FROM DUAL;  

                SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
                into v_set_wrksht_num
                FROM DUAL;
            -- Sequence inc END
            -- Set v_vendor_id from Supp_Offer
                select Vendor_Id into v_vendor_id from OMS.SUP_OFFER where TK_SUP_OFFER = p_tk_sup_offer;
            -- State Rule 
                IF (p_tk_cntry in (12,3)) then
                    begin
                       
                       -- Get State from the last Worksheet from this vendor.
                          select PROVINCE into v_province      
                            from OW_PUR_ORD_pub
                            inner join OW_WORKSHEET_pub 
                                on OW_WORKSHEET_pub.TK_OW = OW_PUR_ORD_pub.TK_OW 
                            where vendor_id = v_vendor_id and owner = p_tk_owner order by OW_PUR_ORD_pub.TK_OW desc
                            FETCH FIRST ROW ONLY ;
                    Exception when no_data_found then v_province  := 0;
                    end;
                end if;
            -- State Rule END  

            -- Shipment Rule
                BEGIN
                    SELECT distinct SHIPMENT into v_shipment
                    FROM OMS.SUP_OFFERLN   
                    WHERE TK_SUP_OFFER = p_tk_sup_offer;
                  Exception when too_many_rows then v_shipment  := NULL;
                End;
                
            -- Shipment Rule  END 
            -- Payment_Term_Descr Rule 
                /*BEGIN

                    select PAY_TERM_DESCR into v_payment_terms
                    from OW_PUR_ORD 
                    where TK_OW = (select max(lastWS.TK_OW) 
                                    from OW_PUR_ORD_PUB lastWS 
                                    where vendor_id = v_vendor_id 
                                          and tk_emp_trader = p_tk_owner);
                    
                    Exception when no_data_found then v_payment_terms  := NULL;                      
                end;    */
               -- if (v_payment_terms is null ) then
                    BEGIN

                        SELECT substr(DESCRIPTION,1,25)  into v_payment_terms
                        FROM PO_VENDORS VENDORS, AP_TERMS_TL TERM
                        WHERE VENDOR_ID = v_vendor_id
                        AND VENDORS.TERMS_ID = TERM.TERM_ID;
                      Exception when no_data_found then v_payment_terms  := NULL;
                    End;
               -- end if;
            -- Payment_Term_Descr Rule END
            -- Description Rule
                v_Desc := APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(v_set_wrksht_num);
            -- Description Rule END
            
            -- v_tk_emp_trf  and Company Rule
                APX_WOKDSK_PO_TOOLKIT.GET_LAST_PUBLISHED_PO_DATA(v_VENDOR_ID, p_tk_owner,var_PURCHASER,var_INCOTERM,v_CO_TK_ORG,v_tk_emp_trf,var_PURCHASE_PAYMENT_TERMS,var_CURRENCY_CODE, var_ORIGIN_COUNTRY, var_DEST_PORT,pEXECUTION_ID);
            -- End Company Rule
            
            -- Worksheet Header insert 
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
                    ,ORIG_TK_CNTRY 
                    ,TK_SUP_OFFER
                    ,new_ow )
               SELECT 
                    v_tk_ow                                
                    ,v_type             
                    ,v_desc as DESCRIPTION --No Acepta NULL       
                    ,v_set_wrksht_num as  SET_WRKSHT_NUM    
                    ,1               
                    ,'UNPUBLISHED'            
                    ,NULL as DEST_TK_CNTRY     
                    ,NULL as INSP_TK_CNTRY     
                    ,null as PLANT             
                    ,v_CO_TK_ORG as CO_TK_ORG         
                    ,HEAD.CURRENCY_CODE     
                    ,'LB' as  WT_UOM            
                    ,SYSDATE AS CREATION_DATE           
                    ,p_tk_owner            
                    ,v_tk_ow as INIT_TK_OW  --Init Tk_OW              
                    ,p_tk_owner as OWNER             
                    ,v_dest_port AS DEST_PORT         
                    ,null AS NOTIFY_SUBJECT    
                    ,'N' AS ODS               
                    ,'N' AS POSITION_PURCHASE 
                    ,'UNPOSITIONED' AS PURCHASE_DECISION 
                    ,v_province AS PROVINCE
                    ,p_tk_cntry
                    ,p_tk_sup_offer
                    ,'Y'
              from OMS.SUP_OFFER HEAD
               -- INNER JOIN OMS.SUP_OFFERLN LINE  ON LINE.TK_SUP_OFFER = HEAD.TK_SUP_OFFER 
              where HEAD.TK_SUP_OFFER = p_tk_sup_offer;
              
              --Insert OW Sale Ord DUMMY Record
                WORKDESK.APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(v_tk_ow,n_NEW_EXECUTION_ID);
              
              INSERT INTO OW_PUR_ORD
                (TK_OW
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
                ,EXCHANGE_RATE)
              SELECT
                 v_tk_ow  
                ,HEAD.VENDOR_ID
                ,p_sp_terms_id as PURCHASE_TERMS_DESCR
                ,v_shipment
                ,NULL AS CONTACT
                ,NULL AS VND_ORD_NUM
                ,v_payment_terms as PAY_TERM_DESCR
                ,SYSDATE AS PURCHASE_DATE
                ,NVL(HEAD.TK_EMPLOYEE,p_tk_owner)
                ,v_tk_emp_trf AS TK_EMP_TRF
                ,NULL
                ,HEAD.CURRENCY_CODE
                ,NULL
                from OMS.SUP_OFFER HEAD
                where HEAD.TK_SUP_OFFER = p_tk_sup_offer;   
            -- Worksheet Header insert END
            -- UOM Variable
               BEGIN
                 select UOM,
                        currency_code
                 into   v_uom,
                        v_currency_code
                 from   OMS.SUP_OFFER  
                 where  TK_SUP_OFFER = p_tk_sup_offer;
               Exception 
                 when no_data_found then 
                   v_uom  := NULL;
                   v_currency_code  := NULL;
               END;
            --UOM Variable end
                  -- Product Insert
                 OW_WORKSHEET_INSERT_PRODUCTS(v_tk_ow,p_tk_sup_offer, 0,p_sp_terms_id, p_tk_port, v_uom,p_tk_owner,v_currency_code, pEXECUTION_ID); -- 0 Because we are not defining custom products selections for an offer
    
            -- Product Insert end
              --Insert Notes
                APX_WOKDSK_PO_DML.OW_WS_NOTE_INSERT(v_tk_ow, NULL, NULL, n_NEW_EXECUTION_ID);
                --Insert Foreign Echange Information
                APX_WOKDSK_PO_DML.OW_WS_FOREX_INSERT(v_tk_ow, NULL, NULL,NULL, NULL,NULL, n_NEW_EXECUTION_ID);  
--                OW_WS_FOREX_INSERT(v_tk_ow, p_BANK_DESCR, p_EXCHANGE_RATE,p_EXCHANGE_AMOUNT, p_CONTRACT_NUMBER,p_VALUATION_DATE, n_NEW_EXECUTION_ID);    
                --Insert Purchaser table   
                p_tk_ow := v_tk_ow;
                
                -- Condition To create Contract based on the P_TYPE
                if (p_type = 'CONTRACT') then
                    begin
                        --P_NameRule
                        BEGIN
                            select vendor_name into v_Name from PO_VENDORS where vendor_id = v_vendor_id;
                            Exception when no_data_found then v_Name  := 'TBD';
                        end;
                        --End P_NameRule
                        -- Insert into Contract
                            --Generate tk_contract_id 
                                SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL" 
                                into v_TK_CONTRACT_ID
                                FROM DUAL;    

                                --Create a new contract
                                 APX_WOKDSK_PO_DML.OW_CONTRACT_INSERT(v_tk_ow , v_TK_CONTRACT_ID, v_Name, 'UNPUBLISHED', p_tk_owner, SYSDATE,SYSDATE, p_tk_owner, 'N');   
                        -- End Insert into Contract
                        -- Loop to Insert N Worksheet
                            FOR i in 1..p_number_worksheets
                             LOOP
                                -- Change v_type as worksheet instead of TEMPLATE
                                v_type := 'WORKSHEET';
                                
                                --Incremento la Secuencia v_tk_ow_new
                                   SELECT WORKDESK.SEQ_OW_TK.NEXTVAL into v_tk_ow_new FROM DUAL;
                                    
                                -- Incremento la secuencia de v_set_wrksht_num_new
                                  SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" INTO v_set_wrksht_num_new FROM DUAL;
                                   

                                APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(v_tk_ow, v_Type ,v_tk_ow_new ,v_set_wrksht_num_new , p_tk_owner , n_NEW_EXECUTION_ID);
                                
                                -- insert into the Mapping table contract_Worksheet
                                INSERT INTO ow_contract_worksheet(tk_contract,tk_ow,creation_date,created_by, last_update_date, last_updated_by,init_tk_ow)
                                VALUES (v_TK_CONTRACT_ID,v_tk_ow_new, SYSDATE,p_tk_owner, NULL, NULL,v_tk_ow_new );
                                --dbms_output.put_line(i);
                        
                            END LOOP;
                        -- End Loop
                    end;
                end if;
        COMMIT;  
        EXCEPTION
            WHEN OTHERS THEN    
                ROLLBACK;
                OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
                OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
                Err_MSG :=  'An error was encountered - ERROR- '||SQLERRM;
                p_tk_ow := NULL;
END CREATE_FROM_OFFER;

PROCEDURE OW_WORKSHEET_INSERT_PRODUCTS(
        p_tk_ow             NUMBER,
        p_tk_sup_offer      NUMBER,
        p_tk_sup_offerln    NUMBER,
        p_sp_terms_id        NUMBER,
        p_tk_port            NUMBER,
        p_uom               varchar2,
        p_tk_owner          number,
        p_currency_code     varchar2,
        pEXECUTION_ID         IN NUMBER
        ) 
        IS
        v_starttime         TIMESTAMP;
        v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_INSERT_PRODUCTS';
        v_table             VARCHAR2(100)   := 'OW_WS_PRD_LINE';    
        v_user_Desc         varchar2(100)   := NULL;
    BEGIN
        --Logging Begin
           v_starttime := CURRENT_TIMESTAMP;
        --Logging End    
        --Insert into OW_WS_PRD_LINE
        DECLARE
              rownumber integer :=0;
              v_price_cs numeric(13,5);
              v_price_wt numeric(13,5);
              v_price numeric(13,5);
              v_prodDescr varchar2(4000):=NULL;
              v_packDescr varchar2(4000):=NULL;
              CURSOR cProducts IS
              select LINE.TK_SUP_OFFERLN
                ,LINE.QTY
                ,LINE.Qty_uom
                ,LINE.tk_prd_pack
                ,LINE.valid_through
                ,LINE.TK_Cntry
                ,LINE.Is_halal
                ,LINE.Is_Prc
                ,LINE.tk_prd
                from OMS.SUP_OFFERln LINE 
                where LINE.TK_SUP_OFFER =  p_tk_sup_offer 
                    and LINE.status not in ('DRAFT','DELETED');
                prodLine cProducts%ROWTYPE;
        BEGIN
              FOR prodLine IN cProducts
           LOOP

                --Price Rule
                Begin
                    select Sum(Price) into v_price from OMS.SUP_OFFERln_PRICE where  TK_SUP_OFFERln = prodLine.tk_sup_offerln and sp_terms_id =p_sp_terms_id and tk_port = p_tk_port;
                    Exception when no_data_found then v_price  := 0; 
                End;
                if (prodLine.QTY_UOM = 'CS') then
                    BEGIN
                        v_price_wt  := 0;
                       v_price_cs := v_price;         
                    END;
                   ELSE
                    BEGIN
                        v_price_wt := v_price; 
                        v_price_cs  := 0;
        
                    END;
                   
                   end if; 
                  
                --Price Rule END
           
                 insert into OW_WS_PRD_LINE
                    (TK_OW
                    ,LINE_NUM
                    ,CASES
                    ,WEIGHT
                    ,WT_UOM
                    ,SELL_DESCR
                    ,PUR_DESCR
                    ,PROPRIETARY
                    ,TK_SUP_OFFERLN
                    )
                 values(
                   p_tk_ow,
                   rownumber,
                   case when prodLine.QTY_UOM = 'CS' then prodLine.QTY else 0 end,
                   case when prodLine.QTY_UOM not in ('CS','FCL','TL') then prodLine.QTY else 0 end,
                   case when prodLine.QTY_UOM in ('CS', 'FCL','TL') then NULL else prodLine.QTY_UOM  end,
                   NULL,
                   GET_PUR_DESCR(p_tk_sup_offer,prodLine.TK_SUP_OFFERLN),--PENDING debo definir el description del producto
                   'N',
                   prodLine.TK_SUP_OFFERLN
                 ) ;
                 --END OW_WS_PRD_LINE
             
                --Product Description Rule
                Begin 
                    select base_descr into v_prodDescr from atisprod.product where TK_PRD = prodLine.tk_prd;
                    Exception when no_data_found then v_prodDescr  := ''; 
                end;
                Begin
                    select descr into v_packDescr from ATISPROD.PACKAGING where TK_PRD_pack = prodLine.tk_prd_pack;
                    Exception when no_data_found then v_packDescr  := ''; 
                end;
                --Product Description Rule END
               -- User Description Rule
                    begin
                        select oracle_user into v_user_Desc from a_employee where full_name like 'SORAYA%'; 
                        Exception when no_data_found then v_user_Desc  := p_tk_owner;       
                    end;
                -- END User Description Rule

                insert into OW_PO_PRD_LINE (
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
                    )
                    values (
                    p_tk_ow
                   ,rownumber
                    ,NUll-- v_price_cs
                    ,NULL--v_price_wt
                    ,p_uom
                   ,p_currency_code
                    ,prodline.TK_PRD
                   ,sysdate
                   ,v_user_Desc
                    ,sysdate
                    ,v_user_Desc
                    ,p_currency_code--PER
                    ,prodline.tk_prd_pack
                    ,v_prodDescr || ' ' || v_packDescr--PRD_BUY_DESCR
                    );

                -- Insert Plants
                   insert into WORKDESK.ow_po_prd_plants (tk_ow, line_num , tk_prd_plant)
                   SELECT p_tk_ow, rownumber, tk_prd_plant FROM OMS.SUP_OFFERLN_PLANT WHERE TK_SUP_OFFERLN = PRODLINE.TK_SUP_OFFERLN;
                -- Insert Plants END
                rownumber := rownumber +1;
           END LOOP;
           --Insert into OW_WS_PRD_LINE END
           
           
      END;  
          
        EXCEPTION
        WHEN OTHERS THEN    
            ROLLBACK;
            OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);                  
END OW_WORKSHEET_INSERT_PRODUCTS;

    PROCEDURE CREATE_FROM_OFFERLN(
            p_share_a_offerLNs   IN arrayofOFFERLN,
            p_sp_terms_id        NUMBER,
            p_tk_port            NUMBER,
            p_tk_cntry           NUMBER,
            p_tk_owner              NUMBER,
            p_type           varchar2,
            p_number_worksheets     NUMBER,
            p_tk_ow             OUT NUMBER,
            Err_MSG             OUT varchar2             
    )
    IS
        v_tk_sup_offer      number  := NULL;
        v_uom               varchar2(50) :=NULL;
        v_currency_code     varchar2(15):= NULL;
        v_tk_ow             number:=null;
        n_NEW_EXECUTION_ID  NUMBER;
        v_proc              VARCHAR2(100)   := 'CREATE_FROM_OFFERLN';
        v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
        v_starttime         TIMESTAMP;  
        pEXECUTION_ID       number := -1;
        v_rownumber         number := 0;
        v_type              varchar2(50);
        v_Name              varchar2(100);
        v_vendor_id         number:=0;
        v_tk_contract_id    number:=0;
        v_tk_ow_new         number:=0;
        v_set_wrksht_num_new    number:=0;
        v_shipment          ow_pur_ord.PICKUP_PERIOD_DESCR%type:=NULL;
        v_shipmentln          ow_pur_ord.PICKUP_PERIOD_DESCR%type:=NULL;
    BEGIN
         --Logging Begin
                IF pEXECUTION_ID = -1 THEN
                    n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
                ELSE 
                    n_NEW_EXECUTION_ID := pEXECUTION_ID;
                END IF;
                v_starttime := CURRENT_TIMESTAMP;
            --Logging End

        -- Shipment Rule 
            select SHIPMENT into v_shipment from oms.sup_offerln where tk_sup_offerln = p_share_a_offerLNs(1);
            
            FOR i in 1..p_share_a_offerLNs.count
            LOOP
                select SHIPMENT into v_shipmentln from oms.sup_offerln where tk_sup_offerln = p_share_a_offerLNs(i);
                if (v_shipment <> v_shipmentln) then
                    v_shipment := null;
                end if;
            END LOOP;

            
         --End Shipment Rule
         FOR i in 1..p_share_a_offerLNs.count
         LOOP


            --Insert Header from OfferLN
                if( i =1)then -- Only 1 header
                  if (p_type = 'CONTRACT') then
                        v_type:='TEMPLATE';
                    else
                        v_type:='WORKSHEET';
                    end if;


                    CREATE_HEADERS_FROM_OFFERLN(p_share_a_offerLNs(i), p_sp_terms_id,p_tk_port,p_tk_cntry,p_tk_owner,v_type, v_shipment, v_tk_sup_offer,v_tk_ow);
                    
                    DECLARE
                      v_count number := null;
                    BEGIN
                      SELECT COUNT(DISTINCT tk_sup_offer)
                      INTO   v_count
                      FROM   oms.sup_offerln 
                      WHERE  tk_sup_offerln IN (select column_value 
                                                from table(p_share_a_offerLNs));

                      IF v_count = 1 THEN
                        UPDATE OW_WORKSHEET
                        SET    TK_SUP_OFFER = (SELECT tk_sup_offer FROM oms.sup_offerln WHERE tk_sup_offerln IN (select column_value from table(p_share_a_offerLNs)) AND ROWNUM = 1)
                        WHERE  TK_OW = v_tk_ow;
                      END IF;
                    END;

                end if;
                -- UOM Variable
               BEGIN
                    select UOM into v_uom from OMS.SUP_OFFER  where TK_SUP_OFFER = v_tk_sup_offer;
                    Exception when no_data_found then v_uom  := NULL;
               END;
               BEGIN
                    select currency_code into v_currency_code from OMS.SUP_OFFER  where TK_SUP_OFFER = v_tk_sup_offer;
                    Exception when no_data_found then v_currency_code  := NULL;
               END;
                --UOM Variable end
                -- ProductLine Insert
                OW_WORKSHEET_INSERT_PRODUCTLN(v_tk_ow,p_share_a_offerLNs(i), p_sp_terms_id, p_tk_port, v_uom,p_tk_owner,v_currency_code, pEXECUTION_ID, v_rownumber); -- 0 Because we are not defining custom products selections for an offer
                -- Product Insert end
                v_rownumber := v_rownumber+1;
    
        END LOOP;

         --Insert Notes
        APX_WOKDSK_PO_DML.OW_WS_NOTE_INSERT(v_tk_ow, NULL, NULL, n_NEW_EXECUTION_ID);
        --Insert Foreign Echange Information
        APX_WOKDSK_PO_DML.OW_WS_FOREX_INSERT(v_tk_ow, NULL, NULL,NULL, NULL,NULL, n_NEW_EXECUTION_ID);  
--                OW_WS_FOREX_INSERT(v_tk_ow, p_BANK_DESCR, p_EXCHANGE_RATE,p_EXCHANGE_AMOUNT, p_CONTRACT_NUMBER,p_VALUATION_DATE, n_NEW_EXECUTION_ID);    
        --Insert Purchaser table   
         p_tk_ow := v_tk_ow;
        
        -- Set v_vendor_id from Supp_Offer
            select Vendor_Id into v_vendor_id from OMS.SUP_OFFER where TK_SUP_OFFER = v_tk_sup_offer;
        -- Condition To create Contract based on the P_TYPE
                if (p_type = 'CONTRACT') then
                    begin
                        --P_NameRule
                        BEGIN
                            select vendor_name into v_Name from PO_VENDORS where vendor_id = v_vendor_id;
                            Exception when no_data_found then v_Name  := 'TBD';
                        end;
                        --End P_NameRule
                        -- Insert into Contract
                            --Generate tk_contract_id 
                                SELECT "WORKDESK"."SEQ_OW_TK_CONTRACT"."NEXTVAL" 
                                into v_TK_CONTRACT_ID
                                FROM DUAL;    

                                --Create a new contract
                                 APX_WOKDSK_PO_DML.OW_CONTRACT_INSERT(v_tk_ow , v_TK_CONTRACT_ID, v_Name, 'UNPUBLISHED', p_tk_owner, SYSDATE,SYSDATE, p_tk_owner, 'N');   
                        -- End Insert into Contract
                        -- Loop to Insert N Worksheet
                            FOR i in 1..p_number_worksheets
                             LOOP
                                -- Change v_type as worksheet instead of TEMPLATE
                                v_type := 'WORKSHEET';
                                
                                --Incremento la Secuencia v_tk_ow_new
                                   SELECT WORKDESK.SEQ_OW_TK.NEXTVAL into v_tk_ow_new FROM DUAL;
                                    
                                -- Incremento la secuencia de v_set_wrksht_num_new
                                  SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" INTO v_set_wrksht_num_new FROM DUAL;
                                   
                                --COPY_WORKSHEET_DATA(v_tk_ow_ori, p_Type ,p_NEW_TK_OW ,p_NEW_WORKSHEET_NUM , p_TK_EMPLOYEE , pEXECUTION_ID IN NUMBER default -1)
                                APX_WOKDSK_PO_TOOLKIT.COPY_WORKSHEET_DATA(v_tk_ow, v_Type ,v_tk_ow_new ,v_set_wrksht_num_new , p_tk_owner , n_NEW_EXECUTION_ID);
                                
                                -- insert into the Mapping table contract_Worksheet
                                INSERT INTO ow_contract_worksheet (tk_contract,tk_ow,creation_date,created_by, last_update_date, last_updated_by,init_tk_ow)
                                VALUES (v_TK_CONTRACT_ID,v_tk_ow_new, SYSDATE,p_tk_owner, NULL, NULL,v_tk_ow_new );
                                --dbms_output.put_line(i);
                        
                            END LOOP;
                        -- End Loop
                    end;
                end if;
                
         COMMIT;  
        EXCEPTION
            WHEN OTHERS THEN    
                ROLLBACK;
                OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
                OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME); 
                Err_MSG :=  'An error was encountered - ERROR- '||SQLERRM;
                p_tk_ow := NULL;

    END CREATE_FROM_OFFERLN;
    
    PROCEDURE CREATE_HEADERS_FROM_OFFERLN (
            p_tk_sup_offerln      NUMBER,
            p_sp_terms_id        NUMBER,
            p_tk_port            NUMBER,
            p_tk_cntry           NUMBER,
            p_tk_owner              NUMBER,
            p_type           varchar2,
            p_shipment      varchar2,
            p_tk_sup_offer         OUT NUMBER,
            p_tk_ow                 OUT NUMBER
    )
    IS
    
         n_NEW_EXECUTION_ID  NUMBER;
            v_proc              VARCHAR2(100)   := 'CREATE_HEADERS_FROM_OFFERLN';
            v_table             VARCHAR2(100)   := 'OW_WORKSHEET';
            v_starttime         TIMESTAMP;
            v_set_wrksht_num    NUMBER := NULL;
            v_tk_ow             NUMBER := NULL;  
            pEXECUTION_ID       number := -1;
            v_vendor_id         number:=0;
            v_province          number:=0;
            v_count             number:=0;
            v_payment_terms         OW_PUR_ORD.PAY_TERM_DESCR%type := NULL;
            v_uom               varchar2(50) := NULL;
            v_currency_code     varchar2(15):= NULL;
            v_tk_sup_offer      NUMBER:=0;
             v_dest_port         varchar2(50):=p_tk_port;
             v_desc              varchar2(500) := NULL;
             v_CO_TK_ORG             OW_WORKSHEET.CO_TK_ORG%type := NULL;
            v_tk_emp_trf            OW_PUR_ORD.TK_EMP_TRF%type := NULL;
            var_PURCHASER               NUMBER:= NULL; 
            var_INCOTERM                VARCHAR2(100):= NULL; 
            var_CO_TK_ORG               NUMBER:= NULL; 
            var_LOGISTICS_COORDINATOR   NUMBER:= NULL; 
            var_PURCHASE_PAYMENT_TERMS  VARCHAR2(100):= NULL; 
            var_CURRENCY_CODE           VARCHAR2(100):= NULL; 
            var_ORIGIN_COUNTRY          NUMBER:= NULL; 
            var_DEST_PORT               NUMBER:= NULL; 
    BEGIN

            --Logging Begin
                IF pEXECUTION_ID = -1 THEN
                    n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
                ELSE 
                    n_NEW_EXECUTION_ID := pEXECUTION_ID;
                END IF;
                v_starttime := CURRENT_TIMESTAMP;
            --Logging End
            
            -- Sequence inc 
                SELECT "WORKDESK"."SEQ_OW_TK"."NEXTVAL" 
                into v_tk_ow
                FROM DUAL;  
                
                SELECT "ATISPROD"."SEQ_WORKSHEET"."NEXTVAL" 
                into v_set_wrksht_num
                FROM DUAL;
                p_tk_ow:=v_tk_ow;
            -- Sequence inc END
            --  Set v_tk_sup_offer
                Begin
                    select max(tk_sup_offer) into v_tk_sup_offer from oms.sup_offerln where tk_sup_offerln = p_tk_sup_offerln;
                     Exception when no_data_found then v_tk_sup_offer  := 0;
                End;
                
            --  Set v_tk_sup_offerEND
            -- Set v_vendor_id from Supp_Offer
                Begin
                    select Vendor_Id into v_vendor_id from OMS.SUP_OFFER where TK_SUP_OFFER = v_tk_sup_offer;
                    Exception when no_data_found then v_vendor_id  := 0;
                end;
            -- State Rule 
                IF (p_tk_cntry in (12,3)) then
                    begin
                       
                       -- Get State from the last Worksheet from this vendor.
                          select PROVINCE into v_province      
                            from OW_PUR_ORD_pub
                            inner join OW_WORKSHEET_pub 
                                on OW_WORKSHEET_pub.TK_OW = OW_PUR_ORD_pub.TK_OW 
                            where vendor_id = v_vendor_id and owner = p_tk_owner order by OW_PUR_ORD_pub.TK_OW desc
                            FETCH FIRST ROW ONLY ;
                    Exception when no_data_found then v_province  := 0;
                    end;
                end if;
            -- State Rule END   

            -- Payment_Term_Descr Rule 
              /*  BEGIN
                    
                    select PAY_TERM_DESCR into v_payment_terms
                    from OW_PUR_ORD 
                    where TK_OW = (select max(lastWS.TK_OW) 
                                    from OW_PUR_ORD_PUB lastWS 
                                    where vendor_id = v_vendor_id 
                                          and tk_emp_trader = p_tk_owner);
                    
                    Exception when no_data_found then v_payment_terms  := NULL;                      
                end;    */
               -- if (v_payment_terms is null ) then
                    BEGIN

                        SELECT substr(DESCRIPTION,1,25)  into v_payment_terms
                        FROM PO_VENDORS VENDORS, AP_TERMS_TL TERM
                        WHERE VENDOR_ID = v_vendor_id
                        AND VENDORS.TERMS_ID = TERM.TERM_ID;
                      Exception when no_data_found then v_payment_terms  := NULL;
                    End;
             --   end if;
            -- Payment_Term_Descr Rule END
            
            -- Description Rule
                v_Desc := APX_WOKDSK_PO_TOOLKIT.PO_SET_SUPPLIER_DESCRIPTION(v_set_wrksht_num);
            -- Description Rule END
             
             -- v_tk_emp_trf  and Company Rule
                APX_WOKDSK_PO_TOOLKIT.GET_LAST_PUBLISHED_PO_DATA(v_VENDOR_ID, p_tk_owner,var_PURCHASER,var_INCOTERM,v_CO_TK_ORG,v_tk_emp_trf,var_PURCHASE_PAYMENT_TERMS,var_CURRENCY_CODE, var_ORIGIN_COUNTRY, var_DEST_PORT,pEXECUTION_ID);
            -- End Company Rule 

            -- Worksheet Header insert 
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
                    ,ORIG_TK_CNTRY 
                    ,TK_SUP_OFFER 
                    ,NEW_OW)
               SELECT 
                    v_tk_ow                                
                    ,p_type             
                    ,v_desc as DESCRIPTION --No Acepta NULL       
                    ,v_set_wrksht_num as  SET_WRKSHT_NUM    
                    ,1               
                    ,'UNPUBLISHED'            
                    ,NULL as DEST_TK_CNTRY     
                    ,NULL as INSP_TK_CNTRY     
                    ,null as PLANT             
                    ,v_CO_TK_ORG as CO_TK_ORG         
                    ,HEAD.CURRENCY_CODE     
                    ,'LB' as  WT_UOM            
                    ,SYSDATE AS CREATION_DATE           
                    ,p_tk_owner            
                    ,v_tk_ow as INIT_TK_OW  --Init Tk_OW              
                    ,p_tk_owner as OWNER             
                    ,v_dest_port AS DEST_PORT         
                    ,null AS NOTIFY_SUBJECT    
                    ,'N' AS ODS               
                    ,'N' AS POSITION_PURCHASE 
                    ,'UNPOSITIONED' AS PURCHASE_DECISION 
                    ,v_province AS PROVINCE
                    ,p_tk_cntry
                    ,NULL as tk_sup_offer
                    ,'Y'
              from OMS.SUP_OFFER HEAD
              where HEAD.TK_SUP_OFFER = v_tk_sup_offer;
              
                --Insert OW Sale Ord DUMMY Record
                WORKDESK.APX_WOKDSK_PO_DML.OW_SALE_ORD_INSERT_DUMMY(v_tk_ow,n_NEW_EXECUTION_ID);
              
              
              INSERT INTO OW_PUR_ORD
                (TK_OW
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
                ,EXCHANGE_RATE)
              SELECT
                  v_tk_ow  
                ,HEAD.VENDOR_ID
                ,p_sp_terms_id as PURCHASE_TERMS_DESCR
                ,p_shipment
                ,NULL AS CONTACT
                ,NULL AS VND_ORD_NUM
                ,v_payment_terms as PAY_TERM_DESCR
                ,SYSDATE AS PURCHASE_DATE
                ,NVL(HEAD.TK_EMPLOYEE,p_tk_owner)
                ,v_tk_emp_trf AS TK_EMP_TRF
                ,NULL
                ,HEAD.CURRENCY_CODE
                ,NULL
                from OMS.SUP_OFFER HEAD
                where HEAD.TK_SUP_OFFER = v_tk_sup_offer;   
            -- Worksheet Header insert END
                p_tk_sup_offer := v_tk_sup_offer;
        COMMIT;   
        EXCEPTION
            WHEN OTHERS THEN    
                ROLLBACK;
                OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);    
                OMS.AUDIT_LOGGER.SEND_NOTIFICATION(pEXECUTION_ID,'FAIL: Execution Status Email - ' || CONST_PACKAGE_NAME);
    END CREATE_HEADERS_FROM_OFFERLN;
    
    PROCEDURE OW_WORKSHEET_INSERT_PRODUCTLN(
       p_tk_ow             NUMBER,
            p_tk_sup_offerln    NUMBER,
            p_sp_terms_id        NUMBER,
            p_tk_port            NUMBER,
            p_uom               varchar2,
            p_tk_owner          number,
            p_currency_code     varchar2,
            pEXECUTION_ID         IN NUMBER,
            p_rownumber         number
    )
    IS
    
             v_starttime         TIMESTAMP;
            v_proc              VARCHAR2(100)   := 'OW_WORKSHEET_INSERT_PRODUCTLN';
            v_table             VARCHAR2(100)   := 'OW_WS_PRD_LINE';    
            
     BEGIN
        --Logging Begin
           v_starttime := CURRENT_TIMESTAMP;
        --Logging End    
        --Insert into OW_WS_PRD_LINE
        DECLARE
     
              v_price_cs numeric(13,5);
              v_price_wt numeric(13,5);
              v_price numeric(13,5);
              v_prodDescr varchar2(4000):=NULL;
              v_packDescr varchar2(4000):=NULL;
              v_user_Desc varchar2(100):=NULL;
              CURSOR cProducts IS
              select LINE.TK_SUP_OFFERLN
                ,LINE.QTY
                ,LINE.Qty_uom
                ,LINE.tk_prd_pack
                ,LINE.valid_through
                ,LINE.TK_Cntry
                ,LINE.Is_halal
                ,LINE.Is_Prc
                ,LINE.tk_prd
                ,LINE.tk_sup_offer
                from OMS.SUP_OFFERln LINE 
                where LINE.TK_SUP_OFFERLN =  p_tk_sup_offerln 
                    and LINE.status not in ('DRAFT','DELETED');
                prodLine cProducts%ROWTYPE;
        BEGIN
          FOR prodLine IN cProducts
           LOOP

                --Price Rule
                Begin
                    select Sum(Price) into v_price from OMS.SUP_OFFERln_PRICE where  TK_SUP_OFFERln = prodLine.tk_sup_offerln and sp_terms_id =p_sp_terms_id and tk_port = p_tk_port;
                    Exception when no_data_found then v_price  := 0; 
                End;
                if (prodLine.QTY_UOM = 'CS') then
                    BEGIN
                        v_price_wt  := 0;
                       v_price_cs := v_price;         
                    END;
                   ELSE
                    BEGIN
                        v_price_wt := v_price; 
                        v_price_cs  := 0;
        
                    END;
                   
                end if; 
         
                --Price Rule END
                 --Product Description Rule
                Begin 
                    select base_descr into v_prodDescr from atisprod.product where TK_PRD = prodLine.tk_prd;
                    Exception when no_data_found then v_prodDescr  := ''; 
                end;
                Begin
                    select descr into v_packDescr from ATISPROD.PACKAGING where TK_PRD_pack = prodLine.tk_prd_pack;
                    Exception when no_data_found then v_packDescr  := ''; 
                end;
                --Product Description Rule END

                 insert into OW_WS_PRD_LINE
                    (TK_OW
                    ,LINE_NUM
                    ,CASES
                    ,WEIGHT
                    ,WT_UOM
                    ,SELL_DESCR
                    ,PUR_DESCR
                    ,PROPRIETARY
                    ,TK_SUP_OFFERLN
                    )
                 values(
                   p_tk_ow,
                   p_rownumber,
                   case when prodLine.QTY_UOM = 'CS' then prodLine.QTY else 0 end,
                   case when prodLine.QTY_UOM not in ('CS','FCL','TL') then prodLine.QTY else 0 end,
                   case when prodLine.QTY_UOM in ('CS', 'FCL','TL') then NULL else prodLine.QTY_UOM  end,
                   NULL,
                   GET_PUR_DESCR(prodLine.tk_sup_offer,p_tk_sup_offerln),--v_prodDescr || ' ' || v_packDescr,--PENDING debo definir el description del producto
                   'N',
                   prodLine.TK_SUP_OFFERLN
                 ) ;
                 --END OW_WS_PRD_LINE
             
               
               -- User Description Rule
                    begin
                        select oracle_user into v_user_Desc from a_employee where full_name like 'SORAYA%'; 
                        Exception when no_data_found then v_user_Desc  := p_tk_owner;       
                    end;
                -- END User Description Rule

                insert into OW_PO_PRD_LINE (
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
                    )
                    values (
                    p_tk_ow
                   ,p_rownumber
                    ,NUll--v_price_cs
                    ,NUll--v_price_wt
                    ,p_uom
                   ,p_currency_code
                    ,prodline.TK_PRD
                   ,sysdate
                   ,v_user_Desc
                    ,sysdate
                    ,v_user_Desc
                    ,p_currency_code--PER
                    ,prodline.tk_prd_pack
                    ,NULL --PRD_BUY_DESCR
                    );

                -- Insert Plants
                   insert into WORKDESK.ow_po_prd_plants (tk_ow, line_num , tk_prd_plant)
                   SELECT p_tk_ow, p_rownumber, tk_prd_plant FROM OMS.SUP_OFFERLN_PLANT WHERE TK_SUP_OFFERLN = PRODLINE.TK_SUP_OFFERLN;
                -- Insert Plants END

           END LOOP;
           --Insert into OW_WS_PRD_LINE END
           
           
      END;  
          
            EXCEPTION
               WHEN OTHERS THEN    
                    ROLLBACK;
          OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);                  

    END OW_WORKSHEET_INSERT_PRODUCTLN; 

FUNCTION GET_PUR_DESCR(
p_tk_sup_offer      IN NUMBER,
p_tk_sup_offerln    IN NUMBER,
pEXECUTION_ID       IN NUMBER default -1
) RETURN VARCHAR2 AS
    n_NEW_EXECUTION_ID  NUMBER;
    v_proc              VARCHAR2(100)   := 'GET_PUR_DESCR';
    v_table             VARCHAR2(100)   := 'SUP_OFFER';
    v_starttime         TIMESTAMP;
    v_base_descr  varchar2(4000);
    v_size_descr  varchar2(4000);
    v_grade_descr varchar2(4000);
    v_brand_descr varchar2(4000);
    v_pack_descr  varchar2(4000); 
    v_vendor_id    number;
    v_user         varchar2(500);
BEGIN

  --Logging Begin
  IF pEXECUTION_ID = -1 THEN
      n_NEW_EXECUTION_ID := OMS.AUDIT_LOGGER.GET_EXECUTION_ID(-1);
  ELSE 
      n_NEW_EXECUTION_ID := pEXECUTION_ID;
  END IF;
  v_starttime := CURRENT_TIMESTAMP;
  --Logging End
  
select pro.base_descr prod_desc, 
       (SELECT pac.DESCR FROM atisprod.packaging pac WHERE LINE.TK_PRD_PACK = pac.TK_PRD_PACK) PACK,
       (SELECT SIZ.DESCR FROM atisprod.PRD_SIZE SIZ WHERE SIZ.TK_PRD_SIZE = pro.TK_PRD_SIZE) SIZ,
       (SELECT GRA.DESCR FROM atisprod.PRD_GRADE GRA WHERE GRA.TK_PRD_GRADE = pro.TK_PRD_GRADE) GRADE,
       (SELECT BRA.DESCR FROM atisprod.PRD_BRAND BRA WHERE BRA.TK_PRD_BRAND = pro.TK_PRD_BRAND) BRAND
INTO   v_base_descr,
       v_pack_descr,
       v_size_descr ,
       v_grade_descr,
       v_brand_descr
from   OMS.SUP_OFFERln LINE,
       atisprod.product pro
WHERE  line.tk_prd = pro.tk_prd
AND    LINE.TK_SUP_OFFERLN = p_tk_sup_offerln;

select VENDOR_ID,
       LINE.TK_EMPLOYEE
INTO   v_vendor_id  ,
       v_user
from   OMS.SUP_OFFER LINE
WHERE  LINE.TK_SUP_OFFER = p_tk_sup_offer;

RETURN OMS.UTL_PRODUCT_TOOLKIT.GET_REVERSE_PRD_BUY_DESCR
                                   (v_base_descr ,
                                    v_size_descr ,
                                    v_grade_descr,
                                    v_brand_descr,
                                    v_pack_descr , 
                                    v_vendor_id  ,
                                    v_user );

EXCEPTION
  WHEN OTHERS THEN    
    ROLLBACK;
    OMS.AUDIT_LOGGER.ADD_LOG_ENTRY(pEXECUTION_ID, CONST_PACKAGE_NAME, v_proc, v_table, 'ERROR', 'An error was encountered - ERROR- '||SQLERRM, SQLCODE ,v_starttime,CURRENT_TIMESTAMP, NULL, NULL);
END;

END UTL_OW_OFFER_TO_WORKSHEET;
/


GRANT EXECUTE ON WORKDESK.UTL_OW_OFFER_TO_WORKSHEET TO OMS;
