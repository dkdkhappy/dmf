/* 3. 요일/시간 방문자수량 히트맵 - 히트맵 SQL */
/*    조회결과 가공방법 방문자수 ==> [[WEEK_NO, HOUR_NO, VIST_CNT], [WEEK_NO, HOUR_NO, VIST_CNT], ...] */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')                AS WEEK_ID
              ,CAST(STATISTICS_HOURS                     AS DECIMAL(20,0)) AS HOUR_NO
              ,CAST(REPLACE(NUMBER_OF_VISITORS, ',', '') AS DECIMAL(20,0)) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_SHOP_BY_HOUR A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
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
               END WEEK_NO
              ,HOUR_NO
              ,VIST_CNT  /* 방문자수 */
          FROM WT_CAST A
    )
   SELECT WEEK_NO
         ,HOUR_NO
         ,CAST(SUM(VIST_CNT) AS DECIMAL(20,0)) AS VIST_CNT /* 방문자수 */
     FROM WT_BASE A
 GROUP BY WEEK_NO
         ,HOUR_NO
 ORDER BY WEEK_NO
         ,HOUR_NO
