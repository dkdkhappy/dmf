/* 8. 방문자 연령별 분포- 그래프 SQL */
WITH WT_AGE_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
      GROUP BY NAME
     UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT AGE_NM        AS AGE_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_AGE_ALL
      GROUP BY AGE_NM
    )
    SELECT AGE_NM   AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY AGE_NM