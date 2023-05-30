/* 7. 요일별 방문자 평균 체류시간 그래프- 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_AVG AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,CAST(AVG(STAY_TIME) AS DECIMAL(20,4))        AS STAY_TIME  /* 평균체류시간 */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')
    ), WT_BASE AS
    (
        SELECT CASE
                 WHEN WEEK_ID = 'Mon' THEN 0
                 WHEN WEEK_ID = 'Tue' THEN 1
                 WHEN WEEK_ID = 'Wed' THEN 2
                 WHEN WEEK_ID = 'Thu' THEN 3
                 WHEN WEEK_ID = 'Fri' THEN 4
                 WHEN WEEK_ID = 'Sat' THEN 5
                 WHEN WEEK_ID = 'Sun' THEN 6
               END SORT_KEY
              ,WEEK_ID
              ,CAST(STAY_TIME AS DECIMAL(20,2)) AS STAY_TIME
          FROM WT_AVG
    )
    SELECT SORT_KEY
          ,WEEK_ID   AS X_WEEK
          ,STAY_TIME AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY
