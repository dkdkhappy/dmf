/* 7. 제품별 Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS   AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
     UNION ALL
        SELECT 9999999999999   AS PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS   AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(PGVW_CNT) AS PGVW_CNT
          FROM WT_PGVW A
      GROUP BY PRODUCT_ID
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
               ) AS SORT_KEY
              ,PRODUCT_ID AS L_LGND_ID
              ,CASE
                 WHEN PRODUCT_ID = 9999999999999 THEN '전체 페이지뷰'
                 ELSE DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,PGVW_CNT        AS Y_VAL  /* 페이지뷰 수 */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT