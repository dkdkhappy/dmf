/* 2. Contribution Margin Waterfall Chart - CM Line SQL */
WITH WT_CHNL_WHERE AS
    (
        SELECT 1                AS SORT_KEY
              ,'Tmall China'    AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'Tmall Global'   AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'Douyin China'   AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'Douyin Global'  AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ),WT_WHERE AS
    (
        SELECT {FR_MNTH}  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
    ), WT_DATA AS
    (
        SELECT COALESCE(SUM(REVENUE), 0) /** 1000000*/ AS REVN_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT (SELECT REVN_AMT FROM WT_DATA) * AVG("cmPercTarget") / 100 AS CM_TAGT
              ,AVG("cmPercTarget")                                        AS CM_RATE
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    )
    SELECT CM_TAGT
          ,CM_RATE
      FROM WT_BASE