/* 15. 당해 연도 채널 구매전환율 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT      /* 기준일의  1월  1일       */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT      /* 기준일의 12월 31일       */
              ,FRST_DT_YEAR_YOY         AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,BASE_YEAR_YOY||'-12-31'  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,BASE_YEAR                AS THIS_YEAR  /* 기준일의 연도            */
              ,BASE_YEAR_YOY            AS LAST_YEAR  /* 기준일의 연도       -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                                              AS SORT_KEY
              ,'올해 '   ||  (SELECT THIS_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 2                                              AS SORT_KEY
              ,'전년도 ' ||  (SELECT LAST_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 3                                              AS SORT_KEY
              ,'YoY'                                          AS ROW_TITL
     UNION ALL
        SELECT 4                                              AS SORT_KEY
              ,'MoM'                                          AS ROW_TITL
    ), WT_ORDR AS
    (
        SELECT CAST(CAST(DATE AS TEXT) AS DATE)
              ,num_people_searched_products_clicked     AS CLCK_CNT  /* 방문 */
              ,num_people_search_transactions_live_broadcast    AS PAID_CNT  /* 구매 */
          FROM DASH_RAW.OVER_{TAG}_FIND_FUNNEL A
         WHERE CAST(CAST(DATE AS TEXT) AS DATE)   BETWEEN (SELECT CAST(CAST(FR_DT AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT AS TEXT) AS DATE) FROM WT_WHERE)         
    ), WT_ORDR_YOY AS
    (
        SELECT CAST(CAST(DATE AS TEXT) AS DATE)
              ,num_people_searched_products_clicked     AS CLCK_CNT  /* 방문 */
              ,num_people_search_transactions_live_broadcast    AS PAID_CNT  /* 구매 */
          FROM DASH_RAW.OVER_{TAG}_FIND_FUNNEL A
         WHERE CAST(CAST(DATE AS TEXT) AS DATE)   BETWEEN (SELECT CAST(CAST(FR_DT_YOY AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT_YOY AS TEXT) AS DATE) FROM WT_WHERE)                   

    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 01 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 01 THEN CLCK_CNT END) * 100 AS ORDR_RATE_01  /* 01월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 02 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 02 THEN CLCK_CNT END) * 100 AS ORDR_RATE_02  /* 02월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 03 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 03 THEN CLCK_CNT END) * 100 AS ORDR_RATE_03  /* 03월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 04 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 04 THEN CLCK_CNT END) * 100 AS ORDR_RATE_04  /* 04월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 05 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 05 THEN CLCK_CNT END) * 100 AS ORDR_RATE_05  /* 05월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 06 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 06 THEN CLCK_CNT END) * 100 AS ORDR_RATE_06  /* 06월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 07 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 07 THEN CLCK_CNT END) * 100 AS ORDR_RATE_07  /* 07월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 08 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 08 THEN CLCK_CNT END) * 100 AS ORDR_RATE_08  /* 08월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 09 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 09 THEN CLCK_CNT END) * 100 AS ORDR_RATE_09  /* 09월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 10 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 10 THEN CLCK_CNT END) * 100 AS ORDR_RATE_10  /* 10월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 11 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 11 THEN CLCK_CNT END) * 100 AS ORDR_RATE_11  /* 11월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 12 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 12 THEN CLCK_CNT END) * 100 AS ORDR_RATE_12  /* 12월 구매 전환율 */
          FROM WT_ORDR A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 01 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 01 THEN CLCK_CNT END) * 100 AS ORDR_RATE_01  /* 01월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 02 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 02 THEN CLCK_CNT END) * 100 AS ORDR_RATE_02  /* 02월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 03 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 03 THEN CLCK_CNT END) * 100 AS ORDR_RATE_03  /* 03월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 04 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 04 THEN CLCK_CNT END) * 100 AS ORDR_RATE_04  /* 04월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 05 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 05 THEN CLCK_CNT END) * 100 AS ORDR_RATE_05  /* 05월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 06 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 06 THEN CLCK_CNT END) * 100 AS ORDR_RATE_06  /* 06월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 07 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 07 THEN CLCK_CNT END) * 100 AS ORDR_RATE_07  /* 07월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 08 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 08 THEN CLCK_CNT END) * 100 AS ORDR_RATE_08  /* 08월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 09 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 09 THEN CLCK_CNT END) * 100 AS ORDR_RATE_09  /* 09월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 10 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 10 THEN CLCK_CNT END) * 100 AS ORDR_RATE_10  /* 10월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 11 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 11 THEN CLCK_CNT END) * 100 AS ORDR_RATE_11  /* 11월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 12 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(DATE AS DATE)) = 12 THEN CLCK_CNT END) * 100 AS ORDR_RATE_12  /* 12월 구매 전환율 - YoY */
          FROM WT_ORDR_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_01
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_01, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_01, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_01, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_12, 2) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_01
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_02
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_02, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_02, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_02, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_01, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_02
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_03
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_03, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_03, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_03, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_02, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_03
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_04
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_04, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_04, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_04, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_03, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_04
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_05
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_05, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_05, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_05, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_04, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_05
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_06
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_06, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_06, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_06, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_05, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_06
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_07
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_07, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_07, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_07, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_06, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_07
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_08
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_08, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_08, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_08, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_07, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_08
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_09
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_09, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_09, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_09, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_08, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_09
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_10
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_10, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_10, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_10, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_09, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_10
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_11
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_11, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_11, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_11, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_10, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_11
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ORDR_RATE_12
                  WHEN A.SORT_KEY = 3
                  THEN LAG(ORDR_RATE_12, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_12, 1) OVER(ORDER BY A.SORT_KEY))
                  WHEN A.SORT_KEY = 4
                  THEN LAG(ORDR_RATE_12, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(ORDR_RATE_11, 3) OVER(ORDER BY A.SORT_KEY))
               END AS ORDR_RATE_12
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(ORDR_RATE_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_01   /* 01월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_02   /* 02월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_03   /* 03월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_04   /* 04월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_05   /* 05월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_06   /* 06월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_07   /* 07월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_08   /* 08월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_09   /* 09월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_10   /* 10월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_11   /* 11월 구매 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_12   /* 12월 구매 전환율 */
      FROM WT_BASE
  ORDER BY SORT_KEY