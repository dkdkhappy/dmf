/* 11. 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 SQL */
/*     최종 화면에 표시할 컬럼 (등수 : REFD_RANK, 작년 제품명 : PROD_NM_YOY_RMB 또는 PROD_NM_YOY_KRW,  올해 제품명 : PROD_NM_RMB 또는 PROD_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
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
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,2)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
    ), WT_EXCH AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK_RMB AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
          FROM WT_EXCH A
    ), WT_RANK_KRW AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
    ), WT_BASE_RANK_01_RMB AS
    (
        SELECT 'RANK_01_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '01'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_02_RMB AS
    (
        SELECT 'RANK_02_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '02'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_03_RMB AS
    (
        SELECT 'RANK_03_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '03'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_04_RMB AS
    (
        SELECT 'RANK_04_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '04'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_05_RMB AS
    (
        SELECT 'RANK_05_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '05'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_06_RMB AS
    (
        SELECT 'RANK_06_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '06'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_07_RMB AS
    (
        SELECT 'RANK_07_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '07'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_08_RMB AS
    (
        SELECT 'RANK_08_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '08'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_09_RMB AS
    (
        SELECT 'RANK_09_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '09'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_10_RMB AS
    (
        SELECT 'RANK_10_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '10'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_11_RMB AS
    (
        SELECT 'RANK_11_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '11'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_12_RMB AS
    (
        SELECT 'RANK_12_RMB'                           AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                           AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                            AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '12'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_01_KRW AS
    (
        SELECT 'RANK_01_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '01'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_02_KRW AS
    (
        SELECT 'RANK_02_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '02'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_03_KRW AS
    (
        SELECT 'RANK_03_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '03'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_04_KRW AS
    (
        SELECT 'RANK_04_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '04'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_05_KRW AS
    (
        SELECT 'RANK_05_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '05'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_06_KRW AS
    (
        SELECT 'RANK_06_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '06'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_07_KRW AS
    (
        SELECT 'RANK_07_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '07'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_08_KRW AS
    (
        SELECT 'RANK_08_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '08'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_09_KRW AS
    (
        SELECT 'RANK_09_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '09'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_10_KRW AS
    (
        SELECT 'RANK_10_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '10'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_11_KRW AS
    (
        SELECT 'RANK_11_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '11'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_12_KRW AS
    (
        SELECT 'RANK_12_KRW'                           AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                           AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                            AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '12'
           AND REFD_RANK_KRW <= 5
    )
    SELECT A.REFD_RANK                                                         /* 순위                   */
          ,COALESCE(CAST(RMB_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_RMB  /* 01월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_RMB  /* 02월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_RMB  /* 03월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_RMB  /* 04월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_RMB  /* 05월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_RMB  /* 06월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_RMB  /* 07월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_RMB  /* 08월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_RMB  /* 09월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_RMB  /* 10월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_RMB  /* 11월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_RMB  /* 12월 제품ID   - 위안화 */

          ,COALESCE(CAST(RMB_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01_RMB  /* 01월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02_RMB  /* 02월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03_RMB  /* 03월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04_RMB  /* 04월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05_RMB  /* 05월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06_RMB  /* 06월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07_RMB  /* 07월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08_RMB  /* 08월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09_RMB  /* 09월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10_RMB  /* 10월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11_RMB  /* 11월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12_RMB  /* 12월 제품명   - 위안화 */

          ,CAST(RMB_01.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_01_RMB /* 01월 제품금액 - 위안화 */
          ,CAST(RMB_02.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_02_RMB /* 02월 제품금액 - 위안화 */
          ,CAST(RMB_03.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_03_RMB /* 03월 제품금액 - 위안화 */
          ,CAST(RMB_04.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_04_RMB /* 04월 제품금액 - 위안화 */
          ,CAST(RMB_05.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_05_RMB /* 05월 제품금액 - 위안화 */
          ,CAST(RMB_06.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_06_RMB /* 06월 제품금액 - 위안화 */
          ,CAST(RMB_07.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_07_RMB /* 07월 제품금액 - 위안화 */
          ,CAST(RMB_08.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_08_RMB /* 08월 제품금액 - 위안화 */
          ,CAST(RMB_09.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_09_RMB /* 09월 제품금액 - 위안화 */
          ,CAST(RMB_10.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_10_RMB /* 10월 제품금액 - 위안화 */
          ,CAST(RMB_11.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_11_RMB /* 11월 제품금액 - 위안화 */
          ,CAST(RMB_12.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_12_RMB /* 12월 제품금액 - 위안화 */

          ,COALESCE(CAST(KRW_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_KRW  /* 01월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_KRW  /* 02월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_KRW  /* 03월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_KRW  /* 04월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_KRW  /* 05월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_KRW  /* 06월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_KRW  /* 07월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_KRW  /* 08월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_KRW  /* 09월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_KRW  /* 10월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_KRW  /* 11월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_KRW  /* 12월 제품ID   - 원화   */

          ,COALESCE(CAST(KRW_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01_KRW  /* 01월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02_KRW  /* 02월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03_KRW  /* 03월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04_KRW  /* 04월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05_KRW  /* 05월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06_KRW  /* 06월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07_KRW  /* 07월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08_KRW  /* 08월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09_KRW  /* 09월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10_KRW  /* 10월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11_KRW  /* 11월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12_KRW  /* 12월 제품명   - 원화   */

          ,CAST(KRW_01.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_01_KRW /* 01월 제품금액 - 원화   */
          ,CAST(KRW_02.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_02_KRW /* 02월 제품금액 - 원화   */
          ,CAST(KRW_03.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_03_KRW /* 03월 제품금액 - 원화   */
          ,CAST(KRW_04.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_04_KRW /* 04월 제품금액 - 원화   */
          ,CAST(KRW_05.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_05_KRW /* 05월 제품금액 - 원화   */
          ,CAST(KRW_06.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_06_KRW /* 06월 제품금액 - 원화   */
          ,CAST(KRW_07.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_07_KRW /* 07월 제품금액 - 원화   */
          ,CAST(KRW_08.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_08_KRW /* 08월 제품금액 - 원화   */
          ,CAST(KRW_09.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_09_KRW /* 09월 제품금액 - 원화   */
          ,CAST(KRW_10.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_10_KRW /* 10월 제품금액 - 원화   */
          ,CAST(KRW_11.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_11_KRW /* 11월 제품금액 - 원화   */
          ,CAST(KRW_12.REFD_AMT AS DECIMAL(20,0))           AS REFD_AMT_12_KRW /* 12월 제품금액 - 원화   */
          
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01_RMB RMB_01 ON (A.REFD_RANK = RMB_01.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_RMB RMB_02 ON (A.REFD_RANK = RMB_02.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_RMB RMB_03 ON (A.REFD_RANK = RMB_03.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_RMB RMB_04 ON (A.REFD_RANK = RMB_04.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_RMB RMB_05 ON (A.REFD_RANK = RMB_05.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_RMB RMB_06 ON (A.REFD_RANK = RMB_06.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_RMB RMB_07 ON (A.REFD_RANK = RMB_07.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_RMB RMB_08 ON (A.REFD_RANK = RMB_08.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_RMB RMB_09 ON (A.REFD_RANK = RMB_09.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_RMB RMB_10 ON (A.REFD_RANK = RMB_10.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_RMB RMB_11 ON (A.REFD_RANK = RMB_11.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_RMB RMB_12 ON (A.REFD_RANK = RMB_12.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_01_KRW KRW_01 ON (A.REFD_RANK = KRW_01.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_KRW KRW_02 ON (A.REFD_RANK = KRW_02.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_KRW KRW_03 ON (A.REFD_RANK = KRW_03.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_KRW KRW_04 ON (A.REFD_RANK = KRW_04.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_KRW KRW_05 ON (A.REFD_RANK = KRW_05.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_KRW KRW_06 ON (A.REFD_RANK = KRW_06.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_KRW KRW_07 ON (A.REFD_RANK = KRW_07.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_KRW KRW_08 ON (A.REFD_RANK = KRW_08.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_KRW KRW_09 ON (A.REFD_RANK = KRW_09.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_KRW KRW_10 ON (A.REFD_RANK = KRW_10.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_KRW KRW_11 ON (A.REFD_RANK = KRW_11.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_KRW KRW_12 ON (A.REFD_RANK = KRW_12.REFD_RANK)
  ORDER BY A.REFD_RANK
