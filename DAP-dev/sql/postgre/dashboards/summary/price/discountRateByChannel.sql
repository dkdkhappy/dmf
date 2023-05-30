/* 4. 전 채널 기준 제품별 할인율 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR AS DATE)     AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(BASE_DT      AS DATE)     AS TO_DT      /* 기준일자 (어제)        */
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
    ), WT_ALL_AMT AS
    (
        SELECT SUM(ALL_AMT_RMB) AS ALL_AMT_RMB
              ,SUM(ALL_AMT_KRW) AS ALL_AMT_KRW
          FROM (
                    SELECT STATISTICS_DATE 
                          ,MAX(ALL_CHAN_SALES_AMOUNT_RMB)  AS ALL_AMT_RMB
                          ,MAX(ALL_CHAN_SALES_AMOUNT_KRW)  AS ALL_AMT_KRW
                      FROM DASH.DCT_PRICEANLAYSISITEMTIMESERIES
                     WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                  GROUP BY STATISTICS_DATE
               ) A
    ), WT_AMT_DATA AS
    (
        SELECT 'DCT'                                AS CHNL_ID
              ,ITEM_CODE                            AS PROD_ID   /* 아이템 바코드      */
              ,ITEM_NAME                            AS PROD_NM   /* 아이템 명          */
              ,ALL_SALE_ITEM_AMOUNT_RMB             AS AMT_RMB   /* 판매금액  - 위안화 */
              ,ALL_SALE_ITEM_AMOUNT_KRW             AS AMT_KRW   /* 판매금액  - 원화   */
              ,ALL_SALES_ITEM_QTY                   AS AMT_CNT   /* 판매수량           */
              ,SALE_TAG_ITEM_PRICE_RMB              AS TAG_RMB   /* 정가      - 위안화 */
              ,SALE_TAG_ITEM_PRICE_KRW              AS TAG_KRW   /* 정가      - 원화   */
          FROM DASH.DCT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'                                AS CHNL_ID
              ,ITEM_CODE                            AS PROD_ID   /* 아이템 바코드      */
              ,ITEM_NAME                            AS PROD_NM   /* 아이템 명          */
              ,ALL_SALE_ITEM_AMOUNT_RMB             AS AMT_RMB   /* 판매금액  - 위안화 */
              ,ALL_SALE_ITEM_AMOUNT_KRW             AS AMT_KRW   /* 판매금액  - 원화   */
              ,ALL_SALES_ITEM_QTY                   AS AMT_CNT   /* 판매수량           */
              ,SALE_TAG_ITEM_PRICE_RMB              AS TAG_RMB   /* 정가      - 위안화 */
              ,SALE_TAG_ITEM_PRICE_KRW              AS TAG_KRW   /* 정가      - 원화   */
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DCD'                                AS CHNL_ID
              ,ITEM_CODE                            AS PROD_ID   /* 아이템 바코드      */
              ,ITEM_NAME                            AS PROD_NM   /* 아이템 명          */
              ,ALL_SALE_ITEM_AMOUNT_RMB             AS AMT_RMB   /* 판매금액  - 위안화 */
              ,ALL_SALE_ITEM_AMOUNT_KRW             AS AMT_KRW   /* 판매금액  - 원화   */
              ,ALL_SALES_ITEM_QTY                   AS AMT_CNT   /* 판매수량           */
              ,SALE_TAG_ITEM_PRICE_RMB              AS TAG_RMB   /* 정가      - 위안화 */
              ,SALE_TAG_ITEM_PRICE_KRW              AS TAG_KRW   /* 정가      - 원화   */
          FROM DASH.DCD_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
--     UNION ALL
--        SELECT 'DGD'                                AS CHNL_ID
--              ,ITEM_CODE                            AS PROD_ID   /* 아이템 바코드      */
--              ,ITEM_NAME                            AS PROD_NM   /* 아이템 명          */
--              ,ALL_SALE_ITEM_AMOUNT_RMB             AS AMT_RMB   /* 판매금액  - 위안화 */
--              ,ALL_SALE_ITEM_AMOUNT_KRW             AS AMT_KRW   /* 판매금액  - 원화   */
--              ,ALL_SALES_ITEM_QTY                   AS AMT_CNT   /* 판매수량           */
--              ,SALE_TAG_ITEM_PRICE_RMB              AS TAG_RMB   /* 정가      - 위안화 */
--              ,SALE_TAG_ITEM_PRICE_KRW              AS TAG_KRW   /* 정가      - 원화   */
--          FROM DASH.DGD_PRICEANLAYSISITEMTIMESERIES
--         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_AMT AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,MAX(PROD_NM)  AS PROD_NM
              ,SUM(AMT_RMB)  AS AMT_RMB
              ,SUM(AMT_KRW)  AS AMT_KRW
              ,SUM(AMT_CNT)  AS AMT_CNT
          FROM WT_AMT_DATA
      GROUP BY CHNL_ID
              ,PROD_ID
     UNION ALL
        SELECT 'ALL' AS CHNL_ID
              ,PROD_ID
              ,MAX(PROD_NM)  AS PROD_NM
              ,SUM(AMT_RMB)  AS AMT_RMB
              ,SUM(AMT_KRW)  AS AMT_KRW
              ,SUM(AMT_CNT)  AS AMT_CNT
          FROM WT_AMT_DATA
      GROUP BY PROD_ID
    ), WT_TAG_DATA AS
    (
        SELECT CHNL_ID
              ,PROD_ID   /* 아이템 바코드 */
              ,TAG_RMB *
               CASE
                 WHEN SUM(AMT_RMB) OVER(PARTITION BY CHNL_ID, PROD_ID) = 0 THEN 0
                 ELSE AMT_RMB / SUM(AMT_RMB) OVER(PARTITION BY CHNL_ID, PROD_ID)
               END  AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,TAG_KRW *
               CASE
                 WHEN SUM(AMT_KRW) OVER(PARTITION BY CHNL_ID, PROD_ID) = 0 THEN 0
                 ELSE AMT_KRW / SUM(AMT_KRW) OVER(PARTITION BY CHNL_ID, PROD_ID)
               END  AS CALC_TAG_KRW   /* 정가 - 원화 */
          FROM WT_AMT_DATA
     UNION ALL
        SELECT 'ALL' AS CHNL_ID
              ,PROD_ID   /* 아이템 바코드 */
              ,TAG_RMB *
               CASE
                 WHEN SUM(AMT_RMB) OVER(PARTITION BY PROD_ID) = 0 THEN 0
                 ELSE AMT_RMB / SUM(AMT_RMB) OVER(PARTITION BY PROD_ID)
               END  AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,TAG_KRW *
               CASE
                 WHEN SUM(AMT_KRW) OVER(PARTITION BY PROD_ID) = 0 THEN 0
                 ELSE AMT_KRW / SUM(AMT_KRW) OVER(PARTITION BY PROD_ID)
               END  AS CALC_TAG_KRW   /* 정가 - 원화 */
          FROM WT_AMT_DATA
    ), WT_TAG AS
    (
        SELECT CHNL_ID
              ,PROD_ID                             /* 아이템 바코드 */
              ,SUM(CALC_TAG_RMB) AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,SUM(CALC_TAG_KRW) AS CALC_TAG_KRW   /* 정가 - 원화   */
          FROM WT_TAG_DATA
      GROUP BY CHNL_ID
              ,PROD_ID
    ), WT_CALC_DATA AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.AMT_RMB
              ,A.AMT_KRW
              ,A.AMT_CNT
              ,B.CALC_TAG_RMB
              ,B.CALC_TAG_KRW
              ,                                          CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_RMB / A.AMT_CNT) END                                               AS CALC_AMT_RMB
              ,                                          CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_KRW / A.AMT_CNT) END                                               AS CALC_AMT_KRW
              ,CASE WHEN B.CALC_TAG_RMB = 0 THEN 0 ELSE (B.CALC_TAG_RMB - CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_RMB / A.AMT_CNT) END) / B.CALC_TAG_RMB END * 100  AS D_RATE_RMB
              ,CASE WHEN B.CALC_TAG_KRW = 0 THEN 0 ELSE (B.CALC_TAG_KRW - CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_KRW / A.AMT_CNT) END) / B.CALC_TAG_KRW END * 100  AS D_RATE_KRW
          FROM WT_AMT A LEFT OUTER JOIN WT_TAG B ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID)
    ), WT_RANK_DATA AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,PROD_NM
              ,ROW_NUMBER() OVER(ORDER BY CASE WHEN CHNL_ID = 'ALL' THEN 1 ELSE 2 END, D_RATE_RMB DESC, PROD_ID) AS SALE_RANK_RMB
              ,ROW_NUMBER() OVER(ORDER BY CASE WHEN CHNL_ID = 'ALL' THEN 1 ELSE 2 END, D_RATE_KRW DESC, PROD_ID) AS SALE_RANK_KRW
              ,D_RATE_RMB
              ,D_RATE_KRW
              ,CASE WHEN ALL_AMT_RMB = 0 THEN 0 ELSE AMT_RMB / ALL_AMT_RMB * 100 END AS ALL_RATE_RMB
              ,CASE WHEN ALL_AMT_KRW = 0 THEN 0 ELSE AMT_KRW / ALL_AMT_KRW * 100 END AS ALL_RATE_KRW
          FROM WT_CALC_DATA A
              ,WT_ALL_AMT   B
    ), WT_RANK AS
    (
        SELECT A.SALE_RANK
              ,B.PROD_ID      AS PROD_ID_RMB
              ,B.PROD_NM      AS PROD_NM_RMB
              ,B.D_RATE_RMB   AS D_RATE_RMB
              ,B.ALL_RATE_RMB AS ALL_RATE_RMB
              ,C.PROD_ID      AS PROD_ID_KRW
              ,C.PROD_NM      AS PROD_NM_KRW
              ,C.D_RATE_RMB   AS D_RATE_KRW
              ,C.ALL_RATE_KRW AS ALL_RATE_KRW
          FROM WT_COPY A LEFT OUTER JOIN WT_RANK_DATA B ON (A.SALE_RANK = B.SALE_RANK_RMB)
                         LEFT OUTER JOIN WT_RANK_DATA C ON (A.SALE_RANK = C.SALE_RANK_KRW)
    ), WT_BASE AS
    (
        SELECT SALE_RANK
              ,PROD_ID_RMB
              ,PROD_NM_RMB
              ,D_RATE_RMB
              ,ALL_RATE_RMB
              ,(SELECT X.D_RATE_RMB FROM WT_RANK_DATA X WHERE CHNL_ID = 'DCT' AND X.PROD_ID = A.PROD_ID_RMB) AS DCT_D_RATE_RMB
              ,(SELECT X.D_RATE_RMB FROM WT_RANK_DATA X WHERE CHNL_ID = 'DGT' AND X.PROD_ID = A.PROD_ID_RMB) AS DGT_D_RATE_RMB
              ,(SELECT X.D_RATE_RMB FROM WT_RANK_DATA X WHERE CHNL_ID = 'DCD' AND X.PROD_ID = A.PROD_ID_RMB) AS DCD_D_RATE_RMB
              ,(SELECT X.D_RATE_RMB FROM WT_RANK_DATA X WHERE CHNL_ID = 'DGD' AND X.PROD_ID = A.PROD_ID_RMB) AS DGD_D_RATE_RMB
              ,PROD_ID_KRW
              ,PROD_NM_KRW
              ,D_RATE_KRW
              ,ALL_RATE_KRW
              ,(SELECT X.D_RATE_KRW FROM WT_RANK_DATA X WHERE CHNL_ID = 'DCT' AND X.PROD_ID = A.PROD_ID_KRW) AS DCT_D_RATE_KRW
              ,(SELECT X.D_RATE_KRW FROM WT_RANK_DATA X WHERE CHNL_ID = 'DGT' AND X.PROD_ID = A.PROD_ID_KRW) AS DGT_D_RATE_KRW
              ,(SELECT X.D_RATE_KRW FROM WT_RANK_DATA X WHERE CHNL_ID = 'DCD' AND X.PROD_ID = A.PROD_ID_KRW) AS DCD_D_RATE_KRW
              ,(SELECT X.D_RATE_KRW FROM WT_RANK_DATA X WHERE CHNL_ID = 'DGD' AND X.PROD_ID = A.PROD_ID_KRW) AS DGD_D_RATE_KRW
          FROM WT_RANK A
    )
    SELECT SALE_RANK                                             AS SALE_RANK       /* 순위             - 위안화 */
          ,PROD_ID_RMB                                           AS PROD_ID_RMB     /* 제품ID           - 위안화 */
          ,PROD_NM_RMB                                           AS PROD_NM_RMB     /* 제품명           - 위안화 */
          ,TO_CHAR(D_RATE_RMB    , 'FM999,999,999,999,990.00%')  AS D_RATE_RMB      /* 전채널 할인율    - 위안화 */
          ,TO_CHAR(ALL_RATE_RMB  , 'FM999,999,999,999,990.00%')  AS ALL_RATE_RMB    /* 전채널 매출 비중 - 위안화 */
          ,TO_CHAR(DCT_D_RATE_RMB, 'FM999,999,999,999,990.00%')  AS DCT_D_RATE_RMB  /* Tmall  내륙      - 위안화 */
          ,TO_CHAR(DGT_D_RATE_RMB, 'FM999,999,999,999,990.00%')  AS DGT_D_RATE_RMB  /* Tmall  글로벌    - 위안화 */
          ,TO_CHAR(DCD_D_RATE_RMB, 'FM999,999,999,999,990.00%')  AS DCD_D_RATE_RMB  /* Douyin 내륙      - 위안화 */
          ,TO_CHAR(DGD_D_RATE_RMB, 'FM999,999,999,999,990.00%')  AS DGD_D_RATE_RMB  /* Douyin 글로벌    - 위안화 */
          ,PROD_ID_KRW                                           AS PROD_ID_KRW     /* 제품ID           - 원화   */
          ,PROD_NM_KRW                                           AS PROD_NM_KRW     /* 제품명           - 원화   */
          ,TO_CHAR(D_RATE_KRW    , 'FM999,999,999,999,990.00%')  AS D_RATE_KRW      /* 전채널 할인율    - 원화   */
          ,TO_CHAR(ALL_RATE_KRW  , 'FM999,999,999,999,990.00%')  AS ALL_RATE_KRW    /* 전채널 매출 비중 - 원화   */
          ,TO_CHAR(DCT_D_RATE_KRW, 'FM999,999,999,999,990.00%')  AS DCT_D_RATE_KRW  /* Tmall  내륙      - 원화   */
          ,TO_CHAR(DGT_D_RATE_KRW, 'FM999,999,999,999,990.00%')  AS DGT_D_RATE_KRW  /* Tmall  글로벌    - 원화   */
          ,TO_CHAR(DCD_D_RATE_KRW, 'FM999,999,999,999,990.00%')  AS DCD_D_RATE_KRW  /* Douyin 내륙      - 원화   */
          ,TO_CHAR(DGD_D_RATE_KRW, 'FM999,999,999,999,990.00%')  AS DGD_D_RATE_KRW  /* Douyin 글로벌    - 원화   */
      FROM WT_BASE
  ORDER BY SALE_RANK