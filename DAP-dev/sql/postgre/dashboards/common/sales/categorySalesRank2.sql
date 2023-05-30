/* 7. 카테고리별 매출 순위 - 2차 카테고리 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT {CATE_1}  AS CATE_1           /* 사용자가 선택한 1차 카테고리 ex) '메이크업/향수/미용 도구' 또는 '스킨케어/바디/에센셜오일'  */
    ), WT_BASE AS
    (
        SELECT DISTINCT
               "번역1차" AS CATE_1
              ,"번역2차" AS CATE_2
          FROM DASH_RAW.OVER_TMALL_ITEM_RANK_CATEGORY
    )
    SELECT CATE_1
          ,CATE_2
      FROM WT_BASE
     WHERE CATE_1 = (SELECT CATE_1 FROM WT_WHERE)
  ORDER BY CATE_2 COLLATE "ko_KR.utf8"