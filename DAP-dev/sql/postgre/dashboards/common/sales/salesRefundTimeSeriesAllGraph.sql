/* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1           AS SORT_KEY
              ,'SALE'      AS L_LGND_ID /* 일매출          */ 
              ,'일매출'    AS L_LGND_NM /* 결제금액 - 일매출*/
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'SALE_WEEK'  AS L_LGND_ID /* 주매출           */ 
              ,'주매출'     AS L_LGND_NM /* 결제금액 - 주매출*/
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'SALE_MNTH'  AS L_LGND_ID /* 월매출           */ 
              ,'월매출'     AS L_LGND_NM /* 결제금액 - 월매출*/
     UNION ALL
        SELECT 4            AS SORT_KEY
              ,'REFD'       AS L_LGND_ID /* 일환불           */ 
              ,'일환불'     AS L_LGND_NM /* 환불금액 - 일환불*/
     UNION ALL
        SELECT 5            AS SORT_KEY
              ,'REFD_WEEK'  AS L_LGND_ID /* 주환불           */
              ,'주환불'     AS L_LGND_NM /* 환불금액 - 주환불*/
     UNION ALL
        SELECT 6            AS SORT_KEY
              ,'REFD_MNTH'  AS L_LGND_ID /* 월환불          */
              ,'월환불'     AS L_LGND_NM /* 환불금액 - 월환불*/
     UNION ALL
        SELECT 7            AS SORT_KEY
              ,'RATE'       AS L_LGND_ID /* 일환불비중       */ 
              ,'일환불비중' AS L_LGND_NM /* 환불비중 - 일비중*/
     UNION ALL
        SELECT 8            AS SORT_KEY
              ,'RATE_WEEK'  AS L_LGND_ID /* 주환불비중       */
              ,'주환불비중' AS L_LGND_NM /* 환불금액 - 주비중*/
     UNION ALL
        SELECT 9            AS SORT_KEY
              ,'RATE_MNTH'  AS L_LGND_ID /* 월환불비중       */
              ,'월환불비중' AS L_LGND_NM /* 환불금액 - 월비중*/
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(SALE_AMT_RMB)                                                                           AS SALE_AMT_RMB       /* 일매출                - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출 이동평균( 5일) - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출 이동평균(30일) - 위안화 */
              ,    SUM(REFD_AMT_RMB)                                                                           AS REFD_AMT_RMB       /* 일환불                - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_RMB  /* 주환불 이동평균( 5일) - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_RMB  /* 월환불 이동평균(30일) - 위안화 */

              ,    SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100                                                                           AS REFD_RATE_RMB       /* 일비중                - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_RATE_WEEK_RMB  /* 주비중 이동평균( 5일) - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_RATE_MNTH_RMB  /* 월비중 이동평균(30일) - 위안화 */


              ,    SUM(SALE_AMT_KRW)                                                                           AS SALE_AMT_KRW       /* 일매출                - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 일매출 이동평균( 5일) - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 일매출 이동평균(30일) - 원화   */
              ,    SUM(REFD_AMT_KRW)                                                                           AS REFD_AMT_KRW       /* 일환불                - 원화   */
              ,AVG(SUM(REFD_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_KRW  /* 일환불 이동평균( 5일) - 원화   */
              ,AVG(SUM(REFD_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_KRW  /* 일환불 이동평균(30일) - 원화   */

              ,    SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100                                                                           AS REFD_RATE_KRW       /* 일비중                - 원화   */
              ,AVG(SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_RATE_WEEK_KRW  /* 주비중 이동평균( 5일) - 원화   */
              ,AVG(SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_RATE_MNTH_KRW  /* 월비중 이동평균(30일) - 원화   */
          FROM WT_EXCH A
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_RMB
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_RMB
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_RMB
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_RMB
                 WHEN L_LGND_ID = 'RATE'      THEN REFD_RATE_RMB
                 WHEN L_LGND_ID = 'RATE_WEEK' THEN REFD_RATE_WEEK_RMB
                 WHEN L_LGND_ID = 'RATE_MNTH' THEN REFD_RATE_MNTH_RMB
             END AS Y_VAL_RMB  /* 매출/환불 금액/비중 - 위안화 */
             ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_KRW
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_KRW
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_KRW
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_KRW
                 WHEN L_LGND_ID = 'RATE'      THEN REFD_RATE_KRW
                 WHEN L_LGND_ID = 'RATE_WEEK' THEN REFD_RATE_WEEK_KRW
                 WHEN L_LGND_ID = 'RATE_MNTH' THEN REFD_RATE_MNTH_KRW
             END AS Y_VAL_KRW  /* 매출/환불 금액/비중 - 원화   */
        FROM WT_COPY A
            ,WT_MOVE B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CASE WHEN SORT_KEY IN (7, 8, 9) THEN CAST(Y_VAL_RMB AS DECIMAL(20,2)) ELSE CAST(Y_VAL_RMB AS DECIMAL(20,0)) END, 0) AS Y_VAL_RMB
          ,COALESCE(CASE WHEN SORT_KEY IN (7, 8, 9) THEN CAST(Y_VAL_KRW AS DECIMAL(20,2)) ELSE CAST(Y_VAL_KRW AS DECIMAL(20,0)) END, 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
