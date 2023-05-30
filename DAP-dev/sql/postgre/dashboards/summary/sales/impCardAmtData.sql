/* 1. 중요정보 카드 - 매출 금액, 매출 비율, 브랜드 매출 순위 SQL */
WITH WT_BASE AS
    (
        SELECT SALE_AMT_RMB          - REFD_AMT_RMB          AS SALE_AMT_RMB
              ,SALE_AMT_DOD_RMB      - REFD_AMT_DOD_RMB      AS SALE_AMT_DOD_RMB
              ,SALE_AMT_MNTH_RMB     - REFD_AMT_MNTH_RMB     AS SALE_AMT_MNTH_RMB
              ,SALE_AMT_MNTH_YOY_RMB - REFD_AMT_MNTH_YOY_RMB AS SALE_AMT_MNTH_YOY_RMB
              ,SALE_AMT_YEAR_RMB     - REFD_AMT_YEAR_RMB     AS SALE_AMT_YEAR_RMB
              ,SALE_AMT_YEAR_YOY_RMB - REFD_AMT_YEAR_YOY_RMB AS SALE_AMT_YEAR_YOY_RMB
              
              ,SALE_AMT_KRW          - REFD_AMT_KRW          AS SALE_AMT_KRW
              ,SALE_AMT_DOD_KRW      - REFD_AMT_DOD_KRW      AS SALE_AMT_DOD_KRW
              ,SALE_AMT_MNTH_KRW     - REFD_AMT_MNTH_KRW     AS SALE_AMT_MNTH_KRW
              ,SALE_AMT_MNTH_YOY_KRW - REFD_AMT_MNTH_YOY_KRW AS SALE_AMT_MNTH_YOY_KRW
              ,SALE_AMT_YEAR_KRW     - REFD_AMT_YEAR_KRW     AS SALE_AMT_YEAR_KRW
              ,SALE_AMT_YEAR_YOY_KRW - REFD_AMT_YEAR_YOY_KRW AS SALE_AMT_YEAR_YOY_KRW
              
              ,REFD_AMT_RMB
              ,REFD_AMT_DOD_RMB
              ,REFD_AMT_MNTH_RMB
              ,REFD_AMT_MNTH_YOY_RMB
              ,REFD_AMT_YEAR_RMB
              ,REFD_AMT_YEAR_YOY_RMB
              
              ,REFD_AMT_KRW
              ,REFD_AMT_DOD_KRW
              ,REFD_AMT_MNTH_KRW
              ,REFD_AMT_MNTH_YOY_KRW
              ,REFD_AMT_YEAR_KRW
              ,REFD_AMT_YEAR_YOY_KRW
          FROM DASH.SUM_IMPCARDAMTDATA
    ), WT_SALE AS
    (
        SELECT SALE_AMT_RMB                                                                       /* 전일 매출                - 위안화 */
              ,(SALE_AMT_RMB      / SALE_AMT_DOD_RMB      - 1) * 100 AS SALE_RATE_DOD_RMB         /* 전일 매출 비율 DOD       - 위안화 */
              ,SALE_AMT_MNTH_RMB                                                                  /* 월별 누적 매출           - 위안화 */
              ,(SALE_AMT_MNTH_RMB / SALE_AMT_MNTH_YOY_RMB - 1) * 100 AS SALE_RATE_MNTH_YOY_RMB    /* 월별 누적 매출 비율 YoY  - 위안화 */
              ,SALE_AMT_YEAR_RMB                                                                  /* 연간 누적 매출           - 위안화 */
              ,(SALE_AMT_YEAR_RMB / SALE_AMT_YEAR_YOY_RMB - 1) * 100 AS SALE_RATE_YEAR_YOY_RMB    /* 연간 누적 매출 비율 YoY  - 위안화 */
              
              ,SALE_AMT_KRW                                                                       /* 전일 매출                - 원화 */
              ,(SALE_AMT_KRW      / SALE_AMT_DOD_KRW      - 1) * 100 AS SALE_RATE_DOD_KRW         /* 전일 매출 비율 DOD       - 원화 */
              ,SALE_AMT_MNTH_KRW                                                                  /* 월별 누적 매출           - 원화 */
              ,(SALE_AMT_MNTH_KRW / SALE_AMT_MNTH_YOY_KRW - 1) * 100 AS SALE_RATE_MNTH_YOY_KRW    /* 월별 누적 매출 비율 YoY  - 원화 */
              ,SALE_AMT_YEAR_KRW                                                                  /* 연간 누적 매출           - 원화 */
              ,(SALE_AMT_YEAR_KRW / SALE_AMT_YEAR_YOY_KRW - 1) * 100 AS SALE_RATE_YEAR_YOY_KRW    /* 연간 누적 매출 비율 YoY  - 원화 */

              ,REFD_AMT_RMB                                                                       /* 전일 환불                - 위안화 */
              ,(REFD_AMT_RMB      / REFD_AMT_DOD_RMB      - 1) * 100 AS REFD_RATE_DOD_RMB         /* 전일 환불 비율 DOD       - 위안화 */
              ,REFD_AMT_MNTH_RMB                                                                  /* 월별 누적 환불           - 위안화 */
              ,(REFD_AMT_MNTH_RMB / REFD_AMT_MNTH_YOY_RMB - 1) * 100 AS REFD_RATE_MNTH_YOY_RMB    /* 월별 누적 환불 비율 YoY  - 위안화 */
              ,REFD_AMT_YEAR_RMB                                                                  /* 연간 누적 환불           - 위안화 */
              ,(REFD_AMT_YEAR_RMB / REFD_AMT_YEAR_YOY_RMB - 1) * 100 AS REFD_RATE_YEAR_YOY_RMB    /* 연간 누적 환불 비율 YoY  - 위안화 */
              
              ,REFD_AMT_KRW                                                                       /* 전일 환불                - 원화 */
              ,(REFD_AMT_KRW      / REFD_AMT_DOD_KRW      - 1) * 100 AS REFD_RATE_DOD_KRW         /* 전일 환불 비율 DOD       - 원화 */
              ,REFD_AMT_MNTH_KRW                                                                  /* 월별 누적 환불           - 원화 */
              ,(REFD_AMT_MNTH_KRW / REFD_AMT_MNTH_YOY_KRW - 1) * 100 AS REFD_RATE_MNTH_YOY_KRW    /* 월별 누적 환불 비율 YoY  - 원화 */
              ,REFD_AMT_YEAR_KRW                                                                  /* 연간 누적 환불           - 원화 */
              ,(REFD_AMT_YEAR_KRW / REFD_AMT_YEAR_YOY_KRW - 1) * 100 AS REFD_RATE_YEAR_YOY_KRW    /* 연간 누적 환불 비율 YoY  - 원화 */
          FROM WT_BASE
    ), WT_RANK AS 
    (
        SELECT MAX(DCT_RANK_TOT     ) AS DCT_RANK_TOT       /* Tmall  내륙   매출 순위      */
              ,MAX(DGT_RANK_TOT     ) AS DGT_RANK_TOT       /* Tmall  글로벌 매출 순위      */
              ,MAX(DCD_RANK_TOT     ) AS DCD_RANK_TOT       /* Douyin 내륙   매출 순위      */
              ,MAX(DGD_RANK_TOT     ) AS DGD_RANK_TOT       /* Douyin 글로벌 매출 순위      */
              ,MAX(DCT_RANK_TOT_DIFF) AS DCT_RANK_TOT_DIFF  /* Tmall  내륙   매출 순위 변화 */
              ,MAX(DGT_RANK_TOT_DIFF) AS DGT_RANK_TOT_DIFF  /* Tmall  글로벌 매출 순위 변화 */
              ,MAX(DCD_RANK_TOT_DIFF) AS DCD_RANK_TOT_DIFF  /* Douyin 내륙   매출 순위 변화 */
              ,MAX(DGD_RANK_TOT_DIFF) AS DGD_RANK_TOT_DIFF  /* Douyin 글로벌 매출 순위 변화 */
          FROM DASH.SUM_RANKCARDDATA
    ), WT_REVN_TAGT AS
    (
        SELECT SUM("revenueTarget") * 1000000 AS REVN_TAGT_AMT  /* 한화로 백만원 단위 */
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN ('Tmall China', 'Tmall Global', 'Douyin China', 'Douyin Global')
    )
    SELECT CAST(SALE_AMT_RMB           AS DECIMAL(20,0)) AS SALE_AMT_RMB            /* 전일 매출                - 위안화 */
          ,CAST(SALE_RATE_DOD_RMB      AS DECIMAL(20,2)) AS SALE_RATE_DAY_YOY_RMB   /* 전일 매출 비율 YoY       - 위안화 */
          ,CAST(SALE_AMT_MNTH_RMB      AS DECIMAL(20,0)) AS SALE_AMT_MNTH_RMB       /* 월별 누적 매출           - 위안화 */
          ,CAST(SALE_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_MNTH_YOY_RMB  /* 월별 누적 매출 비율 YoY  - 위안화 */
          ,CAST(SALE_AMT_YEAR_RMB      AS DECIMAL(20,0)) AS SALE_AMT_YEAR_RMB       /* 연간 누적 매출           - 위안화 */
          ,CAST(SALE_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_RMB  /* 연간 누적 매출 비율 YoY  - 위안화 */
          ,CAST(SALE_AMT_KRW           AS DECIMAL(20,0)) AS SALE_AMT_KRW            /* 전일 매출                - 원화   */
          ,CAST(SALE_RATE_DOD_KRW      AS DECIMAL(20,2)) AS SALE_RATE_DAY_YOY_KRW   /* 전일 매출 비율 YoY       - 원화   */
          ,CAST(SALE_AMT_MNTH_KRW      AS DECIMAL(20,0)) AS SALE_AMT_MNTH_KRW       /* 월별 누적 매출           - 원화   */
          ,CAST(SALE_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_MNTH_YOY_KRW  /* 월별 누적 매출 비율 YoY  - 원화   */
          ,CAST(SALE_AMT_YEAR_KRW      AS DECIMAL(20,0)) AS SALE_AMT_YEAR_KRW       /* 연간 누적 매출           - 원화   */
          ,CAST(SALE_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS SALE_RATE_YEAR_YOY_KRW  /* 연간 누적 매출 비율 YoY  - 원화   */

          ,CAST(REFD_AMT_RMB           AS DECIMAL(20,0)) AS REFD_AMT_RMB            /* 전일 환불                - 위안화 */
          ,CAST(REFD_RATE_DOD_RMB      AS DECIMAL(20,2)) AS REFD_RATE_DAY_YOY_RMB   /* 전일 환불 비율 YoY       - 위안화 */
          ,CAST(REFD_AMT_MNTH_RMB      AS DECIMAL(20,0)) AS REFD_AMT_MNTH_RMB       /* 월별 누적 환불           - 위안화 */
          ,CAST(REFD_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_MNTH_YOY_RMB  /* 월별 누적 환불 비율 YoY  - 위안화 */
          ,CAST(REFD_AMT_YEAR_RMB      AS DECIMAL(20,0)) AS REFD_AMT_YEAR_RMB       /* 연간 누적 환불           - 위안화 */
          ,CAST(REFD_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_RMB  /* 연간 누적 환불 비율 YoY  - 위안화 */
          ,CAST(REFD_AMT_KRW           AS DECIMAL(20,0)) AS REFD_AMT_KRW            /* 전일 환불                - 원화   */
          ,CAST(REFD_RATE_DOD_KRW      AS DECIMAL(20,2)) AS REFD_RATE_DAY_YOY_KRW   /* 전일 환불 비율 YoY       - 원화   */
          ,CAST(REFD_AMT_MNTH_KRW      AS DECIMAL(20,0)) AS REFD_AMT_MNTH_KRW       /* 월별 누적 환불           - 원화   */
          ,CAST(REFD_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_MNTH_YOY_KRW  /* 월별 누적 환불 비율 YoY  - 원화   */
          ,CAST(REFD_AMT_YEAR_KRW      AS DECIMAL(20,0)) AS REFD_AMT_YEAR_KRW       /* 연간 누적 환불           - 원화   */
          ,CAST(REFD_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)) AS REFD_RATE_YEAR_YOY_KRW  /* 연간 누적 환불 비율 YoY  - 원화   */

          ,DCT_RANK_TOT       /* Tmall  내륙   매출 순위      */
          ,DGT_RANK_TOT       /* Tmall  글로벌 매출 순위      */
          ,DCD_RANK_TOT       /* Douyin 내륙   매출 순위      */
          ,DGD_RANK_TOT       /* Douyin 글로벌 매출 순위      */
          ,DCT_RANK_TOT_DIFF  /* Tmall  내륙   매출 순위 변화 */
          ,DGT_RANK_TOT_DIFF  /* Tmall  글로벌 매출 순위 변화 */
          ,DCD_RANK_TOT_DIFF  /* Douyin 내륙   매출 순위 변화 */
          ,DGD_RANK_TOT_DIFF  /* Douyin 글로벌 매출 순위 변화 */

          ,REVN_TAGT_AMT                                                                    /* 당해 Target 대비 누적 매출 비용 - 원화 */
          ,CAST(SALE_AMT_YEAR_KRW / REVN_TAGT_AMT * 100 AS DECIMAL(20,2)) AS REVN_TAGT_RATE /* 당해 Target 대비 누적 매출 비용 - 원화 */
      FROM WT_SALE      A
          ,WT_RANK      B
          ,WT_REVN_TAGT C