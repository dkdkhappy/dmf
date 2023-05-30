/* 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 SQL */
WITH WT_WHERE AS
    (
        SELECT {BASE_MNTH}  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1           AS SORT_KEY
              ,'환불금액'  AS ROW_TITL
     UNION ALL
        SELECT 2           AS SORT_KEY
              ,'환불비중'  AS ROW_TITL
    ), WT_EXCH AS
    (
        SELECT (SELECT BASE_MNTH FROM WT_WHERE) AS BASE_MNTH
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_EXCH_YOY AS
    (
        SELECT (SELECT BASE_MNTH FROM WT_WHERE_YOY) AS BASE_MNTH_YOY
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 YoY - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 YoY - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 YoY - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 YoY - 원화   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_SUM AS
    (
        SELECT 1                 AS SORT_KEY
              ,MAX(BASE_MNTH)    AS BASE_MNTH
              ,SUM(REFD_AMT_RMB) AS REFD_RMB  /* 환불금액 - 위안화 */
              ,SUM(REFD_AMT_KRW) AS REFD_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
     UNION ALL
        SELECT 2                                     AS SORT_KEY
              ,MAX(BASE_MNTH)                        AS BASE_MNTH
              ,SUM(REFD_AMT_RMB) / SUM(SALE_AMT_RMB) AS REFD_RMB  /* 환불비중 - 위안화 */
              ,SUM(REFD_AMT_KRW) / SUM(SALE_AMT_KRW) AS REFD_KRW  /* 환불비중 - 원화   */
          FROM WT_EXCH A
    ), WT_SUM_YOY AS
    (
        SELECT 1                  AS SORT_KEY
              ,MAX(BASE_MNTH_YOY) AS BASE_MNTH_YOY
              ,SUM(REFD_AMT_RMB)  AS REFD_RMB  /* 환불금액 - 위안화 */
              ,SUM(REFD_AMT_KRW)  AS REFD_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH_YOY A
     UNION ALL
        SELECT 2                                     AS SORT_KEY
              ,MAX(BASE_MNTH_YOY)                    AS BASE_MNTH_YOY
              ,SUM(REFD_AMT_RMB) / SUM(SALE_AMT_RMB) AS REFD_RMB  /* 환불비중 - 위안화 */
              ,SUM(REFD_AMT_KRW) / SUM(SALE_AMT_KRW) AS REFD_KRW  /* 환불비중 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.ROW_TITL
              ,CAST(CASE WHEN C.BASE_MNTH_YOY = (SELECT BASE_MNTH FROM WT_WHERE_YOY) THEN C.REFD_RMB END AS DECIMAL(20,2)) AS REFD_YOY_RMB  /* 전년도 - 위안화 */
              ,CAST(CASE WHEN B.BASE_MNTH     = (SELECT BASE_MNTH FROM WT_WHERE    ) THEN B.REFD_RMB END AS DECIMAL(20,2)) AS REFD_RMB      /* 올해   - 위안화 */
    
              ,CAST(CASE WHEN C.BASE_MNTH_YOY = (SELECT BASE_MNTH FROM WT_WHERE_YOY) THEN C.REFD_KRW END AS DECIMAL(20,2)) AS REFD_YOY_KRW  /* 전년도 - 원화   */
              ,CAST(CASE WHEN B.BASE_MNTH     = (SELECT BASE_MNTH FROM WT_WHERE    ) THEN B.REFD_KRW END AS DECIMAL(20,2)) AS REFD_KRW      /* 올해   - 원화   */
          FROM WT_COPY A LEFT OUTER JOIN WT_SUM     B ON (A.SORT_KEY = B.SORT_KEY)
                         LEFT OUTER JOIN WT_SUM_YOY C ON (A.SORT_KEY = C.SORT_KEY)
    )
    SELECT SORT_KEY
          ,ROW_TITL
          ,CASE WHEN ROW_TITL = '환불비중' THEN TO_CHAR(REFD_YOY_RMB, 'FM999,999,999,999,990.99%') ELSE TO_CHAR(REFD_YOY_RMB, 'FM999,999,999,999,990') END AS REFD_YOY_RMB  /* 전년도 - 위안화 */
          ,CASE WHEN ROW_TITL = '환불비중' THEN TO_CHAR(REFD_RMB    , 'FM999,999,999,999,990.99%') ELSE TO_CHAR(REFD_RMB    , 'FM999,999,999,999,990') END AS REFD_RMB      /* 올해   - 위안화 */
          ,CASE WHEN ROW_TITL = '환불비중' THEN TO_CHAR(REFD_YOY_KRW, 'FM999,999,999,999,990.99%') ELSE TO_CHAR(REFD_YOY_KRW, 'FM999,999,999,999,990') END AS REFD_YOY_KRW  /* 전년도 - 원화   */
          ,CASE WHEN ROW_TITL = '환불비중' THEN TO_CHAR(REFD_KRW    , 'FM999,999,999,999,990.99%') ELSE TO_CHAR(REFD_KRW    , 'FM999,999,999,999,990') END AS REFD_KRW      /* 올해   - 원화   */
      FROM WT_BASE
  ORDER BY SORT_KEY
