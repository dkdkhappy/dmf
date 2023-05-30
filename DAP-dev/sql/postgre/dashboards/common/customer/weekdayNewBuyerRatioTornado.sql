/* 5. 요일별 첫방문 구매자 비중 - 토네이도 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                 AS SORT_KEY
              ,'FRST'            AS L_LGND_ID  /* 첫 방문 */ 
              ,'첫 방문'         AS L_LGND_NM 
     UNION ALL
        SELECT 2                 AS SORT_KEY
              ,'PAID'            AS L_LGND_ID  /* 구매자 비중 */ 
              ,'구매자 비중'     AS L_LGND_NM 
    ), WT_WEEK AS
    (
        SELECT 0 AS WEEK_NO, 'Mon' AS WEEK_ID UNION ALL
        SELECT 1 AS WEEK_NO, 'Tue' AS WEEK_ID UNION ALL
        SELECT 2 AS WEEK_NO, 'Wed' AS WEEK_ID UNION ALL
        SELECT 3 AS WEEK_NO, 'Thu' AS WEEK_ID UNION ALL
        SELECT 4 AS WEEK_NO, 'Fri' AS WEEK_ID UNION ALL
        SELECT 5 AS WEEK_NO, 'Sat' AS WEEK_ID UNION ALL
        SELECT 6 AS WEEK_NO, 'Sun' AS WEEK_ID 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,SUM(VIST_CNT)                                AS VIST_CNT  /* 방문자수   */
              ,SUM(FRST_CNT)                                AS FRST_CNT  /* 첫방문자수 */
              ,SUM(PAID_CNT)                                AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')
    ), WT_RATE AS
    (
        SELECT WEEK_ID
              ,VIST_CNT       /* 방문자수 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE FRST_CNT / VIST_CNT * 100 END AS FRST_RATE  /* 첫 방문자 비율 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE PAID_CNT / VIST_CNT * 100 END AS PAID_RATE  /* 구매자    비율 */
          FROM WT_SUM A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,B.WEEK_NO
              ,B.WEEK_ID
              ,CASE 
                 WHEN L_LGND_ID = 'FRST' THEN FRST_RATE
                 WHEN L_LGND_ID = 'PAID' THEN PAID_RATE
               END AS Y_VAL  /* FRST:첫 방문자 비율, PAID:구매자 비율 */
          FROM WT_COPY A
              ,WT_WEEK B LEFT OUTER JOIN WT_RATE C ON (B.WEEK_ID = C.WEEK_ID)
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,WEEK_ID                      AS Y_WEEK
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS X_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,WEEK_NO
