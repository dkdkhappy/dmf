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
          FROM DASH.{TAG}_PRICEANALYSISCARD
    )
    SELECT CAST(MNTH_AMT_RMB AS DECIMAL(20,2))       AS MNTH_AMT_RMB               /* 평균판매가               - 한달평균 - 위안화 */
          ,CAST(MNTH_AMT_KRW AS DECIMAL(20,2))       AS MNTH_AMT_KRW               /* 평균판매가               - 한달평균 - 위안화 */
          ,CAST(YTD_AMT_RMB  AS DECIMAL(20,2))       AS YTD_AMT_RMB                /* 평균판매가               -  YTD평균 - 한화   */
          ,CAST(YTD_AMT_KRW  AS DECIMAL(20,2))       AS YTD_AMT_KRW                /* 평균판매가               -  YTD평균 - 한화   */
          ,MNTH_D30_RMB                              AS MNTH_D30_RMB               /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
          ,MNTH_D30_KRW                              AS MNTH_D30_KRW               /* 30%~50% 할인판매 제품 수 - 한달평균 - 위안화 */
          ,YTD_D30_RMB                               AS YTD_D30_RMB                /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
          ,YTD_D30_KRW                               AS YTD_D30_KRW                /* 30%~50% 할인판매 제품 수 -  YTD평균 - 한화   */
          ,MNTH_D50_RMB                              AS MNTH_D50_RMB               /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
          ,MNTH_D50_KRW                              AS MNTH_D50_KRW               /* 50%이상 할인판매 제품 수 - 한달평균 - 위안화 */
          ,YTD_D50_RMB                               AS YTD_D50_RMB                /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
          ,YTD_D50_KRW                               AS YTD_D50_KRW                /* 50%이상 할인판매 제품 수 -  YTD평균 - 한화   */
          ,MNTH_TOP_NAME_RMB                         AS MNTH_TOP_NAME_RMB          /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
          ,CAST(MNTH_TOP_RATE_RMB * 100 AS DECIMAL(20,2))  AS MNTH_TOP_RATE_RMB    /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
          ,MNTH_TOP_NAME_KRW                         AS MNTH_TOP_NAME_KRW          /* 할인율 1위 제품 명       - 한달평균 - 제품명 - 위안환 */
          ,CAST(MNTH_TOP_RATE_KRW * 100 AS DECIMAL(20,2))  AS MNTH_TOP_RATE_KRW    /* 할인율 1위 제품 명       - 한달평균 - 할인율 - 한환   */
          ,YTD_TOP_NAME_RMB                          AS YTD_TOP_NAME_RMB           /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
          ,CAST(YTD_TOP_RATE_RMB * 100 AS DECIMAL(20,2))   AS YTD_TOP_RATE_RMB     /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
          ,YTD_TOP_NAME_KRW                          AS YTD_TOP_NAME_KRW           /* 할인율 1위 제품 명       -  YTD평균 - 제품명 - 위안환 */
          ,CAST(YTD_TOP_RATE_KRW * 100 AS DECIMAL(20,2))   AS YTD_TOP_RATE_KRW     /* 할인율 1위 제품 명       -  YTD평균 - 할인율 - 한환   */
       FROM WT_BASE