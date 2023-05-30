/* 5. 채널별 검색 지표 Break Down - Douyin 선택 SQL */
WITH WT_TYPE AS
    (
        SELECT 1                AS SORT_KEY
              ,'PAID_RATE'      AS TYPE_ID
              ,'구매자 비중'    AS TYPE_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'REPD_RATE'      AS TYPE_ID
              ,'재구매율'       AS TYPE_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'CUST_AMT'       AS TYPE_ID
              ,'객단가'         AS TYPE_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'CUST_CM'        AS TYPE_ID
              ,'구매자당 수익'  AS TYPE_NM
     UNION ALL
        SELECT 5                AS SORT_KEY
              ,'CLCK_RATE'      AS TYPE_ID
              ,'클릭률'         AS TYPE_NM
    )
    SELECT SORT_KEY
          ,TYPE_ID
          ,TYPE_NM
      FROM WT_TYPE A
  ORDER BY SORT_KEY