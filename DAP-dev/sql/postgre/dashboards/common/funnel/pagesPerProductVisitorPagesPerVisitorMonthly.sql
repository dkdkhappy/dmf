/* 12. Unique Visitor (UV) 당 Page View (PV) Top 5 제품 - 월별 방문자당 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS PGVW_RANK
     UNION ALL
        SELECT 2 AS PGVW_RANK
     UNION ALL
        SELECT 3 AS PGVW_RANK
     UNION ALL
        SELECT 4 AS PGVW_RANK
     UNION ALL
        SELECT 5 AS PGVW_RANK
    ), WT_PGVW AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')  AS RANK_MNTH
              ,PRODUCT_ID
              ,CASE WHEN SUM(NUMBER_OF_VISITORS) = 0 THEN 0 ELSE SUM(PRODUCT_VIEWS) / SUM(NUMBER_OF_VISITORS) END AS PGVW_CNT  /* 방문자당 페이지뷰수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT  /* 페이지뷰 건수 */
          FROM WT_PGVW A
    ), WT_BASE_RANK_01 AS
    (
        SELECT 'RANK_01'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '01'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_02 AS
    (
        SELECT 'RANK_02'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '02'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_03 AS
    (
        SELECT 'RANK_03'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '03'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_04 AS
    (
        SELECT 'RANK_04'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '04'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_05 AS
    (
        SELECT 'RANK_05'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '05'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_06 AS
    (
        SELECT 'RANK_06'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '06'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_07 AS
    (
        SELECT 'RANK_07'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '07'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_08 AS
    (
        SELECT 'RANK_08'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '08'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_09 AS
    (
        SELECT 'RANK_09'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '09'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_10 AS
    (
        SELECT 'RANK_10'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '10'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_11 AS
    (
        SELECT 'RANK_11'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '11'
           AND PGVW_RANK <= 5
    ), WT_BASE_RANK_12 AS
    (
        SELECT 'RANK_12'                               AS RANK_TYPE  /* 순위          */
              ,PGVW_RANK                               AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명        */
          FROM WT_RANK A
         WHERE RANK_MNTH  = '12'
           AND PGVW_RANK <= 5
    )
    SELECT A.PGVW_RANK                                                      /* 순위        */
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

          ,CAST(RANK_01.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_01 /* 01월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_02.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_02 /* 02월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_03.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_03 /* 03월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_04.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_04 /* 04월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_05.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_05 /* 05월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_06.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_06 /* 06월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_07.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_07 /* 07월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_08.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_08 /* 08월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_09.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_09 /* 09월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_10.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_10 /* 10월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_11.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_11 /* 11월 Unique Visitor (UV) 당 Page View (PV) 건수 */
          ,CAST(RANK_12.PGVW_CNT AS DECIMAL(20,2))           AS PGVW_CNT_12 /* 12월 Unique Visitor (UV) 당 Page View (PV) 건수 */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01 RANK_01 ON (A.PGVW_RANK = RANK_01.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02 RANK_02 ON (A.PGVW_RANK = RANK_02.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03 RANK_03 ON (A.PGVW_RANK = RANK_03.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04 RANK_04 ON (A.PGVW_RANK = RANK_04.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05 RANK_05 ON (A.PGVW_RANK = RANK_05.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06 RANK_06 ON (A.PGVW_RANK = RANK_06.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07 RANK_07 ON (A.PGVW_RANK = RANK_07.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08 RANK_08 ON (A.PGVW_RANK = RANK_08.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09 RANK_09 ON (A.PGVW_RANK = RANK_09.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10 RANK_10 ON (A.PGVW_RANK = RANK_10.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11 RANK_11 ON (A.PGVW_RANK = RANK_11.PGVW_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12 RANK_12 ON (A.PGVW_RANK = RANK_12.PGVW_RANK)
  ORDER BY A.PGVW_RANK