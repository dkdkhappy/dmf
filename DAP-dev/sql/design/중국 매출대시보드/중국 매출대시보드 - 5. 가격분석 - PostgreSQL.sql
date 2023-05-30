● 중국 매출대시보드 - 5. 가격분석

0. 화면 설명
    * 대시보드 중 가격분석 - 평균가격과 할인가격을 체크하는 페이지
    * Comment : 할인일수 CARD에 숫자 두개 최근 30일 + 연누적

1. 평균 판매가
    * 기준 : 최근 30일 평균, YTD(1년 누적기준)의 값이 두개가 나오도록
    * 평균 판매가의 그래프와 금액이 나오길 바람. 평균판매가는 (weighted average) = (제품 총 판매금액 / 제품 판매수량) * (제품 총 판매금액 / 채널 총 판매금액) 의 전체 합

2. 30%~50% 할인판매 제품 수
    * 할인 판매된 제품 수 30~50% 할인판매 기준 (최근 30일 기준 하나, YTD 하나)


3. 50%이상 할인판매 제품 수
    * 50%이상 할인 판매된 제품의 수(최근 30일 기준 하나, YTD 하나)


4. 할인율 1위 제품 명
    * 제일 할인율이 높았던 제품 명과, 제품 할인율 표기 (최근 30일 기준 하나, YTD 하나)

/* 1. 중요정보 카드 - 금액 SQL */
WITH WT_BASE AS
    (
        SELECT /* 1. 평균판매가 */
               MONTHLY_AV_PRICE_RMB       AS MNTH_AMT_RMB       /* 평균판매가               - 한달평균 - 위안화 */
              ,MONTHLY_AV_PRICE_KRW       AS MNTH_AMT_KRW       /* 평균판매가               - 한달평균 - 위안화 */
              ,YTD_AV_PRICE_RMB           AS YTD_AMT_RMB        /* 평균판매가               -  YTD평균 - 한화   */
              ,YTD_AV_PRICE_KRW           AS YTD_AMT_KRW        /* 평균판매가               -  YTD평균 - 한화   */
               /* 2. 30%~50% 할인판매 제품 수 */
              ,NO_DICS_ITEMS_30_RMB_MON   AS MNTH_D30_RMB       /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
              ,NO_DICS_ITEMS_30_KRW_MON   AS MNTH_D30_KRW       /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
              ,NO_DICS_ITEMS_30_RMB_YTD   AS YTD_D30_RMB        /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
              ,NO_DICS_ITEMS_30_KRW_YTD   AS YTD_D30_KRW        /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
               /* 3. 50%이상 할인판매 제품 수 */
              ,NO_DICS_ITEMS_50_RMB_MON   AS MNTH_D50_RMB       /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
              ,NO_DICS_ITEMS_50_KRW_MON   AS MNTH_D50_KRW       /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
              ,NO_DICS_ITEMS_50_RMB_YTD   AS YTD_D50_RMB        /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
              ,NO_DICS_ITEMS_50_KRW_YTD   AS YTD_D50_KRW        /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
               /* 4. 할인율 1위 제품 명 */
              ,TOP_SALE_ITEM_NAME_MON_RMB AS MNTH_TOP_NAME_RMB  /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
              ,TOP_SALE_ITEM_RATE_MON_RMB AS MNTH_TOP_RATE_RMB  /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
              ,TOP_SALE_ITEM_NAME_MON_KRW AS MNTH_TOP_NAME_KRW  /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
              ,TOP_SALE_ITEM_RATE_MON_KRW AS MNTH_TOP_RATE_KRW  /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
              ,TOP_SALE_ITEM_NAME_YTD_RMB AS YTD_TOP_NAME_RMB   /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
              ,TOP_SALE_ITEM_RATE_YTD_RMB AS YTD_TOP_RATE_RMB   /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
              ,TOP_SALE_ITEM_NAME_YTD_KRW AS YTD_TOP_NAME_KRW   /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
              ,TOP_SALE_ITEM_RATE_YTD_KRW AS YTD_TOP_RATE_KRW   /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
          FROM DASH.DGT_PRICEANALYSISCARD
    )
    SELECT CAST(MNTH_AMT_RMB AS DECIMAL(20,2))       AS MNTH_AMT_RMB       /* 평균판매가               - 한달평균 - 위안화 */
          ,CAST(MNTH_AMT_KRW AS DECIMAL(20,2))       AS MNTH_AMT_KRW       /* 평균판매가               - 한달평균 - 위안화 */
          ,CAST(YTD_AMT_RMB  AS DECIMAL(20,2))       AS YTD_AMT_RMB        /* 평균판매가               -  YTD평균 - 한화   */
          ,CAST(YTD_AMT_KRW  AS DECIMAL(20,2))       AS YTD_AMT_KRW        /* 평균판매가               -  YTD평균 - 한화   */
          ,MNTH_D30_RMB                              AS MNTH_D30_RMB       /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
          ,MNTH_D30_KRW                              AS MNTH_D30_KRW       /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
          ,YTD_D30_RMB                               AS YTD_D30_RMB        /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
          ,YTD_D30_KRW                               AS YTD_D30_KRW        /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
          ,MNTH_D50_RMB                              AS MNTH_D50_RMB       /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
          ,MNTH_D50_KRW                              AS MNTH_D50_KRW       /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
          ,YTD_D50_RMB                               AS YTD_D50_RMB        /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
          ,YTD_D50_KRW                               AS YTD_D50_KRW        /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
          ,MNTH_TOP_NAME_RMB                         AS MNTH_TOP_NAME_RMB  /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
          ,CAST(MNTH_TOP_RATE_RMB AS DECIMAL(20,2))  AS MNTH_TOP_RATE_RMB  /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
          ,MNTH_TOP_NAME_KRW                         AS MNTH_TOP_NAME_KRW  /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
          ,CAST(MNTH_TOP_RATE_KRW AS DECIMAL(20,2))  AS MNTH_TOP_RATE_KRW  /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
          ,YTD_TOP_NAME_RMB                          AS YTD_TOP_NAME_RMB   /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
          ,CAST(YTD_TOP_RATE_RMB AS DECIMAL(20,2))   AS YTD_TOP_RATE_RMB   /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
          ,YTD_TOP_NAME_KRW                          AS YTD_TOP_NAME_KRW   /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
          ,CAST(YTD_TOP_RATE_KRW AS DECIMAL(20,2))   AS YTD_TOP_RATE_KRW   /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
      FROM WT_BASE


/* 1. 중요정보 카드 - Chart SQL */
WITH WT_WHERE AS
    (
        SELECT STATISTICS_DATE - INTERVAL '1 MONTH' AS FR_DT
              ,STATISTICS_DATE                      AS TO_DT
              ,DATE_TRUNC('YEAR', STATISTICS_DATE)  AS FR_DT_YEAR
          FROM DASH.DGT_PRICEANALYSISCARD
    ), WT_BASE AS
    (
        SELECT 'MNTH'            AS CHRT_KEY
              ,STATISTICS_DATE   AS X_DT
              ,AV_SALE_PRICE_RMB AS Y_VAL_RMB
              ,AV_SALE_PRICE_KRW AS Y_VAL_KRW
          FROM DASH.DGT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL
        SELECT 'YTD'             AS CHRT_KEY
              ,STATISTICS_DATE   AS X_DT
              ,AV_SALE_PRICE_RMB AS Y_VAL_RMB
              ,AV_SALE_PRICE_KRW AS Y_VAL_KRW
          FROM DASH.DGT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YEAR FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    )
    SELECT CHRT_KEY   /* MNTH:한달 평균, YTD:YTD 평균 */
          ,CAST(X_DT AS DATE)      AS X_DT
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_KRW
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT


5. 가중평균 판매가 (제목을 이렇게 하면 될까요?)
    * 시계열그래프, y축은 전체의 가중평균 판매가(1에 나온것과 동일) 판매한 제품에 대한 전체 평균 정가, 정가대비 30%, 정가대비 50% 수평선으로 표기, 
      아래에는 시계열 선택할 수 있는 tiem selector 필요

/* 5. 가중평균 판매가 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_BASE AS
    (
        SELECT STATISTICS_DATE                AS X_DT
              ,AV_SALE_PRICE_RMB              AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
              ,AV_SALE_PRICE_KRW              AS AMT_KRW  /* 가중평균 판매가  - 원화   */
              ,AV_SALE_TAG_PRICE_RMB          AS TAG_RMB  /* 가중평균 정가    - 위안화 */
              ,AV_SALE_TAG_PRICE_KRW          AS TAG_KRW  /* 가중평균 정가    - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가 대비 50프로 - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가 대비 30프로 - 원화   */
          FROM DASH.DGT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE) 
    )
    SELECT CAST(X_DT AS DATE)                          AS X_DT     /* 일자                      */
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,2)), 0) AS AMT_RMB  /* 가중평균 판매가  - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,2)), 0) AS AMT_KRW  /* 가중평균 판매가  - 원화   */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,2)), 0) AS TAG_RMB  /* 가중평균 정가    - 위안화 */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,2)), 0) AS TAG_KRW  /* 가중평균 정가    - 원화   */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,2)), 0) AS D50_RMB  /* 정가 대비 50프로 - 위안화 */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,2)), 0) AS D50_KRW  /* 정가 대비 50프로 - 원화   */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,2)), 0) AS D30_RMB  /* 정가 대비 30프로 - 위안화 */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,2)), 0) AS D30_KRW  /* 정가 대비 30프로 - 원화   */
      FROM WT_BASE
  ORDER BY X_DT


6. 할인율 발생 일수 (제목을 이렇게 하면 될까요?)
    * 할인율 30% ~ 50%에 포함된 일자 표기, 할인율 50% 이상 발생한 일자 표기 (발생한 일수 계산하여 넣기)

/* 6. 할인율 발생 일수 - 파이, 하단 리스트 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_BASE AS
    (
        SELECT SUM(DISC_COUNT_30_50_RMB) AS D30_CNT_RMB
              ,SUM(DISC_COUNT_30_50_KRW) AS D30_CNT_KRW
              ,SUM(DISC_COUNT_50_RMB   ) AS D50_CNT_RMB
              ,SUM(DISC_COUNT_50_KRW   ) AS D50_CNT_KRW
          FROM DASH.DGT_PRICETIMESERIESCHART
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE) 
    )
    SELECT D30_CNT_RMB  /* 30~50%   할인율 발생일수 - 위안화 */
          ,D30_CNT_KRW  /* 30~50%   할인율 발생일수 - 원화   */
          ,D50_CNT_RMB  /* 50% 이상 할인율 발생일수 - 위안화 */
          ,D50_CNT_KRW  /* 50% 이상 할인율 발생일수 - 원화   */
      FROM WT_BASE


7. 일자별 제품 평균 판매가
    * 시계열그래프, y축은 선택한 제품에 대한 일자별 판매가, 해당 제품의 정가, 정가대비 30%, 정가대비 50%는 수평선으로 나타내기,
      time selecor필요하고, 제품 단일 선택 창 필요

/* 7. 일자별 제품 평균 판매가 - 제품 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_BASE AS
    (
        SELECT DISTINCT
               ITEM_CODE AS PROD_ID
              ,ITEM_NAME AS PROD_NM
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ITEM_NAME IS NOT NULL
    )
    SELECT PROD_ID
          ,PROD_NM
      FROM WT_BASE
  ORDER BY PROD_NM COLLATE "ko_KR.utf8"


/* 7. 일자별 제품 평균 판매가 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT     /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'    */
              ,CAST(:TO_DT AS DATE) AS TO_DT     /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'    */
              ,TRIM(:PROD_ID)       AS PROD_ID   /* 사용자가 선택한 제품ID         ex) '8809310539802' */
    ), WT_BASE AS
    (
        SELECT CAST(STATISTICS_DATE AS DATE)  AS X_DT     /* 일자                  */
              ,AV_SALE_ITEM_PRICE_RMB         AS AMT_RMB  /* 판매가       - 위안화 */
              ,AV_SALE_ITEM_PRICE_KRW         AS AMT_KRW  /* 판매가       - 원화   */
              ,SALE_TAG_ITEM_PRICE_RMB        AS TAG_RMB  /* 정가         - 위안화 */
              ,SALE_TAG_ITEM_PRICE_KRW        AS TAG_KRW  /* 정가         - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_30_RMB  AS D30_RMB  /* 정가대비 30% - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_30_KRW  AS D30_KRW  /* 정가대비 30% - 원화   */
              ,AV_SALE_TAG_PRICE_DISC_50_RMB  AS D50_RMB  /* 정가대비 50% - 위안화 */
              ,AV_SALE_TAG_PRICE_DISC_50_KRW  AS D50_KRW  /* 정가대비 50% - 원화   */
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ITEM_CODE = (SELECT PROD_ID FROM WT_WHERE)
    )
    SELECT X_DT                                                    /* 일자                  */
          ,COALESCE(CAST(AMT_RMB AS DECIMAL(20,2)), 0) AS AMT_RMB  /* 판매가       - 위안화 */
          ,COALESCE(CAST(AMT_KRW AS DECIMAL(20,2)), 0) AS AMT_KRW  /* 판매가       - 원화   */
          ,COALESCE(CAST(TAG_RMB AS DECIMAL(20,2)), 0) AS TAG_RMB  /* 정가         - 위안화 */
          ,COALESCE(CAST(TAG_KRW AS DECIMAL(20,2)), 0) AS TAG_KRW  /* 정가         - 원화   */
          ,COALESCE(CAST(D30_RMB AS DECIMAL(20,2)), 0) AS D30_RMB  /* 정가대비 30% - 위안화 */
          ,COALESCE(CAST(D30_KRW AS DECIMAL(20,2)), 0) AS D30_KRW  /* 정가대비 30% - 원화   */
          ,COALESCE(CAST(D50_RMB AS DECIMAL(20,2)), 0) AS D50_RMB  /* 정가대비 50% - 위안화 */
          ,COALESCE(CAST(D50_KRW AS DECIMAL(20,2)), 0) AS D50_KRW  /* 정가대비 50% - 원화   */
      FROM WT_BASE
  ORDER BY X_DT


8. 제품별 할인율 및 매출비중 순위
    * 7번에서 선택한 기간에 따른, 제품별 할인율 및 매출비중 순위 (순위의 기준은 할인율로 해야하며, 총 5개의 순위만 보여주면 됨)
      할일율 매출비중 오름차순 내림차순

/* 8. 제품별 할인율 및 매출비중 순위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE) AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,CAST(:TO_DT AS DATE) AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1 AS DISC_RANK
     UNION ALL
        SELECT 2 AS DISC_RANK
     UNION ALL
        SELECT 3 AS DISC_RANK
     UNION ALL
        SELECT 4 AS DISC_RANK
     UNION ALL
        SELECT 5 AS DISC_RANK
    ), WT_DISC_RMB AS
    (
        SELECT ITEM_NAME
              ,SUM((1-((ALL_SALE_ITEM_AMOUNT_RMB / ALL_SALES_ITEM_QTY) / SALE_TAG_ITEM_PRICE_RMB)) * ALL_SALE_ITEM_AMOUNT_RMB) / SUM(ALL_SALE_ITEM_AMOUNT_RMB) * 100 AS DISC_RATE
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND SALE_TAG_ITEM_PRICE_RMB > 0
           AND ITEM_NAME IS NOT NULL
      GROUP BY ITEM_NAME
        HAVING SUM(ALL_SALE_ITEM_AMOUNT_RMB) > 0
    ), WT_DISC_KRW AS
    (
        SELECT ITEM_NAME
              ,SUM((1-((ALL_SALE_ITEM_AMOUNT_KRW / ALL_SALES_ITEM_QTY) / SALE_TAG_ITEM_PRICE_KRW)) * ALL_SALE_ITEM_AMOUNT_KRW) / SUM(ALL_SALE_ITEM_AMOUNT_KRW) * 100 AS DISC_RATE
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND SALE_TAG_ITEM_PRICE_KRW > 0
           AND ITEM_NAME IS NOT NULL
      GROUP BY ITEM_NAME
        HAVING SUM(ALL_SALE_ITEM_AMOUNT_KRW) > 0
    ), WT_SALE_RMB AS
    (
        SELECT ITEM_NAME
              ,AVG(ALL_SALE_ITEM_AMOUNT_RMB / ALL_CHAN_SALES_AMOUNT_RMB * 100) AS AMT_RATE
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ALL_CHAN_SALES_AMOUNT_RMB > 0
           AND ITEM_NAME IS NOT NULL
      GROUP BY ITEM_NAME
    ), WT_SALE_KRW AS
    (
        SELECT ITEM_NAME
              ,AVG(ALL_SALE_ITEM_AMOUNT_KRW / ALL_CHAN_SALES_AMOUNT_KRW * 100) AS AMT_RATE
          FROM DASH.DGT_PRICEANLAYSISITEMTIMESERIES
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ALL_CHAN_SALES_AMOUNT_KRW > 0
           AND ITEM_NAME IS NOT NULL
      GROUP BY ITEM_NAME
    ), WT_DISC_RANK_RMB AS
    (
        SELECT ITEM_NAME
              ,DISC_RATE
              ,ROW_NUMBER() OVER(ORDER BY DISC_RATE DESC, ITEM_NAME) AS DISC_RANK
          FROM WT_DISC_RMB
    ), WT_DISC_RANK_KRW AS
    (
        SELECT ITEM_NAME
              ,DISC_RATE
              ,ROW_NUMBER() OVER(ORDER BY DISC_RATE DESC, ITEM_NAME) AS DISC_RANK
          FROM WT_DISC_KRW
    ), WT_JOIN_RMB AS
    (
        SELECT A.ITEM_NAME
              ,A.DISC_RANK
              ,A.DISC_RATE
              ,B.AMT_RATE
         FROM WT_DISC_RANK_RMB A LEFT OUTER JOIN WT_SALE_RMB B ON (A.ITEM_NAME = B.ITEM_NAME)
        WHERE A.DISC_RANK <= 5
    ), WT_JOIN_KRW AS
    (
        SELECT A.ITEM_NAME
              ,A.DISC_RANK
              ,A.DISC_RATE
              ,B.AMT_RATE
         FROM WT_DISC_RANK_KRW A LEFT OUTER JOIN WT_SALE_KRW B ON (A.ITEM_NAME = B.ITEM_NAME)
        WHERE A.DISC_RANK <= 5
    ), WT_BASE AS
    (
        SELECT A.DISC_RANK                   /* 순위              */
              ,B.ITEM_NAME AS ITEM_NAME_RMB  /* 제품명   - 위안화 */
              ,B.DISC_RATE AS DISC_RATE_RMB  /* 할인율   - 위안화 */
              ,B.AMT_RATE  AS AMT_RATE_RMB   /* 매출비중 - 위안화 */
              ,C.ITEM_NAME AS ITEM_NAME_KRW  /* 제품명   - 한화   */
              ,C.DISC_RATE AS DISC_RATE_KRW  /* 할인율   - 한화   */
              ,C.AMT_RATE  AS AMT_RATE_KRW   /* 매출비중 - 한화   */
         FROM WT_COPY A LEFT OUTER JOIN WT_JOIN_RMB B ON (A.DISC_RANK = B.DISC_RANK)
                        LEFT OUTER JOIN WT_JOIN_KRW C ON (A.DISC_RANK = C.DISC_RANK)
    )
    SELECT DISC_RANK                                                                                    /* 순위              */
          ,ITEM_NAME_RMB                                                              AS ITEM_NAME_RMB  /* 제품명   - 위안화 */
          ,TO_CHAR(CAST(DISC_RATE_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS DISC_RATE_RMB  /* 할인율   - 위안화 */
          ,TO_CHAR(CAST(AMT_RATE_RMB  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS AMT_RATE_RMB   /* 매출비중 - 위안화 */
          ,ITEM_NAME_KRW                                                              AS ITEM_NAME_KRW  /* 제품명   - 한화   */
          ,TO_CHAR(CAST(DISC_RATE_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS DISC_RATE_KRW  /* 할인율   - 한화   */
          ,TO_CHAR(CAST(AMT_RATE_KRW  AS DECIMAL(20,2)), 'FM999,999,999,999,990.00%') AS AMT_RATE_KRW   /* 매출비중 - 한화   */
      FROM WT_BASE
  ORDER BY DISC_RANK
