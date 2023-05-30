/* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1                       AS SORT_KEY
              ,'SALE'                  AS L_LGND_ID /* 일매출          */ 
              ,'결제금액 - 일매출'     AS L_LGND_NM /* 결제금액 - 일매출*/
     UNION ALL
        SELECT 2                       AS SORT_KEY
              ,'SALE_WEEK'             AS L_LGND_ID /* 주매출           */ 
              ,'결제금액 - 주매출'     AS L_LGND_NM /* 결제금액 - 주매출*/
     UNION ALL
        SELECT 3                       AS SORT_KEY
              ,'SALE_MNTH'             AS L_LGND_ID /* 월매출           */ 
              ,'결제금액 - 월매출'     AS L_LGND_NM /* 결제금액 - 월매출*/
     UNION ALL
        SELECT 4                       AS SORT_KEY
              ,'EXRE'                  AS L_LGND_ID /* 일매출(환불제외) */ 
              ,'환불제외금액 - 일매출' AS L_LGND_NM /* 결제금액 - 일매출*/
     UNION ALL
        SELECT 5                       AS SORT_KEY
              ,'EXRE_WEEK'             AS L_LGND_ID /* 주매출(환불제외) */
              ,'환불제외금액 - 주매출' AS L_LGND_NM /* 결제금액 - 주매출*/
     UNION ALL
        SELECT 6                       AS SORT_KEY
              ,'EXRE_MNTH'             AS L_LGND_ID /* 월매출(환불제외) */
              ,'환불제외금액 - 월매출' AS L_LGND_NM /* 결제금액 - 월매출*/
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(SALE_AMT_RMB)                                                                           AS SALE_AMT_RMB       /* 일매출                          - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출           이동평균( 5일) - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출           이동평균(30일) - 위안화 */
              ,    SUM(EXRE_AMT_RMB)                                                                           AS EXRE_AMT_RMB       /* 일매출(환불제외)                - 위안화 */
              ,AVG(SUM(EXRE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS EXRE_AMT_WEEK_RMB  /* 주매출(환불제외) 이동평균( 5일) - 위안화 */
              ,AVG(SUM(EXRE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS EXRE_AMT_MNTH_RMB  /* 월매출(환불제외) 이동평균(30일) - 위안화 */

              ,    SUM(SALE_AMT_KRW)                                                                           AS SALE_AMT_KRW       /* 일매출                          - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 일매출           이동평균( 5일) - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 일매출           이동평균(30일) - 원화   */
              ,    SUM(EXRE_AMT_KRW)                                                                           AS EXRE_AMT_KRW       /* 일매출(환불제외)                - 원화   */
              ,AVG(SUM(EXRE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS EXRE_AMT_WEEK_KRW  /* 일매출(환불제외) 이동평균( 5일) - 원화   */
              ,AVG(SUM(EXRE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS EXRE_AMT_MNTH_KRW  /* 일매출(환불제외) 이동평균(30일) - 원화   */
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
                 WHEN L_LGND_ID = 'EXRE'      THEN EXRE_AMT_RMB
                 WHEN L_LGND_ID = 'EXRE_WEEK' THEN EXRE_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'EXRE_MNTH' THEN EXRE_AMT_MNTH_RMB
               END AS Y_VAL_RMB  /* 매출금액 - 위안화 */
              ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_KRW
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_KRW
                 WHEN L_LGND_ID = 'EXRE'      THEN EXRE_AMT_KRW
                 WHEN L_LGND_ID = 'EXRE_WEEK' THEN EXRE_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'EXRE_MNTH' THEN EXRE_AMT_MNTH_KRW
              END AS Y_VAL_KRW  /* 매출금액 - 원화   */
          FROM WT_COPY A
              ,WT_MOVE B
    )
    SELECT SORT_KEY 
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT
