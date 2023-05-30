/* [도우인] 5. 요일별 클릭 전환율 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,SUM(PRODUCT_IMPRESSIONS                                      )  AS PROD_CNT         /* 상품 본 수        */
              ,SUM(PRODUCT_CLICKS                                           )  AS CLCK_CNT         /* 클릭수            */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY DATE
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,CASE WHEN SUM(PROD_CNT) = 0 THEN 0 ELSE SUM(CLCK_CNT) / SUM(PROD_CNT) * 100 END  AS CLCK_RATE  /* 클릭 전환율 */
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
              ,CAST(CLCK_RATE AS DECIMAL(20,2)) AS CLCK_RATE
          FROM WT_SUM
    )
    SELECT SORT_KEY
          ,WEEK_ID   AS X_WEEK
          ,CLCK_RATE AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY