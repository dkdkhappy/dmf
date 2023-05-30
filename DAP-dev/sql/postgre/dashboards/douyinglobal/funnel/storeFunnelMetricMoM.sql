/* 18. 스토어 Funnel 지표 비교 - B. 전년 동월대비 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT {BASE_MNTH}  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'클릭한 사람 수(중복제거)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'노출수/클릭한 사람 수(중복제거)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0)) * DASH_RAW.SF_EXCH_KRW(TO_CHAR(CAST(CAST(a.DATE AS TEXT) AS DATE), 'YYYY-MM')))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(PRODUCT_CLICKS_PERSON)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PRODUCT_IMPRESSIONS) / SUM(PRODUCT_CLICKS_PERSON)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_TRANSACTIONS) / SUM(PRODUCT_CLICKS_PERSON) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'YYYY-MM') = (SELECT BASE_MNTH FROM WT_WHERE)
    ), WT_VIST_YOY AS
    (
        SELECT SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0)) * DASH_RAW.SF_EXCH_KRW(TO_CHAR(CAST(CAST(a.DATE AS TEXT) AS DATE), 'YYYY-MM')))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(PRODUCT_CLICKS_PERSON)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PRODUCT_IMPRESSIONS) / SUM(PRODUCT_CLICKS_PERSON)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_TRANSACTIONS) / SUM(PRODUCT_CLICKS_PERSON) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'YYYY-MM') = (SELECT BASE_MNTH FROM WT_WHERE_YOY)

    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(C.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(C.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(C.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(C.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_YOY_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_KRW
          FROM WT_COPY     A
              ,WT_VIST     B
              ,WT_VIST_YOY C
    )
    SELECT SORT_KEY
          ,ROW_TITL
          ,COL_YOY_RMB
          ,COL_RMB
          ,COL_YOY_KRW
          ,COL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY