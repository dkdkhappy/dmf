/* 13. Top5 매출 제품 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR            AS DATE) AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(BASE_YEAR    ||'-12-31' AS DATE) AS TO_DT      /* 기준일의 12월 31일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_AMT_YEAR AS
    (
        SELECT COALESCE(MAX(A.SALE_AMT_YEAR_RMB), 0) + COALESCE(MAX(B.SALE_AMT_YEAR_RMB), 0) AS T_SALE_AMT_YEAR_RMB
              ,COALESCE(MAX(A.SALE_AMT_YEAR_KRW), 0) + COALESCE(MAX(B.SALE_AMT_YEAR_KRW), 0) AS T_SALE_AMT_YEAR_KRW
              ,0                                                                             AS D_SALE_AMT_YEAR_RMB
              ,0                                                                             AS D_SALE_AMT_YEAR_KRW
--              ,COALESCE(MAX(C.SALE_AMT_YEAR_RMB), 0) + COALESCE(MAX(D.SALE_AMT_YEAR_RMB), 0) AS D_SALE_AMT_YEAR_RMB
--              ,COALESCE(MAX(C.SALE_AMT_YEAR_KRW), 0) + COALESCE(MAX(D.SALE_AMT_YEAR_KRW), 0) AS D_SALE_AMT_YEAR_KRW
          FROM DASH.DCT_IMPCARDAMTDATA A
              ,DASH.DGT_IMPCARDAMTDATA B
--              ,DASH.DCD_IMPCARDAMTDATA C
--              ,DASH.DGD_IMPCARDAMTDATA D
    ), WT_PROD_DATA AS
    (
        SELECT 'DCT'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DCT_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
     UNION ALL
        SELECT 'DGT'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
     UNION ALL
        SELECT 'DCD'                         AS CHNL_ID
              ,ITEM_CODE                     AS PROD_ID
              ,MAX(ITEM_NAME)                AS PROD_NM
              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
          FROM DASH.DCD_PRICEANLAYSISITEMTIMESERIES A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY ITEM_CODE
--     UNION ALL
--        SELECT 'DGD'                         AS CHNL_ID
--              ,ITEM_CODE                     AS PROD_ID
--              ,MAX(ITEM_NAME)                AS PROD_NM
--              ,SUM(ALL_SALE_ITEM_AMOUNT_RMB) AS SALE_AMT_RMB
--              ,SUM(ALL_SALE_ITEM_AMOUNT_KRW) AS SALE_AMT_KRW
--          FROM DASH.DGD_PRICEANLAYSISITEMTIMESERIES A
--         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
--      GROUP BY ITEM_CODE
    ), WT_PROD AS
    (
        SELECT PROD_ID
              ,MAX(PROD_NM)      AS PROD_NM
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW
              ,SUM(CASE WHEN CHNL_ID IN ('DCT', 'DGT') THEN SALE_AMT_RMB END) AS T_SALE_AMT_RMB 
              ,SUM(CASE WHEN CHNL_ID IN ('DCT', 'DGT') THEN SALE_AMT_KRW END) AS T_SALE_AMT_KRW 
              ,SUM(CASE WHEN CHNL_ID IN ('DCD', 'DGD') THEN SALE_AMT_RMB END) AS D_SALE_AMT_RMB 
              ,SUM(CASE WHEN CHNL_ID IN ('DCD', 'DGD') THEN SALE_AMT_KRW END) AS D_SALE_AMT_KRW 
          FROM WT_PROD_DATA
      GROUP BY PROD_ID
    ), WT_PROD_AMT AS
    (
        SELECT PROD_ID
              ,PROD_NM
              ,ROW_NUMBER() OVER(ORDER BY SALE_AMT_RMB DESC, A.PROD_ID) AS SALE_RANK_RMB
              ,ROW_NUMBER() OVER(ORDER BY SALE_AMT_KRW DESC, A.PROD_ID) AS SALE_RANK_KRW
              ,SALE_AMT_RMB
              ,SALE_AMT_KRW
              ,CASE WHEN SUM(SALE_AMT_RMB) OVER() = 0 THEN 0 ELSE SALE_AMT_RMB   / SUM(SALE_AMT_RMB) OVER() * 100 END AS SALE_RATE_RMB
              ,CASE WHEN SUM(SALE_AMT_KRW) OVER() = 0 THEN 0 ELSE SALE_AMT_KRW   / SUM(SALE_AMT_KRW) OVER() * 100 END AS SALE_RATE_KRW
              ,CASE WHEN T_SALE_AMT_YEAR_RMB      = 0 THEN 0 ELSE T_SALE_AMT_RMB / T_SALE_AMT_YEAR_RMB      * 100 END AS T_SALE_RATE_RMB
              ,CASE WHEN T_SALE_AMT_YEAR_KRW      = 0 THEN 0 ELSE T_SALE_AMT_KRW / T_SALE_AMT_YEAR_KRW      * 100 END AS T_SALE_RATE_KRW
              ,CASE WHEN D_SALE_AMT_YEAR_RMB      = 0 THEN 0 ELSE D_SALE_AMT_RMB / D_SALE_AMT_YEAR_RMB      * 100 END AS D_SALE_RATE_RMB
              ,CASE WHEN D_SALE_AMT_YEAR_KRW      = 0 THEN 0 ELSE D_SALE_AMT_KRW / D_SALE_AMT_YEAR_KRW      * 100 END AS D_SALE_RATE_KRW
          FROM WT_PROD     A
              ,WT_AMT_YEAR B
         WHERE A.PROD_ID != '99'
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK
              ,B.PROD_ID         AS PROD_ID_RMB
              ,B.PROD_NM         AS PROD_NM_RMB
              ,B.SALE_AMT_RMB    AS SALE_AMT_RMB
              ,B.SALE_RATE_RMB   AS SALE_RATE_RMB
              ,B.T_SALE_RATE_RMB AS T_SALE_RATE_RMB
              ,B.D_SALE_RATE_RMB AS D_SALE_RATE_RMB
              ,C.PROD_ID         AS PROD_ID_KRW
              ,C.PROD_NM         AS PROD_NM_KRW
              ,C.SALE_AMT_KRW    AS SALE_AMT_KRW
              ,C.SALE_RATE_KRW   AS SALE_RATE_KRW
              ,C.T_SALE_RATE_KRW AS T_SALE_RATE_KRW
              ,C.D_SALE_RATE_KRW AS D_SALE_RATE_KRW
          FROM WT_COPY A LEFT OUTER JOIN WT_PROD_AMT B ON (A.SALE_RANK = B.SALE_RANK_RMB)
                         LEFT OUTER JOIN WT_PROD_AMT C ON (A.SALE_RANK = C.SALE_RANK_KRW)
    )
    SELECT SALE_RANK                                                                 /* 순위                      */
          ,PROD_ID_RMB                                                               /* 제품ID           - 위안화 */
          ,PROD_NM_RMB                                                               /* 제품명           - 위안화 */
          ,TO_CHAR(SALE_AMT_RMB   , 'FM999,999,999,999,990'    ) AS SALE_AMT_RMB     /* 매출액           - 위안화 */
          ,TO_CHAR(SALE_RATE_RMB  , 'FM999,999,999,999,990.00%') AS SALE_RATE_RMB    /* 매출기여         - 위안화 */
          ,TO_CHAR(T_SALE_RATE_RMB, 'FM999,999,999,999,990.00%') AS T_SALE_RATE_RMB  /* Tmall  매출 비중 - 위안화 */
          ,TO_CHAR(D_SALE_RATE_RMB, 'FM999,999,999,999,990.00%') AS D_SALE_RATE_RMB  /* Douyin 매출 비중 - 위안화 */
          ,PROD_ID_KRW                                                               /* 제품ID           - 원화   */
          ,PROD_NM_KRW                                                               /* 제품명           - 원화   */
          ,TO_CHAR(SALE_AMT_KRW   , 'FM999,999,999,999,990'    ) AS SALE_AMT_KRW     /* 매출액           - 원화   */
          ,TO_CHAR(SALE_RATE_KRW  , 'FM999,999,999,999,990.00%') AS SALE_RATE_KRW    /* 매출기여         - 원화   */
          ,TO_CHAR(T_SALE_RATE_KRW, 'FM999,999,999,999,990.00%') AS T_SALE_RATE_KRW  /* Tmall  매출 비중 - 원화   */
          ,TO_CHAR(D_SALE_RATE_KRW, 'FM999,999,999,999,990.00%') AS D_SALE_RATE_KRW  /* Douyin 매출 비중 - 원화   */
      FROM WT_BASE
  ORDER BY SALE_RANK