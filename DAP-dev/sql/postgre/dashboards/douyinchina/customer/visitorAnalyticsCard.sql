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