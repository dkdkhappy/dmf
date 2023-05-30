/* 4. 매출 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_RAW_BASE AS
    (
        SELECT SALE_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
              ,SALE_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
              ,REFD_AMT_YEAR_RMB
              ,REFD_AMT_YEAR_YOY_RMB
              ,SALE_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
              ,SALE_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
              ,REFD_AMT_YEAR_KRW
              ,REFD_AMT_YEAR_YOY_KRW
          FROM DASH.SUM_SALESTIMESERIESCARDDATA
    ), WT_BASE AS
    (
        SELECT SALE_AMT_YEAR_RMB - REFD_AMT_YEAR_RMB                                                                                AS SALE_AMT_YEAR_RMB
              ,SALE_AMT_YEAR_YOY_RMB - REFD_AMT_YEAR_YOY_RMB                                                                        AS SALE_AMT_YEAR_YOY_RMB
              ,((COALESCE((SALE_AMT_YEAR_RMB - REFD_AMT_YEAR_RMB) / (SALE_AMT_YEAR_YOY_RMB - REFD_AMT_YEAR_YOY_RMB), 0)) - 1) * 100 AS SALE_RATE_YEAR_YOY_RMB
              ,SALE_AMT_YEAR_KRW - REFD_AMT_YEAR_KRW                                                                                AS SALE_AMT_YEAR_KRW
              ,SALE_AMT_YEAR_YOY_KRW - REFD_AMT_YEAR_YOY_KRW                                                                        AS SALE_AMT_YEAR_YOY_KRW
              ,((COALESCE((SALE_AMT_YEAR_KRW - REFD_AMT_YEAR_KRW) / (SALE_AMT_YEAR_YOY_KRW - REFD_AMT_YEAR_YOY_KRW), 0)) - 1) * 100 AS SALE_RATE_YEAR_YOY_KRW
          FROM WT_RAW_BASE
    )
    SELECT CAST(SALE_AMT_YEAR_RMB      AS DECIMAL(20,0)) AS SALE_AMT_YEAR_RMB       /* 당해 누적 금액   - 위안화  */
          ,CAST(SALE_AMT_YEAR_YOY_RMB  AS DECIMAL(20,0)) AS SALE_AMT_YEAR_YOY_RMB   /* 전년도 누적 금액 - 위안화  */
          ,CAST(SALE_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_RMB  /* 증감률           - 위안화  */
          ,CAST(SALE_AMT_YEAR_KRW      AS DECIMAL(20,0)) AS SALE_AMT_YEAR_KRW       /* 당해 누적 금액   - 원화    */
          ,CAST(SALE_AMT_YEAR_YOY_KRW  AS DECIMAL(20,0)) AS SALE_AMT_YEAR_YOY_KRW   /* 전년도 누적 금액 - 원화    */
          ,CAST(SALE_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_KRW  /* 증감률           - 원화    */
      FROM WT_BASE