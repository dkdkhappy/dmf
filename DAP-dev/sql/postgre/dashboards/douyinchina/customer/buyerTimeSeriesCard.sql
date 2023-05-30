/* buyerTimeSeriesCard.sql */
/* [도우인] 6. 구매자 수 시계열 그래프 - 그래프상단 정보 SQL */
/*    당해   누적금액 : 오늘(2023.03.04)일 경우 => 2023.01.01 ~ 2023.03.03 */
/*    전년도 누적금액 : 오늘(2023.03.04)일 경우 => 2022.01.01 ~ 2022.03.03 */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR    , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(REPLACE(BASE_DT         , '-', '') AS INTEGER)  AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY, '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(REPLACE(BASE_DT_YOY     , '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SUM AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(NUMBER_OF_TRANSACTIONS) AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.PAID_CNT AS PAID_CNT      /* 당해 구매자수  */
              ,B.PAID_CNT AS PAID_CNT_YOY  /* 전해 구매자수  */
              ,(A.PAID_CNT - COALESCE(B.PAID_CNT, 0)) / B.PAID_CNT * 100 AS PAID_RATE  /* 구매자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(PAID_CNT     AS DECIMAL(20,0)), 0) AS PAID_CNT      /* 당해 구매자수    */
          ,COALESCE(CAST(PAID_CNT_YOY AS DECIMAL(20,0)), 0) AS PAID_CNT_YOY  /* 전해 구매자수    */
          ,COALESCE(CAST(PAID_RATE    AS DECIMAL(20,2)), 0) AS PAID_RATE     /* 구매자수 증감률  */
      FROM WT_BASE