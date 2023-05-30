● 중국 매출대시보드 - 4. 퍼널 분석

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 대시보드 중 퍼널분석 방문자 중 얼마나 실제로 구매까지 이어졌는지 얼마나 많은 사람이 환불을 하는지를 분석하는 화면 (방문 -> 주문 -> 구매 -> 환불 단계로 분석)
    ※ 본 화면은 그 중 방문자 수와 페이지뷰 관련 정보 전달


1. Unique Visitor (UV)
    * 기간 선택 후 날짜에 따른 채널 전제 (예: dgt) 방문자 수 디스플레이, 주 smoothing은 7일 월 smoothing은 30일 이동평균

/* 1. Unique Visitor (UV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_VIST AS 
    (
        SELECT STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,VIST_CNT
          FROM WT_VIST
    )
    SELECT X_DT
          ,VIST_CNT AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT
;


2. Unique Visitor (UV) 추이 분석
    * 방문자 수 월별로 합산하여 디스플레이 
    * YOY는 올해수치 / 작년수치 - 1 
    * MOM은 이번 달 수치/ 전달 수치 -1 

/* 2. Unique Visitor (UV) 추이 분석 - 표 SQL */
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
    ), WT_VIST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_VIST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS VIST_CNT_01  /* 01월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS VIST_CNT_02  /* 02월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS VIST_CNT_03  /* 03월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS VIST_CNT_04  /* 04월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS VIST_CNT_05  /* 05월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS VIST_CNT_06  /* 06월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS VIST_CNT_07  /* 07월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS VIST_CNT_08  /* 08월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS VIST_CNT_09  /* 09월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS VIST_CNT_10  /* 10월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS VIST_CNT_11  /* 11월 방문자 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS VIST_CNT_12  /* 12월 방문자 수 */
          FROM WT_VIST A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS VIST_CNT_01  /* 01월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS VIST_CNT_02  /* 02월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS VIST_CNT_03  /* 03월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS VIST_CNT_04  /* 04월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS VIST_CNT_05  /* 05월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS VIST_CNT_06  /* 06월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS VIST_CNT_07  /* 07월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS VIST_CNT_08  /* 08월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS VIST_CNT_09  /* 09월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS VIST_CNT_10  /* 10월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS VIST_CNT_11  /* 11월 방문자 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS VIST_CNT_12  /* 12월 방문자 수 - YoY */
          FROM WT_VIST_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_01
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_01
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_02
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_02
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_03
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_03
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_04
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_04
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_05
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_05
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_06
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_06
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_07
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_07
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_08
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_08
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_09
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_09
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_10
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_10
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_11
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_11
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN VIST_CNT_12
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(VIST_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS VIST_CNT_12
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_01   /* 01월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_02   /* 02월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_03   /* 03월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_04   /* 04월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_05   /* 05월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_06   /* 06월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_07   /* 07월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_08   /* 08월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_09   /* 09월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_10   /* 10월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_11   /* 11월 방문자 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_12   /* 12월 방문자 */
      FROM WT_BASE
  ORDER BY SORT_KEY


3. 제품별 Unique Visitor (UV)
    * 기간 선택에 따른 제품별 페이지 방문자 수 디스플레이, 주 smoothing은 7일, 월 smoothing은 30일 이동평균 
    * 채널 전제 방문자 수도 같이 디스플레이 

/* 제품 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PROD AS
    (
        SELECT DISTINCT
               CAST(PRODUCT_ID AS VARCHAR) AS PRODUCT_ID
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    )
    SELECT A.PRODUCT_ID   AS PROD_ID
          ,A.PRODUCT_NAME AS PROD_NM
      FROM DASH_RAW.OVER_DGT_ID_NAME_URL A INNER JOIN WT_PROD B ON (A.PRODUCT_ID = B.PRODUCT_ID)
  ORDER BY PRODUCT_NAME COLLATE "ko_KR.utf8"


/* 3. 제품별 Unique Visitor (UV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_VIST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
     UNION ALL
        SELECT 9999999999999 AS PRODUCT_ID
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_VIST A
      GROUP BY PRODUCT_ID
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
               ) AS SORT_KEY
              ,PRODUCT_ID AS L_LGND_ID
              ,CASE
                 WHEN PRODUCT_ID = 9999999999999 THEN '전체 방문자'
                 ELSE DASH_RAW.SF_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,VIST_CNT        AS Y_VAL  /* 방문자 수 */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT


4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5)
    * 전년도/당해 연도도 각각 등수, 제품명, 방문자 수, 방문자 비중 디스플레이 (비중 = 제품별 방문자/ 채널 전제 방문자) 
    * 중국 매출 대쉬보드 -> Tmall 글로벌 -> 매출 -> 제품별 매출 정보 데이터 뷰어랑 동일한 형태 
        ex) 현재 23년 3월 28일이면 전년 동기는 22년 1월 1일 - 22년 3월 28일

/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 방문자 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS VIST_RANK
     UNION ALL
        SELECT 2 AS VIST_RANK
     UNION ALL
        SELECT 3 AS VIST_RANK
     UNION ALL
        SELECT 4 AS VIST_RANK
     UNION ALL
        SELECT 5 AS VIST_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_VIST AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_VIST_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'     AS RANK_TYPE  /* 금년순위 */
              ,VIST_RANK  AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT   AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE VIST_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY' AS RANK_TYPE  /* 전년순위 */
              ,VIST_RANK  AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT   AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE VIST_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.VIST_RANK                                                  /* 순위          */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID   */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명   */
              ,C.VIST_CNT                                  AS VIST_CNT_YOY  /* 전년 방문자수 */
              ,C.VIST_CNT / Y.VIST_CNT * 100               AS VIST_RATE_YOY /* 전년 방문비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID   */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명   */
              ,B.VIST_CNT                                  AS VIST_CNT      /* 금년 방문자수 */
              ,B.VIST_CNT / T.VIST_CNT * 100               AS VIST_RATE     /* 금년 방문비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.VIST_RANK = B.VIST_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.VIST_RANK = C.VIST_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT VIST_RANK                                                                                    /* 순위          */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID   */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT_YOY   /* 전년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE_YOY  /* 전년 방문비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID   */
          ,PROD_NM                                                                                      /* 금년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT       /* 금년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE      /* 금년 방문비중 */
      FROM WT_BASE
  ORDER BY VIST_RANK


/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년 동월 대비 방문자 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH        AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
              ,FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS VIST_RANK
     UNION ALL
        SELECT 2 AS VIST_RANK
     UNION ALL
        SELECT 3 AS VIST_RANK
     UNION ALL
        SELECT 4 AS VIST_RANK
     UNION ALL
        SELECT 5 AS VIST_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_VIST AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
      GROUP BY PRODUCT_ID
    ), WT_VIST_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위 */
              ,VIST_RANK   AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT    AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE VIST_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위 */
              ,VIST_RANK   AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT    AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE VIST_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.VIST_RANK                                                   /* 순위         */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID   */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명   */
              ,C.VIST_CNT                                  AS VIST_CNT_YOY  /* 전년 방문수   */
              ,C.VIST_CNT / Y.VIST_CNT * 100               AS VIST_RATE_YOY /* 전년 방문비중 */

              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID   */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명   */
              ,B.VIST_CNT                                  AS VIST_CNT      /* 금년 방문수   */
              ,B.VIST_CNT / T.VIST_CNT * 100               AS VIST_RATE     /* 금년 방문비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.VIST_RANK = B.VIST_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.VIST_RANK = C.VIST_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT VIST_RANK                                                                                    /* 순위          */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID   */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT_YOY   /* 전년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE_YOY  /* 전년 방문비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID   */
          ,PROD_NM                                                                                      /* 금년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT       /* 금년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE      /* 금년 방문비중 */
      FROM WT_BASE
  ORDER BY VIST_RANK


/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 월별 방문자 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS VIST_RANK
     UNION ALL
        SELECT 2 AS VIST_RANK
     UNION ALL
        SELECT 3 AS VIST_RANK
     UNION ALL
        SELECT 4 AS VIST_RANK
     UNION ALL
        SELECT 5 AS VIST_RANK
    ), WT_VIST AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS) AS VIST_CNT   /* 방문 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT  /* 방문자수 */
          FROM WT_VIST A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND VIST_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                         AS RANK_TYPE  /* 순위     */
              ,VIST_RANK                         AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                          AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND VIST_RANK <= 5
    )
    SELECT A.VIST_RANK                                                      /* 순위        */
          ,COALESCE(CAST(RANK_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01  /* 01월 제품ID */
          ,COALESCE(CAST(RANK_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02  /* 02월 제품ID */
          ,COALESCE(CAST(RANK_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03  /* 03월 제품ID */
          ,COALESCE(CAST(RANK_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04  /* 04월 제품ID */
          ,COALESCE(CAST(RANK_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05  /* 05월 제품ID */
          ,COALESCE(CAST(RANK_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06  /* 06월 제품ID */
          ,COALESCE(CAST(RANK_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07  /* 07월 제품ID */
          ,COALESCE(CAST(RANK_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08  /* 08월 제품ID */
          ,COALESCE(CAST(RANK_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09  /* 09월 제품ID */
          ,COALESCE(CAST(RANK_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10  /* 10월 제품ID */
          ,COALESCE(CAST(RANK_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11  /* 11월 제품ID */
          ,COALESCE(CAST(RANK_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12  /* 12월 제품ID */

          ,COALESCE(CAST(RANK_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01  /* 01월 제품명 */
          ,COALESCE(CAST(RANK_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02  /* 02월 제품명 */
          ,COALESCE(CAST(RANK_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03  /* 03월 제품명 */
          ,COALESCE(CAST(RANK_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04  /* 04월 제품명 */
          ,COALESCE(CAST(RANK_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05  /* 05월 제품명 */
          ,COALESCE(CAST(RANK_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06  /* 06월 제품명 */
          ,COALESCE(CAST(RANK_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07  /* 07월 제품명 */
          ,COALESCE(CAST(RANK_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08  /* 08월 제품명 */
          ,COALESCE(CAST(RANK_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09  /* 09월 제품명 */
          ,COALESCE(CAST(RANK_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10  /* 10월 제품명 */
          ,COALESCE(CAST(RANK_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11  /* 11월 제품명 */
          ,COALESCE(CAST(RANK_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12  /* 12월 제품명 */

          ,CAST(RANK_01.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_01 /* 01월 방문수 */
          ,CAST(RANK_02.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_02 /* 02월 방문수 */
          ,CAST(RANK_03.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_03 /* 03월 방문수 */
          ,CAST(RANK_04.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_04 /* 04월 방문수 */
          ,CAST(RANK_05.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_05 /* 05월 방문수 */
          ,CAST(RANK_06.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_06 /* 06월 방문수 */
          ,CAST(RANK_07.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_07 /* 07월 방문수 */
          ,CAST(RANK_08.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_08 /* 08월 방문수 */
          ,CAST(RANK_09.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_09 /* 09월 방문수 */
          ,CAST(RANK_10.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_10 /* 10월 방문수 */
          ,CAST(RANK_11.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_11 /* 11월 방문수 */
          ,CAST(RANK_12.VIST_CNT AS DECIMAL(20,0))           AS VIST_CNT_12 /* 12월 방문수 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.VIST_RANK = RANK_01.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.VIST_RANK = RANK_02.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.VIST_RANK = RANK_03.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.VIST_RANK = RANK_04.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.VIST_RANK = RANK_05.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.VIST_RANK = RANK_06.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.VIST_RANK = RANK_07.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.VIST_RANK = RANK_08.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.VIST_RANK = RANK_09.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.VIST_RANK = RANK_10.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.VIST_RANK = RANK_11.VIST_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.VIST_RANK = RANK_12.VIST_RANK)
  ORDER BY A.VIST_RANK


5. Page View (PV)
    * 기간 선택 후 날짜에 따른 채널 전제 (예: dgt) 페이지뷰 디스플레이, 주 smoothing은 7일 월 smoothing은 30일 이동평균

/* 5. Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PGVW AS 
    (
        SELECT STATISTICS_DATE          AS X_DT
              ,SUM(PAGEVIEWS)           AS PGVW_CNT  /* 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,PGVW_CNT
          FROM WT_PGVW
    )
    SELECT X_DT
          ,PGVW_CNT AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT
;


6. Page View (PV) 추이 분석
    * 페이지뷰 월별로 합산하여 디스플레이 
    * YOY는 올해수지 / 작년수지 - 1 
    * MOM은 이번달 수치/ 전달 수지 -1 

/* 6. Page View (PV) 추이 분석 - 표 SQL */
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
    ), WT_PGVW AS
    (
        SELECT STATISTICS_DATE
              ,PAGEVIEWS       AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_PGVW_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAGEVIEWS       AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PGVW_CNT END) AS PGVW_CNT_01  /* 01월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PGVW_CNT END) AS PGVW_CNT_02  /* 02월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PGVW_CNT END) AS PGVW_CNT_03  /* 03월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PGVW_CNT END) AS PGVW_CNT_04  /* 04월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PGVW_CNT END) AS PGVW_CNT_05  /* 05월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PGVW_CNT END) AS PGVW_CNT_06  /* 06월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PGVW_CNT END) AS PGVW_CNT_07  /* 07월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PGVW_CNT END) AS PGVW_CNT_08  /* 08월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PGVW_CNT END) AS PGVW_CNT_09  /* 09월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PGVW_CNT END) AS PGVW_CNT_10  /* 10월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PGVW_CNT END) AS PGVW_CNT_11  /* 11월 페이지뷰 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PGVW_CNT END) AS PGVW_CNT_12  /* 12월 페이지뷰 수 */
          FROM WT_PGVW A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PGVW_CNT END) AS PGVW_CNT_01  /* 01월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PGVW_CNT END) AS PGVW_CNT_02  /* 02월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PGVW_CNT END) AS PGVW_CNT_03  /* 03월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PGVW_CNT END) AS PGVW_CNT_04  /* 04월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PGVW_CNT END) AS PGVW_CNT_05  /* 05월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PGVW_CNT END) AS PGVW_CNT_06  /* 06월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PGVW_CNT END) AS PGVW_CNT_07  /* 07월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PGVW_CNT END) AS PGVW_CNT_08  /* 08월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PGVW_CNT END) AS PGVW_CNT_09  /* 09월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PGVW_CNT END) AS PGVW_CNT_10  /* 10월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PGVW_CNT END) AS PGVW_CNT_11  /* 11월 페이지뷰 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PGVW_CNT END) AS PGVW_CNT_12  /* 12월 페이지뷰 수 - YoY */
          FROM WT_PGVW_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_01
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_01
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_02
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_02
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_03
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_03
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_04
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_04
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_05
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_05
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_06
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_06
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_07
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_07
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_08
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_08
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_09
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_09
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_10
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_10
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_11
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_11
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_12
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_12
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_01   /* 01월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_02   /* 02월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_03   /* 03월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_04   /* 04월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_05   /* 05월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_06   /* 06월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_07   /* 07월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_08   /* 08월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_09   /* 09월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_10   /* 10월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_11   /* 11월 페이지뷰 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PGVW_CNT_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PGVW_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PGVW_CNT_12   /* 12월 페이지뷰 */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

7. 제품별 Page View (PV)
    * 기간 선택에 따른 제품별 Page View (PV) 디스플레이, 주 smoothing은 7일, 월 smoothing은 30일 이동평균     
    * 채널 전제 페이지 뷰도 같이 디스플레이

/* 7. 제품별 Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS   AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
     UNION ALL
        SELECT 9999999999999   AS PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS   AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(PGVW_CNT) AS PGVW_CNT
          FROM WT_PGVW A
      GROUP BY PRODUCT_ID
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
               ) AS SORT_KEY
              ,PRODUCT_ID AS L_LGND_ID
              ,CASE
                 WHEN PRODUCT_ID = 9999999999999 THEN '전체 페이지뷰'
                 ELSE DASH_RAW.SF_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,PGVW_CNT        AS Y_VAL  /* 페이지뷰 수 */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT
;

8. 제품별 페이지 뷰 데이터 뷰어 (Top 5)
    * 전년도/당해 연도 각각 등수, 제품명, 페이지뷰, 페이지뷰 비중 디스플레이 (비중 = 제품별 Page View (PV) / 채널 전제 페이지뷰) 
    * 중국 매출 대쉬보드 -> Tmall 글로벌 -> 매출 -> 제품별 매출 정보 데이터 뷰어랑 동일한 형태
        ex) 현재 23년 3월 28일이면 전년 동기는 22년 1월 1일 ~ 22년 3월 28일

/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_PGVW_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'     AS RANK_TYPE  /* 금년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE PGVW_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY' AS RANK_TYPE  /* 전년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE PGVW_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.PGVW_RANK                                                  /* 순위               */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명        */
              ,C.PGVW_CNT                                  AS PGVW_CNT_YOY  /* 전년 페이지뷰 건수 */
              ,C.PGVW_CNT / Y.PGVW_CNT * 100               AS PGVW_RATE_YOY /* 전년 페이지뷰 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명        */
              ,B.PGVW_CNT                                  AS PGVW_CNT      /* 금년 페이지뷰 건수 */
              ,B.PGVW_CNT / T.PGVW_CNT * 100               AS PGVW_RATE     /* 금년 페이지뷰 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.PGVW_RANK = B.PGVW_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.PGVW_RANK = C.PGVW_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT PGVW_RANK                                                                                    /* 순위               */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID        */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT_YOY   /* 전년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE_YOY  /* 전년 페이지뷰 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID        */
          ,PROD_NM                                                                                      /* 금년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT       /* 금년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE      /* 금년 페이지뷰 비중 */
      FROM WT_BASE
  ORDER BY PGVW_RANK
;

/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년 동월 대비 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH        AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
              ,FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
      GROUP BY PRODUCT_ID
    ), WT_PGVW_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 건수 */
          FROM WT_PGVW A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 건수 */
          FROM WT_PGVW_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위      */
              ,PGVW_RANK   AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT    AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE PGVW_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위      */
              ,PGVW_RANK   AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT    AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE PGVW_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.PGVW_RANK                                                   /* 순위              */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명        */
              ,C.PGVW_CNT                                  AS PGVW_CNT_YOY  /* 전년 페이지뷰 건수 */
              ,C.PGVW_CNT / Y.PGVW_CNT * 100               AS PGVW_RATE_YOY /* 전년 페이지뷰 비중 */

              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명        */
              ,B.PGVW_CNT                                  AS PGVW_CNT      /* 금년 페이지뷰 건수 */
              ,B.PGVW_CNT / T.PGVW_CNT * 100               AS PGVW_RATE     /* 금년 페이지뷰 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.PGVW_RANK = B.PGVW_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.PGVW_RANK = C.PGVW_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT PGVW_RANK                                                                                    /* 순위               */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID        */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT_YOY   /* 전년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE_YOY  /* 전년 페이지뷰 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID        */
          ,PROD_NM                                                                                      /* 금년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT       /* 금년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE      /* 금년 페이지뷰 비중 */
      FROM WT_BASE
  ORDER BY PGVW_RANK
;

/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 월별 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_PGVW AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,PRODUCT_ID
              ,SUM(PRODUCT_VIEWS) AS PGVW_CNT   /* 페이지뷰 건수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT  /* 페이지뷰 건수 */
          FROM WT_PGVW A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND PGVW_RANK <= 5
    )
    SELECT A.PGVW_RANK                                                      /* 순위        */
          ,COALESCE(CAST(RANK_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01  /* 01월 제품ID */
          ,COALESCE(CAST(RANK_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02  /* 02월 제품ID */
          ,COALESCE(CAST(RANK_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03  /* 03월 제품ID */
          ,COALESCE(CAST(RANK_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04  /* 04월 제품ID */
          ,COALESCE(CAST(RANK_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05  /* 05월 제품ID */
          ,COALESCE(CAST(RANK_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06  /* 06월 제품ID */
          ,COALESCE(CAST(RANK_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07  /* 07월 제품ID */
          ,COALESCE(CAST(RANK_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08  /* 08월 제품ID */
          ,COALESCE(CAST(RANK_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09  /* 09월 제품ID */
          ,COALESCE(CAST(RANK_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10  /* 10월 제품ID */
          ,COALESCE(CAST(RANK_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11  /* 11월 제품ID */
          ,COALESCE(CAST(RANK_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12  /* 12월 제품ID */

          ,COALESCE(CAST(RANK_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01  /* 01월 제품명 */
          ,COALESCE(CAST(RANK_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02  /* 02월 제품명 */
          ,COALESCE(CAST(RANK_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03  /* 03월 제품명 */
          ,COALESCE(CAST(RANK_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04  /* 04월 제품명 */
          ,COALESCE(CAST(RANK_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05  /* 05월 제품명 */
          ,COALESCE(CAST(RANK_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06  /* 06월 제품명 */
          ,COALESCE(CAST(RANK_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07  /* 07월 제품명 */
          ,COALESCE(CAST(RANK_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08  /* 08월 제품명 */
          ,COALESCE(CAST(RANK_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09  /* 09월 제품명 */
          ,COALESCE(CAST(RANK_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10  /* 10월 제품명 */
          ,COALESCE(CAST(RANK_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11  /* 11월 제품명 */
          ,COALESCE(CAST(RANK_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12  /* 12월 제품명 */

          ,CAST(RANK_01.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_01 /* 01월 페이지뷰 건수 */
          ,CAST(RANK_02.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_02 /* 02월 페이지뷰 건수 */
          ,CAST(RANK_03.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_03 /* 03월 페이지뷰 건수 */
          ,CAST(RANK_04.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_04 /* 04월 페이지뷰 건수 */
          ,CAST(RANK_05.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_05 /* 05월 페이지뷰 건수 */
          ,CAST(RANK_06.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_06 /* 06월 페이지뷰 건수 */
          ,CAST(RANK_07.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_07 /* 07월 페이지뷰 건수 */
          ,CAST(RANK_08.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_08 /* 08월 페이지뷰 건수 */
          ,CAST(RANK_09.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_09 /* 09월 페이지뷰 건수 */
          ,CAST(RANK_10.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_10 /* 10월 페이지뷰 건수 */
          ,CAST(RANK_11.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_11 /* 11월 페이지뷰 건수 */
          ,CAST(RANK_12.PGVW_CNT AS DECIMAL(20,0))           AS PGVW_CNT_12 /* 12월 페이지뷰 건수 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.PGVW_RANK = RANK_01.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.PGVW_RANK = RANK_02.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.PGVW_RANK = RANK_03.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.PGVW_RANK = RANK_04.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.PGVW_RANK = RANK_05.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.PGVW_RANK = RANK_06.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.PGVW_RANK = RANK_07.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.PGVW_RANK = RANK_08.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.PGVW_RANK = RANK_09.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.PGVW_RANK = RANK_10.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.PGVW_RANK = RANK_11.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.PGVW_RANK = RANK_12.PGVW_RANK)
  ORDER BY A.PGVW_RANK
;

9. 체널 Unique Visitor (UV) 당 Page View (PV)
    * 기간 선택 후 날짜에 따른 체널 전제 (예: dgt) Unique Visitor (UV) 당 Page View (PV) 디스플레이, 주 smoothing은 7일, 월 smoothing은 30일 이동평균 (Unique Visitor (UV) 당 Page View (PV)= 페이지 류/ 방문자 수)

/* 9. 체널 Unique Visitor (UV) 당 Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PGVW AS 
    (
        SELECT STATISTICS_DATE                          AS X_DT
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS) AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,PGVW_CNT
          FROM WT_PGVW
    )
    SELECT X_DT
          ,CAST(PGVW_CNT AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT
;

10. Unique Visitor (UV) 당 Page View (PV) 추이 분석
    * Unique Visitor (UV) 당 Page View (PV) 월별로 계산하여 디스플레이 (월 페이지 뷰/월 방문자 수)
    * YOY는 올해수치 / 작년수치 - 1
    * MoM은 이번달 수치 / 전달 수치 - 1 

/* 10. Unique Visitor (UV) 당 Page View (PV) 추이 분석 - 표 SQL */
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
    ), WT_PGVW AS
    (
        SELECT STATISTICS_DATE
              ,PAGEVIEWS          AS PGVW_CNT
              ,NUMBER_OF_VISITORS AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_PGVW_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAGEVIEWS          AS PGVW_CNT
              ,NUMBER_OF_VISITORS AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS PGVW_CNT_01  /* 01월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS PGVW_CNT_02  /* 02월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS PGVW_CNT_03  /* 03월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS PGVW_CNT_04  /* 04월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS PGVW_CNT_05  /* 05월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS PGVW_CNT_06  /* 06월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS PGVW_CNT_07  /* 07월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS PGVW_CNT_08  /* 08월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS PGVW_CNT_09  /* 09월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS PGVW_CNT_10  /* 10월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS PGVW_CNT_11  /* 11월 Unique Visitor (UV) 당 Page View (PV) 수 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS PGVW_CNT_12  /* 12월 Unique Visitor (UV) 당 Page View (PV) 수 */
          FROM WT_PGVW A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS PGVW_CNT_01  /* 01월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS PGVW_CNT_02  /* 02월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS PGVW_CNT_03  /* 03월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS PGVW_CNT_04  /* 04월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS PGVW_CNT_05  /* 05월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS PGVW_CNT_06  /* 06월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS PGVW_CNT_07  /* 07월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS PGVW_CNT_08  /* 08월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS PGVW_CNT_09  /* 09월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS PGVW_CNT_10  /* 10월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS PGVW_CNT_11  /* 11월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PGVW_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS PGVW_CNT_12  /* 12월 Unique Visitor (UV) 당 Page View (PV) 수 - YoY */
          FROM WT_PGVW_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_01
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_01
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_02
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_02
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_03
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_03
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_04
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_04
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_05
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_05
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_06
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_06
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_07
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_07
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_08
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_08
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_09
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_09
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_10
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_10
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_11
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_11
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PGVW_CNT_12
                  WHEN A.SORT_KEY = 3
                  THEN ((LAG(PGVW_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) -1) * 100
                  WHEN A.SORT_KEY = 4
                  THEN ((LAG(PGVW_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) / COALESCE(LAG(PGVW_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) -1) * 100
               END AS PGVW_CNT_12
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(PGVW_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_01   /* 01월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_02   /* 02월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_03   /* 03월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_04   /* 04월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_05   /* 05월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_06   /* 06월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_07   /* 07월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_08   /* 08월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_09   /* 09월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_10   /* 10월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_11   /* 11월 Unique Visitor (UV) 당 Page View (PV) */
          ,TO_CHAR(CAST(PGVW_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS PGVW_CNT_12   /* 12월 Unique Visitor (UV) 당 Page View (PV) */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

11. 제품별 Unique Visitor (UV) 당 Page View (PV)
    * 기간 선택에 따른 제품별 방문자당 페이지 뷰 디스플레이, 주 smoothing은 7일, 월 smoothing은 30일 이동평균
    * 전체 채널의 방문자당 페이지 뷰 포함

/* 11. 제품별 Unique Visitor (UV) 당 Page View (PV) - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS      AS PGVW_CNT
              ,NUMBER_OF_VISITORS AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
     UNION ALL
        SELECT 9999999999999      AS PRODUCT_ID
              ,STATISTICS_DATE
              ,PRODUCT_VIEWS      AS PGVW_CNT
              ,NUMBER_OF_VISITORS AS VIST_CNT
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CASE WHEN SUM(VIST_CNT) = 0 THEN 0 ELSE SUM(PGVW_CNT) / SUM(VIST_CNT) END AS PGVW_CNT
          FROM WT_PGVW A
      GROUP BY PRODUCT_ID
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
               ) AS SORT_KEY
              ,PRODUCT_ID AS L_LGND_ID
              ,CASE
                 WHEN PRODUCT_ID = 9999999999999 THEN '전체 페이지뷰'
                 ELSE DASH_RAW.SF_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,PGVW_CNT        AS Y_VAL  /* Unique Visitor (UV) 당 Page View (PV) 수 */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,2)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT
;

12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품
    * 전년도/당해 연도 각각 등수, 제품명, Unique Visitor (UV) 당 Page View (PV) 디스플레이 (여기는 비중 없음!)
    * 중국 매출 대쉬보드 -> Tmall 글로벌 -> 매출 -> 제품별 매출 정보 데이터 뷰어랑 동일한 형태
        ex) 현재 23년 3월 28일이면 전년 동기는 22년 1월 1일 ~ 22년 3월 28일

/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년도 동기 누적 대비 누적 방문자당 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_TOTL AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_PGVW_YOY AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'     AS RANK_TYPE  /* 금년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE PGVW_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY' AS RANK_TYPE  /* 전년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE PGVW_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.PGVW_RANK                                                  /* 순위               */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명        */
              ,C.PGVW_CNT                                  AS PGVW_CNT_YOY  /* 전년 페이지뷰 건수 */
              ,C.PGVW_CNT / Y.PGVW_CNT * 100               AS PGVW_RATE_YOY /* 전년 페이지뷰 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명        */
              ,B.PGVW_CNT                                  AS PGVW_CNT      /* 금년 페이지뷰 건수 */
              ,B.PGVW_CNT / T.PGVW_CNT * 100               AS PGVW_RATE     /* 금년 페이지뷰 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.PGVW_RANK = B.PGVW_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.PGVW_RANK = C.PGVW_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT PGVW_RANK                                                                                    /* 순위                         */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID                  */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명                  */
          ,TO_CHAR(CAST(PGVW_CNT_YOY  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' ) AS PGVW_CNT_YOY   /* 전년 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,TO_CHAR(CAST(PGVW_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE_YOY  /* 전년 Unique Visitor (UV) 당 Page View (PV) 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID                  */
          ,PROD_NM                                                                                      /* 금년 제품명                  */
          ,TO_CHAR(CAST(PGVW_CNT      AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' ) AS PGVW_CNT       /* 금년 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,TO_CHAR(CAST(PGVW_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE      /* 금년 Unique Visitor (UV) 당 Page View (PV) 비중 */
      FROM WT_BASE
  ORDER BY PGVW_RANK
;

/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 전년 동월 대비 방문자당 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH        AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
              ,FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_TOTL AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
      GROUP BY PRODUCT_ID
    ), WT_PGVW_YOY AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 건수 */
          FROM WT_PGVW A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 건수 */
          FROM WT_PGVW_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위      */
              ,PGVW_RANK   AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT    AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE PGVW_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위      */
              ,PGVW_RANK   AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT    AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE PGVW_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.PGVW_RANK                                                  /* 순위               */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명        */
              ,C.PGVW_CNT                                  AS PGVW_CNT_YOY  /* 전년 페이지뷰 건수 */
              ,C.PGVW_CNT / Y.PGVW_CNT * 100               AS PGVW_RATE_YOY /* 전년 페이지뷰 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID        */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명        */
              ,B.PGVW_CNT                                  AS PGVW_CNT      /* 금년 페이지뷰 건수 */
              ,B.PGVW_CNT / T.PGVW_CNT * 100               AS PGVW_RATE     /* 금년 페이지뷰 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.PGVW_RANK = B.PGVW_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.PGVW_RANK = C.PGVW_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT PGVW_RANK                                                                                    /* 순위                         */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID                  */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명                  */
          ,TO_CHAR(CAST(PGVW_CNT_YOY  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' ) AS PGVW_CNT_YOY   /* 전년 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,TO_CHAR(CAST(PGVW_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE_YOY  /* 전년 Unique Visitor (UV) 당 Page View (PV) 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID                  */
          ,PROD_NM                                                                                      /* 금년 제품명                  */
          ,TO_CHAR(CAST(PGVW_CNT      AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' ) AS PGVW_CNT       /* 금년 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,TO_CHAR(CAST(PGVW_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE      /* 금년 Unique Visitor (UV) 당 Page View (PV) 비중 */
      FROM WT_BASE
  ORDER BY PGVW_RANK
;

/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 월별 방문자당 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_PGVW AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')  AS RANK_MNTH
              ,PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT  /* 페이지뷰 건수 */
          FROM WT_PGVW A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                         AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                         AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                          AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND PGVW_RANK <= 5
    )
    SELECT A.PGVW_RANK                                                      /* 순위        */
          ,COALESCE(CAST(RANK_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01  /* 01월 제품ID */
          ,COALESCE(CAST(RANK_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02  /* 02월 제품ID */
          ,COALESCE(CAST(RANK_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03  /* 03월 제품ID */
          ,COALESCE(CAST(RANK_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04  /* 04월 제품ID */
          ,COALESCE(CAST(RANK_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05  /* 05월 제품ID */
          ,COALESCE(CAST(RANK_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06  /* 06월 제품ID */
          ,COALESCE(CAST(RANK_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07  /* 07월 제품ID */
          ,COALESCE(CAST(RANK_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08  /* 08월 제품ID */
          ,COALESCE(CAST(RANK_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09  /* 09월 제품ID */
          ,COALESCE(CAST(RANK_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10  /* 10월 제품ID */
          ,COALESCE(CAST(RANK_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11  /* 11월 제품ID */
          ,COALESCE(CAST(RANK_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12  /* 12월 제품ID */

          ,COALESCE(CAST(RANK_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01  /* 01월 제품명 */
          ,COALESCE(CAST(RANK_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02  /* 02월 제품명 */
          ,COALESCE(CAST(RANK_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03  /* 03월 제품명 */
          ,COALESCE(CAST(RANK_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04  /* 04월 제품명 */
          ,COALESCE(CAST(RANK_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05  /* 05월 제품명 */
          ,COALESCE(CAST(RANK_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06  /* 06월 제품명 */
          ,COALESCE(CAST(RANK_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07  /* 07월 제품명 */
          ,COALESCE(CAST(RANK_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08  /* 08월 제품명 */
          ,COALESCE(CAST(RANK_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09  /* 09월 제품명 */
          ,COALESCE(CAST(RANK_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10  /* 10월 제품명 */
          ,COALESCE(CAST(RANK_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11  /* 11월 제품명 */
          ,COALESCE(CAST(RANK_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12  /* 12월 제품명 */

          ,CAST(RANK_01.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_01 /* 01월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_02.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_02 /* 02월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_03.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_03 /* 03월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_04.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_04 /* 04월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_05.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_05 /* 05월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_06.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_06 /* 06월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_07.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_07 /* 07월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_08.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_08 /* 08월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_09.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_09 /* 09월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_10.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_10 /* 10월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_11.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_11 /* 11월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_12.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_12 /* 12월 Unique Visitor (UV) 당 Page View (PV) 건수 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.PGVW_RANK = RANK_01.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.PGVW_RANK = RANK_02.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.PGVW_RANK = RANK_03.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.PGVW_RANK = RANK_04.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.PGVW_RANK = RANK_05.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.PGVW_RANK = RANK_06.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.PGVW_RANK = RANK_07.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.PGVW_RANK = RANK_08.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.PGVW_RANK = RANK_09.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.PGVW_RANK = RANK_10.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.PGVW_RANK = RANK_11.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.PGVW_RANK = RANK_12.PGVW_RANK)
  ORDER BY A.PGVW_RANK
;

13. 채널 퍼널분석
    * 기간 선택 후 해당 기간에 대한 퍼널자트 디스플레이
    * 들어가는 변수 (각 단계)들은 위에서부터 방문, 주문, 구매, 환불 순

/* 13. 채널 퍼널분석 - 퍼널 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'VIST'  AS LGND_ID
              ,'방문'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'ORDR'  AS LGND_ID
              ,'주문'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'REFD'  AS LGND_ID
              ,'환불'  AS LGND_NM
    ), WT_DATA AS 
    (
        SELECT SUM(NUMBER_OF_VISITORS)                              AS VIST_CNT  /* 방문 */
              ,SUM(NUMBER_OF_BUYERS_WHO_PLACE_AN_ORDER)             AS ORDR_CNT  /* 주문 */
              ,SUM(NUMBER_OF_PAID_BUYERS)                           AS PAID_CNT  /* 구매 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT) / SUM(CUSTOMER_PRICE)  AS REFD_CNT  /* 환불 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE 
                 WHEN LGND_ID = 'VIST' THEN VIST_CNT  /* 방문 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT  /* 환불 */
               END AS STEP_CNT
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,LGND_ID
          ,LGND_NM
          ,CAST(STEP_CNT AS DECIMAL(20,0))                              AS STEP_CNT
          ,CAST(STEP_CNT / SUM(STEP_CNT) OVER() * 100 AS DECIMAL(20,2)) AS STEP_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY
;


14. 채널 전환율 분석
    * 퍼널자트 우측에는 각 단계별로 몇 명이 해당하는지를 디스플레이
    * 단계 별 전환을 = 다음단계 / 전 단계 (ex : 주문자 수 / 방문자 수)
    * 구매전환율 = 구매자 수 / 방문자 수

/* 14. 채널 전환율 분석 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'VIST'  AS LGND_ID
              ,'방문'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'ORDR'  AS LGND_ID
              ,'주문'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'REFD'  AS LGND_ID
              ,'환불'  AS LGND_NM
    ), WT_DATA AS 
    (
        SELECT SUM(NUMBER_OF_VISITORS)                              AS VIST_CNT  /* 방문 */
              ,SUM(NUMBER_OF_BUYERS_WHO_PLACE_AN_ORDER)             AS ORDR_CNT  /* 주문 */
              ,SUM(NUMBER_OF_PAID_BUYERS)                           AS PAID_CNT  /* 구매 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT) / SUM(CUSTOMER_PRICE)  AS REFD_CNT  /* 환불 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE 
                 WHEN LGND_ID = 'VIST' THEN VIST_CNT  /* 방문 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT  /* 환불 */
               END AS STEP_CNT
              ,CASE
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT / VIST_CNT * 100  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT / ORDR_CNT * 100  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT / PAID_CNT * 100  /* 환불 */
               END AS STEP_RATE
              ,CASE
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT / VIST_CNT * 100  /* 구매 전환율 */
               END AS ORDR_RATE
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,LGND_ID
          ,LGND_NM                                                                              /* 단계명        */
          ,TO_CHAR(CAST(STEP_CNT  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS STEP_CNT   /* 단계별 인원수 */
          ,TO_CHAR(CAST(STEP_RATE AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS STEP_RATE  /* 단계별 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE  /* 구매 전환율   */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

15. 당해 연도 채널 구매전환율
    * 월별 구매전환율 계산 후 디스플레이 (월 구매전환율 = 월별 주문자 수 / 월별 방문자 수) 
    * YOY = 올해 수치 - 작년수치 (%p)
    * MoM = 이 번달 수치 -저 번달 수치 (%p)

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
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT  /* 방문 */
              ,NUMBER_OF_PAID_BUYERS  AS PAID_CNT  /* 구매 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_ORDR_YOY AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT  /* 방문 */
              ,NUMBER_OF_PAID_BUYERS  AS PAID_CNT  /* 구매 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) * 100 AS ORDR_RATE_01  /* 01월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) * 100 AS ORDR_RATE_02  /* 02월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) * 100 AS ORDR_RATE_03  /* 03월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) * 100 AS ORDR_RATE_04  /* 04월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) * 100 AS ORDR_RATE_05  /* 05월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) * 100 AS ORDR_RATE_06  /* 06월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) * 100 AS ORDR_RATE_07  /* 07월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) * 100 AS ORDR_RATE_08  /* 08월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) * 100 AS ORDR_RATE_09  /* 09월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) * 100 AS ORDR_RATE_10  /* 10월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) * 100 AS ORDR_RATE_11  /* 11월 구매 전환율 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) * 100 AS ORDR_RATE_12  /* 12월 구매 전환율 */
          FROM WT_ORDR A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) * 100 AS ORDR_RATE_01  /* 01월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) * 100 AS ORDR_RATE_02  /* 02월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) * 100 AS ORDR_RATE_03  /* 03월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) * 100 AS ORDR_RATE_04  /* 04월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) * 100 AS ORDR_RATE_05  /* 05월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) * 100 AS ORDR_RATE_06  /* 06월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) * 100 AS ORDR_RATE_07  /* 07월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) * 100 AS ORDR_RATE_08  /* 08월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) * 100 AS ORDR_RATE_09  /* 09월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) * 100 AS ORDR_RATE_10  /* 10월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) * 100 AS ORDR_RATE_11  /* 11월 구매 전환율 - YoY */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN PAID_CNT END) / SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) * 100 AS ORDR_RATE_12  /* 12월 구매 전환율 - YoY */
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
;

16. 제품벌 Funnel 분석
    * 제품(총 3개까지 선택가능) 기간 선택 후 퍼널그래프가 최대 3개 나와서 비교할 수 있도록 해야함. 들어가는 변수들은 방문, 주문, 구매, 환불 순으로 들어감

/* 16. 제품벌 Funnel 분석 - 퍼널 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,:TO_DT AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'VIST'  AS LGND_ID
              ,'방문'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'ORDR'  AS LGND_ID
              ,'주문'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'REFD'  AS LGND_ID
              ,'환불'  AS LGND_NM
    ), WT_DATA AS 
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)                                                                                          AS VIST_CNT  /* 방문 */
              ,SUM(NUMBER_OF_BUYERS_WHO_PLACE_AN_ORDER)                                                                         AS ORDR_CNT  /* 주문 */
              ,SUM(NUMBER_OF_PAID_BUYERS)                                                                                       AS PAID_CNT  /* 구매 */
              ,CASE WHEN SUM(CUSTOMER_PRICE) = 0 THEN 0 ELSE SUM(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT) / SUM(CUSTOMER_PRICE) END AS REFD_CNT  /* 환불 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
      GROUP BY PRODUCT_ID
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = B.PRODUCT_ID            
               ) AS SORT_KEY_PROD
              ,PRODUCT_ID                        AS PROD_ID
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID) AS PROD_NM
              ,SORT_KEY AS LGND_SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE 
                 WHEN LGND_ID = 'VIST' THEN VIST_CNT  /* 방문 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT  /* 환불 */
               END AS STEP_CNT
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY_PROD
          ,LGND_SORT_KEY
          ,PROD_ID
          ,PROD_NM
          ,LGND_ID
          ,LGND_NM
          ,CAST(STEP_CNT AS DECIMAL(20,0))                              AS STEP_CNT
          ,CAST(STEP_CNT / SUM(STEP_CNT) OVER() * 100 AS DECIMAL(20,2)) AS STEP_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY_PROD
          ,LGND_SORT_KEY
;


17. 제품별 구매 전환율 Top 5

/* 17. 제품별 구매 전환율 Top 5 - 전년도 동기 누적 대비 누적 구매 전환율 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS ORDR_RANK
     UNION ALL
        SELECT 2 AS ORDR_RANK
     UNION ALL
        SELECT 3 AS ORDR_RANK
     UNION ALL
        SELECT 4 AS ORDR_RANK
     UNION ALL
        SELECT 5 AS ORDR_RANK
    ), WT_TOTL AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_ORDR AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_ORDR_YOY AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'     AS RANK_TYPE  /* 금년순위         */
              ,ORDR_RANK  AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL   AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE ORDR_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY' AS RANK_TYPE  /* 전년순위         */
              ,ORDR_RANK  AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL   AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE ORDR_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.ORDR_RANK                                                  /* 순위                  */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID           */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명           */
              ,C.ORDR_VAL                                  AS ORDR_VAL_YOY  /* 전년 구매 전환율      */
              ,C.ORDR_VAL - Y.ORDR_VAL                     AS ORDR_RATE_YOY /* 전년 구매 전환율 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID           */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명           */
              ,B.ORDR_VAL                                  AS ORDR_VAL      /* 금년 구매 전환율      */
              ,B.ORDR_VAL - T.ORDR_VAL                     AS ORDR_RATE     /* 금년 구매 전환율 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.ORDR_RANK = B.ORDR_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.ORDR_RANK = C.ORDR_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT ORDR_RANK                                                                                    /* 순위                  */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID           */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL_YOY  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL_YOY   /* 전년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_YOY  /* 전년 구매 전환율 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID           */
          ,PROD_NM                                                                                      /* 금년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL      AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL       /* 금년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE      /* 금년 구매 전환율 비중 */
      FROM WT_BASE
  ORDER BY ORDR_RANK
;

/* 17. 제품별 구매 전환율 Top 5 - 전년 동월 대비 구매 전환율 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH        AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
              ,FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS ORDR_RANK
     UNION ALL
        SELECT 2 AS ORDR_RANK
     UNION ALL
        SELECT 3 AS ORDR_RANK
     UNION ALL
        SELECT 4 AS ORDR_RANK
     UNION ALL
        SELECT 5 AS ORDR_RANK
    ), WT_TOTL AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_ORDR AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
      GROUP BY PRODUCT_ID
    ), WT_ORDR_YOY AS
    (
        SELECT PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위      */
              ,ORDR_RANK   AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL    AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE ORDR_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위      */
              ,ORDR_RANK   AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL    AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE ORDR_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.ORDR_RANK                                                  /* 순위                  */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID           */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_YOY   /* 전년 제품명           */
              ,C.ORDR_VAL                                  AS ORDR_VAL_YOY  /* 전년 구매 전환율      */
              ,C.ORDR_VAL - Y.ORDR_VAL                     AS ORDR_RATE_YOY /* 전년 구매 전환율 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID           */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM       /* 금년 제품명           */
              ,B.ORDR_VAL                                  AS ORDR_VAL      /* 금년 구매 전환율      */
              ,B.ORDR_VAL - T.ORDR_VAL                     AS ORDR_RATE     /* 금년 구매 전환율 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.ORDR_RANK = B.ORDR_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.ORDR_RANK = C.ORDR_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT ORDR_RANK                                                                                    /* 순위                  */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID           */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL_YOY  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL_YOY   /* 전년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_YOY  /* 전년 구매 전환율 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID           */
          ,PROD_NM                                                                                      /* 금년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL      AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL       /* 금년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE      /* 금년 구매 전환율 비중 */
      FROM WT_BASE
  ORDER BY ORDR_RANK
;

/* 17. 제품별 구매 전환율 Top 5 - 월별 구매 전환율 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS ORDR_RANK
     UNION ALL
        SELECT 2 AS ORDR_RANK
     UNION ALL
        SELECT 3 AS ORDR_RANK
     UNION ALL
        SELECT 4 AS ORDR_RANK
     UNION ALL
        SELECT 5 AS ORDR_RANK
    ), WT_ORDR AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')  AS RANK_MNTH
              ,PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL  /* 구매 전환율 */
          FROM WT_ORDR A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                         AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                         AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                          AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND ORDR_RANK <= 5
    )
    SELECT A.ORDR_RANK                                                      /* 순위        */
          ,COALESCE(CAST(RANK_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01  /* 01월 제품ID */
          ,COALESCE(CAST(RANK_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02  /* 02월 제품ID */
          ,COALESCE(CAST(RANK_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03  /* 03월 제품ID */
          ,COALESCE(CAST(RANK_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04  /* 04월 제품ID */
          ,COALESCE(CAST(RANK_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05  /* 05월 제품ID */
          ,COALESCE(CAST(RANK_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06  /* 06월 제품ID */
          ,COALESCE(CAST(RANK_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07  /* 07월 제품ID */
          ,COALESCE(CAST(RANK_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08  /* 08월 제품ID */
          ,COALESCE(CAST(RANK_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09  /* 09월 제품ID */
          ,COALESCE(CAST(RANK_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10  /* 10월 제품ID */
          ,COALESCE(CAST(RANK_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11  /* 11월 제품ID */
          ,COALESCE(CAST(RANK_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12  /* 12월 제품ID */

          ,COALESCE(CAST(RANK_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01  /* 01월 제품명 */
          ,COALESCE(CAST(RANK_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02  /* 02월 제품명 */
          ,COALESCE(CAST(RANK_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03  /* 03월 제품명 */
          ,COALESCE(CAST(RANK_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04  /* 04월 제품명 */
          ,COALESCE(CAST(RANK_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05  /* 05월 제품명 */
          ,COALESCE(CAST(RANK_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06  /* 06월 제품명 */
          ,COALESCE(CAST(RANK_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07  /* 07월 제품명 */
          ,COALESCE(CAST(RANK_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08  /* 08월 제품명 */
          ,COALESCE(CAST(RANK_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09  /* 09월 제품명 */
          ,COALESCE(CAST(RANK_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10  /* 10월 제품명 */
          ,COALESCE(CAST(RANK_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11  /* 11월 제품명 */
          ,COALESCE(CAST(RANK_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12  /* 12월 제품명 */

          ,CAST(RANK_01.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_01 /* 01월 구매 전환율 */
          ,CAST(RANK_02.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_02 /* 02월 구매 전환율 */
          ,CAST(RANK_03.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_03 /* 03월 구매 전환율 */
          ,CAST(RANK_04.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_04 /* 04월 구매 전환율 */
          ,CAST(RANK_05.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_05 /* 05월 구매 전환율 */
          ,CAST(RANK_06.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_06 /* 06월 구매 전환율 */
          ,CAST(RANK_07.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_07 /* 07월 구매 전환율 */
          ,CAST(RANK_08.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_08 /* 08월 구매 전환율 */
          ,CAST(RANK_09.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_09 /* 09월 구매 전환율 */
          ,CAST(RANK_10.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_10 /* 10월 구매 전환율 */
          ,CAST(RANK_11.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_11 /* 11월 구매 전환율 */
          ,CAST(RANK_12.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_12 /* 12월 구매 전환율 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.ORDR_RANK = RANK_01.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.ORDR_RANK = RANK_02.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.ORDR_RANK = RANK_03.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.ORDR_RANK = RANK_04.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.ORDR_RANK = RANK_05.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.ORDR_RANK = RANK_06.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.ORDR_RANK = RANK_07.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.ORDR_RANK = RANK_08.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.ORDR_RANK = RANK_09.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.ORDR_RANK = RANK_10.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.ORDR_RANK = RANK_11.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.ORDR_RANK = RANK_12.ORDR_RANK)
  ORDER BY A.ORDR_RANK
;

18. 스토어 Funnel 지표 비교
    * UV, UV,PV, Conversion Rate 스토어 전제 정보를 보여주는 표
        A. 전년도 동기 누적 대비 비교
        B. 전년 동월대비 비교
        C. 당해 연도 월별 비교
        D. 당해 연도 주차별 비교
        총 4개의 표가 들어감
    * 전년동기누적대비 비교는 전년동기와 당해 연도 이번 기의 누적값 비교,
      전년동월 대비 비교는 전년도 동월 기준, 당해 연도 동월 누적을 비교 
      당해 연도 월별 비교는 당해 연도의 1월부터 12월까지의 비교, 
      당해 연도 주차별 비교는 월별 주별 주차별 비교가 되게끔 나열

/* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_VIST_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_KRW
          FROM WT_COPY     A
              ,WT_VIST     B
              ,WT_VIST_YOY C
    )
    SELECT SORT_KEY
          ,ROW_TITL
          ,COL_YOY_RMB
          ,COL_RMB
          ,COL_YOY_KRW
          ,COL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
;

/* 18. 스토어 Funnel 지표 비교 - B. 전년 동월대비 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_VIST_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_KRW
          FROM WT_COPY     A
              ,WT_VIST     B
              ,WT_VIST_YOY C
    )
    SELECT SORT_KEY
          ,ROW_TITL
          ,COL_YOY_RMB
          ,COL_RMB
          ,COL_YOY_KRW
          ,COL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
;

/* 18. 스토어 Funnel 지표 비교 - C. 당해 연도 월별 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT '00'                                                                                                     AS COL_MNTH
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
     UNION ALL
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')                                                             AS COL_MNTH
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_KRW
          FROM WT_COPY      A
              ,WT_VIST      B
    )
    SELECT SORT_KEY
          ,MAX(ROW_TITL  )  AS ROW_TITL    /* 구분                   */
          ,MAX(COL_00_RMB)  AS COL_00_RMB  /* 당해 연도 누적 - 위안화 */
          ,MAX(COL_01_RMB)  AS COL_01_RMB  /* 01월          - 위안화 */
          ,MAX(COL_02_RMB)  AS COL_02_RMB  /* 02월          - 위안화 */
          ,MAX(COL_03_RMB)  AS COL_03_RMB  /* 03월          - 위안화 */
          ,MAX(COL_04_RMB)  AS COL_04_RMB  /* 04월          - 위안화 */
          ,MAX(COL_05_RMB)  AS COL_05_RMB  /* 05월          - 위안화 */
          ,MAX(COL_06_RMB)  AS COL_06_RMB  /* 06월          - 위안화 */
          ,MAX(COL_07_RMB)  AS COL_07_RMB  /* 07월          - 위안화 */
          ,MAX(COL_08_RMB)  AS COL_08_RMB  /* 08월          - 위안화 */
          ,MAX(COL_09_RMB)  AS COL_09_RMB  /* 09월          - 위안화 */
          ,MAX(COL_10_RMB)  AS COL_10_RMB  /* 10월          - 위안화 */
          ,MAX(COL_11_RMB)  AS COL_11_RMB  /* 11월          - 위안화 */
          ,MAX(COL_12_RMB)  AS COL_12_RMB  /* 12월          - 위안화 */
          ,MAX(COL_00_KRW)  AS COL_00_KRW  /* 당해 연도 누적 - 원화   */
          ,MAX(COL_01_KRW)  AS COL_01_KRW  /* 01월          - 원화   */
          ,MAX(COL_02_KRW)  AS COL_02_KRW  /* 02월          - 원화   */
          ,MAX(COL_03_KRW)  AS COL_03_KRW  /* 03월          - 원화   */
          ,MAX(COL_04_KRW)  AS COL_04_KRW  /* 04월          - 원화   */
          ,MAX(COL_05_KRW)  AS COL_05_KRW  /* 05월          - 원화   */
          ,MAX(COL_06_KRW)  AS COL_06_KRW  /* 06월          - 원화   */
          ,MAX(COL_07_KRW)  AS COL_07_KRW  /* 07월          - 원화   */
          ,MAX(COL_08_KRW)  AS COL_08_KRW  /* 08월          - 원화   */
          ,MAX(COL_09_KRW)  AS COL_09_KRW  /* 09월          - 원화   */
          ,MAX(COL_10_KRW)  AS COL_10_KRW  /* 10월          - 원화   */
          ,MAX(COL_11_KRW)  AS COL_11_KRW  /* 11월          - 원화   */
          ,MAX(COL_12_KRW)  AS COL_12_KRW  /* 12월          - 원화   */
     FROM WT_BASE
 GROUP BY SORT_KEY
 ORDER BY SORT_KEY
;

/* 당해 연도 월/주차 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT  /* 기준일의  1월  1일 */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT  /* 기준일의 12월 31일 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_DATE AS
    (
        SELECT GENERATE_SERIES((SELECT CAST(FR_DT AS DATE) FROM WT_WHERE), (SELECT CAST(TO_DT AS DATE) FROM WT_WHERE), INTERVAL '1 WEEK') AS DT 
    )
    SELECT TO_CHAR(A.DT, 'MM')||'월' AS COL_MNTH
          ,TO_CHAR(A.DT, 'WW')||'주' AS COL_WEEK
      FROM WT_DATE A
     WHERE TO_CHAR(A.DT, 'YYYY-MM') = TO_CHAR(DATE_TRUNC('MONTH', A.DT), 'YYYY-MM')
  ORDER BY A.DT 
;

/* 18. 스토어 Funnel 지표 비교 - D. 당해 연도 주차별 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT '00'                                                                                                     AS COL_WEEK
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
     UNION ALL
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'WW')                                                             AS COL_WEEK
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'WW')
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_13_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_14_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_15_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_16_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_17_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_18_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_19_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_20_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_21_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_22_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_23_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_24_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_25_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_26_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_27_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_28_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_29_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_30_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_31_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_32_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_33_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_34_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_35_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_36_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_37_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_38_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_39_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_40_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_41_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_42_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_43_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_44_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_45_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_46_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_47_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_48_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_49_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_50_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_51_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_52_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_53_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_13_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_14_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_15_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_16_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_17_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_18_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_19_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_20_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_21_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_22_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_23_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_24_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_25_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_26_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_27_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_28_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_29_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_30_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_31_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_32_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_33_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_34_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_35_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_36_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_37_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_38_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_39_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_40_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_41_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_42_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_43_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_44_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_45_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_46_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_47_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_48_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_49_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_50_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_51_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_52_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_53_KRW
          FROM WT_COPY      A
              ,WT_VIST      B
    )
    SELECT SORT_KEY
          ,MAX(ROW_TITL  )  AS ROW_TITL    /* 구분                   */
          ,MAX(COL_00_RMB)  AS COL_00_RMB  /* 당해 연도 누적 - 위안화 */
          ,MAX(COL_01_RMB)  AS COL_01_RMB  /* 01주          - 위안화 */
          ,MAX(COL_02_RMB)  AS COL_02_RMB  /* 02주          - 위안화 */
          ,MAX(COL_03_RMB)  AS COL_03_RMB  /* 03주          - 위안화 */
          ,MAX(COL_04_RMB)  AS COL_04_RMB  /* 04주          - 위안화 */
          ,MAX(COL_05_RMB)  AS COL_05_RMB  /* 05주          - 위안화 */
          ,MAX(COL_06_RMB)  AS COL_06_RMB  /* 06주          - 위안화 */
          ,MAX(COL_07_RMB)  AS COL_07_RMB  /* 07주          - 위안화 */
          ,MAX(COL_08_RMB)  AS COL_08_RMB  /* 08주          - 위안화 */
          ,MAX(COL_09_RMB)  AS COL_09_RMB  /* 09주          - 위안화 */
          ,MAX(COL_10_RMB)  AS COL_10_RMB  /* 10주          - 위안화 */
          ,MAX(COL_11_RMB)  AS COL_11_RMB  /* 11주          - 위안화 */
          ,MAX(COL_12_RMB)  AS COL_12_RMB  /* 12주          - 위안화 */
          ,MAX(COL_13_RMB)  AS COL_13_RMB  /* 13주          - 위안화 */
          ,MAX(COL_14_RMB)  AS COL_14_RMB  /* 14주          - 위안화 */
          ,MAX(COL_15_RMB)  AS COL_15_RMB  /* 15주          - 위안화 */
          ,MAX(COL_16_RMB)  AS COL_16_RMB  /* 16주          - 위안화 */
          ,MAX(COL_17_RMB)  AS COL_17_RMB  /* 17주          - 위안화 */
          ,MAX(COL_18_RMB)  AS COL_18_RMB  /* 18주          - 위안화 */
          ,MAX(COL_19_RMB)  AS COL_19_RMB  /* 19주          - 위안화 */
          ,MAX(COL_20_RMB)  AS COL_20_RMB  /* 20주          - 위안화 */
          ,MAX(COL_21_RMB)  AS COL_21_RMB  /* 21주          - 위안화 */
          ,MAX(COL_22_RMB)  AS COL_22_RMB  /* 22주          - 위안화 */
          ,MAX(COL_23_RMB)  AS COL_23_RMB  /* 23주          - 위안화 */
          ,MAX(COL_24_RMB)  AS COL_24_RMB  /* 24주          - 위안화 */
          ,MAX(COL_25_RMB)  AS COL_25_RMB  /* 25주          - 위안화 */
          ,MAX(COL_26_RMB)  AS COL_26_RMB  /* 26주          - 위안화 */
          ,MAX(COL_27_RMB)  AS COL_27_RMB  /* 27주          - 위안화 */
          ,MAX(COL_28_RMB)  AS COL_28_RMB  /* 28주          - 위안화 */
          ,MAX(COL_29_RMB)  AS COL_29_RMB  /* 29주          - 위안화 */
          ,MAX(COL_30_RMB)  AS COL_30_RMB  /* 30주          - 위안화 */
          ,MAX(COL_31_RMB)  AS COL_31_RMB  /* 31주          - 위안화 */
          ,MAX(COL_32_RMB)  AS COL_32_RMB  /* 32주          - 위안화 */
          ,MAX(COL_33_RMB)  AS COL_33_RMB  /* 33주          - 위안화 */
          ,MAX(COL_34_RMB)  AS COL_34_RMB  /* 34주          - 위안화 */
          ,MAX(COL_35_RMB)  AS COL_35_RMB  /* 35주          - 위안화 */
          ,MAX(COL_36_RMB)  AS COL_36_RMB  /* 36주          - 위안화 */
          ,MAX(COL_37_RMB)  AS COL_37_RMB  /* 37주          - 위안화 */
          ,MAX(COL_38_RMB)  AS COL_38_RMB  /* 38주          - 위안화 */
          ,MAX(COL_39_RMB)  AS COL_39_RMB  /* 39주          - 위안화 */
          ,MAX(COL_40_RMB)  AS COL_40_RMB  /* 40주          - 위안화 */
          ,MAX(COL_41_RMB)  AS COL_41_RMB  /* 41주          - 위안화 */
          ,MAX(COL_42_RMB)  AS COL_42_RMB  /* 42주          - 위안화 */
          ,MAX(COL_43_RMB)  AS COL_43_RMB  /* 43주          - 위안화 */
          ,MAX(COL_44_RMB)  AS COL_44_RMB  /* 44주          - 위안화 */
          ,MAX(COL_45_RMB)  AS COL_45_RMB  /* 45주          - 위안화 */
          ,MAX(COL_46_RMB)  AS COL_46_RMB  /* 46주          - 위안화 */
          ,MAX(COL_47_RMB)  AS COL_47_RMB  /* 47주          - 위안화 */
          ,MAX(COL_48_RMB)  AS COL_48_RMB  /* 48주          - 위안화 */
          ,MAX(COL_49_RMB)  AS COL_49_RMB  /* 49주          - 위안화 */
          ,MAX(COL_50_RMB)  AS COL_50_RMB  /* 50주          - 위안화 */
          ,MAX(COL_51_RMB)  AS COL_51_RMB  /* 51주          - 위안화 */
          ,MAX(COL_52_RMB)  AS COL_52_RMB  /* 52주          - 위안화 */
          ,MAX(COL_53_RMB)  AS COL_53_RMB  /* 53주          - 위안화 */
          ,MAX(COL_00_KRW)  AS COL_00_KRW  /* 당해 연도 누적 - 원화   */
          ,MAX(COL_01_KRW)  AS COL_01_KRW  /* 01주          - 원화   */
          ,MAX(COL_02_KRW)  AS COL_02_KRW  /* 02주          - 원화   */
          ,MAX(COL_03_KRW)  AS COL_03_KRW  /* 03주          - 원화   */
          ,MAX(COL_04_KRW)  AS COL_04_KRW  /* 04주          - 원화   */
          ,MAX(COL_05_KRW)  AS COL_05_KRW  /* 05주          - 원화   */
          ,MAX(COL_06_KRW)  AS COL_06_KRW  /* 06주          - 원화   */
          ,MAX(COL_07_KRW)  AS COL_07_KRW  /* 07주          - 원화   */
          ,MAX(COL_08_KRW)  AS COL_08_KRW  /* 08주          - 원화   */
          ,MAX(COL_09_KRW)  AS COL_09_KRW  /* 09주          - 원화   */
          ,MAX(COL_10_KRW)  AS COL_10_KRW  /* 10주          - 원화   */
          ,MAX(COL_11_KRW)  AS COL_11_KRW  /* 11주          - 원화   */
          ,MAX(COL_12_KRW)  AS COL_12_KRW  /* 12주          - 원화   */
          ,MAX(COL_13_KRW)  AS COL_13_KRW  /* 13주          - 원화   */
          ,MAX(COL_14_KRW)  AS COL_14_KRW  /* 14주          - 원화   */
          ,MAX(COL_15_KRW)  AS COL_15_KRW  /* 15주          - 원화   */
          ,MAX(COL_16_KRW)  AS COL_16_KRW  /* 16주          - 원화   */
          ,MAX(COL_17_KRW)  AS COL_17_KRW  /* 17주          - 원화   */
          ,MAX(COL_18_KRW)  AS COL_18_KRW  /* 18주          - 원화   */
          ,MAX(COL_19_KRW)  AS COL_19_KRW  /* 19주          - 원화   */
          ,MAX(COL_20_KRW)  AS COL_20_KRW  /* 20주          - 원화   */
          ,MAX(COL_21_KRW)  AS COL_21_KRW  /* 21주          - 원화   */
          ,MAX(COL_22_KRW)  AS COL_22_KRW  /* 22주          - 원화   */
          ,MAX(COL_23_KRW)  AS COL_23_KRW  /* 23주          - 원화   */
          ,MAX(COL_24_KRW)  AS COL_24_KRW  /* 24주          - 원화   */
          ,MAX(COL_25_KRW)  AS COL_25_KRW  /* 25주          - 원화   */
          ,MAX(COL_26_KRW)  AS COL_26_KRW  /* 26주          - 원화   */
          ,MAX(COL_27_KRW)  AS COL_27_KRW  /* 27주          - 원화   */
          ,MAX(COL_28_KRW)  AS COL_28_KRW  /* 28주          - 원화   */
          ,MAX(COL_29_KRW)  AS COL_29_KRW  /* 29주          - 원화   */
          ,MAX(COL_30_KRW)  AS COL_30_KRW  /* 30주          - 원화   */
          ,MAX(COL_31_KRW)  AS COL_31_KRW  /* 31주          - 원화   */
          ,MAX(COL_32_KRW)  AS COL_32_KRW  /* 32주          - 원화   */
          ,MAX(COL_33_KRW)  AS COL_33_KRW  /* 33주          - 원화   */
          ,MAX(COL_34_KRW)  AS COL_34_KRW  /* 34주          - 원화   */
          ,MAX(COL_35_KRW)  AS COL_35_KRW  /* 35주          - 원화   */
          ,MAX(COL_36_KRW)  AS COL_36_KRW  /* 36주          - 원화   */
          ,MAX(COL_37_KRW)  AS COL_37_KRW  /* 37주          - 원화   */
          ,MAX(COL_38_KRW)  AS COL_38_KRW  /* 38주          - 원화   */
          ,MAX(COL_39_KRW)  AS COL_39_KRW  /* 39주          - 원화   */
          ,MAX(COL_40_KRW)  AS COL_40_KRW  /* 40주          - 원화   */
          ,MAX(COL_41_KRW)  AS COL_41_KRW  /* 41주          - 원화   */
          ,MAX(COL_42_KRW)  AS COL_42_KRW  /* 42주          - 원화   */
          ,MAX(COL_43_KRW)  AS COL_43_KRW  /* 43주          - 원화   */
          ,MAX(COL_44_KRW)  AS COL_44_KRW  /* 44주          - 원화   */
          ,MAX(COL_45_KRW)  AS COL_45_KRW  /* 45주          - 원화   */
          ,MAX(COL_46_KRW)  AS COL_46_KRW  /* 46주          - 원화   */
          ,MAX(COL_47_KRW)  AS COL_47_KRW  /* 47주          - 원화   */
          ,MAX(COL_48_KRW)  AS COL_48_KRW  /* 48주          - 원화   */
          ,MAX(COL_49_KRW)  AS COL_49_KRW  /* 49주          - 원화   */
          ,MAX(COL_50_KRW)  AS COL_50_KRW  /* 50주          - 원화   */
          ,MAX(COL_51_KRW)  AS COL_51_KRW  /* 51주          - 원화   */
          ,MAX(COL_52_KRW)  AS COL_52_KRW  /* 52주          - 원화   */
          ,MAX(COL_53_KRW)  AS COL_53_KRW  /* 53주          - 원화   */
     FROM WT_BASE
 GROUP BY SORT_KEY
 ORDER BY SORT_KEY
;

19. 제품별 Funnel 지표 비교 (당해 연도 주차별)
    * 제품을 최대 3개까지 선택가능하며, 선택한 제품을 하단의 표와 같이 구성하여 주차별 비교를 할 수 있게끔 제공

/* 19. 제품별 Funnel 지표 비교 (당해 연도 주차별) - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '60, 2' */
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT PRODUCT_ID
              ,'00'                                                                                                                AS COL_WEEK
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                             AS VIST_CNT      /* 방문자수            */
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS)         / SUM(NUMBER_OF_VISITORS)       END    AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END    AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PRODUCT_ID
     UNION ALL
        SELECT PRODUCT_ID
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'WW')                                                                        AS COL_WEEK
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                             AS VIST_CNT      /* 방문자수            */
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS)         / SUM(NUMBER_OF_VISITORS)       END    AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100 END    AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PRODUCT_ID
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'WW')
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,PRODUCT_ID
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_13_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_14_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_15_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_16_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_17_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_18_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_19_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_20_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_21_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_22_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_23_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_24_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_25_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_26_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_27_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_28_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_29_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_30_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_31_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_32_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_33_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_34_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_35_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_36_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_37_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_38_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_39_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_40_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_41_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_42_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_43_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_44_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_45_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_46_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_47_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_48_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_49_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_50_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_51_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_52_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_53_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '13' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_13_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '14' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_14_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '15' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_15_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '16' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_16_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '17' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_17_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '18' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_18_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '19' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_19_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '20' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_20_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '21' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_21_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '22' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_22_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '23' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_23_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '24' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_24_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '25' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_25_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '26' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_26_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '27' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_27_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '28' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_28_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '29' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_29_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '30' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_30_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '31' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_31_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '32' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_32_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '33' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_33_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '34' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_34_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '35' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_35_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '36' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_36_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '37' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_37_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '38' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_38_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '39' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_39_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '40' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_40_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '41' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_41_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '42' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_42_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '43' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_43_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '44' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_44_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '45' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_45_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '46' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_46_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '47' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_47_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '48' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_48_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '49' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_49_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '50' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_50_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '51' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_51_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '52' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_52_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_WEEK = '53' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_53_KRW
          FROM WT_COPY      A
              ,WT_VIST      B
    )
    SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
           ) AS SORT_KEY_PROD
          ,PRODUCT_ID                        AS PROD_ID
          ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM
          ,SORT_KEY
          ,MAX(ROW_TITL  )  AS ROW_TITL    /* 구분                   */
          ,MAX(COL_00_RMB)  AS COL_00_RMB  /* 당해 연도 누적 - 위안화 */
          ,MAX(COL_01_RMB)  AS COL_01_RMB  /* 01주          - 위안화 */
          ,MAX(COL_02_RMB)  AS COL_02_RMB  /* 02주          - 위안화 */
          ,MAX(COL_03_RMB)  AS COL_03_RMB  /* 03주          - 위안화 */
          ,MAX(COL_04_RMB)  AS COL_04_RMB  /* 04주          - 위안화 */
          ,MAX(COL_05_RMB)  AS COL_05_RMB  /* 05주          - 위안화 */
          ,MAX(COL_06_RMB)  AS COL_06_RMB  /* 06주          - 위안화 */
          ,MAX(COL_07_RMB)  AS COL_07_RMB  /* 07주          - 위안화 */
          ,MAX(COL_08_RMB)  AS COL_08_RMB  /* 08주          - 위안화 */
          ,MAX(COL_09_RMB)  AS COL_09_RMB  /* 09주          - 위안화 */
          ,MAX(COL_10_RMB)  AS COL_10_RMB  /* 10주          - 위안화 */
          ,MAX(COL_11_RMB)  AS COL_11_RMB  /* 11주          - 위안화 */
          ,MAX(COL_12_RMB)  AS COL_12_RMB  /* 12주          - 위안화 */
          ,MAX(COL_13_RMB)  AS COL_13_RMB  /* 13주          - 위안화 */
          ,MAX(COL_14_RMB)  AS COL_14_RMB  /* 14주          - 위안화 */
          ,MAX(COL_15_RMB)  AS COL_15_RMB  /* 15주          - 위안화 */
          ,MAX(COL_16_RMB)  AS COL_16_RMB  /* 16주          - 위안화 */
          ,MAX(COL_17_RMB)  AS COL_17_RMB  /* 17주          - 위안화 */
          ,MAX(COL_18_RMB)  AS COL_18_RMB  /* 18주          - 위안화 */
          ,MAX(COL_19_RMB)  AS COL_19_RMB  /* 19주          - 위안화 */
          ,MAX(COL_20_RMB)  AS COL_20_RMB  /* 20주          - 위안화 */
          ,MAX(COL_21_RMB)  AS COL_21_RMB  /* 21주          - 위안화 */
          ,MAX(COL_22_RMB)  AS COL_22_RMB  /* 22주          - 위안화 */
          ,MAX(COL_23_RMB)  AS COL_23_RMB  /* 23주          - 위안화 */
          ,MAX(COL_24_RMB)  AS COL_24_RMB  /* 24주          - 위안화 */
          ,MAX(COL_25_RMB)  AS COL_25_RMB  /* 25주          - 위안화 */
          ,MAX(COL_26_RMB)  AS COL_26_RMB  /* 26주          - 위안화 */
          ,MAX(COL_27_RMB)  AS COL_27_RMB  /* 27주          - 위안화 */
          ,MAX(COL_28_RMB)  AS COL_28_RMB  /* 28주          - 위안화 */
          ,MAX(COL_29_RMB)  AS COL_29_RMB  /* 29주          - 위안화 */
          ,MAX(COL_30_RMB)  AS COL_30_RMB  /* 30주          - 위안화 */
          ,MAX(COL_31_RMB)  AS COL_31_RMB  /* 31주          - 위안화 */
          ,MAX(COL_32_RMB)  AS COL_32_RMB  /* 32주          - 위안화 */
          ,MAX(COL_33_RMB)  AS COL_33_RMB  /* 33주          - 위안화 */
          ,MAX(COL_34_RMB)  AS COL_34_RMB  /* 34주          - 위안화 */
          ,MAX(COL_35_RMB)  AS COL_35_RMB  /* 35주          - 위안화 */
          ,MAX(COL_36_RMB)  AS COL_36_RMB  /* 36주          - 위안화 */
          ,MAX(COL_37_RMB)  AS COL_37_RMB  /* 37주          - 위안화 */
          ,MAX(COL_38_RMB)  AS COL_38_RMB  /* 38주          - 위안화 */
          ,MAX(COL_39_RMB)  AS COL_39_RMB  /* 39주          - 위안화 */
          ,MAX(COL_40_RMB)  AS COL_40_RMB  /* 40주          - 위안화 */
          ,MAX(COL_41_RMB)  AS COL_41_RMB  /* 41주          - 위안화 */
          ,MAX(COL_42_RMB)  AS COL_42_RMB  /* 42주          - 위안화 */
          ,MAX(COL_43_RMB)  AS COL_43_RMB  /* 43주          - 위안화 */
          ,MAX(COL_44_RMB)  AS COL_44_RMB  /* 44주          - 위안화 */
          ,MAX(COL_45_RMB)  AS COL_45_RMB  /* 45주          - 위안화 */
          ,MAX(COL_46_RMB)  AS COL_46_RMB  /* 46주          - 위안화 */
          ,MAX(COL_47_RMB)  AS COL_47_RMB  /* 47주          - 위안화 */
          ,MAX(COL_48_RMB)  AS COL_48_RMB  /* 48주          - 위안화 */
          ,MAX(COL_49_RMB)  AS COL_49_RMB  /* 49주          - 위안화 */
          ,MAX(COL_50_RMB)  AS COL_50_RMB  /* 50주          - 위안화 */
          ,MAX(COL_51_RMB)  AS COL_51_RMB  /* 51주          - 위안화 */
          ,MAX(COL_52_RMB)  AS COL_52_RMB  /* 52주          - 위안화 */
          ,MAX(COL_53_RMB)  AS COL_53_RMB  /* 53주          - 위안화 */
          ,MAX(COL_00_KRW)  AS COL_00_KRW  /* 당해 연도 누적 - 원화   */
          ,MAX(COL_01_KRW)  AS COL_01_KRW  /* 01주          - 원화   */
          ,MAX(COL_02_KRW)  AS COL_02_KRW  /* 02주          - 원화   */
          ,MAX(COL_03_KRW)  AS COL_03_KRW  /* 03주          - 원화   */
          ,MAX(COL_04_KRW)  AS COL_04_KRW  /* 04주          - 원화   */
          ,MAX(COL_05_KRW)  AS COL_05_KRW  /* 05주          - 원화   */
          ,MAX(COL_06_KRW)  AS COL_06_KRW  /* 06주          - 원화   */
          ,MAX(COL_07_KRW)  AS COL_07_KRW  /* 07주          - 원화   */
          ,MAX(COL_08_KRW)  AS COL_08_KRW  /* 08주          - 원화   */
          ,MAX(COL_09_KRW)  AS COL_09_KRW  /* 09주          - 원화   */
          ,MAX(COL_10_KRW)  AS COL_10_KRW  /* 10주          - 원화   */
          ,MAX(COL_11_KRW)  AS COL_11_KRW  /* 11주          - 원화   */
          ,MAX(COL_12_KRW)  AS COL_12_KRW  /* 12주          - 원화   */
          ,MAX(COL_13_KRW)  AS COL_13_KRW  /* 13주          - 원화   */
          ,MAX(COL_14_KRW)  AS COL_14_KRW  /* 14주          - 원화   */
          ,MAX(COL_15_KRW)  AS COL_15_KRW  /* 15주          - 원화   */
          ,MAX(COL_16_KRW)  AS COL_16_KRW  /* 16주          - 원화   */
          ,MAX(COL_17_KRW)  AS COL_17_KRW  /* 17주          - 원화   */
          ,MAX(COL_18_KRW)  AS COL_18_KRW  /* 18주          - 원화   */
          ,MAX(COL_19_KRW)  AS COL_19_KRW  /* 19주          - 원화   */
          ,MAX(COL_20_KRW)  AS COL_20_KRW  /* 20주          - 원화   */
          ,MAX(COL_21_KRW)  AS COL_21_KRW  /* 21주          - 원화   */
          ,MAX(COL_22_KRW)  AS COL_22_KRW  /* 22주          - 원화   */
          ,MAX(COL_23_KRW)  AS COL_23_KRW  /* 23주          - 원화   */
          ,MAX(COL_24_KRW)  AS COL_24_KRW  /* 24주          - 원화   */
          ,MAX(COL_25_KRW)  AS COL_25_KRW  /* 25주          - 원화   */
          ,MAX(COL_26_KRW)  AS COL_26_KRW  /* 26주          - 원화   */
          ,MAX(COL_27_KRW)  AS COL_27_KRW  /* 27주          - 원화   */
          ,MAX(COL_28_KRW)  AS COL_28_KRW  /* 28주          - 원화   */
          ,MAX(COL_29_KRW)  AS COL_29_KRW  /* 29주          - 원화   */
          ,MAX(COL_30_KRW)  AS COL_30_KRW  /* 30주          - 원화   */
          ,MAX(COL_31_KRW)  AS COL_31_KRW  /* 31주          - 원화   */
          ,MAX(COL_32_KRW)  AS COL_32_KRW  /* 32주          - 원화   */
          ,MAX(COL_33_KRW)  AS COL_33_KRW  /* 33주          - 원화   */
          ,MAX(COL_34_KRW)  AS COL_34_KRW  /* 34주          - 원화   */
          ,MAX(COL_35_KRW)  AS COL_35_KRW  /* 35주          - 원화   */
          ,MAX(COL_36_KRW)  AS COL_36_KRW  /* 36주          - 원화   */
          ,MAX(COL_37_KRW)  AS COL_37_KRW  /* 37주          - 원화   */
          ,MAX(COL_38_KRW)  AS COL_38_KRW  /* 38주          - 원화   */
          ,MAX(COL_39_KRW)  AS COL_39_KRW  /* 39주          - 원화   */
          ,MAX(COL_40_KRW)  AS COL_40_KRW  /* 40주          - 원화   */
          ,MAX(COL_41_KRW)  AS COL_41_KRW  /* 41주          - 원화   */
          ,MAX(COL_42_KRW)  AS COL_42_KRW  /* 42주          - 원화   */
          ,MAX(COL_43_KRW)  AS COL_43_KRW  /* 43주          - 원화   */
          ,MAX(COL_44_KRW)  AS COL_44_KRW  /* 44주          - 원화   */
          ,MAX(COL_45_KRW)  AS COL_45_KRW  /* 45주          - 원화   */
          ,MAX(COL_46_KRW)  AS COL_46_KRW  /* 46주          - 원화   */
          ,MAX(COL_47_KRW)  AS COL_47_KRW  /* 47주          - 원화   */
          ,MAX(COL_48_KRW)  AS COL_48_KRW  /* 48주          - 원화   */
          ,MAX(COL_49_KRW)  AS COL_49_KRW  /* 49주          - 원화   */
          ,MAX(COL_50_KRW)  AS COL_50_KRW  /* 50주          - 원화   */
          ,MAX(COL_51_KRW)  AS COL_51_KRW  /* 51주          - 원화   */
          ,MAX(COL_52_KRW)  AS COL_52_KRW  /* 52주          - 원화   */
          ,MAX(COL_53_KRW)  AS COL_53_KRW  /* 53주          - 원화   */
     FROM WT_BASE A
 GROUP BY PRODUCT_ID
         ,SORT_KEY
 ORDER BY SORT_KEY_PROD
         ,SORT_KEY
;