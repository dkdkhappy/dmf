/* 1. 중요정보 카드 - 방문자수/객단가/평균체류시간 Chart SQL */
WITH WT_WHERE AS
    (
        SELECT BASE_DT           /* 기준일자 (어제)        */
              ,TO_CHAR(CAST(BASE_DT AS DATE)  - INTERVAL '1' MONTH , 'YYYY-MM-DD') AS BASE_DT_MOM  /* 기준일자 (어제)   -1월 */
              ,FRST_DT_MNTH      /* 기준월의 1일           */
              ,FRST_DT_YEAR      /* 기준년의 1월 1일       */
          FROM DASH.DASH_INITIAL_DATE
    ), WT_VIST_DAY AS
    (
        SELECT 'DAY'                    AS CHRT_KEY
              ,STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 일방문자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT BASE_DT_MOM FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_MNTH AS
    (
        SELECT 'MNTH'                   AS CHRT_KEY
              ,STATISTICS_DATE          AS X_DT
              ,SUM(NUMBER_OF_VISITORS)  AS VIST_CNT  /* 월방문자수 */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_MNTH FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY STATISTICS_DATE
    ), WT_VIST_YEAR AS
    (
        SELECT 'YEAR'                                             AS CHRT_KEY
              ,TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')  AS X_DT
              ,SUM(NUMBER_OF_VISITORS)                            AS VIST_CNT  /* 연방문자수   */
          FROM DASH_RAW.OVER_{TAG}_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FRST_DT_YEAR FROM WT_WHERE) AND (SELECT BASE_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(STATISTICS_DATE AS DATE), 'YYYY-MM')
    ), WT_BASE AS
    (
        SELECT A.CHRT_KEY                /* DAY:전일 방문자 수 */
              ,A.X_DT                    /* 일자(x축)          */
              ,A.VIST_CNT AS Y_VAL_VIST  /* 방문자 수          */
          FROM WT_VIST_DAY A
     UNION ALL
        SELECT B.CHRT_KEY                /* MNTH:당일 방문자 수 */
              ,B.X_DT                    /* 일자(x축)           */
              ,B.VIST_CNT AS Y_VAL_VIST  /* 방문자 수           */
          FROM WT_VIST_MNTH B
     UNION ALL
        SELECT C.CHRT_KEY                /* YEAR:당일 방문자 수 */
              ,C.X_DT                    /* 일자(x축)           */
              ,C.VIST_CNT AS Y_VAL_VIST  /* 방문자 수           */
          FROM WT_VIST_YEAR C
    )
    SELECT CHRT_KEY                                                      /* DAY:전일 방문자 수, MNTH:당일 방문자 수, YEAR:당일 방문자 수 */
          ,X_DT                                                          /* 일자(x축) */
          ,COALESCE(CAST(Y_VAL_VIST AS DECIMAL(20,0)), 0) AS Y_VAL_VIST  /* 방문자 수 */
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT
