/* 10. 방문자 지역 분포 - 지도 그래프 SQL */
WITH WT_CITY AS
    (
        SELECT NAME            AS CITY_NM
              ,SUM(UV::FLOAT8) AS VIST_CNT
          FROM DASH_RAW.CRM_{TAG}_PROD_VISIT_CITY
         WHERE COALESCE(TRIM(NAME), '') != ''
      GROUP BY NAME
        HAVING SUM(UV::FLOAT8) > 0 
    ), WT_PROV AS
    (
        SELECT A.PROV_NM_KR
              ,SUM(B.VIST_CNT) AS VIST_CNT
          FROM DASH_RAW.OVER_CHINA_CITY A INNER JOIN WT_CITY B
            ON (A.CITY_NM LIKE B.CITY_NM || '%')
      GROUP BY A.PROV_NM_KR
     UNION ALL
        SELECT DISTINCT A.PROV_NM_KR
              ,B.VIST_CNT AS VIST_CNT
          FROM DASH_RAW.OVER_CHINA_CITY A INNER JOIN WT_CITY B
            ON (A.PROV_NM LIKE B.CITY_NM || '%')
    ), WT_BASE AS 
    (
        SELECT PROV_NM_KR AS CITY_NM
              ,VIST_CNT
          FROM WT_PROV
    )
    SELECT CITY_NM
          ,VIST_CNT
      FROM WT_BASE
  ORDER BY VIST_CNT DESC NULLS LAST
          ,CITY_NM