/* 17. 제품별 구매 전환율 Top 5 - 월별 구매 전환율 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS ORDR_RANK
     UNION ALL
        SELECT 2 AS ORDR_RANK
     UNION ALL
        SELECT 3 AS ORDR_RANK
     UNION ALL
        SELECT 4 AS ORDR_RANK
     UNION ALL
        SELECT 5 AS ORDR_RANK
    ), WT_ORDR AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')  AS RANK_MNTH
              ,PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY ORDR_VAL DESC, PRODUCT_ID) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL  /* 구매 전환율 */
          FROM WT_ORDR A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND ORDR_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                               AS RANK_TYPE  /* 순위             */
              ,ORDR_RANK                               AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                AS ORDR_VAL   /* 구매 전환율      */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명           */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND ORDR_RANK <= 5
    )
    SELECT A.ORDR_RANK                                                      /* 순위        */
          ,COALESCE(CAST(RANK_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01  /* 01월 제품ID */
          ,COALESCE(CAST(RANK_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02  /* 02월 제품ID */
          ,COALESCE(CAST(RANK_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03  /* 03월 제품ID */
          ,COALESCE(CAST(RANK_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04  /* 04월 제품ID */
          ,COALESCE(CAST(RANK_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05  /* 05월 제품ID */
          ,COALESCE(CAST(RANK_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06  /* 06월 제품ID */
          ,COALESCE(CAST(RANK_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07  /* 07월 제품ID */
          ,COALESCE(CAST(RANK_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08  /* 08월 제품ID */
          ,COALESCE(CAST(RANK_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09  /* 09월 제품ID */
          ,COALESCE(CAST(RANK_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10  /* 10월 제품ID */
          ,COALESCE(CAST(RANK_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11  /* 11월 제품ID */
          ,COALESCE(CAST(RANK_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12  /* 12월 제품ID */

          ,COALESCE(CAST(RANK_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01  /* 01월 제품명 */
          ,COALESCE(CAST(RANK_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02  /* 02월 제품명 */
          ,COALESCE(CAST(RANK_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03  /* 03월 제품명 */
          ,COALESCE(CAST(RANK_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04  /* 04월 제품명 */
          ,COALESCE(CAST(RANK_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05  /* 05월 제품명 */
          ,COALESCE(CAST(RANK_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06  /* 06월 제품명 */
          ,COALESCE(CAST(RANK_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07  /* 07월 제품명 */
          ,COALESCE(CAST(RANK_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08  /* 08월 제품명 */
          ,COALESCE(CAST(RANK_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09  /* 09월 제품명 */
          ,COALESCE(CAST(RANK_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10  /* 10월 제품명 */
          ,COALESCE(CAST(RANK_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11  /* 11월 제품명 */
          ,COALESCE(CAST(RANK_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12  /* 12월 제품명 */

          ,CAST(RANK_01.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_01 /* 01월 구매 전환율 */
          ,CAST(RANK_02.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_02 /* 02월 구매 전환율 */
          ,CAST(RANK_03.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_03 /* 03월 구매 전환율 */
          ,CAST(RANK_04.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_04 /* 04월 구매 전환율 */
          ,CAST(RANK_05.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_05 /* 05월 구매 전환율 */
          ,CAST(RANK_06.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_06 /* 06월 구매 전환율 */
          ,CAST(RANK_07.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_07 /* 07월 구매 전환율 */
          ,CAST(RANK_08.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_08 /* 08월 구매 전환율 */
          ,CAST(RANK_09.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_09 /* 09월 구매 전환율 */
          ,CAST(RANK_10.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_10 /* 10월 구매 전환율 */
          ,CAST(RANK_11.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_11 /* 11월 구매 전환율 */
          ,CAST(RANK_12.ORDR_VAL AS DECIMAL(20,2))           AS ORDR_VAL_12 /* 12월 구매 전환율 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.ORDR_RANK = RANK_01.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.ORDR_RANK = RANK_02.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.ORDR_RANK = RANK_03.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.ORDR_RANK = RANK_04.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.ORDR_RANK = RANK_05.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.ORDR_RANK = RANK_06.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.ORDR_RANK = RANK_07.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.ORDR_RANK = RANK_08.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.ORDR_RANK = RANK_09.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.ORDR_RANK = RANK_10.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.ORDR_RANK = RANK_11.ORDR_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.ORDR_RANK = RANK_12.ORDR_RANK)
  ORDER BY A.ORDR_RANK