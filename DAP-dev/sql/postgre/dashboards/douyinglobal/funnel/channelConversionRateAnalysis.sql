/* 14. 채널 전환율 분석 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'IMPR'  AS LGND_ID
              ,'노출'  AS LGND_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'CLCK'  AS LGND_ID
              ,'클릭'  AS LGND_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'ORDR'  AS LGND_ID
              ,'주문'  AS LGND_NM
     UNION ALL
        SELECT 4       AS SORT_KEY
              ,'PAID'  AS LGND_ID
              ,'구매'  AS LGND_NM
     UNION ALL
        SELECT 5       AS SORT_KEY
              ,'REFD'  AS LGND_ID
              ,'환불'  AS LGND_NM

    ),  WT_DATA AS 
    (
        SELECT SUM(PRODUCT_IMPRESSIONS)                                AS IMPR_CNT  /* 방문 */
              ,SUM(PRODUCT_CLICKS_PERSON)                              AS CLCK_CNT  /* 방문 */
              ,SUM(NUMBER_OF_TRADED_ORDERS)                            AS ORDR_CNT  /* 주문 */
              ,SUM(NUMBER_OF_TRANSACTIONS)                             AS PAID_CNT  /* 구매 */
              ,SUM(REFUND_ORDER_QUANTITY)                              AS REFD_CNT  /* 환불 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE CAST(CAST(DATE AS TEXT) AS DATE)   BETWEEN (SELECT CAST(CAST(FR_DT AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT AS TEXT) AS DATE) FROM WT_WHERE)         
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,LGND_ID
              ,LGND_NM
              ,CASE
                 WHEN LGND_ID = 'IMPR' THEN IMPR_CNT  /* 노출 */
                 WHEN LGND_ID = 'CLCK' THEN CLCK_CNT  /* 클릭 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT  /* 환불 */
               END AS STEP_CNT
              ,CASE
                 WHEN LGND_ID = 'CLCK' THEN CLCK_CNT / IMPR_CNT * 100  /* 클릭 */
                 WHEN LGND_ID = 'ORDR' THEN ORDR_CNT / CLCK_CNT * 100  /* 주문 */
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT / ORDR_CNT * 100  /* 구매 */
                 WHEN LGND_ID = 'REFD' THEN REFD_CNT / PAID_CNT * 100  /* 환불 */
               END AS STEP_RATE
              ,CASE
                 WHEN LGND_ID = 'PAID' THEN PAID_CNT / CLCK_CNT * 100  /* 구매 전환율 */
               END AS ORDR_RATE
          FROM WT_COPY A 
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,LGND_ID
          ,LGND_NM                                                                              /* 단계명        */
          ,TO_CHAR(CAST(STEP_CNT  AS DECIMAL(20,0)), 'FM999,999,999,999,990'    ) AS STEP_CNT   /* 단계별 인원수 */
          ,TO_CHAR(CAST(STEP_RATE AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS STEP_RATE  /* 단계별 전환율 */
          ,TO_CHAR(CAST(ORDR_RATE AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS ORDR_RATE  /* 구매 전환율   */
      FROM WT_BASE
  ORDER BY SORT_KEY