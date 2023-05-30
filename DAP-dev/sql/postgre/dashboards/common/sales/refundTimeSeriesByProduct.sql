/* 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '564613428727, 564872651758, 617136486827, 618017669492, 630334774562' */        
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 일환불 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SALE_AMT_RMB                                           AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,REFD_AMT_RMB                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM WT_CAST A
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB /* 일매출 - 위안화 */
              ,SUM(REFD_AMT_RMB) AS REFD_AMT_RMB /* 일환불 - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW /* 일매출 - 원화   */
              ,SUM(REFD_AMT_KRW) AS REFD_AMT_KRW /* 일환불 - 원화   */
          FROM WT_EXCH A
      GROUP BY PRODUCT_ID
              ,STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PRODUCT_ID            
               ) AS SORT_KEY
              ,COALESCE(CAST(PRODUCT_ID AS VARCHAR), '') AS L_LGND_ID
              ,DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID)   AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT

              ,REFD_AMT_RMB                                                                 AS Y_VAL_REFD_RMB /* 환불금액 - 위안화 */
              ,CASE WHEN SALE_AMT_RMB = 0 THEN 0 ELSE REFD_AMT_RMB / SALE_AMT_RMB * 100 END AS Y_VAL_RATE_RMB /* 환불비중 - 위안화 */

              ,REFD_AMT_KRW                                                                 AS Y_VAL_REFD_KRW /* 환불금액 - 원화   */
              ,CASE WHEN SALE_AMT_KRW = 0 THEN 0 ELSE REFD_AMT_KRW / SALE_AMT_KRW * 100 END AS Y_VAL_RATE_KRW /* 환불비중 - 원화   */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_REFD_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_REFD_RMB
          ,COALESCE(CAST(Y_VAL_RATE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_RMB
          ,COALESCE(CAST(Y_VAL_REFD_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_REFD_KRW
          ,COALESCE(CAST(Y_VAL_RATE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT
