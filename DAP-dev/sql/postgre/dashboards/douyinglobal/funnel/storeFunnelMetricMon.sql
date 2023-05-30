/* 18. 스토어 Funnel 지표 비교 - C. 당해 연도 월별 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
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
        SELECT '00'                                                                                                     AS COL_MNTH
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0)) * DASH_RAW.SF_EXCH_KRW(TO_CHAR(CAST(CAST(a.DATE AS TEXT) AS DATE), 'YYYY-MM')))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(PRODUCT_CLICKS_PERSON)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PRODUCT_IMPRESSIONS) / SUM(PRODUCT_CLICKS_PERSON)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_TRANSACTIONS) / SUM(PRODUCT_CLICKS_PERSON) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'YYYY')  =  (SELECT BASE_YEAR FROM WT_WHERE)
     UNION ALL
        SELECT TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'MM')                                                             AS COL_MNTH
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((TRANSACTION_AMOUNT_YUAN - COALESCE(REFUND_AMOUNT_YUAN, 0)) * DASH_RAW.SF_EXCH_KRW(TO_CHAR(CAST(CAST(a.DATE AS TEXT) AS DATE), 'YYYY-MM')))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(PRODUCT_CLICKS_PERSON)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PRODUCT_IMPRESSIONS) / SUM(PRODUCT_CLICKS_PERSON)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_TRANSACTIONS) / SUM(PRODUCT_CLICKS_PERSON) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'YYYY')  =  (SELECT BASE_YEAR FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(CAST(DATE AS TEXT) AS DATE), 'MM')  
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,ROW_TITL
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.SALE_AMT_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_RMB
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '00' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_00_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '01' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_01_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '02' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_02_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '03' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_03_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '04' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_04_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '05' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_05_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '06' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_06_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '07' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_07_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '08' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_08_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '09' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_09_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '10' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_10_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '11' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_11_KRW
              ,CASE
                 WHEN ROW_ID = 'AMT'  AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.SALE_AMT_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'VIST' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.VIST_CNT     AS DECIMAL(20,0)), 'FM999,999,999,999,990'    )
                 WHEN ROW_ID = 'PGVW' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.PGVW_CNT     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00' )
                 WHEN ROW_ID = 'ORDR' AND COL_MNTH = '12' THEN TO_CHAR(CAST(B.ORDR_VAL     AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%')
               END COL_12_KRW
          FROM WT_COPY      A
              ,WT_VIST      B
    )
    SELECT SORT_KEY
          ,MAX(ROW_TITL  )  AS ROW_TITL    /* 구분                   */
          ,MAX(COL_00_RMB)  AS COL_00_RMB  /* 당해 연도 누적 - 위안화 */
          ,MAX(COL_01_RMB)  AS COL_01_RMB  /* 01월          - 위안화 */
          ,MAX(COL_02_RMB)  AS COL_02_RMB  /* 02월          - 위안화 */
          ,MAX(COL_03_RMB)  AS COL_03_RMB  /* 03월          - 위안화 */
          ,MAX(COL_04_RMB)  AS COL_04_RMB  /* 04월          - 위안화 */
          ,MAX(COL_05_RMB)  AS COL_05_RMB  /* 05월          - 위안화 */
          ,MAX(COL_06_RMB)  AS COL_06_RMB  /* 06월          - 위안화 */
          ,MAX(COL_07_RMB)  AS COL_07_RMB  /* 07월          - 위안화 */
          ,MAX(COL_08_RMB)  AS COL_08_RMB  /* 08월          - 위안화 */
          ,MAX(COL_09_RMB)  AS COL_09_RMB  /* 09월          - 위안화 */
          ,MAX(COL_10_RMB)  AS COL_10_RMB  /* 10월          - 위안화 */
          ,MAX(COL_11_RMB)  AS COL_11_RMB  /* 11월          - 위안화 */
          ,MAX(COL_12_RMB)  AS COL_12_RMB  /* 12월          - 위안화 */
          ,MAX(COL_00_KRW)  AS COL_00_KRW  /* 당해 연도 누적 - 원화   */
          ,MAX(COL_01_KRW)  AS COL_01_KRW  /* 01월          - 원화   */
          ,MAX(COL_02_KRW)  AS COL_02_KRW  /* 02월          - 원화   */
          ,MAX(COL_03_KRW)  AS COL_03_KRW  /* 03월          - 원화   */
          ,MAX(COL_04_KRW)  AS COL_04_KRW  /* 04월          - 원화   */
          ,MAX(COL_05_KRW)  AS COL_05_KRW  /* 05월          - 원화   */
          ,MAX(COL_06_KRW)  AS COL_06_KRW  /* 06월          - 원화   */
          ,MAX(COL_07_KRW)  AS COL_07_KRW  /* 07월          - 원화   */
          ,MAX(COL_08_KRW)  AS COL_08_KRW  /* 08월          - 원화   */
          ,MAX(COL_09_KRW)  AS COL_09_KRW  /* 09월          - 원화   */
          ,MAX(COL_10_KRW)  AS COL_10_KRW  /* 10월          - 원화   */
          ,MAX(COL_11_KRW)  AS COL_11_KRW  /* 11월          - 원화   */
          ,MAX(COL_12_KRW)  AS COL_12_KRW  /* 12월          - 원화   */
     FROM WT_BASE
 GROUP BY SORT_KEY
 ORDER BY SORT_KEY