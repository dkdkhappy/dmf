/* 5. 채널별 검색 지표 Break Down - Douyin 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                             , 'YYYYMMDD') AS INTEGER) AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYYMMDD') AS INTEGER) AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,CAST(TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE)                             , 'YYYYMMDD') AS INTEGER) AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,CAST(TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYYMMDD') AS INTEGER) AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */
              ,{FR_MNTH}                                                                                          AS FR_MNTH         /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                                          AS TO_MNTH         /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({TYPE_ID}, 'PAID_RATE')                                                                   AS TYPE_ID         /* PAID_RATE: '구매자 비중', REPD_RATE: '재구매율', CUST_AMT: '객단가', CUST_CM: '구매자당 수익', CLCK_RATE: '클릭률' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 0                AS SORT_KEY
              ,'ALL'            AS CHNL_ID
              ,'전체'           AS CHNL_NM
              ,''               AS CHNL_ID_CM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
              ,'Douyin China'   AS CHNL_ID_CM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
              ,'Douyin Global'  AS CHNL_ID_CM
    ), WT_ANLS AS
    (
        SELECT DATE                                                                        AS MNTH_ANLS
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin China'  THEN CM END), 0) * 1000000 AS DCD_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin Global' THEN CM END), 0) * 1000000 AS DGD_CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID_CM FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DCD AS
    (
        SELECT 'DCD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DCD
              ,SUM(PRODUCT_CLICKS_PERSON                                       )  AS DCD_VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS DCD_PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS DCD_PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS DCD_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS DCD_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS DCD_CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DCD_REPD AS
    (
        SELECT 'DCD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DCD
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS DCD_REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS DCD_REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_DCD_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')    
    ), WT_DGD AS
    (
        SELECT 'DGD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DGD
              ,SUM(PRODUCT_CLICKS_PERSON                                       )  AS DGD_VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS DGD_PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS DGD_PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS DGD_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS DGD_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS DGD_CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DGD_REPD AS
    (
        SELECT 'DGD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DGD
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS DGD_REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS DGD_REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_DGD_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')    
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CASE WHEN DCD_VIST_CNT      = 0 THEN 0 ELSE DCD_PAID_CNT     / DCD_VIST_CNT      * 100 END AS DCD_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DCD_REPD_PAID_CNT = 0 THEN 0 ELSE DCD_REPD_CNT     / DCD_REPD_PAID_CNT * 100 END AS DCD_REPD_RATE     /* 재구매율        */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_SALE_AMT_RMB / DCD_PAID_CNT            END AS DCD_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_SALE_AMT_KRW / DCD_PAID_CNT            END AS DCD_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_CM_AMT       / DCD_PAID_CNT            END AS DCD_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DCD_PROD_CNT      = 0 THEN 0 ELSE DCD_CLCK_CNT     / DCD_PROD_CNT      * 100 END AS DCD_CLCK_RATE     /* 클릭률          */

              ,CASE WHEN DGD_VIST_CNT      = 0 THEN 0 ELSE DGD_PAID_CNT     / DGD_VIST_CNT      * 100 END AS DGD_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DGD_REPD_PAID_CNT = 0 THEN 0 ELSE DGD_REPD_CNT     / DGD_REPD_PAID_CNT * 100 END AS DGD_REPD_RATE     /* 재구매율        */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_SALE_AMT_RMB / DGD_PAID_CNT            END AS DGD_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_SALE_AMT_KRW / DGD_PAID_CNT            END AS DGD_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_CM_AMT       / DGD_PAID_CNT            END AS DGD_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DGD_PROD_CNT      = 0 THEN 0 ELSE DGD_CLCK_CNT     / DGD_PROD_CNT      * 100 END AS DGD_CLCK_RATE     /* 클릭률          */

              ,CASE WHEN (DCD_VIST_CNT      + DCD_VIST_CNT     ) = 0 THEN 0 ELSE (DCD_PAID_CNT     + DCD_PAID_CNT    ) / (DCD_VIST_CNT      + DCD_VIST_CNT     ) * 100 END AS ALL_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN (DCD_REPD_PAID_CNT + DCD_REPD_PAID_CNT) = 0 THEN 0 ELSE (DCD_REPD_CNT     + DCD_REPD_CNT    ) / (DCD_REPD_PAID_CNT + DCD_REPD_PAID_CNT) * 100 END AS ALL_REPD_RATE     /* 재구매율        */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_SALE_AMT_RMB + DCD_SALE_AMT_RMB) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_SALE_AMT_KRW + DCD_SALE_AMT_KRW) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_CM_AMT       + DCD_CM_AMT      ) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN (DCD_PROD_CNT      + DCD_PROD_CNT     ) = 0 THEN 0 ELSE (DCD_CLCK_CNT     + DCD_CLCK_CNT    ) / (DCD_PROD_CNT      + DCD_PROD_CNT     ) * 100 END AS ALL_CLCK_RATE     /* 클릭률          */
              ,(SELECT TYPE_ID FROM WT_WHERE) AS TYPE_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCD      B ON (A.COPY_MNTH = B.MNTH_DCD)
                              LEFT OUTER JOIN WT_DCD_REPD C ON (A.COPY_MNTH = C.MNTH_DCD)
                              LEFT OUTER JOIN WT_DGD      D ON (A.COPY_MNTH = D.MNTH_DGD)
                              LEFT OUTER JOIN WT_DGD_REPD E ON (A.COPY_MNTH = E.MNTH_DGD)
                              LEFT OUTER JOIN WT_ANLS     F ON (A.COPY_MNTH = F.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'PAID_RATE' THEN DCD_PAID_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'REPD_RATE' THEN DCD_REPD_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_AMT'  THEN DCD_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_CM'   THEN DCD_CUST_CM
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CLCK_RATE' THEN DCD_CLCK_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'PAID_RATE' THEN DGD_PAID_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'REPD_RATE' THEN DGD_REPD_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_AMT'  THEN DGD_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_CM'   THEN DGD_CUST_CM
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CLCK_RATE' THEN DGD_CLCK_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CLCK_RATE' THEN ALL_CLCK_RATE
               END AS Y_VAL_RMB
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'PAID_RATE' THEN DCD_PAID_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'REPD_RATE' THEN DCD_REPD_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_AMT'  THEN DCD_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_CM'   THEN DCD_CUST_CM
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CLCK_RATE' THEN DCD_CLCK_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'PAID_RATE' THEN DGD_PAID_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'REPD_RATE' THEN DGD_REPD_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_AMT'  THEN DGD_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_CM'   THEN DGD_CUST_CM
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CLCK_RATE' THEN DGD_CLCK_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CLCK_RATE' THEN ALL_CLCK_RATE
               END AS Y_VAL_KRW
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT