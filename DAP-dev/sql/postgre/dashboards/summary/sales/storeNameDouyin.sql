/* 6. 채널별 브랜드 등수 - 상점명 선택 SQL */
WITH WT_BASE AS
    (
        SELECT AUTHOR_ID         AS SHOP_ID
              ,MAX(LIVE_NAME_KR) AS SHOP_NM
          FROM DASH_RAW.OVER_DOUYIN_LIVE_NAME
      GROUP BY AUTHOR_ID
    )
    SELECT DISTINCT
           SHOP_ID
          ,SHOP_NM
      FROM WT_BASE
     WHERE SHOP_ID IS NOT NULL
       AND SHOP_NM IS NOT NULL
  ORDER BY SHOP_NM