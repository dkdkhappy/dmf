/* 3. 토픽별/제품별 히트맵 overview - 토픽 세부주제 선택 SQL */
/*    토픽 2단계 선택 SQL                                    */
/*    토픽 1단계 -> 토픽선택, 효능, CS 선택 시 조회          */
WITH WT_WHERE AS
    (
        SELECT {TPIC_TYPE} AS TPIC_TYPE   /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
    ), WT_TPIC_TYPE AS
    (
        SELECT 1 AS SORT_KEY, '대주제'   AS TPIC_TYPE UNION ALL
        SELECT 2 AS SORT_KEY, '효능'     AS TPIC_TYPE UNION ALL
        SELECT 3 AS SORT_KEY, 'CS'       AS TPIC_TYPE 
    ), WT_TPIC_DATA AS
    (
        SELECT DISTINCT
               '대주제' AS TPIC_TYPE
              ,FIRST    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
     UNION ALL
        SELECT DISTINCT
               '효능'   AS TPIC_TYPE
              ,TOTAL    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
         WHERE FIRST  = '효능'
           AND TOTAL != '효능'
     UNION ALL
        SELECT DISTINCT
               'CS'     AS TPIC_TYPE
              ,TOTAL    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
         WHERE FIRST = 'CS'
    ), WT_TPIC AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE X WHERE X.TPIC_TYPE = A.TPIC_TYPE), TPIC_ITEM COLLATE "ko_KR.utf8") AS SORT_KEY
              ,TPIC_TYPE
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
         WHERE TPIC_TYPE IN (
                                SELECT CASE
                                         WHEN X.TPIC_TYPE = '전체'     THEN '대주제'
                                         WHEN X.TPIC_TYPE = '토픽선택' THEN A.TPIC_TYPE
                                         WHEN X.TPIC_TYPE = '효능'     THEN '효능'
                                         WHEN X.TPIC_TYPE = 'CS'       THEN 'CS'
                                       END
                                  FROM WT_WHERE X
                            )
    )
    SELECT SORT_KEY   /* 정렬순서   */
          ,TPIC_TYPE  /* 토픽 1단계 */
          ,TPIC_ITEM  /* 토픽 2단계 */
      FROM WT_TPIC
  ORDER BY SORT_KEY
