/* 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 SQL      */
/*     금년 환불금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*     전년 환불금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS REFD_RANK
     UNION ALL
        SELECT 2 AS REFD_RANK
     UNION ALL
        SELECT 3 AS REFD_RANK
     UNION ALL
        SELECT 4 AS REFD_RANK
     UNION ALL
        SELECT 5 AS REFD_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 YoY - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'       AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,REFD_RANK_RMB    AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB     AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'       AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,REFD_RANK_KRW    AS REFD_RANK  /* 환불순위 -      원화   */
              ,REFD_AMT_KRW     AS REFD_AMT   /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB'   AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,REFD_RANK_RMB    AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB     AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW'   AS RANK_TYPE /* 순위     - 전년 원화   */
              ,REFD_RANK_KRW    AS REFD_RANK /* 환불순위 -      원화   */
              ,REFD_AMT_KRW     AS REFD_AMT  /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.REFD_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_{TAG}_PROD_NM(D.PRODUCT_ID)     AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.REFD_AMT                                  AS REFD_AMT_YOY_RMB  /* 전년 환불액   - 위안화 */
              ,D.REFD_AMT / Y.REFD_AMT_RMB  * 100          AS REFD_RATE_YOY_RMB /* 전년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_{TAG}_PROD_NM(B.PRODUCT_ID)     AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.REFD_AMT                                  AS REFD_AMT_RMB      /* 금년 환불액   - 위안화 */
              ,B.REFD_AMT / T.REFD_AMT_RMB  * 100          AS REFD_RATE_RMB     /* 금년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_{TAG}_PROD_NM(E.PRODUCT_ID)     AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.REFD_AMT                                  AS REFD_AMT_YOY_KRW  /* 전년 환불액   - 원화    */
              ,E.REFD_AMT / Y.REFD_AMT_KRW  * 100          AS REFD_RATE_YOY_KRW /* 전년 환불비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_{TAG}_PROD_NM(C.PRODUCT_ID)     AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.REFD_AMT                                  AS REFD_AMT_KRW      /* 금년 환불액   - 원화    */
              ,C.REFD_AMT / T.REFD_AMT_KRW  * 100          AS REFD_RATE_KRW     /* 금년 환불비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.REFD_RANK = B.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.REFD_RANK = C.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.REFD_RANK = D.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.REFD_RANK = E.REFD_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT REFD_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_RMB  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS REFD_AMT_YOY_RMB   /* 전년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_RMB  /* 전년 환불비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_RMB      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS REFD_AMT_RMB       /* 금년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_RMB      /* 금년 환불비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_KRW  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS REFD_AMT_YOY_KRW   /* 전년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_KRW  /* 전년 환불비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_KRW      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS REFD_AMT_KRW       /* 금년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_KRW      /* 금년 환불비중 - 원화 */
      FROM WT_BASE
  ORDER BY REFD_RANK
