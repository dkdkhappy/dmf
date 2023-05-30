/* 7.비용 항목 별 월별 트렌드 분석 - 비용 선택 SQL */
WITH WT_BASE AS
    (
        SELECT 1                  AS SORT_KEY
              ,'COGS'             AS COST_ID
              ,'COGS'             AS COST_NM
     UNION ALL
        SELECT 2                  AS SORT_KEY
              ,'ADVR'             AS COST_ID
              ,'광고비(영업본부)' AS COST_NM
     UNION ALL
        SELECT 3                  AS SORT_KEY
              ,'FREE'             AS COST_ID
              ,'광고비(무상지원)' AS COST_NM
     UNION ALL
        SELECT 4                  AS SORT_KEY
              ,'SALE'             AS COST_ID
              ,'판매수수료'       AS COST_NM
     UNION ALL
        SELECT 5                  AS SORT_KEY
              ,'TRNS'             AS COST_ID
              ,'물류비'           AS COST_NM
    )
    SELECT SORT_KEY
          ,COST_ID
          ,COST_NM
      FROM WT_BASE
  ORDER BY SORT_KEY