/* 5. Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PGVW AS 
    (
        SELECT STATISTICS_DATE          AS X_DT
              ,SUM(PAGEVIEWS)           AS PGVW_CNT  /* 페이지뷰수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,PGVW_CNT
          FROM WT_PGVW
    )
    SELECT X_DT
          ,PGVW_CNT AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT