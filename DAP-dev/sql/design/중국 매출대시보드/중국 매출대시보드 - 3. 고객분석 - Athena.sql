● 중국 매출대시보드 - 3. 고객분석

/* 아래 SQL은 AWS Athena 문법으로 작성되어 있음!!! */

/* 0. 매출 대시보드 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 어제임 오늘이 2023.03.04 일 경우 => 22023.03.03 */
SELECT CAST(                    CURRENT_DATE - INTERVAL '1' DAY                       AS VARCHAR) AS BASE_DT           /* 기준일자               */
      ,CAST(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR  AS VARCHAR) AS BASE_DT_YOY       /* 기준일자          -1년 */
      ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_MNTH      /* 기준월의 1일           */
      ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' YEAR)                     AS VARCHAR) AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
      ,CAST(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
      ,CAST(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' YEAR)                     AS VARCHAR) AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
      ,DATE_FORMAT(CURRENT_DATE - INTERVAL '1' DAY,                     '%Y'   )                  AS BASE_YEAR         /* 기준년                 */
      ,DATE_FORMAT(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, '%Y'   )                  AS BASE_YEAR_YOY     /* 기준년            -1년 */
      ,DATE_FORMAT(CURRENT_DATE - INTERVAL '1' DAY,                     '%Y-%m')                  AS BASE_MNTH         /* 기준월                 */
      ,DATE_FORMAT(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, '%Y-%m')                  AS BASE_MNTH_YOY     /* 기준월            -1년 */   


1. 중요정보카드
    * 방문자수 : 직전일 방문자수
        => 
    * 월별방문자수(누적) : 해당월 직전일까지의 누적 방문자수
      (예 : 2월 20일이면 2월 1일 부터 2월 19일까지 누적 합)
        =>
    * 연간방문자수(누적) : 1월 1일부터 직전일까지 누적 방문자수 
        =>
    * 객단가 : 직전일 환불금액
        => 객단가 = 매출 / 구매자
    * 평균체류시간 : 평균 체류시간 카드
        =>
    * 첫방문자 게이지 그래프 : 총 방문자 중 첫방문자의 비율을 게이지로 나타냄 
        => 연간 누적으로 계산 (화면기획에 게이지 카드 상단에 YYYY표시가 있는 것으로 보아 년간 누적으로 예상)
        => 방문자 컬럼 변경 PRODUCT_VISITORS => NUMBER_OF_VISITORS

    * 구매자 게이지 그래프 : 총 방문자 중 구매자의 비율을 게이지로 나타냄 
        => 연간 누적으로 계산 (화면기획에 게이지 카드 상단에 YYYY표시가 있는 것으로 보아 년간 누적으로 예상)

    필요 기능 : 
    [1] YoY 비교 기능  : 월별방문자, 연간방문자, 객단가, 평균체류시간 작년 대비 비교하여 증감률(%)을 나타낸다. 증감률이 양수이면 초록색 음수이면 붉은색으로 표기 
    [2] 게이지 그래프 : 첫방문자그래프와 구매자 그래프는 총 방문자 대비 얼마나 비율이 차지되는지 확인 필요
    [3] MoM비교 기능 : 일별방문자, 
    


/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(                    CURRENT_DATE - INTERVAL '1' DAY                       AS VARCHAR) AS BASE_DT           /* 기준일자 (어제)        */
              ,CAST(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' MONTH AS VARCHAR) AS BASE_DT_MOM       /* 기준일자 (어제)   -1월 */
              ,CAST(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR  AS VARCHAR) AS BASE_DT_YOY       /* 기준일자 (어제)   -1년 */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_MNTH      /* 기준월의 1일           */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' YEAR)                     AS VARCHAR) AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
              ,CAST(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
              ,CAST(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' YEAR)                     AS VARCHAR) AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
    ), WT_VIST_DAY AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 일방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_MNTH AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 월방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_YEAR AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4)))  AS VIST_CNT  /* 연방문자수   */
              ,SUM(CAST(NEW_VISITORS          AS DECIMAL(20,4)))  AS FRST_CNT  /* 연첫방문자수 */
              ,SUM(CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4)))  AS PAID_CNT  /* 연구매자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_CUST_DAY AS
    (
        SELECT SUM(CAST(PAYMENT_AMOUNT                                                                                                           AS DECIMAL(20,4))) AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,SUM(CAST(PAYMENT_AMOUNT * (SELECT MAX(X.EXRATE) FROM DASH.OVER_MACRO_EX_KRW_CNY X WHERE X.DATE = REPLACE(A.STATISTICS_DATE, '-')) AS DECIMAL(20,4))) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,SUM(CAST(NUMBER_OF_PAID_BUYERS                                                                                                    AS DECIMAL(20,4))) AS PAID_CNT      /* 일구매자수          */
              ,SUM(CAST(AVERAGE_LENGTH_OF_STAY                                                                                                   AS DECIMAL(20,4))) AS STAY_TIME     /* 일평균 체류시간     */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_DAY_MOM AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 일방문자수 - MoM */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_MOM FROM WT_WHERE)
    ), WT_VIST_MNTH_YOY AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 월방문자수 - YoY */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_YEAR_YOY AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4)))  AS VIST_CNT  /* 연방문자수   - YoY */
              ,SUM(CAST(NEW_VISITORS          AS DECIMAL(20,4)))  AS FRST_CNT  /* 연첫방문자수 - YoY */
              ,SUM(CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4)))  AS PAID_CNT  /* 연구매자수   - YoY */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_CUST_DAY_YOY AS
    (
        SELECT SUM(CAST(PAYMENT_AMOUNT                                                                                                           AS DECIMAL(20,4))) AS SALE_AMT_RMB  /* 일매출금액      YoY - 위안화 */
              ,SUM(CAST(PAYMENT_AMOUNT * (SELECT MAX(X.EXRATE) FROM DASH.OVER_MACRO_EX_KRW_CNY X WHERE X.DATE = REPLACE(A.STATISTICS_DATE, '-')) AS DECIMAL(20,4))) AS SALE_AMT_KRW  /* 일매출금액      YoY - 원화   */
              ,SUM(CAST(NUMBER_OF_PAID_BUYERS                                                                                                    AS DECIMAL(20,4))) AS PAID_CNT      /* 일구매자수      YoY          */
              ,SUM(CAST(AVERAGE_LENGTH_OF_STAY                                                                                                   AS DECIMAL(20,4))) AS STAY_TIME     /* 일평균 체류시간 YoY          */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT                                                                                AS VIST_CNT           /* 전일 방문자 수       */
              ,B.VIST_CNT                                                                                AS VIST_CNT_MNTH      /* 당월 방문자 수       */
              ,C.VIST_CNT                                                                                AS VIST_CNT_YEAR      /* 당해 방문자 수       */
              ,CASE WHEN COALESCE(D.PAID_CNT, 0) = 0 THEN 0    ELSE D.SALE_AMT_RMB / D.PAID_CNT      END AS CUST_AMT_RMB       /* 객단가      - 위안화 */
              ,CASE WHEN COALESCE(D.PAID_CNT, 0) = 0 THEN 0    ELSE D.SALE_AMT_KRW / D.PAID_CNT      END AS CUST_AMT_KRW       /* 객단가      - 원화   */
              ,D.STAY_TIME                                                                               AS STAY_TIME          /* 평균 체류시간        */
              ,C.FRST_CNT                                                                                AS FRST_CNT           /* 첫 방문자 수         */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.FRST_CNT    / C.VIST_CNT * 100 END AS FRST_RATE          /* 첫 방문자 비율       */
              ,C.PAID_CNT                                                                                AS PAID_CNT           /* 구매자 수            */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.PAID_CNT    / C.VIST_CNT * 100 END AS PAID_RATE          /* 구매자 비율          */
              ,E.VIST_CNT                                                                                AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
              ,F.VIST_CNT                                                                                AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
              ,G.VIST_CNT                                                                                AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
              ,CASE WHEN COALESCE(H.PAID_CNT, 0) = 0 THEN NULL ELSE H.SALE_AMT_RMB / H.PAID_CNT      END AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
              ,CASE WHEN COALESCE(H.PAID_CNT, 0) = 0 THEN NULL ELSE H.SALE_AMT_KRW / H.PAID_CNT      END AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
              ,H.STAY_TIME                                                                               AS STAY_TIME_YOY      /* 평균 체류시간 YoY    */
              ,G.FRST_CNT                                                                                AS FRST_CNT_YOY       /* 첫 방문자 수   YoY   */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.FRST_CNT / G.VIST_CNT * 100    END AS FRST_RATE_YOY      /* 첫 방문자 비율 YoY   */
              ,G.PAID_CNT                                                                                AS PAID_CNT_YOY       /* 구매자 수   YoY      */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.PAID_CNT / G.VIST_CNT * 100    END AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
          FROM WT_VIST_DAY       A
              ,WT_VIST_MNTH      B
              ,WT_VIST_YEAR      C
              ,WT_CUST_DAY       D
              ,WT_VIST_DAY_MOM   E
              ,WT_VIST_MNTH_YOY  F
              ,WT_VIST_YEAR_YOY  G
              ,WT_CUST_DAY_YOY   H
    )
    SELECT CAST(VIST_CNT                                                                   AS DECIMAL(20,0)) AS VIST_CNT           /* 전일 방문자 수         */
          ,CAST(VIST_CNT_MNTH                                                              AS DECIMAL(20,0)) AS VIST_CNT_MNTH      /* 당월 방문자 수         */
          ,CAST(VIST_CNT_YEAR                                                              AS DECIMAL(20,0)) AS VIST_CNT_YEAR      /* 당해 방문자 수         */
          ,CAST(CUST_AMT_RMB                                                               AS DECIMAL(20,2)) AS CUST_AMT_RMB       /* 객단가        - 위안화 */
          ,CAST(CUST_AMT_KRW                                                               AS DECIMAL(20,2)) AS CUST_AMT_KRW       /* 객단가        - 원화   */
          ,CAST(STAY_TIME                                                                  AS DECIMAL(20,2)) AS STAY_TIME          /* 평균 체류시간          */
          ,CAST(FRST_CNT                                                                   AS DECIMAL(20,0)) AS FRST_CNT           /* 첫 방문자 수           */
          ,CAST(FRST_RATE                                                                  AS DECIMAL(20,2)) AS FRST_RATE          /* 첫 방문자 비율         */
          ,CAST(PAID_CNT                                                                   AS DECIMAL(20,0)) AS PAID_CNT           /* 구매자 수              */
          ,CAST(PAID_RATE                                                                  AS DECIMAL(20,2)) AS PAID_RATE          /* 구매자 비율            */

          ,CAST((VIST_CNT      - COALESCE(VIST_CNT_MOM     , 0)) / VIST_CNT_MOM      * 100 AS DECIMAL(20,2)) AS VIST_RATE          /* 전일 방문자 수 증감률  */
          ,CAST((VIST_CNT_MNTH - COALESCE(VIST_CNT_MNTH_YOY, 0)) / VIST_CNT_MNTH_YOY * 100 AS DECIMAL(20,2)) AS VIST_RATE_MNTH     /* 전일 방문자 수 증감률  */
          ,CAST((VIST_CNT_YEAR - COALESCE(VIST_CNT_YEAR_YOY, 0)) / VIST_CNT_YEAR_YOY * 100 AS DECIMAL(20,2)) AS VIST_RATE_YEAR     /* 당해 방문자 수 증감률  */
          ,CAST((CUST_AMT_RMB  - COALESCE(CUST_AMT_YOY_RMB , 0)) / CUST_AMT_YOY_RMB  * 100 AS DECIMAL(20,2)) AS CUST_RATE_RMB      /* 객단가 증감률 - 위안화 */
          ,CAST((CUST_AMT_KRW  - COALESCE(CUST_AMT_YOY_KRW , 0)) / CUST_AMT_YOY_KRW  * 100 AS DECIMAL(20,2)) AS CUST_RATE_KRW      /* 객단가 증감률 - 원화   */
          ,CAST((STAY_TIME     - COALESCE(STAY_TIME_YOY    , 0)) / STAY_TIME_YOY     * 100 AS DECIMAL(20,2)) AS STAY_RATE          /* 평균 체류시간 증감률   */

          ,CAST(VIST_CNT_MOM                                                               AS DECIMAL(20,0)) AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
          ,CAST(VIST_CNT_MNTH_YOY                                                          AS DECIMAL(20,0)) AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
          ,CAST(VIST_CNT_YEAR_YOY                                                          AS DECIMAL(20,0)) AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
          ,CAST(CUST_AMT_YOY_RMB                                                           AS DECIMAL(20,2)) AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
          ,CAST(CUST_AMT_YOY_KRW                                                           AS DECIMAL(20,2)) AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
          ,CAST(STAY_TIME_YOY                                                              AS DECIMAL(20,2)) AS STAY_TIME_YOY      /* 평균 체류시간 YoY    */
          ,CAST(FRST_CNT_YOY                                                               AS DECIMAL(20,0)) AS FRST_CNT_YOY       /* 첫 방문자 수   YoY   */
          ,CAST(FRST_RATE_YOY                                                              AS DECIMAL(20,2)) AS FRST_RATE_YOY      /* 첫 방문자 비율 YoY   */
          ,CAST(PAID_CNT_YOY                                                               AS DECIMAL(20,0)) AS PAID_CNT_YOY       /* 구매자 수   YoY      */
          ,CAST(PAID_RATE_YOY                                                              AS DECIMAL(20,2)) AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
      FROM WT_BASE


/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(                    CURRENT_DATE - INTERVAL '1' DAY                       AS VARCHAR) AS BASE_DT           /* 기준일자 (어제)        */
              ,CAST(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' MONTH AS VARCHAR) AS BASE_DT_MOM       /* 기준일자 (어제)   -1월 */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_MNTH      /* 기준월의 1일           */
              ,CAST(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                     AS VARCHAR) AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
    ), WT_VIST_DAY AS
    (
        SELECT 'DAY'                                           AS CHRT_KEY
              ,STATISTICS_DATE                                 AS X_DT
              ,SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 일방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT BASE_DT_MOM FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_MNTH AS
    (
        SELECT 'MNTH'                                          AS CHRT_KEY
              ,STATISTICS_DATE                                 AS X_DT
              ,SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)))  AS VIST_CNT  /* 월방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_YEAR AS
    (
        SELECT 'YEAR'                                              AS CHRT_KEY
              ,DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%Y-%m') AS X_DT
              ,SUM(CAST(NUMBER_OF_VISITORS      AS DECIMAL(20,4))) AS VIST_CNT  /* 연방문자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%Y-%m')
    ), WT_BASE AS
    (
        SELECT A.CHRT_KEY                /* DAY:전일 방문자 수 */
              ,A.X_DT                    /* 일자(x축)          */
              ,A.VIST_CNT AS Y_VAL_VIST  /* 방문자 수          */
          FROM WT_VIST_DAY A
     UNION ALL
        SELECT B.CHRT_KEY                /* MNTH:당일 방문자 수 */
              ,B.X_DT                    /* 일자(x축)           */
              ,B.VIST_CNT AS Y_VAL_VIST  /* 방문자 수           */
          FROM WT_VIST_MNTH B
     UNION ALL
        SELECT C.CHRT_KEY                /* YEAR:당일 방문자 수 */
              ,C.X_DT                    /* 일자(x축)           */
              ,C.VIST_CNT AS Y_VAL_VIST  /* 방문자 수           */
          FROM WT_VIST_YEAR C
    )
    SELECT CHRT_KEY                         /* DAY:전일 방문자 수, MNTH:당일 방문자 수, YEAR:당일 방문자 수 */
          ,X_DT                             /* 일자(x축) */
          ,ROUND(Y_VAL_VIST) AS Y_VAL_VIST  /* 방문자 수 */
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT



2. 방문자수 시계열 그래프
    * 방문자수 전체에 대한 시계열 그래프 : 선택한 기간에 대한 방문자수의 전체에 대한 시계열 그래프 

    필요기능 : 
    [1] 다운로드 : 그래프의 DB다운로드 할 수 있도록 
    [2] 기간선택 : 타임 슬라이드로 기간 선택 필요 
    [3] 상단 정보기능 : 기간, 당해 누적방문자, 전년도 누적방문자, 증감률
    [4] 하단 데이터 표 : 1월부터 12월까지, 올해, 전년도, YoY, MoM 표기 
    [5] 일별, 주별, 월별 선택기능


/* 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY                    ) AS VARCHAR)  AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(                   CURRENT_DATE - INTERVAL '1' DAY                      AS VARCHAR)  AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR) AS VARCHAR)  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(                   CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR  AS VARCHAR)  AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
    ), WT_SUM AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4))) AS VIST_CNT  /* 방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4))) AS VIST_CNT  /* 방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT AS VIST_CNT      /* 당해 방문자수  */
              ,B.VIST_CNT AS VIST_CNT_YOY  /* 전해 방문자수  */
              ,(A.VIST_CNT - COALESCE(B.VIST_CNT, 0)) / B.VIST_CNT * 100.0000 AS VIST_RATE  /* 방문자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT CAST(VIST_CNT     AS DECIMAL(20,0)) AS VIST_CNT      /* 당해 방문자수    */
          ,CAST(VIST_CNT_YOY AS DECIMAL(20,0)) AS VIST_CNT_YOY  /* 전해 방문자수    */
          ,CAST(VIST_RATE    AS DECIMAL(20,2)) AS VIST_RATE     /* 방문자수 증감률  */
      FROM WT_BASE



/* 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)) AS VIST_CNT  /* 방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,CAST(    SUM(VIST_CNT)                                                                           AS DECIMAL(20,2)) AS VIST_CNT       /* 방문자수                  */
              ,CAST(AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,CAST(AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
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
          ,ROUND(Y_VAL) AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT


/* 2. 방문자수 시계열 그래프 - 하단표 SQL                           */
/*    오늘(2023.03.04)일 경우 => 기준일 : 2023.03.03              */
/*                               올해   : 2023.01.01 ~ 2023.12.31 */
/*                               전년도 : 2022.01.01 ~ 2022.12.31 */
/*    올해, 전년도는 방문자 수라서 소숫점이 없게 표시하고         */
/*    YoY, MoM는 증감률이라서 소숫점 2자리까지 표시하도록         */
/*    VARCHAR로 형변환하여 리턴함.                                */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY                                        ) AS VARCHAR)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY) + INTERVAL '1' YEAR - INTERVAL '1' DAY  AS VARCHAR)  AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR                   ) AS VARCHAR)  AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY) + INTERVAL '0' YEAR - INTERVAL '1' DAY  AS VARCHAR)  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1' DAY                    )                      AS VARCHAR)  AS THIS_YEAR  /* 기준일의 연도            */
              ,CAST(EXTRACT(YEAR FROM CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR)                      AS VARCHAR)  AS LAST_YEAR  /* 기준일의 연도       -1년 */
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
              ,CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)) AS VIST_CNT  /* 방문자수 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS AS DECIMAL(20,4)) AS VIST_CNT   /* 방문자수 YoY */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_01 /* 01월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_02 /* 02월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_03 /* 03월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_04 /* 04월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_05 /* 05월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_06 /* 06월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_07 /* 07월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_08 /* 08월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_09 /* 09월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_10 /* 10월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_11 /* 11월 방문자수 */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_12 /* 12월 방문자수 */
          FROM WT_CAST A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_01 /* 01월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_02 /* 02월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_03 /* 03월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_04 /* 04월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_05 /* 05월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_06 /* 06월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_07 /* 07월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_08 /* 08월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_09 /* 09월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_10 /* 10월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_11 /* 11월 방문자수 YoY */
              ,CAST(SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN VIST_CNT END) AS DECIMAL(20,4)) AS VIST_CNT_12 /* 12월 방문자수 YoY */
          FROM WT_CAST_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_01, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_01, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_01, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_01  /* 01월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_02, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_02, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_02, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_01, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_02  /* 02월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_03, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_03, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_03, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_02, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_03  /* 03월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_04, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_04, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_04, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_03, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_04  /* 04월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_05, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_05, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_05, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_04, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_05  /* 05월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_06, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_06, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_06, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_05, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_06  /* 06월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_07, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_07, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_07, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_06, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_07  /* 07월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_08, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_08, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_08, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_07, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_08  /* 08월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_09, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_09, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_09, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_08, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_09  /* 09월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_10, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_10, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_10, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_09, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_10  /* 10월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_11, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_11, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_11, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_10, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_11  /* 11월 방문자수 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN ROUND(VIST_CNT_12, 2)
                  WHEN A.SORT_KEY = 3
                  THEN ROUND((LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_12, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_12, 2) OVER(ORDER BY A.SORT_KEY) * 100, 2)
                  WHEN A.SORT_KEY = 4
                  THEN ROUND((LAG(VIST_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(VIST_CNT_11, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(VIST_CNT_12, 3) OVER(ORDER BY A.SORT_KEY) * 100, 2)
               END AS VIST_CNT_12  /* 12월 방문자수 */

          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_01 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_01 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_01   /* 01월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_02 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_02 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_02   /* 02월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_03 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_03 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_03   /* 03월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_04 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_04 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_04   /* 04월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_05 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_05 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_05   /* 05월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_06 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_06 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_06   /* 06월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_07 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_07 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_07   /* 07월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_08 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_08 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_08   /* 08월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_09 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_09 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_09   /* 09월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_10 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_10 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_10   /* 10월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_11 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_11 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_11   /* 11월 방문자수 */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2) THEN CAST(CAST(VIST_CNT_12 AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(VIST_CNT_12 AS DECIMAL(20,2)) AS VARCHAR) END, '') AS VIST_CNT_12   /* 12월 방문자수 */
      FROM WT_BASE
  ORDER BY SORT_KEY


3. 요일/시간 방문자수 히트맵(선택된 기간에 따라 확인)
    * 방문자수에 대한 요일/시간 히트맵 : 선택한 기간에 따라 방문자수가 몇시에 많이 들어오는지 히트맵으로 보여줘야함 

    필요기능 : 
    [1] 기간선택 : 2번의 시계열그래프의 타임슬라이드 이동시 변화해야함 
    [2] 해당기간의 매출과 상관관계 결과가 그래프 상단에 표기되었으면함  예) 해당기간 매출과의 상관관계 95% 
        => 매출 상관관계 Logic은???

/* 3. 요일/시간 방문자수량 히트맵 - 히트맵 SQL */
/*    조회결과 가공방법 방문자수 ==> [[WEEK_NO, HOUR_NO, VIST_CNT], [WEEK_NO, HOUR_NO, VIST_CNT], ...] */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a')        AS WEEK_ID
              ,CAST(STATISTICS_HOURS                 AS DECIMAL(20,0)) AS HOUR_NO
              ,CAST(REPLACE(NUMBER_OF_VISITORS, ',') AS DECIMAL(20,0)) AS VIST_CNT  /* 방문자수 */
          FROM DASH.OVER_DGT_SHOP_BY_HOUR A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT CASE
                 WHEN WEEK_ID = 'Sun' THEN 6
                 WHEN WEEK_ID = 'Mon' THEN 5
                 WHEN WEEK_ID = 'Tue' THEN 4
                 WHEN WEEK_ID = 'Wed' THEN 3
                 WHEN WEEK_ID = 'Thu' THEN 2
                 WHEN WEEK_ID = 'Fri' THEN 1
                 WHEN WEEK_ID = 'Sat' THEN 0
               END WEEK_NO
              ,HOUR_NO
              ,VIST_CNT  /* 방문자수 */
          FROM WT_CAST A
    )
   SELECT WEEK_NO
         ,HOUR_NO
         ,CAST(SUM(VIST_CNT) AS DECIMAL(20,0)) AS VIST_CNT /* 방문자수 */
     FROM WT_BASE A
 GROUP BY WEEK_NO
         ,HOUR_NO
 ORDER BY WEEK_NO
         ,HOUR_NO



4. 방문자 첫방문/재방문 그래프
    트랜드를 보는것이 중요하므로 시계열 그래프로 봐야함 

    들어가야하는 정보 
    * 방문자 중 첫방문자의 비율에 대한 시계열그래프 :  LINE그래프로 선택한 기간에 방문자 수가 나와야하고 
    * 첫방문자와 구매자 비율은 하단의 바그래프로  

    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함  
    [2] y축 2개 : 바그래프는 왼쪽, 선그래프는 오른쪽에 축이 위치
    [3] 일별, 주별, 월별 주기 선택 기능
    [4] 하단에 데이터 테이블로 월별 첫방문과 구매자 비중이 나왔으면 한다
    [5] 다운로드 기능 
    [6] 물음표 모달


/* 4. 방문자 첫방문/재방문 그래프 - 방문자 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
              ,CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4))  AS VIST_CNT  /* 방문자수   */
              ,CAST(NEW_VISITORS          AS DECIMAL(20,4))  AS FRST_CNT  /* 첫방문자수 */
              ,CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4))  AS PAID_CNT  /* 구매자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,CAST(    SUM(VIST_CNT)                                                                           AS DECIMAL(20,4)) AS VIST_CNT       /* 방문자수                  */
              ,CAST(AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,4)) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,CAST(AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,4)) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
              ,CAST(    SUM(FRST_CNT)                                                                           AS DECIMAL(20,4)) AS FRST_CNT       /* 첫방문자수                */
              ,CAST(    SUM(PAID_CNT)                                                                           AS DECIMAL(20,4)) AS PAID_CNT       /* 구매자수                  */
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
          /*,CAST(Y_VAL AS DECIMAL(20,0)) AS Y_VAL*/
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2, 3) THEN CAST(CAST(Y_VAL AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT


/* 4. 방문자 첫방문/재방문 그래프 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY                                        ) AS VARCHAR)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY) + INTERVAL '1' YEAR - INTERVAL '1' DAY  AS VARCHAR)  AS TO_DT      /* 기준일의 12월 31일       */
    ), WT_COPY AS
    (
        SELECT 1        AS SORT_KEY
              ,'첫방문' AS ROW_TITL
     UNION ALL
        SELECT 2        AS SORT_KEY
              ,'구매자' AS ROW_TITL
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4))  AS VIST_CNT  /* 방문자수   */
              ,CAST(NEW_VISITORS          AS DECIMAL(20,4))  AS FRST_CNT  /* 첫방문자수 */
              ,CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4))  AS PAID_CNT  /* 구매자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) AS COL_MNTH
              ,CAST(SUM(VIST_CNT)              AS DECIMAL(20,4)) AS VIST_CNT  /* 방문자수   */
              ,CAST(SUM(FRST_CNT)              AS DECIMAL(20,4)) AS FRST_CNT  /* 첫방문자수 */
              ,CAST(SUM(PAID_CNT)              AS DECIMAL(20,4)) AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE))
    ), WT_RATE AS
    (
        SELECT COL_MNTH       /* 월       */
              ,VIST_CNT       /* 방문자수 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE FRST_CNT / VIST_CNT * 100 END AS FRST_RATE  /* 첫 방문자 비율 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE PAID_CNT / VIST_CNT * 100 END AS PAID_RATE  /* 구매자    비율 */
          FROM WT_SUM A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 01 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 01 THEN PAID_RATE  END) AS COL_VAL_01
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 02 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 02 THEN PAID_RATE  END) AS COL_VAL_02
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 03 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 03 THEN PAID_RATE  END) AS COL_VAL_03
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 04 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 04 THEN PAID_RATE  END) AS COL_VAL_04
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 05 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 05 THEN PAID_RATE  END) AS COL_VAL_05
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 06 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 06 THEN PAID_RATE  END) AS COL_VAL_06
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 07 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 07 THEN PAID_RATE  END) AS COL_VAL_07
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 08 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 08 THEN PAID_RATE  END) AS COL_VAL_08
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 09 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 09 THEN PAID_RATE  END) AS COL_VAL_09
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 10 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 10 THEN PAID_RATE  END) AS COL_VAL_10
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 11 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 11 THEN PAID_RATE  END) AS COL_VAL_11
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = 12 THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = 12 THEN PAID_RATE  END) AS COL_VAL_12
          FROM WT_COPY A 
              ,WT_RATE B
      GROUP BY SORT_KEY
              ,ROW_TITL
    )
    SELECT ROW_TITL
          ,CAST(COL_VAL_01 AS DECIMAL(20,2)) AS COL_VAL_01
          ,CAST(COL_VAL_02 AS DECIMAL(20,2)) AS COL_VAL_02
          ,CAST(COL_VAL_03 AS DECIMAL(20,2)) AS COL_VAL_03
          ,CAST(COL_VAL_04 AS DECIMAL(20,2)) AS COL_VAL_04
          ,CAST(COL_VAL_05 AS DECIMAL(20,2)) AS COL_VAL_05
          ,CAST(COL_VAL_06 AS DECIMAL(20,2)) AS COL_VAL_06
          ,CAST(COL_VAL_07 AS DECIMAL(20,2)) AS COL_VAL_07
          ,CAST(COL_VAL_08 AS DECIMAL(20,2)) AS COL_VAL_08
          ,CAST(COL_VAL_09 AS DECIMAL(20,2)) AS COL_VAL_09
          ,CAST(COL_VAL_10 AS DECIMAL(20,2)) AS COL_VAL_10
          ,CAST(COL_VAL_11 AS DECIMAL(20,2)) AS COL_VAL_11
          ,CAST(COL_VAL_12 AS DECIMAL(20,2)) AS COL_VAL_12
      FROM WT_BASE
  ORDER BY SORT_KEY



5. 요일별 첫방문 구매자 비중
    * 요일별 첫방문과 구매자 비중에 대한 토네이도 그래프 
    왼쪽에는 첫방문, 오른쪽에는 구매자 비중 
    둘다 비율 그래프 이며, 중앙에 축은 요일 

    필요기능 : 
    [1] 기간선택 : 왼쪽 그래프에서 선택한 기간에 연동되어 분석
    [2] 하단데이터 필요 : 요일별, 첫방문, 구매자 비율 나오게 끔
    [3] 물음표 모달


/* 5. 요일별 첫방문 구매자 비중 - 토네이도 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                 AS SORT_KEY
              ,'FRST'            AS L_LGND_ID  /* 첫 방문 */ 
              ,'첫 방문'         AS L_LGND_NM 
     UNION ALL
        SELECT 2                 AS SORT_KEY
              ,'PAID'            AS L_LGND_ID  /* 구매자 비중 */ 
              ,'구매자 비중'     AS L_LGND_NM 
    ), WT_WEEK AS
    (
        SELECT 1 AS WEEK_NO, 'Mon' AS WEEK_ID UNION ALL
        SELECT 2 AS WEEK_NO, 'Tue' AS WEEK_ID UNION ALL
        SELECT 3 AS WEEK_NO, 'Wed' AS WEEK_ID UNION ALL
        SELECT 4 AS WEEK_NO, 'Thu' AS WEEK_ID UNION ALL
        SELECT 5 AS WEEK_NO, 'Fri' AS WEEK_ID UNION ALL
        SELECT 6 AS WEEK_NO, 'Sat' AS WEEK_ID UNION ALL
        SELECT 7 AS WEEK_NO, 'Sun' AS WEEK_ID 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4))  AS VIST_CNT  /* 방문자수   */
              ,CAST(NEW_VISITORS          AS DECIMAL(20,4))  AS FRST_CNT  /* 첫방문자수 */
              ,CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4))  AS PAID_CNT  /* 구매자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a') AS WEEK_ID
              ,CAST(SUM(VIST_CNT) AS DECIMAL(20,4))             AS VIST_CNT  /* 방문자수   */
              ,CAST(SUM(FRST_CNT) AS DECIMAL(20,4))             AS FRST_CNT  /* 첫방문자수 */
              ,CAST(SUM(PAID_CNT) AS DECIMAL(20,4))             AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a')
    ), WT_RATE AS
    (
        SELECT WEEK_ID
              ,VIST_CNT       /* 방문자수 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE FRST_CNT / VIST_CNT * 100 END AS FRST_RATE  /* 첫 방문자 비율 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE PAID_CNT / VIST_CNT * 100 END AS PAID_RATE  /* 구매자    비율 */
          FROM WT_SUM A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,B.WEEK_NO
              ,B.WEEK_ID
              ,CASE 
                 WHEN L_LGND_ID = 'FRST' THEN FRST_RATE
                 WHEN L_LGND_ID = 'PAID' THEN PAID_RATE
               END AS Y_VAL  /* FRST:첫 방문자 비율, PAID:구매자 비율 */
          FROM WT_COPY A
              ,WT_WEEK B LEFT OUTER JOIN WT_RATE C ON (B.WEEK_ID = C.WEEK_ID)
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,WEEK_ID                      AS Y_WEEK
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS X_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,WEEK_NO


/* 5. 요일별 첫방문 구매자 비중 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY                                        ) AS VARCHAR)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(DATE_TRUNC('YEAR', CURRENT_DATE - INTERVAL '1' DAY) + INTERVAL '1' YEAR - INTERVAL '1' DAY  AS VARCHAR)  AS TO_DT      /* 기준일의 12월 31일       */
    ), WT_COPY AS
    (
        SELECT 1        AS SORT_KEY
              ,'첫방문' AS ROW_TITL
     UNION ALL
        SELECT 2        AS SORT_KEY
              ,'구매자' AS ROW_TITL
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS    AS DECIMAL(20,4))  AS VIST_CNT  /* 방문자수   */
              ,CAST(NEW_VISITORS          AS DECIMAL(20,4))  AS FRST_CNT  /* 첫방문자수 */
              ,CAST(NUMBER_OF_PAID_BUYERS AS DECIMAL(20,4))  AS PAID_CNT  /* 구매자수   */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a')  AS WEEK_ID
              ,CAST(SUM(VIST_CNT)              AS DECIMAL(20,4)) AS VIST_CNT  /* 방문자수   */
              ,CAST(SUM(FRST_CNT)              AS DECIMAL(20,4)) AS FRST_CNT  /* 첫방문자수 */
              ,CAST(SUM(PAID_CNT)              AS DECIMAL(20,4)) AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a')
    ), WT_RATE AS
    (
        SELECT WEEK_ID        /* 요일     */
              ,VIST_CNT       /* 방문자수 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE FRST_CNT / VIST_CNT * 100 END AS FRST_RATE  /* 첫 방문자 비율 */
              ,CASE WHEN COALESCE(VIST_CNT, 0) = 0 THEN 0 ELSE PAID_CNT / VIST_CNT * 100 END AS PAID_RATE  /* 구매자    비율 */
          FROM WT_SUM A
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Mon' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Mon' THEN PAID_RATE  END) AS COL_VAL_MON
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Tue' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Tue' THEN PAID_RATE  END) AS COL_VAL_TUE
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Wed' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Wed' THEN PAID_RATE  END) AS COL_VAL_WED
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Thu' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Thu' THEN PAID_RATE  END) AS COL_VAL_THU
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Fri' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Fri' THEN PAID_RATE  END) AS COL_VAL_FRI
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Sat' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Sat' THEN PAID_RATE  END) AS COL_VAL_SAT
              ,SUM(CASE WHEN SORT_KEY = 1 AND WEEK_ID = 'Sun' THEN FRST_RATE WHEN SORT_KEY = 2 AND WEEK_ID = 'Sun' THEN PAID_RATE  END) AS COL_VAL_SUN
          FROM WT_COPY A 
              ,WT_RATE B
      GROUP BY SORT_KEY
              ,ROW_TITL
    )
    SELECT ROW_TITL
          ,CAST(COL_VAL_MON AS DECIMAL(20,2)) AS COL_VAL_MON
          ,CAST(COL_VAL_TUE AS DECIMAL(20,2)) AS COL_VAL_TUE
          ,CAST(COL_VAL_WED AS DECIMAL(20,2)) AS COL_VAL_WED
          ,CAST(COL_VAL_THU AS DECIMAL(20,2)) AS COL_VAL_THU
          ,CAST(COL_VAL_FRI AS DECIMAL(20,2)) AS COL_VAL_FRI
          ,CAST(COL_VAL_SAT AS DECIMAL(20,2)) AS COL_VAL_SAT
          ,CAST(COL_VAL_SUN AS DECIMAL(20,2)) AS COL_VAL_SUN
      FROM WT_BASE
  ORDER BY SORT_KEY



6. 방문자 평균체류시간 그래프
    * 방문자 평균체류 비중의 일별 시계열그래프 : 방문자 평균체류시간이 일별로 어떻게 변화하는지 필요하다 
    * 작년기준 그래프도 함께 포함되어야함 
        => 선택한 기간에 따른 작년 Line 표시
    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함

/* 6. 방문자 평균체류시간 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT CAST(CAST((SELECT FR_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR AS VARCHAR) AS FR_DT
              ,CAST(CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR AS VARCHAR) AS TO_DT
    ), WT_CAST AS
    (
        SELECT 1      AS SORT_KEY
              ,'VIST' AS L_LGND_ID
              ,'올해' AS L_LGND_NM 
              ,STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS      AS DECIMAL(20,0))  AS VIST_CNT   /* 방문자수     */
              ,CAST(AVERAGE_LENGTH_OF_STAY  AS DECIMAL(20,2))  AS STAY_TIME  /* 평균체류시간 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 2          AS SORT_KEY
              ,'VIST_YOY' AS L_LGND_ID
              ,'작년'     AS L_LGND_NM 
              ,STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS      AS DECIMAL(20,0))  AS VIST_CNT   /* 방문자수     */
              ,CAST(AVERAGE_LENGTH_OF_STAY  AS DECIMAL(20,2))  AS STAY_TIME  /* 평균체류시간 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,STATISTICS_DATE AS X_DT
          ,STAY_TIME       AS Y_VAL
      FROM WT_CAST A
  ORDER BY SORT_KEY
          ,STATISTICS_DATE



7. 요일별 방문자 평균체류시간 그래프
    * 요일별 방문자 평균체류시간 그래프

    필요기능 : 
    [1] 기간은 좌측 6번 그래프와 연동되도록 해야함

/* 7. 요일별 방문자 평균체류시간 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,CAST(NUMBER_OF_VISITORS      AS DECIMAL(20,0))  AS VIST_CNT   /* 방문자수     */
              ,CAST(AVERAGE_LENGTH_OF_STAY  AS DECIMAL(20,4))  AS STAY_TIME  /* 평균체류시간 */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_AVG AS
    (
        SELECT DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a') AS WEEK_ID
              ,CAST(AVG(STAY_TIME) AS DECIMAL(20,4))            AS STAY_TIME  /* 평균체류시간 */
          FROM WT_CAST A
      GROUP BY DATE_FORMAT(CAST(STATISTICS_DATE AS DATE), '%a')
    ), WT_BASE AS
    (
        SELECT CASE
                 WHEN WEEK_ID = 'Mon' THEN 1
                 WHEN WEEK_ID = 'Tue' THEN 2
                 WHEN WEEK_ID = 'Wed' THEN 3
                 WHEN WEEK_ID = 'Thu' THEN 4
                 WHEN WEEK_ID = 'Fri' THEN 5
                 WHEN WEEK_ID = 'Sat' THEN 6
                 WHEN WEEK_ID = 'Sun' THEN 7
               END SORT_KEY
              ,WEEK_ID
              ,CAST(STAY_TIME AS DECIMAL(20,2)) AS STAY_TIME
          FROM WT_AVG
    )
    SELECT SORT_KEY
          ,WEEK_ID   AS X_WEEK
          ,STAY_TIME AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY



8. 구매자 객단가 그래프
    * 구매자 객단가 일별 시계열그래프 : 구매자 객단가가 일별로 어떻게 변화하는지 필요하다
    객단가는 라인그래프로 들어가고 
    * 바그래프로 구매자수가 들어가야함 
    
    * 작년기준 그래프도 함께 포함되어야함 
    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함
    [2] 일별/주별/월별 선택
    [3] 다운로드 기능


/* 8. 구매자 객단가 그래프 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ?  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,?  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT CAST(CAST((SELECT FR_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR AS VARCHAR) AS FR_DT
              ,CAST(CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR AS VARCHAR) AS TO_DT
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'PAID'                  AS L_LGND_ID  /* 구매자수 */ 
              ,'구매자수 - 올해'       AS L_LGND_NM 
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'CUST'                  AS L_LGND_ID  /* 일 객단가 */ 
              ,'일 객단가 - 올해'      AS L_LGND_NM 
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'CUST_WEEK'             AS L_LGND_ID  /* 주 객단가 */ 
              ,'주 객단가 - 올해'      AS L_LGND_NM 
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'CUST_MNTH'             AS L_LGND_ID  /* 월 객단가 */ 
              ,'월 객단가 - 올해'      AS L_LGND_NM 
    ), WT_COPY_YOY AS
    (
        SELECT 5                       AS SORT_KEY
              ,'PAID_YOY'              AS L_LGND_ID  /* 구매자수  - YoY */ 
              ,'구매자수 - 작년'       AS L_LGND_NM 
     UNION ALL
        SELECT 6                       AS SORT_KEY
              ,'CUST_YOY'              AS L_LGND_ID  /* 일 객단가 - YoY */ 
              ,'일 객단가 - 작년'      AS L_LGND_NM 
     UNION ALL
        SELECT 7                       AS SORT_KEY
              ,'CUST_WEEK_YOY'         AS L_LGND_ID  /* 주 객단가 - YoY */ 
              ,'주 객단가 - 작년'      AS L_LGND_NM 
     UNION ALL
        SELECT 8                       AS SORT_KEY
              ,'CUST_MNTH_YOY'         AS L_LGND_ID  /* 월 객단가 - YoY */
              ,'월 객단가 - 작년'      AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                                                                                                           AS DECIMAL(20,4)) AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,CAST(PAYMENT_AMOUNT * (SELECT MAX(X.EXRATE) FROM DASH.OVER_MACRO_EX_KRW_CNY X WHERE X.DATE = REPLACE(A.STATISTICS_DATE, '-')) AS DECIMAL(20,4)) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,CAST(NUMBER_OF_PAID_BUYERS                                                                                                    AS DECIMAL(20,4)) AS PAID_CNT      /* 일구매자수          */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                                                                                                           AS DECIMAL(20,4)) AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,CAST(PAYMENT_AMOUNT * (SELECT MAX(X.EXRATE) FROM DASH.OVER_MACRO_EX_KRW_CNY X WHERE X.DATE = REPLACE(A.STATISTICS_DATE, '-')) AS DECIMAL(20,4)) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,CAST(NUMBER_OF_PAID_BUYERS                                                                                                    AS DECIMAL(20,4)) AS PAID_CNT      /* 일구매자수          */
          FROM DASH.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
    ), WT_CALC AS
    (
        SELECT STATISTICS_DATE
              ,PAID_CNT  /* 구매자수 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_RMB / PAID_CNT END AS CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_KRW / PAID_CNT END AS CUST_AMT_KRW  /* 객단가 - 원화   */
          FROM WT_CAST A
    ), WT_CALC_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAID_CNT  /* 구매자수 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_RMB / PAID_CNT END AS CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_KRW / PAID_CNT END AS CUST_AMT_KRW  /* 객단가 - 원화   */
          FROM WT_CAST_YOY A
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,CAST(    SUM(PAID_CNT    )                                                                           AS DECIMAL(20,0)) AS PAID_CNT           /* 구매자수                       */
              ,CAST(    SUM(CUST_AMT_RMB)                                                                           AS DECIMAL(20,2)) AS CUST_AMT_RMB       /* 객단가                - 위안화 */
              ,CAST(AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_WEEK_RMB  /* 객단가 이동평균( 5일) - 위안화 */
              ,CAST(AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_MNTH_RMB  /* 객단가 이동평균(30일) - 위안화 */

              ,CAST(    SUM(CUST_AMT_KRW)                                                                           AS DECIMAL(20,2)) AS CUST_AMT_KRW       /* 객단가                - 원화   */
              ,CAST(AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_WEEK_KRW  /* 객단가 이동평균( 5일) - 원화   */
              ,CAST(AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_MNTH_KRW  /* 객단가 이동평균(30일) - 원화   */
          FROM WT_CALC A
      GROUP BY STATISTICS_DATE
    ), WT_MOVE_YOY AS
    (
        SELECT STATISTICS_DATE
              ,CAST(    SUM(PAID_CNT    )                                                                           AS DECIMAL(20,0)) AS PAID_CNT           /* 구매자수                       */
              ,CAST(    SUM(CUST_AMT_RMB)                                                                           AS DECIMAL(20,2)) AS CUST_AMT_RMB       /* 객단가                - 위안화 */
              ,CAST(AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_WEEK_RMB  /* 객단가 이동평균( 5일) - 위안화 */
              ,CAST(AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_MNTH_RMB  /* 객단가 이동평균(30일) - 위안화 */

              ,CAST(    SUM(CUST_AMT_KRW)                                                                           AS DECIMAL(20,2)) AS CUST_AMT_KRW       /* 객단가                - 원화   */
              ,CAST(AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_WEEK_KRW  /* 객단가 이동평균( 5일) - 원화   */
              ,CAST(AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS DECIMAL(20,2)) AS CUST_AMT_MNTH_KRW  /* 객단가 이동평균(30일) - 원화   */
          FROM WT_CALC_YOY A
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST'      THEN CUST_AMT_RMB
                 WHEN L_LGND_ID = 'CUST_WEEK' THEN CUST_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'CUST_MNTH' THEN CUST_AMT_MNTH_RMB
               END AS Y_VAL_RMB  /* PAID:구매자수, CUST:객단가 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST'      THEN CUST_AMT_KRW
                 WHEN L_LGND_ID = 'CUST_WEEK' THEN CUST_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'CUST_MNTH' THEN CUST_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* PAID:구매자수, CUST:객단가 - 원화   */
         FROM WT_COPY A
             ,WT_MOVE B
    UNION ALL
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'PAID_YOY'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST_YOY'      THEN CUST_AMT_RMB
                 WHEN L_LGND_ID = 'CUST_MNTH_YOY' THEN CUST_AMT_MNTH_RMB
                 WHEN L_LGND_ID = 'CUST_WEEK_YOY' THEN CUST_AMT_WEEK_RMB
               END AS Y_VAL_RMB  /* PAID:구매자수, CUST:객단가 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'PAID_YOY'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST_YOY'      THEN CUST_AMT_KRW
                 WHEN L_LGND_ID = 'CUST_WEEK_YOY' THEN CUST_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'CUST_MNTH_YOY' THEN CUST_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* PAID:구매자수, CUST:객단가 - 원화   */
         FROM WT_COPY_YOY A
             ,WT_MOVE_YOY B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_RMB AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_RMB
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_KRW AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT



9. 구매자당 수익 그래프(월별 바그래프)
    * 구매자당 수익 그래프(월별) 바 그래프 : CM/구매자수로 구매자당 수익이 어떻게 변화하는지 월별로 보여줘야함
        => CM데이터(수익) 테이블 정보 없음
    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함


/* 9. 구매자당 수익 그래프 - 바 그래프 SQL */


10. 지역분포
    * 지도그래프 : 해당 채널 고객의 누적 지역분포 스냅샷을 지도 그래프(geo chart)로 그려야함

    필요기능
    [1] 지도그래프 
    [2] 마우스오버 : 마우스오버시 지역과 수가 나와야함
    [3] 클릭시 바그래프 등이 나올 수 있으면 좋음 
    [4] 바그래프에는 1선도시, 2선도시, 3선도시로 구분되어 분석될 수 있음 좋음


/* 10. 지역분포 그래프 - 지도 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME                           AS CITY_NM
              ,CAST(SUM(UV) AS DECIMAL(20,0)) AS VIST_CNT
          FROM DASH.CRM_DGT_PROD_VISIT_CITY
       GROUP BY NAME
    )
    SELECT CITY_NM
          ,VIST_CNT
      FROM WT_BASE
  ORDER BY CITY_NM


/* 10. 지역분포 그래프 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN 1
                 WHEN LEVEL = '준1선도시' THEN 2
                 WHEN LEVEL = '2선도시'   THEN 3
                 WHEN LEVEL = '3선도시'   THEN 4
                 ELSE 9
               END AS SORT_KEY
              ,LEVEL                          AS CITY_LV
              ,CAST(SUM(UV) AS DECIMAL(20,0)) AS VIST_CNT
          FROM DASH.CRM_DGT_PROD_VISIT_CITY
      GROUP BY LEVEL
    )
    SELECT SORT_KEY
          ,CITY_LV   AS X_VAL
          ,VIST_CNT  AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY



11. 성별분포
    * 바그래프 : 성별에 대한 누적 스냅샷을 바그래프로 표기 (가로 바) 

    필요기능 
    [1] 마우스오버 : 마우스오버시 사람 수가 나와야함
    [2] 성별 미상도 존재 

/* 11. 성별분포 그래프 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME                           AS GNDR_NM
              ,CAST(SUM(UV) AS DECIMAL(20,0)) AS VIST_CNT
          FROM DASH.CRM_DGT_PROD_VISIT_GENDER
       GROUP BY NAME
    )
    SELECT GNDR_NM  AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY GNDR_NM


12. 연령분포
    * 연령분포 바그래프 : 세로그래프로 연령분포에 대한 스냅샷을 표기한다 

    필요기능
    [1] 연령분포 마우스오버 : 마우스오버시 연령에 따른 사람 수 나와야함


/* 12. 연령분포 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME                           AS AGE_NM
              ,CAST(SUM(UV) AS DECIMAL(20,0)) AS VIST_CNT
          FROM DASH.CRM_DGT_PROD_VISIT_AGE
       GROUP BY NAME
    )
    SELECT AGE_NM   AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY AGE_NM
