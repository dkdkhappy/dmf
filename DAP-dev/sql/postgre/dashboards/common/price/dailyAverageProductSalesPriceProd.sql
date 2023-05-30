/* 7. 일자별 제품 평균 판매가 - 제품 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST({TO_DT} AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_BASE AS
    (
        SELECT DISTINCT
               a.ITEM_CODE AS PROD_ID
              ,b.product_name AS PROD_NM
          FROM DASH.{TAG}_PRICEANLAYSISITEMTIMESERIES a left outer join dash_raw.over_dcd_id_name_bcd  b on  a.item_code = b.product_id
         WHERE a.STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND product_name IS NOT NULL
    )
    SELECT PROD_ID
          ,PROD_NM
      FROM WT_BASE
  ORDER BY PROD_NM COLLATE "ko_KR.utf8"