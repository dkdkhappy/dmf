/* 1. 토픽별 바그래프 -  제품 선택 SQL */
WITH WT_PROD_TYPE AS
    (
        SELECT CASE 
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,STRING_AGG(ID, ',')    AS PROD_ID
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
         WHERE DISPLAY = 'O'
           AND LOWER('D'||SUBSTRING(MARKET,1,1)||SUBSTRING({CHNL_ID},1,1)) = LOWER({TAG_ID})
      GROUP BY BRND_SORT
              ,BRND_NM
              ,PROD_NM
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY BRND_SORT, BRND_NM COLLATE "ko_KR.utf8", PROD_NM COLLATE "ko_KR.utf8", PROD_ID) -1 AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE
    )
    SELECT SORT_KEY  /* 정렬순서  */
          ,BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,PROD_ID   /* 제품코드  */
      FROM WT_PROD
  ORDER BY SORT_KEY