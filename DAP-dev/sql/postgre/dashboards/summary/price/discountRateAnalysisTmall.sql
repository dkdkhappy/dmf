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
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,0)), 0) AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,0)), 0) AS TAG_RMB  /* 가중평균 정가    - 위안화 */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,0)), 0) AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,0)), 0) AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,0)), 0) AS AMT_KRW  /* 가중평균 판매가  - 원화   */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,0)), 0) AS TAG_KRW  /* 가중평균 정가    - 원화   */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,0)), 0) AS D50_KRW  /* 정가 대비 50프로 - 원화   */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,0)), 0) AS D30_KRW  /* 정가 대비 30프로 - 원화   */
      FROM WT_BASE
  ORDER BY X_DT