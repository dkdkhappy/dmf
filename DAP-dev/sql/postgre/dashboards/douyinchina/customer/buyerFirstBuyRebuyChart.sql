/* buyerFirstBuyRebuyChart.sql */
/* [도우인] 7. 구매자 첫구매/재구매 비율 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                 AS SORT_KEY
              ,'PAID'            AS L_LGND_ID  /* 일 구매자수    */ 
              ,'일 구매자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 2                 AS SORT_KEY
              ,'PAID_WEEK'       AS L_LGND_ID  /* 주 구매자수    */ 
              ,'주 구매자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 3                 AS SORT_KEY
              ,'PAID_MNTH'       AS L_LGND_ID  /* 월 구매자수    */ 
              ,'월 구매자수'     AS L_LGND_NM 
     UNION ALL
        SELECT 4                 AS SORT_KEY
              ,'REPD'            AS L_LGND_ID  /* 재 구매자 비율 */ 
              ,'재구매자 비율'  AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')     AS STATISTICS_DATE
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS REPD_CNT         /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS PAID_CNT         /* 구매자 수        */
          FROM DASH_RAW.OVER_{TAG}_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY DATE
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(PAID_CNT)                                                                           AS PAID_CNT       /* 구매자수                  */
              ,AVG(SUM(PAID_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS PAID_CNT_WEEK  /* 구매자수 - 이동평균( 5일) */
              ,AVG(SUM(PAID_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS PAID_CNT_MNTH  /* 구매자수 - 이동평균(30일) */
              ,    SUM(REPD_CNT)                                                                           AS REPD_CNT       /* 재구매자수                */
          FROM WT_CAST A
      GROUP BY STATISTICS_DATE
    ), WT_RATE AS
    (
        SELECT STATISTICS_DATE
              ,PAID_CNT       /* 구매자수                  */
              ,PAID_CNT_WEEK  /* 구매자수 - 이동평균( 5일) */
              ,PAID_CNT_MNTH  /* 구매자수 - 이동평균(30일) */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE REPD_CNT / PAID_CNT * 100 END AS REPD_RATE  /* 재구매자 비율 */
          FROM WT_MOVE A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'PAID_WEEK' THEN PAID_CNT_WEEK
                 WHEN L_LGND_ID = 'PAID_MNTH' THEN PAID_CNT_MNTH
                 WHEN L_LGND_ID = 'REPD'      THEN REPD_RATE
               END AS Y_VAL  /* PAID:일 구매자수, PAID_WEEK:주 구매자수, PAID_MNTH:월 구매자수, REPD:재구매자 비율 */
          FROM WT_COPY A
              ,WT_RATE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID  /* PAID:일 구매자수 (바), PAID_WEEK:주 구매자수 (바), PAID_MNTH:월 구매자수 (바), REPD:재구매자 비율 (라인) */
          ,L_LGND_NM
          ,X_DT
          /*,CAST(Y_VAL AS DECIMAL(20,0)) AS Y_VAL */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2, 3) THEN CAST(CAST(Y_VAL AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT