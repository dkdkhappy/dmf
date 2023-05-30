/* 6. 채널 내 매출 순위 300위 - 상점명 선택 SQL */
WITH WT_BASE AS
    (
        SELECT DISTINCT
               SHOP_ID   AS SHOP_ID
              ,SHOPNAME  AS SHOP_NM
          FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY 
    )
    SELECT SHOP_ID
          ,SHOP_NM
      FROM WT_BASE
  ORDER BY SHOP_NM