/* 7.선택한 비용 CM Trend 분석 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}                                                    AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                    AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,MAX(CHANNEL)                                                 AS CHNL_NM    /* 채널명 */
              ,{COST_ID}                                                    AS COST_ID    /* 사용자가 선택한 비용 ex) 'COGS' */
              ,          SUBSTRING(MAX(DATE), 1, 4)                         AS THIS_YEAR  /* 기준월 기준 올해 */
              ,CAST(CAST(SUBSTRING(MAX(DATE), 1, 4) AS INTEGER) -1 AS TEXT) AS LAST_YEAR  /* 기준월 기준 작년 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = TRIM({CHNL_NM}) /* 'Tmall Global' */
           AND DATE   != 'ytd'
    ), WT_COPY_MNTH AS
    (
        SELECT 1 AS SORT_KEY, LAST_YEAR AS COPY_MNTH FROM WT_WHERE
     UNION ALL
        SELECT 2 AS SORT_KEY, THIS_YEAR AS COPY_MNTH FROM WT_WHERE
     UNION ALL
        SELECT ROW_NUMBER() OVER(ORDER BY COPY_MNTH) + 2 AS SORT_KEY
              ,COPY_MNTH
         FROM (
                SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
              ) A
    ), WT_COPY AS
    (
        SELECT 1                  AS SORT_KEY
              ,'AMT'              AS L_LGND_ID  /* 금액 */ 
              ,'금액'             AS L_LGND_NM 
     UNION ALL
        SELECT 2                  AS SORT_KEY
              ,'RATE'             AS L_LGND_ID  /* CM(%) */ 
              ,'CM(%)'            AS L_LGND_NM 
    ), WT_COST AS
    (
        SELECT 1                  AS SORT_KEY
              ,'COGS'             AS COST_ID
              ,'COGS'             AS COST_NM
     UNION ALL
        SELECT 2                  AS SORT_KEY
              ,'ADVR'             AS COST_ID
              ,'광고비(영업본부)' AS COST_NM
     UNION ALL
        SELECT 3                  AS SORT_KEY
              ,'FREE'             AS COST_ID
              ,'광고비(무상지원)' AS COST_NM
     UNION ALL
        SELECT 4                  AS SORT_KEY
              ,'SALE'             AS COST_ID
              ,'판매수수료'       AS COST_NM
     UNION ALL
        SELECT 5                  AS SORT_KEY
              ,'TRNS'             AS COST_ID
              ,'물류비'           AS COST_NM
    ), WT_ANLS AS
    (
        SELECT (SELECT LAST_YEAR FROM WT_WHERE)               AS MNTH_ANLS
              ,COALESCE(SUM(REVENUE           ) /** 1000000*/, 0) AS REVN_AMT
              ,COALESCE(SUM(COGS              ) /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE(SUM("advertSales"     ) /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE(SUM("advertFree"      ) /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE(SUM("salesFee"        ) /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE(SUM("transportFee"    ) /** 1000000*/, 0) AS TRNS_AMT
              ,COALESCE(AVG("cogsPerc"        ) * 100    , 0) AS COGS_RATE
              ,COALESCE(AVG("advertSalesPerc" ) * 100    , 0) AS ADVR_RATE
              ,COALESCE(AVG("advertFreePerc"  ) * 100    , 0) AS FREE_RATE
              ,COALESCE(AVG("salesFeePerc"    ) * 100    , 0) AS SALE_RATE
              ,COALESCE(AVG("transportFeePerc") * 100    , 0) AS TRNS_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE LIKE (SELECT LAST_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT (SELECT THIS_YEAR FROM WT_WHERE)               AS MNTH_ANLS
              ,COALESCE(SUM(REVENUE           ) /** 1000000*/, 0) AS REVN_AMT
              ,COALESCE(SUM(COGS              ) /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE(SUM("advertSales"     ) /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE(SUM("advertFree"      ) /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE(SUM("salesFee"        ) /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE(SUM("transportFee"    ) /** 1000000*/, 0) AS TRNS_AMT
              ,COALESCE(AVG("cogsPerc"        ) * 100    , 0) AS COGS_RATE
              ,COALESCE(AVG("advertSalesPerc" ) * 100    , 0) AS ADVR_RATE
              ,COALESCE(AVG("advertFreePerc"  ) * 100    , 0) AS FREE_RATE
              ,COALESCE(AVG("salesFeePerc"    ) * 100    , 0) AS SALE_RATE
              ,COALESCE(AVG("transportFeePerc") * 100    , 0) AS TRNS_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE LIKE (SELECT THIS_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT DATE                                      AS MNTH_ANLS
              ,COALESCE(REVENUE            /** 1000000*/, 0) AS REVN_AMT
              ,COALESCE(COGS               /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE("advertSales"      /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE("advertFree"       /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE("salesFee"         /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE("transportFee"     /** 1000000*/, 0) AS TRNS_AMT
              ,COALESCE("cogsPerc"         * 100    , 0) AS COGS_RATE
              ,COALESCE("advertSalesPerc"  * 100    , 0) AS ADVR_RATE
              ,COALESCE("advertFreePerc"   * 100    , 0) AS FREE_RATE
              ,COALESCE("salesFeePerc"     * 100    , 0) AS SALE_RATE
              ,COALESCE("transportFeePerc" * 100    , 0) AS TRNS_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,A.SORT_KEY  AS X_DT_SORT_KEY
              ,COGS_AMT
              ,ADVR_AMT
              ,FREE_AMT
              ,SALE_AMT
              ,TRNS_AMT
              ,CASE WHEN REVN_AMT = 0 THEN 0 ELSE COGS_AMT / REVN_AMT * 100 END AS COGS_RATE
              ,CASE WHEN REVN_AMT = 0 THEN 0 ELSE ADVR_AMT / REVN_AMT * 100 END AS ADVR_RATE
              ,CASE WHEN REVN_AMT = 0 THEN 0 ELSE FREE_AMT / REVN_AMT * 100 END AS FREE_RATE
              ,CASE WHEN REVN_AMT = 0 THEN 0 ELSE SALE_AMT / REVN_AMT * 100 END AS SALE_RATE
              ,CASE WHEN REVN_AMT = 0 THEN 0 ELSE TRNS_AMT / REVN_AMT * 100 END AS TRNS_RATE
              ,(SELECT COST_ID FROM WT_WHERE)  AS COST_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.L_LGND_ID
              ,(SELECT COST_NM FROM WT_COST X WHERE X.COST_ID = B.COST_ID)||' '||A.L_LGND_NM AS L_LGND_NM
              ,B.X_DT_SORT_KEY
              ,B.X_DT
              ,CASE 
                 WHEN B.COST_ID = 'COGS' THEN CASE WHEN L_LGND_ID = 'AMT' THEN COGS_AMT ELSE COGS_RATE END
                 WHEN B.COST_ID = 'ADVR' THEN CASE WHEN L_LGND_ID = 'AMT' THEN ADVR_AMT ELSE ADVR_RATE END
                 WHEN B.COST_ID = 'FREE' THEN CASE WHEN L_LGND_ID = 'AMT' THEN FREE_AMT ELSE FREE_RATE END
                 WHEN B.COST_ID = 'SALE' THEN CASE WHEN L_LGND_ID = 'AMT' THEN SALE_AMT ELSE SALE_RATE END
                 WHEN B.COST_ID = 'TRNS' THEN CASE WHEN L_LGND_ID = 'AMT' THEN TRNS_AMT ELSE TRNS_RATE END
               END AS Y_VAL
          FROM WT_COPY A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID  /* AMT:Bar, RATE:Line */
          ,L_LGND_NM
          ,X_DT_SORT_KEY
          ,X_DT
          ,CASE WHEN L_LGND_ID = 'AMT' THEN CAST(Y_VAL AS DECIMAL(20,0)) ELSE CAST(Y_VAL AS DECIMAL(20,2)) END AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT_SORT_KEY
          ,X_DT
