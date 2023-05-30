/* 6. 방문자 지역 등급별 데이터 뷰어 - 표 SQL */
WITH WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'1'          AS CITY_LV
              ,'1선도시'    AS CITY_LV_NM 
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'1.5'        AS CITY_LV
              ,'준1선도시'  AS CITY_LV_NM 
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'2'          AS CITY_LV
              ,'2선도시'    AS CITY_LV_NM 
     UNION ALL
        SELECT 4            AS SORT_KEY
              ,'3'          AS CITY_LV
              ,'3선도시'    AS CITY_LV_NM
    ), WT_DCT AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DGT AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DCD AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END     AS CITY_LV
              ,LEVEL   AS CITY_LV_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_DGD AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN '1'
                 WHEN LEVEL = '준1선도시' THEN '1.5'
                 WHEN LEVEL = '2선도시'   THEN '2'
                 WHEN LEVEL = '3선도시'   THEN '3'
                 ELSE '9' 
               END              AS CITY_LV
              ,LEVEL            AS CITY_LV_NM
              ,SUM(UV::FLOAT8)  AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_CITY
      GROUP BY LEVEL
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CITY_LV
              ,A.CITY_LV_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) + COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.CITY_LV = B.CITY_LV)
                         LEFT OUTER JOIN WT_DGT C ON (A.CITY_LV = C.CITY_LV)
                         LEFT OUTER JOIN WT_DCD D ON (A.CITY_LV = D.CITY_LV)
                         LEFT OUTER JOIN WT_DGD E ON (A.CITY_LV = E.CITY_LV)
    )
    SELECT SORT_KEY
          ,CITY_LV_NM
          ,TO_CHAR(CASE WHEN TOTL_VIST_CNT = 0 THEN NULL ELSE TOTL_VIST_CNT END, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY