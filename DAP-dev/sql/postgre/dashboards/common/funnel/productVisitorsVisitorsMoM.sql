/* 4. 제품별 Unique Visitor (UV) 데이터 뷰어 (Top 5) - 전년 동월 대비 방문자 TOP 5 */
WITH WT_WHERE AS
    (
        SELECT {BASE_MNTH}       AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
              ,FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS VIST_RANK
     UNION ALL
        SELECT 2 AS VIST_RANK
     UNION ALL
        SELECT 3 AS VIST_RANK
     UNION ALL
        SELECT 4 AS VIST_RANK
     UNION ALL
        SELECT 5 AS VIST_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_VIST AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
      GROUP BY PRODUCT_ID
    ), WT_VIST_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY VIST_CNT DESC, PRODUCT_ID) AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT                                        AS VIST_CNT   /* 방문자수 */
          FROM WT_VIST_YOY A
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위 */
              ,VIST_RANK   AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT    AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE VIST_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위 */
              ,VIST_RANK   AS VIST_RANK  /* 방문순위 */
              ,VIST_CNT    AS VIST_CNT   /* 방문자수 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE VIST_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.VIST_RANK                                                   /* 순위         */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID   */
              ,DASH_RAW.SF_{TAG}_PROD_NM(C.PRODUCT_ID)     AS PROD_NM_YOY   /* 전년 제품명   */
              ,C.VIST_CNT                                  AS VIST_CNT_YOY  /* 전년 방문수   */
              ,C.VIST_CNT / Y.VIST_CNT * 100               AS VIST_RATE_YOY /* 전년 방문비중 */

              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID   */
              ,DASH_RAW.SF_{TAG}_PROD_NM(B.PRODUCT_ID)     AS PROD_NM       /* 금년 제품명   */
              ,B.VIST_CNT                                  AS VIST_CNT      /* 금년 방문수   */
              ,B.VIST_CNT / T.VIST_CNT * 100               AS VIST_RATE     /* 금년 방문비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.VIST_RANK = B.VIST_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.VIST_RANK = C.VIST_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT VIST_RANK                                                                                    /* 순위          */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID   */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT_YOY  AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT_YOY   /* 전년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE_YOY  /* 전년 방문비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID   */
          ,PROD_NM                                                                                      /* 금년 제품명   */
          ,TO_CHAR(CAST(VIST_CNT      AS DECIMAL(20,0)), 'FM999,999,999,999,999'    ) AS VIST_CNT       /* 금년 방문자수 */
          ,TO_CHAR(CAST(VIST_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS VIST_RATE      /* 금년 방문비중 */
      FROM WT_BASE
  ORDER BY VIST_RANK