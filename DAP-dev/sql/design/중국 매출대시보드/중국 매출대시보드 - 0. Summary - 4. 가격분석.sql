● 중국 매출대시보드 - 0. Summary - 4. 가격분석

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 대시보드 중 Summary에서 가격분석을 표기하는 페이지


1. 티몰 할인율 분석
    * Tmall 전체 기준 판매가평균, 평균정가, 정가대비30%, 정가대비 50%할인 표기
/* 1. 티몰 할인율 분석 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST({TO_DT} AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_WGHT_C AS
    (
        SELECT 'DCT'                          AS CHNL_ID
              ,STATISTICS_DATE                AS X_DT
              ,DAILY_ALL_PRICE                AS CHNL_AMT_RMB
              ,DAILY_ALL_PRICE * EXRATE       AS CHNL_AMT_KRW
              ,AV_SALE_PRICE_RMB              AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,AV_SALE_PRICE_KRW              AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,AV_SALE_TAG_PRICE_RMB          AS TAG_RMB  /* 가중평균 정가    - 위안화 */
              ,AV_SALE_TAG_PRICE_KRW          AS TAG_KRW  /* 가중평균 정가    - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM DASH.DCT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_WGHT_G AS
    (
        SELECT 'DGT'                          AS CHNL_ID
              ,STATISTICS_DATE                AS X_DT
              ,DAILY_ALL_PRICE                AS CHNL_AMT_RMB
              ,DAILY_ALL_PRICE * EXRATE       AS CHNL_AMT_KRW
              ,AV_SALE_PRICE_RMB              AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,AV_SALE_PRICE_KRW              AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,AV_SALE_TAG_PRICE_RMB          AS TAG_RMB  /* 가중평균 정가    - 위안화 */
              ,AV_SALE_TAG_PRICE_KRW          AS TAG_KRW  /* 가중평균 정가    - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM DASH.DGT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_WGHT AS
    (
        SELECT COALESCE(C.X_DT, G.X_DT)                                                                                                                                               AS X_DT
              ,CASE WHEN (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) = 0 THEN 0 ELSE C.CHNL_AMT_RMB / (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) END AS C_RATE_RMB
              ,CASE WHEN (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) = 0 THEN 0 ELSE C.CHNL_AMT_KRW / (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) END AS C_RATE_KRW
              ,CASE WHEN (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) = 0 THEN 0 ELSE G.CHNL_AMT_RMB / (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) END AS G_RATE_RMB
              ,CASE WHEN (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) = 0 THEN 0 ELSE G.CHNL_AMT_KRW / (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) END AS G_RATE_KRW
          FROM WT_WGHT_C C FULL OUTER JOIN WT_WGHT_G G ON (C.X_DT = G.X_DT)
    ), WT_BASE AS
    (
        SELECT A.X_DT                                                                                 AS X_DT     /* 일자                      */
              ,(COALESCE((C.AMT_RMB * C_RATE_RMB), 0) + COALESCE((G.AMT_RMB * G_RATE_RMB), 0))        AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,(COALESCE((C.AMT_KRW * C_RATE_KRW), 0) + COALESCE((G.AMT_KRW * G_RATE_KRW), 0))        AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0))        AS TAG_RMB  /* 가중평균 판매가  - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0))        AS TAG_KRW  /* 가중평균 판매가  - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0)) * 0.5  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0)) * 0.5  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0)) * 0.7  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0)) * 0.7  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM WT_WGHT A LEFT OUTER JOIN WT_WGHT_C C ON (A.X_DT = C.X_DT)
                         LEFT OUTER JOIN WT_WGHT_G G ON (A.X_DT = G.X_DT)
    )
    SELECT CAST(X_DT AS DATE)                          AS X_DT     /* 일자                      */
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,2)), 0) AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,2)), 0) AS TAG_RMB  /* 가중평균 정가    - 위안화 */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,2)), 0) AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,2)), 0) AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,2)), 0) AS AMT_KRW  /* 가중평균 판매가  - 원화   */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,2)), 0) AS TAG_KRW  /* 가중평균 정가    - 원화   */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,2)), 0) AS D50_KRW  /* 정가 대비 50프로 - 원화   */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,2)), 0) AS D30_KRW  /* 정가 대비 30프로 - 원화   */
      FROM WT_BASE
  ORDER BY X_DT
;

2. 도우인 할인율 분석
    * 도우인 전체 기준 판매가평균, 평균정가, 정가대비30%, 정가대비 50%할인 표기
/* 2. 도우인 할인율 분석 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST({TO_DT} AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_WGHT_C AS
    (
        SELECT 'DCD'                          AS CHNL_ID
              ,STATISTICS_DATE                AS X_DT
              ,DAILY_ALL_PRICE                AS CHNL_AMT_RMB
              ,DAILY_ALL_PRICE * EXRATE       AS CHNL_AMT_KRW
              ,AV_SALE_PRICE_RMB              AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,AV_SALE_PRICE_KRW              AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,AV_SALE_TAG_PRICE_RMB          AS TAG_RMB  /* 가중평균 정가    - 위안화 */
              ,AV_SALE_TAG_PRICE_KRW          AS TAG_KRW  /* 가중평균 정가    - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM DASH.DCD_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_WGHT_G AS
    (
        SELECT 'DGD'                          AS CHNL_ID
              ,STATISTICS_DATE                AS X_DT
              ,DAILY_ALL_PRICE                AS CHNL_AMT_RMB
              ,DAILY_ALL_PRICE * EXRATE       AS CHNL_AMT_KRW
              ,AV_SALE_PRICE_RMB              AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,AV_SALE_PRICE_KRW              AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,AV_SALE_TAG_PRICE_RMB          AS TAG_RMB  /* 가중평균 정가    - 위안화 */
              ,AV_SALE_TAG_PRICE_KRW          AS TAG_KRW  /* 가중평균 정가    - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
--          FROM DASH.DGD_PRICETIMESERIESCHART
--         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
          FROM DASH.DCD_PRICETIMESERIESCHART    /* DGD_PRICETIMESERIESCHART 테이블이 없어서 임시로 작성함. 추후 DGD 테이블 생성후 변경해야함. */
         WHERE 1 = 2
    ), WT_WGHT AS
    (
        SELECT COALESCE(C.X_DT, G.X_DT)                                                                                                                                               AS X_DT
              ,CASE WHEN (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) = 0 THEN 0 ELSE C.CHNL_AMT_RMB / (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) END AS C_RATE_RMB
              ,CASE WHEN (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) = 0 THEN 0 ELSE C.CHNL_AMT_KRW / (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) END AS C_RATE_KRW
              ,CASE WHEN (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) = 0 THEN 0 ELSE G.CHNL_AMT_RMB / (COALESCE(C.CHNL_AMT_RMB, 0) + COALESCE(G.CHNL_AMT_RMB, 0)) END AS G_RATE_RMB
              ,CASE WHEN (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) = 0 THEN 0 ELSE G.CHNL_AMT_KRW / (COALESCE(C.CHNL_AMT_KRW, 0) + COALESCE(G.CHNL_AMT_KRW, 0)) END AS G_RATE_KRW
          FROM WT_WGHT_C C FULL OUTER JOIN WT_WGHT_G G ON (C.X_DT = G.X_DT)
    ), WT_BASE AS
    (
        SELECT A.X_DT                                                                                 AS X_DT     /* 일자                      */
              ,(COALESCE((C.AMT_RMB * C_RATE_RMB), 0) + COALESCE((G.AMT_RMB * G_RATE_RMB), 0))        AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,(COALESCE((C.AMT_KRW * C_RATE_KRW), 0) + COALESCE((G.AMT_KRW * G_RATE_KRW), 0))        AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0))        AS TAG_RMB  /* 가중평균 판매가  - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0))        AS TAG_KRW  /* 가중평균 판매가  - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0)) * 0.5  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0)) * 0.5  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,(COALESCE((C.TAG_RMB * C_RATE_RMB), 0) + COALESCE((G.TAG_RMB * G_RATE_RMB), 0)) * 0.7  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,(COALESCE((C.TAG_KRW * C_RATE_KRW), 0) + COALESCE((G.TAG_KRW * G_RATE_KRW), 0)) * 0.7  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM WT_WGHT A LEFT OUTER JOIN WT_WGHT_C C ON (A.X_DT = C.X_DT)
                         LEFT OUTER JOIN WT_WGHT_G G ON (A.X_DT = G.X_DT)
    )
    SELECT CAST(X_DT AS DATE)                          AS X_DT     /* 일자                      */
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,2)), 0) AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,2)), 0) AS TAG_RMB  /* 가중평균 정가    - 위안화 */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,2)), 0) AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,2)), 0) AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,2)), 0) AS AMT_KRW  /* 가중평균 판매가  - 원화   */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,2)), 0) AS TAG_KRW  /* 가중평균 정가    - 원화   */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,2)), 0) AS D50_KRW  /* 정가 대비 50프로 - 원화   */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,2)), 0) AS D30_KRW  /* 정가 대비 30프로 - 원화   */
      FROM WT_BASE
  ORDER BY X_DT
;


3. 월별 할인현황
    * 월별로 30%이상, 30~50%이상, 50%이상을 전체, Tmall글로벌, Tmall내륙, 도우인 글로벌, 도우인 내륙으로 다 표기
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
;

4. 전 채널 기준 제품별 할인율
    * 전채널기준 제품별 할인율 표기
    * 전채널 매출비중 : 전체채널의 합산값 기준이며, 전채널 할인율은: 채널 전체의 합산 기준 할인율 계산 나머지는 각 채널에서의 할인율 표기
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
;