/* 5. Contribution Margin Waterfall Chart - CM Line SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{CHNL_NM}  AS CHNL_NM    /* 채널명 ex) 'Tmall Global' */ 
    ), WT_DATA AS
    (
        SELECT COALESCE(SUM(REVENUE), 0) /** 1000000*/ AS REVN_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT (SELECT REVN_AMT FROM WT_DATA) * AVG("cmPercTarget") / 100 AS CM_TAGT
              ,AVG("cmPercTarget")                                        AS CM_RATE
          FROM DASH.CM_TARGET
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    )
    SELECT CAST(CM_TAGT AS DECIMAL(20,0)) AS CM_TAGT
          ,CAST(CM_RATE AS DECIMAL(20,2)) AS CM_RATE
      FROM WT_BASE