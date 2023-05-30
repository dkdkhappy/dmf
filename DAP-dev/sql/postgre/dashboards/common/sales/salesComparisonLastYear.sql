/* 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 SQL */
/*    금년 매출금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년 매출금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 YoY - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'     AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,SALE_RANK_RMB  AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB   AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'     AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,SALE_RANK_KRW  AS SALE_RANK  /* 매출순위 -      원화   */
              ,SALE_AMT_KRW   AS SALE_AMT   /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB' AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,SALE_RANK_RMB  AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB   AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW' AS RANK_TYPE /* 순위     - 전년 원화   */
              ,SALE_RANK_KRW  AS SALE_RANK /* 매출순위 -      원화   */
              ,SALE_AMT_KRW   AS SALE_AMT  /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_{TAG}_PROD_NM(D.PRODUCT_ID)     AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.SALE_AMT                                  AS SALE_AMT_YOY_RMB  /* 전년 매출액   - 위안화 */
              ,D.SALE_AMT / Y.SALE_AMT_RMB  * 100          AS SALE_RATE_YOY_RMB /* 전년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_{TAG}_PROD_NM(B.PRODUCT_ID)     AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.SALE_AMT                                  AS SALE_AMT_RMB      /* 금년 매출액   - 위안화 */
              ,B.SALE_AMT / T.SALE_AMT_RMB  * 100          AS SALE_RATE_RMB     /* 금년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_{TAG}_PROD_NM(E.PRODUCT_ID)     AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.SALE_AMT                                  AS SALE_AMT_YOY_KRW  /* 전년 매출액   - 원화    */
              ,E.SALE_AMT / Y.SALE_AMT_KRW  * 100          AS SALE_RATE_YOY_KRW /* 전년 매출비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_{TAG}_PROD_NM(C.PRODUCT_ID)     AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.SALE_AMT                                  AS SALE_AMT_KRW      /* 금년 매출액   - 원화    */
              ,C.SALE_AMT / T.SALE_AMT_KRW  * 100          AS SALE_RATE_KRW     /* 금년 매출비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.SALE_RANK = B.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.SALE_RANK = C.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.SALE_RANK = D.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.SALE_RANK = E.SALE_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT SALE_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_RMB  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_YOY_RMB   /* 전년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_RMB  /* 전년 매출비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_RMB      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_RMB       /* 금년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_RMB      /* 금년 매출비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_KRW  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_YOY_KRW   /* 전년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_KRW  /* 전년 매출비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_KRW      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_KRW       /* 금년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_KRW      /* 금년 매출비중 - 원화 */
      FROM WT_BASE
  ORDER BY SALE_RANK
