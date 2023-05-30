/* 6. 채널 내 매출 순위 300위 - 상점명 선택 SQL */
WITH WT_BASE AS
    (
        SELECT DISTINCT
               SHOP_NAME_CN AS SHOP_ID
              ,SHOP_NAME_KR AS SHOP_NM
          FROM DASH_RAW.OVER_DOUYIN_STORE_NAME
    )
    SELECT SHOP_ID
          ,SHOP_NM
      FROM WT_BASE
  ORDER BY SHOP_NM