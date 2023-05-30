/* 8. 환불 정보에 대한 시계열 / 데이터 뷰어 - 그래프상단 정보 SQL */
WITH WT_BASE AS
    (
        SELECT REFD_AMT_YEAR_RMB                                                                                                                                    /* 당해 환불 누적 금액   - 위안화 */
              ,REFD_AMT_YEAR_YOY_RMB                                                                                                                                /* 전년도 환불 누적 금액 - 위안화 */
              ,REFD_RATE_YEAR_YOY_RMB                                                                                                                               /* 환불 증감률           - 위안화 */
              , REFD_AMT_YEAR_RMB     / SALE_AMT_YEAR_RMB     * 100                                                                       AS PCNT_AMT_YEAR_RMB      /* 당해 환불 비중        - 위안화 */
              , REFD_AMT_YEAR_YOY_RMB / SALE_AMT_YEAR_YOY_RMB * 100                                                                       AS PCNT_AMT_YEAR_YOY_RMB  /* 전해 환불 비중        - 위안화 */
              ,(REFD_AMT_YEAR_RMB     / SALE_AMT_YEAR_RMB     * 100) - COALESCE((REFD_AMT_YEAR_YOY_RMB / SALE_AMT_YEAR_YOY_RMB * 100), 0) AS PCNT_RATE_YEAR_RMB     /* 환불금액 증감률       - 위안화 */
              ,REFD_AMT_YEAR_KRW                                                                                                                                    /* 당해 환불 누적 금액   -   원화 */
              ,REFD_AMT_YEAR_YOY_KRW                                                                                                                                /* 전년도 환불 누적 금액 -   원화 */
              ,REFD_RATE_YEAR_YOY_KRW                                                                                                                               /* 환불 증감률           -   원화 */
              , REFD_AMT_YEAR_KRW     / SALE_AMT_YEAR_KRW     * 100                                                                       AS PCNT_AMT_YEAR_KRW      /* 당해 환불 비중        -   원화 */
              , REFD_AMT_YEAR_YOY_KRW / SALE_AMT_YEAR_YOY_KRW * 100                                                                       AS PCNT_AMT_YEAR_YOY_KRW  /* 전해 환불 비중        -   원화 */
              ,(REFD_AMT_YEAR_KRW     / SALE_AMT_YEAR_KRW     * 100) - COALESCE((REFD_AMT_YEAR_YOY_KRW / SALE_AMT_YEAR_YOY_KRW * 100), 0) AS PCNT_RATE_YEAR_KRW     /* 환불금액 증감률       -   원화 */
          FROM DASH.SUM_SALESTIMESERIESCARDDATA
    )
    SELECT CAST(REFD_AMT_YEAR_RMB      AS DECIMAL(20,0)) AS REFD_AMT_YEAR_RMB       /* 당해 환불 누적 금액   - 위안화 */
          ,CAST(REFD_AMT_YEAR_YOY_RMB  AS DECIMAL(20,0)) AS REFD_AMT_YEAR_YOY_RMB   /* 전년도 환불 누적 금액 - 위안화 */
          ,CAST(REFD_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_RMB  /* 환불 증감률           - 위안화 */
          ,CAST(PCNT_AMT_YEAR_RMB      AS DECIMAL(20,0)) AS PCNT_AMT_YEAR_RMB       /* 당해 환불 비중        - 위안화 */
          ,CAST(PCNT_AMT_YEAR_YOY_RMB  AS DECIMAL(20,0)) AS PCNT_AMT_YEAR_YOY_RMB   /* 전해 환불 비중        - 위안화 */
          ,CAST(PCNT_RATE_YEAR_RMB     AS DECIMAL(20,2)) AS PCNT_RATE_YEAR_RMB      /* 환불금액 증감률       - 위안화 */
          ,CAST(REFD_AMT_YEAR_KRW      AS DECIMAL(20,0)) AS REFD_AMT_YEAR_KRW       /* 당해 환불 누적 금액   -   원화 */
          ,CAST(REFD_AMT_YEAR_YOY_KRW  AS DECIMAL(20,0)) AS REFD_AMT_YEAR_YOY_KRW   /* 전년도 환불 누적 금액 -   원화 */
          ,CAST(REFD_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_KRW  /* 환불 증감률           -   원화 */
          ,CAST(PCNT_AMT_YEAR_KRW      AS DECIMAL(20,0)) AS PCNT_AMT_YEAR_KRW       /* 당해 환불 비중        -   원화 */
          ,CAST(PCNT_AMT_YEAR_YOY_KRW  AS DECIMAL(20,0)) AS PCNT_AMT_YEAR_YOY_KRW   /* 전해 환불 비중        -   원화 */
          ,CAST(PCNT_RATE_YEAR_KRW     AS DECIMAL(20,2)) AS PCNT_RATE_YEAR_KRW      /* 환불금액 증감률       -   원화 */
      FROM WT_BASE