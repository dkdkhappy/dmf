/* 1. Unique Visitor (UV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_VIST AS 
    (
        SELECT STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,VIST_CNT
          FROM WT_VIST
    )
    SELECT X_DT
          ,VIST_CNT AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT