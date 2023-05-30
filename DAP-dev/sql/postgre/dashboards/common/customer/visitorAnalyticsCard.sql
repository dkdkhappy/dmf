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
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_MNTH AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_YEAR AS
    (
        SELECT SUM(NUMBER_OF_VISITORS   )  AS VIST_CNT  /* 연방문자수   */
              ,SUM(NEW_VISITORS         )  AS FRST_CNT  /* 연첫방문자수 */
              ,SUM(NUMBER_OF_PAID_BUYERS)  AS PAID_CNT  /* 연구매자수   */
              ,SUM(PAY_OLD_BUYERS       )  AS REPD_CNT  /* 재구매자수   */
              ,AVG(AVERAGE_LENGTH_OF_STAY) AS STAY_TIME     /* 연간 일평균 체류시간     */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_CUST_DAY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,SUM(NUMBER_OF_PAID_BUYERS                                   ) AS PAID_CNT      /* 일구매자수          */
              ,SUM(AVERAGE_LENGTH_OF_STAY                                  ) AS STAY_TIME     /* 일평균 체류시간     */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_VIST_DAY_MOM AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 - MoM */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_MOM FROM WT_WHERE)
    ), WT_VIST_DAY_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 - YoY */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_MNTH_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 - YoY */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_VIST_YEAR_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS   )  AS VIST_CNT  /* 연방문자수   - YoY */
              ,SUM(NEW_VISITORS         )  AS FRST_CNT  /* 연첫방문자수 - YoY */
              ,SUM(NUMBER_OF_PAID_BUYERS)  AS PAID_CNT  /* 연구매자수   - YoY */
              ,SUM(PAY_OLD_BUYERS       )  AS REPD_CNT  /* 재구매자수   - YoY */
              ,AVG(AVERAGE_LENGTH_OF_STAY) AS STAY_TIME     /* 연간 일평균 체류시간     */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_CUST_DAY_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB  /* 일매출금액      YoY - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW  /* 일매출금액      YoY - 원화   */
              ,SUM(NUMBER_OF_PAID_BUYERS                                   ) AS PAID_CNT      /* 일구매자수      YoY          */
              ,SUM(AVERAGE_LENGTH_OF_STAY                                  ) AS STAY_TIME     /* 일평균 체류시간 YoY          */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT                                                                                AS VIST_CNT           /* 전일 방문자 수       */
              ,B.VIST_CNT                                                                                AS VIST_CNT_MNTH      /* 당월 방문자 수       */
              ,C.VIST_CNT                                                                                AS VIST_CNT_YEAR      /* 당해 방문자 수       */
              ,CASE WHEN COALESCE(D.PAID_CNT, 0) = 0 THEN 0    ELSE D.SALE_AMT_RMB / D.PAID_CNT      END AS CUST_AMT_RMB       /* 객단가      - 위안화 */
              ,CASE WHEN COALESCE(D.PAID_CNT, 0) = 0 THEN 0    ELSE D.SALE_AMT_KRW / D.PAID_CNT      END AS CUST_AMT_KRW       /* 객단가      - 원화   */
              ,C.STAY_TIME                                                                               AS STAY_TIME          /* 평균 체류시간        */
              ,C.FRST_CNT                                                                                AS FRST_CNT           /* 첫 방문자 수         */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.FRST_CNT    / C.VIST_CNT * 100 END AS FRST_RATE          /* 첫 방문자 비율       */
              ,C.PAID_CNT                                                                                AS PAID_CNT           /* 구매자 수            */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.REPD_CNT    / C.PAID_CNT * 100 END AS REPD_RATE          /* 재구매자 비율        */
              ,C.REPD_CNT                                                                                AS REPD_CNT           /* 재구매자 수          */
              ,CASE WHEN COALESCE(C.VIST_CNT, 0) = 0 THEN 0    ELSE C.PAID_CNT    / C.VIST_CNT * 100 END AS PAID_RATE          /* 구매자 비율          */
              ,E.VIST_CNT                                                                                AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
              ,I.VIST_CNT                                                                                AS VIST_CNT_YOY       /* 전일 방문자 수 - YoY */
              ,F.VIST_CNT                                                                                AS VIST_CNT_MNTH_YOY  /* 당월 방문자 수 - YoY */
              ,G.VIST_CNT                                                                                AS VIST_CNT_YEAR_YOY  /* 당해 방문자 수 - YoY */
              ,CASE WHEN COALESCE(H.PAID_CNT, 0) = 0 THEN NULL ELSE H.SALE_AMT_RMB / H.PAID_CNT      END AS CUST_AMT_YOY_RMB   /* 객단가 YoY  - 위안화 */
              ,CASE WHEN COALESCE(H.PAID_CNT, 0) = 0 THEN NULL ELSE H.SALE_AMT_KRW / H.PAID_CNT      END AS CUST_AMT_YOY_KRW   /* 객단가 YoY  - 원화   */
              ,G.STAY_TIME                                                                               AS STAY_TIME_YOY      /* 평균 체류시간 YoY    */
              ,G.FRST_CNT                                                                                AS FRST_CNT_YOY       /* 첫 방문자 수   YoY   */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.FRST_CNT / G.VIST_CNT * 100    END AS FRST_RATE_YOY      /* 첫 방문자 비율 YoY   */
              ,G.PAID_CNT                                                                                AS PAID_CNT_YOY       /* 구매자 수   YoY      */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.REPD_CNT / G.PAID_CNT * 100    END AS PAID_RATE_YOY      /* 구매자 비율 YoY      */
              ,G.REPD_CNT                                                                                AS REPD_CNT_YOY       /* 재구매자 수   YoY    */
              ,CASE WHEN COALESCE(G.VIST_CNT, 0) = 0 THEN 0    ELSE G.PAID_CNT / G.VIST_CNT * 100    END AS REPD_RATE_YOY      /* 재구매자 비율 YoY    */
          FROM WT_VIST_DAY       A
              ,WT_VIST_MNTH      B
              ,WT_VIST_YEAR      C
              ,WT_CUST_DAY       D
              ,WT_VIST_DAY_MOM   E
              ,WT_VIST_MNTH_YOY  F
              ,WT_VIST_YEAR_YOY  G
              ,WT_CUST_DAY_YOY   H
              ,WT_VIST_DAY_YOY   I
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

          ,COALESCE(CAST((VIST_CNT      - COALESCE(VIST_CNT_YOY     , 0)) / VIST_CNT_YOY      * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE          /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_MNTH - COALESCE(VIST_CNT_MNTH_YOY, 0)) / VIST_CNT_MNTH_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_MNTH     /* 전일 방문자 수 증감률  */
          ,COALESCE(CAST((VIST_CNT_YEAR - COALESCE(VIST_CNT_YEAR_YOY, 0)) / VIST_CNT_YEAR_YOY * 100 AS DECIMAL(20,2)), 0) AS VIST_RATE_YEAR     /* 당해 방문자 수 증감률  */
          ,COALESCE(CAST((CUST_AMT_RMB  - COALESCE(CUST_AMT_YOY_RMB , 0)) / CUST_AMT_YOY_RMB  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_RMB      /* 객단가 증감률 - 위안화 */
          ,COALESCE(CAST((CUST_AMT_KRW  - COALESCE(CUST_AMT_YOY_KRW , 0)) / CUST_AMT_YOY_KRW  * 100 AS DECIMAL(20,2)), 0) AS CUST_RATE_KRW      /* 객단가 증감률 - 원화   */
          ,COALESCE(CAST((STAY_TIME     - COALESCE(STAY_TIME_YOY    , 0)) / STAY_TIME_YOY     * 100 AS DECIMAL(20,2)), 0) AS STAY_RATE          /* 평균 체류시간 증감률   */

          ,COALESCE(CAST(VIST_CNT_MOM                                                               AS DECIMAL(20,0)), 0) AS VIST_CNT_MOM       /* 전일 방문자 수 - MoM */
          ,COALESCE(CAST(VIST_CNT_YOY                                                               AS DECIMAL(20,0)), 0) AS VIST_CNT_YOY       /* 전일 방문자 수 - YoY */
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
