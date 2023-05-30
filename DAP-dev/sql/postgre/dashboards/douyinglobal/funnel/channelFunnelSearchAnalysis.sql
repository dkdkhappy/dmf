/* 13. 채널 퍼널분석 - 퍼널 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'IMPR'  AS LGND_ID
              ,'노출'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'PRIM'  AS LGND_ID
              ,'상품노출'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'CLCK'  AS LGND_ID
              ,'클릭'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM

    ), WT_DATA AS 
    (
        SELECT SUM(num_people_search_results_exposed_live_broadcast)                                AS IMPR_CNT  /* 노출 */
              ,SUM(num_people_searched_products_live_broadcast)                              AS PRIM_CNT  /* 상품노출 */
              ,SUM(num_people_searched_products_clicked_live_broadcast)                              AS CLCK_CNT  /* 클릭 */
              ,SUM(num_people_search_transactions_live_broadcast)                             AS PAID_CNT  /* 구매 */
          FROM DASH_RAW.OVER_{TAG}_FIND_FUNNEL A
         WHERE DATE   BETWEEN (SELECT CAST(CAST(FR_DT AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT AS TEXT) AS DATE) FROM WT_WHERE)         
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE 
                 WHEN LGND_ID = 'IMPR' THEN IMPR_CNT  /* 노출 */
                 WHEN LGND_ID = 'PRIM' THEN PRIM_CNT  /* 상품노출 */
                 WHEN LGND_ID = 'CLCK' THEN CLCK_CNT  /* 클릭 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
               END AS STEP_CNT
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,LGND_ID
          ,LGND_NM
          ,CAST(STEP_CNT AS DECIMAL(20,0))                              AS STEP_CNT
          ,CAST(STEP_CNT / SUM(STEP_CNT) OVER() * 100 AS DECIMAL(20,2)) AS STEP_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY