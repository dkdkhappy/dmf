/* 17. 제품별 구매 전환율 Top 5 - 전년 동월 대비 구매 전환율 TOP 5 */
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
        SELECT 1 AS ORDR_RANK
     UNION ALL
        SELECT 2 AS ORDR_RANK
     UNION ALL
        SELECT 3 AS ORDR_RANK
     UNION ALL
        SELECT 4 AS ORDR_RANK
     UNION ALL
        SELECT 5 AS ORDR_RANK
    ), WT_TOTL AS
    (
        SELECT CASE WHEN SUM(live_commodity_clicks) = 0 THEN 0 ELSE SUM(live_transaction_number) / SUM(live_commodity_clicks) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_{TAG}_shopping_recommend_live_details A
          WHERE DATE BETWEEN (SELECT CAST(CAST(FR_DT AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT AS TEXT) AS DATE) FROM WT_WHERE) 
    ), WT_TOTL_YOY AS
    (
        SELECT CASE WHEN SUM(live_commodity_clicks) = 0 THEN 0 ELSE SUM(live_transaction_number) / SUM(live_commodity_clicks) * 100 END AS ORDR_VAL  /* 구매 전환율 */
          FROM DASH_RAW.OVER_{TAG}_shopping_recommend_live_details A
          WHERE DATE BETWEEN (SELECT CAST(CAST(FR_DT_YOY AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT_YOY AS TEXT) AS DATE) FROM WT_WHERE) 
    ), WT_ORDR AS
    (
        SELECT DOUYIN_ID
              ,EXPERT_NICKNAME
              ,CASE WHEN SUM(live_commodity_clicks) = 0 THEN 0 ELSE SUM(live_transaction_number) / SUM(live_commodity_clicks) * 100 END AS ORDR_VAL  /* 구매 전환율 */
              ,COUNT(DATE) AS CNT_DATE
          FROM DASH_RAW.OVER_{TAG}_shopping_recommend_live_details A
         WHERE TO_CHAR(DATE, 'YYYY-MM') =  (SELECT BASE_MNTH FROM WT_WHERE)
      GROUP BY DOUYIN_ID
              ,EXPERT_NICKNAME
    ), WT_ORDR_YOY AS
    (
        SELECT DOUYIN_ID
              ,EXPERT_NICKNAME
              ,CASE WHEN SUM(live_commodity_clicks) = 0 THEN 0 ELSE SUM(live_transaction_number) / SUM(live_commodity_clicks) * 100 END AS ORDR_VAL  /* 구매 전환율 */
              ,COUNT(DATE) AS CNT_DATE
          FROM DASH_RAW.OVER_{TAG}_shopping_recommend_live_details A
         WHERE TO_CHAR(DATE, 'YYYY-MM')  = (SELECT BASE_MNTH FROM WT_WHERE_YOY)
      GROUP BY DOUYIN_ID
              ,EXPERT_NICKNAME
    ), WT_RANK AS
    (
        SELECT DOUYIN_ID
              ,EXPERT_NICKNAME
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, EXPERT_NICKNAME) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR A
          WHERE CNT_DATE >= 7
    ), WT_RANK_YOY AS
    (
        SELECT DOUYIN_ID
              ,EXPERT_NICKNAME
              ,RANK() OVER(ORDER BY ORDR_VAL DESC, EXPERT_NICKNAME) AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL                                        AS ORDR_VAL   /* 구매 전환율      */
          FROM WT_ORDR_YOY A
          WHERE CNT_DATE >= 7
    ), WT_BASE_RANK AS
    (
        SELECT 'RANK'      AS RANK_TYPE  /* 금년순위      */
              ,ORDR_RANK   AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL    AS ORDR_VAL   /* 구매 전환율      */
              ,DOUYIN_ID   AS PRODUCT_ID
              ,EXPERT_NICKNAME AS PRODUCT_NAME
          FROM WT_RANK A
         WHERE ORDR_RANK <= 5
    ), WT_BASE_RANK_YOY AS
    (
        SELECT 'RANK_YOY'  AS RANK_TYPE  /* 전년순위      */
              ,ORDR_RANK   AS ORDR_RANK  /* 구매 전환율 순위 */
              ,ORDR_VAL    AS ORDR_VAL   /* 구매 전환율      */
              ,DOUYIN_ID   AS PRODUCT_ID
              ,EXPERT_NICKNAME AS PRODUCT_NAME
          FROM WT_RANK_YOY A
         WHERE ORDR_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.ORDR_RANK                                                  /* 순위                  */
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY   /* 전년 제품ID           */
              ,C.PRODUCT_NAME                              AS PROD_NM_YOY   /* 전년 제품명           */
              ,C.ORDR_VAL                                  AS ORDR_VAL_YOY  /* 전년 구매 전환율      */
              ,C.ORDR_VAL - Y.ORDR_VAL                     AS ORDR_RATE_YOY /* 전년 구매 전환율 비중 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID       /* 금년 제품ID           */
              ,B.PRODUCT_NAME                              AS PROD_NM       /* 금년 제품명           */
              ,B.ORDR_VAL                                  AS ORDR_VAL      /* 금년 구매 전환율      */
              ,B.ORDR_VAL - T.ORDR_VAL                     AS ORDR_RATE     /* 금년 구매 전환율 비중 */
    
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK     B ON (A.ORDR_RANK = B.ORDR_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY C ON (A.ORDR_RANK = C.ORDR_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT ORDR_RANK                                                                                    /* 순위                  */
          ,PROD_ID_YOY                                                                                  /* 전년 제품ID           */
          ,PROD_NM_YOY                                                                                  /* 전년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL_YOY  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL_YOY   /* 전년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE_YOY AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE_YOY  /* 전년 구매 전환율 비중 */
          ,PROD_ID                                                                                      /* 금년 제품ID           */
          ,PROD_NM                                                                                      /* 금년 제품명           */
          ,TO_CHAR(CAST(ORDR_VAL      AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_VAL       /* 금년 구매 전환율      */
          ,TO_CHAR(CAST(ORDR_RATE     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE      /* 금년 구매 전환율 비중 */
      FROM WT_BASE
  ORDER BY ORDR_RANK
;
