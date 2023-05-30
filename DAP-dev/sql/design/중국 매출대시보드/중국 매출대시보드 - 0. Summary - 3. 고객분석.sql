● 중국 매출대시보드 - 0. Summary - 3. 고객분석

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 대시보드 중 Summary에서 고객을 표기하는 첫번째 페이지


1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어
    * Tmall 채널의 방문자수 합산에 대한 시계열 데이터
/* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_DATA AS
    (
        SELECT 'DCT'                 AS CHNL_ID
              ,SUM(PRODUCT_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'                 AS CHNL_ID
              ,SUM(PRODUCT_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_DATA_YOY AS
    (
        SELECT 'DCT'                 AS CHNL_ID
              ,SUM(PRODUCT_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'                 AS CHNL_ID
              ,SUM(PRODUCT_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(VIST_CNT) AS VIST_CNT  /* 방문자수 */
          FROM WT_DATA A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(VIST_CNT) AS VIST_CNT  /* 방문자수 */
          FROM WT_DATA_YOY A
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT AS VIST_CNT      /* 당해 방문자수  */
              ,B.VIST_CNT AS VIST_CNT_YOY  /* 전해 방문자수  */
              ,(A.VIST_CNT - COALESCE(B.VIST_CNT, 0)) / B.VIST_CNT * 100 AS VIST_RATE  /* 방문자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(VIST_CNT     AS DECIMAL(20,0)), 0) AS VIST_CNT      /* 당해 방문자수    */
          ,COALESCE(CAST(VIST_CNT_YOY AS DECIMAL(20,0)), 0) AS VIST_CNT_YOY  /* 전해 방문자수    */
          ,COALESCE(CAST(VIST_RATE    AS DECIMAL(20,2)), 0) AS VIST_RATE     /* 방문자수 증감률  */
      FROM WT_BASE
;

/* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1              AS SORT_KEY
              ,'VIST'         AS L_LGND_ID  /* 일 방문자수 */ 
              ,'일 방문자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'VIST_WEEK'    AS L_LGND_ID  /* 주 방문자수 */ 
              ,'주 방문자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 3              AS SORT_KEY
              ,'VIST_MNTH'    AS L_LGND_ID  /* 월 방문자수 */ 
              ,'월 방문자수'  AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT 'DCT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(VIST_CNT)                                                                           AS VIST_CNT       /* 방문자수                  */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
          FROM WT_CAST A
      GROUP BY STATISTICS_DATE
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
               END AS Y_VAL  /* VIST:일 방문자수, VIST_WEEK:주 방문자수, VIST_MNTH:월 방문자수 */
          FROM WT_COPY A
              ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
;

/* 1. Tmall 방문자 수 정보에 대한 시계열 데이터 뷰어 - 하단 표 SQL */
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
    ), WT_CAST AS
    (
        SELECT 'DCT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT 'DCT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT   /* 방문자수 YoY */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
     UNION ALL
        SELECT 'DGT'            AS CHNL_ID
              ,STATISTICS_DATE
              ,PRODUCT_VISITORS AS VIST_CNT   /* 방문자수 YoY */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
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
;


2. Tmall 방문자 수 Break Down
    * 티몰 채널의 방문자수를 stack그래프로 표기하여 내륙몰과 글로벌몰 확인
/* 2. Tmall 방문자 수 Break Down - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:FR_MNTH                                                                           AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                           AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE(:CHRT_TYPE, 'RATE')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'CNT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
    ), WT_DCT AS
    (
        SELECT 'DCT'                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM') AS MNTH_DCT
              ,SUM(PRODUCT_VISITORS)                                      AS DCT_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DGT AS
    (
        SELECT 'DGT'                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM') AS MNTH_DGT
              ,SUM(PRODUCT_VISITORS)                                      AS DGT_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCT_VIST_CNT
              ,DGT_VIST_CNT
              ,DCT_VIST_CNT + DGT_VIST_CNT AS CHNL_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCT B ON (A.COPY_MNTH = B.MNTH_DCT)
                              LEFT OUTER JOIN WT_DGT C ON (A.COPY_MNTH = C.MNTH_DGT)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DCT_VIST_CNT ELSE DCT_VIST_CNT / CHNL_CNT * 100 END
                 WHEN A.CHNL_ID = 'DGT' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DGT_VIST_CNT ELSE DGT_VIST_CNT / CHNL_CNT * 100 END
               END AS Y_VAL
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;


3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어
    * 도우인 채널의 노출 또는 클릭한 사람의 시계열 데이터
/* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR    , '-', '') AS INTEGER) AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(REPLACE(BASE_DT         , '-', '') AS INTEGER) AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY, '-', '') AS INTEGER) AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(REPLACE(BASE_DT_YOY     , '-', '') AS INTEGER) AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_DATA AS
    (
        SELECT 'DCD'                      AS CHNL_ID
              ,SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'DGD'                      AS CHNL_ID
              ,SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_DATA_YOY AS
    (
        SELECT 'DCD'                      AS CHNL_ID
              ,SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
     UNION ALL
        SELECT 'DGD'                      AS CHNL_ID
              ,SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(VIST_CNT) AS VIST_CNT  /* 방문자수 */
          FROM WT_DATA A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(VIST_CNT) AS VIST_CNT  /* 방문자수 */
          FROM WT_DATA_YOY A
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT AS VIST_CNT      /* 당해 방문자수  */
              ,B.VIST_CNT AS VIST_CNT_YOY  /* 전해 방문자수  */
              ,(A.VIST_CNT - COALESCE(B.VIST_CNT, 0)) / B.VIST_CNT * 100 AS VIST_RATE  /* 방문자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(VIST_CNT     AS DECIMAL(20,0)), 0) AS VIST_CNT      /* 당해 방문자수    */
          ,COALESCE(CAST(VIST_CNT_YOY AS DECIMAL(20,0)), 0) AS VIST_CNT_YOY  /* 전해 방문자수    */
          ,COALESCE(CAST(VIST_RATE    AS DECIMAL(20,2)), 0) AS VIST_RATE     /* 방문자수 증감률  */
      FROM WT_BASE
;

/* 3. Douyin 방문자 수 정보에 대한 시계열 데이터 뷰어 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(:FR_DT, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE(:TO_DT, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1              AS SORT_KEY
              ,'VIST'         AS L_LGND_ID  /* 일 방문자수 */ 
              ,'일 방문자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'VIST_WEEK'    AS L_LGND_ID  /* 주 방문자수 */ 
              ,'주 방문자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 3              AS SORT_KEY
              ,'VIST_MNTH'    AS L_LGND_ID  /* 월 방문자수 */ 
              ,'월 방문자수'  AS L_LGND_NM 
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
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(VIST_CNT)                                                                           AS VIST_CNT       /* 방문자수                  */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
          FROM WT_CAST A
      GROUP BY STATISTICS_DATE
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
               END AS Y_VAL  /* VIST:일 방문자수, VIST_WEEK:주 방문자수, VIST_MNTH:월 방문자수 */
          FROM WT_COPY A
              ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
;

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
;

4. Douyin 방문자 수 Break Down
    * 도우인 채널의 노출 또는 클릭한 사람의 stack 그래프로 표기하여 티몰과 글로벌몰 확인
/* 4. Douyin 방문자 수 Break Down - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYYMMDD') AS INTEGER) AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYYMMDD') AS INTEGER) AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:FR_MNTH                                                                                          AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                                          AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE(:CHRT_TYPE, 'RATE')                                                                      AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'CNT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_DCD AS
    (
        SELECT 'DCD'                                                       AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_DCD
              ,SUM(PRODUCT_CLICKS_PERSON)                                  AS DCD_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DGD AS
    (
        SELECT 'DGD'                                                       AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_DGD
              ,SUM(PRODUCT_CLICKS_PERSON)                                  AS DGD_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCD_VIST_CNT
              ,DGD_VIST_CNT
              ,DCD_VIST_CNT + DGD_VIST_CNT AS CHNL_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCD B ON (A.COPY_MNTH = B.MNTH_DCD)
                              LEFT OUTER JOIN WT_DGD C ON (A.COPY_MNTH = C.MNTH_DGD)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DCD_VIST_CNT ELSE DCD_VIST_CNT / CHNL_CNT * 100 END
                 WHEN A.CHNL_ID = 'DGD' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DGD_VIST_CNT ELSE DGD_VIST_CNT / CHNL_CNT * 100 END
               END AS Y_VAL
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;

5. 채널별 검색 지표 Break Down
    * 구매자 비중, 객단가, 구매자당 수익, 첫방문자비중(tmall만), 평균체류시간(tmall만)를 월단위로 표기
    * 표기시에는 전체(채널 전체 합산)과 각 채널이 함께 나올 수 있도록

/* 5. 채널별 검색 지표 Break Down - Tmall 선택 SQL */
WITH WT_TYPE AS
    (
        SELECT 1                AS SORT_KEY
              ,'PAID_RATE'      AS TYPE_ID
              ,'구매자 비중'    AS TYPE_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'CUST_AMT'       AS TYPE_ID
              ,'객단가'         AS TYPE_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'CUST_CM'        AS TYPE_ID
              ,'구매자당 수익'  AS TYPE_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'FRST_RATE'      AS TYPE_ID
              ,'첫방문자 비중'  AS TYPE_NM
     UNION ALL
        SELECT 5                AS SORT_KEY
              ,'STAY_TIME'      AS TYPE_ID
              ,'평균 체류시간'  AS TYPE_NM
     UNION ALL
        SELECT 6                AS SORT_KEY
              ,'REPD_RATE'      AS TYPE_ID
              ,'재구매율'       AS TYPE_NM
    )
    SELECT SORT_KEY
          ,TYPE_ID
          ,TYPE_NM
      FROM WT_TYPE A
  ORDER BY SORT_KEY
;

/* 5. 채널별 검색 지표 Break Down - Tmall 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                             , 'YYYY-MM-DD') AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYY-MM-DD') AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE)                             , 'YYYY-MM-DD') AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYY-MM-DD') AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */
              ,:FR_MNTH                                                                          AS FR_MNTH         /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                          AS TO_MNTH         /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE(:TYPE_ID, 'PAID_RATE')                                                   AS TYPE_ID         /* PAID_RATE: '구매자 비중', CUST_AMT: '객단가', CUST_CM: '구매자당 수익', FRST_RATE: '첫방문자 비중', STAY_TIME: '평균 체류시간', REPD_RATE: '재구매율' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 0                AS SORT_KEY
              ,'ALL'            AS CHNL_ID
              ,'전체'           AS CHNL_NM
              ,''               AS CHNL_ID_CM
     UNION ALL
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
              ,'Tmall China'    AS CHNL_ID_CM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
              ,'Tmall Global'   AS CHNL_ID_CM
    ), WT_ANLS AS
    (
        SELECT DATE                                                                        AS MNTH_ANLS
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall China'   THEN CM END), 0) * 1000000 AS DCT_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall Global'  THEN CM END), 0) * 1000000 AS DGT_CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID_CM FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DCT AS
    (
        SELECT 'DCT'                                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')                 AS MNTH_DCT
              ,COALESCE(SUM(PRODUCT_VISITORS                                        ), 0) AS DCT_VIST_CNT      /* 방문자 수         */
              ,COALESCE(SUM(NEW_VISITORS                                            ), 0) AS DCT_FRST_CNT      /* 첫방문자수        */
              ,COALESCE(SUM(NUMBER_OF_PAID_BUYERS                                   ), 0) AS DCT_PAID_CNT      /* 구매자 수         */
              ,COALESCE(SUM(PAYMENT_AMOUNT                                          ), 0) AS DCT_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,COALESCE(SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)), 0) AS DCT_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,COALESCE(AVG(AVERAGE_LENGTH_OF_STAY                                  ), 0) AS DCT_STAY_TIME     /* 체류시간          */
              ,COALESCE(SUM(PAY_OLD_BUYERS                                          ), 0) AS DCT_REPD_CNT      /* 재구매자 수       */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DGT AS
    (
        SELECT 'DGT'                                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')                 AS MNTH_DGT
              ,COALESCE(SUM(PRODUCT_VISITORS                                        ), 0) AS DGT_VIST_CNT      /* 방문자 수         */
              ,COALESCE(SUM(NEW_VISITORS                                            ), 0) AS DGT_FRST_CNT      /* 첫방문자수        */
              ,COALESCE(SUM(NUMBER_OF_PAID_BUYERS                                   ), 0) AS DGT_PAID_CNT      /* 구매자 수         */
              ,COALESCE(SUM(PAYMENT_AMOUNT                                          ), 0) AS DGT_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,COALESCE(SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)), 0) AS DGT_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,COALESCE(AVG(AVERAGE_LENGTH_OF_STAY                                  ), 0) AS DGT_STAY_TIME     /* 체류시간          */
              ,COALESCE(SUM(PAY_OLD_BUYERS                                          ), 0) AS DGT_REPD_CNT      /* 재구매자 수       */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CASE WHEN DCT_VIST_CNT = 0 THEN 0 ELSE DCT_PAID_CNT     / DCT_VIST_CNT * 100 END AS DCT_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_SALE_AMT_RMB / DCT_PAID_CNT       END AS DCT_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_SALE_AMT_KRW / DCT_PAID_CNT       END AS DCT_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_CM_AMT       / DCT_PAID_CNT       END AS DCT_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DCT_VIST_CNT = 0 THEN 0 ELSE DCT_FRST_CNT     / DCT_VIST_CNT * 100 END AS DCT_FRST_RATE     /* 첫방문자 비중   */
              ,DCT_STAY_TIME                                                                    AS DCT_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN DCT_PAID_CNT = 0 THEN 0 ELSE DCT_REPD_CNT     / DCT_PAID_CNT * 100 END AS DCT_REPD_RATE     /* 재구매율        */

              ,CASE WHEN DGT_VIST_CNT = 0 THEN 0 ELSE DGT_PAID_CNT     / DGT_VIST_CNT * 100 END AS DGT_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_SALE_AMT_RMB / DGT_PAID_CNT       END AS DGT_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_SALE_AMT_KRW / DGT_PAID_CNT       END AS DGT_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_CM_AMT       / DGT_PAID_CNT       END AS DGT_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DGT_VIST_CNT = 0 THEN 0 ELSE DGT_FRST_CNT     / DGT_VIST_CNT * 100 END AS DGT_FRST_RATE     /* 첫방문자 비중   */
              ,DGT_STAY_TIME                                                                    AS DGT_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN DGT_PAID_CNT = 0 THEN 0 ELSE DGT_REPD_CNT     / DGT_PAID_CNT * 100 END AS DGT_REPD_RATE     /* 재구매율        */

              ,CASE WHEN (DCT_VIST_CNT + DGT_VIST_CNT) = 0 THEN 0 ELSE (DCT_PAID_CNT     + DGT_PAID_CNT    ) / (DCT_VIST_CNT + DGT_VIST_CNT) * 100 END AS ALL_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_SALE_AMT_RMB + DGT_SALE_AMT_RMB) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_SALE_AMT_KRW + DGT_SALE_AMT_KRW) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_CM_AMT       + DGT_CM_AMT      ) / (DCT_PAID_CNT + DGT_PAID_CNT)       END AS ALL_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN (DCT_VIST_CNT + DGT_VIST_CNT) = 0 THEN 0 ELSE (DCT_FRST_CNT     + DGT_FRST_CNT    ) / (DCT_VIST_CNT + DGT_VIST_CNT) * 100 END AS ALL_FRST_RATE     /* 첫방문자 비중   */
              ,(DCT_STAY_TIME + DGT_STAY_TIME) / 2                                                                                                     AS ALL_STAY_TIME     /* 평균 체류시간   */
              ,CASE WHEN (DCT_PAID_CNT + DGT_PAID_CNT) = 0 THEN 0 ELSE (DCT_REPD_CNT     + DGT_REPD_CNT    ) / (DCT_PAID_CNT + DGT_PAID_CNT) * 100 END AS ALL_REPD_RATE     /* 재구매율        */
              ,(SELECT TYPE_ID FROM WT_WHERE) AS TYPE_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCT  B ON (A.COPY_MNTH = B.MNTH_DCT)
                              LEFT OUTER JOIN WT_DGT  C ON (A.COPY_MNTH = C.MNTH_DGT)
                              LEFT OUTER JOIN WT_ANLS D ON (A.COPY_MNTH = D.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'PAID_RATE' THEN DCT_PAID_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_AMT'  THEN DCT_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_CM'   THEN DCT_CUST_CM
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'FRST_RATE' THEN DCT_FRST_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'STAY_TIME' THEN DCT_STAY_TIME
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'REPD_RATE' THEN DCT_REPD_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'PAID_RATE' THEN DGT_PAID_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_AMT'  THEN DGT_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_CM'   THEN DGT_CUST_CM
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'FRST_RATE' THEN DGT_FRST_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'STAY_TIME' THEN DGT_STAY_TIME
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'REPD_RATE' THEN DGT_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'FRST_RATE' THEN ALL_FRST_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'STAY_TIME' THEN ALL_STAY_TIME
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
               END AS Y_VAL_RMB
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'PAID_RATE' THEN DCT_PAID_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_AMT'  THEN DCT_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'CUST_CM'   THEN DCT_CUST_CM
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'FRST_RATE' THEN DCT_FRST_RATE
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'STAY_TIME' THEN DCT_STAY_TIME
                 WHEN A.CHNL_ID = 'DCT' AND TYPE_ID = 'REPD_RATE' THEN DCT_REPD_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'PAID_RATE' THEN DGT_PAID_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_AMT'  THEN DGT_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'CUST_CM'   THEN DGT_CUST_CM
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'FRST_RATE' THEN DGT_FRST_RATE
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'STAY_TIME' THEN DGT_STAY_TIME
                 WHEN A.CHNL_ID = 'DGT' AND TYPE_ID = 'REPD_RATE' THEN DGT_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'FRST_RATE' THEN ALL_FRST_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'STAY_TIME' THEN ALL_STAY_TIME
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
               END AS Y_VAL_KRW
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;


/* 5. 채널별 검색 지표 Break Down - Douyin 선택 SQL */
WITH WT_TYPE AS
    (
        SELECT 1                AS SORT_KEY
              ,'PAID_RATE'      AS TYPE_ID
              ,'구매자 비중'    AS TYPE_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'REPD_RATE'      AS TYPE_ID
              ,'재구매율'       AS TYPE_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'CUST_AMT'       AS TYPE_ID
              ,'객단가'         AS TYPE_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'CUST_CM'        AS TYPE_ID
              ,'구매자당 수익'  AS TYPE_NM
     UNION ALL
        SELECT 5                AS SORT_KEY
              ,'CLCK_RATE'      AS TYPE_ID
              ,'클릭률'         AS TYPE_NM
    )
    SELECT SORT_KEY
          ,TYPE_ID
          ,TYPE_NM
      FROM WT_TYPE A
  ORDER BY SORT_KEY
;

/* 5. 채널별 검색 지표 Break Down - Douyin 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                             , 'YYYYMMDD') AS INTEGER) AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYYMMDD') AS INTEGER) AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,CAST(TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE)                             , 'YYYYMMDD') AS INTEGER) AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,CAST(TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY', 'YYYYMMDD') AS INTEGER) AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */
              ,:FR_MNTH                                                                                          AS FR_MNTH         /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                                          AS TO_MNTH         /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE(:TYPE_ID, 'PAID_RATE')                                                                   AS TYPE_ID         /* PAID_RATE: '구매자 비중', REPD_RATE: '재구매율', CUST_AMT: '객단가', CUST_CM: '구매자당 수익', CLCK_RATE: '클릭률' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 0                AS SORT_KEY
              ,'ALL'            AS CHNL_ID
              ,'전체'           AS CHNL_NM
              ,''               AS CHNL_ID_CM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
              ,'Douyin China'   AS CHNL_ID_CM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
              ,'Douyin Global'  AS CHNL_ID_CM
    ), WT_ANLS AS
    (
        SELECT DATE                                                                        AS MNTH_ANLS
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin China'  THEN CM END), 0) * 1000000 AS DCD_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin Global' THEN CM END), 0) * 1000000 AS DGD_CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID_CM FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DCD AS
    (
        SELECT 'DCD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DCD
              ,SUM(PRODUCT_CLICKS_PERSON                                       )  AS DCD_VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS DCD_PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS DCD_PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS DCD_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS DCD_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS DCD_CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DCD_REPD AS
    (
        SELECT 'DCD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DCD
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS DCD_REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS DCD_REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_DCD_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')    
    ), WT_DGD AS
    (
        SELECT 'DGD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DGD
              ,SUM(PRODUCT_CLICKS_PERSON                                       )  AS DGD_VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS DGD_PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS DGD_PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS DGD_SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS DGD_SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS DGD_CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DGD_REPD AS
    (
        SELECT 'DGD'                                                              AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')        AS MNTH_DGD
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS DGD_REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS DGD_REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_DCD_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')    
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,CASE WHEN DCD_VIST_CNT      = 0 THEN 0 ELSE DCD_PAID_CNT     / DCD_VIST_CNT      * 100 END AS DCD_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DCD_REPD_PAID_CNT = 0 THEN 0 ELSE DCD_REPD_CNT     / DCD_REPD_PAID_CNT * 100 END AS DCD_REPD_RATE     /* 재구매율        */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_SALE_AMT_RMB / DCD_PAID_CNT            END AS DCD_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_SALE_AMT_KRW / DCD_PAID_CNT            END AS DCD_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DCD_PAID_CNT      = 0 THEN 0 ELSE DCD_CM_AMT       / DCD_PAID_CNT            END AS DCD_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DCD_PROD_CNT      = 0 THEN 0 ELSE DCD_CLCK_CNT     / DCD_PROD_CNT      * 100 END AS DCD_CLCK_RATE     /* 클릭률          */

              ,CASE WHEN DGD_VIST_CNT      = 0 THEN 0 ELSE DGD_PAID_CNT     / DGD_VIST_CNT      * 100 END AS DGD_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN DGD_REPD_PAID_CNT = 0 THEN 0 ELSE DGD_REPD_CNT     / DGD_REPD_PAID_CNT * 100 END AS DGD_REPD_RATE     /* 재구매율        */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_SALE_AMT_RMB / DGD_PAID_CNT            END AS DGD_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_SALE_AMT_KRW / DGD_PAID_CNT            END AS DGD_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN DGD_PAID_CNT      = 0 THEN 0 ELSE DGD_CM_AMT       / DGD_PAID_CNT            END AS DGD_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN DGD_PROD_CNT      = 0 THEN 0 ELSE DGD_CLCK_CNT     / DGD_PROD_CNT      * 100 END AS DGD_CLCK_RATE     /* 클릭률          */

              ,CASE WHEN (DCD_VIST_CNT      + DCD_VIST_CNT     ) = 0 THEN 0 ELSE (DCD_PAID_CNT     + DCD_PAID_CNT    ) / (DCD_VIST_CNT      + DCD_VIST_CNT     ) * 100 END AS ALL_PAID_RATE     /* 구매자 비중     */
              ,CASE WHEN (DCD_REPD_PAID_CNT + DCD_REPD_PAID_CNT) = 0 THEN 0 ELSE (DCD_REPD_CNT     + DCD_REPD_CNT    ) / (DCD_REPD_PAID_CNT + DCD_REPD_PAID_CNT) * 100 END AS ALL_REPD_RATE     /* 재구매율        */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_SALE_AMT_RMB + DCD_SALE_AMT_RMB) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_SALE_AMT_KRW + DCD_SALE_AMT_KRW) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_AMT_KRW  /* 객단가 - 원화   */
              ,CASE WHEN (DCD_PAID_CNT      + DCD_PAID_CNT     ) = 0 THEN 0 ELSE (DCD_CM_AMT       + DCD_CM_AMT      ) / (DCD_PAID_CNT      + DCD_PAID_CNT     )       END AS ALL_CUST_CM       /* 구매자당 수익   */
              ,CASE WHEN (DCD_PROD_CNT      + DCD_PROD_CNT     ) = 0 THEN 0 ELSE (DCD_CLCK_CNT     + DCD_CLCK_CNT    ) / (DCD_PROD_CNT      + DCD_PROD_CNT     ) * 100 END AS ALL_CLCK_RATE     /* 클릭률          */
              ,(SELECT TYPE_ID FROM WT_WHERE) AS TYPE_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCD      B ON (A.COPY_MNTH = B.MNTH_DCD)
                              LEFT OUTER JOIN WT_DCD_REPD C ON (A.COPY_MNTH = C.MNTH_DCD)
                              LEFT OUTER JOIN WT_DGD      D ON (A.COPY_MNTH = D.MNTH_DGD)
                              LEFT OUTER JOIN WT_DGD_REPD E ON (A.COPY_MNTH = E.MNTH_DGD)
                              LEFT OUTER JOIN WT_ANLS     F ON (A.COPY_MNTH = F.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'PAID_RATE' THEN DCD_PAID_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'REPD_RATE' THEN DCD_REPD_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_AMT'  THEN DCD_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_CM'   THEN DCD_CUST_CM
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CLCK_RATE' THEN DCD_CLCK_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'PAID_RATE' THEN DGD_PAID_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'REPD_RATE' THEN DGD_REPD_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_AMT'  THEN DGD_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_CM'   THEN DGD_CUST_CM
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CLCK_RATE' THEN DGD_CLCK_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_RMB
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CLCK_RATE' THEN ALL_CLCK_RATE
               END AS Y_VAL_RMB
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'PAID_RATE' THEN DCD_PAID_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'REPD_RATE' THEN DCD_REPD_RATE
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_AMT'  THEN DCD_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CUST_CM'   THEN DCD_CUST_CM
                 WHEN A.CHNL_ID = 'DCD' AND TYPE_ID = 'CLCK_RATE' THEN DCD_CLCK_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'PAID_RATE' THEN DGD_PAID_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'REPD_RATE' THEN DGD_REPD_RATE
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_AMT'  THEN DGD_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CUST_CM'   THEN DGD_CUST_CM
                 WHEN A.CHNL_ID = 'DGD' AND TYPE_ID = 'CLCK_RATE' THEN DGD_CLCK_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'PAID_RATE' THEN ALL_PAID_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'REPD_RATE' THEN ALL_REPD_RATE
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_AMT'  THEN ALL_CUST_AMT_KRW
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CUST_CM'   THEN ALL_CUST_CM
                 WHEN A.CHNL_ID = 'ALL' AND TYPE_ID = 'CLCK_RATE' THEN ALL_CLCK_RATE
               END AS Y_VAL_KRW
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS Y_VAL_RMB
          ,CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;


6. 지역 분포 그래프
    * 지역별 전체 방문자 수 / 우측의 표를 통해 각 1선도시, 2선도시, 준1선도시, 3선도시의 비중을 채널별로 표기

/* 6. 지역 분포 그래프 - Map Chart SQL */
WITH WT_CITY_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
    ), WT_CITY AS
    (
        SELECT CITY_NM       AS CITY_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_CITY_ALL
       GROUP BY CITY_NM
         HAVING SUM(VIST_CNT) > 0 
    ), WT_PROV AS
    (
        SELECT A.PROV_NM
              ,SUM(B.VIST_CNT) AS VIST_CNT
          FROM DASH_RAW.OVER_CHINA_CITY A INNER JOIN WT_CITY B
            ON (A.CITY_NM = B.CITY_NM)
      GROUP BY A.PROV_NM
    ), WT_BASE AS 
    (
        SELECT CITY_NM
              ,VIST_CNT
          FROM WT_CITY
     UNION ALL
        SELECT PROV_NM
              ,VIST_CNT
          FROM WT_PROV
    )
    SELECT CITY_NM
          ,VIST_CNT
      FROM WT_BASE
  ORDER BY VIST_CNT DESC NULLS LAST
          ,CITY_NM
;

/* 6. 지역 분포 그래프 - 표 SQL */
WITH WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'1'          AS CITY_LV
              ,'1선도시'    AS CITY_LV_NM 
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'2'          AS CITY_LV
              ,'준1선도시'  AS CITY_LV_NM 
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'3'          AS CITY_LV
              ,'2선도시'    AS CITY_LV_NM 
     UNION ALL
        SELECT 4            AS SORT_KEY
              ,'4'          AS CITY_LV
              ,'3선도시'    AS CITY_LV_NM
    ), WT_DCT AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DGT AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DCD AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DGD AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END              AS CITY_LV
              ,LEVEL            AS CITY_LV_NM
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CITY_LV
              ,A.CITY_LV_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) + COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.CITY_LV = B.CITY_LV)
                         LEFT OUTER JOIN WT_DGT C ON (A.CITY_LV = C.CITY_LV)
                         LEFT OUTER JOIN WT_DCD D ON (A.CITY_LV = D.CITY_LV)
                         LEFT OUTER JOIN WT_DGD E ON (A.CITY_LV = E.CITY_LV)
    )
    SELECT SORT_KEY
          ,CITY_LV_NM
          ,TO_CHAR(CASE WHEN TOTL_VIST_CNT = 0 THEN NULL ELSE TOTL_VIST_CNT END, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

7. 성별 그래프
    * 남녀 비중을 전체 채널 표기 이후 각 채널별로 표기
/* 7. 성별 그래프 - 그래프 SQL */
WITH WT_GNDR_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT GNDR_NM       AS GNDR_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_GNDR_ALL
       GROUP BY GNDR_NM
    )
    SELECT GNDR_NM  AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY GNDR_NM
;

/* 7. 성별 그래프 - 표 SQL */
WITH WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'女'         AS GNDR_ID
              ,'여성'       AS GNDR_NM 
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'未知'       AS GNDR_ID
              ,'미상'       AS GNDR_NM 
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'男'         AS GNDR_ID
              ,'남성'       AS GNDR_NM 
    ), WT_DCT AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DGT AS
    (
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DCD AS
    (
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DGD AS
    (
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.GNDR_ID
              ,A.GNDR_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) + COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.GNDR_ID = B.GNDR_ID)
                         LEFT OUTER JOIN WT_DGT C ON (A.GNDR_ID = C.GNDR_ID)
                         LEFT OUTER JOIN WT_DCD D ON (A.GNDR_ID = D.GNDR_ID)
                         LEFT OUTER JOIN WT_DGD E ON (A.GNDR_ID = E.GNDR_ID)
    )
    SELECT SORT_KEY
          ,GNDR_NM
          ,TO_CHAR(TOTL_VIST_CNT, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

8. 연령별 그래프
    * 연령별 전체 비중 표기 이후 각 채널 별로 표기
/* 8. 연령별 그래프 - 그래프 SQL */
WITH WT_AGE_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
      GROUP BY NAME
     UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
      GROUP BY NAME
     UNION ALL
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
      GROUP BY NAME
     UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT AGE_NM        AS AGE_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_AGE_ALL
      GROUP BY AGE_NM
    )
    SELECT AGE_NM   AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY AGE_NM
;

/* 8. 연령별 그래프 - 표 SQL */
WITH WT_COPY AS
    (
    SELECT ROW_NUMBER() OVER(ORDER BY AGE_NM) AS SORT_KEY
          ,AGE_NM AS AGE_ID
          ,AGE_NM
      FROM  (
                SELECT DISTINCT 
                       AGE_NM
                  FROM  (
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
                         UNION ALL
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
                         UNION ALL
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
                         UNION ALL
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
                        ) A
            ) A
    ), WT_DCT AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_DGT AS
    (
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_DCD AS
    (
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_DGD AS
    (
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV::INTEGER) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 Intger로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.AGE_ID
              ,A.AGE_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) + COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.AGE_ID = B.AGE_ID)
                         LEFT OUTER JOIN WT_DGT C ON (A.AGE_ID = C.AGE_ID)
                         LEFT OUTER JOIN WT_DCD D ON (A.AGE_ID = D.AGE_ID)
                         LEFT OUTER JOIN WT_DGD E ON (A.AGE_ID = E.AGE_ID)
    )
    SELECT SORT_KEY
          ,AGE_NM
          ,TO_CHAR(TOTL_VIST_CNT, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY
;