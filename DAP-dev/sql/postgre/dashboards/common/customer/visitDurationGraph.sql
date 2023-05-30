/* 6. 방문자 평균 체류시간 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST((SELECT FR_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS FR_DT
              ,TO_CHAR(CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS TO_DT
    ), WT_CAST AS
    (
        SELECT 1      AS SORT_KEY
              ,'VIST' AS L_LGND_ID
              ,'올해' AS L_LGND_NM 
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 2          AS SORT_KEY
              ,'VIST_YOY' AS L_LGND_ID
              ,'작년'     AS L_LGND_NM 
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
    ), WT_BASE AS
    (
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,CASE 
             WHEN L_LGND_ID = 'VIST_YOY' 
             THEN TO_CHAR(CAST(STATISTICS_DATE AS DATE) + INTERVAL '1' YEAR, 'YYYY-MM-DD')
             ELSE STATISTICS_DATE
           END       AS X_DT
          ,STAY_TIME AS Y_VAL
      FROM WT_CAST A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
