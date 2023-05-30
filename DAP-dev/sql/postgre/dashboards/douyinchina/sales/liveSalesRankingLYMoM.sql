/* 11. 라이브별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 SQL */
/*     최종 화면에 표시할 컬럼 (등수 : SALE_RANK, 작년 라이브명 : LIVE_NM_YOY_RMB 또는 LIVE_NM_YOY_KRW,  올해 라이브명 : LIVE_NM_RMB 또는 LIVE_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT {BASE_MNTH}  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
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
    ),  WT_TOTL AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_CAST AS
    (
        SELECT ACCOUNT_NAME
              ,TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,CAST(LIVE_TRANSACTION_AMOUNT_YUAN AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_ACCOUNT_COMPOSITION A
         WHERE TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_CAST_YOY AS
    (
        SELECT ACCOUNT_NAME
              ,TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,CAST(LIVE_TRANSACTION_AMOUNT_YUAN AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_ACCOUNT_COMPOSITION A
         WHERE TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_EXCH AS
    (
        SELECT ACCOUNT_NAME
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY ACCOUNT_NAME
    ), WT_EXCH_YOY AS
    (
        SELECT ACCOUNT_NAME
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 YoY - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY ACCOUNT_NAME
    ), WT_RANK AS
    (
        SELECT ACCOUNT_NAME
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, ACCOUNT_NAME) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, ACCOUNT_NAME) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT ACCOUNT_NAME
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, ACCOUNT_NAME) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, ACCOUNT_NAME) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'      AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,SALE_RANK_RMB   AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB    AS SALE_AMT   /* 매출금액 -      위안화 */
              ,ACCOUNT_NAME
          FROM WT_RANK A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'      AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,SALE_RANK_KRW   AS SALE_RANK  /* 매출순위 -      원화   */
              ,SALE_AMT_KRW    AS SALE_AMT   /* 매출금액 -      원화   */
              ,ACCOUNT_NAME
          FROM WT_RANK A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB'  AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,SALE_RANK_RMB   AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB    AS SALE_AMT   /* 매출금액 -      위안화 */
              ,ACCOUNT_NAME
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW'  AS RANK_TYPE /* 순위     - 전년 원화   */
              ,SALE_RANK_KRW   AS SALE_RANK /* 매출순위 -      원화   */
              ,SALE_AMT_KRW    AS SALE_AMT  /* 매출금액 -      원화   */
              ,ACCOUNT_NAME
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK                                                          /* 순위                   */
              ,COALESCE(CAST(D.ACCOUNT_NAME AS VARCHAR), '') AS ACCONT_NM_YOY_RMB   /* 전년 라이브ID   - 위안화 */
              ,D.ACCOUNT_NAME                                AS ACCOUNT_NM_YOY_RMB  /* 전년 라이브명   - 위안화 */
              ,D.SALE_AMT                                  AS SALE_AMT_YOY_RMB      /* 전년 매출액   - 위안화 */
              ,D.SALE_AMT / Y.SALE_AMT_RMB  * 100          AS SALE_RATE_YOY_RMB     /* 전년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(B.ACCOUNT_NAME AS VARCHAR), '') AS ACCONT_NM_RMB       /* 금년 라이브ID   - 위안화 */
              ,B.ACCOUNT_NAME                                AS ACCOUNT_NM_RMB      /* 금년 라이브명   - 위안화 */
              ,B.SALE_AMT                                  AS SALE_AMT_RMB          /* 금년 매출액   - 위안화 */
              ,B.SALE_AMT / T.SALE_AMT_RMB  * 100          AS SALE_RATE_RMB         /* 금년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(E.ACCOUNT_NAME AS VARCHAR), '') AS ACCONT_NM_YOY_KRW   /* 전년 라이브ID   - 원화    */
              ,E.ACCOUNT_NAME                                AS ACCOUNT_NM_YOY_KRW  /* 전년 라이브명   - 원화    */
              ,E.SALE_AMT                                  AS SALE_AMT_YOY_KRW      /* 전년 매출액   - 원화    */
              ,E.SALE_AMT / Y.SALE_AMT_KRW  * 100          AS SALE_RATE_YOY_KRW     /* 전년 매출비중 - 원화    */
    
              ,COALESCE(CAST(C.ACCOUNT_NAME AS VARCHAR), '') AS ACCONT_NM_KRW       /* 금년 라이브ID   - 원화    */
              ,C.ACCOUNT_NAME                                AS ACCOUNT_NM_KRW      /* 금년 라이브명   - 원화    */
              ,C.SALE_AMT                                  AS SALE_AMT_KRW          /* 금년 매출액   - 원화    */
              ,C.SALE_AMT / T.SALE_AMT_KRW  * 100          AS SALE_RATE_KRW         /* 금년 매출비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.SALE_RANK = B.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.SALE_RANK = C.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.SALE_RANK = D.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.SALE_RANK = E.SALE_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT SALE_RANK                                                                      AS SALE_RANK          /* 순위                   */
          ,ACCONT_NM_YOY_RMB                                                                                    /* 전년 라이브ID - 위안화 */
          ,ACCOUNT_NM_YOY_RMB                                                             AS LIVE_NM_YOY_RMB    /* 전년 라이브명 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_RMB  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_YOY_RMB   /* 전년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_RMB  /* 전년 매출비중 - 위안화 */
          ,ACCONT_NM_RMB                                                                                        /* 금년 라이브ID - 위안화 */
          ,ACCOUNT_NM_RMB                                                                 AS LIVE_NM_RMB        /* 금년 라이브명 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_RMB      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_RMB       /* 금년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_RMB      /* 금년 매출비중 - 위안화 */

          ,ACCONT_NM_YOY_KRW                                                                                    /* 전년 라이브ID - 원화 */
          ,ACCOUNT_NM_YOY_KRW                                                             AS LIVE_NM_YOY_KRW    /* 전년 라이브명 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_KRW  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_YOY_KRW   /* 전년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_KRW  /* 전년 매출비중 - 원화 */
          ,ACCONT_NM_KRW                                                                                        /* 금년 라이브ID - 원화 */
          ,ACCOUNT_NM_KRW                                                                 AS LIVE_NM_KRW        /* 금년 라이브명 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_KRW      AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS SALE_AMT_KRW       /* 금년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_KRW      /* 금년 매출비중 - 원화 */
      FROM WT_BASE
  ORDER BY SALE_RANK
