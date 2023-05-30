/* 4. 방문자 첫방문/재방문 그래프 - 방문자 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                 AS SORT_KEY
              ,'VIST'            AS L_LGND_ID  /* 일 방문자수    */ 
              ,'일 방문자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 2                 AS SORT_KEY
              ,'VIST_WEEK'       AS L_LGND_ID  /* 주 방문자수    */ 
              ,'주 방문자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 3                 AS SORT_KEY
              ,'VIST_MNTH'       AS L_LGND_ID  /* 월 방문자수    */ 
              ,'월 방문자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 4                 AS SORT_KEY
              ,'FRST'            AS L_LGND_ID  /* 첫 방문자 비율 */ 
              ,'첫 방문자 비율'  AS L_LGND_NM 
     UNION ALL
        SELECT 5                 AS SORT_KEY
              ,'PAID'            AS L_LGND_ID  /* 구매자 비율    */ 
              ,'구매자 비율'     AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(VIST_CNT)                                                                           AS VIST_CNT       /* 방문자수                  */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
              ,    SUM(FRST_CNT)                                                                           AS FRST_CNT       /* 첫방문자수                */
              ,    SUM(PAID_CNT)                                                                           AS PAID_CNT       /* 구매자수                  */
          FROM WT_CAST A
      GROUP BY STATISTICS_DATE
    ), WT_RATE AS
    (
        SELECT STATISTICS_DATE
              ,VIST_CNT       /* 방문자수                  */
              ,VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE FRST_CNT / VIST_CNT * 100 END AS FRST_RATE  /* 첫 방문자 비율 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE PAID_CNT / VIST_CNT * 100 END AS PAID_RATE  /* 구매자    비율 */
          FROM WT_MOVE A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'VIST'      THEN VIST_CNT
                 WHEN L_LGND_ID = 'VIST_WEEK' THEN VIST_CNT_WEEK
                 WHEN L_LGND_ID = 'VIST_MNTH' THEN VIST_CNT_MNTH
                 WHEN L_LGND_ID = 'FRST'      THEN FRST_RATE
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_RATE
               END AS Y_VAL  /* VIST:일 방문자수, VIST_WEEK:주 방문자수, VIST_MNTH:월 방문자수, FRST:첫 방문자 비율, PAID:구매자 비율 */
          FROM WT_COPY A
              ,WT_RATE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          /*,CAST(Y_VAL AS DECIMAL(20,0)) AS Y_VAL */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2, 3) THEN CAST(CAST(Y_VAL AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
