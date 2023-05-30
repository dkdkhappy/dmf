/* 3. 요일별 매출그래프 바그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01' */
              ,{TO_DT} AS TO_DT /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13' */
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
              ,PAYMENT_AMOUNT           AS PAY_AMT  /* 매출액 */
              ,SUCCESSFUL_REFUND_AMOUNT AS RFED_AMT /* 환불액 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,SUM(PAY_AMT)                                 AS PAY_AMT  /* 매출액 */
              ,SUM(RFED_AMT)                                AS RFED_AMT /* 환불액 */
              ,SUM(PAY_AMT) - SUM(RFED_AMT)                 AS SALE_AMT /* 환불제외 매출액 */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')
    ), WT_BASE AS
    (
        SELECT B.WEEK_NO
              ,B.WEEK_ID
              ,C.SALE_AMT
          FROM WT_WEEK B LEFT OUTER JOIN WT_SUM C ON (B.WEEK_ID = C.WEEK_ID)
    )
    SELECT WEEK_NO                         AS SORT_KEY
          ,WEEK_ID                         AS X_WEEK
          ,CAST(SALE_AMT AS DECIMAL(20,0)) AS Y_VAL
     FROM WT_BASE
 ORDER BY WEEK_NO
