/* 4. 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 SQL */
/*    당해   환불금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 환불금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 YoY - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 YoY - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 YoY - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 YoY - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_RMB  /* 일매출 - 위안화 */
              ,SUM(REFD_AMT_RMB) AS REFD_AMT_RMB  /* 일환불 - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW  /* 일매출 - 원화   */
              ,SUM(REFD_AMT_KRW) AS REFD_AMT_KRW  /* 일환불 - 원화   */
          FROM WT_EXCH A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_YOY_RMB  /* 일매출 YoY - 위안화 */
              ,SUM(REFD_AMT_RMB) AS REFD_AMT_YOY_RMB  /* 일환불 YoY - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_YOY_KRW  /* 일매출 YoY - 원화   */
              ,SUM(REFD_AMT_KRW) AS REFD_AMT_YOY_KRW  /* 일환불 YoY - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
      SELECT REFD_AMT_RMB                                                                                           AS REFD_AMT_RMB      /* 당해 환불금액   - 위안화 */
            ,REFD_AMT_YOY_RMB                                                                                       AS REFD_AMT_YOY_RMB  /* 전해 환불금액   - 위안화 */
            ,(A.REFD_AMT_RMB - COALESCE(B.REFD_AMT_YOY_RMB, 0)) / B.REFD_AMT_YOY_RMB * 100                          AS REFD_RATE_RMB     /* 환불금액 증감률 - 위안화 */

            , REFD_AMT_RMB     / SALE_AMT_RMB     * 100                                                             AS PCNT_AMT_RMB      /* 당해 환불 비중  - 위안화 */
            , REFD_AMT_YOY_RMB / SALE_AMT_YOY_RMB * 100                                                             AS PCNT_AMT_YOY_RMB  /* 전해 환불 비중  - 위안화 */
            ,(REFD_AMT_RMB     / SALE_AMT_RMB     * 100) - COALESCE((REFD_AMT_YOY_RMB / SALE_AMT_YOY_RMB * 100), 0) AS PCNT_RATE_RMB     /* 환불금액 증감률 - 위안화 */
            
            ,REFD_AMT_KRW                                                                                           AS REFD_AMT_KRW      /* 당해 환불금액   - 원화   */
            ,REFD_AMT_YOY_KRW                                                                                       AS REFD_AMT_YOY_KRW  /* 전해 환불금액   - 원화   */
            ,(A.REFD_AMT_KRW - COALESCE(B.REFD_AMT_YOY_KRW, 0)) / B.REFD_AMT_YOY_KRW * 100                          AS REFD_RATE_KRW     /* 환불금액 증감률 - 원화   */

            , REFD_AMT_KRW     / SALE_AMT_KRW     * 100                                                             AS PCNT_AMT_KRW      /* 당해 환불 비중  - 원화   */
            , REFD_AMT_YOY_KRW / SALE_AMT_YOY_KRW * 100                                                             AS PCNT_AMT_YOY_KRW  /* 전해 환불 비중  - 원화   */
            ,(REFD_AMT_KRW     / SALE_AMT_KRW     * 100) - COALESCE((REFD_AMT_YOY_KRW / SALE_AMT_YOY_KRW * 100), 0) AS PCNT_RATE_KRW     /* 환불비중 증감률 - 원화   */
         FROM WT_SUM     A
            ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(REFD_AMT_RMB     AS DECIMAL(20,0)), 0) AS REFD_AMT_RMB     /* 당해 환불금액   - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YOY_RMB AS DECIMAL(20,0)), 0) AS REFD_AMT_YOY_RMB /* 전해 환불금액   - 위안화 */
          ,COALESCE(CAST(REFD_RATE_RMB    AS DECIMAL(20,2)), 0) AS REFD_RATE_RMB    /* 환불금액 증감률 - 위안화 */

          ,COALESCE(CAST(PCNT_AMT_RMB     AS DECIMAL(20,0)), 0) AS PCNT_AMT_RMB     /* 당해 환불 비중  - 위안화 */
          ,COALESCE(CAST(PCNT_AMT_YOY_RMB AS DECIMAL(20,0)), 0) AS PCNT_AMT_YOY_RMB /* 전해 환불 비중  - 위안화 */
          ,COALESCE(CAST(PCNT_RATE_RMB    AS DECIMAL(20,2)), 0) AS PCNT_RATE_RMB    /* 환불금액 증감률 - 위안화 */

          ,COALESCE(CAST(REFD_AMT_KRW     AS DECIMAL(20,0)), 0) AS REFD_AMT_KRW     /* 당해 환불금액   - 원화   */
          ,COALESCE(CAST(REFD_AMT_YOY_KRW AS DECIMAL(20,0)), 0) AS REFD_AMT_YOY_KRW /* 전해 환불금액   - 원화   */
          ,COALESCE(CAST(REFD_RATE_KRW    AS DECIMAL(20,2)), 0) AS REFD_RATE_KRW    /* 환불금액 증감률 - 원화   */
          
          ,COALESCE(CAST(PCNT_AMT_KRW     AS DECIMAL(20,0)), 0) AS PCNT_AMT_KRW     /* 당해 환불 비중  - 원화   */
          ,COALESCE(CAST(PCNT_AMT_YOY_KRW AS DECIMAL(20,0)), 0) AS PCNT_AMT_YOY_KRW /* 전해 환불 비중  - 원화   */
          ,COALESCE(CAST(PCNT_RATE_KRW    AS DECIMAL(20,2)), 0) AS PCNT_RATE_KRW    /* 환불비중 증감률 - 원화   */
      FROM WT_BASE
