/* 2. 채널 별 리뷰 지도 - 토픽 선택 SQL */
WITH WT_TPIC_DATA AS
    (
        SELECT '전체'   AS TPIC_ITEM
     UNION ALL
        SELECT DISTINCT
               FIRST    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
    ), WT_TPIC AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY CASE WHEN TPIC_ITEM = '전체' THEN '' ELSE TPIC_ITEM END COLLATE "ko_KR.utf8") AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
    )
    SELECT SORT_KEY   /* 정렬순서      */
          ,REPLACE(TPIC_ITEM, '/', '-') AS TPIC_ITEM  /* 토픽 상세항목 */
      FROM WT_TPIC
  ORDER BY SORT_KEY