/* 10. 방문자 지역 분류별 분포 - 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT CASE
                 WHEN LEVEL = '1선도시'   THEN 1
                 WHEN LEVEL = '준1선도시' THEN 2
                 WHEN LEVEL = '2선도시'   THEN 3
                 WHEN LEVEL = '3선도시'   THEN 4
                 ELSE 9
               END AS SORT_KEY
              ,LEVEL                        AS CITY_LV
              ,COALESCE(SUM(UV::FLOAT8), 0) AS VIST_CNT
          FROM DASH_RAW.CRM_{TAG}_PROD_VISIT_CITY
      GROUP BY LEVEL
    )
    SELECT SORT_KEY
          ,CITY_LV   AS X_VAL
          ,VIST_CNT  AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
     WHERE SORT_KEY IN (1, 2, 3, 4)
  ORDER BY SORT_KEY
