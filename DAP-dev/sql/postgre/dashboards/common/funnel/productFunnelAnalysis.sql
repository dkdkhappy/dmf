/* 16. 제품벌 Funnel 분석 - 퍼널 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'VIST'  AS LGND_ID
              ,'방문'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'ORDR'  AS LGND_ID
              ,'주문'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'REFD'  AS LGND_ID
              ,'환불'  AS LGND_NM
    ), WT_DATA AS 
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)                                                                                          AS VIST_CNT  /* 방문 */
              ,SUM(NUMBER_OF_BUYERS_WHO_PLACE_AN_ORDER)                                                                         AS ORDR_CNT  /* 주문 */
              ,SUM(NUMBER_OF_PAID_BUYERS)                                                                                       AS PAID_CNT  /* 구매 */
              ,CASE WHEN SUM(CUSTOMER_PRICE) = 0 THEN 0 ELSE SUM(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT) / SUM(CUSTOMER_PRICE) END AS REFD_CNT  /* 환불 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
      GROUP BY PRODUCT_ID
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = B.PRODUCT_ID            
               ) AS SORT_KEY_PROD
              ,PRODUCT_ID                              AS PROD_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(B.PRODUCT_ID) AS PROD_NM
              ,SORT_KEY AS LGND_SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE 
                 WHEN LGND_ID = 'VIST' THEN VIST_CNT  /* 방문 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT  /* 환불 */
               END AS STEP_CNT
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY_PROD
          ,LGND_SORT_KEY
          ,PROD_ID
          ,PROD_NM
          ,LGND_ID
          ,LGND_NM
          ,CAST(STEP_CNT AS DECIMAL(20,0))                              AS STEP_CNT
          ,CAST(STEP_CNT / SUM(STEP_CNT) OVER() * 100 AS DECIMAL(20,2)) AS STEP_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY_PROD
          ,LGND_SORT_KEY