/* 5. 카테고리별 / 토픽 100% 바그래프 - 카테고리 선택 SQL */
WITH WT_CATE_SPLT_ORG AS
    (
        SELECT DISTINCT
               TRIM(REGEXP_SPLIT_TO_TABLE(CATEGORY, '/')) AS CATE_NM
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
    ), WT_CATE_SPLT_RE AS 
    (
        SELECT DISTINCT
               TRIM(REGEXP_SPLIT_TO_TABLE(CATE_NM, ',')) AS CATE_NM
          FROM WT_CATE_SPLT_ORG
         WHERE TRIM(CATE_NM) != '' 
    ), WT_CATE_SPLT AS 
    (
        SELECT ROW_NUMBER() OVER (ORDER BY CATE_NM COLLATE "ko_KR.utf8") AS SORT_KEY
              ,CATE_NM
          FROM WT_CATE_SPLT_RE
     UNION ALL
        SELECT '0'   AS SORT_KEY
             ,'전체' AS CATE_NM
    )
    SELECT SORT_KEY  /* 정렬순서   */
          ,CATE_NM   /* 카테고리 명*/
      FROM WT_CATE_SPLT
  ORDER BY SORT_KEY
