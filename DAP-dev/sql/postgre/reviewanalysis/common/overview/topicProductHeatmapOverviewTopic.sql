/* 3. 토픽별/제품별 히트맵 overview - 토픽 대주제 선택 SQL */
/*    토픽 1단계 선택 SQL */
WITH WT_BASE AS
    (
        SELECT 1 AS SORT_KEY, '전체'     AS TPIC_TYPE UNION ALL
        SELECT 2 AS SORT_KEY, '토픽선택' AS TPIC_TYPE UNION ALL
        SELECT 3 AS SORT_KEY, '효능'     AS TPIC_TYPE UNION ALL
        SELECT 4 AS SORT_KEY, 'CS'       AS TPIC_TYPE 
    )
    SELECT SORT_KEY   /* 정렬순서   */
          ,TPIC_TYPE  /* 토픽 1단계 */
      FROM WT_BASE
  ORDER BY SORT_KEY
