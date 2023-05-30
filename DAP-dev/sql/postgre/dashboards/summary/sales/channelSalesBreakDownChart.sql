/* 7. 채널별 매출 비중 Break Down - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_MNTH}||'-01' AS DATE)                              AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{CHRT_TYPE}                                                 AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_AMT AS
    (
        SELECT TO_CHAR(STATISTICS_DATE, 'YYYY-MM') AS MNTH_AMT
              ,CASE 
                 WHEN CHRT_KEY IN ('dct_sale_amt_rmb', 'dct_sale_amt_krw')
                 THEN 'DCT'
                 WHEN CHRT_KEY IN ('dgt_sale_amt_rmb', 'dgt_sale_amt_krw')
                 THEN 'DGT'
                 WHEN CHRT_KEY IN ('dcd_sale_amt_rmb', 'dcd_sale_amt_krw')
                 THEN 'DCD'
                 WHEN CHRT_KEY IN ('dgd_sale_amt_rmb', 'dgd_sale_amt_krw')
                 THEN 'DGD'
               END AS CHNL_ID
              ,SUM(CASE
                     WHEN CHRT_KEY IN ('dct_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_sale_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_sale_amt_rmb')
                     THEN VALUE
                   END) AS SALE_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY IN ('dct_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_sale_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_sale_amt_krw')
                     THEN VALUE
                   END) AS SALE_AMT_KRW
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('dct_sale_amt_rmb', 'dgt_sale_amt_rmb', 'dcd_sale_amt_rmb', 'dgd_sale_amt_rmb',
                            'dct_sale_amt_krw', 'dgt_sale_amt_krw', 'dcd_sale_amt_krw', 'dgd_sale_amt_krw')
      GROUP BY TO_CHAR(STATISTICS_DATE, 'YYYY-MM')
              ,CHNL_ID
    ), WT_REFD AS
    (
        SELECT TO_CHAR(STATISTICS_DATE, 'YYYY-MM') AS MNTH_AMT
              ,CASE 
                 WHEN CHRT_KEY IN ('dct_refd_amt_rmb', 'dct_refd_amt_krw')
                 THEN 'DCT'
                 WHEN CHRT_KEY IN ('dgt_refd_amt_rmb', 'dgt_refd_amt_krw')
                 THEN 'DGT'
                 WHEN CHRT_KEY IN ('dcd_refd_amt_rmb', 'dcd_refd_amt_krw')
                 THEN 'DCD'
                 WHEN CHRT_KEY IN ('dgd_refd_amt_rmb', 'dgd_refd_amt_krw')
                 THEN 'DGD'
               END AS CHNL_ID
              ,SUM(CASE
                     WHEN CHRT_KEY IN ('dct_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_refd_amt_rmb')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_refd_amt_rmb')
                     THEN VALUE
                   END) AS REFD_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY IN ('dct_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgt_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dcd_refd_amt_krw')
                     THEN VALUE
                     WHEN CHRT_KEY IN ('dgd_refd_amt_krw')
                     THEN VALUE
                   END) AS REFD_AMT_KRW
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.SUM_refdTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('dct_refd_amt_rmb', 'dgt_refd_amt_rmb', 'dcd_refd_amt_rmb', 'dgd_refd_amt_rmb',
                            'dct_refd_amt_krw', 'dgt_refd_amt_krw', 'dcd_refd_amt_krw', 'dgd_refd_amt_krw')
      GROUP BY TO_CHAR(STATISTICS_DATE, 'YYYY-MM')
              ,CHNL_ID
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,B.CHNL_ID
              ,B.SALE_AMT_RMB
              ,B.SALE_AMT_KRW
              ,B.CHRT_TYPE
              ,C.REFD_AMT_RMB
              ,C.REFD_AMT_KRW
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_AMT B ON (A.COPY_MNTH = B.MNTH_AMT)
          LEFT OUTER JOIN WT_REFD C ON (B.MNTH_AMT = C.MNTH_AMT) AND (B.CHNL_ID = C.CHNL_ID) 
          

    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID                       AS L_LGND_ID
              ,A.CHNL_NM                       AS L_LGND_NM
              ,B.X_DT
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN SALE_AMT_RMB - REFD_AMT_RMB
                 ELSE (SALE_AMT_RMB - REFD_AMT_RMB) / SUM(SALE_AMT_RMB - REFD_AMT_RMB) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_RMB
              ,CASE
                 WHEN CHRT_TYPE = 'AMT' 
                 THEN SALE_AMT_KRW - REFD_AMT_KRW
                 ELSE (SALE_AMT_KRW- REFD_AMT_KRW) / SUM(SALE_AMT_KRW- REFD_AMT_KRW) OVER(PARTITION BY B.X_DT) * 100
               END AS Y_VAL_KRW
          FROM WT_CHNL A INNER JOIN WT_DATA B ON (A.CHNL_ID = B.CHNL_ID)
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,0)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,0)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT  