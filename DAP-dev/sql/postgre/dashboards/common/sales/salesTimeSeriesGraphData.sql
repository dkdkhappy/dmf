/* 2. 매출정보에 대한 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
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
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH_YOY AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           YoY - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) YoY - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           YoY - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) YoY - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_RMB  /* 일매출           - 위안화 */
              ,SUM(EXRE_AMT_RMB) AS EXRE_AMT_RMB  /* 일매출(환불제외) - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW  /* 일매출           - 원화   */
              ,SUM(EXRE_AMT_KRW) AS EXRE_AMT_KRW  /* 일매출(환불제외) - 원화   */
          FROM WT_EXCH A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_YOY_RMB  /* 일매출           YoY - 위안화 */
              ,SUM(EXRE_AMT_RMB) AS EXRE_AMT_YOY_RMB  /* 일매출(환불제외) YoY - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_YOY_KRW  /* 일매출           YoY - 원화   */
              ,SUM(EXRE_AMT_KRW) AS EXRE_AMT_YOY_KRW  /* 일매출(환불제외) YoY - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
        SELECT SALE_AMT_RMB     AS SALE_AMT_RMB      /* 당해 누적금액               - 위안화 */
              ,EXRE_AMT_RMB     AS EXRE_AMT_RMB      /* 당해 누적금액(환불제외)     - 위안화 */
              ,SALE_AMT_KRW     AS SALE_AMT_KRW      /* 당해 누적금액               - 원화   */
              ,EXRE_AMT_KRW     AS EXRE_AMT_KRW      /* 당해 누적금액(환불제외)     - 원화   */
              
              ,SALE_AMT_YOY_RMB AS SALE_AMT_YOY_RMB  /* 전년도 누적금액           YoY - 위안화 */
              ,EXRE_AMT_YOY_RMB AS EXRE_AMT_YOY_RMB  /* 전년도 누적금액(환불제외) YoY - 위안화 */
              ,SALE_AMT_YOY_KRW AS SALE_AMT_YOY_KRW  /* 전년도 누적금액           YoY - 원화   */
              ,EXRE_AMT_YOY_KRW AS EXRE_AMT_YOY_KRW  /* 전년도 누적금액(환불제외) YoY - 원화   */

              ,(A.SALE_AMT_RMB - COALESCE(B.SALE_AMT_YOY_RMB, 0)) / B.SALE_AMT_YOY_RMB * 100 AS SALE_RATE_RMB  /* 매출           증감률 - 위안화 */
              ,(A.EXRE_AMT_RMB - COALESCE(B.EXRE_AMT_YOY_RMB, 0)) / B.EXRE_AMT_YOY_RMB * 100 AS EXRE_RATE_RMB  /* 매출(환불제외) 증감률 - 위안화 */
              ,(A.SALE_AMT_KRW - COALESCE(B.SALE_AMT_YOY_KRW, 0)) / B.SALE_AMT_YOY_KRW * 100 AS SALE_RATE_KRW  /* 매출           증감률 - 원화   */
              ,(A.EXRE_AMT_KRW - COALESCE(B.EXRE_AMT_YOY_KRW, 0)) / B.EXRE_AMT_YOY_KRW * 100 AS EXRE_RATE_KRW  /* 매출(환불제외) 증감률 - 원화   */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(SALE_AMT_RMB     AS DECIMAL(20,0)), 0) AS SALE_AMT_RMB      /* 당해 누적금액               - 위안화 */
          ,COALESCE(CAST(EXRE_AMT_RMB     AS DECIMAL(20,0)), 0) AS EXRE_AMT_RMB      /* 당해 누적금액(환불제외)     - 위안화 */
          ,COALESCE(CAST(SALE_AMT_KRW     AS DECIMAL(20,0)), 0) AS SALE_AMT_KRW      /* 당해 누적금액               - 원화   */
          ,COALESCE(CAST(EXRE_AMT_KRW     AS DECIMAL(20,0)), 0) AS EXRE_AMT_KRW      /* 당해 누적금액(환불제외)     - 원화   */

          ,COALESCE(CAST(SALE_AMT_YOY_RMB AS DECIMAL(20,0)), 0) AS SALE_AMT_YOY_RMB  /* 전년도 누적금액           YoY - 위안화 */
          ,COALESCE(CAST(EXRE_AMT_YOY_RMB AS DECIMAL(20,0)), 0) AS EXRE_AMT_YOY_RMB  /* 전년도 누적금액(환불제외) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YOY_KRW AS DECIMAL(20,0)), 0) AS SALE_AMT_YOY_KRW  /* 전년도 누적금액           YoY - 원화   */
          ,COALESCE(CAST(EXRE_AMT_YOY_KRW AS DECIMAL(20,0)), 0) AS EXRE_AMT_YOY_KRW  /* 전년도 누적금액(환불제외) YoY - 원화   */

          ,COALESCE(CAST(SALE_RATE_RMB    AS DECIMAL(20,2)), 0) AS SALE_RATE_RMB     /* 매출           증감률 - 위안화 */
          ,COALESCE(CAST(EXRE_RATE_RMB    AS DECIMAL(20,2)), 0) AS EXRE_RATE_RMB     /* 매출(환불제외) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_KRW    AS DECIMAL(20,2)), 0) AS SALE_RATE_KRW     /* 매출           증감률 - 원화   */
          ,COALESCE(CAST(EXRE_RATE_KRW    AS DECIMAL(20,2)), 0) AS EXRE_RATE_KRW     /* 매출(환불제외) 증감률 - 원화   */
      FROM WT_BASE