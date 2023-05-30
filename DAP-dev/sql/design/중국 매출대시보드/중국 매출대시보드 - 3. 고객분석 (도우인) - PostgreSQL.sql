● 중국 매출대시보드 - 3. 고객분석 (도우인)

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */

0. 화면 설명
    * 기존 매출 대시보드 고객분석 도우인 페이지에 대한 특이사항
    * 도우인에는 티몰에 없는 데이터가 있으며 도우인 채널만의 특이사항이 존재하기 때문에 별도의 기획 필요

[도우인] 1. 중요정보 카드 - 방문자수/객단가/클릭 전환율/재 구매자 비율
    
/* visitorAnalyticsCard.sql */
/* [도우인] 1. 중요정보 카드 - 방문자수/객단가/클릭 전환율/재 구매자 비율 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(BASE_DT                                                            , '-', '') AS INTEGER) AS BASE_DT           /* 기준일자 (어제)        */
              ,CAST(REPLACE(TO_CHAR(CAST(BASE_DT AS DATE)  - INTERVAL '1' MONTH , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS BASE_DT_MOM       /* 기준일자 (어제)   -1월 */
              ,CAST(REPLACE(BASE_DT_YOY                                                        , '-', '') AS INTEGER) AS BASE_DT_YOY       /* 기준일자 (어제)   -1년 */
              ,CAST(REPLACE(FRST_DT_MNTH                                                       , '-', '') AS INTEGER) AS FRST_DT_MNTH      /* 기준월의 1일           */
              ,CAST(REPLACE(FRST_DT_MNTH_YOY                                                   , '-', '') AS INTEGER) AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
              ,CAST(REPLACE(FRST_DT_YEAR                                                       , '-', '') AS INTEGER) AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY                                                   , '-', '') AS INTEGER) AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_CUST_DAY AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_DAY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_MNTH AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_YEAR AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_REPD_YEAR AS
    (
        SELECT SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_{TAG}_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
    ), WT_CUST_DAY_YOY AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE = (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_DAY_MOM AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE = (SELECT BASE_DT_MOM FROM WT_WHERE)
    ), WT_VIST_DAY_YOY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE = (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_MNTH_YOY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_YEAR_YOY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON                                       )  AS VIST_CNT      /* 방문자수          */
              ,SUM(PRODUCT_IMPRESSIONS                                         )  AS PROD_CNT      /* 상품 본 수        */
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
              ,SUM(PRODUCT_CLICKS                                              )  AS CLCK_CNT      /* 클릭수            */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_REPD_YEAR_YOY AS
    (
        SELECT SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS REPD_CNT      /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS REPD_PAID_CNT /* 구매자 수        */
          FROM DASH_RAW.OVER_{TAG}_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT                                                                                       AS VIST_CNT           /* 전일 방문자 수       */
              ,B.VIST_CNT                                                                                       AS VIST_CNT_MNTH      /* 당월 방문자 수       */
              ,C.VIST_CNT                                                                                       AS VIST_CNT_YEAR      /* 당해 방문자 수       */
              ,CASE WHEN COALESCE(D.PAID_CNT     , 0) = 0 THEN 0    ELSE D.SALE_AMT_RMB / D.PAID_CNT        END AS CUST_AMT_RMB       /* 객단가      - 위안화 */
              ,CASE WHEN COALESCE(D.PAID_CNT     , 0) = 0 THEN 0    ELSE D.SALE_AMT_KRW / D.PAID_CNT        END AS CUST_AMT_KRW       /* 객단가      - 원화   */
              ,C.CLCK_CNT                                                                                       AS CLCK_CNT           /* 클릭 수              */
              ,CASE WHEN COALESCE(C.PROD_CNT     , 0) = 0 THEN 0    ELSE C.CLCK_CNT / C.PROD_CNT      * 100 END AS CLCK_RATE          /* 클릭전환율           */
              ,J.REPD_CNT                                                                                       AS REPD_CNT           /* 재구매자 수          */
              ,CASE WHEN COALESCE(J.REPD_PAID_CNT, 0) = 0 THEN 0    ELSE J.REPD_CNT / J.REPD_PAID_CNT * 100 END AS REPD_RATE          /* 재구매자 비율        */
              ,C.PAID_CNT                                                                                       AS PAID_CNT           /* 구매자 수            */
              ,CASE WHEN COALESCE(C.VIST_CNT     , 0) = 0 THEN 0    ELSE C.PAID_CNT / C.VIST_CNT      * 100 END AS PAID_RATE          /* 구매자 비율          */
              ,E.VIST_CNT                                                                                       AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
              ,I.VIST_CNT                                                                                       AS VIST_CNT_YOY       /* 전일 방문자 수 - YoY */
              ,F.VIST_CNT                                                                                       AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
              ,G.VIST_CNT                                                                                       AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
              ,CASE WHEN COALESCE(H.PAID_CNT     , 0) = 0 THEN NULL ELSE H.SALE_AMT_RMB / H.PAID_CNT        END AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
              ,CASE WHEN COALESCE(H.PAID_CNT     , 0) = 0 THEN NULL ELSE H.SALE_AMT_KRW / H.PAID_CNT        END AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
              ,G.CLCK_CNT                                                                                       AS CLCK_CNT_YOY       /* 클릭 수    YoY       */
              ,CASE WHEN COALESCE(G.VIST_CNT     , 0) = 0 THEN 0    ELSE G.CLCK_CNT / G.PROD_CNT * 100      END AS CLCK_RATE_YOY      /* 클릭전환율 YoY       */
              ,K.REPD_CNT                                                                                       AS REPD_CNT_YOY       /* 재구매자 수 YoY      */
              ,CASE WHEN COALESCE(K.REPD_PAID_CNT, 0) = 0 THEN 0    ELSE K.REPD_CNT / K.REPD_PAID_CNT * 100 END AS REPD_RATE_YOY      /* 재구매자 비율 YoY    */
              ,G.PAID_CNT                                                                                       AS PAID_CNT_YOY       /* 구매자 수   YoY      */
              ,CASE WHEN COALESCE(G.VIST_CNT     , 0) = 0 THEN 0    ELSE G.PAID_CNT / G.VIST_CNT * 100      END AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
          FROM WT_VIST_DAY       A
              ,WT_VIST_MNTH      B
              ,WT_VIST_YEAR      C
              ,WT_CUST_DAY       D
              ,WT_VIST_DAY_MOM   E
              ,WT_VIST_MNTH_YOY  F
              ,WT_VIST_YEAR_YOY  G
              ,WT_CUST_DAY_YOY   H
              ,WT_VIST_DAY_YOY   I
              ,WT_REPD_YEAR      J
              ,WT_REPD_YEAR_YOY  K
    )
    SELECT COALESCE(CAST(VIST_CNT                                                                   AS DECIMAL(20,0)), 0) AS VIST_CNT           /* 전일 방문자 수         */
          ,COALESCE(CAST(VIST_CNT_MNTH                                                              AS DECIMAL(20,0)), 0) AS VIST_CNT_MNTH      /* 당월 방문자 수         */
          ,COALESCE(CAST(VIST_CNT_YEAR                                                              AS DECIMAL(20,0)), 0) AS VIST_CNT_YEAR      /* 당해 방문자 수         */
          ,COALESCE(CAST(CUST_AMT_RMB                                                               AS DECIMAL(20,2)), 0) AS CUST_AMT_RMB       /* 객단가        - 위안화 */
          ,COALESCE(CAST(CUST_AMT_KRW                                                               AS DECIMAL(20,2)), 0) AS CUST_AMT_KRW       /* 객단가        - 원화   */
          ,COALESCE(CAST(CLCK_CNT                                                                   AS DECIMAL(20,0)), 0) AS CLCK_CNT           /* 클릭 수                */
          ,COALESCE(CAST(CLCK_RATE                                                                  AS DECIMAL(20,2)), 0) AS CLCK_RATE          /* 클릭전환율             */
          ,COALESCE(CAST(PAID_CNT                                                                   AS DECIMAL(20,0)), 0) AS PAID_CNT           /* 구매자 수              */
          ,COALESCE(CAST(PAID_RATE                                                                  AS DECIMAL(20,2)), 0) AS PAID_RATE          /* 구매자 비율            */
          ,COALESCE(CAST(REPD_CNT                                                                   AS DECIMAL(20,0)), 0) AS REPD_CNT           /* 재구매자 수            */
          ,COALESCE(CAST(REPD_RATE                                                                  AS DECIMAL(20,2)), 0) AS REPD_RATE          /* 재구매자 비율          */

          ,COALESCE(CAST((VIST_CNT      - COALESCE(VIST_CNT_YOY     , 0)) / VIST_CNT_YOY      * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE          /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_MNTH - COALESCE(VIST_CNT_MNTH_YOY, 0)) / VIST_CNT_MNTH_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_MNTH     /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_YEAR - COALESCE(VIST_CNT_YEAR_YOY, 0)) / VIST_CNT_YEAR_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_YEAR     /* 당해 방문자 수 증감률  */
          ,COALESCE(CAST((CUST_AMT_RMB  - COALESCE(CUST_AMT_YOY_RMB , 0)) / CUST_AMT_YOY_RMB  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_RMB      /* 객단가 증감률 - 위안화 */
          ,COALESCE(CAST((CUST_AMT_KRW  - COALESCE(CUST_AMT_YOY_KRW , 0)) / CUST_AMT_YOY_KRW  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_KRW      /* 객단가 증감률 - 원화   */
          
          ,COALESCE(CAST(VIST_CNT_MOM                                                               AS DECIMAL(20,0)), 0) AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
          ,COALESCE(CAST(VIST_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS VIST_CNT_YOY       /* 전일 방문자 수 - YoY */
          ,COALESCE(CAST(VIST_CNT_MNTH_YOY                                                          AS DECIMAL(20,0)), 0) AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
          ,COALESCE(CAST(VIST_CNT_YEAR_YOY                                                          AS DECIMAL(20,0)), 0) AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
          ,COALESCE(CAST(CUST_AMT_YOY_RMB                                                           AS DECIMAL(20,2)), 0) AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
          ,COALESCE(CAST(CUST_AMT_YOY_KRW                                                           AS DECIMAL(20,2)), 0) AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
          ,COALESCE(CAST(CLCK_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS CLCK_CNT_YOY       /* 클릭 수    YoY       */
          ,COALESCE(CAST(CLCK_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS CLCK_RATE_YOY      /* 클릭전환율 YoY       */
          ,COALESCE(CAST(PAID_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS PAID_CNT_YOY       /* 구매자 수   YoY      */
          ,COALESCE(CAST(PAID_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
          ,COALESCE(CAST(REPD_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS REPD_CNT_YOY       /* 재구매자 수   YoY    */
          ,COALESCE(CAST(REPD_RATE_YOY                                                              AS DECIMAL(20,2)), 0) AS REPD_RATE_YOY      /* 재구매자 비율 YoY    */
      FROM WT_BASE
;

/* visitorAnalyticsChart.sql */
/* [도우인] 1. 중요정보 카드 - 방문자수/객단가/클릭 전환율/재 구매자 비율 Chart SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(BASE_DT                                                            , '-', '') AS INTEGER) AS BASE_DT           /* 기준일자 (어제)        */
              ,CAST(REPLACE(TO_CHAR(CAST(BASE_DT AS DATE)  - INTERVAL '1' MONTH , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS BASE_DT_MOM       /* 기준일자 (어제)   -1월 */
              ,CAST(REPLACE(FRST_DT_MNTH                                                       , '-', '') AS INTEGER) AS FRST_DT_MNTH      /* 기준월의 1일           */
              ,CAST(REPLACE(FRST_DT_YEAR                                                       , '-', '') AS INTEGER) AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_VIST_DAY AS
    (
        SELECT 'DAY'                                                          AS CHRT_KEY
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS X_DT
              ,SUM(PRODUCT_CLICKS_PERSON)                                     AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT BASE_DT_MOM FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY DATE
    ), WT_VIST_MNTH AS
    (
        SELECT 'MNTH'                                                         AS CHRT_KEY
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS X_DT
              ,SUM(PRODUCT_CLICKS_PERSON)                                     AS VIST_CNT  /* 월방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY DATE
    ), WT_VIST_YEAR AS
    (
        SELECT 'YEAR'                                                      AS CHRT_KEY
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS X_DT
              ,SUM(PRODUCT_CLICKS_PERSON)                                  AS VIST_CNT  /* 연방문자수   */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
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
;


[도우인] 2. 방문자수 시계열 그래프
/* visitorTimeSeriesCard.sql */
/* [도우인] 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR    , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(REPLACE(BASE_DT         , '-', '') AS INTEGER)  AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY, '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(REPLACE(BASE_DT_YOY     , '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SUM AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
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

/* visitorTimeSeriesChart.sql */
/* [도우인] 2. 방문자수 시계열 그래프 - 방문자수 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT        /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
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

/* visitorTimeSeriesBottom.sql */
/* [도우인] 2. 방문자수 시계열 그래프 - 하단표 SQL                  */
/*    오늘(2023.03.04)일 경우 => 기준일 : 2023.03.03              */
/*                               올해   : 2023.01.01 ~ 2023.12.31 */
/*                               전년도 : 2022.01.01 ~ 2022.12.31 */
/*    올해, 전년도는 방문자 수라서 소숫점이 없게 표시하고         */
/*    YoY, MoM는 증감률이라서 소숫점 2자리까지 표시하도록         */
/*    VARCHAR로 형변환하여 리턴함.                                */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR           , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(REPLACE(BASE_YEAR    ||'-12-31', '-', '') AS INTEGER)  AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY       , '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(REPLACE(BASE_YEAR_YOY||'-12-31', '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,CAST(REPLACE(BASE_YEAR              , '-', '') AS INTEGER)  AS THIS_YEAR  /* 기준일의 연도            */
              ,CAST(REPLACE(BASE_YEAR_YOY          , '-', '') AS INTEGER)  AS LAST_YEAR  /* 기준일의 연도       -1년 */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT         /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_CLICKS_PERSON > 0
    ), WT_CAST_YOY AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT         /* 방문자수 YoY */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND PRODUCT_CLICKS_PERSON > 0
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
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_01 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_01   /* 01월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_02 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_02   /* 02월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_03 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_03   /* 03월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_04 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_04   /* 04월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_05 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_05   /* 05월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_06 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_06   /* 06월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_07 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_07   /* 07월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_08 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_08   /* 08월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_09 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_09   /* 09월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_10 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_10   /* 10월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_11 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_11   /* 11월 방문자수 */
          ,CASE WHEN SORT_KEY IN (1, 2) THEN TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,0)), 'FM999,999,999,999,999') ELSE TO_CHAR(CAST(VIST_CNT_12 AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') END AS VIST_CNT_12   /* 12월 방문자수 */
      FROM WT_BASE
  ORDER BY SORT_KEY
;

[도우인] 3. 요일 방문자 수 그래프
/* [도우인] 3. 요일 방문자 수 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,PRODUCT_CLICKS_PERSON                                          AS VIST_CNT        /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,CAST(SUM(VIST_CNT) AS DECIMAL(20,0))         AS VIST_CNT  /* 방문자수 */
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
              ,CAST(VIST_CNT AS DECIMAL(20,0)) AS VIST_CNT
          FROM WT_SUM
    )
    SELECT SORT_KEY
          ,WEEK_ID   AS X_WEEK
          ,VIST_CNT  AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY
;

[도우인] 4. 클릭 전환율
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
;


[도우인] 5. 요일별 클릭 전환율
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
;


[도우인] 6. 구매자 수 시계열 그래프
/* buyerTimeSeriesCard.sql */
/* [도우인] 6. 구매자 수 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR    , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(REPLACE(BASE_DT         , '-', '') AS INTEGER)  AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY, '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(REPLACE(BASE_DT_YOY     , '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SUM AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
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

/* buyerTimeSeriesChart.sql */
/* [도우인] 6. 구매자 수 시계열 그래프 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,NUMBER_OF_TRANSACTIONS                                          AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
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

/* buyerTimeSeriesBottom.sql */
/* [도우인] 6. 구매자 수 시계열 그래프 - 하단표 SQL                 */
/*    오늘(2023.03.04)일 경우 => 기준일 : 2023.03.03              */
/*                               올해   : 2023.01.01 ~ 2023.12.31 */
/*                               전년도 : 2022.01.01 ~ 2022.12.31 */
/*    올해, 전년도는 방문자 수라서 소숫점이 없게 표시하고         */
/*    YoY, MoM는 증감률이라서 소숫점 2자리까지 표시하도록         */
/*    VARCHAR로 형변환하여 리턴함.                                */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR           , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(REPLACE(BASE_YEAR    ||'-12-31', '-', '') AS INTEGER)  AS TO_DT      /* 기준일의 12월 31일       */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY       , '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,CAST(REPLACE(BASE_YEAR_YOY||'-12-31', '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,CAST(REPLACE(BASE_YEAR              , '-', '') AS INTEGER)  AS THIS_YEAR  /* 기준일의 연도            */
              ,CAST(REPLACE(BASE_YEAR_YOY          , '-', '') AS INTEGER)  AS LAST_YEAR  /* 기준일의 연도       -1년 */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,NUMBER_OF_TRANSACTIONS                                          AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND NUMBER_OF_TRANSACTIONS > 0
    ), WT_CAST_YOY AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')  AS STATISTICS_DATE
              ,NUMBER_OF_TRANSACTIONS                                          AS PAID_CNT   /* 구매자수 YoY */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
           AND NUMBER_OF_TRANSACTIONS > 0
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


[도우인] 7. 구매자 첫구매/재구매 비율
/* buyerFirstBuyRebuyChart.sql */
/* [도우인] 7. 구매자 첫구매/재구매 비율 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')     AS STATISTICS_DATE
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS REPD_CNT         /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS PAID_CNT         /* 구매자 수        */
          FROM DASH_RAW.OVER_{TAG}_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY DATE
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

/* buyerFirstBuyRebuyBottom.sql */
/* [도우인] 7. 구매자 첫구매/재구매 비율 - 하단 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR           , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의  1월  1일       */
              ,CAST(REPLACE(BASE_YEAR    ||'-12-31', '-', '') AS INTEGER)  AS TO_DT      /* 기준일의 12월 31일       */
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')     AS STATISTICS_DATE
              ,SUM(CASE WHEN CROWD_TYPE = '老客' THEN NUMBER_OF_TRANSACTIONS END) AS REPD_CNT         /* 재구매자 수      */
              ,SUM(NUMBER_OF_TRANSACTIONS                                       ) AS PAID_CNT         /* 구매자 수        */
          FROM DASH_RAW.OVER_{TAG}_CROWD_COMPOSITION
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CARRIER_TYPE = '全部'
      GROUP BY DATE
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

[도우인] 8. 구매자 객 단가 그래프
/* averageRevenuePerCustomerGraph.sql */
/* [도우인] 8. 구매자 객단가 그래프 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE({FR_DT}, '-', '') AS INTEGER)  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST(REPLACE({TO_DT}, '-', '') AS INTEGER)  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_WHERE_YOY AS
    (
        SELECT CAST(REPLACE(TO_CHAR(CAST({FR_DT} AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD'), '-', '') AS INTEGER)  AS FR_DT
              ,CAST(REPLACE(TO_CHAR(CAST({TO_DT} AS DATE) - INTERVAL '1' YEAR , 'YYYY-MM-DD'), '-', '') AS INTEGER)  AS TO_DT
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')     AS STATISTICS_DATE
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY DATE
    ), WT_CAST_YOY AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM-DD')     AS STATISTICS_DATE
              ,SUM(NUMBER_OF_TRANSACTIONS                                      )  AS PAID_CNT      /* 구매자 수         */
              ,SUM(TRANSACTION_AMOUNT_YUAN                                     )  AS SALE_AMT_RMB  /* 구매금액 - 위안화 */
              ,SUM(TRANSACTION_AMOUNT_YUAN * DASH_RAW.SF_EXCH_KRW(A.DATE::TEXT))  AS SALE_AMT_KRW  /* 구매금액 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE_YOY) AND (SELECT TO_DT FROM WT_WHERE_YOY)
      GROUP BY DATE
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
          ,CASE WHEN RIGHT(L_LGND_ID, 3) = 'YOY' THEN TO_CHAR(X_DT::DATE + INTERVAL '1 YEAR', 'YYYY-MM-DD') ELSE X_DT END X_DT
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_RMB AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_RMB
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_KRW AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
;

[도우인] 9. 구매자당 수익 그래프(월별 바그래프)
    * 구매자당 수익 그래프(월별) 바 그래프 : CM/구매자수로 구매자당 수익이 어떻게 변화하는지 월별로 보여줘야함
        => CM데이터(수익) 테이블 정보 없음
    필요기능 : 
    [1] 기간선택 : 선택한 기간에 따라 볼 수 있어야함
/* [도우인] 9. 구매자당 수익 그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(REPLACE(TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{FR_MNTH}                                                                                                              AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                                                              AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{CHNL_NM}                                                                                                              AS CHNL_NM    /* 채널명 ex) 'Tmall Global'       */ 
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
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_PAID
              ,SUM(COALESCE(NUMBER_OF_TRANSACTIONS, 0))                    AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
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

