/* 7. 카테고리별 매출 순위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}  AS FR_MNTH           /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}  AS TO_MNTH           /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{OWN_YN}   AS OWN_YN            /* 사용자가 선택한 자사 여부 ex) 전체:%, 자사제품:Y */
              ,{KR_YN}    AS KR_YN             /* 사용자가 선택한 국가     ex) 전체:%, 한국:Y */
              ,{DEMA_YN}  AS DEMA_YN           /* 사용자가 선택한 더마여부 ex) 전체:%, 더마:Y, 더마 외:N */
    ), WT_CATE_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(CATE_2)         AS CATE_2
          FROM REGEXP_SPLIT_TO_TABLE({CATE_2}, ',') AS CATE_2  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '바디 케어, 로션/크림, 클렌징' */
         WHERE TRIM(CATE_2) <> ''
    ), WT_SALE AS
    (
        SELECT DISTINCT
              "1차"                             AS CATE_1
              ,"2차"                            AS CATE_2
              ,PROD_ID                          AS PROD_ID
              ,KR_NAME                          AS PROD_NM
              ,ITEM_PIC                         AS PROD_URL
              ,CAST(SALE_AMT AS DECIMAL(20,0))  AS SALE_AMT
              ,COUNTRY                          AS NATN_NM
              ,CASE WHEN DERMA = 1 THEN '●' END AS DEMA_YN
              ,BASE_TIME
          FROM DASH.TMALL_ITEM_RANK_DATA
         WHERE BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
           AND "2차"   IN (SELECT CATE_2 FROM WT_CATE_WHERE)
           AND COUNTRY LIKE CASE WHEN (SELECT KR_YN FROM WT_WHERE) = 'Y' THEN '%한국%' ELSE '%' END
           AND CASE WHEN DERMA = 1 THEN 'Y' ELSE 'N' END LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT MAX(CATE_1)   AS CATE_1
              ,MAX(CATE_2)   AS CATE_2
              ,PROD_ID
              ,PROD_NM
              ,MAX(PROD_URL) AS PROD_URL
              ,SUM(SALE_AMT) AS SALE_AMT
              ,ARRAY_TO_STRING(ARRAY_AGG(DISTINCT NATN_NM),',') AS NATN_NM
              ,MAX(DEMA_YN)  AS DEMA_YN
          FROM WT_SALE
      GROUP BY PROD_ID
              ,PROD_NM
    ), WT_RATE AS
    (
        SELECT CATE_1
              ,CATE_2
              ,PROD_ID
              ,PROD_NM
              ,PROD_URL
              ,SALE_AMT / SUM(SALE_AMT) OVER() * 100 AS SALE_RATE
              ,SALE_AMT
              ,SUM(SALE_AMT) OVER()                  AS SALE_AMT_SUM
              ,NATN_NM
              ,DEMA_YN
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_RATE DESC NULLS LAST, PROD_NM) AS PROD_RANK
              ,CATE_1
              ,CATE_2
              ,PROD_ID
              ,PROD_NM
              ,PROD_URL
              ,TO_CHAR(SALE_RATE, 'FM999,999,999,999,990.0000') AS SALE_RATE
              ,SALE_AMT
              ,SALE_AMT_SUM
              ,NATN_NM
              ,DEMA_YN
          FROM WT_RATE
    ), WT_PROD_OWN AS
    (
        SELECT DISTINCT PRODUCT_ID
          FROM DASH_RAW.OVER_DGT_ID_NAME
     UNION ALL
        SELECT DISTINCT PRODUCT_ID
          FROM DASH_RAW.OVER_DCT_ID_NAME
    )
    SELECT PROD_RANK
          ,CATE_1
          ,CATE_2
          ,PROD_ID
          ,PROD_NM
          ,PROD_URL
          ,SALE_RATE
          ,SALE_AMT
          ,SALE_AMT_SUM
          ,NATN_NM
          ,DEMA_YN
      FROM WT_BASE
     WHERE 
        CASE WHEN (SELECT OWN_YN FROM WT_WHERE) = 'Y' THEN PROD_ID in (SELECT PRODUCT_ID FROM WT_PROD_OWN)
             ELSE TRUE
        END
  ORDER BY PROD_RANK
