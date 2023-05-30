/* 7. 카테고리별 매출 순위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(CAST({FR_MNTH} || '-01' AS DATE) AS TEXT)                                                  AS FR_DT /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,TO_CHAR(CAST({TO_MNTH} || '-01' AS DATE) + INTERVAL '1' MONTH - INTERVAL '1' DAY, 'YYYY-MM-DD') AS TO_DT /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{OWN_YN}   AS OWN_YN            /* 사용자가 선택한 자사 여부 ex) 전체:%, 자사제품:Y */
              ,{KR_YN}    AS KR_YN             /* 사용자가 선택한 국가     ex) 전체:%, 한국:Y */
              ,{DEMA_YN}  AS DEMA_YN           /* 사용자가 선택한 더마여부 ex) 전체:%, 더마:Y, 더마 외:N */
    ), WT_CATE_WHERE_RAW AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(CATE_1)         AS CATE_1
          FROM REGEXP_SPLIT_TO_TABLE({CATE_1}, ',') AS CATE_1  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '바디 케어, 로션/크림, 클렌징' */
         WHERE TRIM(CATE_1) <> ''
    ), WT_CATE_WHERE AS
    (
        SELECT A.SORT_KEY    AS SORT_KEY
              ,B.CATEGORY_NO AS CATE_1
          FROM WT_CATE_WHERE_RAW A
     LEFT JOIN DASH_RAW.OVER_DOUYIN_ITEM_RANK_CATEGORY B
            ON A.CATE_1 = B.CATEGORY_NAME
    )
    , WT_TEMP AS
    (
       SELECT '' AS COUNTRY
             ,'' AS ITEM_PIC 
             ,0  AS DERMA
             ,CATEGORY_NO
             ,CATEGORY_NAME
        FROM DASH_RAW.OVER_DOUYIN_ITEM_RANK_CATEGORY
    ), WT_SALE AS
    (
        SELECT DISTINCT
               B.CATEGORY_NAME                      AS CATE_1
              ,A.PRODUCT_ID                         AS PROD_ID
              ,A.PRODUCT_NAME                       AS PROD_NM
              ,B.ITEM_PIC                           AS PROD_URL
              ,CAST(A.TRADE_INDEX AS DECIMAL(20,0)) AS SALE_AMT
              ,B.COUNTRY                            AS NATN_NM
              ,CASE WHEN B.DERMA = 1 THEN '●' END   AS DEMA_YN
              ,A.DATE
              ,A.BRAND
          FROM DASH.DOUYIN_ITEM_RANK_DATA A LEFT JOIN WT_TEMP B
            ON A.CATEGORY = B.CATEGORY_NO
         WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND A.CATEGORY IN (SELECT CATE_1 FROM WT_CATE_WHERE)
           AND B.COUNTRY LIKE CASE WHEN (SELECT KR_YN FROM WT_WHERE) = 'Y' THEN '%한국%' ELSE '%' END
           AND CASE WHEN B.DERMA = 1 THEN 'Y' ELSE 'N' END LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT MAX(CATE_1)   AS CATE_1
              ,PROD_ID
              ,PROD_NM
              ,BRAND
              ,MAX(PROD_URL) AS PROD_URL
              ,SUM(SALE_AMT) / (CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - CAST((SELECT FR_DT FROM WT_WHERE) AS DATE))  AS SALE_AMT
              ,ARRAY_TO_STRING(ARRAY_AGG(DISTINCT NATN_NM),',') AS NATN_NM
              ,MAX(DEMA_YN)  AS DEMA_YN
          FROM WT_SALE
      GROUP BY PROD_ID
              ,PROD_NM
              ,BRAND
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_AMT DESC NULLS LAST, PROD_NM) AS PROD_RANK
              ,CATE_1
              ,BRAND
              ,PROD_ID
              ,PROD_NM
              ,PROD_URL
              ,SALE_AMT
              ,NATN_NM
              ,DEMA_YN
          FROM WT_SUM
    )
    SELECT PROD_RANK
          ,CATE_1
          ,PROD_ID
          ,PROD_NM
          ,PROD_URL
          ,CAST(SALE_AMT AS DECIMAL(20, 2)) AS SALE_RATE
          ,NATN_NM
          ,DEMA_YN
      FROM WT_BASE
     WHERE CASE WHEN (SELECT OWN_YN FROM WT_WHERE) = 'Y' THEN BRAND='德妃'
                ELSE TRUE
            END
  ORDER BY PROD_RANK
