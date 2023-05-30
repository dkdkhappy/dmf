/* 18. 스토어 Funnel 지표 비교 - A. 전년도 동기 누적 대비 비교 SQL */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'AMT'                   AS ROW_ID
              ,'매출'                  AS ROW_TITL
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'VIST'                  AS ROW_ID
              ,'Unique Visitor (UV)'    AS ROW_TITL
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'PGVW'                  AS ROW_ID
              ,'Unique Visitor (UV) 당 Page View (PV)' AS ROW_TITL
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'ORDR'                  AS ROW_ID
              ,'구매전환율'            AS ROW_TITL
    ), WT_VIST AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_VIST_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB  /* 매출금액 - 위안화   */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW  /* 매출금액 - 원화     */
              ,SUM(NUMBER_OF_VISITORS)                                                                                  AS VIST_CNT      /* 방문자수            */
              ,SUM(PAGEVIEWS) / SUM(NUMBER_OF_VISITORS)                                                                 AS PGVW_CNT      /* 방문자당 페이지뷰수 */
              ,SUM(NUMBER_OF_PAID_BUYERS) / SUM(NUMBER_OF_VISITORS) * 100                                               AS ORDR_VAL      /* 구매 전환율         */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
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