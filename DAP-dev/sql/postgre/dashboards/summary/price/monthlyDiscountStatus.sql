/* 3. 월별 할인현황 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(FRST_DT_YEAR AS DATE)     AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(BASE_DT      AS DATE)     AS TO_DT      /* 기준일자 (어제)        */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_COPY_TITL AS
    (
        SELECT 1                AS SORT_KEY
              ,'D30'            AS TITL_ID
              ,'30% 이상'       AS TITL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'D40'            AS TITL_ID
              ,'30~50%'         AS TITL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'D50'            AS TITL_ID
              ,'50% 이상'       AS TITL_NM
    ), WT_TITL AS
    (
        SELECT A.COPY_MNTH
              ,B.SORT_KEY
              ,B.TITL_ID
              ,B.TITL_NM
          FROM WT_COPY_MNTH A
              ,WT_COPY_TITL B
    ), WT_AMT_DATA AS
    (
        SELECT 'DCT'                                AS CHNL_ID
              ,ITEM_CODE                            AS PROD_ID   /* 아이템 바코드      */
              ,TO_CHAR(STATISTICS_DATE, 'YYYY-MM')  AS AMT_MNTH  /* 월                 */
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
              ,TO_CHAR(STATISTICS_DATE, 'YYYY-MM')  AS AMT_MNTH  /* 월                 */
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
              ,TO_CHAR(STATISTICS_DATE, 'YYYY-MM')  AS AMT_MNTH  /* 월                 */
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
--              ,TO_CHAR(STATISTICS_DATE, 'YYYY-MM')  AS AMT_MNTH  /* 월                 */
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
              ,AMT_MNTH
              ,SUM(AMT_RMB)  AS AMT_RMB
              ,SUM(AMT_KRW)  AS AMT_KRW
              ,SUM(AMT_CNT)  AS AMT_CNT
          FROM WT_AMT_DATA
      GROUP BY CHNL_ID
              ,PROD_ID
              ,AMT_MNTH
     UNION ALL
        SELECT 'ALL' AS CHNL_ID
              ,PROD_ID
              ,AMT_MNTH
              ,SUM(AMT_RMB)  AS AMT_RMB
              ,SUM(AMT_KRW)  AS AMT_KRW
              ,SUM(AMT_CNT)  AS AMT_CNT
          FROM WT_AMT_DATA
      GROUP BY PROD_ID
              ,AMT_MNTH
    ), WT_TAG_DATA AS
    (
        SELECT CHNL_ID
              ,PROD_ID   /* 아이템 바코드 */
              ,AMT_MNTH  /* 월            */
              ,TAG_RMB *
               CASE
                 WHEN SUM(AMT_RMB) OVER(PARTITION BY CHNL_ID, PROD_ID, AMT_MNTH) = 0 THEN 0
                 ELSE AMT_RMB / SUM(AMT_RMB) OVER(PARTITION BY CHNL_ID, PROD_ID, AMT_MNTH)
               END  AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,TAG_KRW *
               CASE
                 WHEN SUM(AMT_KRW) OVER(PARTITION BY CHNL_ID, PROD_ID, AMT_MNTH) = 0 THEN 0
                 ELSE AMT_KRW / SUM(AMT_KRW) OVER(PARTITION BY CHNL_ID, PROD_ID, AMT_MNTH)
               END  AS CALC_TAG_KRW   /* 정가 - 원화 */
          FROM WT_AMT_DATA
     UNION ALL
        SELECT 'ALL' AS CHNL_ID
              ,PROD_ID   /* 아이템 바코드 */
              ,AMT_MNTH  /* 월            */
              ,TAG_RMB *
               CASE
                 WHEN SUM(AMT_RMB) OVER(PARTITION BY PROD_ID, AMT_MNTH) = 0 THEN 0
                 ELSE AMT_RMB / SUM(AMT_RMB) OVER(PARTITION BY PROD_ID, AMT_MNTH)
               END  AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,TAG_KRW *
               CASE
                 WHEN SUM(AMT_KRW) OVER(PARTITION BY PROD_ID, AMT_MNTH) = 0 THEN 0
                 ELSE AMT_KRW / SUM(AMT_KRW) OVER(PARTITION BY PROD_ID, AMT_MNTH)
               END  AS CALC_TAG_KRW   /* 정가 - 원화 */
          FROM WT_AMT_DATA
    ), WT_TAG AS
    (
        SELECT CHNL_ID
              ,PROD_ID                             /* 아이템 바코드 */
              ,AMT_MNTH                            /* 월            */
              ,SUM(CALC_TAG_RMB) AS CALC_TAG_RMB   /* 정가 - 위안화 */
              ,SUM(CALC_TAG_KRW) AS CALC_TAG_KRW   /* 정가 - 원화   */
          FROM WT_TAG_DATA
      GROUP BY CHNL_ID
              ,PROD_ID
              ,AMT_MNTH
    ), WT_CALC_DATA AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.AMT_MNTH
              ,A.AMT_RMB
              ,A.AMT_KRW
              ,A.AMT_CNT
              ,B.CALC_TAG_RMB
              ,B.CALC_TAG_KRW
              ,CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_RMB / A.AMT_CNT) END CALC_AMT_RMB
              ,CASE WHEN A.AMT_CNT = 0 THEN 0 ELSE (A.AMT_KRW / A.AMT_CNT) END CALC_AMT_KRW
              ,B.CALC_TAG_RMB * 0.5 AS D50_RMB
              ,B.CALC_TAG_KRW * 0.5 AS D50_KRW
              ,B.CALC_TAG_RMB * 0.7 AS D30_RMB
              ,B.CALC_TAG_KRW * 0.7 AS D30_KRW
          FROM WT_AMT A LEFT OUTER JOIN WT_TAG B ON (A.CHNL_ID = B.CHNL_ID AND A.AMT_MNTH = B.AMT_MNTH AND A.PROD_ID = B.PROD_ID)
    ), WT_CALC AS
    (
        SELECT AMT_MNTH
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND D30_RMB <= CALC_AMT_RMB                             THEN 1 END) AS ALL_D30_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND D30_RMB <= CALC_AMT_RMB                             THEN 1 END) AS DCT_D30_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND D30_RMB <= CALC_AMT_RMB                             THEN 1 END) AS DGT_D30_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND D30_RMB <= CALC_AMT_RMB                             THEN 1 END) AS DCD_D30_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND D30_RMB <= CALC_AMT_RMB                             THEN 1 END) AS DGD_D30_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND D30_RMB >  CALC_AMT_RMB AND CALC_AMT_RMB >  D50_RMB THEN 1 END) AS ALL_D40_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND D30_RMB >  CALC_AMT_RMB AND CALC_AMT_RMB >  D50_RMB THEN 1 END) AS DCT_D40_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND D30_RMB >  CALC_AMT_RMB AND CALC_AMT_RMB >  D50_RMB THEN 1 END) AS DGT_D40_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND D30_RMB >  CALC_AMT_RMB AND CALC_AMT_RMB >  D50_RMB THEN 1 END) AS DCD_D40_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND D30_RMB >  CALC_AMT_RMB AND CALC_AMT_RMB >  D50_RMB THEN 1 END) AS DGD_D40_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND                             CALC_AMT_RMB <= D50_RMB THEN 1 END) AS ALL_D50_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND                             CALC_AMT_RMB <= D50_RMB THEN 1 END) AS DCT_D50_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND                             CALC_AMT_RMB <= D50_RMB THEN 1 END) AS DGT_D50_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND                             CALC_AMT_RMB <= D50_RMB THEN 1 END) AS DCD_D50_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND                             CALC_AMT_RMB <= D50_RMB THEN 1 END) AS DGD_D50_CNT_RMB
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND D30_KRW <= CALC_AMT_KRW                             THEN 1 END) AS ALL_D30_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND D30_KRW <= CALC_AMT_KRW                             THEN 1 END) AS DCT_D30_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND D30_KRW <= CALC_AMT_KRW                             THEN 1 END) AS DGT_D30_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND D30_KRW <= CALC_AMT_KRW                             THEN 1 END) AS DCD_D30_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND D30_KRW <= CALC_AMT_KRW                             THEN 1 END) AS DGD_D30_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND D30_KRW >  CALC_AMT_KRW AND CALC_AMT_KRW >  D50_KRW THEN 1 END) AS ALL_D40_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND D30_KRW >  CALC_AMT_KRW AND CALC_AMT_KRW >  D50_KRW THEN 1 END) AS DCT_D40_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND D30_KRW >  CALC_AMT_KRW AND CALC_AMT_KRW >  D50_KRW THEN 1 END) AS DGT_D40_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND D30_KRW >  CALC_AMT_KRW AND CALC_AMT_KRW >  D50_KRW THEN 1 END) AS DCD_D40_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND D30_KRW >  CALC_AMT_KRW AND CALC_AMT_KRW >  D50_KRW THEN 1 END) AS DGD_D40_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'ALL' AND                             CALC_AMT_KRW <= D50_KRW THEN 1 END) AS ALL_D50_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCT' AND                             CALC_AMT_KRW <= D50_KRW THEN 1 END) AS DCT_D50_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGT' AND                             CALC_AMT_KRW <= D50_KRW THEN 1 END) AS DGT_D50_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DCD' AND                             CALC_AMT_KRW <= D50_KRW THEN 1 END) AS DCD_D50_CNT_KRW
              ,SUM(CASE WHEN CHNL_ID = 'DGD' AND                             CALC_AMT_KRW <= D50_KRW THEN 1 END) AS DGD_D50_CNT_KRW
          FROM WT_CALC_DATA
      GROUP BY AMT_MNTH
    ), WT_BASE AS
    (
        SELECT COPY_MNTH
              ,SORT_KEY
              ,TITL_ID
              ,TITL_NM
              ,CASE WHEN TITL_ID = 'D30' THEN ALL_D30_CNT_RMB WHEN TITL_ID = 'D40' THEN ALL_D40_CNT_RMB WHEN TITL_ID = 'D50' THEN ALL_D50_CNT_RMB END  AS ALL_CNT_RMB
              ,CASE WHEN TITL_ID = 'D30' THEN DCT_D30_CNT_RMB WHEN TITL_ID = 'D40' THEN DCT_D40_CNT_RMB WHEN TITL_ID = 'D50' THEN DCT_D50_CNT_RMB END  AS DCT_CNT_RMB
              ,CASE WHEN TITL_ID = 'D30' THEN DGT_D30_CNT_RMB WHEN TITL_ID = 'D40' THEN DGT_D40_CNT_RMB WHEN TITL_ID = 'D50' THEN DGT_D50_CNT_RMB END  AS DGT_CNT_RMB
              ,CASE WHEN TITL_ID = 'D30' THEN DCD_D30_CNT_RMB WHEN TITL_ID = 'D40' THEN DCD_D40_CNT_RMB WHEN TITL_ID = 'D50' THEN DCD_D50_CNT_RMB END  AS DCD_CNT_RMB
              ,CASE WHEN TITL_ID = 'D30' THEN DGD_D30_CNT_RMB WHEN TITL_ID = 'D40' THEN DGD_D40_CNT_RMB WHEN TITL_ID = 'D50' THEN DGD_D50_CNT_RMB END  AS DGD_CNT_RMB
              ,CASE WHEN TITL_ID = 'D30' THEN ALL_D30_CNT_KRW WHEN TITL_ID = 'D40' THEN ALL_D40_CNT_KRW WHEN TITL_ID = 'D50' THEN ALL_D50_CNT_KRW END  AS ALL_CNT_KRW
              ,CASE WHEN TITL_ID = 'D30' THEN DCT_D30_CNT_KRW WHEN TITL_ID = 'D40' THEN DCT_D40_CNT_KRW WHEN TITL_ID = 'D50' THEN DCT_D50_CNT_KRW END  AS DCT_CNT_KRW
              ,CASE WHEN TITL_ID = 'D30' THEN DGT_D30_CNT_KRW WHEN TITL_ID = 'D40' THEN DGT_D40_CNT_KRW WHEN TITL_ID = 'D50' THEN DGT_D50_CNT_KRW END  AS DGT_CNT_KRW
              ,CASE WHEN TITL_ID = 'D30' THEN DCD_D30_CNT_KRW WHEN TITL_ID = 'D40' THEN DCD_D40_CNT_KRW WHEN TITL_ID = 'D50' THEN DCD_D50_CNT_KRW END  AS DCD_CNT_KRW
              ,CASE WHEN TITL_ID = 'D30' THEN DGD_D30_CNT_KRW WHEN TITL_ID = 'D40' THEN DGD_D40_CNT_KRW WHEN TITL_ID = 'D50' THEN DGD_D50_CNT_KRW END  AS DGD_CNT_KRW
          FROM WT_TITL A LEFT OUTER JOIN WT_CALC B ON (A.COPY_MNTH = B.AMT_MNTH)
    )
    SELECT COPY_MNTH                                     AS TITL_MNTH   /* 월                     */
          ,TITL_NM                                       AS TITL_NM     /* 할인율 구간            */
          ,TO_CHAR(ALL_CNT_RMB, 'FM999,999,999,999,999') AS ALL_CNT_RMB /* 전체          - 위안화 */
          ,TO_CHAR(DCT_CNT_RMB, 'FM999,999,999,999,999') AS DCT_CNT_RMB /* Tmall  내륙   - 위안화 */
          ,TO_CHAR(DGT_CNT_RMB, 'FM999,999,999,999,999') AS DGT_CNT_RMB /* Tmall  글로벌 - 위안화 */
          ,TO_CHAR(DCD_CNT_RMB, 'FM999,999,999,999,999') AS DCD_CNT_RMB /* Douyin 내륙   - 위안화 */
          ,TO_CHAR(DGD_CNT_RMB, 'FM999,999,999,999,999') AS DGD_CNT_RMB /* Douyin 글로벌 - 위안화 */
          ,TO_CHAR(ALL_CNT_KRW, 'FM999,999,999,999,999') AS ALL_CNT_KRW /* 전체          - 원화   */
          ,TO_CHAR(DCT_CNT_KRW, 'FM999,999,999,999,999') AS DCT_CNT_KRW /* Tmall  내륙   - 원화   */
          ,TO_CHAR(DGT_CNT_KRW, 'FM999,999,999,999,999') AS DGT_CNT_KRW /* Tmall  글로벌 - 원화   */
          ,TO_CHAR(DCD_CNT_KRW, 'FM999,999,999,999,999') AS DCD_CNT_KRW /* Douyin 내륙   - 원화   */
          ,TO_CHAR(DGD_CNT_KRW, 'FM999,999,999,999,999') AS DGD_CNT_KRW /* Douyin 글로벌 - 원화   */
      FROM WT_BASE
  ORDER BY COPY_MNTH
          ,SORT_KEY