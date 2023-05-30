/* 8. 방문자 연령별 데이터 뷰어 - 표 SQL */
WITH WT_COPY AS
    (
    SELECT ROW_NUMBER() OVER(ORDER BY AGE_NM) AS SORT_KEY
          ,AGE_NM AS AGE_ID
          ,AGE_NM
      FROM  (
                SELECT DISTINCT 
                       AGE_NM
                  FROM  (
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
                         UNION ALL
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
                        ) A
            ) A
    ), WT_DCD AS
    (
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_DGD AS
    (
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV::FLOAT8) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.AGE_ID
              ,A.AGE_NM
              ,COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCD D ON (A.AGE_ID = D.AGE_ID)
                         LEFT OUTER JOIN WT_DGD E ON (A.AGE_ID = E.AGE_ID)
    )
    SELECT SORT_KEY
          ,AGE_NM
          ,TO_CHAR(TOTL_VIST_CNT, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY