● 중국 매출대시보드 - 3. 고객분석

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


/* Index 생성 */

/* dash_raw.over_dgt_shop_by_hour */
CREATE INDEX over_dgt_shop_by_hour_statistics_date_idx ON dash_raw.over_dgt_shop_by_hour (statistics_date);


/*************************************************************************************************************************************/
/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL */            visitorAnalyticsCard.sql
/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL */      visitorAnalyticsChart.sql
/* 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL */                    visitorTimeSeriesCard.sql
/* 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */            visitorTimeSeriesChart.sql
/* 2. 방문자수 시계열 그래프 - 하단표 SQL */                           visitorTimeSeriesBottom.sql
/* 4. 방문자 첫방문/재방문 그래프 - 하단표 SQL */                    dayOfWeekVisitorCountBottom.sql
/* 3. 요일/시간 방문자수량 히트맵 - 히트맵 SQL */                    dayOfWeekVisitorCountHeatMap.sql
/* 4. 방문자 첫방문/재방문 그래프 - 방문자 시계열 그래프 SQL */        dayOfWeekVisitorCountTimeSeries.sql
/* 5. 요일별 첫방문 구매자 비중 - 토네이도 그래프 SQL */               weekdayNewBuyerRatioTornado.sql
/* 5. 요일별 첫방문 구매자 비중 - 하단표 SQL */                      weekdayNewBuyerRatioBottom.sql
/* 6. 방문자 평균체류시간 그래프 - 시계열 그래프 SQL */                visitDurationGraph.sql
/* 7. 요일별 방문자 평균체류시간 - 시계열 그래프 SQL */                averageDwellTimeByDayOfWeek.sql
/* 8. 구매자 객단가 그래프 - 그래프 SQL */                             averageRevenuePerCustomerGraph.sql
/* 9. 구매자당 수익 그래프 - 그래프 SQL */
/* 10. 지역분포 그래프 - 지도 그래프 SQL */                            regionalDistributionMapChart.sql
/* 10. 지역분포 그래프 - 바 그래프 SQL */                              regionalDistributionBarChart.sql
/* 11. 성별분포 그래프 - 바 그래프 SQL */                              genderDistributionBarChart.sql
/* 12. 연령분포 - 바 그래프 SQL */                                     ageDistributionBarChart.sql
/*************************************************************************************************************************************/


/* 0. 매출 대시보드 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 어제임 오늘이 2023.03.04 일 경우 => 22023.03.03 */
SELECT TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY                       , 'YYYY-MM-DD') AS BASE_DT           /* 기준일자               */
      ,TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR  , 'YYYY-MM-DD') AS BASE_DT_YOY       /* 기준일자          -1년 */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                     , 'YYYY-MM-DD') AS FRST_DT_MNTH      /* 기준월의 1일           */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' YEAR)                     , 'YYYY-MM-DD') AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                     , 'YYYY-MM-DD') AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' YEAR)                     , 'YYYY-MM-DD') AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY'   )                           AS BASE_YEAR         /* 기준년                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY'   )                           AS BASE_YEAR_YOY     /* 기준년            -1년 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY-MM')                           AS BASE_MNTH         /* 기준월                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY-MM')                           AS BASE_MNTH_YOY     /* 기준월            -1년 */   

SELECT BASE_DT               /* 기준일자               */
      ,BASE_DT_YOY           /* 기준일자          -1년 */
      ,FRST_DT_MNTH          /* 기준월의 1일           */
      ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
      ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
      ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
      ,FR_DT                 /* 기간조회 - 시작일자    */
      ,TO_DT                 /* 기간조회 - 종료일자    */
      ,BASE_YEAR             /* 기준년                 */
      ,BASE_YEAR_YOY         /* 기준년            -1년 */
      ,BASE_MNTH             /* 기준월                 */
      ,BASE_MNTH_YOY         /* 기준월            -1년 */
FROM DASH.DASH_INITIAL_DATE

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
    

/* visitorAnalyticsCard.sql */
/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_DT           /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE)  - INTERVAL '1' MONTH , 'YYYY-MM-DD') AS BASE_DT_MOM  /* 기준일자 (어제)   -1월 */
              ,BASE_DT_YOY       /* 기준일자 (어제)   -1년 */
              ,FRST_DT_MNTH      /* 기준월의 1일           */
              ,FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
              ,FRST_DT_YEAR      /* 기준년의 1월 1일       */
              ,FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_VIST_DAY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_MNTH AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_YEAR AS
    (
        SELECT SUM(NUMBER_OF_VISITORS   )  AS VIST_CNT  /* 연방문자수   */
              ,SUM(NEW_VISITORS         )  AS FRST_CNT  /* 연첫방문자수 */
              ,SUM(NUMBER_OF_PAID_BUYERS)  AS PAID_CNT  /* 연구매자수   */
              ,SUM(PAY_OLD_BUYERS       )  AS REPD_CNT  /* 재구매자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_CUST_DAY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,SUM(NUMBER_OF_PAID_BUYERS                                   ) AS PAID_CNT      /* 일구매자수          */
              ,SUM(AVERAGE_LENGTH_OF_STAY                                  ) AS STAY_TIME     /* 일평균 체류시간     */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_DAY_MOM AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 - MoM */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_MOM FROM WT_WHERE)
    ), WT_VIST_MNTH_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 - YoY */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_YEAR_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS   ) AS VIST_CNT  /* 연방문자수   - YoY */
              ,SUM(NEW_VISITORS         ) AS FRST_CNT  /* 연첫방문자수 - YoY */
              ,SUM(NUMBER_OF_PAID_BUYERS) AS PAID_CNT  /* 연구매자수   - YoY */
              ,SUM(PAY_OLD_BUYERS       ) AS REPD_CNT  /* 재구매자수   - YoY */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_CUST_DAY_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB  /* 일매출금액      YoY - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW  /* 일매출금액      YoY - 원화   */
              ,SUM(NUMBER_OF_PAID_BUYERS                                   ) AS PAID_CNT      /* 일구매자수      YoY          */
              ,SUM(AVERAGE_LENGTH_OF_STAY                                  ) AS STAY_TIME     /* 일평균 체류시간 YoY          */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
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
              ,C.REPD_CNT                                                                                AS REPD_CNT           /* 재구매자 수          */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.REPD_CNT    / C.VIST_CNT * 100 END AS REPD_RATE          /* 재구매자 비율        */
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
              ,G.REPD_CNT                                                                                AS REPD_CNT_YOY       /* 재구매자 수   YoY    */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.REPD_CNT / G.VIST_CNT * 100    END AS REPD_RATE_YOY      /* 재구매자 비율 YoY    */
          FROM WT_VIST_DAY       A
              ,WT_VIST_MNTH      B
              ,WT_VIST_YEAR      C
              ,WT_CUST_DAY       D
              ,WT_VIST_DAY_MOM   E
              ,WT_VIST_MNTH_YOY  F
              ,WT_VIST_YEAR_YOY  G
              ,WT_CUST_DAY_YOY   H
    )
    SELECT COALESCE(CAST(VIST_CNT                                                                   AS DECIMAL(20,0)), 0) AS VIST_CNT           /* 전일 방문자 수         */
          ,COALESCE(CAST(VIST_CNT_MNTH                                                              AS DECIMAL(20,0)), 0) AS VIST_CNT_MNTH      /* 당월 방문자 수         */
          ,COALESCE(CAST(VIST_CNT_YEAR                                                              AS DECIMAL(20,0)), 0) AS VIST_CNT_YEAR      /* 당해 방문자 수         */
          ,COALESCE(CAST(CUST_AMT_RMB                                                               AS DECIMAL(20,2)), 0) AS CUST_AMT_RMB       /* 객단가        - 위안화 */
          ,COALESCE(CAST(CUST_AMT_KRW                                                               AS DECIMAL(20,2)), 0) AS CUST_AMT_KRW       /* 객단가        - 원화   */
          ,COALESCE(CAST(STAY_TIME                                                                  AS DECIMAL(20,2)), 0) AS STAY_TIME          /* 평균 체류시간          */
          ,COALESCE(CAST(FRST_CNT                                                                   AS DECIMAL(20,0)), 0) AS FRST_CNT           /* 첫 방문자 수           */
          ,COALESCE(CAST(FRST_RATE                                                                  AS DECIMAL(20,2)), 0) AS FRST_RATE          /* 첫 방문자 비율         */
          ,COALESCE(CAST(PAID_CNT                                                                   AS DECIMAL(20,0)), 0) AS PAID_CNT           /* 구매자 수              */
          ,COALESCE(CAST(PAID_RATE                                                                  AS DECIMAL(20,2)), 0) AS PAID_RATE          /* 구매자 비율            */
          ,COALESCE(CAST(REPD_CNT                                                                   AS DECIMAL(20,0)), 0) AS REPD_CNT           /* 재구매자 수            */
          ,COALESCE(CAST(REPD_RATE                                                                  AS DECIMAL(20,2)), 0) AS REPD_RATE          /* 재구매자 비율          */

          ,COALESCE(CAST((VIST_CNT      - COALESCE(VIST_CNT_MOM     , 0)) / VIST_CNT_MOM      * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE          /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_MNTH - COALESCE(VIST_CNT_MNTH_YOY, 0)) / VIST_CNT_MNTH_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_MNTH     /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_YEAR - COALESCE(VIST_CNT_YEAR_YOY, 0)) / VIST_CNT_YEAR_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_YEAR     /* 당해 방문자 수 증감률  */
          ,COALESCE(CAST((CUST_AMT_RMB  - COALESCE(CUST_AMT_YOY_RMB , 0)) / CUST_AMT_YOY_RMB  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_RMB      /* 객단가 증감률 - 위안화 */
          ,COALESCE(CAST((CUST_AMT_KRW  - COALESCE(CUST_AMT_YOY_KRW , 0)) / CUST_AMT_YOY_KRW  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_KRW      /* 객단가 증감률 - 원화   */
          ,COALESCE(CAST((STAY_TIME     - COALESCE(STAY_TIME_YOY    , 0)) / STAY_TIME_YOY     * 100 AS DECIMAL(20,2)), 0) AS STAY_RATE          /* 평균 체류시간 증감률   */

          ,COALESCE(CAST(VIST_CNT_MOM                                                               AS DECIMAL(20,0)), 0) AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
          ,COALESCE(CAST(VIST_CNT_MNTH_YOY                                                          AS DECIMAL(20,0)), 0) AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
          ,COALESCE(CAST(VIST_CNT_YEAR_YOY                                                          AS DECIMAL(20,0)), 0) AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
          ,COALESCE(CAST(CUST_AMT_YOY_RMB                                                           AS DECIMAL(20,2)), 0) AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
          ,COALESCE(CAST(CUST_AMT_YOY_KRW                                                           AS DECIMAL(20,2)), 0) AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
          ,COALESCE(CAST(STAY_TIME_YOY                                                              AS DECIMAL(20,2)), 0) AS STAY_TIME_YOY      /* 평균 체류시간 YoY    */
          ,COALESCE(CAST(FRST_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS FRST_CNT_YOY       /* 첫 방문자 수   YoY   */
          ,COALESCE(CAST(FRST_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS FRST_RATE_YOY      /* 첫 방문자 비율 YoY   */
          ,COALESCE(CAST(PAID_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS PAID_CNT_YOY       /* 구매자 수   YoY      */
          ,COALESCE(CAST(PAID_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
          ,COALESCE(CAST(REPD_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS REPD_CNT_YOY       /* 재구매자 수   YoY    */
          ,COALESCE(CAST(REPD_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS REPD_RATE_YOY      /* 재구매자 비율 YoY    */
      FROM WT_BASE

/* visitorAnalyticsChart.sql */
/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_DT           /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE)  - INTERVAL '1' MONTH , 'YYYY-MM-DD') AS BASE_DT_MOM  /* 기준일자 (어제)   -1월 */
              ,FRST_DT_MNTH      /* 기준월의 1일           */
              ,FRST_DT_YEAR      /* 기준년의 1월 1일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_VIST_DAY AS
    (
        SELECT 'DAY'                    AS CHRT_KEY
              ,STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT BASE_DT_MOM FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_MNTH AS
    (
        SELECT 'MNTH'                   AS CHRT_KEY
              ,STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_YEAR AS
    (
        SELECT 'YEAR'                                             AS CHRT_KEY
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')  AS X_DT
              ,SUM(NUMBER_OF_VISITORS)                            AS VIST_CNT  /* 연방문자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')
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
    SELECT CHRT_KEY                                                      /* DAY:전일 방문자 수, MNTH:당일 방문자 수, YEAR:당일 방문자 수 */
          ,X_DT                                                          /* 일자(x축) */
          ,COALESCE(CAST(Y_VAL_VIST AS DECIMAL(20,0)), 0) AS Y_VAL_VIST  /* 방문자 수 */
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

/* visitorTimeSeriesCard.sql */
/* 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL */
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
        SELECT SUM(NUMBER_OF_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
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


/* visitorTimeSeriesChart.sql */
/* 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
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
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS AS VIST_CNT  /* 방문자수 */
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


/* visitorTimeSeriesBottom.sql */
/* 2. 방문자수 시계열 그래프 - 하단표 SQL                           */
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
              ,NUMBER_OF_VISITORS AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS AS VIST_CNT   /* 방문자수 YoY */
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


3. 요일/시간 방문자수 히트맵(선택된 기간에 따라 확인)
    * 방문자수에 대한 요일/시간 히트맵 : 선택한 기간에 따라 방문자수가 몇시에 많이 들어오는지 히트맵으로 보여줘야함 

    필요기능 : 
    [1] 기간선택 : 2번의 시계열그래프의 타임슬라이드 이동시 변화해야함 
    [2] 해당기간의 매출과 상관관계 결과가 그래프 상단에 표기되었으면함  예) 해당기간 매출과의 상관관계 95% 
        => 매출 상관관계 Logic은???

/* dayOfWeekVisitorCountHeatMap.sql */
/* 3. 요일/시간 방문자수량 히트맵 - 히트맵 SQL */
/*    조회결과 가공방법 방문자수 ==> [[WEEK_NO, HOUR_NO, VIST_CNT], [WEEK_NO, HOUR_NO, VIST_CNT], ...] */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')                AS WEEK_ID
              ,CAST(STATISTICS_HOURS                     AS DECIMAL(20,0)) AS HOUR_NO
              ,CAST(REPLACE(NUMBER_OF_VISITORS, ',', '') AS DECIMAL(20,0)) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_SHOP_BY_HOUR A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
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

/* dayOfWeekVisitorCountTimeSeries.sql */
/* 4. 방문자 첫방문/재방문 그래프 - 방문자 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(VIST_CNT)                                                                           AS VIST_CNT       /* 방문자수                  */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS VIST_CNT_WEEK  /* 방문자수 - 이동평균( 5일) */
              ,AVG(SUM(VIST_CNT)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS VIST_CNT_MNTH  /* 방문자수 - 이동평균(30일) */
              ,    SUM(FRST_CNT)                                                                           AS FRST_CNT       /* 첫방문자수                */
              ,    SUM(PAID_CNT)                                                                           AS PAID_CNT       /* 구매자수                  */
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
          /*,CAST(Y_VAL AS DECIMAL(20,0)) AS Y_VAL */
          ,COALESCE(CASE WHEN SORT_KEY IN (1, 2, 3) THEN CAST(CAST(Y_VAL AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT


/* dayOfWeekVisitorCountBottom.sql */
/* 4. 방문자 첫방문/재방문 그래프 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT      /* 기준일의  1월  1일       */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT      /* 기준일의 12월 31일       */
          FROM DASH.DASH_INITIAL_DATE
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
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS COL_MNTH
              ,SUM(VIST_CNT)                                AS VIST_CNT  /* 방문자수   */
              ,SUM(FRST_CNT)                                AS FRST_CNT  /* 첫방문자수 */
              ,SUM(PAID_CNT)                                AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
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
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '01' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '01' THEN PAID_RATE  END) AS COL_VAL_01
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '02' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '02' THEN PAID_RATE  END) AS COL_VAL_02
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '03' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '03' THEN PAID_RATE  END) AS COL_VAL_03
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '04' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '04' THEN PAID_RATE  END) AS COL_VAL_04
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '05' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '05' THEN PAID_RATE  END) AS COL_VAL_05
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '06' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '06' THEN PAID_RATE  END) AS COL_VAL_06
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '07' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '07' THEN PAID_RATE  END) AS COL_VAL_07
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '08' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '08' THEN PAID_RATE  END) AS COL_VAL_08
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '09' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '09' THEN PAID_RATE  END) AS COL_VAL_09
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '10' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '10' THEN PAID_RATE  END) AS COL_VAL_10
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '11' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '11' THEN PAID_RATE  END) AS COL_VAL_11
              ,SUM(CASE WHEN SORT_KEY = 1 AND COL_MNTH = '12' THEN FRST_RATE WHEN SORT_KEY = 2 AND COL_MNTH = '12' THEN PAID_RATE  END) AS COL_VAL_12
          FROM WT_COPY A 
              ,WT_RATE B
      GROUP BY SORT_KEY
              ,ROW_TITL
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(COL_VAL_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_01
          ,TO_CHAR(CAST(COL_VAL_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_02
          ,TO_CHAR(CAST(COL_VAL_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_03
          ,TO_CHAR(CAST(COL_VAL_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_04
          ,TO_CHAR(CAST(COL_VAL_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_05
          ,TO_CHAR(CAST(COL_VAL_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_06
          ,TO_CHAR(CAST(COL_VAL_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_07
          ,TO_CHAR(CAST(COL_VAL_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_08
          ,TO_CHAR(CAST(COL_VAL_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_09
          ,TO_CHAR(CAST(COL_VAL_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_10
          ,TO_CHAR(CAST(COL_VAL_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_11
          ,TO_CHAR(CAST(COL_VAL_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_12
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


/* weekdayNewBuyerRatioTornado.sql */
/* 5. 요일별 첫방문 구매자 비중 - 토네이도 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,SUM(VIST_CNT)                                AS VIST_CNT  /* 방문자수   */
              ,SUM(FRST_CNT)                                AS FRST_CNT  /* 첫방문자수 */
              ,SUM(PAID_CNT)                                AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')
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


/* weekdayNewBuyerRatioBottom.sql */
/* 5. 요일별 첫방문 구매자 비중 - 하단표 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT      /* 기준일의  1월  1일       */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT      /* 기준일의 12월 31일       */
          FROM DASH.DASH_INITIAL_DATE
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
              ,NUMBER_OF_VISITORS    AS VIST_CNT  /* 방문자수   */
              ,NEW_VISITORS          AS FRST_CNT  /* 첫방문자수 */
              ,NUMBER_OF_PAID_BUYERS AS PAID_CNT  /* 구매자수   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,SUM(VIST_CNT)                                AS VIST_CNT  /* 방문자수   */
              ,SUM(FRST_CNT)                                AS FRST_CNT  /* 첫방문자수 */
              ,SUM(PAID_CNT)                                AS PAID_CNT  /* 구매자수   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy')
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
          ,TO_CHAR(CAST(COL_VAL_MON AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_MON
          ,TO_CHAR(CAST(COL_VAL_TUE AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_TUE
          ,TO_CHAR(CAST(COL_VAL_WED AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_WED
          ,TO_CHAR(CAST(COL_VAL_THU AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_THU
          ,TO_CHAR(CAST(COL_VAL_FRI AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_FRI
          ,TO_CHAR(CAST(COL_VAL_SAT AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_SAT
          ,TO_CHAR(CAST(COL_VAL_SUN AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS COL_VAL_SUN
      FROM WT_BASE
  ORDER BY SORT_KEY



6. 방문자 평균체류시간 그래프
    * 방문자 평균체류 비중의 일별 시계열그래프 : 방문자 평균체류시간이 일별로 어떻게 변화하는지 필요하다 
    * 작년기준 그래프도 함께 포함되어야함 
        => 선택한 기간에 따른 작년 Line 표시
    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함

/* visitDurationGraph.sql */
/* 6. 방문자 평균체류시간 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST((SELECT FR_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS FR_DT
              ,TO_CHAR(CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS TO_DT
    ), WT_CAST AS
    (
        SELECT 1      AS SORT_KEY
              ,'VIST' AS L_LGND_ID
              ,'올해' AS L_LGND_NM 
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 2          AS SORT_KEY
              ,'VIST_YOY' AS L_LGND_ID
              ,'작년'     AS L_LGND_NM 
              ,STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
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
          ,STAY_TIME AS Y_VAL
      FROM WT_CAST A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT


7. 요일별 방문자 평균체류시간 그래프
    * 요일별 방문자 평균체류시간 그래프

    필요기능 : 
    [1] 기간은 좌측 6번 그래프와 연동되도록 해야함

/* averageDwellTimeByDayOfWeek.sql */
/* 7. 요일별 방문자 평균체류시간 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,NUMBER_OF_VISITORS     AS VIST_CNT   /* 방문자수     */
              ,AVERAGE_LENGTH_OF_STAY AS STAY_TIME  /* 평균체류시간 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_AVG AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,CAST(AVG(STAY_TIME) AS DECIMAL(20,4))        AS STAY_TIME  /* 평균체류시간 */
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

/* averageRevenuePerCustomerGraph.sql */
/* 8. 구매자 객단가 그래프 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST((SELECT FR_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS FR_DT
              ,TO_CHAR(CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS TO_DT
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
              ,PAYMENT_AMOUNT                                           AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,NUMBER_OF_PAID_BUYERS                                    AS PAID_CNT      /* 일구매자수          */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                           AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,NUMBER_OF_PAID_BUYERS                                    AS PAID_CNT      /* 일구매자수          */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
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
              ,    SUM(PAID_CNT    )                                                                           AS PAID_CNT           /* 구매자수                       */
              ,    SUM(CUST_AMT_RMB)                                                                           AS CUST_AMT_RMB       /* 객단가                - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_RMB  /* 객단가 이동평균( 5일) - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_RMB  /* 객단가 이동평균(30일) - 위안화 */

              ,    SUM(CUST_AMT_KRW)                                                                           AS CUST_AMT_KRW       /* 객단가                - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_KRW  /* 객단가 이동평균( 5일) - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_KRW  /* 객단가 이동평균(30일) - 원화   */
          FROM WT_CALC A
      GROUP BY STATISTICS_DATE
    ), WT_MOVE_YOY AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(PAID_CNT    )                                                                           AS PAID_CNT           /* 구매자수                       */
              ,    SUM(CUST_AMT_RMB)                                                                           AS CUST_AMT_RMB       /* 객단가                - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_RMB  /* 객단가 이동평균( 5일) - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_RMB  /* 객단가 이동평균(30일) - 위안화 */

              ,    SUM(CUST_AMT_KRW)                                                                           AS CUST_AMT_KRW       /* 객단가                - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_KRW  /* 객단가 이동평균( 5일) - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_KRW  /* 객단가 이동평균(30일) - 원화   */
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
/* Tmall Only                            */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,:FR_MNTH                                                                           AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH                                                                           AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM                                                                           AS CHNL_NM    /* 채널명 ex) 'Tmall Global'       */ 
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_ANLS AS
    (
        SELECT DATE                           AS MNTH_ANLS
              ,SUM(COALESCE(CM * 1000000, 0)) AS CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
     GROUP BY DATE
    ), WT_PAID AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM') AS MNTH_PAID
              ,SUM(COALESCE(NUMBER_OF_PAID_BUYERS, 0))           AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')
    ), WT_BASE AS
    (
        SELECT A.COPY_MNTH                                                  AS X_MNTH
              ,CASE WHEN C.PAID_CNT = 0 THEN 0 ELSE B.CM_AMT / PAID_CNT END AS Y_VAL
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
                              LEFT OUTER JOIN WT_PAID C ON (A.COPY_MNTH = C.MNTH_PAID)
    )
    SELECT X_MNTH
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL  /* Bar Chart */
      FROM WT_BASE
  ORDER BY X_MNTH
;


10. 지역분포
    * 지도그래프 : 해당 채널 고객의 누적 지역분포 스냅샷을 지도 그래프(geo chart)로 그려야함

    필요기능
    [1] 지도그래프 
    [2] 마우스오버 : 마우스오버시 지역과 수가 나와야함
    [3] 클릭시 바그래프 등이 나올 수 있으면 좋음 
    [4] 바그래프에는 1선도시, 2선도시, 3선도시로 구분되어 분석될 수 있음 좋음

/* regionalDistributionMapChart.sql */
/* 10. 지역분포 그래프 - 지도 그래프 SQL */
/* 10. 지역분포 그래프 - 지도 그래프 SQL */
WITH WT_CITY AS
    (
        SELECT NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
         HAVING SUM(UV) > 0 
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


/* regionalDistributionBarChart.sql */
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
              ,LEVEL   AS CITY_LV
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
      GROUP BY LEVEL
    )
    SELECT SORT_KEY
          ,CITY_LV   AS X_VAL
          ,VIST_CNT  AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
     WHERE SORT_KEY IN (1, 2, 3, 4)
  ORDER BY SORT_KEY



11. 성별분포
    * 바그래프 : 성별에 대한 누적 스냅샷을 바그래프로 표기 (가로 바) 

    필요기능 
    [1] 마우스오버 : 마우스오버시 사람 수가 나와야함
    [2] 성별 미상도 존재 

/* genderDistributionBarChart.sql */
/* 11. 성별분포 그래프 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_GENDER
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

/* ageDistributionBarChart.sql */
/* 12. 연령분포 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
       GROUP BY NAME
    )
    SELECT AGE_NM   AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY AGE_NM



/* 10. 지역분포 그래프 - 지도 그래프 SQL */
/* Table 생성 */
CREATE TABLE dash_raw.over_china_city (
	city_nm text NULL,
	prov_nm text NULL
);
CREATE INDEX over_china_city_city_nm_idx ON dash_raw.over_china_city USING btree (city_nm);

INSERT
  INTO dash_raw.over_china_city  (city_nm, prov_nm)
VALUES
    ('东城区', '北京市'),
    ('西城区', '北京市'),
    ('朝阳区', '北京市'),
    ('丰台区', '北京市'),
    ('石景山区', '北京市'),
    ('海淀区', '北京市'),
    ('门头沟区', '北京市'),
    ('房山区', '北京市'),
    ('通州区', '北京市'),
    ('顺义区', '北京市'),
    ('昌平区', '北京市'),
    ('大兴区', '北京市'),
    ('怀柔区', '北京市'),
    ('平谷区', '北京市'),
    ('密云区', '北京市'),
    ('延庆区', '北京市'),
    ('和平区', '天津市'),
    ('河东区', '天津市'),
    ('河西区', '天津市'),
    ('南开区', '天津市'),
    ('河北区', '天津市'),
    ('红桥区', '天津市'),
    ('东丽区', '天津市'),
    ('西青区', '天津市'),
    ('津南区', '天津市'),
    ('北辰区', '天津市'),
    ('武清区', '天津市'),
    ('宝坻区', '天津市'),
    ('滨海新区', '天津市'),
    ('宁河区', '天津市'),
    ('静海区', '天津市'),
    ('蓟州区', '天津市'),
    ('石家庄市', '河北省'),
    ('唐山市', '河北省'),
    ('秦皇岛市', '河北省'),
    ('邯郸市', '河北省'),
    ('邢台市', '河北省'),
    ('保定市', '河北省'),
    ('张家口市', '河北省'),
    ('承德市', '河北省'),
    ('沧州市', '河北省'),
    ('廊坊市', '河北省'),
    ('衡水市', '河北省'),
    ('太原市', '山西省'),
    ('大同市', '山西省'),
    ('阳泉市', '山西省'),
    ('长治市', '山西省'),
    ('晋城市', '山西省'),
    ('朔州市', '山西省'),
    ('晋中市', '山西省'),
    ('运城市', '山西省'),
    ('忻州市', '山西省'),
    ('临汾市', '山西省'),
    ('吕梁市', '山西省'),
    ('呼和浩特市', '内蒙古自治区'),
    ('包头市', '内蒙古自治区'),
    ('乌海市', '内蒙古自治区'),
    ('赤峰市', '内蒙古自治区'),
    ('通辽市', '内蒙古自治区'),
    ('鄂尔多斯市', '内蒙古自治区'),
    ('呼伦贝尔市', '内蒙古自治区'),
    ('巴彦淖尔市', '内蒙古自治区'),
    ('乌兰察布市', '内蒙古自治区'),
    ('兴安盟', '内蒙古自治区'),
    ('锡林郭勒盟', '内蒙古自治区'),
    ('阿拉善盟', '内蒙古自治区'),
    ('沈阳市', '辽宁省'),
    ('大连市', '辽宁省'),
    ('鞍山市', '辽宁省'),
    ('抚顺市', '辽宁省'),
    ('本溪市', '辽宁省'),
    ('丹东市', '辽宁省'),
    ('锦州市', '辽宁省'),
    ('营口市', '辽宁省'),
    ('阜新市', '辽宁省'),
    ('辽阳市', '辽宁省'),
    ('盘锦市', '辽宁省'),
    ('铁岭市', '辽宁省'),
    ('朝阳市', '辽宁省'),
    ('葫芦岛市', '辽宁省'),
    ('长春市', '吉林省'),
    ('吉林市', '吉林省'),
    ('四平市', '吉林省'),
    ('辽源市', '吉林省'),
    ('通化市', '吉林省'),
    ('白山市', '吉林省'),
    ('松原市', '吉林省'),
    ('白城市', '吉林省'),
    ('延边朝鲜族自治州', '吉林省'),
    ('哈尔滨市', '黑龙江省'),
    ('齐齐哈尔市', '黑龙江省'),
    ('鸡西市', '黑龙江省'),
    ('鹤岗市', '黑龙江省'),
    ('双鸭山市', '黑龙江省'),
    ('大庆市', '黑龙江省'),
    ('伊春市', '黑龙江省'),
    ('佳木斯市', '黑龙江省'),
    ('七台河市', '黑龙江省'),
    ('牡丹江市', '黑龙江省'),
    ('黑河市', '黑龙江省'),
    ('绥化市', '黑龙江省'),
    ('大兴安岭地区', '黑龙江省'),
    ('黄浦区', '上海市'),
    ('徐汇区', '上海市'),
    ('长宁区', '上海市'),
    ('静安区', '上海市'),
    ('普陀区', '上海市'),
    ('虹口区', '上海市'),
    ('杨浦区', '上海市'),
    ('闵行区', '上海市'),
    ('宝山区', '上海市'),
    ('嘉定区', '上海市'),
    ('浦东新区', '上海市'),
    ('金山区', '上海市'),
    ('松江区', '上海市'),
    ('青浦区', '上海市'),
    ('奉贤区', '上海市'),
    ('崇明区', '上海市'),
    ('南京市', '江苏省'),
    ('无锡市', '江苏省'),
    ('徐州市', '江苏省'),
    ('常州市', '江苏省'),
    ('苏州市', '江苏省'),
    ('南通市', '江苏省'),
    ('连云港市', '江苏省'),
    ('淮安市', '江苏省'),
    ('盐城市', '江苏省'),
    ('扬州市', '江苏省'),
    ('镇江市', '江苏省'),
    ('泰州市', '江苏省'),
    ('宿迁市', '江苏省'),
    ('杭州市', '浙江省'),
    ('宁波市', '浙江省'),
    ('温州市', '浙江省'),
    ('嘉兴市', '浙江省'),
    ('湖州市', '浙江省'),
    ('绍兴市', '浙江省'),
    ('金华市', '浙江省'),
    ('衢州市', '浙江省'),
    ('舟山市', '浙江省'),
    ('台州市', '浙江省'),
    ('丽水市', '浙江省'),
    ('合肥市', '安徽省'),
    ('芜湖市', '安徽省'),
    ('蚌埠市', '安徽省'),
    ('淮南市', '安徽省'),
    ('马鞍山市', '安徽省'),
    ('淮北市', '安徽省'),
    ('铜陵市', '安徽省'),
    ('安庆市', '安徽省'),
    ('黄山市', '安徽省'),
    ('滁州市', '安徽省'),
    ('阜阳市', '安徽省'),
    ('宿州市', '安徽省'),
    ('六安市', '安徽省'),
    ('亳州市', '安徽省'),
    ('池州市', '安徽省'),
    ('宣城市', '安徽省'),
    ('福州市', '福建省'),
    ('厦门市', '福建省'),
    ('莆田市', '福建省'),
    ('三明市', '福建省'),
    ('泉州市', '福建省'),
    ('漳州市', '福建省'),
    ('南平市', '福建省'),
    ('龙岩市', '福建省'),
    ('宁德市', '福建省'),
    ('南昌市', '江西省'),
    ('景德镇市', '江西省'),
    ('萍乡市', '江西省'),
    ('九江市', '江西省'),
    ('新余市', '江西省'),
    ('鹰潭市', '江西省'),
    ('赣州市', '江西省'),
    ('吉安市', '江西省'),
    ('宜春市', '江西省'),
    ('抚州市', '江西省'),
    ('上饶市', '江西省'),
    ('济南市', '山东省'),
    ('青岛市', '山东省'),
    ('淄博市', '山东省'),
    ('枣庄市', '山东省'),
    ('东营市', '山东省'),
    ('烟台市', '山东省'),
    ('潍坊市', '山东省'),
    ('济宁市', '山东省'),
    ('泰安市', '山东省'),
    ('威海市', '山东省'),
    ('日照市', '山东省'),
    ('临沂市', '山东省'),
    ('德州市', '山东省'),
    ('聊城市', '山东省'),
    ('滨州市', '山东省'),
    ('菏泽市', '山东省'),
    ('郑州市', '河南省'),
    ('开封市', '河南省'),
    ('洛阳市', '河南省'),
    ('平顶山市', '河南省'),
    ('安阳市', '河南省'),
    ('鹤壁市', '河南省'),
    ('新乡市', '河南省'),
    ('焦作市', '河南省'),
    ('濮阳市', '河南省'),
    ('许昌市', '河南省'),
    ('漯河市', '河南省'),
    ('三门峡市', '河南省'),
    ('南阳市', '河南省'),
    ('商丘市', '河南省'),
    ('信阳市', '河南省'),
    ('周口市', '河南省'),
    ('驻马店市', '河南省'),
    ('济源市', '河南省'),
    ('武汉市', '湖北省'),
    ('黄石市', '湖北省'),
    ('十堰市', '湖北省'),
    ('宜昌市', '湖北省'),
    ('襄阳市', '湖北省'),
    ('鄂州市', '湖北省'),
    ('荆门市', '湖北省'),
    ('孝感市', '湖北省'),
    ('荆州市', '湖北省'),
    ('黄冈市', '湖北省'),
    ('咸宁市', '湖北省'),
    ('随州市', '湖北省'),
    ('恩施土家族苗族自治州', '湖北省'),
    ('仙桃市', '湖北省'),
    ('潜江市', '湖北省'),
    ('天门市', '湖北省'),
    ('神农架林区', '湖北省'),
    ('长沙市', '湖南省'),
    ('株洲市', '湖南省'),
    ('湘潭市', '湖南省'),
    ('衡阳市', '湖南省'),
    ('邵阳市', '湖南省'),
    ('岳阳市', '湖南省'),
    ('常德市', '湖南省'),
    ('张家界市', '湖南省'),
    ('益阳市', '湖南省'),
    ('郴州市', '湖南省'),
    ('永州市', '湖南省'),
    ('怀化市', '湖南省'),
    ('娄底市', '湖南省'),
    ('湘西土家族苗族自治州', '湖南省'),
    ('广州市', '广东省'),
    ('韶关市', '广东省'),
    ('深圳市', '广东省'),
    ('珠海市', '广东省'),
    ('汕头市', '广东省'),
    ('佛山市', '广东省'),
    ('江门市', '广东省'),
    ('湛江市', '广东省'),
    ('茂名市', '广东省'),
    ('肇庆市', '广东省'),
    ('惠州市', '广东省'),
    ('梅州市', '广东省'),
    ('汕尾市', '广东省'),
    ('河源市', '广东省'),
    ('阳江市', '广东省'),
    ('清远市', '广东省'),
    ('东莞市', '广东省'),
    ('中山市', '广东省'),
    ('潮州市', '广东省'),
    ('揭阳市', '广东省'),
    ('云浮市', '广东省'),
    ('南宁市', '广西壮族自治区'),
    ('柳州市', '广西壮族自治区'),
    ('桂林市', '广西壮族自治区'),
    ('梧州市', '广西壮族自治区'),
    ('北海市', '广西壮族自治区'),
    ('防城港市', '广西壮族自治区'),
    ('钦州市', '广西壮族自治区'),
    ('贵港市', '广西壮族自治区'),
    ('玉林市', '广西壮族自治区'),
    ('百色市', '广西壮族自治区'),
    ('贺州市', '广西壮族自治区'),
    ('河池市', '广西壮族自治区'),
    ('来宾市', '广西壮族自治区'),
    ('崇左市', '广西壮族自治区'),
    ('海口市', '海南省'),
    ('三亚市', '海南省'),
    ('三沙市', '海南省'),
    ('儋州市', '海南省'),
    ('五指山市', '海南省'),
    ('琼海市', '海南省'),
    ('文昌市', '海南省'),
    ('万宁市', '海南省'),
    ('东方市', '海南省'),
    ('定安县', '海南省'),
    ('屯昌县', '海南省'),
    ('澄迈县', '海南省'),
    ('临高县', '海南省'),
    ('白沙黎族自治县', '海南省'),
    ('昌江黎族自治县', '海南省'),
    ('乐东黎族自治县', '海南省'),
    ('陵水黎族自治县', '海南省'),
    ('保亭黎族苗族自治县', '海南省'),
    ('琼中黎族苗族自治县', '海南省'),
    ('万州区', '重庆市'),
    ('涪陵区', '重庆市'),
    ('渝中区', '重庆市'),
    ('大渡口区', '重庆市'),
    ('江北区', '重庆市'),
    ('沙坪坝区', '重庆市'),
    ('九龙坡区', '重庆市'),
    ('南岸区', '重庆市'),
    ('北碚区', '重庆市'),
    ('綦江区', '重庆市'),
    ('大足区', '重庆市'),
    ('渝北区', '重庆市'),
    ('巴南区', '重庆市'),
    ('黔江区', '重庆市'),
    ('长寿区', '重庆市'),
    ('江津区', '重庆市'),
    ('合川区', '重庆市'),
    ('永川区', '重庆市'),
    ('南川区', '重庆市'),
    ('璧山区', '重庆市'),
    ('铜梁区', '重庆市'),
    ('潼南区', '重庆市'),
    ('荣昌区', '重庆市'),
    ('开州区', '重庆市'),
    ('梁平区', '重庆市'),
    ('武隆区', '重庆市'),
    ('城口县', '重庆市'),
    ('丰都县', '重庆市'),
    ('垫江县', '重庆市'),
    ('忠县', '重庆市'),
    ('云阳县', '重庆市'),
    ('奉节县', '重庆市'),
    ('巫山县', '重庆市'),
    ('巫溪县', '重庆市'),
    ('石柱土家族自治县', '重庆市'),
    ('秀山土家族苗族自治县', '重庆市'),
    ('酉阳土家族苗族自治县', '重庆市'),
    ('彭水苗族土家族自治县', '重庆市'),
    ('成都市', '四川省'),
    ('自贡市', '四川省'),
    ('攀枝花市', '四川省'),
    ('泸州市', '四川省'),
    ('德阳市', '四川省'),
    ('绵阳市', '四川省'),
    ('广元市', '四川省'),
    ('遂宁市', '四川省'),
    ('内江市', '四川省'),
    ('乐山市', '四川省'),
    ('南充市', '四川省'),
    ('眉山市', '四川省'),
    ('宜宾市', '四川省'),
    ('广安市', '四川省'),
    ('达州市', '四川省'),
    ('雅安市', '四川省'),
    ('巴中市', '四川省'),
    ('资阳市', '四川省'),
    ('阿坝藏族羌族自治州', '四川省'),
    ('甘孜藏族自治州', '四川省'),
    ('凉山彝族自治州', '四川省'),
    ('贵阳市', '贵州省'),
    ('六盘水市', '贵州省'),
    ('遵义市', '贵州省'),
    ('安顺市', '贵州省'),
    ('毕节市', '贵州省'),
    ('铜仁市', '贵州省'),
    ('黔西南布依族苗族自治州', '贵州省'),
    ('黔东南苗族侗族自治州', '贵州省'),
    ('黔南布依族苗族自治州', '贵州省'),
    ('昆明市', '云南省'),
    ('曲靖市', '云南省'),
    ('玉溪市', '云南省'),
    ('保山市', '云南省'),
    ('昭通市', '云南省'),
    ('丽江市', '云南省'),
    ('普洱市', '云南省'),
    ('临沧市', '云南省'),
    ('楚雄彝族自治州', '云南省'),
    ('红河哈尼族彝族自治州', '云南省'),
    ('文山壮族苗族自治州', '云南省'),
    ('西双版纳傣族自治州', '云南省'),
    ('大理白族自治州', '云南省'),
    ('德宏傣族景颇族自治州', '云南省'),
    ('怒江傈僳族自治州', '云南省'),
    ('迪庆藏族自治州', '云南省'),
    ('拉萨市', '西藏自治区'),
    ('日喀则市', '西藏自治区'),
    ('昌都市', '西藏自治区'),
    ('林芝市', '西藏自治区'),
    ('山南市', '西藏自治区'),
    ('那曲市', '西藏自治区'),
    ('阿里地区', '西藏自治区'),
    ('西安市', '陕西省'),
    ('铜川市', '陕西省'),
    ('宝鸡市', '陕西省'),
    ('咸阳市', '陕西省'),
    ('渭南市', '陕西省'),
    ('延安市', '陕西省'),
    ('汉中市', '陕西省'),
    ('榆林市', '陕西省'),
    ('安康市', '陕西省'),
    ('商洛市', '陕西省'),
    ('兰州市', '甘肃省'),
    ('嘉峪关市', '甘肃省'),
    ('金昌市', '甘肃省'),
    ('白银市', '甘肃省'),
    ('天水市', '甘肃省'),
    ('武威市', '甘肃省'),
    ('张掖市', '甘肃省'),
    ('平凉市', '甘肃省'),
    ('酒泉市', '甘肃省'),
    ('庆阳市', '甘肃省'),
    ('定西市', '甘肃省'),
    ('陇南市', '甘肃省'),
    ('临夏回族自治州', '甘肃省'),
    ('甘南藏族自治州', '甘肃省'),
    ('西宁市', '青海省'),
    ('海东市', '青海省'),
    ('海北藏族自治州', '青海省'),
    ('黄南藏族自治州', '青海省'),
    ('海南藏族自治州', '青海省'),
    ('果洛藏族自治州', '青海省'),
    ('玉树藏族自治州', '青海省'),
    ('海西蒙古族藏族自治州', '青海省'),
    ('银川市', '宁夏回族自治区'),
    ('石嘴山市', '宁夏回族自治区'),
    ('吴忠市', '宁夏回族自治区'),
    ('固原市', '宁夏回族自治区'),
    ('中卫市', '宁夏回族自治区'),
    ('乌鲁木齐市', '新疆维吾尔自治区'),
    ('克拉玛依市', '新疆维吾尔自治区'),
    ('吐鲁番市', '新疆维吾尔自治区'),
    ('哈密市', '新疆维吾尔自治区'),
    ('昌吉回族自治州', '新疆维吾尔自治区'),
    ('博尔塔拉蒙古自治州', '新疆维吾尔自治区'),
    ('巴音郭楞蒙古自治州', '新疆维吾尔自治区'),
    ('阿克苏地区', '新疆维吾尔自治区'),
    ('克孜勒苏柯尔克孜自治州', '新疆维吾尔自治区'),
    ('喀什地区', '新疆维吾尔自治区'),
    ('和田地区', '新疆维吾尔自治区'),
    ('伊犁哈萨克自治州', '新疆维吾尔自治区'),
    ('塔城地区', '新疆维吾尔自治区'),
    ('阿勒泰地区', '新疆维吾尔自治区'),
    ('石河子市', '新疆维吾尔自治区'),
    ('阿拉尔市', '新疆维吾尔自治区'),
    ('图木舒克市', '新疆维吾尔自治区'),
    ('五家渠市', '新疆维吾尔自治区'),
    ('北屯市', '新疆维吾尔自治区'),
    ('铁门关市', '新疆维吾尔自治区'),
    ('双河市', '新疆维吾尔自治区'),
    ('可克达拉市', '新疆维吾尔自治区'),
    ('昆玉市', '新疆维吾尔自治区'),
    ('胡杨河市', '新疆维吾尔自治区'),
    ('中西区', '香港特别行政区'),
    ('湾仔区', '香港特别行政区'),
    ('东区', '香港特别行政区'),
    ('南区', '香港特别行政区'),
    ('油尖旺区', '香港特别行政区'),
    ('深水埗区', '香港特别行政区'),
    ('九龙城区', '香港特别行政区'),
    ('黄大仙区', '香港特别行政区'),
    ('观塘区', '香港特别行政区'),
    ('荃湾区', '香港特别行政区'),
    ('屯门区', '香港特别行政区'),
    ('元朗区', '香港特别行政区'),
    ('北区', '香港特别行政区'),
    ('大埔区', '香港特别行政区'),
    ('西贡区', '香港特别行政区'),
    ('沙田区', '香港特别行政区'),
    ('葵青区', '香港特别行政区'),
    ('离岛区', '香港特别行政区'),
    ('花地玛堂区', '澳门特别行政区'),
    ('花王堂区', '澳门特别行政区'),
    ('望德堂区', '澳门特别行政区'),
    ('大堂区', '澳门特别行政区'),
    ('风顺堂区', '澳门特别行政区'),
    ('嘉模堂区', '澳门特别行政区'),
    ('路凼填海区', '澳门特别行政区'),
    ('圣方济各堂区', '澳门特别行政区') ;
