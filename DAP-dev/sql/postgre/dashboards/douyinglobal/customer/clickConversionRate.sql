/* [도우인] 4. 클릭 전환율 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT CAST(REPLACE(TO_CHAR(CAST({FR_DT} AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD'), '-', '') AS INTEGER)  AS FR_DT
              ,CAST(REPLACE(TO_CHAR(CAST({TO_DT} AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD'), '-', '') AS INTEGER)  AS TO_DT
    ), WT_CAST AS
    (
        SELECT 1      AS SORT_KEY
              ,'VIST' AS L_LGND_ID
              ,'올해' AS L_LGND_NM 
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,SUM(PRODUCT_IMPRESSIONS                                      )  AS PROD_CNT         /* 상품 본 수        */
              ,SUM(PRODUCT_CLICKS                                           )  AS CLCK_CNT         /* 클릭수            */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY DATE
     UNION ALL
        SELECT 2          AS SORT_KEY
              ,'VIST_YOY' AS L_LGND_ID
              ,'작년'     AS L_LGND_NM 
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,SUM(PRODUCT_IMPRESSIONS                                      )  AS PROD_CNT         /* 상품 본 수        */
              ,SUM(PRODUCT_CLICKS                                           )  AS CLCK_CNT         /* 클릭수            */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
      GROUP BY DATE
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
          ,CASE WHEN PROD_CNT = 0 THEN 0 ELSE CLCK_CNT / PROD_CNT * 100 END  AS Y_VAL
      FROM WT_CAST A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT