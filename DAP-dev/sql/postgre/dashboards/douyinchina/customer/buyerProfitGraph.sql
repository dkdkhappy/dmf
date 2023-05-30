/* [도우인] 9. 구매자 수익 그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(REPLACE(TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(REPLACE(TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD'), '-', '') AS INTEGER) AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{FR_MNTH}                                                                                                              AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                                                              AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{CHNL_NM}                                                                                                              AS CHNL_NM    /* 채널명 ex) 'Tmall Global'       */ 
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_ANLS AS
    (
        SELECT DATE                           AS MNTH_ANLS
              ,SUM(COALESCE(CM * 1000000, 0)) AS CM_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
     GROUP BY DATE
    ), WT_PAID AS
    (
        SELECT TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_PAID
              ,SUM(COALESCE(NUMBER_OF_TRANSACTIONS, 0))                    AS PAID_CNT  /* 구매자수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_BASE AS
    (
        SELECT A.COPY_MNTH                                                  AS X_MNTH
              ,CASE WHEN C.PAID_CNT = 0 THEN 0 ELSE B.CM_AMT / PAID_CNT END AS Y_VAL
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
                              LEFT OUTER JOIN WT_PAID C ON (A.COPY_MNTH = C.MNTH_PAID)
    )
    SELECT X_MNTH
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL  /* Bar Chart */
      FROM WT_BASE
  ORDER BY X_MNTH