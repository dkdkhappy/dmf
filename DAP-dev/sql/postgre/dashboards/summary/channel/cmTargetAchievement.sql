/* 6. CM 목표 및 달성 여부 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
    ), WT_CHNL AS
    (
        SELECT 0                AS SORT_KEY
              ,'Total'          AS CHNL_ID
              ,'전체'           AS CHNL_NM
     UNION ALL
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
    ), WT_TAGT AS
    (
        SELECT CHANNEL                                                                                         AS CHNL_ID
              ,SUM("cmTarget")                                                                       * 1000000 AS CM_TAGT_AMT
              ,CASE WHEN SUM("revenueTarget") = 0 THEN 0 ELSE SUM("cmTarget") / SUM("revenueTarget") * 100 END AS CM_TAGT_RATE
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL WHERE SORT_KEY > 0)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY CHANNEL
     UNION ALL
        SELECT 'Total'                                                                                         AS CHNL_ID
              ,SUM("cmTarget")                                                                       * 1000000 AS CM_TAGT_AMT
              ,CASE WHEN SUM("revenueTarget") = 0 THEN 0 ELSE SUM("cmTarget") / SUM("revenueTarget") * 100 END AS CM_TAGT_RATE
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL WHERE SORT_KEY > 0)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_ANLS AS
    (
        SELECT CHANNEL                                                                     AS CHNL_ID
              ,SUM(CM)                                                           * 1000000 AS CM_AMT
              ,CASE WHEN SUM("revenue") = 0 THEN 0 ELSE SUM(CM) / SUM("revenue") * 100 END AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY CHANNEL
     UNION ALL
        SELECT 'Total'                                                                     AS CHNL_ID
              ,SUM(CM)                                                           * 1000000 AS CM_AMT
              ,CASE WHEN SUM("revenue") = 0 THEN 0 ELSE SUM(CM) / SUM("revenue") * 100 END AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL WHERE SORT_KEY > 0)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID                      AS CHNL_ID
              ,A.CHNL_NM                      AS CHNL_NM
              ,B.CM_TAGT_AMT                  AS CM_TAGT_AMT
              ,B.CM_TAGT_RATE                 AS CM_TAGT_RATE
              ,C.CM_AMT                       AS CM_CUM_AMT
              ,C.CM_RATE                      AS CM_CUM_RATE
              ,C.CM_AMT - B.CM_TAGT_AMT       AS CM_CALC_AMT
              ,C.CM_AMT / B.CM_TAGT_AMT * 100 AS CM_CALC_RATE
          FROM WT_CHNL A LEFT OUTER JOIN WT_TAGT B ON (A.CHNL_ID = B.CHNL_ID)
                         LEFT OUTER JOIN WT_ANLS C ON (A.CHNL_ID = C.CHNL_ID)
    )
    SELECT SORT_KEY
          ,CHNL_ID
          ,CHNL_NM
          ,TO_CHAR(CASE WHEN CM_TAGT_AMT  = 0 THEN NULL ELSE CM_TAGT_AMT  END, 'FM999,999,999,999,990'    ) AS CM_TAGT_AMT
          ,TO_CHAR(CASE WHEN CM_TAGT_RATE = 0 THEN NULL ELSE CM_TAGT_RATE END, 'FM999,999,999,999,990.00%') AS CM_TAGT_RATE
          ,TO_CHAR(CASE WHEN CM_CUM_AMT   = 0 THEN NULL ELSE CM_CUM_AMT   END, 'FM999,999,999,999,990'    ) AS CM_CUM_AMT
          ,TO_CHAR(CASE WHEN CM_CUM_RATE  = 0 THEN NULL ELSE CM_CUM_RATE  END, 'FM999,999,999,999,990.00%') AS CM_CUM_RATE
          ,TO_CHAR(CASE WHEN CM_CALC_AMT  = 0 THEN NULL ELSE CM_CALC_AMT  END, 'FM999,999,999,999,990'    ) AS CM_CALC_AMT
          ,TO_CHAR(CASE WHEN CM_CALC_RATE = 0 THEN NULL ELSE CM_CALC_RATE END, 'FM999,999,999,999,990.00%') AS CM_CALC_RATE
          ,CASE WHEN CM_CALC_AMT >= CM_TAGT_AMT THEN '달성' ELSE '미달성' END                               AS CM_CALC_TXT
      FROM WT_BASE
  ORDER BY SORT_KEY