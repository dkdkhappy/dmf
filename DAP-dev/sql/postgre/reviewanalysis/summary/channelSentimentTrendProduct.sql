/* 4. 채널 별 긍부정 시계열 그래프 - 제품 선택 */
WITH WT_PROD_TYPE AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_TMALL_ID_NAME A
         WHERE MARKET = 'china'
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_TMALL_ID_NAME A
         WHERE MARKET = 'global'
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_DOUYIN_ID_NAME A
         WHERE MARKET = 'china'
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_DOUYIN_ID_NAME A
         WHERE MARKET = 'global'
    ), WT_PROD_ALL AS
    (
        SELECT DISTINCT 
               BRND_SORT
              ,BRND_NM
              ,PROD_NM
              ,PROD_NM AS PROD_ID
          FROM WT_PROD_TYPE
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY BRND_SORT, BRND_NM COLLATE "ko_KR.utf8", PROD_NM COLLATE "ko_KR.utf8", PROD_ID) AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_ALL
    )
    SELECT SORT_KEY  /* 정렬순서  */
          ,BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,PROD_ID   /* 제품코드  */
      FROM WT_PROD
  ORDER BY SORT_KEY