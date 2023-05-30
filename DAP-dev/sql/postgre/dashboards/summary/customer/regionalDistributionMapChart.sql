/* 6. 방문자 지역 분류별 분포- Map Chart SQL */
WITH WT_CITY_ALL AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
      UNION ALL
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS CITY_NM
              ,SUM(UV::FLOAT8) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
       GROUP BY NAME
    ), WT_CITY AS
    (
        SELECT CITY_NM
              ,SUM(VIST_CNT) AS VIST_CNT
          FROM WT_CITY_ALL
         GROUP BY CITY_NM
    ), WT_BASE AS
    (
    	  SELECT A.CITY_NM_KR AS PROV_NM_KR
    		  ,SUM(B.VIST_CNT)  AS VIST_CNT
       	  FROM DASH_RAW.OVER_CHINA_CITY A INNER JOIN WT_CITY B
       	    ON (A.CITY_NM = B.CITY_NM)
      GROUP BY A.CITY_NM_KR
     UNION ALL
        SELECT A.PROV_NM_KR
              ,SUM(B.VIST_CNT) AS VIST_CNT
          FROM DASH_RAW.OVER_CHINA_CITY A INNER JOIN WT_CITY B
            ON (A.CITY_NM LIKE B.CITY_NM || '%')
      GROUP BY A.PROV_NM_KR
      		    ,A.PROV_NM
     UNION ALL
        SELECT A.PROV_NM_KR
              ,B.VIST_CNT AS VIST_CNT
          FROM (SELECT DISTINCT PROV_NM_KR, PROV_NM FROM DASH_RAW.OVER_CHINA_CITY) A INNER JOIN WT_CITY B
            ON (A.PROV_NM LIKE B.CITY_NM || '%')
    )
    SELECT PROV_NM_KR AS CITY_NM
          ,VIST_CNT
      FROM WT_BASE
     WHERE VIST_CNT IS NOT NULL
  ORDER BY VIST_CNT DESC NULLS LAST
          ,CITY_NM