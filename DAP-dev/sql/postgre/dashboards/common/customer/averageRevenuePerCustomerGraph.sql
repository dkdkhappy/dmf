/* 8. 구매자 객단가 그래프 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'PAID'                  AS L_LGND_ID  /* 구매자수 */ 
              ,'구매자 수'              AS L_LGND_NM 
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'CUST'                  AS L_LGND_ID  /* 일 객단가 */ 
              ,'일 객단가'              AS L_LGND_NM 
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'CUST_WEEK'             AS L_LGND_ID  /* 주 객단가 */ 
              ,'주 객단가'              AS L_LGND_NM 
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'CUST_MNTH'             AS L_LGND_ID  /* 월 객단가 */ 
              ,'월 객단가'              AS L_LGND_NM 
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                           AS SALE_AMT_RMB  /* 일매출금액 - 위안화 */
              ,PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW  /* 일매출금액 - 원화   */
              ,NUMBER_OF_PAID_BUYERS                                    AS PAID_CNT      /* 일구매자수          */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CALC AS
    (
        SELECT STATISTICS_DATE
              ,PAID_CNT  /* 구매자수 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_RMB / PAID_CNT END AS CUST_AMT_RMB  /* 객단가 - 위안화 */
              ,CASE WHEN COALESCE(PAID_CNT, 0) = 0 THEN 0 ELSE SALE_AMT_KRW / PAID_CNT END AS CUST_AMT_KRW  /* 객단가 - 원화   */
          FROM WT_CAST A
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(PAID_CNT    )                                                                           AS PAID_CNT           /* 구매자수                       */
              ,    SUM(CUST_AMT_RMB)                                                                           AS CUST_AMT_RMB       /* 객단가                - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_RMB  /* 객단가 이동평균( 5일) - 위안화 */
              ,AVG(SUM(CUST_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_RMB  /* 객단가 이동평균(30일) - 위안화 */

              ,    SUM(CUST_AMT_KRW)                                                                           AS CUST_AMT_KRW       /* 객단가                - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS CUST_AMT_WEEK_KRW  /* 객단가 이동평균( 5일) - 원화   */
              ,AVG(SUM(CUST_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS CUST_AMT_MNTH_KRW  /* 객단가 이동평균(30일) - 원화   */
          FROM WT_CALC A
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST'      THEN CUST_AMT_RMB
                 WHEN L_LGND_ID = 'CUST_WEEK' THEN CUST_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'CUST_MNTH' THEN CUST_AMT_MNTH_RMB
               END AS Y_VAL_RMB  /* PAID:구매자수, CUST:객단가 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'PAID'      THEN PAID_CNT
                 WHEN L_LGND_ID = 'CUST'      THEN CUST_AMT_KRW
                 WHEN L_LGND_ID = 'CUST_WEEK' THEN CUST_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'CUST_MNTH' THEN CUST_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* PAID:구매자수, CUST:객단가 - 원화   */
         FROM WT_COPY A
             ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_RMB AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_RMB AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_RMB
          ,COALESCE(CASE WHEN L_LGND_ID LIKE 'PAID%' THEN CAST(CAST(Y_VAL_KRW AS DECIMAL(20,0)) AS VARCHAR) ELSE CAST(CAST(Y_VAL_KRW AS DECIMAL(20,2)) AS VARCHAR) END, '') AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
