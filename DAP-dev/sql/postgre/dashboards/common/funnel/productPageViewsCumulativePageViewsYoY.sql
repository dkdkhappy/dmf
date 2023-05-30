/* 8. 제품별 페이지 뷰 데이터 뷰어 (Top 5) - 전년도 동기 누적 대비 누적 페이지뷰 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
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
    ), WT_TOTL AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAGEVIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_PGVW AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_PGVW_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(PRODUCT_VIEWS)  AS PGVW_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY PGVW_CNT DESC, PRODUCT_ID) AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT                                        AS PGVW_CNT   /* 페이지뷰 자수 */
          FROM WT_PGVW_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'     AS RANK_TYPE  /* 금년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE PGVW_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY' AS RANK_TYPE  /* 전년순위      */
              ,PGVW_RANK  AS PGVW_RANK  /* 페이지뷰 순위 */
              ,PGVW_CNT   AS PGVW_CNT   /* 페이지뷰 건수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE PGVW_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.PGVW_RANK                                                  /* 순위               */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID        */
              ,DASH_RAW.SF_{TAG}_PROD_NM(C.PRODUCT_ID)     AS PROD_NM_YOY   /* 전년 제품명        */
              ,C.PGVW_CNT                                  AS PGVW_CNT_YOY  /* 전년 페이지뷰 건수 */
              ,C.PGVW_CNT / Y.PGVW_CNT * 100               AS PGVW_RATE_YOY /* 전년 페이지뷰 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID        */
              ,DASH_RAW.SF_{TAG}_PROD_NM(B.PRODUCT_ID)     AS PROD_NM       /* 금년 제품명        */
              ,B.PGVW_CNT                                  AS PGVW_CNT      /* 금년 페이지뷰 건수 */
              ,B.PGVW_CNT / T.PGVW_CNT * 100               AS PGVW_RATE     /* 금년 페이지뷰 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.PGVW_RANK = B.PGVW_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.PGVW_RANK = C.PGVW_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT PGVW_RANK                                                                                    /* 순위               */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID        */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT_YOY   /* 전년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE_YOY  /* 전년 페이지뷰 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID        */
          ,PROD_NM                                                                                      /* 금년 제품명        */
          ,TO_CHAR(CAST(PGVW_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS PGVW_CNT       /* 금년 페이지뷰 건수 */
          ,TO_CHAR(CAST(PGVW_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS PGVW_RATE      /* 금년 페이지뷰 비중 */
      FROM WT_BASE
  ORDER BY PGVW_RANK