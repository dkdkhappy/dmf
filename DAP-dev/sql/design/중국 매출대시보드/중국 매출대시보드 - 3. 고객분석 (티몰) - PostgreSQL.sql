● 중국 매출대시보드 - 3. 고객분석 (티몰)

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */

0. 화면 설명
    * 기존 매출 대시보드 고객분석 페이지에 대한 수정내용
    * 티몰과 도우인 모두에 적용
    * 위치는 방문자 평균 체류시간 그래프와 요일별 방문자 평균 체류시간 그래프 아래 각각 부트스트랩 12 사이즈로 (한 줄 전체)

추가 1. 구매자 수 시계열 그래프
    * 형태는 방문자 수 시계열 그래프와 동일
    * 날짜 선택 가능해야함
    * 상단에는 카드로 당해 누적 구매자, 전해 누적 구매자, 증감율 디스플레이
    * 시계열 그래프로는 일,주,월 구매자 디스플레이
    * 단, 최초 초기값으로는 주 구매자수와 월 구매자수는 비활성화되어 있는 상태로
    * 그래프 하단에 월간 구매자 수 계산하여 디스플레이
    * 첫 행은 올해 (2023년)의 값
    * 둘째 행은 전년도(2022년)의 값
    * YoY는 YTD로 전년동기 대비 변화율
    * MoM은 전월대비 변화율

/* [추가] 1. 구매자 수 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SUM AS
    (
        SELECT SUM(NUMBER_OF_PAID_BUYERS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(NUMBER_OF_PAID_BUYERS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.PAID_CNT AS PAID_CNT      /* 당해 구매자수  */
              ,B.PAID_CNT AS PAID_CNT_YOY  /* 전해 구매자수  */
              ,(A.PAID_CNT - COALESCE(B.PAID_CNT, 0)) / B.PAID_CNT * 100 AS PAID_RATE  /* 구매자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(PAID_CNT     AS DECIMAL(20,0)), 0) AS PAID_CNT      /* 당해 구매자수    */
          ,COALESCE(CAST(PAID_CNT_YOY AS DECIMAL(20,0)), 0) AS PAID_CNT_YOY  /* 전해 구매자수    */
          ,COALESCE(CAST(PAID_RATE    AS DECIMAL(20,2)), 0) AS PAID_RATE     /* 구매자수 증감률  */
      FROM WT_BASE
;

/* [추가] 1. 구매자 수 시계열 그래프 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1              AS SORT_KEY
              ,'PAID'         AS L_LGND_ID  /* 일 구매자수 */ 
              ,'일 구매자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'PAID_WEEK'    AS L_LGND_ID  /* 주 구매자수 */ 
              ,'주 구매자수'  AS L_LGND_NM 
     UNION ALL
        SELECT 3              AS SORT_KEY
              ,'PAID_MNTH'    AS L_LGND_ID  /* 월 구매자수 */ 
              ,'월 구매자수'  AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(PAID_CNT)                                                                           AS PAID_CNT       /* 구매자수                  */
              ,AVG(SUM(PAID_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS PAID_CNT_WEEK  /* 구매자수 - 이동평균( 5일) */
              ,AVG(SUM(PAID_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS PAID_CNT_MNTH  /* 구매자수 - 이동평균(30일) */
          FROM WT_CAST A
      GROUP BY STATISTICS_DATE
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
               END AS Y_VAL  /* PAID:일 구매자수, PAID_WEEK:주 구매자수, PAID_MNTH:월 구매자수 */
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

/* [추가] 1. 구매자 수 시계열 그래프 - 하단표 SQL                   */
/*    오늘(2023.03.04)일 경우 => 기준일 : 2023.03.03              */
/*                               올해   : 2023.01.01 ~ 2023.12.31 */
/*                               전년도 : 2022.01.01 ~ 2022.12.31 */
/*    올해, 전년도는 방문자 수라서 소숫점이 없게 표시하고         */
/*    YoY, MoM는 증감률이라서 소숫점 2자리까지 표시하도록         */
/*    VARCHAR로 형변환하여 리턴함.                                */
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
        SELECT STATISTICS_DATE
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT   /* 구매자수 YoY */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '01' THEN PAID_CNT END) AS PAID_CNT_01 /* 01월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '02' THEN PAID_CNT END) AS PAID_CNT_02 /* 02월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '03' THEN PAID_CNT END) AS PAID_CNT_03 /* 03월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '04' THEN PAID_CNT END) AS PAID_CNT_04 /* 04월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '05' THEN PAID_CNT END) AS PAID_CNT_05 /* 05월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '06' THEN PAID_CNT END) AS PAID_CNT_06 /* 06월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '07' THEN PAID_CNT END) AS PAID_CNT_07 /* 07월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '08' THEN PAID_CNT END) AS PAID_CNT_08 /* 08월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '09' THEN PAID_CNT END) AS PAID_CNT_09 /* 09월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '10' THEN PAID_CNT END) AS PAID_CNT_10 /* 10월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '11' THEN PAID_CNT END) AS PAID_CNT_11 /* 11월 구매자수 */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '12' THEN PAID_CNT END) AS PAID_CNT_12 /* 12월 구매자수 */
          FROM WT_CAST A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '01' THEN PAID_CNT END) AS PAID_CNT_01 /* 01월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '02' THEN PAID_CNT END) AS PAID_CNT_02 /* 02월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '03' THEN PAID_CNT END) AS PAID_CNT_03 /* 03월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '04' THEN PAID_CNT END) AS PAID_CNT_04 /* 04월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '05' THEN PAID_CNT END) AS PAID_CNT_05 /* 05월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '06' THEN PAID_CNT END) AS PAID_CNT_06 /* 06월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '07' THEN PAID_CNT END) AS PAID_CNT_07 /* 07월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '08' THEN PAID_CNT END) AS PAID_CNT_08 /* 08월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '09' THEN PAID_CNT END) AS PAID_CNT_09 /* 09월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '10' THEN PAID_CNT END) AS PAID_CNT_10 /* 10월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '11' THEN PAID_CNT END) AS PAID_CNT_11 /* 11월 구매자수 YoY */
              ,SUM(CASE WHEN TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') = '12' THEN PAID_CNT END) AS PAID_CNT_12 /* 12월 구매자수 YoY */
          FROM WT_CAST_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_01
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_01, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_01, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_12, 2) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_01  /* 01월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_02
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_02, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_01, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_02  /* 02월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_03
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_03, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_03  /* 03월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_04
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_04, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_04  /* 04월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_05
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_05, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_05  /* 05월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_06
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_06, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_06  /* 06월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_07
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_07, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_07  /* 07월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_08
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_08, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_08  /* 08월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_09
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_09, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_09  /* 09월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_10
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_10, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_10  /* 10월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_11
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_11, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_11  /* 11월 구매자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN PAID_CNT_12
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(PAID_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_12, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(PAID_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(PAID_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(PAID_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS PAID_CNT_12  /* 12월 구매자수 */
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_01   /* 01월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_02   /* 02월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_03   /* 03월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_04   /* 04월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_05   /* 05월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_06   /* 06월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_07   /* 07월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_08   /* 08월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_09   /* 09월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_10   /* 10월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_11   /* 11월 구매자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(PAID_CNT_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(PAID_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS PAID_CNT_12   /* 12월 구매자수 */
      FROM WT_BASE
  ORDER BY SORT_KEY
;


추가 2. 구매자 첫구매/재구매 비율
    * 형태는 방문자 첫 방문 / 재 방문 그래프와 동일
    * 날짜 선택 가능해야함
    * 라인 그래프로 재구매자 비율 디스플레이
        재구매자 비율 - 재구매자 / 구매자
    * 바그래프로 구매자수 (일간, 주간, 월간) 표시
    * 단, 최초 초기값으로 주 구매자수와 월 구매자수는 비활성화 되어있는 상태로
    * 그래프 하단에 월간 재 구매율 계산하여 디스플레이
    * 첫 행은 재 구매자수
    * 둘째 행은 재구매율

/* 추가 2. 구매자 첫구매/재구매 비율 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
        SELECT STATISTICS_DATE
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
              ,PAY_OLD_BUYERS        AS REPD_CNT  /* 재구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
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
;

/* 추가 2. 구매자 첫구매/재구매 비율 - 하단 표 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT      /* 기준일의  1월  1일       */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT      /* 기준일의 12월 31일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1             AS SORT_KEY
              ,'재구매자 수' AS ROW_TITL
     UNION ALL
        SELECT 2             AS SORT_KEY
              ,'재구매율'    AS ROW_TITL
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
              ,PAY_OLD_BUYERS        AS REPD_CNT  /* 재구매자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS COL_MNTH
              ,SUM(PAID_CNT)                                AS PAID_CNT  /* 구매자수   */
              ,SUM(REPD_CNT)                                AS REPD_CNT  /* 재구매자수 */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
    ), WT_RATE AS
    (
        SELECT COL_MNTH       /* 월       */
              ,PAID_CNT       /* 구매자수 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE REPD_CNT / PAID_CNT * 100 END AS REPD_RATE  /* 재구매자 비율 */
          FROM WT_SUM A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '01' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '01' THEN REPD_RATE  END) AS COL_VAL_01
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '02' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '02' THEN REPD_RATE  END) AS COL_VAL_02
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '03' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '03' THEN REPD_RATE  END) AS COL_VAL_03
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '04' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '04' THEN REPD_RATE  END) AS COL_VAL_04
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '05' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '05' THEN REPD_RATE  END) AS COL_VAL_05
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '06' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '06' THEN REPD_RATE  END) AS COL_VAL_06
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '07' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '07' THEN REPD_RATE  END) AS COL_VAL_07
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '08' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '08' THEN REPD_RATE  END) AS COL_VAL_08
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '09' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '09' THEN REPD_RATE  END) AS COL_VAL_09
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '10' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '10' THEN REPD_RATE  END) AS COL_VAL_10
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '11' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '11' THEN REPD_RATE  END) AS COL_VAL_11
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '12' THEN PAID_CNT WHEN SORT_KEY = 2 AND COL_MNTH = '12' THEN REPD_RATE  END) AS COL_VAL_12
          FROM WT_COPY A 
              ,WT_RATE B
      GROUP BY SORT_KEY
              ,ROW_TITL
    )
    SELECT ROW_TITL
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_01   /* 01월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_02   /* 02월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_03   /* 03월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_04   /* 04월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_05   /* 05월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_06   /* 06월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_07   /* 07월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_08   /* 08월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_09   /* 09월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_10   /* 10월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_11   /* 11월  */
          ,CASE WHEN SORT_KEY = 1 THEN TO_CHAR(CAST(COL_VAL_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(COL_VAL_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS COL_VAL_12   /* 12월  */
      FROM WT_BASE
  ORDER BY SORT_KEY
;
