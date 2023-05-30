/* visitorTimeSeriesCard.sql */
/* [도우인] 2. 방문자수 시계열 그래프 - 그래프상단 정보 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(FRST_DT_YEAR    , '-', '') AS INTEGER)  AS FR_DT      /* 기준일의 1월 1일       */
              ,CAST(REPLACE(BASE_DT         , '-', '') AS INTEGER)  AS TO_DT      /* 기준일자 (어제)        */
              ,CAST(REPLACE(FRST_DT_YEAR_YOY, '-', '') AS INTEGER)  AS FR_DT_YOY  /* 기준년의 1월 1일  -1년 */
              ,CAST(REPLACE(BASE_DT_YOY     , '-', '') AS INTEGER)  AS TO_DT_YOY  /* 기준일자 (어제)   -1년 */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_SUM AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_SUM_YOY AS
    (
        SELECT SUM(PRODUCT_CLICKS_PERSON) AS VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT_YOY FROM WT_WHERE) AND (SELECT TO_DT_YOY FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.VIST_CNT AS VIST_CNT      /* 당해 방문자수  */
              ,B.VIST_CNT AS VIST_CNT_YOY  /* 전해 방문자수  */
              ,(A.VIST_CNT - COALESCE(B.VIST_CNT, 0)) / B.VIST_CNT * 100 AS VIST_RATE  /* 방문자수 증감률 */
          FROM WT_SUM     A
              ,WT_SUM_YOY B
    )
    SELECT COALESCE(CAST(VIST_CNT     AS DECIMAL(20,0)), 0) AS VIST_CNT      /* 당해 방문자수    */
          ,COALESCE(CAST(VIST_CNT_YOY AS DECIMAL(20,0)), 0) AS VIST_CNT_YOY  /* 전해 방문자수    */
          ,COALESCE(CAST(VIST_RATE    AS DECIMAL(20,2)), 0) AS VIST_RATE     /* 방문자수 증감률  */
      FROM WT_BASE