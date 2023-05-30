/* 7. 방문자 성별 분포 - 그래프 SQL */
WITH WT_GNDR_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_GENDER
       GROUP BY NAME
      UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS GNDR_NM
              ,SUM(UV::FLOAT8) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT GNDR_NM       AS GNDR_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_GNDR_ALL
       GROUP BY GNDR_NM
    )
    SELECT GNDR_NM  AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY GNDR_NM