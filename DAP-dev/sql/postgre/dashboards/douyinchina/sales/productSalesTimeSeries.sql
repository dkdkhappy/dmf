/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY
              ,TRIM(PROD_ID)                         AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '564613428727, 564872651758, 617136486827, 618017669492, 630334774562' */
    ), WT_GROUP_SORT_KEY_1 AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,A.PROD_ID
              ,A.PROD_NM
          FROM (
            SELECT STRING_AGG(PROD_ID, ',')           AS PROD_ID
                  ,DASH_RAW.SF_{TAG}_PROD_NM(PROD_ID) AS PROD_NM
              FROM WT_PROD_WHERE
          GROUP BY PROD_NM
            ) A
    ), WT_GROUP_SORT_KEY as (
    SELECT * FROM WT_GROUP_SORT_KEY_1
	UNION ALL
	SELECT NULL, '9999999999999', '전체 매출'
),	WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_BCD A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              , SALE_AMT_RMB                                           AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              , SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
          FROM WT_CAST A
     UNION ALL
        SELECT '9999999999999' AS PRODUCT_ID
              ,STATISTICS_DATE
              , PAYMENT_AMOUNT                                           AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              , PAYMENT_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB /* 일매출            - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW /* 일매출            - 원화   */
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
              ,PRODUCT_ID AS L_LGND_ID
              ,CASE
                 WHEN PRODUCT_ID = '9999999999999' THEN '전체 매출'
                 ELSE DASH_RAW.SF_{TAG}_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,SALE_AMT_RMB    AS Y_VAL_SALE_RMB /* 일매출           - 위안화 */
              ,SALE_AMT_KRW    AS Y_VAL_SALE_KRW /* 일매출           - 원화   */
        FROM WT_SUM A
    ORDER BY SORT_KEY
            ,L_LGND_ID
            ,X_DT
    ), 	WT_MOD_BASE AS
    (
        SELECT L_LGND_NM
              ,X_DT
              ,STRING_AGG(L_LGND_ID, ',') AS L_LGND_ID
              ,SUM(Y_VAL_SALE_RMB)        AS Y_VAL_SALE_RMB
              ,SUM(Y_VAL_SALE_KRW)        AS Y_VAL_SALE_KRW
          FROM WT_BASE
      GROUP BY L_LGND_NM
              ,X_DT
    ) 
    SELECT (
            SELECT SORT_KEY
                FROM WT_GROUP_SORT_KEY X
                WHERE X.PROD_NM = A.L_LGND_NM
           ) AS SORT_KEY
          ,(
            SELECT PROD_ID
                FROM WT_GROUP_SORT_KEY X
                WHERE X.PROD_NM = A.L_LGND_NM
           ) AS L_LGND_ID
          ,A.L_LGND_NM
          ,A.X_DT
          ,COALESCE(CAST(A.Y_VAL_SALE_RMB AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_RMB
          ,COALESCE(CAST(A.Y_VAL_SALE_KRW AS DECIMAL(20,0)), 0) AS Y_VAL_SALE_KRW
     FROM WT_MOD_BASE A
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT
 