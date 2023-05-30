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
                              FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
                         UNION ALL
                            SELECT NAME AS AGE_NM
                              FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
                        ) A
            ) A
    ), WT_DCT AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_DGT AS
    (
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS AGE_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_AGE
      GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.AGE_ID
              ,A.AGE_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.AGE_ID = B.AGE_ID)
                         LEFT OUTER JOIN WT_DGT C ON (A.AGE_ID = C.AGE_ID)
    )
    SELECT SORT_KEY
          ,AGE_NM
          ,TO_CHAR(TOTL_VIST_CNT, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
      FROM WT_BASE
  ORDER BY SORT_KEY