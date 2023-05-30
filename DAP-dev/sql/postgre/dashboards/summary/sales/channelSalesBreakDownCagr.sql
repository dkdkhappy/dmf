/* 7. 채널별 매출 비중 Break Down - CAGR SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_MNTH}||'-01' AS DATE)                              AS FR_MNTH_FR_DT   /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST({FR_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS FR_MNTH_TO_DT   /* 사용자가 선택한 월 - 시작월 기준 말일 ex) '2023-02-28' */
              ,CAST({TO_MNTH}||'-01' AS DATE)                              AS TO_MNTH_FR_DT   /* 사용자가 선택한 월 - 종료월 기준  1일 ex) '2023-03-01' */
              ,CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' AS TO_MNTH_TO_DT   /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-03-31' */              
    ), WT_MNTH_DIFF AS
    (
        SELECT EXTRACT(MONTH FROM AGE((SELECT TO_MNTH_TO_DT FROM WT_WHERE), (SELECT FR_MNTH_FR_DT FROM WT_WHERE))) AS MNTH_DIFF
    ), WT_FR_AMT AS
    (
        SELECT SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_rmb'
                     THEN VALUE
                   END) AS FR_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_krw'
                     THEN VALUE
                   END) AS FR_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_MNTH_FR_DT FROM WT_WHERE) AND (SELECT FR_MNTH_TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('sale_amt_rmb', 'sale_amt_krw')
    ), WT_TO_AMT AS
    (
        SELECT SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_rmb'
                     THEN VALUE
                   END) AS TO_AMT_RMB
              ,SUM(CASE
                     WHEN CHRT_KEY = 'sale_amt_krw'
                     THEN VALUE
                   END) AS TO_AMT_KRW
          FROM DASH.SUM_SALETIMESERIESALLDATA
         WHERE STATISTICS_DATE BETWEEN (SELECT TO_MNTH_FR_DT FROM WT_WHERE) AND (SELECT TO_MNTH_TO_DT FROM WT_WHERE)
           AND CHRT_KEY IN ('sale_amt_rmb', 'sale_amt_krw')
    ), WT_BASE AS
    (
        SELECT (((SELECT TO_AMT_RMB::DECIMAL FROM WT_TO_AMT) / (SELECT FR_AMT_RMB::DECIMAL FROM WT_FR_AMT)) ^ (1::DECIMAL / (SELECT MNTH_DIFF::DECIMAL FROM WT_MNTH_DIFF)) -1::DECIMAL) * 100 AS CAGR_AMT_RMB
              ,(((SELECT TO_AMT_KRW::DECIMAL FROM WT_TO_AMT) / (SELECT FR_AMT_KRW::DECIMAL FROM WT_FR_AMT)) ^ (1::DECIMAL / (SELECT MNTH_DIFF::DECIMAL FROM WT_MNTH_DIFF)) -1::DECIMAL) * 100 AS CAGR_AMT_KRW
          FROM WT_FR_AMT    A
              ,WT_TO_AMT    B
              ,WT_MNTH_DIFF C
    )
    SELECT CAST(CAGR_AMT_RMB AS DECIMAL(20,2)) AS CAGR_AMT_RMB
          ,CAST(CAGR_AMT_KRW AS DECIMAL(20,2)) AS CAGR_AMT_KRW
      FROM WT_BASE