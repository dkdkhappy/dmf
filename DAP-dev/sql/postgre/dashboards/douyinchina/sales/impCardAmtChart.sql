/* 1. 중요정보 카드 - Chart SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_DT                /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE) - INTERVAL '1' DAY, 'YYYY-MM-DD') AS BASE_DT_DOD  /* 기준일자 (어제)   -1일 */
              ,BASE_DT_YOY           /* 기준일자 (어제)   -1년 */
              ,FRST_DT_MNTH          /* 기준월의 1일           */
              ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
              ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
              ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SALE_DAY AS
    (
        SELECT 'DAY'                                                                                                     AS CHRT_KEY
              ,STATISTICS_DATE                                                                                           AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_RMB       /* 일매출금액          - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_RMB       /* 일환불금액          - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_KRW       /* 일매출금액          - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_KRW       /* 일환불금액          - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT BASE_DT_DOD FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_SALE_MNTH AS
    (             
        SELECT 'MNTH'                                                                                                    AS CHRT_KEY
              ,STATISTICS_DATE                                                                                           AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_MNTH_RMB  /* 월매출금액(누적)    - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_MNTH_RMB  /* 월매환불액(누적)    - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_MNTH_KRW  /* 월매출금액(누적)    - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_MNTH_KRW  /* 월매환불액(누적)    - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_SALE_YEAR AS
    (
        SELECT 'YEAR'                                                                                                    AS CHRT_KEY
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')                                                         AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_YEAR_RMB  /* 연매출금액(누적)   - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_YEAR_RMB  /* 연환불금액(누적)   - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_YEAR_KRW  /* 연매출금액(누적)   - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_YEAR_KRW  /* 연환불금액(누적)   - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')
    ), WT_BASE AS
    (
        SELECT A.CHRT_KEY                        /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,A.X_DT                            /* 일자(x축)                      */
              ,A.SALE_AMT_RMB AS Y_VAL_SALE_RMB  /* 일매출금액            - 위안화 */
              ,A.REFD_AMT_RMB AS Y_VAL_REFD_RMB  /* 일환불금액            - 위안화 */
              ,A.SALE_AMT_KRW AS Y_VAL_SALE_KRW  /* 일매출금액            - 원화   */
              ,A.REFD_AMT_KRW AS Y_VAL_REFD_KRW  /* 일환불금액            - 원화   */
          FROM WT_SALE_DAY A
     UNION ALL
        SELECT B.CHRT_KEY                               /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,B.X_DT                                   /* 일자(x축)                    */
              ,B.SALE_AMT_MNTH_RMB  AS Y_VAL_SALE_RMB   /* 월매출금액(누적)    - 위안화 */
              ,B.REFD_AMT_MNTH_RMB  AS Y_VAL_REFD_RMB   /* 월매환불액(누적)    - 위안화 */
              ,B.SALE_AMT_MNTH_KRW  AS Y_VAL_SALE_KRW   /* 월매출금액(누적)    - 원화   */
              ,B.REFD_AMT_MNTH_KRW  AS Y_VAL_REFD_KRW   /* 월매환불액(누적)    - 원화   */
          FROM WT_SALE_MNTH B
     UNION ALL
        SELECT C.CHRT_KEY                               /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,C.X_DT                                   /* 일자(x축)                    */
              ,C.SALE_AMT_YEAR_RMB  AS Y_VAL_SALE_RMB   /* 연매출금액(누적)    - 위안화 */
              ,C.REFD_AMT_YEAR_RMB  AS Y_VAL_REFD_RMB   /* 연매환불액(누적)    - 위안화 */
              ,C.SALE_AMT_YEAR_KRW  AS Y_VAL_SALE_KRW   /* 연매출금액(누적)    - 원화   */
              ,C.REFD_AMT_YEAR_KRW  AS Y_VAL_REFD_KRW   /* 연매환불액(누적)    - 원화   */
          FROM WT_SALE_YEAR C
    )
    SELECT CHRT_KEY
          ,X_DT
          ,COALESCE(CAST(Y_VAL_SALE_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_RMB  /* 매출금액 - 위안화 */
          ,COALESCE(CAST(Y_VAL_REFD_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_REFD_RMB  /* 환불금액 - 위안화 */
          ,COALESCE(CAST(Y_VAL_SALE_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_KRW  /* 매출금액 - 원화   */
          ,COALESCE(CAST(Y_VAL_REFD_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_REFD_KRW  /* 환불금액 - 원화   */
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT
