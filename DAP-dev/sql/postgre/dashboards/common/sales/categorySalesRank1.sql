/* 7. 카테고리별 매출 순위 - 1차 카테고리 선택 SQL */
WITH WT_BASE AS
    (
        SELECT DISTINCT
               "번역1차" AS CATE_1
          FROM DASH_RAW.OVER_TMALL_ITEM_RANK_CATEGORY
    )
    SELECT CATE_1
      FROM WT_BASE
  ORDER BY CATE_1 COLLATE "ko_KR.utf8"