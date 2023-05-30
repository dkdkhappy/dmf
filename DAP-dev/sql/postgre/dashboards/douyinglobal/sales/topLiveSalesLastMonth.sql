/* 11. 라이브별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 SQL */
/*     최종 화면에 표시할 컬럼 (등수 : SALE_RANK, 작년 라이브명 : ACCOUNT_NM_YOY_RMB 또는 ACCOUNT_NM_YOY_KRW,  올해 라이브명 : ACCOUNT_NM_RMB 또는 ACCOUNT_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
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
    ), WT_CAST AS
    (
        SELECT ACCOUNT_NAME
              ,TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,CAST(LIVE_TRANSACTION_AMOUNT_YUAN AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_ACCOUNT_COMPOSITION A
         WHERE TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
    ), WT_EXCH AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,ACCOUNT_NAME
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,ACCOUNT_NAME
    ), WT_RANK_RMB AS
    (
        SELECT RANK_MNTH
              ,ACCOUNT_NAME
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY SALE_AMT_RMB DESC, ACCOUNT_NAME) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
          FROM WT_EXCH A
    ), WT_RANK_KRW AS
    (
        SELECT RANK_MNTH
              ,ACCOUNT_NAME
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY SALE_AMT_KRW DESC, ACCOUNT_NAME) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_BASE_RANK_01_RMB AS
    (
        SELECT 'RANK_01_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME                      AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '01'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_02_RMB AS
    (
        SELECT 'RANK_02_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME                      AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '02'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_03_RMB AS
    (
        SELECT 'RANK_03_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME                      AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '03'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_04_RMB AS
    (
        SELECT 'RANK_04_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '04'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_05_RMB AS
    (
        SELECT 'RANK_05_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '05'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_06_RMB AS
    (
        SELECT 'RANK_06_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '06'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_07_RMB AS
    (
        SELECT 'RANK_07_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '07'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_08_RMB AS
    (
        SELECT 'RANK_08_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '08'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_09_RMB AS
    (
        SELECT 'RANK_09_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '09'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_10_RMB AS
    (
        SELECT 'RANK_10_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '10'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_11_RMB AS
    (
        SELECT 'RANK_11_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '11'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_12_RMB AS
    (
        SELECT 'RANK_12_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '12'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_01_KRW AS
    (
        SELECT 'RANK_01_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '01'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_02_KRW AS
    (
        SELECT 'RANK_02_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '02'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_03_KRW AS
    (
        SELECT 'RANK_03_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '03'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_04_KRW AS
    (
        SELECT 'RANK_04_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '04'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_05_KRW AS
    (
        SELECT 'RANK_05_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '05'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_06_KRW AS
    (
        SELECT 'RANK_06_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '06'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_07_KRW AS
    (
        SELECT 'RANK_07_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '07'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_08_KRW AS
    (
        SELECT 'RANK_08_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '08'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_09_KRW AS
    (
        SELECT 'RANK_09_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '09'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_10_KRW AS
    (
        SELECT 'RANK_10_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '10'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_11_KRW AS
    (
        SELECT 'RANK_11_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '11'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_12_KRW AS
    (
        SELECT 'RANK_12_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,ACCOUNT_NAME
              ,A.ACCOUNT_NAME AS ACCOUNT_NM    /* 라이브명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '12'
           AND SALE_RANK_KRW <= 5
    )
    SELECT A.SALE_RANK                                                              /* 순위                   */
          ,COALESCE(CAST(RMB_01.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_01_RMB  /* 01월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_02.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_02_RMB  /* 02월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_03.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_03_RMB  /* 03월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_04.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_04_RMB  /* 04월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_05.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_05_RMB  /* 05월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_06.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_06_RMB  /* 06월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_07.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_07_RMB  /* 07월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_08.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_08_RMB  /* 08월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_09.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_09_RMB  /* 09월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_10.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_10_RMB  /* 10월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_11.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_11_RMB  /* 11월 라이브ID   - 위안화 */
          ,COALESCE(CAST(RMB_12.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_12_RMB  /* 12월 라이브ID   - 위안화 */

          ,COALESCE(CAST(RMB_01.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_01_RMB  /* 01월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_02.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_02_RMB  /* 02월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_03.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_03_RMB  /* 03월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_04.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_04_RMB  /* 04월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_05.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_05_RMB  /* 05월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_06.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_06_RMB  /* 06월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_07.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_07_RMB  /* 07월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_08.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_08_RMB  /* 08월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_09.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_09_RMB  /* 09월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_10.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_10_RMB  /* 10월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_11.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_11_RMB  /* 11월 라이브명   - 위안화 */
          ,COALESCE(CAST(RMB_12.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_12_RMB  /* 12월 라이브명   - 위안화 */

          ,CAST(RMB_01.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_01_RMB /* 01월 라이브금액 - 위안화 */
          ,CAST(RMB_02.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_02_RMB /* 02월 라이브금액 - 위안화 */
          ,CAST(RMB_03.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_03_RMB /* 03월 라이브금액 - 위안화 */
          ,CAST(RMB_04.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_04_RMB /* 04월 라이브금액 - 위안화 */
          ,CAST(RMB_05.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_05_RMB /* 05월 라이브금액 - 위안화 */
          ,CAST(RMB_06.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_06_RMB /* 06월 라이브금액 - 위안화 */
          ,CAST(RMB_07.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_07_RMB /* 07월 라이브금액 - 위안화 */
          ,CAST(RMB_08.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_08_RMB /* 08월 라이브금액 - 위안화 */
          ,CAST(RMB_09.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_09_RMB /* 09월 라이브금액 - 위안화 */
          ,CAST(RMB_10.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_10_RMB /* 10월 라이브금액 - 위안화 */
          ,CAST(RMB_11.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_11_RMB /* 11월 라이브금액 - 위안화 */
          ,CAST(RMB_12.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_12_RMB /* 12월 라이브금액 - 위안화 */

          ,COALESCE(CAST(KRW_01.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_01_KRW  /* 01월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_02.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_02_KRW  /* 02월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_03.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_03_KRW  /* 03월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_04.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_04_KRW  /* 04월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_05.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_05_KRW  /* 05월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_06.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_06_KRW  /* 06월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_07.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_07_KRW  /* 07월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_08.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_08_KRW  /* 08월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_09.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_09_KRW  /* 09월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_10.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_10_KRW  /* 10월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_11.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_11_KRW  /* 11월 라이브ID   - 원화   */
          ,COALESCE(CAST(KRW_12.ACCOUNT_NAME AS VARCHAR), '') AS ACCOUNT_ID_12_KRW  /* 12월 라이브ID   - 원화   */

          ,COALESCE(CAST(KRW_01.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_01_KRW  /* 01월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_02.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_02_KRW  /* 02월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_03.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_03_KRW  /* 03월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_04.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_04_KRW  /* 04월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_05.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_05_KRW  /* 05월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_06.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_06_KRW  /* 06월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_07.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_07_KRW  /* 07월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_08.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_08_KRW  /* 08월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_09.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_09_KRW  /* 09월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_10.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_10_KRW  /* 10월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_11.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_11_KRW  /* 11월 라이브명   - 원화   */
          ,COALESCE(CAST(KRW_12.ACCOUNT_NM    AS VARCHAR), '') AS ACCOUNT_NM_12_KRW  /* 12월 라이브명   - 원화   */

          ,CAST(KRW_01.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_01_KRW /* 01월 라이브금액 - 원화   */
          ,CAST(KRW_02.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_02_KRW /* 02월 라이브금액 - 원화   */
          ,CAST(KRW_03.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_03_KRW /* 03월 라이브금액 - 원화   */
          ,CAST(KRW_04.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_04_KRW /* 04월 라이브금액 - 원화   */
          ,CAST(KRW_05.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_05_KRW /* 05월 라이브금액 - 원화   */
          ,CAST(KRW_06.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_06_KRW /* 06월 라이브금액 - 원화   */
          ,CAST(KRW_07.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_07_KRW /* 07월 라이브금액 - 원화   */
          ,CAST(KRW_08.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_08_KRW /* 08월 라이브금액 - 원화   */
          ,CAST(KRW_09.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_09_KRW /* 09월 라이브금액 - 원화   */
          ,CAST(KRW_10.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_10_KRW /* 10월 라이브금액 - 원화   */
          ,CAST(KRW_11.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_11_KRW /* 11월 라이브금액 - 원화   */
          ,CAST(KRW_12.SALE_AMT AS DECIMAL(20,0))           AS SALE_AMT_12_KRW /* 12월 라이브금액 - 원화   */
          
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01_RMB RMB_01 ON (A.SALE_RANK = RMB_01.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_RMB RMB_02 ON (A.SALE_RANK = RMB_02.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_RMB RMB_03 ON (A.SALE_RANK = RMB_03.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_RMB RMB_04 ON (A.SALE_RANK = RMB_04.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_RMB RMB_05 ON (A.SALE_RANK = RMB_05.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_RMB RMB_06 ON (A.SALE_RANK = RMB_06.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_RMB RMB_07 ON (A.SALE_RANK = RMB_07.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_RMB RMB_08 ON (A.SALE_RANK = RMB_08.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_RMB RMB_09 ON (A.SALE_RANK = RMB_09.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_RMB RMB_10 ON (A.SALE_RANK = RMB_10.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_RMB RMB_11 ON (A.SALE_RANK = RMB_11.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_RMB RMB_12 ON (A.SALE_RANK = RMB_12.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_01_KRW KRW_01 ON (A.SALE_RANK = KRW_01.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_KRW KRW_02 ON (A.SALE_RANK = KRW_02.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_KRW KRW_03 ON (A.SALE_RANK = KRW_03.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_KRW KRW_04 ON (A.SALE_RANK = KRW_04.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_KRW KRW_05 ON (A.SALE_RANK = KRW_05.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_KRW KRW_06 ON (A.SALE_RANK = KRW_06.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_KRW KRW_07 ON (A.SALE_RANK = KRW_07.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_KRW KRW_08 ON (A.SALE_RANK = KRW_08.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_KRW KRW_09 ON (A.SALE_RANK = KRW_09.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_KRW KRW_10 ON (A.SALE_RANK = KRW_10.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_KRW KRW_11 ON (A.SALE_RANK = KRW_11.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_KRW KRW_12 ON (A.SALE_RANK = KRW_12.SALE_RANK)
  ORDER BY A.SALE_RANK
