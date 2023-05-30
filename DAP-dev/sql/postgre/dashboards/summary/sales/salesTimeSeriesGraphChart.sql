/* 5. 매출 정보에 대한 시계열 / 데이터 뷰어 - 매출 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE) AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,CAST({TO_DT} AS DATE) AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
    ), WT_SALE_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_RMB
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_rmb'
    ), WT_SALE_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS SALE_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'sale_amt_krw'
    ), WT_REFD_AMT_RMB AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_RMB
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CHRT_KEY = 'refd_amt_rmb'
    ), WT_REFD_AMT_KRW AS
    (
        SELECT STATISTICS_DATE
              ,VALUE           AS REFD_AMT_KRW
          FROM DASH.SUM_REFDTIMESERIESALLDATA
         WHERE CHRT_KEY = 'refd_amt_krw'
    ), WT_AMT_RMB AS
    (
        SELECT A.STATISTICS_DATE
              ,A.SALE_AMT_RMB                               AS SALE_AMT_RMB
              ,A.SALE_AMT_RMB - COALESCE(B.REFD_AMT_RMB, 0) AS EXRE_AMT_RMB
          FROM WT_SALE_AMT_RMB A
     LEFT JOIN WT_REFD_AMT_RMB B
            ON A.STATISTICS_DATE = B.STATISTICS_DATE
         WHERE A.STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_AMT_KRW AS
    (
        SELECT A.STATISTICS_DATE
              ,A.SALE_AMT_KRW                               AS SALE_AMT_KRW
              ,A.SALE_AMT_KRW - COALESCE(B.REFD_AMT_KRW, 0) AS EXRE_AMT_KRW
          FROM WT_SALE_AMT_KRW A
     LEFT JOIN WT_REFD_AMT_KRW B
            ON A.STATISTICS_DATE = B.STATISTICS_DATE
         WHERE A.STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ),
    WT_MOVE AS
    (
        SELECT A.STATISTICS_DATE
              ,    SUM(A.SALE_AMT_RMB)                                                                             AS SALE_AMT_RMB       /* 일매출                - 위안화 */
              ,AVG(SUM(A.SALE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출 이동평균( 5일) - 위안화 */
              ,AVG(SUM(A.SALE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출 이동평균(30일) - 위안화 */
              ,    SUM(A.EXRE_AMT_RMB)                                                                             AS EXRE_AMT_RMB       /* 일매출(환불제외)                - 위안화 */
              ,AVG(SUM(A.EXRE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW)   AS EXRE_AMT_WEEK_RMB  /* 주매출(환불제외) 이동평균( 5일) - 위안화 */
              ,AVG(SUM(A.EXRE_AMT_RMB)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)   AS EXRE_AMT_MNTH_RMB  /* 월매출(환불제외) 이동평균(30일) - 위안화 */
                            
              ,    SUM(B.SALE_AMT_KRW)                                                                             AS SALE_AMT_KRW       /* 일매출                - 원화   */
              ,AVG(SUM(B.SALE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 주매출 이동평균( 5일) - 원화   */
              ,AVG(SUM(B.SALE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 월매출 이동평균(30일) - 원화   */
              ,    SUM(B.EXRE_AMT_KRW)                                                                             AS EXRE_AMT_KRW       /* 일매출(환불제외)                - 원화   */
              ,AVG(SUM(B.EXRE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW)   AS EXRE_AMT_WEEK_KRW  /* 일매출(환불제외) 이동평균( 5일) - 원화   */
              ,AVG(SUM(B.EXRE_AMT_KRW)) OVER(ORDER BY A.STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW)   AS EXRE_AMT_MNTH_KRW  /* 일매출(환불제외) 이동평균(30일) - 원화   */
          FROM WT_AMT_RMB A INNER JOIN WT_AMT_KRW B ON (A.STATISTICS_DATE = B.STATISTICS_DATE)
      GROUP BY A.STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,CAST(STATISTICS_DATE AS DATE) AS X_DT
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