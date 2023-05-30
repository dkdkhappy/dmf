/* impCardAmtData.sql */
/* 1. 중요정보 카드 - 금액 SQL */
/*    ※ 매출금액 : 환불제외 매출금액 */
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
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB            /* 일매출금액          - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_RMB            /* 일환불금액          - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW            /* 일매출금액          - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_KRW            /* 일환불금액          - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_MNTH AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_MNTH_RMB       /* 월매출금액(누적)    - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_MNTH_RMB       /* 월매환불액(누적)    - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_MNTH_KRW       /* 월매출금액(누적)    - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_MNTH_KRW       /* 월매환불액(누적)    - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_YEAR AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_YEAR_RMB       /* 연매출금액(누적)   - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_YEAR_RMB       /* 연환불금액(누적)   - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_YEAR_KRW       /* 연매출금액(누적)   - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_YEAR_KRW       /* 연환불금액(누적)   - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_DAY_DOD AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  SALE_AMT_DOD_RMB       /* 일매출금액      DoD - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  REFD_AMT_DOD_RMB       /* 일환불금액      DoD - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  SALE_AMT_DOD_KRW       /* 일매출금액      DoD - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  REFD_AMT_DOD_KRW       /* 일환불금액      DoD - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_DOD FROM WT_WHERE)
    ), WT_SALE_MNTH_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_MNTH_YOY_RMB  /* 월매출금액(누적) YoY - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_MNTH_YOY_RMB  /* 월매환불액(누적) YoY - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_MNTH_YOY_KRW  /* 월매출금액(누적) YoY - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_MNTH_YOY_KRW  /* 월매환불액(누적) YoY - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_SALE_YEAR_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_YEAR_YOY_RMB  /* 연매출금액(누적) YoY - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_YEAR_YOY_RMB  /* 연환불금액(누적) YoY - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_YEAR_YOY_KRW  /* 연매출금액(누적) YoY - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_YEAR_YOY_KRW  /* 연환불금액(누적) YoY - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_RANK AS
    (
        SELECT MAX({TAG}_RANK_TOT)                           AS BRND_RANK
              ,MAX({TAG}_RANK_TOT_MOM) - MAX({TAG}_RANK_TOT) AS BRND_RANK_MOM
              ,MAX({TAG}_RANK_KR )                           AS BRND_RANK_KR
              ,MAX({TAG}_RANK_KR_MOM ) - MAX({TAG}_RANK_KR ) AS BRND_RANK_KR_MOM
          FROM dash.sum_rankcarddata
    ), WT_REVN_TAGT AS
    (
        SELECT SUM("revenueTarget") * 1000000 AS REVN_TAGT_AMT  /* 한화로 백만원 단위 */
          FROM DASH.CM_TARGET
         WHERE CHANNEL = 'Douyin China'
    ), WT_BASE AS
    (
        SELECT A.SALE_AMT_RMB                                                                               AS SALE_AMT_RMB           /* 일매출금액            - 위안화 */
              ,A.REFD_AMT_RMB                                                                               AS REFD_AMT_RMB           /* 일환불금액            - 위안화 */
              ,A.SALE_AMT_KRW                                                                               AS SALE_AMT_KRW           /* 일매출금액            - 원화   */
              ,A.REFD_AMT_KRW                                                                               AS REFD_AMT_KRW           /* 일환불금액            - 원화   */
              ,(A.SALE_AMT_RMB - COALESCE(D.SALE_AMT_DOD_RMB, 0)) / D.SALE_AMT_DOD_RMB * 100                AS SALE_RATE_DOD_RMB      /* 일매출금액 증감률     - 위안화 */
              ,(A.REFD_AMT_RMB - COALESCE(D.REFD_AMT_DOD_RMB, 0)) / D.REFD_AMT_DOD_RMB * 100                AS REFD_RATE_DOD_RMB      /* 일환불금액 증감률     - 위안화 */
              ,(A.SALE_AMT_KRW - COALESCE(D.SALE_AMT_DOD_KRW, 0)) / D.SALE_AMT_DOD_KRW * 100                AS SALE_RATE_DOD_KRW      /* 일매출금액 증감률     - 원화   */
              ,(A.REFD_AMT_KRW - COALESCE(D.REFD_AMT_DOD_KRW, 0)) / D.REFD_AMT_DOD_KRW * 100                AS REFD_RATE_DOD_KRW      /* 일환불금액 증감률     - 원화   */

              ,B.SALE_AMT_MNTH_RMB                                                                          AS SALE_AMT_MNTH_RMB      /* 월매출금액(누적)        - 위안화 */
              ,B.REFD_AMT_MNTH_RMB                                                                          AS REFD_AMT_MNTH_RMB      /* 월매환불액(누적)        - 위안화 */
              ,B.SALE_AMT_MNTH_KRW                                                                          AS SALE_AMT_MNTH_KRW      /* 월매출금액(누적)        - 원화   */
              ,B.REFD_AMT_MNTH_KRW                                                                          AS REFD_AMT_MNTH_KRW      /* 월매환불액(누적)        - 원화   */
              ,(B.SALE_AMT_MNTH_RMB - COALESCE(E.SALE_AMT_MNTH_YOY_RMB, 0)) / E.SALE_AMT_MNTH_YOY_RMB * 100 AS SALE_RATE_MNTH_YOY_RMB /* 월매출금액(누적) 증감률 - 위안화 */
              ,(B.REFD_AMT_MNTH_RMB - COALESCE(E.REFD_AMT_MNTH_YOY_RMB, 0)) / E.REFD_AMT_MNTH_YOY_RMB * 100 AS REFD_RATE_MNTH_YOY_RMB /* 월환불금액(누적) 증감률 - 위안화 */
              ,(B.SALE_AMT_MNTH_KRW - COALESCE(E.SALE_AMT_MNTH_YOY_KRW, 0)) / E.SALE_AMT_MNTH_YOY_KRW * 100 AS SALE_RATE_MNTH_YOY_KRW /* 월매출금액(누적) 증감률 - 원화   */
              ,(B.REFD_AMT_MNTH_KRW - COALESCE(E.REFD_AMT_MNTH_YOY_KRW, 0)) / E.REFD_AMT_MNTH_YOY_KRW * 100 AS REFD_RATE_MNTH_YOY_KRW /* 월환불금액(누적) 증감률 - 원화   */

              ,C.SALE_AMT_YEAR_RMB                                                                          AS SALE_AMT_YEAR_RMB      /* 연매출금액(누적)        - 위안화 */
              ,C.REFD_AMT_YEAR_RMB                                                                          AS REFD_AMT_YEAR_RMB      /* 연환불금액(누적)        - 위안화 */
              ,C.SALE_AMT_YEAR_KRW                                                                          AS SALE_AMT_YEAR_KRW      /* 연매출금액(누적)        - 원화   */
              ,C.REFD_AMT_YEAR_KRW                                                                          AS REFD_AMT_YEAR_KRW      /* 연환불금액(누적)        - 원화   */
              ,(C.SALE_AMT_YEAR_RMB - COALESCE(F.SALE_AMT_YEAR_YOY_RMB, 0)) / F.SALE_AMT_YEAR_YOY_RMB * 100 AS SALE_RATE_YEAR_YOY_RMB /* 연매출금액(누적) 증감률 - 위안화 */
              ,(C.REFD_AMT_YEAR_RMB - COALESCE(F.REFD_AMT_YEAR_YOY_RMB, 0)) / F.REFD_AMT_YEAR_YOY_RMB * 100 AS REFD_RATE_YEAR_YOY_RMB /* 연환불금액(누적) 증감률 - 위안화 */
              ,(C.SALE_AMT_YEAR_KRW - COALESCE(F.SALE_AMT_YEAR_YOY_KRW, 0)) / F.SALE_AMT_YEAR_YOY_KRW * 100 AS SALE_RATE_YEAR_YOY_KRW /* 연매출금액(누적) 증감률 - 원화   */
              ,(C.REFD_AMT_YEAR_KRW - COALESCE(F.REFD_AMT_YEAR_YOY_KRW, 0)) / F.REFD_AMT_YEAR_YOY_KRW * 100 AS REFD_RATE_YEAR_YOY_KRW /* 연환불금액(누적) 증감률 - 원화   */

              ,D.SALE_AMT_DOD_RMB                                                                           AS SALE_AMT_DOD_RMB       /* 일매출금액       DoD - 위안화 */
              ,D.REFD_AMT_DOD_RMB                                                                           AS REFD_AMT_DOD_RMB       /* 일환불금액       DoD - 위안화 */
              ,D.SALE_AMT_DOD_KRW                                                                           AS SALE_AMT_DOD_KRW       /* 일매출금액       DoD - 원화   */
              ,D.REFD_AMT_DOD_KRW                                                                           AS REFD_AMT_DOD_KRW       /* 일환불금액       DoD - 원화   */

              ,E.SALE_AMT_MNTH_YOY_RMB                                                                      AS SALE_AMT_MNTH_YOY_RMB  /* 월매출금액(누적) YoY - 위안화 */
              ,E.REFD_AMT_MNTH_YOY_RMB                                                                      AS REFD_AMT_MNTH_YOY_RMB  /* 월매환불액(누적) YoY - 위안화 */
              ,E.SALE_AMT_MNTH_YOY_KRW                                                                      AS SALE_AMT_MNTH_YOY_KRW  /* 월매출금액(누적) YoY - 원화   */
              ,E.REFD_AMT_MNTH_YOY_KRW                                                                      AS REFD_AMT_MNTH_YOY_KRW  /* 월매환불액(누적) YoY - 원화   */

              ,F.SALE_AMT_YEAR_YOY_RMB                                                                      AS SALE_AMT_YEAR_YOY_RMB  /* 연매출금액(누적) YoY - 위안화 */
              ,F.REFD_AMT_YEAR_YOY_RMB                                                                      AS REFD_AMT_YEAR_YOY_RMB  /* 연환불금액(누적) YoY - 위안화 */
              ,F.SALE_AMT_YEAR_YOY_KRW                                                                      AS SALE_AMT_YEAR_YOY_KRW  /* 연매출금액(누적) YoY - 원화   */
              ,F.REFD_AMT_YEAR_YOY_KRW                                                                      AS REFD_AMT_YEAR_YOY_KRW  /* 연환불금액(누적) YoY - 원화   */

              ,G.BRND_RANK
              ,G.BRND_RANK_MOM
              ,G.BRND_RANK_KR
              ,G.BRND_RANK_KR_MOM

              ,H.REVN_TAGT_AMT
              ,C.SALE_AMT_YEAR_KRW / H.REVN_TAGT_AMT * 100 AS REVN_TAGT_RATE
          FROM WT_SALE_DAY      A
              ,WT_SALE_MNTH     B
              ,WT_SALE_YEAR     C
              ,WT_SALE_DAY_DOD  D
              ,WT_SALE_MNTH_YOY E
              ,WT_SALE_YEAR_YOY F
              ,WT_RANK          G
              ,WT_REVN_TAGT     H
    )
    SELECT COALESCE(CAST(SALE_AMT_RMB            AS DECIMAL(20,0)), 0) AS SALE_AMT_RMB            /* 일매출금액            - 위안화 */
          ,COALESCE(CAST(REFD_AMT_RMB            AS DECIMAL(20,0)), 0) AS REFD_AMT_RMB            /* 일환불금액            - 위안화 */
          ,COALESCE(CAST(SALE_AMT_KRW            AS DECIMAL(20,0)), 0) AS SALE_AMT_KRW            /* 일매출금액            - 원화   */
          ,COALESCE(CAST(REFD_AMT_KRW            AS DECIMAL(20,0)), 0) AS REFD_AMT_KRW            /* 일환불금액            - 원화   */
          ,COALESCE(CAST(SALE_RATE_DOD_RMB       AS DECIMAL(20,2)), 0) AS SALE_RATE_DOD_RMB       /* 일매출금액 증감률     - 위안화 */
          ,COALESCE(CAST(REFD_RATE_DOD_RMB       AS DECIMAL(20,2)), 0) AS REFD_RATE_DOD_RMB       /* 일환불금액 증감률     - 위안화 */
          ,COALESCE(CAST(SALE_RATE_DOD_KRW       AS DECIMAL(20,2)), 0) AS SALE_RATE_DOD_KRW       /* 일매출금액 증감률     - 원화   */
          ,COALESCE(CAST(REFD_RATE_DOD_KRW       AS DECIMAL(20,2)), 0) AS REFD_RATE_DOD_KRW       /* 일환불금액 증감률     - 원화   */

          ,COALESCE(CAST(SALE_AMT_MNTH_RMB       AS DECIMAL(20,0)), 0) AS SALE_AMT_MNTH_RMB       /* 월매출금액(누적)        - 위안화 */
          ,COALESCE(CAST(REFD_AMT_MNTH_RMB       AS DECIMAL(20,0)), 0) AS REFD_AMT_MNTH_RMB       /* 월매환불액(누적)        - 위안화 */
          ,COALESCE(CAST(SALE_AMT_MNTH_KRW       AS DECIMAL(20,0)), 0) AS SALE_AMT_MNTH_KRW       /* 월매출금액(누적)        - 원화   */
          ,COALESCE(CAST(REFD_AMT_MNTH_KRW       AS DECIMAL(20,0)), 0) AS REFD_AMT_MNTH_KRW       /* 월매환불액(누적)        - 원화   */
          ,COALESCE(CAST(SALE_RATE_MNTH_YOY_RMB  AS DECIMAL(20,2)), 0) AS SALE_RATE_MNTH_YOY_RMB  /* 월매출금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(REFD_RATE_MNTH_YOY_RMB  AS DECIMAL(20,2)), 0) AS REFD_RATE_MNTH_YOY_RMB  /* 월환불금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_MNTH_YOY_KRW  AS DECIMAL(20,2)), 0) AS SALE_RATE_MNTH_YOY_KRW  /* 월매출금액(누적) 증감률 - 원화   */
          ,COALESCE(CAST(REFD_RATE_MNTH_YOY_KRW  AS DECIMAL(20,2)), 0) AS REFD_RATE_MNTH_YOY_KRW  /* 월환불금액(누적) 증감률 - 원화   */

          ,COALESCE(CAST(SALE_AMT_YEAR_RMB       AS DECIMAL(20,0)), 0) AS SALE_AMT_YEAR_RMB       /* 연매출금액(누적)        - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YEAR_RMB       AS DECIMAL(20,0)), 0) AS REFD_AMT_YEAR_RMB       /* 연환불금액(누적)        - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YEAR_KRW       AS DECIMAL(20,0)), 0) AS SALE_AMT_YEAR_KRW       /* 연매출금액(누적)        - 원화   */
          ,COALESCE(CAST(REFD_AMT_YEAR_KRW       AS DECIMAL(20,0)), 0) AS REFD_AMT_YEAR_KRW       /* 연환불금액(누적)        - 원화   */
          ,COALESCE(CAST(SALE_RATE_YEAR_YOY_RMB  AS DECIMAL(20,2)), 0) AS SALE_RATE_YEAR_YOY_RMB  /* 연매출금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(REFD_RATE_YEAR_YOY_RMB  AS DECIMAL(20,2)), 0) AS REFD_RATE_YEAR_YOY_RMB  /* 연환불금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_YEAR_YOY_KRW  AS DECIMAL(20,2)), 0) AS SALE_RATE_YEAR_YOY_KRW  /* 연매출금액(누적) 증감률 - 원화   */
          ,COALESCE(CAST(REFD_RATE_YEAR_YOY_KRW  AS DECIMAL(20,2)), 0) AS REFD_RATE_YEAR_YOY_KRW  /* 연환불금액(누적) 증감률 - 원화   */

          ,COALESCE(CAST(SALE_AMT_DOD_RMB        AS DECIMAL(20,0)), 0) AS SALE_AMT_DOD_RMB        /* 일매출금액       DoD - 위안화 */
          ,COALESCE(CAST(REFD_AMT_DOD_RMB        AS DECIMAL(20,0)), 0) AS REFD_AMT_DOD_RMB        /* 일환불금액       DoD - 위안화 */
          ,COALESCE(CAST(SALE_AMT_DOD_KRW        AS DECIMAL(20,0)), 0) AS SALE_AMT_DOD_KRW        /* 일매출금액       DoD - 원화   */
          ,COALESCE(CAST(REFD_AMT_DOD_KRW        AS DECIMAL(20,0)), 0) AS REFD_AMT_DOD_KRW        /* 일환불금액       DoD - 원화   */

          ,COALESCE(CAST(SALE_AMT_MNTH_YOY_RMB   AS DECIMAL(20,0)), 0) AS SALE_AMT_MNTH_YOY_RMB    /* 월매출금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(REFD_AMT_MNTH_YOY_RMB   AS DECIMAL(20,0)), 0) AS REFD_AMT_MNTH_YOY_RMB    /* 월매환불액(누적) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_MNTH_YOY_KRW   AS DECIMAL(20,0)), 0) AS SALE_AMT_MNTH_YOY_KRW    /* 월매출금액(누적) YoY - 원화   */
          ,COALESCE(CAST(REFD_AMT_MNTH_YOY_KRW   AS DECIMAL(20,0)), 0) AS REFD_AMT_MNTH_YOY_KRW    /* 월매환불액(누적) YoY - 원화   */

          ,COALESCE(CAST(SALE_AMT_YEAR_YOY_RMB   AS DECIMAL(20,0)), 0) AS SALE_AMT_YEAR_YOY_RMB    /* 연매출금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YEAR_YOY_RMB   AS DECIMAL(20,0)), 0) AS REFD_AMT_YEAR_YOY_RMB    /* 연환불금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YEAR_YOY_KRW   AS DECIMAL(20,0)), 0) AS SALE_AMT_YEAR_YOY_KRW    /* 연매출금액(누적) YoY - 원화   */
          ,COALESCE(CAST(REFD_AMT_YEAR_YOY_KRW   AS DECIMAL(20,0)), 0) AS REFD_AMT_YEAR_YOY_KRW    /* 연환불금액(누적) YoY - 원화   */

          ,COALESCE(CAST(BRND_RANK               AS TEXT         ), '') AS BRND_RANK               /* 브랜드 매출 순위     - 순위      */
          ,COALESCE(CAST(BRND_RANK_MOM           AS TEXT         ), '') AS BRND_RANK_MOM           /* 브랜드 매출 순위     - 순위 변화 */
          ,COALESCE(CAST(BRND_RANK_KR            AS TEXT         ), '') AS BRND_RANK_KR            /* 한국브랜드 매출 순위 - 순위      */
          ,COALESCE(CAST(BRND_RANK_KR_MOM        AS TEXT         ), '') AS BRND_RANK_KR_MOM        /* 한국브랜드 매출 순위 - 순위 변화 */

          ,COALESCE(CAST(REVN_TAGT_AMT           AS DECIMAL(20,0)), 0) AS REVN_TAGT_AMT            /* 당해 Target 대비 누적 매출 금액 - 원화   */
          ,COALESCE(CAST(REVN_TAGT_RATE          AS DECIMAL(20,2)), 0) AS REVN_TAGT_RATE           /* 당해 Target 대비 누적 매출 비중 - 원화   */
      FROM WT_BASE