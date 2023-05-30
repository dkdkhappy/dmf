/* 5. Contribution Margin Waterfall Chart - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{CHNL_NM}  AS CHNL_NM    /* 채널명 ex) 'Tmall Global' */ 
    ), WT_COPY AS
    (
        SELECT 1       AS SORT_KEY
              ,'전체'  AS COST_NM
     UNION ALL
        SELECT 2       AS SORT_KEY
              ,'수익'  AS COST_NM
     UNION ALL
        SELECT 3       AS SORT_KEY
              ,'비용'  AS COST_NM
    ), WT_DATA AS
    (
        SELECT COALESCE(SUM(REVENUE       ), 0) AS REVN_AMT
              ,COALESCE(SUM(COGS          ), 0) AS COGS_AMT
              ,COALESCE(SUM("advertSales" ), 0) AS ADVR_AMT
              ,COALESCE(SUM("advertFree"  ), 0) AS FREE_AMT
              ,COALESCE(SUM("salesFee"    ), 0) AS SALE_AMT
              ,COALESCE(SUM("transportFee"), 0) AS TRNS_AMT
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_CALC AS
    (
        SELECT CAST(CAST((REVN_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS REVN_AMT
              ,CAST(CAST((COGS_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS COGS_AMT
              ,CAST(CAST((ADVR_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS ADVR_AMT
              ,CAST(CAST((FREE_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS FREE_AMT
              ,CAST(CAST((SALE_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS SALE_AMT
              ,CAST(CAST((TRNS_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS TRNS_AMT
              ,CAST(CAST((REVN_AMT                                                       ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS REVN_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT                                            ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS COGS_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT                                 ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS ADVR_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT                      ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS FREE_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT           ) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS SALE_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT - TRNS_AMT) /** 1000000*/ AS DECIMAL(20,0)) AS TEXT) AS TRNS_ALL
          FROM WT_DATA
    ), WT_BASE AS
    (
        SELECT SORT_KEY 
              ,COST_NM
              ,REVN_AMT 
              ,COGS_AMT
              ,ADVR_AMT
              ,FREE_AMT
              ,SALE_AMT
              ,TRNS_AMT
              ,REVN_ALL
              ,COGS_ALL
              ,ADVR_ALL
              ,FREE_ALL
              ,SALE_ALL
              ,TRNS_ALL
              ,CASE WHEN COST_NM = '전체' THEN '0'      WHEN COST_NM = '수익' THEN REVN_ALL WHEN COST_NM = '비용' THEN '''-'''  END AS VAL_1
              ,CASE WHEN COST_NM = '전체' THEN COGS_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN COGS_AMT END AS VAL_2
              ,CASE WHEN COST_NM = '전체' THEN ADVR_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN ADVR_AMT END AS VAL_3
              ,CASE WHEN COST_NM = '전체' THEN FREE_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN FREE_AMT END AS VAL_4
              ,CASE WHEN COST_NM = '전체' THEN SALE_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN SALE_AMT END AS VAL_5
              ,CASE WHEN COST_NM = '전체' THEN TRNS_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN TRNS_AMT END AS VAL_6
              ,CASE
                 WHEN COST_NM = '전체' 
                 THEN TRNS_ALL 
                 WHEN COST_NM = '수익' 
                 THEN CASE WHEN CAST(TRNS_ALL AS DECIMAL) > 0 THEN '''-'''  ELSE TRNS_ALL END
                 WHEN COST_NM = '비용' 
                 THEN CASE WHEN CAST(TRNS_ALL AS DECIMAL) > 0 THEN TRNS_ALL ELSE '''-'''  END
               END AS VAL_7
          FROM WT_COPY A
              ,WT_CALC B
    )
    SELECT SORT_KEY
          ,COST_NM
          ,REVN_AMT
          ,COGS_AMT
          ,ADVR_AMT
          ,FREE_AMT
          ,SALE_AMT
          ,TRNS_AMT
          ,REVN_ALL
          ,COGS_ALL
          ,ADVR_ALL
          ,FREE_ALL
          ,SALE_ALL
          ,TRNS_ALL
          ,VAL_1||', '||VAL_2||', '||VAL_3||', '||VAL_4||', '||VAL_5||', '||VAL_6||', '||VAL_7  AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY