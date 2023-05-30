/* 10. 라이브별 매출 정보 시계열 그래프 - 라이브별 매출 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_LIVE_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY 
              ,TRIM(LIVE_ID)                         AS LIVE_ID
          FROM REGEXP_SPLIT_TO_TABLE({LIVE_ID}, ',') AS LIVE_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '564613428727, 564872651758, 617136486827, 618017669492, 630334774562' */        
    ), WT_STORE AS
    (
        SELECT PAYMENT_AMOUNT                                         AS SALE_AMT_RMB
              ,PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(STATISTICS_DATE) AS SALE_AMT_KRW
              ,STATISTICS_DATE
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_RAW AS
    (
        SELECT ACCOUNT_NAME
              ,TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') AS STATISTICS_DATE
              ,CAST(LIVE_TRANSACTION_AMOUNT_YUAN        AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SELF_OPERATED_DELIVERY                                     AS SELF_OPERATED_DELIVERY
          FROM DASH_RAW.OVER_{TAG}_ACCOUNT_COMPOSITION
         WHERE TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_AGG AS
    (
        SELECT ACCOUNT_NAME
              ,STATISTICS_DATE
              ,SALE_AMT_RMB
          FROM WT_CAST_RAW
         WHERE SELF_OPERATED_DELIVERY = '自营'
         UNION
        SELECT '기타'            AS ACCOUNT_NAME
              ,STATISTICS_DATE
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB
          FROM WT_CAST_RAW
         WHERE SELF_OPERATED_DELIVERY != '自营'
      GROUP BY STATISTICS_DATE
    ), WT_FULL_DATE AS
    (
        SELECT STATISTICS_DATE
              ,LIVE_ID
          FROM (SELECT TO_CHAR
                    (
                        GENERATE_SERIES(MIN(CAST(STATISTICS_DATE AS DATE)), MAX(CAST(STATISTICS_DATE AS DATE)), '1d'), 
                        'YYYY-MM-DD'
                    ) AS STATISTICS_DATE FROM WT_CAST_AGG) A
    CROSS JOIN WT_LIVE_WHERE B
    ), WT_CAST AS
    (
        SELECT A.LIVE_ID         AS ACCOUNT_NAME
              ,A.STATISTICS_DATE
              ,B.SALE_AMT_RMB
          FROM WT_FULL_DATE A
     LEFT JOIN WT_CAST_AGG B
            ON A.LIVE_ID = B.ACCOUNT_NAME
           AND A.STATISTICS_DATE = B.STATISTICS_DATE
    ), WT_EXCH AS
    (
        SELECT ACCOUNT_NAME
              ,STATISTICS_DATE
              ,SALE_AMT_RMB                                           AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
          FROM WT_CAST A
         WHERE ACCOUNT_NAME IN (SELECT LIVE_ID FROM WT_LIVE_WHERE)
    ), WT_SUM AS
    (
        SELECT ACCOUNT_NAME
              ,STATISTICS_DATE
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB /* 일매출 - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW /* 일매출 - 원화   */
          FROM WT_EXCH A
      GROUP BY ACCOUNT_NAME
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_LIVE_WHERE X
                 WHERE X.LIVE_ID = A.ACCOUNT_NAME
               ) AS SORT_KEY
              ,COALESCE(A.ACCOUNT_NAME, '')                                                       AS L_LGND_ID
              ,COALESCE(A.ACCOUNT_NAME, '')                                                       AS L_LGND_NM
              ,A.STATISTICS_DATE                                                                  AS X_DT

              ,A.SALE_AMT_RMB                                                                     AS Y_VAL_SALE_RMB /* 매출금액 - 위안화 */
              ,CASE WHEN A.SALE_AMT_RMB = 0 THEN 0 ELSE A.SALE_AMT_RMB / COALESCE(NULLIF(B.SALE_AMT_RMB, 0), 1) * 100 END AS Y_VAL_RATE_RMB /* 매출비중 - 위안화 */

              ,A.SALE_AMT_KRW                                                                     AS Y_VAL_SALE_KRW /* 매출금액 - 원화   */
              ,CASE WHEN A.SALE_AMT_KRW = 0 THEN 0 ELSE A.SALE_AMT_KRW / COALESCE(NULLIF(B.SALE_AMT_KRW, 0), 1) * 100 END AS Y_VAL_RATE_KRW /* 매출비중 - 원화   */
        FROM WT_SUM A
            ,WT_STORE B
        WHERE A.STATISTICS_DATE = B.STATISTICS_DATE
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_SALE_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_RMB
          ,COALESCE(CAST(Y_VAL_RATE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_RMB
          ,COALESCE(CAST(Y_VAL_SALE_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_KRW
          ,COALESCE(CAST(Y_VAL_RATE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT
