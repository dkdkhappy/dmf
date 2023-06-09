/* 11. 방문자 성별 분포- 바 그래프 SQL */
WITH WT_BASE AS
    (
        SELECT NAME            AS GNDR_NM
              ,SUM(UV::FLOAT8) AS VIST_CNT
          FROM DASH_RAW.CRM_{TAG}_PROD_VISIT_GENDER
       GROUP BY NAME
    )
    SELECT GNDR_NM  AS X_VAL
          ,VIST_CNT AS Y_VAL
          ,CAST(VIST_CNT / SUM(VIST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS Y_RATE
      FROM WT_BASE
  ORDER BY GNDR_NM