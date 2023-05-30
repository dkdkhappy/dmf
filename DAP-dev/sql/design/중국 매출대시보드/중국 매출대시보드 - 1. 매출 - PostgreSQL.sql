● 중국 매출대시보드 - 1. 매출

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


/* DASH 에서 사용하는 Function */

/* 환율 (KRW) 적용 Function */
CREATE OR REPLACE FUNCTION dash_raw.sf_exch_krw(p_date text)
 RETURNS double precision
 LANGUAGE plpgsql
AS $function$
    DECLARE V_KRW_RATE float8 ;
BEGIN
    -- KRW 환율
    SELECT MAX(EXRATE)
      INTO V_KRW_RATE
      FROM DASH_RAW.OVER_MACRO_EX_KRW_CNY
     WHERE DATE = REPLACE(P_DATE, '-', '') ;

    RETURN V_KRW_RATE ;

END;
$function$
;

/* 제품명 Function */
CREATE OR REPLACE FUNCTION dash_raw.sf_prod_nm(p_prod_id bigint)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
    DECLARE V_PROD_NM text ;
BEGIN
    -- 제품 ID 뒤에 공백이 생기는 경우가 있어 LIKE로 변경
    SELECT COALESCE(MAX(PRODUCT_NAME), '')
      INTO V_PROD_NM
      FROM DASH_RAW.OVER_DGT_ID_NAME_URL
     WHERE PRODUCT_ID = CAST(P_PROD_ID AS TEXT) ;

    RETURN V_PROD_NM ;

END;
$function$
;


/* Index 생성 */

/* over_dgt_overall_store */
CREATE INDEX over_dgt_overall_store_statistics_date_idx ON dash_raw.over_dgt_overall_store (statistics_date);

/* over_dgt_overall_product */
CREATE INDEX over_dgt_overall_product_statistics_date_idx ON dash_RAW.OVER_DGT_OVERALL_PRODUCT_URL (statistics_date);
CREATE INDEX over_dgt_overall_product_product_id_idx ON dash_RAW.OVER_DGT_OVERALL_PRODUCT_URL (product_id);





/*************************************************************************************************************************************/
/* 1. 중요정보 카드 - 금액 SQL */                                             impCardAmtData.sql
/* 1. 중요정보 카드 - Chart SQL */                                            impCardAmtChart.sql
/* 2. 매출정보에 대한 시계열 그래프 - 그래프상단 정보 SQL */                    salesTimeSeriesGraphData.sql
/* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */                salesTimeSeriesGraphChart.sql
/* 2. 매출정보에 대한 시계열 그래프 - 하단표 SQL                  */          salesTimeSeriesGraphBottom.sql
/* 3. 요일/시간 매출량 히트맵 - 히트맵 SQL */                                 salesHeatmapData.sql
/* 4. 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 SQL */                salesRefundTimeSeriesAllData.sql
/* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */                 salesRefundTimeSeriesAllGraph.sql
/* 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 SQL */        refundAmountYoY.sql
/* 5. 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 SQL */                  refundDataByMonth.sql

/* 6. 채널 내 매출 순위 300위 - 상점명 선택 SQL */                            storeName.sql
/* 6. 채널 내 매출 순위 300위 - 표 SQL */                                     channelSalesRank300Grid.sql
/* 7. 카테고리별 매출 순위 - 1차 카테고리 선택 SQL */                         categorySalesRank1.sql
/* 7. 카테고리별 매출 순위 - 2차 카테고리 선택 SQL */                         categorySalesRank2.sql
/* 7. 카테고리별 매출 순위 - 표 SQL */                                        categorySalesRankGrid.sql
/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 SQL */                     productSalesMast.sql
/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL */        productSalesTimeSeries.sql
/* 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 SQL */   salesComparisonLastYear.sql
/* 9. 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 SQL */          salesRankingLYMoM.sql
/* 9. 제품별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 SQL */                  topSalesLastMonth.sql

/* 10. 제품별 환불 정보 시계열 그래프 - 제품별 선택 SQL */                    productRefundMast.sql
/* 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL */       refundTimeSeriesByProduct.sql

/* 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 SQL      */  refundComparisonLastYear.sql
/* 11. 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 SQL */         refundRankingLYMoM.sql
/* 11. 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 SQL */                 topRefundLastMonth.sql

/*************************************************************************************************************************************/


/* 0. 매출 대시보드 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 어제임 오늘이 2023.03.04 일 경우 => 22023.03.03 */
SELECT TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY                       , 'YYYY-MM-DD') AS BASE_DT           /* 기준일자               */
      ,TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR  , 'YYYY-MM-DD') AS BASE_DT_YOY       /* 기준일자          -1년 */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                     , 'YYYY-MM-DD') AS FRST_DT_MNTH      /* 기준월의 1일           */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' YEAR)                     , 'YYYY-MM-DD') AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                     , 'YYYY-MM-DD') AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' YEAR)                     , 'YYYY-MM-DD') AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY'   )                           AS BASE_YEAR         /* 기준년                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY'   )                           AS BASE_YEAR_YOY     /* 기준년            -1년 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY-MM')                           AS BASE_MNTH         /* 기준월                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY-MM')                           AS BASE_MNTH_YOY     /* 기준월            -1년 */   


SELECT BASE_DT               /* 기준일자               */
      ,BASE_DT_YOY           /* 기준일자          -1년 */
      ,FRST_DT_MNTH          /* 기준월의 1일           */
      ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
      ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
      ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
      ,FR_DT                 /* 기간조회 - 시작일자    */
      ,TO_DT                 /* 기간조회 - 종료일자    */
      ,BASE_YEAR             /* 기준년                 */
      ,BASE_YEAR_YOY         /* 기준년            -1년 */
      ,BASE_MNTH             /* 기준월                 */
      ,BASE_MNTH_YOY         /* 기준월            -1년 */
FROM DASH.DASH_INITIAL_DATE


1. 중요정보 카드
    * 일별매출 : 직전일 매출금액  (환불차감전)
        => SALE_AMT_RMB  /* 일매출금액 - 위안화 */
           SALE_AMT_KRW  /* 일매출금액 - 원화   */
    * 월별매출(누적) : 해당월 직전일까지의 누적 매출 금액
      (예 : 2월 20일이면 2월 1일 부터 2월 19일까지 누적 합  ; 환불차감전)) 
        => SALE_AMT_MNTH_RMB  /* 월매출금액(누적) - 위안화 */
        => SALE_AMT_MNTH_KRW  /* 월매출금액(누적) - 원화   */
    * 연간매출(누적) : 1월 1일부터 직전일까지 누적 매출 금액  (환불차감전)
        => SALE_AMT_YEAR_RMB  /* 연매출금액(누적) - 위안화 */
           SALE_AMT_YEAR_KRW  /* 연매출금액(누적) - 원화   */
    * 일별환불금액 : 직전일 환불금액
        => REFD_AMT_RMB  /* 일환불금액 - 위안화 */
           REFD_AMT_KRW  /* 일환불금액 - 원화   */
    * 월별 환불금액(누적) 해당월 1일부터 직전일까지의 누적 환불
        => REFD_AMT_MNTH_RMB  /* 월환불액(누적) - 위안화 */
           REFD_AMT_MNTH_KRW  /* 월환불액(누적) - 원화   */
    * 연간환불금액(누적) 1월1일부터 직전일가지 누적 환불금액
        => REFD_AMT_YEAR_RMB  /* 연환불금액(누적) - 위안화 */
           REFD_AMT_YEAR_KRW  /* 연환불금액(누적) - 원화   */
    * 브랜드 매출 순위 : 당사 해당 채널 브랜드 매출 순위 (직전월까지 누적기준)
        => 테이블 정보 없음
    * 한국브랜드중 매출 순위 : 한국브랜드 중 매출 순위 (직전월까지 누적기준)
        => 테이블 정보 없음
    * 매출정보에 대한 2023년 목표치/누적치 게이지 그래프 : 1월1일부터 현재까지 누적금액과 올해 목표치에 대한 그래프
        => 테이블 정보 없음
    필요 기능 : 
    [1] YoY 비교 기능  :  월별매출, 연간매출, 월별환불금액, 연간환불금액은 작년 대비 비교하여 증감률(%)을 나타낸다. 증감률이 양수이면 초록색 음수이면 붉은색으로 표기
        => SALE_RATE_MNTH_YOY_RMB  /* 월매출금액(누적) 증감률 - 위안화 */
           REFD_RATE_MNTH_YOY_RMB  /* 월환불금액(누적) 증감률 - 위안화 */
           SALE_RATE_MNTH_YOY_KRW  /* 월매출금액(누적) 증감률 - 원화   */
           REFD_RATE_MNTH_YOY_KRW  /* 월환불금액(누적) 증감률 - 원화   */
           SALE_RATE_YEAR_YOY_RMB  /* 연매출금액(누적) 증감률 - 위안화 */
           REFD_RATE_YEAR_YOY_RMB  /* 연환불금액(누적) 증감률 - 위안화 */
           SALE_RATE_YEAR_YOY_KRW  /* 연매출금액(누적) 증감률 - 원화   */
           REFD_RATE_YEAR_YOY_KRW  /* 연환불금액(누적) 증감률 - 원화   */

    [2] 직전일 비교 기능 : 일별매출, 일별 환불금액은 직전일로 비교
        => SALE_RATE_DOD_RMB  /* 일매출금액 증감률     - 위안화 */
           REFD_RATE_DOD_RMB  /* 일환불금액 증감률     - 위안화 */
           SALE_RATE_DOD_KRW  /* 일매출금액 증감률     - 원화   */
           REFD_RATE_DOD_KRW  /* 일환불금액 증감률     - 원화   */
    [3] 환율기능 : 환율버튼 필요[RMB중국위안화/ KRW한국원화] 기준이며, 매출과 환불 카드에 적용되어야함 --> Top에서 모두 적용되게 부탁드립니다.


/* impCardAmtData.sql */
/* 1. 중요정보 카드 - 금액 SQL */
/*    ※ 매출금액 : 환불제외 매출금액 */
WITH WT_WHERE AS
    (
        SELECT BASE_DT                /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE) - INTERVAL '1' DAY, 'YYYY-MM-DD') AS BASE_DT_DOD  /* 기준일자 (어제)   -1일 */
              ,BASE_DT_YOY           /* 기준일자 (어제)   -1년 */
              ,FRST_DT_MNTH          /* 기준월의 1일           */
              ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
              ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
              ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SALE_DAY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_RMB            /* 일매출금액          - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_RMB            /* 일환불금액          - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_KRW            /* 일매출금액          - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_KRW            /* 일환불금액          - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_MNTH AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_MNTH_RMB       /* 월매출금액(누적)    - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_MNTH_RMB       /* 월매환불액(누적)    - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_MNTH_KRW       /* 월매출금액(누적)    - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_MNTH_KRW       /* 월매환불액(누적)    - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_YEAR AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_YEAR_RMB       /* 연매출금액(누적)   - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_YEAR_RMB       /* 연환불금액(누적)   - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_YEAR_KRW       /* 연매출금액(누적)   - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_YEAR_KRW       /* 연환불금액(누적)   - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
    ), WT_SALE_DAY_DOD AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  SALE_AMT_DOD_RMB       /* 일매출금액      DoD - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  REFD_AMT_DOD_RMB       /* 일환불금액      DoD - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  SALE_AMT_DOD_KRW       /* 일매출금액      DoD - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  REFD_AMT_DOD_KRW       /* 일환불금액      DoD - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE = (SELECT BASE_DT_DOD FROM WT_WHERE)
    ), WT_SALE_MNTH_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_MNTH_YOY_RMB  /* 월매출금액(누적) YoY - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_MNTH_YOY_RMB  /* 월매환불액(누적) YoY - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_MNTH_YOY_KRW  /* 월매출금액(누적) YoY - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_MNTH_YOY_KRW  /* 월매환불액(누적) YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_SALE_YEAR_YOY AS
    (
        SELECT SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                          )  AS SALE_AMT_YEAR_YOY_RMB  /* 연매출금액(누적) YoY - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                         )  AS REFD_AMT_YEAR_YOY_RMB  /* 연환불금액(누적) YoY - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS SALE_AMT_YEAR_YOY_KRW  /* 연매출금액(누적) YoY - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE))  AS REFD_AMT_YEAR_YOY_KRW  /* 연환불금액(누적) YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR_YOY FROM WT_WHERE) AND (SELECT BASE_DT_YOY FROM WT_WHERE)
    ), WT_RANK AS
    (
        SELECT MAX(DGT_RANK_TOT)                         AS BRND_RANK
              ,MAX(DGT_RANK_TOT_MOM) - MAX(DGT_RANK_TOT) AS BRND_RANK_MOM
              ,MAX(DGT_RANK_KR )                         AS BRND_RANK_KR
              ,MAX(DGT_RANK_KR_MOM ) - MAX(DGT_RANK_KR ) AS BRND_RANK_KR_MOM
          FROM DASH.DGT_RANKCARDDATA        
    ), WT_REVN_TAGT AS
    (
        SELECT SUM("revenueTarget") * 1000000 AS REVN_TAGT_AMT  /* 한화로 백만원 단위 */
          FROM DASH.cm_target
         WHERE CHANNEL = 'Tmall Global'
    ), WT_BASE AS
    (
        SELECT A.SALE_AMT_RMB                                                                               AS SALE_AMT_RMB           /* 일매출금액            - 위안화 */
              ,A.REFD_AMT_RMB                                                                               AS REFD_AMT_RMB           /* 일환불금액            - 위안화 */
              ,A.SALE_AMT_KRW                                                                               AS SALE_AMT_KRW           /* 일매출금액            - 원화   */
              ,A.REFD_AMT_KRW                                                                               AS REFD_AMT_KRW           /* 일환불금액            - 원화   */
              ,(A.SALE_AMT_RMB - COALESCE(D.SALE_AMT_DOD_RMB, 0)) / D.SALE_AMT_DOD_RMB * 100                AS SALE_RATE_DOD_RMB      /* 일매출금액 증감률     - 위안화 */
              ,(A.REFD_AMT_RMB - COALESCE(D.REFD_AMT_DOD_RMB, 0)) / D.REFD_AMT_DOD_RMB * 100                AS REFD_RATE_DOD_RMB      /* 일환불금액 증감률     - 위안화 */
              ,(A.SALE_AMT_KRW - COALESCE(D.SALE_AMT_DOD_KRW, 0)) / D.SALE_AMT_DOD_KRW * 100                AS SALE_RATE_DOD_KRW      /* 일매출금액 증감률     - 원화   */
              ,(A.REFD_AMT_KRW - COALESCE(D.REFD_AMT_DOD_KRW, 0)) / D.REFD_AMT_DOD_KRW * 100                AS REFD_RATE_DOD_KRW      /* 일환불금액 증감률     - 원화   */

              ,B.SALE_AMT_MNTH_RMB                                                                          AS SALE_AMT_MNTH_RMB      /* 월매출금액(누적)        - 위안화 */
              ,B.REFD_AMT_MNTH_RMB                                                                          AS REFD_AMT_MNTH_RMB      /* 월매환불액(누적)        - 위안화 */
              ,B.SALE_AMT_MNTH_KRW                                                                          AS SALE_AMT_MNTH_KRW      /* 월매출금액(누적)        - 원화   */
              ,B.REFD_AMT_MNTH_KRW                                                                          AS REFD_AMT_MNTH_KRW      /* 월매환불액(누적)        - 원화   */
              ,(B.SALE_AMT_MNTH_RMB - COALESCE(E.SALE_AMT_MNTH_YOY_RMB, 0)) / E.SALE_AMT_MNTH_YOY_RMB * 100 AS SALE_RATE_MNTH_YOY_RMB /* 월매출금액(누적) 증감률 - 위안화 */
              ,(B.REFD_AMT_MNTH_RMB - COALESCE(E.REFD_AMT_MNTH_YOY_RMB, 0)) / E.REFD_AMT_MNTH_YOY_RMB * 100 AS REFD_RATE_MNTH_YOY_RMB /* 월환불금액(누적) 증감률 - 위안화 */
              ,(B.SALE_AMT_MNTH_KRW - COALESCE(E.SALE_AMT_MNTH_YOY_KRW, 0)) / E.SALE_AMT_MNTH_YOY_KRW * 100 AS SALE_RATE_MNTH_YOY_KRW /* 월매출금액(누적) 증감률 - 원화   */
              ,(B.REFD_AMT_MNTH_KRW - COALESCE(E.REFD_AMT_MNTH_YOY_KRW, 0)) / E.REFD_AMT_MNTH_YOY_KRW * 100 AS REFD_RATE_MNTH_YOY_KRW /* 월환불금액(누적) 증감률 - 원화   */

              ,C.SALE_AMT_YEAR_RMB                                                                          AS SALE_AMT_YEAR_RMB      /* 연매출금액(누적)        - 위안화 */
              ,C.REFD_AMT_YEAR_RMB                                                                          AS REFD_AMT_YEAR_RMB      /* 연환불금액(누적)        - 위안화 */
              ,C.SALE_AMT_YEAR_KRW                                                                          AS SALE_AMT_YEAR_KRW      /* 연매출금액(누적)        - 원화   */
              ,C.REFD_AMT_YEAR_KRW                                                                          AS REFD_AMT_YEAR_KRW      /* 연환불금액(누적)        - 원화   */
              ,(C.SALE_AMT_YEAR_RMB - COALESCE(F.SALE_AMT_YEAR_YOY_RMB, 0)) / F.SALE_AMT_YEAR_YOY_RMB * 100 AS SALE_RATE_YEAR_YOY_RMB /* 연매출금액(누적) 증감률 - 위안화 */
              ,(C.REFD_AMT_YEAR_RMB - COALESCE(F.REFD_AMT_YEAR_YOY_RMB, 0)) / F.REFD_AMT_YEAR_YOY_RMB * 100 AS REFD_RATE_YEAR_YOY_RMB /* 연환불금액(누적) 증감률 - 위안화 */
              ,(C.SALE_AMT_YEAR_KRW - COALESCE(F.SALE_AMT_YEAR_YOY_KRW, 0)) / F.SALE_AMT_YEAR_YOY_KRW * 100 AS SALE_RATE_YEAR_YOY_KRW /* 연매출금액(누적) 증감률 - 원화   */
              ,(C.REFD_AMT_YEAR_KRW - COALESCE(F.REFD_AMT_YEAR_YOY_KRW, 0)) / F.REFD_AMT_YEAR_YOY_KRW * 100 AS REFD_RATE_YEAR_YOY_KRW /* 연환불금액(누적) 증감률 - 원화   */

              ,D.SALE_AMT_DOD_RMB                                                                           AS SALE_AMT_DOD_RMB       /* 일매출금액       DoD - 위안화 */
              ,D.REFD_AMT_DOD_RMB                                                                           AS REFD_AMT_DOD_RMB       /* 일환불금액       DoD - 위안화 */
              ,D.SALE_AMT_DOD_KRW                                                                           AS SALE_AMT_DOD_KRW       /* 일매출금액       DoD - 원화   */
              ,D.REFD_AMT_DOD_KRW                                                                           AS REFD_AMT_DOD_KRW       /* 일환불금액       DoD - 원화   */

              ,E.SALE_AMT_MNTH_YOY_RMB                                                                      AS SALE_AMT_MNTH_YOY_RMB  /* 월매출금액(누적) YoY - 위안화 */
              ,E.REFD_AMT_MNTH_YOY_RMB                                                                      AS REFD_AMT_MNTH_YOY_RMB  /* 월매환불액(누적) YoY - 위안화 */
              ,E.SALE_AMT_MNTH_YOY_KRW                                                                      AS SALE_AMT_MNTH_YOY_KRW  /* 월매출금액(누적) YoY - 원화   */
              ,E.REFD_AMT_MNTH_YOY_KRW                                                                      AS REFD_AMT_MNTH_YOY_KRW  /* 월매환불액(누적) YoY - 원화   */

              ,F.SALE_AMT_YEAR_YOY_RMB                                                                      AS SALE_AMT_YEAR_YOY_RMB  /* 연매출금액(누적) YoY - 위안화 */
              ,F.REFD_AMT_YEAR_YOY_RMB                                                                      AS REFD_AMT_YEAR_YOY_RMB  /* 연환불금액(누적) YoY - 위안화 */
              ,F.SALE_AMT_YEAR_YOY_KRW                                                                      AS SALE_AMT_YEAR_YOY_KRW  /* 연매출금액(누적) YoY - 원화   */
              ,F.REFD_AMT_YEAR_YOY_KRW                                                                      AS REFD_AMT_YEAR_YOY_KRW  /* 연환불금액(누적) YoY - 원화   */

              ,G.BRND_RANK
              ,G.BRND_RANK_MOM
              ,G.BRND_RANK_KR
              ,G.BRND_RANK_KR_MOM

              ,H.REVN_TAGT_AMT
              ,C.SALE_AMT_YEAR_KRW / H.REVN_TAGT_AMT * 100 AS REVN_TAGT_RATE
          FROM WT_SALE_DAY      A
              ,WT_SALE_MNTH     B
              ,WT_SALE_YEAR     C
              ,WT_SALE_DAY_DOD  D
              ,WT_SALE_MNTH_YOY E
              ,WT_SALE_YEAR_YOY F
              ,WT_RANK          G
              ,WT_REVN_TAGT     H
    )
    SELECT COALESCE(CAST(SALE_AMT_RMB            AS DECIMAL(20,2)), 0) AS SALE_AMT_RMB            /* 일매출금액            - 위안화 */
          ,COALESCE(CAST(REFD_AMT_RMB            AS DECIMAL(20,2)), 0) AS REFD_AMT_RMB            /* 일환불금액            - 위안화 */
          ,COALESCE(CAST(SALE_AMT_KRW            AS DECIMAL(20,2)), 0) AS SALE_AMT_KRW            /* 일매출금액            - 원화   */
          ,COALESCE(CAST(REFD_AMT_KRW            AS DECIMAL(20,2)), 0) AS REFD_AMT_KRW            /* 일환불금액            - 원화   */
          ,COALESCE(CAST(SALE_RATE_DOD_RMB       AS DECIMAL(20,2)), 0) AS SALE_RATE_DOD_RMB       /* 일매출금액 증감률     - 위안화 */
          ,COALESCE(CAST(REFD_RATE_DOD_RMB       AS DECIMAL(20,2)), 0) AS REFD_RATE_DOD_RMB       /* 일환불금액 증감률     - 위안화 */
          ,COALESCE(CAST(SALE_RATE_DOD_KRW       AS DECIMAL(20,2)), 0) AS SALE_RATE_DOD_KRW       /* 일매출금액 증감률     - 원화   */
          ,COALESCE(CAST(REFD_RATE_DOD_KRW       AS DECIMAL(20,2)), 0) AS REFD_RATE_DOD_KRW       /* 일환불금액 증감률     - 원화   */

          ,COALESCE(CAST(SALE_AMT_MNTH_RMB      AS DECIMAL(20,2)), 0) AS SALE_AMT_MNTH_RMB       /* 월매출금액(누적)        - 위안화 */
          ,COALESCE(CAST(REFD_AMT_MNTH_RMB      AS DECIMAL(20,2)), 0) AS REFD_AMT_MNTH_RMB       /* 월매환불액(누적)        - 위안화 */
          ,COALESCE(CAST(SALE_AMT_MNTH_KRW      AS DECIMAL(20,2)), 0) AS SALE_AMT_MNTH_KRW       /* 월매출금액(누적)        - 원화   */
          ,COALESCE(CAST(REFD_AMT_MNTH_KRW      AS DECIMAL(20,2)), 0) AS REFD_AMT_MNTH_KRW       /* 월매환불액(누적)        - 원화   */
          ,COALESCE(CAST(SALE_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)), 0) AS SALE_RATE_MNTH_YOY_RMB  /* 월매출금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(REFD_RATE_MNTH_YOY_RMB AS DECIMAL(20,2)), 0) AS REFD_RATE_MNTH_YOY_RMB  /* 월환불금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)), 0) AS SALE_RATE_MNTH_YOY_KRW  /* 월매출금액(누적) 증감률 - 원화   */
          ,COALESCE(CAST(REFD_RATE_MNTH_YOY_KRW AS DECIMAL(20,2)), 0) AS REFD_RATE_MNTH_YOY_KRW  /* 월환불금액(누적) 증감률 - 원화   */

          ,COALESCE(CAST(SALE_AMT_YEAR_RMB      AS DECIMAL(20,2)), 0) AS SALE_AMT_YEAR_RMB       /* 연매출금액(누적)        - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YEAR_RMB      AS DECIMAL(20,2)), 0) AS REFD_AMT_YEAR_RMB       /* 연환불금액(누적)        - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YEAR_KRW      AS DECIMAL(20,2)), 0) AS SALE_AMT_YEAR_KRW       /* 연매출금액(누적)        - 원화   */
          ,COALESCE(CAST(REFD_AMT_YEAR_KRW      AS DECIMAL(20,2)), 0) AS REFD_AMT_YEAR_KRW       /* 연환불금액(누적)        - 원화   */
          ,COALESCE(CAST(SALE_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)), 0) AS SALE_RATE_YEAR_YOY_RMB  /* 연매출금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(REFD_RATE_YEAR_YOY_RMB AS DECIMAL(20,2)), 0) AS REFD_RATE_YEAR_YOY_RMB  /* 연환불금액(누적) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)), 0) AS SALE_RATE_YEAR_YOY_KRW  /* 연매출금액(누적) 증감률 - 원화   */
          ,COALESCE(CAST(REFD_RATE_YEAR_YOY_KRW AS DECIMAL(20,2)), 0) AS REFD_RATE_YEAR_YOY_KRW  /* 연환불금액(누적) 증감률 - 원화   */

          ,COALESCE(CAST(SALE_AMT_DOD_RMB       AS DECIMAL(20,2)), 0) AS SALE_AMT_DOD_RMB        /* 일매출금액       DoD - 위안화 */
          ,COALESCE(CAST(REFD_AMT_DOD_RMB       AS DECIMAL(20,2)), 0) AS REFD_AMT_DOD_RMB        /* 일환불금액       DoD - 위안화 */
          ,COALESCE(CAST(SALE_AMT_DOD_KRW       AS DECIMAL(20,2)), 0) AS SALE_AMT_DOD_KRW        /* 일매출금액       DoD - 원화   */
          ,COALESCE(CAST(REFD_AMT_DOD_KRW       AS DECIMAL(20,2)), 0) AS REFD_AMT_DOD_KRW        /* 일환불금액       DoD - 원화   */

          ,COALESCE(CAST(SALE_AMT_MNTH_YOY_RMB  AS DECIMAL(20,2)), 0) AS SALE_AMT_MNTH_YOY_RMB    /* 월매출금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(REFD_AMT_MNTH_YOY_RMB  AS DECIMAL(20,2)), 0) AS REFD_AMT_MNTH_YOY_RMB    /* 월매환불액(누적) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_MNTH_YOY_KRW  AS DECIMAL(20,2)), 0) AS SALE_AMT_MNTH_YOY_KRW    /* 월매출금액(누적) YoY - 원화   */
          ,COALESCE(CAST(REFD_AMT_MNTH_YOY_KRW  AS DECIMAL(20,2)), 0) AS REFD_AMT_MNTH_YOY_KRW    /* 월매환불액(누적) YoY - 원화   */

          ,COALESCE(CAST(SALE_AMT_YEAR_YOY_RMB  AS DECIMAL(20,2)), 0) AS SALE_AMT_YEAR_YOY_RMB    /* 연매출금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YEAR_YOY_RMB  AS DECIMAL(20,2)), 0) AS REFD_AMT_YEAR_YOY_RMB    /* 연환불금액(누적) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YEAR_YOY_KRW  AS DECIMAL(20,2)), 0) AS SALE_AMT_YEAR_YOY_KRW    /* 연매출금액(누적) YoY - 원화   */
          ,COALESCE(CAST(REFD_AMT_YEAR_YOY_KRW  AS DECIMAL(20,2)), 0) AS REFD_AMT_YEAR_YOY_KRW    /* 연환불금액(누적) YoY - 원화   */

          ,COALESCE(CAST(BRND_RANK              AS TEXT         ), '') AS BRND_RANK               /* 브랜드 매출 순위     - 순위      */
          ,COALESCE(CAST(BRND_RANK_MOM          AS TEXT         ), '') AS BRND_RANK_MOM           /* 브랜드 매출 순위     - 순위 변화 */
          ,COALESCE(CAST(BRND_RANK_KR           AS TEXT         ), '') AS BRND_RANK_KR            /* 한국브랜드 매출 순위 - 순위      */
          ,COALESCE(CAST(BRND_RANK_KR_MOM       AS TEXT         ), '') AS BRND_RANK_KR_MOM        /* 한국브랜드 매출 순위 - 순위 변화 */

          ,COALESCE(CAST(REVN_TAGT_AMT          AS DECIMAL(20,2)), 0) AS REVN_TAGT_AMT            /* 당해 Target 대비 누적 매출 금액 - 원화   */
          ,COALESCE(CAST(REVN_TAGT_RATE         AS DECIMAL(20,2)), 0) AS REVN_TAGT_RATE           /* 당해 Target 대비 누적 매출 비중 - 원화   */
      FROM WT_BASE


/* impCardAmtChart.sql */
/* 1. 중요정보 카드 - Chart SQL */
/*    ※ 매출금액 : 환불제외 매출금액 */
WITH WT_WHERE AS
    (
        SELECT BASE_DT                /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE) - INTERVAL '1' DAY, 'YYYY-MM-DD') AS BASE_DT_DOD  /* 기준일자 (어제)   -1일 */
              ,BASE_DT_YOY           /* 기준일자 (어제)   -1년 */
              ,FRST_DT_MNTH          /* 기준월의 1일           */
              ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
              ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
              ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SALE_DAY AS
    (
        SELECT 'DAY'                                                                                                     AS CHRT_KEY
              ,STATISTICS_DATE                                                                                           AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_RMB       /* 일매출금액          - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_RMB       /* 일환불금액          - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_KRW       /* 일매출금액          - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_KRW       /* 일환불금액          - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT BASE_DT_DOD FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_SALE_MNTH AS
    (             
        SELECT 'MNTH'                                                                                                    AS CHRT_KEY
              ,STATISTICS_DATE                                                                                           AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_MNTH_RMB  /* 월매출금액(누적)    - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_MNTH_RMB  /* 월매환불액(누적)    - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_MNTH_KRW  /* 월매출금액(누적)    - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_MNTH_KRW  /* 월매환불액(누적)    - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_SALE_YEAR AS
    (
        SELECT 'YEAR'                                                                                                    AS CHRT_KEY
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')                                                         AS X_DT
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           )  AS SALE_AMT_YEAR_RMB  /* 연매출금액(누적)   - 위안화 */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                                                          )  AS REFD_AMT_YEAR_RMB  /* 연환불금액(누적)   - 위안화 */
              ,SUM((PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS SALE_AMT_YEAR_KRW  /* 연매출금액(누적)   - 원화   */
              ,SUM( SUCCESSFUL_REFUND_AMOUNT                                * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) )  AS REFD_AMT_YEAR_KRW  /* 연환불금액(누적)   - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')
    ), WT_BASE AS
    (
        SELECT A.CHRT_KEY                        /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,A.X_DT                            /* 일자(x축)                      */
              ,A.SALE_AMT_RMB AS Y_VAL_SALE_RMB  /* 일매출금액            - 위안화 */
              ,A.REFD_AMT_RMB AS Y_VAL_REFD_RMB  /* 일환불금액            - 위안화 */
              ,A.SALE_AMT_KRW AS Y_VAL_SALE_KRW  /* 일매출금액            - 원화   */
              ,A.REFD_AMT_KRW AS Y_VAL_REFD_KRW  /* 일환불금액            - 원화   */
          FROM WT_SALE_DAY A
     UNION ALL
        SELECT B.CHRT_KEY                               /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,B.X_DT                                   /* 일자(x축)                    */
              ,B.SALE_AMT_MNTH_RMB  AS Y_VAL_SALE_RMB   /* 월매출금액(누적)    - 위안화 */
              ,B.REFD_AMT_MNTH_RMB  AS Y_VAL_REFD_RMB   /* 월매환불액(누적)    - 위안화 */
              ,B.SALE_AMT_MNTH_KRW  AS Y_VAL_SALE_KRW   /* 월매출금액(누적)    - 원화   */
              ,B.REFD_AMT_MNTH_KRW  AS Y_VAL_REFD_KRW   /* 월매환불액(누적)    - 원화   */
          FROM WT_SALE_MNTH B
     UNION ALL
        SELECT C.CHRT_KEY                               /* DAY:일매출/일환불, MNTH:월매출/월환불, YEAR:연매출/연환불 */
              ,C.X_DT                                   /* 일자(x축)                    */
              ,C.SALE_AMT_YEAR_RMB  AS Y_VAL_SALE_RMB   /* 연매출금액(누적)    - 위안화 */
              ,C.REFD_AMT_YEAR_RMB  AS Y_VAL_REFD_RMB   /* 연매환불액(누적)    - 위안화 */
              ,C.SALE_AMT_YEAR_KRW  AS Y_VAL_SALE_KRW   /* 연매출금액(누적)    - 원화   */
              ,C.REFD_AMT_YEAR_KRW  AS Y_VAL_REFD_KRW   /* 연매환불액(누적)    - 원화   */
          FROM WT_SALE_YEAR C
    )
    SELECT CHRT_KEY
          ,X_DT
          ,COALESCE(CAST(Y_VAL_SALE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_SALE_RMB  /* 매출금액 - 위안화 */
          ,COALESCE(CAST(Y_VAL_REFD_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_REFD_RMB  /* 환불금액 - 위안화 */
          ,COALESCE(CAST(Y_VAL_SALE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_SALE_KRW  /* 매출금액 - 원화   */
          ,COALESCE(CAST(Y_VAL_REFD_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_REFD_KRW  /* 환불금액 - 원화   */
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT



2. 매출정보에 대한 시계열 그래프
    * 매출 시계열그래프 : 사용자가 선택한 기간에 따른 일별 매출 시계열 그래프(예 : 1월1일부터 2월 1일까지) 
        => /* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
    * Rolling 주단위 매출 : 해당일 까지 rolling으로 주단위 매출 최소 계산 단위(5일) 
        => /* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
    * Rolling 월단위 매출 : 해당일까지 rollin으로 월단위 매출값 산출 (30일)
        => /* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
    필요 기능 : 
    [2] 그래프상단 정보 기능 : 당해누적금액, 전년도 누적금액, 증감률, 분석기간
        => /* 2. 매출정보에 대한 시계열 그래프 - 그래프상단 정보 SQL */
    [3] 지표선택 : 결제금액, 환불제외금액(결제 - 환불금액) 복수선택 가능 형태
        => /* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
    [7] 하단 표 : 매출정보 데이터가 나와야함 (1월부터, 12월까지; 정보는 올해, 전년도 선택한 매출, YOY, MOM)
        => /* 2. 매출정보에 대한 시계열 그래프 - 하단표 SQL */

    /* ※ 참고 : 시계열 그래프의 지표중에 환불제외 금액이 있어, 추후 다른 정보(그래프상단, 하단표)에도 추가 될 수 있어 SQL에 포함함. */
    /*          현재 정의된 화면에서는 시계열 그래프 외에는 EXRE(환불제외) 관련 컬럼 정보는 사용하지 않는다.                      */

/* salesTimeSeriesGraphData.sql */
/* 2. 매출정보에 대한 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH_YOY AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           YoY - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) YoY - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           YoY - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_RMB  /* 일매출           - 위안화 */
              ,SUM(EXRE_AMT_RMB) AS EXRE_AMT_RMB  /* 일매출(환불제외) - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW  /* 일매출           - 원화   */
              ,SUM(EXRE_AMT_KRW) AS EXRE_AMT_KRW  /* 일매출(환불제외) - 원화   */
          FROM WT_EXCH A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_YOY_RMB  /* 일매출           YoY - 위안화 */
              ,SUM(EXRE_AMT_RMB) AS EXRE_AMT_YOY_RMB  /* 일매출(환불제외) YoY - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_YOY_KRW  /* 일매출           YoY - 원화   */
              ,SUM(EXRE_AMT_KRW) AS EXRE_AMT_YOY_KRW  /* 일매출(환불제외) YoY - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
        SELECT SALE_AMT_RMB     AS SALE_AMT_RMB      /* 당해 누적금액               - 위안화 */
              ,EXRE_AMT_RMB     AS EXRE_AMT_RMB      /* 당해 누적금액(환불제외)     - 위안화 */
              ,SALE_AMT_KRW     AS SALE_AMT_KRW      /* 당해 누적금액               - 원화   */
              ,EXRE_AMT_KRW     AS EXRE_AMT_KRW      /* 당해 누적금액(환불제외)     - 원화   */
              
              ,SALE_AMT_YOY_RMB AS SALE_AMT_YOY_RMB  /* 전년도 누적금액           YoY - 위안화 */
              ,EXRE_AMT_YOY_RMB AS EXRE_AMT_YOY_RMB  /* 전년도 누적금액(환불제외) YoY - 위안화 */
              ,SALE_AMT_YOY_KRW AS SALE_AMT_YOY_KRW  /* 전년도 누적금액           YoY - 원화   */
              ,EXRE_AMT_YOY_KRW AS EXRE_AMT_YOY_KRW  /* 전년도 누적금액(환불제외) YoY - 원화   */

              ,(A.SALE_AMT_RMB - COALESCE(B.SALE_AMT_YOY_RMB, 0)) / B.SALE_AMT_YOY_RMB * 100 AS SALE_RATE_RMB  /* 매출           증감률 - 위안화 */
              ,(A.EXRE_AMT_RMB - COALESCE(B.EXRE_AMT_YOY_RMB, 0)) / B.EXRE_AMT_YOY_RMB * 100 AS EXRE_RATE_RMB  /* 매출(환불제외) 증감률 - 위안화 */
              ,(A.SALE_AMT_KRW - COALESCE(B.SALE_AMT_YOY_KRW, 0)) / B.SALE_AMT_YOY_KRW * 100 AS SALE_RATE_KRW  /* 매출           증감률 - 원화   */
              ,(A.EXRE_AMT_KRW - COALESCE(B.EXRE_AMT_YOY_KRW, 0)) / B.EXRE_AMT_YOY_KRW * 100 AS EXRE_RATE_KRW  /* 매출(환불제외) 증감률 - 원화   */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(SALE_AMT_RMB     AS DECIMAL(20,2)), 0) AS SALE_AMT_RMB      /* 당해 누적금액               - 위안화 */
          ,COALESCE(CAST(EXRE_AMT_RMB     AS DECIMAL(20,2)), 0) AS EXRE_AMT_RMB      /* 당해 누적금액(환불제외)     - 위안화 */
          ,COALESCE(CAST(SALE_AMT_KRW     AS DECIMAL(20,2)), 0) AS SALE_AMT_KRW      /* 당해 누적금액               - 원화   */
          ,COALESCE(CAST(EXRE_AMT_KRW     AS DECIMAL(20,2)), 0) AS EXRE_AMT_KRW      /* 당해 누적금액(환불제외)     - 원화   */

          ,COALESCE(CAST(SALE_AMT_YOY_RMB AS DECIMAL(20,2)), 0) AS SALE_AMT_YOY_RMB  /* 전년도 누적금액           YoY - 위안화 */
          ,COALESCE(CAST(EXRE_AMT_YOY_RMB AS DECIMAL(20,2)), 0) AS EXRE_AMT_YOY_RMB  /* 전년도 누적금액(환불제외) YoY - 위안화 */
          ,COALESCE(CAST(SALE_AMT_YOY_KRW AS DECIMAL(20,2)), 0) AS SALE_AMT_YOY_KRW  /* 전년도 누적금액           YoY - 원화   */
          ,COALESCE(CAST(EXRE_AMT_YOY_KRW AS DECIMAL(20,2)), 0) AS EXRE_AMT_YOY_KRW  /* 전년도 누적금액(환불제외) YoY - 원화   */

          ,COALESCE(CAST(SALE_RATE_RMB    AS DECIMAL(20,2)), 0) AS SALE_RATE_RMB     /* 매출           증감률 - 위안화 */
          ,COALESCE(CAST(EXRE_RATE_RMB    AS DECIMAL(20,2)), 0) AS EXRE_RATE_RMB     /* 매출(환불제외) 증감률 - 위안화 */
          ,COALESCE(CAST(SALE_RATE_KRW    AS DECIMAL(20,2)), 0) AS SALE_RATE_KRW     /* 매출           증감률 - 원화   */
          ,COALESCE(CAST(EXRE_RATE_KRW    AS DECIMAL(20,2)), 0) AS EXRE_RATE_KRW     /* 매출(환불제외) 증감률 - 원화   */
      FROM WT_BASE

/* salesTimeSeriesGraphChart.sql */
/* 2. 매출정보에 대한 시계열 그래프 - 매출 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
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
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(SALE_AMT_RMB)                                                                           AS SALE_AMT_RMB       /* 일매출                          - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출           이동평균( 5일) - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출           이동평균(30일) - 위안화 */
              ,    SUM(EXRE_AMT_RMB)                                                                           AS EXRE_AMT_RMB       /* 일매출(환불제외)                - 위안화 */
              ,AVG(SUM(EXRE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS EXRE_AMT_WEEK_RMB  /* 주매출(환불제외) 이동평균( 5일) - 위안화 */
              ,AVG(SUM(EXRE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS EXRE_AMT_MNTH_RMB  /* 월매출(환불제외) 이동평균(30일) - 위안화 */

              ,    SUM(SALE_AMT_KRW)                                                                           AS SALE_AMT_KRW       /* 일매출                          - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 일매출           이동평균( 5일) - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 일매출           이동평균(30일) - 원화   */
              ,    SUM(EXRE_AMT_KRW)                                                                           AS EXRE_AMT_KRW       /* 일매출(환불제외)                - 원화   */
              ,AVG(SUM(EXRE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS EXRE_AMT_WEEK_KRW  /* 일매출(환불제외) 이동평균( 5일) - 원화   */
              ,AVG(SUM(EXRE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS EXRE_AMT_MNTH_KRW  /* 일매출(환불제외) 이동평균(30일) - 원화   */
          FROM WT_EXCH A
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
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
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT

/* salesTimeSeriesGraphBottom.sql */
/* 2. 매출정보에 대한 시계열 그래프 - 하단표 SQL                  */
/*    오늘(2023.03.04)일 경우 => 기준일 : 2023.03.03              */
/*                               올해   : 2023.01.01 ~ 2023.12.31 */
/*                               전년도 : 2022.01.01 ~ 2022.12.31 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR             AS FR_DT      /* 기준일의  1월  1일       */
              ,BASE_YEAR    ||'-12-31'  AS TO_DT      /* 기준일의 12월 31일       */
              ,FRST_DT_YEAR_YOY         AS FR_DT_YOY  /* 기준년의  1월  1일  -1년 */
              ,BASE_YEAR_YOY||'-12-31'  AS TO_DT_YOY  /* 기준일의 12월 31일  -1년 */
              ,BASE_YEAR                AS THIS_YEAR  /* 기준일의 연도            */
              ,BASE_YEAR_YOY            AS LAST_YEAR  /* 기준일의 연도       -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1                                              AS SORT_KEY
              ,'올해 '   ||  (SELECT THIS_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 2                                              AS SORT_KEY
              ,'전년도 ' ||  (SELECT LAST_YEAR FROM WT_WHERE) AS ROW_TITL
     UNION ALL
        SELECT 3                                              AS SORT_KEY
              ,'YoY'                                          AS ROW_TITL
     UNION ALL
        SELECT 4                                              AS SORT_KEY
              ,'MoM'                                          AS ROW_TITL
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH_YOY AS
    (
        SELECT STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           YoY - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) YoY - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           YoY - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT 1  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_RMB END) AS SALE_AMT_01_RMB /* 01월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_RMB END) AS SALE_AMT_02_RMB /* 02월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_RMB END) AS SALE_AMT_03_RMB /* 03월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_RMB END) AS SALE_AMT_04_RMB /* 04월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_RMB END) AS SALE_AMT_05_RMB /* 05월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_RMB END) AS SALE_AMT_06_RMB /* 06월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_RMB END) AS SALE_AMT_07_RMB /* 07월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_RMB END) AS SALE_AMT_08_RMB /* 08월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_RMB END) AS SALE_AMT_09_RMB /* 09월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_RMB END) AS SALE_AMT_10_RMB /* 10월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_RMB END) AS SALE_AMT_11_RMB /* 11월 일매출           - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_RMB END) AS SALE_AMT_12_RMB /* 12월 일매출           - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN EXRE_AMT_RMB END) AS EXRE_AMT_01_RMB /* 01월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN EXRE_AMT_RMB END) AS EXRE_AMT_02_RMB /* 02월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN EXRE_AMT_RMB END) AS EXRE_AMT_03_RMB /* 03월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN EXRE_AMT_RMB END) AS EXRE_AMT_04_RMB /* 04월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN EXRE_AMT_RMB END) AS EXRE_AMT_05_RMB /* 05월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN EXRE_AMT_RMB END) AS EXRE_AMT_06_RMB /* 06월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN EXRE_AMT_RMB END) AS EXRE_AMT_07_RMB /* 07월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN EXRE_AMT_RMB END) AS EXRE_AMT_08_RMB /* 08월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN EXRE_AMT_RMB END) AS EXRE_AMT_09_RMB /* 09월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN EXRE_AMT_RMB END) AS EXRE_AMT_10_RMB /* 10월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN EXRE_AMT_RMB END) AS EXRE_AMT_11_RMB /* 11월 일매출(환불제외) - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN EXRE_AMT_RMB END) AS EXRE_AMT_12_RMB /* 12월 일매출(환불제외) - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_KRW END) AS SALE_AMT_01_KRW /* 01월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_KRW END) AS SALE_AMT_02_KRW /* 02월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_KRW END) AS SALE_AMT_03_KRW /* 03월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_KRW END) AS SALE_AMT_04_KRW /* 04월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_KRW END) AS SALE_AMT_05_KRW /* 05월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_KRW END) AS SALE_AMT_06_KRW /* 06월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_KRW END) AS SALE_AMT_07_KRW /* 07월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_KRW END) AS SALE_AMT_08_KRW /* 08월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_KRW END) AS SALE_AMT_09_KRW /* 09월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_KRW END) AS SALE_AMT_10_KRW /* 10월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_KRW END) AS SALE_AMT_11_KRW /* 11월 일매출           - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_KRW END) AS SALE_AMT_12_KRW /* 12월 일매출           - 원화   */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN EXRE_AMT_KRW END) AS EXRE_AMT_01_KRW /* 01월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN EXRE_AMT_KRW END) AS EXRE_AMT_02_KRW /* 02월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN EXRE_AMT_KRW END) AS EXRE_AMT_03_KRW /* 03월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN EXRE_AMT_KRW END) AS EXRE_AMT_04_KRW /* 04월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN EXRE_AMT_KRW END) AS EXRE_AMT_05_KRW /* 05월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN EXRE_AMT_KRW END) AS EXRE_AMT_06_KRW /* 06월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN EXRE_AMT_KRW END) AS EXRE_AMT_07_KRW /* 07월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN EXRE_AMT_KRW END) AS EXRE_AMT_08_KRW /* 08월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN EXRE_AMT_KRW END) AS EXRE_AMT_09_KRW /* 09월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN EXRE_AMT_KRW END) AS EXRE_AMT_10_KRW /* 10월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN EXRE_AMT_KRW END) AS EXRE_AMT_11_KRW /* 11월 일매출(환불제외) - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN EXRE_AMT_KRW END) AS EXRE_AMT_12_KRW /* 12월 일매출(환불제외) - 원화   */
          FROM WT_EXCH A
     UNION ALL
        SELECT 2  AS SORT_KEY
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_RMB END) AS SALE_AMT_01_RMB /* 01월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_RMB END) AS SALE_AMT_02_RMB /* 02월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_RMB END) AS SALE_AMT_03_RMB /* 03월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_RMB END) AS SALE_AMT_04_RMB /* 04월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_RMB END) AS SALE_AMT_05_RMB /* 05월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_RMB END) AS SALE_AMT_06_RMB /* 06월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_RMB END) AS SALE_AMT_07_RMB /* 07월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_RMB END) AS SALE_AMT_08_RMB /* 08월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_RMB END) AS SALE_AMT_09_RMB /* 09월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_RMB END) AS SALE_AMT_10_RMB /* 10월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_RMB END) AS SALE_AMT_11_RMB /* 11월 일매출           YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_RMB END) AS SALE_AMT_12_RMB /* 12월 일매출           YoY - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN EXRE_AMT_RMB END) AS EXRE_AMT_01_RMB /* 01월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN EXRE_AMT_RMB END) AS EXRE_AMT_02_RMB /* 02월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN EXRE_AMT_RMB END) AS EXRE_AMT_03_RMB /* 03월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN EXRE_AMT_RMB END) AS EXRE_AMT_04_RMB /* 04월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN EXRE_AMT_RMB END) AS EXRE_AMT_05_RMB /* 05월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN EXRE_AMT_RMB END) AS EXRE_AMT_06_RMB /* 06월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN EXRE_AMT_RMB END) AS EXRE_AMT_07_RMB /* 07월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN EXRE_AMT_RMB END) AS EXRE_AMT_08_RMB /* 08월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN EXRE_AMT_RMB END) AS EXRE_AMT_09_RMB /* 09월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN EXRE_AMT_RMB END) AS EXRE_AMT_10_RMB /* 10월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN EXRE_AMT_RMB END) AS EXRE_AMT_11_RMB /* 11월 일매출(환불제외) YoY - 위안화 */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN EXRE_AMT_RMB END) AS EXRE_AMT_12_RMB /* 12월 일매출(환불제외) YoY - 위안화 */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN SALE_AMT_KRW END) AS SALE_AMT_01_KRW /* 01월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN SALE_AMT_KRW END) AS SALE_AMT_02_KRW /* 02월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN SALE_AMT_KRW END) AS SALE_AMT_03_KRW /* 03월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN SALE_AMT_KRW END) AS SALE_AMT_04_KRW /* 04월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN SALE_AMT_KRW END) AS SALE_AMT_05_KRW /* 05월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN SALE_AMT_KRW END) AS SALE_AMT_06_KRW /* 06월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN SALE_AMT_KRW END) AS SALE_AMT_07_KRW /* 07월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN SALE_AMT_KRW END) AS SALE_AMT_08_KRW /* 08월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN SALE_AMT_KRW END) AS SALE_AMT_09_KRW /* 09월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN SALE_AMT_KRW END) AS SALE_AMT_10_KRW /* 10월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN SALE_AMT_KRW END) AS SALE_AMT_11_KRW /* 11월 일매출           YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN SALE_AMT_KRW END) AS SALE_AMT_12_KRW /* 12월 일매출           YoY - 원화   */

              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 01 THEN EXRE_AMT_KRW END) AS EXRE_AMT_01_KRW /* 01월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 02 THEN EXRE_AMT_KRW END) AS EXRE_AMT_02_KRW /* 02월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 03 THEN EXRE_AMT_KRW END) AS EXRE_AMT_03_KRW /* 03월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 04 THEN EXRE_AMT_KRW END) AS EXRE_AMT_04_KRW /* 04월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 05 THEN EXRE_AMT_KRW END) AS EXRE_AMT_05_KRW /* 05월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 06 THEN EXRE_AMT_KRW END) AS EXRE_AMT_06_KRW /* 06월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 07 THEN EXRE_AMT_KRW END) AS EXRE_AMT_07_KRW /* 07월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 08 THEN EXRE_AMT_KRW END) AS EXRE_AMT_08_KRW /* 08월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 09 THEN EXRE_AMT_KRW END) AS EXRE_AMT_09_KRW /* 09월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 10 THEN EXRE_AMT_KRW END) AS EXRE_AMT_10_KRW /* 10월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 11 THEN EXRE_AMT_KRW END) AS EXRE_AMT_11_KRW /* 11월 일매출(환불제외) YoY - 원화   */
              ,SUM(CASE WHEN EXTRACT(MONTH FROM CAST(STATISTICS_DATE AS DATE)) = 12 THEN EXRE_AMT_KRW END) AS EXRE_AMT_12_KRW /* 12월 일매출(환불제외) YoY - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
         SELECT A.SORT_KEY
               ,A.ROW_TITL
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_01_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_01_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_01_RMB  /* 01월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_02_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_02_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_02_RMB  /* 02월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_03_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_03_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_03_RMB  /* 03월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_04_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_04_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_04_RMB  /* 04월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_05_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_05_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_05_RMB  /* 05월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_06_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_06_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_06_RMB  /* 06월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_07_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_07_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_07_RMB  /* 07월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_08_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_08_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_08_RMB  /* 08월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_09_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_09_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_09_RMB  /* 09월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_10_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_10_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_10_RMB  /* 10월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_11_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_11_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_11_RMB  /* 11월 일매출 - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_12_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_12_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_12_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_12_RMB  /* 12월 일매출 - 위안화 */

               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_01_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_01_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_01_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_01_RMB  /* 01월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_02_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_02_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_02_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_01_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_02_RMB  /* 02월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_03_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_03_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_03_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_02_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_03_RMB  /* 03월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_04_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_04_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_04_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_03_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_04_RMB  /* 04월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_05_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_05_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_05_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_04_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_05_RMB  /* 05월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_06_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_06_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_06_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_05_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_06_RMB  /* 06월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_07_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_07_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_07_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_06_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_07_RMB  /* 07월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_08_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_08_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_08_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_07_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_08_RMB  /* 08월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_09_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_09_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_09_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_08_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_09_RMB  /* 09월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_10_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_10_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_10_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_09_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_10_RMB  /* 10월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_11_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_11_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_11_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_10_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_11_RMB  /* 11월 일매출(환불제외) - 위안화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_12_RMB
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_12_RMB, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_12_RMB, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_12_RMB, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_11_RMB, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_12_RMB  /* 12월 일매출(환불제외) - 위안화 */

               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_01_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_01_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_01_KRW  /* 01월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_02_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_02_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_02_KRW  /* 02월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_03_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_03_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_03_KRW  /* 03월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_04_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_04_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_04_KRW  /* 04월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_05_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_05_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_05_KRW  /* 05월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_06_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_06_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_06_KRW  /* 06월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_07_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_07_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_07_KRW  /* 07월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_08_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_08_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_08_KRW  /* 08월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_09_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_09_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_09_KRW  /* 09월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_10_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_10_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_10_KRW  /* 10월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_11_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_11_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_11_KRW  /* 11월 일매출 - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN SALE_AMT_12_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(SALE_AMT_12_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(SALE_AMT_12_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(SALE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS SALE_AMT_12_KRW  /* 12월 일매출 - 원화 */

               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_01_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_01_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_01_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_01_KRW  /* 01월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_02_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_02_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_02_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_01_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_02_KRW  /* 02월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_03_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_03_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_03_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_02_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_03_KRW  /* 03월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_04_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_04_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_04_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_03_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_04_KRW  /* 04월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_05_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_05_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_05_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_04_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_05_KRW  /* 05월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_06_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_06_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_06_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_05_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_06_KRW  /* 06월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_07_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_07_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_07_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_06_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_07_KRW  /* 07월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_08_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_08_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_08_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_07_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_08_KRW  /* 08월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_09_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_09_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_09_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_08_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_09_KRW  /* 09월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_10_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_10_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_10_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_09_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_10_KRW  /* 10월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_11_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_11_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_11_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_10_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_11_KRW  /* 11월 일매출(환불제외) - 원화 */
               ,CASE
                  WHEN A.SORT_KEY IN (1, 2)
                  THEN EXRE_AMT_12_KRW
                  WHEN A.SORT_KEY = 3
                  THEN (LAG(EXRE_AMT_12_KRW, 2) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_12_KRW, 1) OVER(ORDER BY A.SORT_KEY) * 100
                  WHEN A.SORT_KEY = 4
                  THEN (LAG(EXRE_AMT_12_KRW, 3) OVER(ORDER BY A.SORT_KEY) - COALESCE(LAG(EXRE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY))) / LAG(EXRE_AMT_11_KRW, 3) OVER(ORDER BY A.SORT_KEY) * 100
               END AS EXRE_AMT_12_KRW  /* 12월 일매출(환불제외) - 원화 */
          FROM WT_COPY A LEFT OUTER JOIN 
               WT_SUM  B 
            ON (A.SORT_KEY = B.SORT_KEY)
    )
    SELECT ROW_TITL
          ,TO_CHAR(CAST(SALE_AMT_01_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_01_RMB   /* 01월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_02_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_02_RMB   /* 02월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_03_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_03_RMB   /* 03월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_04_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_04_RMB   /* 04월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_05_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_05_RMB   /* 05월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_06_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_06_RMB   /* 06월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_07_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_07_RMB   /* 07월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_08_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_08_RMB   /* 08월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_09_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_09_RMB   /* 09월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_10_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_10_RMB   /* 10월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_11_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_11_RMB   /* 11월 일매출 - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_12_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_12_RMB   /* 12월 일매출 - 위안화 */

          ,TO_CHAR(CAST(EXRE_AMT_01_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_01_RMB  /* 01월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_02_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_02_RMB  /* 02월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_03_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_03_RMB  /* 03월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_04_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_04_RMB  /* 04월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_05_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_05_RMB  /* 05월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_06_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_06_RMB  /* 06월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_07_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_07_RMB  /* 07월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_08_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_08_RMB  /* 08월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_09_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_09_RMB  /* 09월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_10_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_10_RMB  /* 10월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_11_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_11_RMB  /* 11월 일매출(환불제외) - 위안화 */
          ,TO_CHAR(CAST(EXRE_AMT_12_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_12_RMB  /* 12월 일매출(환불제외) - 위안화 */

          ,TO_CHAR(CAST(SALE_AMT_01_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_01_KRW  /* 01월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_02_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_02_KRW  /* 02월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_03_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_03_KRW  /* 03월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_04_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_04_KRW  /* 04월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_05_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_05_KRW  /* 05월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_06_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_06_KRW  /* 06월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_07_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_07_KRW  /* 07월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_08_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_08_KRW  /* 08월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_09_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_09_KRW  /* 09월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_10_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_10_KRW  /* 10월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_11_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_11_KRW  /* 11월 일매출 - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_12_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS SALE_AMT_12_KRW  /* 12월 일매출 - 원화 */

          ,TO_CHAR(CAST(EXRE_AMT_01_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_01_KRW  /* 01월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_02_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_02_KRW  /* 02월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_03_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_03_KRW  /* 03월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_04_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_04_KRW  /* 04월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_05_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_05_KRW  /* 05월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_06_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_06_KRW  /* 06월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_07_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_07_KRW  /* 07월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_08_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_08_KRW  /* 08월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_09_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_09_KRW  /* 09월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_10_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_10_KRW  /* 10월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_11_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_11_KRW  /* 11월 일매출(환불제외) - 원화 */
          ,TO_CHAR(CAST(EXRE_AMT_12_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,999.99')||CASE WHEN ROW_TITL IN('YoY', 'MoM') THEN '%' ELSE '' END AS EXRE_AMT_12_KRW  /* 12월 일매출(환불제외) - 원화 */
      FROM WT_BASE
  ORDER BY SORT_KEY


3. 요일/시간 매출량 히트맵(선택된 기간에 따라 확인)
    * 요일 별 시간 별 히트맵 
    * 히트맵의 계산기간 : 매출시계열에서 선택한 기간으로 
    * X축 시간(0시부터 23시) , y축 요일 (월화수목금토일)
    * 화면구성상 x y축 바꾸는것 가능

    필요 기능 : 
    [1] 마우스오버 :  (월요일 20시 xxx ) 등의 수치들이 나와야함
    [2] 2번의 시간 선택시(타임슬라이드) 히트맵이 변경되길 바람
    [3] 물음표 모달 : 정보 차후 제공


/* salesHeatmapData.sql */
/* 3. 요일/시간 매출량 히트맵 - 히트맵 SQL */
/*    조회결과 가공방법 위완화 ==> [[WEEK_NO, HOUR_NO, SALE_AMT_RMB], [WEEK_NO, HOUR_NO, SALE_AMT_RMB], ...] */
/*                        원화 ==> [[WEEK_NO, HOUR_NO, SALE_AMT_RMB], [WEEK_NO, HOUR_NO, SALE_AMT_KRW], ...] */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_CAST AS
    (
        SELECT STATISTICS_DATE
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'Dy') AS WEEK_ID
              ,CAST(STATISTICS_HOURS                        AS DECIMAL(20,0)) AS HOUR_NO
              ,CAST(REPLACE(PAYMENT_AMOUNT, ',', '')        AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_SHOP_BY_HOUR A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH AS
    (
        SELECT CASE
                 WHEN WEEK_ID = 'Mon' THEN 0
                 WHEN WEEK_ID = 'Tue' THEN 1
                 WHEN WEEK_ID = 'Wed' THEN 2
                 WHEN WEEK_ID = 'Thu' THEN 3
                 WHEN WEEK_ID = 'Fri' THEN 4
                 WHEN WEEK_ID = 'Sat' THEN 5
                 WHEN WEEK_ID = 'Sun' THEN 6
               END WEEK_NO
              ,HOUR_NO
              ,SALE_AMT_RMB                                            AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SALE_AMT_RMB  * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
          FROM WT_CAST A
    )
   SELECT WEEK_NO
         ,HOUR_NO
         ,CAST(SUM(SALE_AMT_RMB) AS DECIMAL(20,2)) AS SALE_AMT_RMB  /* 일매출 - 위안화 */
         ,CAST(SUM(SALE_AMT_KRW) AS DECIMAL(20,2)) AS SALE_AMT_KRW  /* 일매출 - 원화   */
     FROM WT_EXCH A
 GROUP BY WEEK_NO
         ,HOUR_NO
 ORDER BY WEEK_NO
         ,HOUR_NO



4. 전체 매출 환불 시계열 그래프
    * 환불 시계열 그래프 : 사용자가 선택한 기간과 제품에 따른 환불 일별 시계열 그래프(예 : 1월1일부터 2월 1일까지) 
        => /* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */
    * Rolling 주단위 매출 : 해당일 까지 rolling으로 주단위 매출 최소 계산 단위(5일) 
        => /* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */
    * Rolling 월단위 매출 : 해당일까지 rollin으로 월단위 매출값 산출 (30일)
        => /* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */

    필요 기능 : 
    [1] 기간선택 : 분석기간 선택(캘린더 형태) 
    [2] 그래프상단 정보 기능 : 당해환불 전년도 환불, 환불금액 증감률, 당해환불비중, 전년도 환불비중, 환불비중 증감률(%p) , 분석기간 
        => /* 4. 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 SQL */
    [3] 지표선택 : 환불금액, 매출대비 환불비중(%) : 기간중STORE환불/기간중STORE매출 복수선택 가능 형태
        => /* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */
    [4] 주단위/월단위 선택기능 : 기본으로는 주, 월 rolling 지표 다 주되, 지표를 누르면 사라지거나 생성되도록

/* salesRefundTimeSeriesAllData.sql */
/* 4. 전체 매출 환불 시계열 그래프 - 그래프상단 정보 기능 SQL */
/*    당해   환불금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 환불금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_EXCH_YOY AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 YoY - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 YoY - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 YoY - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_RMB  /* 일매출 - 위안화 */
              ,SUM(REFD_AMT_RMB) AS REFD_AMT_RMB  /* 일환불 - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW  /* 일매출 - 원화   */
              ,SUM(REFD_AMT_KRW) AS REFD_AMT_KRW  /* 일환불 - 원화   */
          FROM WT_EXCH A
    ), WT_SUM_YOY AS
    (
        SELECT SUM(SALE_AMT_RMB) AS SALE_AMT_YOY_RMB  /* 일매출 YoY - 위안화 */
              ,SUM(REFD_AMT_RMB) AS REFD_AMT_YOY_RMB  /* 일환불 YoY - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_YOY_KRW  /* 일매출 YoY - 원화   */
              ,SUM(REFD_AMT_KRW) AS REFD_AMT_YOY_KRW  /* 일환불 YoY - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE AS
    (
      SELECT REFD_AMT_RMB                                                                                           AS REFD_AMT_RMB      /* 당해 환불금액   - 위안화 */
            ,REFD_AMT_YOY_RMB                                                                                       AS REFD_AMT_YOY_RMB  /* 전해 환불금액   - 위안화 */
            ,(A.REFD_AMT_RMB - COALESCE(B.REFD_AMT_YOY_RMB, 0)) / B.REFD_AMT_YOY_RMB * 100                          AS REFD_RATE_RMB     /* 환불금액 증감률 - 위안화 */

            , REFD_AMT_RMB     / SALE_AMT_RMB     * 100                                                             AS PCNT_AMT_RMB      /* 당해 환불 비중  - 위안화 */
            , REFD_AMT_YOY_RMB / SALE_AMT_YOY_RMB * 100                                                             AS PCNT_AMT_YOY_RMB  /* 전해 환불 비중  - 위안화 */
            ,(REFD_AMT_RMB     / SALE_AMT_RMB     * 100) - COALESCE((REFD_AMT_YOY_RMB / SALE_AMT_YOY_RMB * 100), 0) AS PCNT_RATE_RMB     /* 환불금액 증감률 - 위안화 */
            
            ,REFD_AMT_KRW                                                                                           AS REFD_AMT_KRW      /* 당해 환불금액   - 원화   */
            ,REFD_AMT_YOY_KRW                                                                                       AS REFD_AMT_YOY_KRW  /* 전해 환불금액   - 원화   */
            ,(A.REFD_AMT_KRW - COALESCE(B.REFD_AMT_YOY_KRW, 0)) / B.REFD_AMT_YOY_KRW * 100                          AS REFD_RATE_KRW     /* 환불금액 증감률 - 원화   */

            , REFD_AMT_KRW     / SALE_AMT_KRW     * 100                                                             AS PCNT_AMT_KRW      /* 당해 환불 비중  - 원화   */
            , REFD_AMT_YOY_KRW / SALE_AMT_YOY_KRW * 100                                                             AS PCNT_AMT_YOY_KRW  /* 전해 환불 비중  - 원화   */
            ,(REFD_AMT_KRW     / SALE_AMT_KRW     * 100) - COALESCE((REFD_AMT_YOY_KRW / SALE_AMT_YOY_KRW * 100), 0) AS PCNT_RATE_KRW     /* 환불비중 증감률 - 원화   */
         FROM WT_SUM     A
            ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(REFD_AMT_RMB     AS DECIMAL(20,2)), 0) AS REFD_AMT_RMB     /* 당해 환불금액   - 위안화 */
          ,COALESCE(CAST(REFD_AMT_YOY_RMB AS DECIMAL(20,2)), 0) AS REFD_AMT_YOY_RMB /* 전해 환불금액   - 위안화 */
          ,COALESCE(CAST(REFD_RATE_RMB    AS DECIMAL(20,2)), 0) AS REFD_RATE_RMB    /* 환불금액 증감률 - 위안화 */

          ,COALESCE(CAST(PCNT_AMT_RMB     AS DECIMAL(20,2)), 0) AS PCNT_AMT_RMB     /* 당해 환불 비중  - 위안화 */
          ,COALESCE(CAST(PCNT_AMT_YOY_RMB AS DECIMAL(20,2)), 0) AS PCNT_AMT_YOY_RMB /* 전해 환불 비중  - 위안화 */
          ,COALESCE(CAST(PCNT_RATE_RMB    AS DECIMAL(20,2)), 0) AS PCNT_RATE_RMB    /* 환불금액 증감률 - 위안화 */

          ,COALESCE(CAST(REFD_AMT_KRW     AS DECIMAL(20,2)), 0) AS REFD_AMT_KRW     /* 당해 환불금액   - 원화   */
          ,COALESCE(CAST(REFD_AMT_YOY_KRW AS DECIMAL(20,2)), 0) AS REFD_AMT_YOY_KRW /* 전해 환불금액   - 원화   */
          ,COALESCE(CAST(REFD_RATE_KRW    AS DECIMAL(20,2)), 0) AS REFD_RATE_KRW    /* 환불금액 증감률 - 원화   */
          
          ,COALESCE(CAST(PCNT_AMT_KRW     AS DECIMAL(20,2)), 0) AS PCNT_AMT_KRW     /* 당해 환불 비중  - 원화   */
          ,COALESCE(CAST(PCNT_AMT_YOY_KRW AS DECIMAL(20,2)), 0) AS PCNT_AMT_YOY_KRW /* 전해 환불 비중  - 원화   */
          ,COALESCE(CAST(PCNT_RATE_KRW    AS DECIMAL(20,2)), 0) AS PCNT_RATE_KRW    /* 환불비중 증감률 - 원화   */
      FROM WT_BASE


/* salesRefundTimeSeriesAllGraph.sql */
/* 4. 전체 매출 환불 시계열 그래프 - 환불 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_COPY AS
    (
        SELECT 1           AS SORT_KEY
              ,'SALE'      AS L_LGND_ID /* 일매출          */ 
              ,'일매출'    AS L_LGND_NM /* 결제금액 - 일매출*/
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'SALE_WEEK'  AS L_LGND_ID /* 주매출           */ 
              ,'주매출'     AS L_LGND_NM /* 결제금액 - 주매출*/
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'SALE_MNTH'  AS L_LGND_ID /* 월매출           */ 
              ,'월매출'     AS L_LGND_NM /* 결제금액 - 월매출*/
     UNION ALL
        SELECT 4            AS SORT_KEY
              ,'REFD'       AS L_LGND_ID /* 일환불           */ 
              ,'일환불'     AS L_LGND_NM /* 환불금액 - 일환불*/
     UNION ALL
        SELECT 5            AS SORT_KEY
              ,'REFD_WEEK'  AS L_LGND_ID /* 주환불           */
              ,'주환불'     AS L_LGND_NM /* 환불금액 - 주환불*/
     UNION ALL
        SELECT 6            AS SORT_KEY
              ,'REFD_MNTH'  AS L_LGND_ID /* 월환불          */
              ,'월환불'     AS L_LGND_NM /* 환불금액 - 월환불*/
     UNION ALL
        SELECT 7            AS SORT_KEY
              ,'RATE'       AS L_LGND_ID /* 일환불비중       */ 
              ,'일환불비중' AS L_LGND_NM /* 환불비중 - 일비중*/
     UNION ALL
        SELECT 8            AS SORT_KEY
              ,'RATE_WEEK'  AS L_LGND_ID /* 주환불비중       */
              ,'주환불비중' AS L_LGND_NM /* 환불금액 - 주비중*/
     UNION ALL
        SELECT 9            AS SORT_KEY
              ,'RATE_MNTH'  AS L_LGND_ID /* 월환불비중       */
              ,'월환불비중' AS L_LGND_NM /* 환불금액 - 월비중*/
    ), WT_EXCH AS
    (
        SELECT STATISTICS_DATE
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_MOVE AS
    (
        SELECT STATISTICS_DATE
              ,    SUM(SALE_AMT_RMB)                                                                           AS SALE_AMT_RMB       /* 일매출                - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_RMB  /* 주매출 이동평균( 5일) - 위안화 */
              ,AVG(SUM(SALE_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_RMB  /* 월매출 이동평균(30일) - 위안화 */
              ,    SUM(REFD_AMT_RMB)                                                                           AS REFD_AMT_RMB       /* 일환불                - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_RMB  /* 주환불 이동평균( 5일) - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_RMB  /* 월환불 이동평균(30일) - 위안화 */

              ,    SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100                                                                           AS REFD_RATE_RMB       /* 일비중                - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_RATE_WEEK_RMB  /* 주비중 이동평균( 5일) - 위안화 */
              ,AVG(SUM(REFD_AMT_RMB) / NULLIF(SUM(SALE_AMT_RMB), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_RATE_MNTH_RMB  /* 월비중 이동평균(30일) - 위안화 */


              ,    SUM(SALE_AMT_KRW)                                                                           AS SALE_AMT_KRW       /* 일매출                - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS SALE_AMT_WEEK_KRW  /* 일매출 이동평균( 5일) - 원화   */
              ,AVG(SUM(SALE_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS SALE_AMT_MNTH_KRW  /* 일매출 이동평균(30일) - 원화   */
              ,    SUM(REFD_AMT_KRW)                                                                           AS REFD_AMT_KRW       /* 일환불                - 원화   */
              ,AVG(SUM(REFD_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_AMT_WEEK_KRW  /* 일환불 이동평균( 5일) - 원화   */
              ,AVG(SUM(REFD_AMT_KRW)) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_AMT_MNTH_KRW  /* 일환불 이동평균(30일) - 원화   */

              ,    SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100                                                                           AS REFD_RATE_KRW       /* 일비중                - 원화   */
              ,AVG(SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN  4 PRECEDING AND CURRENT ROW) AS REFD_RATE_WEEK_KRW  /* 주비중 이동평균( 5일) - 원화   */
              ,AVG(SUM(REFD_AMT_KRW) / NULLIF(SUM(SALE_AMT_KRW), 0) * 100) OVER(ORDER BY STATISTICS_DATE ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS REFD_RATE_MNTH_KRW  /* 월비중 이동평균(30일) - 원화   */
          FROM WT_EXCH A
      GROUP BY STATISTICS_DATE
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND_ID
              ,L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_RMB
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_RMB
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_RMB
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_RMB
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_RMB
                 WHEN L_LGND_ID = 'RATE'      THEN REFD_RATE_RMB
                 WHEN L_LGND_ID = 'RATE_WEEK' THEN REFD_RATE_WEEK_RMB
                 WHEN L_LGND_ID = 'RATE_MNTH' THEN REFD_RATE_MNTH_RMB
             END AS Y_VAL_RMB  /* 매출/환불 금액/비중 - 위안화 */
             ,CASE 
                 WHEN L_LGND_ID = 'SALE'      THEN SALE_AMT_KRW
                 WHEN L_LGND_ID = 'SALE_WEEK' THEN SALE_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'SALE_MNTH' THEN SALE_AMT_MNTH_KRW
                 WHEN L_LGND_ID = 'REFD'      THEN REFD_AMT_KRW
                 WHEN L_LGND_ID = 'REFD_WEEK' THEN REFD_AMT_WEEK_KRW
                 WHEN L_LGND_ID = 'REFD_MNTH' THEN REFD_AMT_MNTH_KRW
                 WHEN L_LGND_ID = 'RATE'      THEN REFD_RATE_KRW
                 WHEN L_LGND_ID = 'RATE_WEEK' THEN REFD_RATE_WEEK_KRW
                 WHEN L_LGND_ID = 'RATE_MNTH' THEN REFD_RATE_MNTH_KRW
             END AS Y_VAL_KRW  /* 매출/환불 금액/비중 - 원화   */
        FROM WT_COPY A
            ,WT_MOVE B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RMB
          ,COALESCE(CAST(Y_VAL_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,X_DT


5. 환불정보 데이터 뷰어 (전년 동기간 대비 누적환불 추이, 월별 환불금액 및 환불비중, 전년동월대비 환불금액 및 환불비중)
    * 월별 환불금액 및 환불 비중 : 월별 환불금액과 환불비중이 선택한기간동안 나와야함 
        => 오히려 연도를 선택하는게?
    * 전년동월대비 환불금액 및 환불비중 : 선택한 월의 전년/현재 환불금액과 환불비중 비교
        => /* 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 SQL */

    필요기능 : 
    [1] 보고싶은 표 선택: 위에서 보고싶은 표를 선택(월별환율금액, 전년동월, 등)
    [2] 환율선택 : RMB/ KRW 중 선택
    [3] 월 선택 : 보고싶은 월의 기간을 선택 

/* refundAmountYoY.sql */
/* 5. 환불정보 데이터 뷰어 - 전년 동월대비 환불금액 및 환불비중 SQL */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
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
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_EXCH_YOY AS
    (
        SELECT (SELECT BASE_MNTH FROM WT_WHERE_YOY) AS BASE_MNTH_YOY
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 YoY - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 YoY - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 YoY - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 YoY - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
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
          ,TO_CHAR(COALESCE(REFD_YOY_RMB, 0), 'FM999,999,999,999,990.99')||CASE WHEN ROW_TITL = '환불비중' THEN '%' ELSE '' END AS REFD_YOY_RMB  /* 전년도 - 위안화 */
          ,TO_CHAR(COALESCE(REFD_RMB    , 0), 'FM999,999,999,999,990.99')||CASE WHEN ROW_TITL = '환불비중' THEN '%' ELSE '' END AS REFD_RMB      /* 올해   - 위안화 */
          ,TO_CHAR(COALESCE(REFD_YOY_KRW, 0), 'FM999,999,999,999,990.99')||CASE WHEN ROW_TITL = '환불비중' THEN '%' ELSE '' END AS REFD_YOY_KRW  /* 전년도 - 원화   */
          ,TO_CHAR(COALESCE(REFD_KRW    , 0), 'FM999,999,999,999,990.99')||CASE WHEN ROW_TITL = '환불비중' THEN '%' ELSE '' END AS REFD_KRW      /* 올해   - 원화   */
      FROM WT_BASE
  ORDER BY SORT_KEY


/* refundDataByMonth.sql */
/* 5. 환불정보 데이터 뷰어 - 월별환불금액 및 환불비중 SQL */
WITH WT_WHERE AS
    (
        SELECT :BASE_YEAR  AS BASE_YEAR  /* 사용자가 선택한 년도  ※ 최초 셋팅값 : 이번년도 ex) '2023'  */
    ), WT_COPY AS
    (
        SELECT 1           AS SORT_KEY
              ,'환불금액'  AS ROW_TITL
     UNION ALL
        SELECT 2           AS SORT_KEY
              ,'환불비중'  AS ROW_TITL
     UNION ALL
        SELECT 3           AS SORT_KEY
              ,'YoY'       AS ROW_TITL
     UNION ALL
        SELECT 4           AS SORT_KEY
              ,'MoM'       AS ROW_TITL
    ), WT_COPY_MNTH AS
    (
        SELECT '01'        AS COL_MNTH
     UNION ALL
        SELECT '02'        AS COL_MNTH
     UNION ALL
        SELECT '03'        AS COL_MNTH
     UNION ALL
        SELECT '04'        AS COL_MNTH
     UNION ALL
        SELECT '05'        AS COL_MNTH
     UNION ALL
        SELECT '06'        AS COL_MNTH
     UNION ALL
        SELECT '07'        AS COL_MNTH
     UNION ALL
        SELECT '08'        AS COL_MNTH
     UNION ALL
        SELECT '09'        AS COL_MNTH
     UNION ALL
        SELECT '10'        AS COL_MNTH
     UNION ALL
        SELECT '11'        AS COL_MNTH
     UNION ALL
        SELECT '12'        AS COL_MNTH
    ), WT_EXCH AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS COL_MNTH
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
     UNION ALL
        SELECT '00' AS COL_MNTH
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT CAST(CAST(BASE_YEAR AS INTEGER) - 1 AS TEXT) FROM WT_WHERE), '-12%')
    ), WT_EXCH_YOY AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS COL_MNTH
              ,PAYMENT_AMOUNT                                                     AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,SUCCESSFUL_REFUND_AMOUNT                                           AS REFD_AMT_RMB   /* 일환불 - 위안화 */
              ,PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출 - 원화   */
              ,SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS REFD_AMT_KRW   /* 일환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT CAST(CAST(BASE_YEAR AS integer) - 1 AS TEXT) FROM WT_WHERE), '%')
    ), WT_AMT AS
    (
        SELECT COL_MNTH
              ,SUM(REFD_AMT_RMB) AS REFD_RMB  /* 환불금액 - 위안화 */
              ,SUM(REFD_AMT_KRW) AS REFD_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
      GROUP BY COL_MNTH
    ), WT_RATE AS
    (
        SELECT COL_MNTH
              ,SUM(REFD_AMT_RMB) / SUM(SALE_AMT_RMB) AS REFD_RMB  /* 환불비중 - 위안화 */
              ,SUM(REFD_AMT_KRW) / SUM(SALE_AMT_KRW) AS REFD_KRW  /* 환불비중 - 원화   */
          FROM WT_EXCH A
      GROUP BY COL_MNTH
    ), WT_RATE_YOY AS
    (
        SELECT COL_MNTH
              ,SUM(REFD_AMT_RMB) / SUM(SALE_AMT_RMB) AS REFD_RMB  /* 환불비중 - 위안화 */
              ,SUM(REFD_AMT_KRW) / SUM(SALE_AMT_KRW) AS REFD_KRW  /* 환불비중 - 원화   */
          FROM WT_EXCH_YOY A
      GROUP BY COL_MNTH
    ), WT_ALL AS
    (
        SELECT 1 AS SORT_KEY
              ,COL_MNTH
              ,REFD_RMB
              ,REFD_KRW
          FROM WT_AMT
     UNION ALL
        SELECT 2 AS SORT_KEY
              ,COL_MNTH
              ,REFD_RMB
              ,REFD_KRW
          FROM WT_RATE
     UNION ALL
        SELECT 3 AS SORT_KEY
              ,A.COL_MNTH
              ,CAST(B.REFD_RMB AS DECIMAL(20,2)) - CAST(C.REFD_RMB AS DECIMAL(20,2)) AS REFD_RMB
              ,CAST(B.REFD_KRW AS DECIMAL(20,2)) - CAST(C.REFD_KRW AS DECIMAL(20,2)) AS REFD_KRW
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_RATE     B ON (A.COL_MNTH = B.COL_MNTH)
                              LEFT OUTER JOIN WT_RATE_YOY C ON (A.COL_MNTH = C.COL_MNTH)
     UNION ALL
        SELECT 4 AS SORT_KEY
              ,A.COL_MNTH
              ,CAST(A.REFD_RMB AS DECIMAL(20,2)) - CAST(B.REFD_RMB AS DECIMAL(20,2)) AS REFD_RMB
              ,CAST(A.REFD_KRW AS DECIMAL(20,2)) - CAST(B.REFD_KRW AS DECIMAL(20,2)) AS REFD_KRW
          FROM WT_RATE A INNER JOIN WT_RATE B
            ON(CAST(A.COL_MNTH AS INT) = CAST(B.COL_MNTH AS INT) + 1)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.ROW_TITL
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '01' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_01_RMB /* 01월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '02' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_02_RMB /* 02월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '03' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_03_RMB /* 03월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '04' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_04_RMB /* 04월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '05' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_05_RMB /* 05월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '06' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_06_RMB /* 06월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '07' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_07_RMB /* 07월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '08' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_08_RMB /* 08월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '09' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_09_RMB /* 09월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '10' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_10_RMB /* 10월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '11' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_11_RMB /* 11월 - 위안화 */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '12' THEN B.REFD_RMB END) AS DECIMAL(20,2)) AS REFD_12_RMB /* 12월 - 위안화 */
    
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '01' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_01_KRW /* 01월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '02' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_02_KRW /* 02월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '03' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_03_KRW /* 03월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '04' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_04_KRW /* 04월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '05' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_05_KRW /* 05월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '06' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_06_KRW /* 06월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '07' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_07_KRW /* 07월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '08' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_08_KRW /* 08월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '09' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_09_KRW /* 09월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '10' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_10_KRW /* 10월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '11' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_11_KRW /* 11월 - 원화   */
              ,CAST(MAX(CASE WHEN B.COL_MNTH = '12' THEN B.REFD_KRW END) AS DECIMAL(20,2)) AS REFD_12_KRW /* 12월 - 원화   */
          FROM WT_COPY A LEFT OUTER JOIN WT_ALL B ON (A.SORT_KEY = B.SORT_KEY)
      GROUP BY A.SORT_KEY
              ,A.ROW_TITL
    )
    SELECT SORT_KEY
          ,ROW_TITL
          ,TO_CHAR(REFD_01_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_01_RMB /* 01월 - 위안화 */
          ,TO_CHAR(REFD_02_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_02_RMB /* 02월 - 위안화 */
          ,TO_CHAR(REFD_03_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_03_RMB /* 03월 - 위안화 */
          ,TO_CHAR(REFD_04_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_04_RMB /* 04월 - 위안화 */
          ,TO_CHAR(REFD_05_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_05_RMB /* 05월 - 위안화 */
          ,TO_CHAR(REFD_06_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_06_RMB /* 06월 - 위안화 */
          ,TO_CHAR(REFD_07_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_07_RMB /* 07월 - 위안화 */
          ,TO_CHAR(REFD_08_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_08_RMB /* 08월 - 위안화 */
          ,TO_CHAR(REFD_09_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_09_RMB /* 09월 - 위안화 */
          ,TO_CHAR(REFD_10_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_10_RMB /* 10월 - 위안화 */
          ,TO_CHAR(REFD_11_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_11_RMB /* 11월 - 위안화 */
          ,TO_CHAR(REFD_12_RMB, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_12_RMB /* 12월 - 위안화 */

          ,TO_CHAR(REFD_01_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_01_KRW /* 01월 - 원화   */
          ,TO_CHAR(REFD_02_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_02_KRW /* 02월 - 원화   */
          ,TO_CHAR(REFD_03_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_03_KRW /* 03월 - 원화   */
          ,TO_CHAR(REFD_04_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_04_KRW /* 04월 - 원화   */
          ,TO_CHAR(REFD_05_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_05_KRW /* 05월 - 원화   */
          ,TO_CHAR(REFD_06_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_06_KRW /* 06월 - 원화   */
          ,TO_CHAR(REFD_07_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_07_KRW /* 07월 - 원화   */
          ,TO_CHAR(REFD_08_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_08_KRW /* 08월 - 원화   */
          ,TO_CHAR(REFD_09_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_09_KRW /* 09월 - 원화   */
          ,TO_CHAR(REFD_10_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_10_KRW /* 10월 - 원화   */
          ,TO_CHAR(REFD_11_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_11_KRW /* 11월 - 원화   */
          ,TO_CHAR(REFD_12_KRW, 'FM999,999,999,999,990.00')||CASE WHEN ROW_TITL = '환불금액' THEN '' ELSE '%' END AS REFD_12_KRW /* 12월 - 원화   */
      FROM WT_BASE
  ORDER BY SORT_KEY


6. 채널 내 매출 순위 300위
    * 선택된 채널의 상위 300위 브랜드, 거래지수, 국가, 더마여부
      => 테이블 정보 없음
    필요기능 : 
    [1] 국가 선택기능 : 원하는 국가를 선택하여 볼 수 있는 소팅 기능
    [2] 더마여부 선택기능 : 더마인지 아닌지 선택 
    [3] 월 선택 : 보고싶은 월 선택가능
    [4] 더마펌 브랜드 이동기능


/* 해당 데이터를 조회해 보면 여러 국가가 나옴
SELECT * FROM DASH.TMALL_STORE_RANK_DATA WHERE shop_id  = '67597230'
SELECT * FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY WHERE shop_id  = '67597230'
*/

/* storeName.sql */
/* 6. 채널 내 매출 순위 300위 - 상점명 선택 SQL */
WITH WT_BASE AS
    (
        SELECT DISTINCT
               SHOP_ID   AS SHOP_ID
              ,SHOPNAME  AS SHOP_NM
          FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY 
    )
    SELECT SHOP_ID
          ,SHOP_NM
      FROM WT_BASE
  ORDER BY SHOP_NM


/* channelSalesRank300Grid.sql */
/* 6. 채널 내 매출 순위 300위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH           /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH           /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:MLTI_YN  AS MLTI_YN           /* 사용자가 선택한 화장품전문몰 제외  ex) 전체:%, 화장품전문몰 제외:N  */
              ,:KR_YN    AS KR_YN             /* 사용자가 선택한 국가               ex) 전체:%, 한국:Y               */
              ,:DEMA_YN  AS DEMA_YN           /* 사용자가 선택한 더마여부           ex) 전체:%, 더마:Y, 더마 외:N    */
    ), WT_SHOP_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()  AS SORT_KEY 
              ,TRIM(SHOP_ID)         AS SHOP_ID
          FROM REGEXP_SPLIT_TO_TABLE(:SHOP_ID, ',') AS SHOP_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '67597230, 60637940, 492216636' */
         WHERE TRIM(SHOP_ID) <> ''
    ), WT_SHOP_RAW AS
    (
        SELECT CAST(SHOP_ID AS TEXT)                   AS SHOP_ID
              ,ARRAY_TO_STRING(ARRAY_AGG(COUNTRY),',') AS NATN_LIST
              ,COUNT(DISTINCT COUNTRY)                 AS NATN_CNT
              ,MAX(DERMA)                              AS DEMA_YN
          FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY
      GROUP BY SHOP_ID
    ), WT_SHOP AS
    (
        SELECT SHOP_ID
              ,NATN_LIST 
              ,NATN_CNT
              ,CASE WHEN NATN_CNT > 1                      THEN 'Y' ELSE 'N' END AS MLTI_YN
              ,CASE WHEN POSITION('한국' IN NATN_LIST) > 0 THEN 'Y' ELSE 'N' END AS KR_YN
              ,CASE WHEN DEMA_YN = 1                       THEN 'Y' ELSE 'N' END AS DEMA_YN
          FROM WT_SHOP_RAW
    ), WT_SALE AS
    (
        SELECT DISTINCT
               A.SHOP_ID                              AS SHOP_ID
              ,A.SHOP_NAME                            AS SHOP_NM
              ,A.SALE_AMT                             AS SALE_AMT
              ,B.NATN_LIST                            AS NATN_NM
              ,B.NATN_CNT                             AS NATN_CNT
              ,B.MLTI_YN                              AS MLTI_YN
              ,B.KR_YN                                AS KR_YN
              ,CASE WHEN B.DEMA_YN = 'Y' THEN '●' END AS DEMA_YN
              ,A.BASE_TIME
          FROM DASH.TMALL_STORE_RANK_DATA A INNER JOIN WT_SHOP B
            ON (A.SHOP_ID = B.SHOP_ID)
         WHERE A.BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
           AND B.MLTI_YN LIKE (SELECT MLTI_YN FROM WT_WHERE)
           AND B.KR_YN   LIKE (SELECT KR_YN   FROM WT_WHERE)
           AND B.DEMA_YN LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SHOP_ID        AS SHOP_ID
              ,SHOP_NM        AS SHOP_NM
              ,SUM(SALE_AMT)  AS SALE_AMT
              ,MAX(NATN_NM)   AS NATN_NM
              ,MAX(NATN_CNT)  AS NATN_CNT
              ,MAX(MLTI_YN)   AS MLTI_YN
              ,MAX(KR_YN)     AS KR_YN
              ,MAX(DEMA_YN)   AS DEMA_YN
          FROM WT_SALE
      GROUP BY SHOP_ID
              ,SHOP_NM
    ), WT_RATE AS
    (
        SELECT SHOP_ID
              ,SHOP_NM
              ,SALE_AMT / SUM(SALE_AMT) OVER() * 100 AS SALE_RATE
              ,SALE_AMT
              ,SUM(SALE_AMT) OVER()                  AS SALE_AMT_SUM
              ,NATN_NM
              ,NATN_CNT
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_RATE DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
              ,SHOP_ID
              ,SHOP_NM
              ,TO_CHAR(SALE_RATE, 'FM999,999,999,999,990.0000') AS SALE_RATE
              ,SALE_AMT
              ,SALE_AMT_SUM
              ,CASE WHEN NATN_CNT = 1 THEN NATN_NM ELSE '다국적' END AS NATN_NM
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_RATE
    )
    SELECT SHOP_RANK
          ,SHOP_ID
          ,SHOP_NM
          ,SALE_RATE
          ,SALE_AMT
          ,SALE_AMT_SUM
          ,NATN_NM
          ,MLTI_YN
          ,KR_YN
          ,DEMA_YN
      FROM WT_BASE
     WHERE ((SELECT COUNT(*) FROM WT_SHOP_WHERE) > 0 AND SHOP_ID IN (SELECT SHOP_ID FROM WT_SHOP_WHERE))
        OR ((SELECT COUNT(*) FROM WT_SHOP_WHERE) = 0 )
  ORDER BY SHOP_RANK
     LIMIT 300



7. 카테고리별 매출 순위
    * 선택된 채널의 상위 300위 카테고리 제품 : 카테고리, 제품명, 브랜드, 거래지수, 국가, 더마여부
      => 테이블 정보 없음
    필요기능 : 
    [1] 국가 선택기능 : 원하는 국가를 선택하여 볼 수 있는 소팅 기능
    [2] 더마여부 선택기능 : 더마인지 아닌지 선택 
    [3] 월 선택 : 보고싶은 월 선택가능
    [4] 카테고리 선택 : 보고싶은 카테고리 선택가능

/* categorySalesRank1.sql */
/* 7. 카테고리별 매출 순위 - 1차 카테고리 선택 SQL */
WITH WT_BASE AS
    (
        SELECT DISTINCT
               "번역1차" AS CATE_1
          FROM DASH_RAW.OVER_TMALL_ITEM_RANK_CATEGORY
    )
    SELECT CATE_1
      FROM WT_BASE
  ORDER BY CATE_1 COLLATE "ko_KR.utf8"


/* categorySalesRank2.sql */
/* 7. 카테고리별 매출 순위 - 2차 카테고리 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT :CATE_1  AS CATE_1           /* 사용자가 선택한 1차 카테고리 ex) '메이크업/향수/미용 도구' 또는 '스킨케어/바디/에센셜오일'  */
    ), WT_BASE AS
    (
        SELECT DISTINCT
               "번역1차" AS CATE_1
              ,"번역2차" AS CATE_2
          FROM DASH_RAW.OVER_TMALL_ITEM_RANK_CATEGORY
    )
    SELECT CATE_1
          ,CATE_2
      FROM WT_BASE
     WHERE CATE_1 = (SELECT CATE_1 FROM WT_WHERE)
  ORDER BY CATE_2 COLLATE "ko_KR.utf8"



/* 해당 데이터를 조회해 보면 동일한 데이터가 2건 씩 나옴
SELECT * FROM DASH.TMALL_ITEM_RANK_DATA WHERE PROD_ID = '685342371188'
*/

/* categorySalesRankGrid.sql */
/* 7. 카테고리별 매출 순위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH           /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH           /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:KR_YN    AS KR_YN             /* 사용자가 선택한 국가     ex) 전체:%, 한국:Y */
              ,:DEMA_YN  AS DEMA_YN           /* 사용자가 선택한 더마여부 ex) 전체:%, 더마:Y, 더마 외:N */
    ), WT_CATE_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(CATE_2)         AS CATE_2
          FROM REGEXP_SPLIT_TO_TABLE(:CATE_2, ',') AS CATE_2  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '바디 케어, 로션/크림, 클렌징' */
         WHERE TRIM(CATE_2) <> ''
    ), WT_SALE AS
    (
        SELECT DISTINCT
              "1차"                             AS CATE_1
              ,"2차"                            AS CATE_2
              ,PROD_ID                          AS PROD_ID
              ,KR_NAME                          AS PROD_NM
              ,ITEM_PIC                         AS PROD_URL
              ,CAST(SALE_AMT AS DECIMAL(20,0))  AS SALE_AMT
              ,COUNTRY                          AS NATN_NM
              ,CASE WHEN DERMA = 1 THEN '●' END AS DEMA_YN
              ,BASE_TIME
          FROM DASH.TMALL_ITEM_RANK_DATA
         WHERE BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
           AND "2차"   IN (SELECT CATE_2 FROM WT_CATE_WHERE)
           AND COUNTRY LIKE CASE WHEN (SELECT KR_YN FROM WT_WHERE) = 'Y' THEN '%한국%' ELSE '%' END
           AND CASE WHEN DERMA = 1 THEN 'Y' ELSE 'N' END LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT MAX(CATE_1)   AS CATE_1
              ,MAX(CATE_2)   AS CATE_2
              ,PROD_ID
              ,PROD_NM
              ,MAX(PROD_URL) AS PROD_URL
              ,SUM(SALE_AMT) AS SALE_AMT
              ,ARRAY_TO_STRING(ARRAY_AGG(DISTINCT NATN_NM),',') AS NATN_NM
              ,MAX(DEMA_YN)  AS DEMA_YN
          FROM WT_SALE
      GROUP BY PROD_ID
              ,PROD_NM
    ), WT_RATE AS
    (
        SELECT CATE_1
              ,CATE_2
              ,PROD_ID
              ,PROD_NM
              ,PROD_URL
              ,SALE_AMT / SUM(SALE_AMT) OVER() * 100 AS SALE_RATE
              ,SALE_AMT
              ,SUM(SALE_AMT) OVER()                  AS SALE_AMT_SUM
              ,NATN_NM
              ,DEMA_YN
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_RATE DESC NULLS LAST, PROD_NM) AS PROD_RANK
              ,CATE_1
              ,CATE_2
              ,PROD_ID
              ,PROD_NM
              ,PROD_URL
              ,TO_CHAR(SALE_RATE, 'FM999,999,999,999,990.0000') AS SALE_RATE
              ,SALE_AMT
              ,SALE_AMT_SUM
              ,NATN_NM
              ,DEMA_YN
          FROM WT_RATE
    )
    SELECT PROD_RANK
          ,CATE_1
          ,CATE_2
          ,PROD_ID
          ,PROD_NM
          ,PROD_URL
          ,SALE_RATE
          ,SALE_AMT
          ,SALE_AMT_SUM
          ,NATN_NM
          ,DEMA_YN
      FROM WT_BASE
  ORDER BY PROD_RANK





8. 제품별 매출 정보 시계열 그래프
    * 제품별 매출 시계열그래프 : 사용자가 선택한 기간과 제품에 따른 일별 매출 시계열 그래프(예 : 1월1일부터 2월 1일까지) 
        => /* 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL */
    * Rolling 주단위 매출 : 해당일 까지 rolling으로 주단위 매출 최소 계산 단위(5일) 
        => 주단위, 월단위는 Legend에서 제거하고, 제품이 Legend로 들어가도록 수정하기로함.
    * Rolling 월단위 매출 : 해당일까지 rollin으로 월단위 매출값 산출 (30일)
        => 주단위, 월단위는 Legend에서 제거하고, 제품이 Legend로 들어가도록 수정하기로함.
    * 오른쪽 y축 기준으로 전체 매출 정보 연하게 들어가기
        => /* 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL */

    필요 기능 : 
    [1] 기간선택 : 타임슬라이드 기준 
    [2] 지표선택 : 결제금액, 환불제외금액(결제 - 환불금액) 복수선택 가능 형태
        => 이미 제품이 Legend 이므로, 복수선택은 하지 않고, 선택에 따라 y값 (금액) 이 변경되게 하기로함.
           Y_VAL_SALE_RMB /* 일매출           - 위안화 */
           Y_VAL_EXRE_RMB /* 일매출(환불제외) - 위안화 */
           Y_VAL_SALE_KRW /* 일매출           - 원화   */
           Y_VAL_EXRE_KRW /* 일매출(환불제외) - 원화   */
    [3] 주단위/월단위 선택기능 : 기본으로는 주, 월 rolling 지표 다 주되, 지표를 누르면 사라지거나 생성되도록
        => 주단위, 월단위는 Legend에서 제거하고, 제품이 Legend로 들어가도록 수정하기로함.
    [4] 제품선택 : 제품선택 (복수선택 가능해야함) 
        => 선택한 제품이 Legend 
        => /* 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 SQL */

/* productSalesMast.sql, productRefundMast.sql */    
/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD AS
    (
        SELECT DISTINCT
               CAST(PRODUCT_ID AS VARCHAR) AS PRODUCT_ID
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    )
    SELECT A.PRODUCT_ID   AS PROD_ID
          ,A.PRODUCT_NAME AS PROD_NM
      FROM DASH_RAW.OVER_DGT_ID_NAME_URL A INNER JOIN WT_PROD B ON (A.PRODUCT_ID = B.PRODUCT_ID)
  ORDER BY PRODUCT_NAME COLLATE "ko_KR.utf8"



/* productSalesTimeSeries.sql */
/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 매출 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '564613428727, 564872651758, 617136486827, 618017669492, 630334774562' */        
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,2)) AS REFD_AMT_RMB   /* 일환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PRODUCT_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE) 
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              , SALE_AMT_RMB                                                                        AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              , SALE_AMT_RMB - COALESCE(REFD_AMT_RMB, 0)                                            AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , SALE_AMT_RMB                              * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(SALE_AMT_RMB - COALESCE(REFD_AMT_RMB, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM WT_CAST A
     UNION ALL
        SELECT 9999999999999 AS PRODUCT_ID
              ,STATISTICS_DATE
              , PAYMENT_AMOUNT                                                                                    AS SALE_AMT_RMB   /* 일매출           - 위안화 */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0))                                           AS EXRE_AMT_RMB   /* 일매출(환불제외) - 위안화 */
              , PAYMENT_AMOUNT                                          * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS SALE_AMT_KRW   /* 일매출           - 원화   */
              ,(PAYMENT_AMOUNT - COALESCE(SUCCESSFUL_REFUND_AMOUNT, 0)) * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE) AS EXRE_AMT_KRW   /* 일매출(환불제외) - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,SUM(SALE_AMT_RMB) AS SALE_AMT_RMB /* 일매출            - 위안화 */
              ,SUM(EXRE_AMT_RMB) AS EXRE_AMT_RMB /* 일매출(환불제외)  - 위안화 */
              ,SUM(SALE_AMT_KRW) AS SALE_AMT_KRW /* 일매출            - 원화   */
              ,SUM(EXRE_AMT_KRW) AS EXRE_AMT_KRW /* 일매출(환불제외)  - 원화   */
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
                 WHEN PRODUCT_ID = 9999999999999 THEN '전체 매출'
                 ELSE DASH_RAW.SF_PROD_NM(A.PRODUCT_ID)
               END AS L_LGND_NM
              ,STATISTICS_DATE AS X_DT
              ,SALE_AMT_RMB    AS Y_VAL_SALE_RMB /* 일매출           - 위안화 */
              ,EXRE_AMT_RMB    AS Y_VAL_EXRE_RMB /* 일매출(환불제외) - 위안화 */
              ,SALE_AMT_KRW    AS Y_VAL_SALE_KRW /* 일매출           - 원화   */
              ,EXRE_AMT_KRW    AS Y_VAL_EXRE_KRW /* 일매출(환불제외) - 원화   */
        FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT
          ,COALESCE(CAST(Y_VAL_SALE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_SALE_RMB
          ,COALESCE(CAST(Y_VAL_EXRE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_EXRE_RMB
          ,COALESCE(CAST(Y_VAL_SALE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_SALE_KRW
          ,COALESCE(CAST(Y_VAL_EXRE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_EXRE_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT




9.제품별 매출 정보 데이터 뷰어 (전년 동기간 누적 top5, 전년 동월대비 매출 top 5, 월별 매출 top 5)
    * 전년 동기간 매출 TOP 5의 제품 : 1/1 부터 현재까지 매출 TOP 5제품 리스트 와 전년 동기간의 매출 TOP5 제품리스트
        => /* 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 SQL */
    * 전년 동월 대비 매출 TOP5 의 제품  : 선택한 월의 전년 동월 매출 TOP5와 올해 동월 매출 TOP5
        => /* 9. 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 SQL */
    * 월별 매출 TOP 5 제품 : 올해 지금까지 당해 연도 월별 매출 TOP5
        => /* 9. 제품별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 SQL */

    필요기능 : 
    [1] 지표선택 : 결제금액 또는 환불제외금액 선택 
    [2] 월 선택 : 보고싶은 월의 기간을 선택 

/* salesComparisonLastYear.sql */
/* 9. 제품별 매출 정보 데이터 뷰어 - 전년동기간 대비 누적 매출 TOP 5 SQL */
/*    금년 매출금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년 매출금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 YoY - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'     AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,SALE_RANK_RMB  AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB   AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'     AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,SALE_RANK_KRW  AS SALE_RANK  /* 매출순위 -      원화   */
              ,SALE_AMT_KRW   AS SALE_AMT   /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB' AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,SALE_RANK_RMB  AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB   AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW' AS RANK_TYPE /* 순위     - 전년 원화   */
              ,SALE_RANK_KRW  AS SALE_RANK /* 매출순위 -      원화   */
              ,SALE_AMT_KRW   AS SALE_AMT  /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(D.PRODUCT_ID)           AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.SALE_AMT                                  AS SALE_AMT_YOY_RMB  /* 전년 매출액   - 위안화 */
              ,D.SALE_AMT / Y.SALE_AMT_RMB  * 100          AS SALE_RATE_YOY_RMB /* 전년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.SALE_AMT                                  AS SALE_AMT_RMB      /* 금년 매출액   - 위안화 */
              ,B.SALE_AMT / T.SALE_AMT_RMB  * 100          AS SALE_RATE_RMB     /* 금년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(E.PRODUCT_ID)           AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.SALE_AMT                                  AS SALE_AMT_YOY_KRW  /* 전년 매출액   - 원화    */
              ,E.SALE_AMT / Y.SALE_AMT_KRW  * 100          AS SALE_RATE_YOY_KRW /* 전년 매출비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.SALE_AMT                                  AS SALE_AMT_KRW      /* 금년 매출액   - 원화    */
              ,C.SALE_AMT / T.SALE_AMT_KRW  * 100          AS SALE_RATE_KRW     /* 금년 매출비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.SALE_RANK = B.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.SALE_RANK = C.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.SALE_RANK = D.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.SALE_RANK = E.SALE_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT SALE_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_RMB  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_YOY_RMB   /* 전년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_RMB  /* 전년 매출비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_RMB      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_RMB       /* 금년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_RMB      /* 금년 매출비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_KRW  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_YOY_KRW   /* 전년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_KRW  /* 전년 매출비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_KRW      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_KRW       /* 금년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_KRW      /* 금년 매출비중 - 원화 */
      FROM WT_BASE
  ORDER BY SALE_RANK


/* salesRankingLYMoM.sql */
/* 9. 제품별 매출 정보 데이터 뷰어 - 전년동월 대비 매출 TOP 5 SQL */
/*    최종 화면에 표시할 컬럼 (등수 : SALE_RANK, 작년 제품명 : PROD_NM_YOY_RMB 또는 PROD_NM_YOY_KRW,  올해 제품명 : PROD_NM_RMB 또는 PROD_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(PAYMENT_AMOUNT                                                    ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(PAYMENT_AMOUNT           * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 YoY - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,RANK() OVER(ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'      AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,SALE_RANK_RMB   AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB    AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'      AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,SALE_RANK_KRW   AS SALE_RANK  /* 매출순위 -      원화   */
              ,SALE_AMT_KRW    AS SALE_AMT   /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB'  AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,SALE_RANK_RMB   AS SALE_RANK  /* 매출순위 -      위안화 */
              ,SALE_AMT_RMB    AS SALE_AMT   /* 매출금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW'  AS RANK_TYPE /* 순위     - 전년 원화   */
              ,SALE_RANK_KRW   AS SALE_RANK /* 매출순위 -      원화   */
              ,SALE_AMT_KRW    AS SALE_AMT  /* 매출금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE SALE_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.SALE_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(D.PRODUCT_ID)           AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.SALE_AMT                                  AS SALE_AMT_YOY_RMB  /* 전년 매출액   - 위안화 */
              ,D.SALE_AMT / Y.SALE_AMT_RMB  * 100          AS SALE_RATE_YOY_RMB /* 전년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.SALE_AMT                                  AS SALE_AMT_RMB      /* 금년 매출액   - 위안화 */
              ,B.SALE_AMT / T.SALE_AMT_RMB  * 100          AS SALE_RATE_RMB     /* 금년 매출비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(E.PRODUCT_ID)           AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.SALE_AMT                                  AS SALE_AMT_YOY_KRW  /* 전년 매출액   - 원화    */
              ,E.SALE_AMT / Y.SALE_AMT_KRW  * 100          AS SALE_RATE_YOY_KRW /* 전년 매출비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.SALE_AMT                                  AS SALE_AMT_KRW      /* 금년 매출액   - 원화    */
              ,C.SALE_AMT / T.SALE_AMT_KRW  * 100          AS SALE_RATE_KRW     /* 금년 매출비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.SALE_RANK = B.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.SALE_RANK = C.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.SALE_RANK = D.SALE_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.SALE_RANK = E.SALE_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT SALE_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_RMB  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_YOY_RMB   /* 전년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_RMB  /* 전년 매출비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(SALE_AMT_RMB      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_RMB       /* 금년 매출액   - 위안화 */
          ,TO_CHAR(CAST(SALE_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_RMB      /* 금년 매출비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_YOY_KRW  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_YOY_KRW   /* 전년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_YOY_KRW  /* 전년 매출비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(SALE_AMT_KRW      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS SALE_AMT_KRW       /* 금년 매출액   - 원화 */
          ,TO_CHAR(CAST(SALE_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS SALE_RATE_KRW      /* 금년 매출비중 - 원화 */
      FROM WT_BASE
  ORDER BY SALE_RANK

/* topSalesLastMonth.sql */
/* 9. 제품별 매출 정보 데이터 뷰어 - 전월별매출 TOP 5 SQL */
/*    최종 화면에 표시할 컬럼 (등수 : SALE_RANK, 작년 제품명 : PROD_NM_YOY_RMB 또는 PROD_NM_YOY_KRW,  올해 제품명 : PROD_NM_RMB 또는 PROD_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS SALE_RANK
     UNION ALL
        SELECT 2 AS SALE_RANK
     UNION ALL
        SELECT 3 AS SALE_RANK
     UNION ALL
        SELECT 4 AS SALE_RANK
     UNION ALL
        SELECT 5 AS SALE_RANK
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,2)) AS SALE_AMT_RMB   /* 매출 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
    ), WT_EXCH AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,PRODUCT_ID
              ,SUM(SALE_AMT_RMB                                          ) AS SALE_AMT_RMB   /* 매출 - 위안화 */
              ,SUM(SALE_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS SALE_AMT_KRW   /* 매출 - 원화   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK_RMB AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY SALE_AMT_RMB DESC, PRODUCT_ID) AS SALE_RANK_RMB  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB  /* 매출금액 - 위안화 */
          FROM WT_EXCH A
    ), WT_RANK_KRW AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY SALE_AMT_KRW DESC, PRODUCT_ID) AS SALE_RANK_KRW  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW  /* 매출금액 - 원화   */
          FROM WT_EXCH A
    ), WT_BASE_RANK_01_RMB AS
    (
        SELECT 'RANK_01_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '01'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_02_RMB AS
    (
        SELECT 'RANK_02_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '02'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_03_RMB AS
    (
        SELECT 'RANK_03_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '03'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_04_RMB AS
    (
        SELECT 'RANK_04_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '04'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_05_RMB AS
    (
        SELECT 'RANK_05_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '05'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_06_RMB AS
    (
        SELECT 'RANK_06_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '06'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_07_RMB AS
    (
        SELECT 'RANK_07_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '07'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_08_RMB AS
    (
        SELECT 'RANK_08_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '08'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_09_RMB AS
    (
        SELECT 'RANK_09_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '09'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_10_RMB AS
    (
        SELECT 'RANK_10_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '10'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_11_RMB AS
    (
        SELECT 'RANK_11_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '11'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_12_RMB AS
    (
        SELECT 'RANK_12_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,SALE_RANK_RMB                     AS SALE_RANK  /* 매출순위 - 위안화 */
              ,SALE_AMT_RMB                      AS SALE_AMT   /* 매출금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '12'
           AND SALE_RANK_RMB <= 5
    ), WT_BASE_RANK_01_KRW AS
    (
        SELECT 'RANK_01_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '01'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_02_KRW AS
    (
        SELECT 'RANK_02_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '02'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_03_KRW AS
    (
        SELECT 'RANK_03_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '03'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_04_KRW AS
    (
        SELECT 'RANK_04_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '04'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_05_KRW AS
    (
        SELECT 'RANK_05_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '05'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_06_KRW AS
    (
        SELECT 'RANK_06_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '06'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_07_KRW AS
    (
        SELECT 'RANK_07_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '07'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_08_KRW AS
    (
        SELECT 'RANK_08_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '08'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_09_KRW AS
    (
        SELECT 'RANK_09_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '09'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_10_KRW AS
    (
        SELECT 'RANK_10_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '10'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_11_KRW AS
    (
        SELECT 'RANK_11_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '11'
           AND SALE_RANK_KRW <= 5
    ), WT_BASE_RANK_12_KRW AS
    (
        SELECT 'RANK_12_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,SALE_RANK_KRW                     AS SALE_RANK  /* 매출순위 - 원화   */
              ,SALE_AMT_KRW                      AS SALE_AMT   /* 매출금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '12'
           AND SALE_RANK_KRW <= 5
    )
    SELECT A.SALE_RANK                                                         /* 순위                   */
          ,COALESCE(CAST(RMB_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_RMB  /* 01월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_RMB  /* 02월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_RMB  /* 03월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_RMB  /* 04월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_RMB  /* 05월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_RMB  /* 06월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_RMB  /* 07월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_RMB  /* 08월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_RMB  /* 09월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_RMB  /* 10월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_RMB  /* 11월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_RMB  /* 12월 제품ID   - 위안화 */

          ,COALESCE(CAST(RMB_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01_RMB  /* 01월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02_RMB  /* 02월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03_RMB  /* 03월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04_RMB  /* 04월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05_RMB  /* 05월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06_RMB  /* 06월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07_RMB  /* 07월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08_RMB  /* 08월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09_RMB  /* 09월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10_RMB  /* 10월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11_RMB  /* 11월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12_RMB  /* 12월 제품명   - 위안화 */

          ,CAST(RMB_01.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_01_RMB /* 01월 제품금액 - 위안화 */
          ,CAST(RMB_02.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_02_RMB /* 02월 제품금액 - 위안화 */
          ,CAST(RMB_03.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_03_RMB /* 03월 제품금액 - 위안화 */
          ,CAST(RMB_04.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_04_RMB /* 04월 제품금액 - 위안화 */
          ,CAST(RMB_05.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_05_RMB /* 05월 제품금액 - 위안화 */
          ,CAST(RMB_06.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_06_RMB /* 06월 제품금액 - 위안화 */
          ,CAST(RMB_07.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_07_RMB /* 07월 제품금액 - 위안화 */
          ,CAST(RMB_08.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_08_RMB /* 08월 제품금액 - 위안화 */
          ,CAST(RMB_09.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_09_RMB /* 09월 제품금액 - 위안화 */
          ,CAST(RMB_10.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_10_RMB /* 10월 제품금액 - 위안화 */
          ,CAST(RMB_11.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_11_RMB /* 11월 제품금액 - 위안화 */
          ,CAST(RMB_12.SALE_AMT AS DECIMAL(20,2))           AS SALE_AMT_12_RMB /* 12월 제품금액 - 위안화 */

          ,COALESCE(CAST(KRW_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_KRW  /* 01월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_KRW  /* 02월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_KRW  /* 03월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_KRW  /* 04월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_KRW  /* 05월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_KRW  /* 06월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_KRW  /* 07월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_KRW  /* 08월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_KRW  /* 09월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_KRW  /* 10월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_KRW  /* 11월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_KRW  /* 12월 제품ID   - 원화   */

          ,COALESCE(CAST(KRW_01.PROD_NM  AS VARCHAR), '')  AS PROD_NM_01_KRW  /* 01월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_02.PROD_NM  AS VARCHAR), '')  AS PROD_NM_02_KRW  /* 02월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_03.PROD_NM  AS VARCHAR), '')  AS PROD_NM_03_KRW  /* 03월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_04.PROD_NM  AS VARCHAR), '')  AS PROD_NM_04_KRW  /* 04월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_05.PROD_NM  AS VARCHAR), '')  AS PROD_NM_05_KRW  /* 05월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_06.PROD_NM  AS VARCHAR), '')  AS PROD_NM_06_KRW  /* 06월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_07.PROD_NM  AS VARCHAR), '')  AS PROD_NM_07_KRW  /* 07월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_08.PROD_NM  AS VARCHAR), '')  AS PROD_NM_08_KRW  /* 08월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_09.PROD_NM  AS VARCHAR), '')  AS PROD_NM_09_KRW  /* 09월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_10.PROD_NM  AS VARCHAR), '')  AS PROD_NM_10_KRW  /* 10월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_11.PROD_NM  AS VARCHAR), '')  AS PROD_NM_11_KRW  /* 11월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_12.PROD_NM  AS VARCHAR), '')  AS PROD_NM_12_KRW  /* 12월 제품명   - 원화   */

          ,CAST(KRW_01.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_01_KRW /* 01월 제품금액 - 원화   */
          ,CAST(KRW_02.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_02_KRW /* 02월 제품금액 - 원화   */
          ,CAST(KRW_03.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_03_KRW /* 03월 제품금액 - 원화   */
          ,CAST(KRW_04.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_04_KRW /* 04월 제품금액 - 원화   */
          ,CAST(KRW_05.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_05_KRW /* 05월 제품금액 - 원화   */
          ,CAST(KRW_06.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_06_KRW /* 06월 제품금액 - 원화   */
          ,CAST(KRW_07.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_07_KRW /* 07월 제품금액 - 원화   */
          ,CAST(KRW_08.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_08_KRW /* 08월 제품금액 - 원화   */
          ,CAST(KRW_09.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_09_KRW /* 09월 제품금액 - 원화   */
          ,CAST(KRW_10.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_10_KRW /* 10월 제품금액 - 원화   */
          ,CAST(KRW_11.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_11_KRW /* 11월 제품금액 - 원화   */
          ,CAST(KRW_12.SALE_AMT AS DECIMAL(20,2))          AS SALE_AMT_12_KRW /* 12월 제품금액 - 원화   */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01_RMB RMB_01 ON (A.SALE_RANK = RMB_01.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_RMB RMB_02 ON (A.SALE_RANK = RMB_02.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_RMB RMB_03 ON (A.SALE_RANK = RMB_03.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_RMB RMB_04 ON (A.SALE_RANK = RMB_04.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_RMB RMB_05 ON (A.SALE_RANK = RMB_05.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_RMB RMB_06 ON (A.SALE_RANK = RMB_06.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_RMB RMB_07 ON (A.SALE_RANK = RMB_07.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_RMB RMB_08 ON (A.SALE_RANK = RMB_08.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_RMB RMB_09 ON (A.SALE_RANK = RMB_09.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_RMB RMB_10 ON (A.SALE_RANK = RMB_10.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_RMB RMB_11 ON (A.SALE_RANK = RMB_11.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_RMB RMB_12 ON (A.SALE_RANK = RMB_12.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_01_KRW KRW_01 ON (A.SALE_RANK = KRW_01.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_KRW KRW_02 ON (A.SALE_RANK = KRW_02.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_KRW KRW_03 ON (A.SALE_RANK = KRW_03.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_KRW KRW_04 ON (A.SALE_RANK = KRW_04.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_KRW KRW_05 ON (A.SALE_RANK = KRW_05.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_KRW KRW_06 ON (A.SALE_RANK = KRW_06.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_KRW KRW_07 ON (A.SALE_RANK = KRW_07.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_KRW KRW_08 ON (A.SALE_RANK = KRW_08.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_KRW KRW_09 ON (A.SALE_RANK = KRW_09.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_KRW KRW_10 ON (A.SALE_RANK = KRW_10.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_KRW KRW_11 ON (A.SALE_RANK = KRW_11.SALE_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_KRW KRW_12 ON (A.SALE_RANK = KRW_12.SALE_RANK)
  ORDER BY A.SALE_RANK



10.제품별 환불 시계열 그래프
    * 제품별 환불 시계열그래프 : 사용자가 선택한 기간과 제품에 따른 일별 환불 시계열 그래프(예 : 1월1일부터 2월 1일까지) 
        => /* 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL */
    * 제품별 환불비중 시계열 그래프 : 사용자가 선택한 기간과 제품에 따른 일별 환불비중 시계열 그래프 
        => /* 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL */

    필요 기능 : 
    [1] 기간선택 : 타임슬라이드 기준 
    [2] 지표선택 : 환불금액, 환불비중 선택 
    [3] 주단위/월단위 선택기능 : 일, 주, 월 단위 선택 기능 
    [4] 제품선택 : 제품선택 (복수선택 가능해야함) 
        ==> /* 10. 제품별 환불 정보 시계열 그래프 - 제품별 선택 SQL */ 을 사용

/* productRefundMast.sql, productSalesMast.sql */
/* 10. 제품별 환불 정보 시계열 그래프 - 제품별 선택 SQL */


/* refundTimeSeriesByProduct.sql */
/* 10. 제품별 환불 정보 시계열 그래프 - 제품별 환불 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_DT  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,:TO_DT  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()        AS SORT_KEY 
              ,CAST(TRIM(PROD_ID) AS INT8) AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '564613428727, 564872651758, 617136486827, 618017669492, 630334774562' */        
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(PAYMENT_AMOUNT                      AS DECIMAL(20,4)) AS SALE_AMT_RMB   /* 일매출 - 위안화 */
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 일환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
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
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID)         AS L_LGND_NM
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
          ,COALESCE(CAST(Y_VAL_REFD_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_REFD_RMB
          ,COALESCE(CAST(Y_VAL_RATE_RMB AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_RMB
          ,COALESCE(CAST(Y_VAL_REFD_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_REFD_KRW
          ,COALESCE(CAST(Y_VAL_RATE_KRW AS DECIMAL(20,2)), 0) AS Y_VAL_RATE_KRW
     FROM WT_BASE
 ORDER BY SORT_KEY
         ,L_LGND_ID
         ,X_DT



11.제품별 환불 데이터 뷰어(전년동기 대비 누적 top5, 월별 누적환불 top5, 전년동월대비 누적환불 top 5)
    * 전년 동기간 대비 누적 환불 TOP5: 1/1 부터 현재까지 환불금액, 환불비중의 상위 5개 제품
        => /* 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 SQL      */
    * 월별 누적 환불 TOP5 : 월별 누적환불 TOP 5가 나와야함 (선택한 지표기준)
        => /* 11. 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 SQL */
    * 전년동월대비 환불금액 및 환불비중 TOP 5: 선택한 월의 전년/현재 환불금액과 환불비중 TOP 5제품
        => /* 11. 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 SQL */
    필요기능 : 
    [1] 보고싶은 표 선택: 위에서 보고싶은 표를 선택(월별환율금액, 전년동월, 등)
    [2] 월 선택 : 보고싶은 월의 기간을 선택

/* refundComparisonLastYear.sql */
/* 11. 제품별 환불 데이터 뷰어 - 전년동기간 대비 누적 환불 TOP 5 SQL      */
/*     금년 환불금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*     전년 환불금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT FRST_DT_YEAR      AS FR_DT      /* 기준일의 1월 1일       */
              ,BASE_DT           AS TO_DT      /* 기준일자 (어제)        */
              ,FRST_DT_YEAR_YOY  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,BASE_DT_YOY       AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS REFD_RANK
     UNION ALL
        SELECT 2 AS REFD_RANK
     UNION ALL
        SELECT 3 AS REFD_RANK
     UNION ALL
        SELECT 4 AS REFD_RANK
     UNION ALL
        SELECT 5 AS REFD_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,4)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 YoY - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'       AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,REFD_RANK_RMB    AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB     AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'       AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,REFD_RANK_KRW    AS REFD_RANK  /* 환불순위 -      원화   */
              ,REFD_AMT_KRW     AS REFD_AMT   /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB'   AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,REFD_RANK_RMB    AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB     AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW'   AS RANK_TYPE /* 순위     - 전년 원화   */
              ,REFD_RANK_KRW    AS REFD_RANK /* 환불순위 -      원화   */
              ,REFD_AMT_KRW     AS REFD_AMT  /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.REFD_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(D.PRODUCT_ID)           AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.REFD_AMT                                  AS REFD_AMT_YOY_RMB  /* 전년 환불액   - 위안화 */
              ,D.REFD_AMT / Y.REFD_AMT_RMB  * 100          AS REFD_RATE_YOY_RMB /* 전년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.REFD_AMT                                  AS REFD_AMT_RMB      /* 금년 환불액   - 위안화 */
              ,B.REFD_AMT / T.REFD_AMT_RMB  * 100          AS REFD_RATE_RMB     /* 금년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(E.PRODUCT_ID)           AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.REFD_AMT                                  AS REFD_AMT_YOY_KRW  /* 전년 환불액   - 원화    */
              ,E.REFD_AMT / Y.REFD_AMT_KRW  * 100          AS REFD_RATE_YOY_KRW /* 전년 환불비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.REFD_AMT                                  AS REFD_AMT_KRW      /* 금년 환불액   - 원화    */
              ,C.REFD_AMT / T.REFD_AMT_KRW  * 100          AS REFD_RATE_KRW     /* 금년 환불비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.REFD_RANK = B.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.REFD_RANK = C.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.REFD_RANK = D.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.REFD_RANK = E.REFD_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT REFD_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_RMB  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_YOY_RMB   /* 전년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_RMB  /* 전년 환불비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_RMB      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_RMB       /* 금년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_RMB      /* 금년 환불비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_KRW  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_YOY_KRW   /* 전년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_KRW  /* 전년 환불비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_KRW      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_KRW       /* 금년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_KRW      /* 금년 환불비중 - 원화 */
      FROM WT_BASE
  ORDER BY REFD_RANK


/* refundRankingLYMoM.sql */
/* 11. 제품별 환불 정보 데이터 뷰어 - 전년동월 대비 환불 TOP 5 SQL */
/*     최종 화면에 표시할 컬럼 (등수 : REFD_RANK, 작년 제품명 : PROD_NM_YOY_RMB 또는 PROD_NM_YOY_KRW,  올해 제품명 : PROD_NM_RMB 또는 PROD_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT :BASE_MNTH  AS BASE_MNTH  /* 사용자가 선택한 월  ※ 최초 셋팅값 : 이번달 ex) '2023-02'  */
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '-01') AS DATE) - INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH
    ), WT_COPY AS
    (
        SELECT 1 AS REFD_RANK
     UNION ALL
        SELECT 2 AS REFD_RANK
     UNION ALL
        SELECT 3 AS REFD_RANK
     UNION ALL
        SELECT 4 AS REFD_RANK
     UNION ALL
        SELECT 5 AS REFD_RANK
    ), WT_TOTL AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_TOTL_YOY AS
    (
        SELECT SUM(SUCCESSFUL_REFUND_AMOUNT                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(SUCCESSFUL_REFUND_AMOUNT * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,2)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE), '%')
    ), WT_CAST_YOY AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,2)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_MNTH FROM WT_WHERE_YOY), '%')
    ), WT_EXCH AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM WT_CAST A
      GROUP BY PRODUCT_ID
    ), WT_EXCH_YOY AS
    (
        SELECT PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 YoY - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 YoY - 원화   */
          FROM WT_CAST_YOY A
      GROUP BY PRODUCT_ID
    ), WT_RANK AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
    ), WT_RANK_YOY AS
    (
        SELECT PRODUCT_ID
              ,RANK() OVER(ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,RANK() OVER(ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH_YOY A
    ), WT_BASE_RANK_RMB AS
    (
        SELECT 'RANK_RMB'      AS RANK_TYPE  /* 순위     - 금년 위안화 */
              ,REFD_RANK_RMB   AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB    AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_KRW AS
    (
        SELECT 'RANK_KRW'      AS RANK_TYPE  /* 순위     - 금년 원화   */
              ,REFD_RANK_KRW   AS REFD_RANK  /* 환불순위 -      원화   */
              ,REFD_AMT_KRW    AS REFD_AMT   /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_YOY_RMB AS
    (
        SELECT 'RANK_YOY_RMB'  AS RANK_TYPE  /* 순위     - 전년 윈안화 */
              ,REFD_RANK_RMB   AS REFD_RANK  /* 환불순위 -      위안화 */
              ,REFD_AMT_RMB    AS REFD_AMT   /* 환불금액 -      위안화 */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_YOY_KRW AS
    (
        SELECT 'RANK_YOY_KRW'  AS RANK_TYPE /* 순위     - 전년 원화   */
              ,REFD_RANK_KRW   AS REFD_RANK /* 환불순위 -      원화   */
              ,REFD_AMT_KRW    AS REFD_AMT  /* 환불금액 -      원화   */
              ,PRODUCT_ID
          FROM WT_RANK_YOY A
         WHERE REFD_RANK_KRW <= 5
    ), WT_BASE AS
    (
        SELECT A.REFD_RANK                                                      /* 순위                   */
              ,COALESCE(CAST(D.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_RMB   /* 전년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(D.PRODUCT_ID)           AS PROD_NM_YOY_RMB   /* 전년 제품명   - 위안화 */
              ,D.REFD_AMT                                  AS REFD_AMT_YOY_RMB  /* 전년 환불액   - 위안화 */
              ,D.REFD_AMT / Y.REFD_AMT_RMB  * 100          AS REFD_RATE_YOY_RMB /* 전년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(B.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_RMB       /* 금년 제품ID   - 위안화 */
              ,DASH_RAW.SF_PROD_NM(B.PRODUCT_ID)           AS PROD_NM_RMB       /* 금년 제품명   - 위안화 */
              ,B.REFD_AMT                                  AS REFD_AMT_RMB      /* 금년 환불액   - 위안화 */
              ,B.REFD_AMT / T.REFD_AMT_RMB  * 100          AS REFD_RATE_RMB     /* 금년 환불비중 - 위안화 */
    
              ,COALESCE(CAST(E.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_YOY_KRW   /* 전년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(E.PRODUCT_ID)           AS PROD_NM_YOY_KRW   /* 전년 제품명   - 원화    */
              ,E.REFD_AMT                                  AS REFD_AMT_YOY_KRW  /* 전년 환불액   - 원화    */
              ,E.REFD_AMT / Y.REFD_AMT_KRW  * 100          AS REFD_RATE_YOY_KRW /* 전년 환불비중 - 원화    */
    
              ,COALESCE(CAST(C.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_KRW       /* 금년 제품ID   - 원화    */
              ,DASH_RAW.SF_PROD_NM(C.PRODUCT_ID)           AS PROD_NM_KRW       /* 금년 제품명   - 원화    */
              ,C.REFD_AMT                                  AS REFD_AMT_KRW      /* 금년 환불액   - 원화    */
              ,C.REFD_AMT / T.REFD_AMT_KRW  * 100          AS REFD_RATE_KRW     /* 금년 환불비중 - 원화    */
          FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_RMB     B ON (A.REFD_RANK = B.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_KRW     C ON (A.REFD_RANK = C.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_RMB D ON (A.REFD_RANK = D.REFD_RANK)
                         LEFT OUTER JOIN WT_BASE_RANK_YOY_KRW E ON (A.REFD_RANK = E.REFD_RANK)
              ,WT_TOTL     T
              ,WT_TOTL_YOY Y
    )
    SELECT REFD_RANK                                                                                            /* 순위                   */
          ,PROD_ID_YOY_RMB                                                                                      /* 전년 제품ID   - 위안화 */
          ,PROD_NM_YOY_RMB                                                                                      /* 전년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_RMB  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_YOY_RMB   /* 전년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_RMB AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_RMB  /* 전년 환불비중 - 위안화 */
          ,PROD_ID_RMB                                                                                          /* 금년 제품ID   - 위안화 */
          ,PROD_NM_RMB                                                                                          /* 금년 제품명   - 위안화 */
          ,TO_CHAR(CAST(REFD_AMT_RMB      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_RMB       /* 금년 환불액   - 위안화 */
          ,TO_CHAR(CAST(REFD_RATE_RMB     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_RMB      /* 금년 환불비중 - 위안화 */

          ,PROD_ID_YOY_KRW                                                                                      /* 전년 제품ID   - 원화 */
          ,PROD_NM_YOY_KRW                                                                                      /* 전년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_YOY_KRW  AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_YOY_KRW   /* 전년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_YOY_KRW AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_YOY_KRW  /* 전년 환불비중 - 원화 */
          ,PROD_ID_KRW                                                                                          /* 금년 제품ID   - 원화 */
          ,PROD_NM_KRW                                                                                          /* 금년 제품명   - 원화 */
          ,TO_CHAR(CAST(REFD_AMT_KRW      AS DECIMAL(20,2)), 'FM999,999,999,999,990.99' ) AS REFD_AMT_KRW       /* 금년 환불액   - 원화 */
          ,TO_CHAR(CAST(REFD_RATE_KRW     AS DECIMAL(20,2)), 'FM999,999,999,999,990.99%') AS REFD_RATE_KRW      /* 금년 환불비중 - 원화 */
      FROM WT_BASE
  ORDER BY REFD_RANK


/* topRefundLastMonth.sql */
/* 11. 제품별 환불 정보 데이터 뷰어 - 전월별환불 TOP 5 SQL */
/*     최종 화면에 표시할 컬럼 (등수 : REFD_RANK, 작년 제품명 : PROD_NM_YOY_RMB 또는 PROD_NM_YOY_KRW,  올해 제품명 : PROD_NM_RMB 또는 PROD_NM_KRW */
WITH WT_WHERE AS
    (
        SELECT BASE_YEAR  /* 기준일의 연도 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_COPY AS
    (
        SELECT 1 AS REFD_RANK
     UNION ALL
        SELECT 2 AS REFD_RANK
     UNION ALL
        SELECT 3 AS REFD_RANK
     UNION ALL
        SELECT 4 AS REFD_RANK
     UNION ALL
        SELECT 5 AS REFD_RANK
    ), WT_CAST AS
    (
        SELECT PRODUCT_ID
              ,STATISTICS_DATE
              ,CAST(SUCCESSFULLY_REFUNDED_RETURN_AMOUNT AS DECIMAL(20,2)) AS REFD_AMT_RMB   /* 환불 - 위안화 */
          FROM DASH_RAW.OVER_DGT_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE LIKE CONCAT((SELECT BASE_YEAR FROM WT_WHERE), '%')
    ), WT_EXCH AS
    (
        SELECT TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM') AS RANK_MNTH
              ,PRODUCT_ID
              ,SUM(REFD_AMT_RMB                                          ) AS REFD_AMT_RMB   /* 환불 - 위안화 */
              ,SUM(REFD_AMT_RMB * DASH_RAW.SF_EXCH_KRW(A.STATISTICS_DATE)) AS REFD_AMT_KRW   /* 환불 - 원화   */
          FROM WT_CAST A
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'MM')
              ,PRODUCT_ID
    ), WT_RANK_RMB AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY REFD_AMT_RMB DESC, PRODUCT_ID) AS REFD_RANK_RMB  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB  /* 환불금액 - 위안화 */
          FROM WT_EXCH A
    ), WT_RANK_KRW AS
    (
        SELECT RANK_MNTH
              ,PRODUCT_ID
              ,RANK() OVER(PARTITION BY RANK_MNTH ORDER BY REFD_AMT_KRW DESC, PRODUCT_ID) AS REFD_RANK_KRW  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW  /* 환불금액 - 원화   */
          FROM WT_EXCH A
    ), WT_BASE_RANK_01_RMB AS
    (
        SELECT 'RANK_01_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '01'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_02_RMB AS
    (
        SELECT 'RANK_02_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '02'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_03_RMB AS
    (
        SELECT 'RANK_03_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '03'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_04_RMB AS
    (
        SELECT 'RANK_04_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '04'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_05_RMB AS
    (
        SELECT 'RANK_05_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '05'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_06_RMB AS
    (
        SELECT 'RANK_06_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '06'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_07_RMB AS
    (
        SELECT 'RANK_07_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '07'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_08_RMB AS
    (
        SELECT 'RANK_08_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '08'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_09_RMB AS
    (
        SELECT 'RANK_09_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '09'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_10_RMB AS
    (
        SELECT 'RANK_10_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '10'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_11_RMB AS
    (
        SELECT 'RANK_11_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '11'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_12_RMB AS
    (
        SELECT 'RANK_12_RMB'                     AS RANK_TYPE  /* 순위     - 위안화 */
              ,REFD_RANK_RMB                     AS REFD_RANK  /* 환불순위 - 위안화 */
              ,REFD_AMT_RMB                      AS REFD_AMT   /* 환불금액 - 위안화 */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 위안화 */
          FROM WT_RANK_RMB A
         WHERE RANK_MNTH      = '12'
           AND REFD_RANK_RMB <= 5
    ), WT_BASE_RANK_01_KRW AS
    (
        SELECT 'RANK_01_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '01'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_02_KRW AS
    (
        SELECT 'RANK_02_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '02'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_03_KRW AS
    (
        SELECT 'RANK_03_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '03'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_04_KRW AS
    (
        SELECT 'RANK_04_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '04'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_05_KRW AS
    (
        SELECT 'RANK_05_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '05'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_06_KRW AS
    (
        SELECT 'RANK_06_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '06'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_07_KRW AS
    (
        SELECT 'RANK_07_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '07'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_08_KRW AS
    (
        SELECT 'RANK_08_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '08'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_09_KRW AS
    (
        SELECT 'RANK_09_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '09'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_10_KRW AS
    (
        SELECT 'RANK_10_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '10'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_11_KRW AS
    (
        SELECT 'RANK_11_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '11'
           AND REFD_RANK_KRW <= 5
    ), WT_BASE_RANK_12_KRW AS
    (
        SELECT 'RANK_12_KRW'                     AS RANK_TYPE  /* 순위     - 원화   */
              ,REFD_RANK_KRW                     AS REFD_RANK  /* 환불순위 - 원화   */
              ,REFD_AMT_KRW                      AS REFD_AMT   /* 환불금액 - 원화   */
              ,PRODUCT_ID
              ,DASH_RAW.SF_PROD_NM(A.PRODUCT_ID) AS PROD_NM    /* 제품명   - 원화   */
          FROM WT_RANK_KRW A
         WHERE RANK_MNTH      = '12'
           AND REFD_RANK_KRW <= 5
    )
    SELECT A.REFD_RANK                                                         /* 순위                   */
          ,COALESCE(CAST(RMB_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_RMB  /* 01월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_RMB  /* 02월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_RMB  /* 03월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_RMB  /* 04월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_RMB  /* 05월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_RMB  /* 06월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_RMB  /* 07월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_RMB  /* 08월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_RMB  /* 09월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_RMB  /* 10월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_RMB  /* 11월 제품ID   - 위안화 */
          ,COALESCE(CAST(RMB_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_RMB  /* 12월 제품ID   - 위안화 */

          ,COALESCE(CAST(RMB_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01_RMB  /* 01월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02_RMB  /* 02월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03_RMB  /* 03월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04_RMB  /* 04월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05_RMB  /* 05월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06_RMB  /* 06월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07_RMB  /* 07월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08_RMB  /* 08월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09_RMB  /* 09월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10_RMB  /* 10월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11_RMB  /* 11월 제품명   - 위안화 */
          ,COALESCE(CAST(RMB_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12_RMB  /* 12월 제품명   - 위안화 */

          ,CAST(RMB_01.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_01_RMB /* 01월 제품금액 - 위안화 */
          ,CAST(RMB_02.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_02_RMB /* 02월 제품금액 - 위안화 */
          ,CAST(RMB_03.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_03_RMB /* 03월 제품금액 - 위안화 */
          ,CAST(RMB_04.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_04_RMB /* 04월 제품금액 - 위안화 */
          ,CAST(RMB_05.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_05_RMB /* 05월 제품금액 - 위안화 */
          ,CAST(RMB_06.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_06_RMB /* 06월 제품금액 - 위안화 */
          ,CAST(RMB_07.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_07_RMB /* 07월 제품금액 - 위안화 */
          ,CAST(RMB_08.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_08_RMB /* 08월 제품금액 - 위안화 */
          ,CAST(RMB_09.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_09_RMB /* 09월 제품금액 - 위안화 */
          ,CAST(RMB_10.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_10_RMB /* 10월 제품금액 - 위안화 */
          ,CAST(RMB_11.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_11_RMB /* 11월 제품금액 - 위안화 */
          ,CAST(RMB_12.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_12_RMB /* 12월 제품금액 - 위안화 */

          ,COALESCE(CAST(KRW_01.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_01_KRW  /* 01월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_02.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_02_KRW  /* 02월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_03.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_03_KRW  /* 03월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_04.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_04_KRW  /* 04월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_05.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_05_KRW  /* 05월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_06.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_06_KRW  /* 06월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_07.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_07_KRW  /* 07월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_08.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_08_KRW  /* 08월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_09.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_09_KRW  /* 09월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_10.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_10_KRW  /* 10월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_11.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_11_KRW  /* 11월 제품ID   - 원화   */
          ,COALESCE(CAST(KRW_12.PRODUCT_ID AS VARCHAR), '') AS PROD_ID_12_KRW  /* 12월 제품ID   - 원화   */

          ,COALESCE(CAST(KRW_01.PROD_NM    AS VARCHAR), '') AS PROD_NM_01_KRW  /* 01월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_02.PROD_NM    AS VARCHAR), '') AS PROD_NM_02_KRW  /* 02월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_03.PROD_NM    AS VARCHAR), '') AS PROD_NM_03_KRW  /* 03월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_04.PROD_NM    AS VARCHAR), '') AS PROD_NM_04_KRW  /* 04월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_05.PROD_NM    AS VARCHAR), '') AS PROD_NM_05_KRW  /* 05월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_06.PROD_NM    AS VARCHAR), '') AS PROD_NM_06_KRW  /* 06월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_07.PROD_NM    AS VARCHAR), '') AS PROD_NM_07_KRW  /* 07월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_08.PROD_NM    AS VARCHAR), '') AS PROD_NM_08_KRW  /* 08월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_09.PROD_NM    AS VARCHAR), '') AS PROD_NM_09_KRW  /* 09월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_10.PROD_NM    AS VARCHAR), '') AS PROD_NM_10_KRW  /* 10월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_11.PROD_NM    AS VARCHAR), '') AS PROD_NM_11_KRW  /* 11월 제품명   - 원화   */
          ,COALESCE(CAST(KRW_12.PROD_NM    AS VARCHAR), '') AS PROD_NM_12_KRW  /* 12월 제품명   - 원화   */

          ,CAST(KRW_01.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_01_KRW /* 01월 제품금액 - 원화   */
          ,CAST(KRW_02.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_02_KRW /* 02월 제품금액 - 원화   */
          ,CAST(KRW_03.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_03_KRW /* 03월 제품금액 - 원화   */
          ,CAST(KRW_04.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_04_KRW /* 04월 제품금액 - 원화   */
          ,CAST(KRW_05.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_05_KRW /* 05월 제품금액 - 원화   */
          ,CAST(KRW_06.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_06_KRW /* 06월 제품금액 - 원화   */
          ,CAST(KRW_07.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_07_KRW /* 07월 제품금액 - 원화   */
          ,CAST(KRW_08.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_08_KRW /* 08월 제품금액 - 원화   */
          ,CAST(KRW_09.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_09_KRW /* 09월 제품금액 - 원화   */
          ,CAST(KRW_10.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_10_KRW /* 10월 제품금액 - 원화   */
          ,CAST(KRW_11.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_11_KRW /* 11월 제품금액 - 원화   */
          ,CAST(KRW_12.REFD_AMT AS DECIMAL(20,2))           AS REFD_AMT_12_KRW /* 12월 제품금액 - 원화   */
      FROM WT_COPY A LEFT OUTER JOIN WT_BASE_RANK_01_RMB RMB_01 ON (A.REFD_RANK = RMB_01.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_RMB RMB_02 ON (A.REFD_RANK = RMB_02.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_RMB RMB_03 ON (A.REFD_RANK = RMB_03.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_RMB RMB_04 ON (A.REFD_RANK = RMB_04.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_RMB RMB_05 ON (A.REFD_RANK = RMB_05.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_RMB RMB_06 ON (A.REFD_RANK = RMB_06.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_RMB RMB_07 ON (A.REFD_RANK = RMB_07.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_RMB RMB_08 ON (A.REFD_RANK = RMB_08.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_RMB RMB_09 ON (A.REFD_RANK = RMB_09.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_RMB RMB_10 ON (A.REFD_RANK = RMB_10.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_RMB RMB_11 ON (A.REFD_RANK = RMB_11.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_RMB RMB_12 ON (A.REFD_RANK = RMB_12.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_01_KRW KRW_01 ON (A.REFD_RANK = KRW_01.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_02_KRW KRW_02 ON (A.REFD_RANK = KRW_02.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_03_KRW KRW_03 ON (A.REFD_RANK = KRW_03.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_04_KRW KRW_04 ON (A.REFD_RANK = KRW_04.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_05_KRW KRW_05 ON (A.REFD_RANK = KRW_05.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_06_KRW KRW_06 ON (A.REFD_RANK = KRW_06.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_07_KRW KRW_07 ON (A.REFD_RANK = KRW_07.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_08_KRW KRW_08 ON (A.REFD_RANK = KRW_08.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_09_KRW KRW_09 ON (A.REFD_RANK = KRW_09.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_10_KRW KRW_10 ON (A.REFD_RANK = KRW_10.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_11_KRW KRW_11 ON (A.REFD_RANK = KRW_11.REFD_RANK)
                     LEFT OUTER JOIN WT_BASE_RANK_12_KRW KRW_12 ON (A.REFD_RANK = KRW_12.REFD_RANK)
  ORDER BY A.REFD_RANK
