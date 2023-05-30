/* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR           , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(REPLACE(BASE_YEAR    ||'-12-31', '-', '') AS INTEGER)  AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY       , '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(REPLACE(BASE_YEAR_YOY||'-12-31', '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,BASE_YEAR                                                   AS THIS_YEAR  /* 기준일의 연도            */
              ,BASE_YEAR_YOY                                               AS LAST_YEAR  /* 기준일의 연도       -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                                              AS SORT_KEY
              ,'올해 방문자 수'                                   AS ROW_TITL
     UNION ALL
        SELECT 2                                              AS SORT_KEY
              ,'전년도 방문자 수'                                 AS ROW_TITL
     UNION ALL
        SELECT 3                                              AS SORT_KEY
              ,'YoY (전년도 동월 대비 방문자 수 증감)'             AS ROW_TITLㄴ
     UNION ALL
        SELECT 4                                              AS SORT_KEY
              ,'MoM (당해 연도 전월 대비 방문자 수 증감)'           AS ROW_TITL
    ), WT_CAST AS
    (
        SELECT 'DCD'                                                          AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGD'                                                          AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT 'DCD'                                                          AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
     UNION ALL
        SELECT 'DGD'                                                          AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '01' THEN VIST_CNT END) AS VIST_CNT_01 /* 01월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '02' THEN VIST_CNT END) AS VIST_CNT_02 /* 02월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '03' THEN VIST_CNT END) AS VIST_CNT_03 /* 03월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '04' THEN VIST_CNT END) AS VIST_CNT_04 /* 04월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '05' THEN VIST_CNT END) AS VIST_CNT_05 /* 05월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '06' THEN VIST_CNT END) AS VIST_CNT_06 /* 06월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '07' THEN VIST_CNT END) AS VIST_CNT_07 /* 07월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '08' THEN VIST_CNT END) AS VIST_CNT_08 /* 08월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '09' THEN VIST_CNT END) AS VIST_CNT_09 /* 09월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '10' THEN VIST_CNT END) AS VIST_CNT_10 /* 10월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '11' THEN VIST_CNT END) AS VIST_CNT_11 /* 11월 방문자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '12' THEN VIST_CNT END) AS VIST_CNT_12 /* 12월 방문자수 */
          FROM WT_CAST A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '01' THEN VIST_CNT END) AS VIST_CNT_01 /* 01월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '02' THEN VIST_CNT END) AS VIST_CNT_02 /* 02월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '03' THEN VIST_CNT END) AS VIST_CNT_03 /* 03월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '04' THEN VIST_CNT END) AS VIST_CNT_04 /* 04월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '05' THEN VIST_CNT END) AS VIST_CNT_05 /* 05월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '06' THEN VIST_CNT END) AS VIST_CNT_06 /* 06월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '07' THEN VIST_CNT END) AS VIST_CNT_07 /* 07월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '08' THEN VIST_CNT END) AS VIST_CNT_08 /* 08월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '09' THEN VIST_CNT END) AS VIST_CNT_09 /* 09월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '10' THEN VIST_CNT END) AS VIST_CNT_10 /* 10월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '11' THEN VIST_CNT END) AS VIST_CNT_11 /* 11월 방문자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '12' THEN VIST_CNT END) AS VIST_CNT_12 /* 12월 방문자수 YoY */
          FROM WT_CAST_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_01
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_01, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_01, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_01  /* 01월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_02
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_02, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_01, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_02  /* 02월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_03
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_03, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_03  /* 03월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_04
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_04, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_04  /* 04월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_05
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_05, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_05  /* 05월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_06
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_06, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_06  /* 06월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_07
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_07, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_07  /* 07월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_08
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_08, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_08  /* 08월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_09
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_09, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_09  /* 09월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_10
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_10, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_10  /* 10월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_11
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_11, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_11  /* 11월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_12
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_12, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(VIST_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS VIST_CNT_12  /* 12월 방문자수 */
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_01   /* 01월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_02   /* 02월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_03   /* 03월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_04   /* 04월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_05   /* 05월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_06   /* 06월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_07   /* 07월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_08   /* 08월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_09   /* 09월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_10   /* 10월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_11   /* 11월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') END AS VIST_CNT_12   /* 12월 방문자수 */
      FROM WT_BASE
  ORDER BY SORT_KEY