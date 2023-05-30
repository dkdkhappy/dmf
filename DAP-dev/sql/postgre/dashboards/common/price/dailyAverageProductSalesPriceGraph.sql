/* 7. 일자별 제품 평균 판매가 - 시계열그래프 SQL */
	
/* 7. 일자별 제품 평균 판매가 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT     /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'    */
              ,CAST({TO_DT} AS DATE) AS TO_DT     /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'    */
              ,TRIM({PROD_ID})       AS PROD_ID   /* 사용자가 선택한 제품ID         ex) '8809310539802' */
    ), WT_BASE AS
    (
        SELECT CAST(STATISTICS_DATE AS DATE)  AS X_DT     /* 일자                  */
              ,AV_SALE_ITEM_PRICE_RMB         AS AMT_RMB  /* 판매가       - 위안화 */
              ,AV_SALE_ITEM_PRICE_KRW         AS AMT_KRW  /* 판매가       - 원화   */
              ,SALE_TAG_ITEM_PRICE_RMB        AS TAG_RMB  /* 정가         - 위안화 */
              ,SALE_TAG_ITEM_PRICE_KRW        AS TAG_KRW  /* 정가         - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가대비 30% - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가대비 30% - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가대비 50% - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가대비 50% - 원화   */
          FROM DASH.{TAG}_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ITEM_CODE = (SELECT PROD_ID FROM WT_WHERE)
    )
    SELECT X_DT                                                    /* 일자                  */
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,2)), 0) AS AMT_RMB  /* 판매가       - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,2)), 0) AS AMT_KRW  /* 판매가       - 원화   */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,2)), 0) AS TAG_RMB  /* 정가         - 위안화 */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,2)), 0) AS TAG_KRW  /* 정가         - 원화   */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,2)), 0) AS D30_RMB  /* 정가대비 30% - 위안화 */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,2)), 0) AS D30_KRW  /* 정가대비 30% - 원화   */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,2)), 0) AS D50_RMB  /* 정가대비 50% - 위안화 */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,2)), 0) AS D50_KRW  /* 정가대비 50% - 원화   */
      FROM WT_BASE
  ORDER BY X_DT