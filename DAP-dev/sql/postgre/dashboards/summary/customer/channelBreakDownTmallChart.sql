/* 5. 채널별 검색 지표 Break Down - Tmall 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                             , 'YYYY-MM-DD') AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYY-MM-DD') AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE)                             , 'YYYY-MM-DD') AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYY-MM-DD') AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */
              ,{FR_MNTH}                                                                          AS FR_MNTH         /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                          AS TO_MNTH         /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({TYPE_ID}, 'PAID_RATE')                                                   AS TYPE_ID         /* PAID_RATE: '구매자 비중', CUST_AMT: '객단가', CUST_CM: '구매자당 수익', FRST_RATE: '첫방문자 비중', STAY_TIME: '평균 체류시간', REPD_RATE: '재구매율' */
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
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
              ,'Tmall China'    AS CHNL_ID_CM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
              ,'Tmall Global'   AS CHNL_ID_CM
    ), WT_ANLS AS
    (
        SELECT DATE                                                                        AS MNTH_ANLS
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall China'   THEN CM END), 0) * 1000000 AS DCT_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall Global'  THEN CM END), 0) * 1000000 AS DGT_CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID_CM FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DCT AS
    (
        SELECT 'DCT'                                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')                 AS MNTH_DCT
              ,COALESCE(SUM(PRODUCT_VISITORS                                        ), 0) AS DCT_VIST_CNT      /* 방문자 수         */
              ,COALESCE(SUM(NEW_VISITORS                                            ), 0) AS DCT_FRST_CNT      /* 첫방문자수        */
              ,COALESCE(SUM(NUMBER_OF_PAID_BUYERS                                   ), 0) AS DCT_PAID_CNT      /* 구매자 수         */
              ,COALESCE(SUM(PAYMENT_AMOUNT                                          ), 0) AS DCT_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,COALESCE(SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)), 0) AS DCT_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,COALESCE(AVG(AVERAGE_LENGTH_OF_STAY                                  ), 0) AS DCT_STAY_TIME     /* 체류시간          */
              ,COALESCE(SUM(PAY_OLD_BUYERS                                          ), 0) AS DCT_REPD_CNT      /* 재구매자 수       */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DGT AS
    (
        SELECT 'DGT'                                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')                 AS MNTH_DGT
              ,COALESCE(SUM(PRODUCT_VISITORS                                        ), 0) AS DGT_VIST_CNT      /* 방문자 수         */
              ,COALESCE(SUM(NEW_VISITORS                                            ), 0) AS DGT_FRST_CNT      /* 첫방문자수        */
              ,COALESCE(SUM(NUMBER_OF_PAID_BUYERS                                   ), 0) AS DGT_PAID_CNT      /* 구매자 수         */
              ,COALESCE(SUM(PAYMENT_AMOUNT                                          ), 0) AS DGT_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,COALESCE(SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)), 0) AS DGT_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,COALESCE(AVG(AVERAGE_LENGTH_OF_STAY                                  ), 0) AS DGT_STAY_TIME     /* 체류시간          */
              ,COALESCE(SUM(PAY_OLD_BUYERS                                          ), 0) AS DGT_REPD_CNT      /* 재구매자 수       */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CASE WHEN DCT_VIST_CNT = 0 THEN 0 ELSE DCT_PAID_CNT     / DCT_VIST_CNT * 100 END AS DCT_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_SALE_AMT_RMB / DCT_PAID_CNT       END AS DCT_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_SALE_AMT_KRW / DCT_PAID_CNT       END AS DCT_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_CM_AMT       / DCT_PAID_CNT       END AS DCT_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DCT_VIST_CNT = 0 THEN 0 ELSE DCT_FRST_CNT     / DCT_VIST_CNT * 100 END AS DCT_FRST_RATE     /* 첫방문자 비중   */
              ,DCT_STAY_TIME                                                                    AS DCT_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_REPD_CNT     / DCT_PAID_CNT * 100 END AS DCT_REPD_RATE     /* 재구매율        */

              ,CASE WHEN DGT_VIST_CNT = 0 THEN 0 ELSE DGT_PAID_CNT     / DGT_VIST_CNT * 100 END AS DGT_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_SALE_AMT_RMB / DGT_PAID_CNT       END AS DGT_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_SALE_AMT_KRW / DGT_PAID_CNT       END AS DGT_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_CM_AMT       / DGT_PAID_CNT       END AS DGT_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DGT_VIST_CNT = 0 THEN 0 ELSE DGT_FRST_CNT     / DGT_VIST_CNT * 100 END AS DGT_FRST_RATE     /* 첫방문자 비중   */
              ,DGT_STAY_TIME                                                                    AS DGT_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_REPD_CNT     / DGT_PAID_CNT * 100 END AS DGT_REPD_RATE     /* 재구매율        */

              ,CASE WHEN (DCT_VIST_CNT + DGT_VIST_CNT) = 0 THEN 0 ELSE (DCT_PAID_CNT     + DGT_PAID_CNT    ) / (DCT_VIST_CNT + DGT_VIST_CNT) * 100 END AS ALL_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_SALE_AMT_RMB + DGT_SALE_AMT_RMB) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_SALE_AMT_KRW + DGT_SALE_AMT_KRW) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_CM_AMT       + DGT_CM_AMT      ) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN (DCT_VIST_CNT + DGT_VIST_CNT) = 0 THEN 0 ELSE (DCT_FRST_CNT     + DGT_FRST_CNT    ) / (DCT_VIST_CNT + DGT_VIST_CNT) * 100 END AS ALL_FRST_RATE     /* 첫방문자 비중   */
              ,(DCT_STAY_TIME + DGT_STAY_TIME) / 2                                                                                                     AS ALL_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_REPD_CNT     + DGT_REPD_CNT    ) / (DCT_PAID_CNT + DGT_PAID_CNT) * 100 END AS ALL_REPD_RATE     /* 재구매율        */
              ,(SELECT TYPE_ID FROM WT_WHERE) AS TYPE_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCT  B ON (A.COPY_MNTH = B.MNTH_DCT)
                              LEFT OUTER JOIN WT_DGT  C ON (A.COPY_MNTH = C.MNTH_DGT)
                              LEFT OUTER JOIN WT_ANLS D ON (A.COPY_MNTH = D.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'PAID_RATE' THEN DCT_PAID_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_AMT'  THEN DCT_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_CM'   THEN DCT_CUST_CM
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'FRST_RATE' THEN DCT_FRST_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'STAY_TIME' THEN DCT_STAY_TIME
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'REPD_RATE' THEN DCT_REPD_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'PAID_RATE' THEN DGT_PAID_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_AMT'  THEN DGT_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_CM'   THEN DGT_CUST_CM
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'FRST_RATE' THEN DGT_FRST_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'STAY_TIME' THEN DGT_STAY_TIME
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'REPD_RATE' THEN DGT_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'FRST_RATE' THEN ALL_FRST_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'STAY_TIME' THEN ALL_STAY_TIME
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
               END AS Y_VAL_RMB
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'PAID_RATE' THEN DCT_PAID_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_AMT'  THEN DCT_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_CM'   THEN DCT_CUST_CM
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'FRST_RATE' THEN DCT_FRST_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'STAY_TIME' THEN DCT_STAY_TIME
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'REPD_RATE' THEN DCT_REPD_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'PAID_RATE' THEN DGT_PAID_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_AMT'  THEN DGT_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_CM'   THEN DGT_CUST_CM
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'FRST_RATE' THEN DGT_FRST_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'STAY_TIME' THEN DGT_STAY_TIME
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'REPD_RATE' THEN DGT_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'FRST_RATE' THEN ALL_FRST_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'STAY_TIME' THEN ALL_STAY_TIME
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
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