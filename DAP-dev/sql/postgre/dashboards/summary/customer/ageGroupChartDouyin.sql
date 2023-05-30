/* 8. 방문자 연령별 분포- 그래프 SQL */
WITH WT_AGE_ALL AS
    (
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
      GROUP BY NAME
     UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS AGE_NM
              ,SUM(UV::FLOAT8) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
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