/* 8. 비용항목 Breakdown - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}                                                    AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                    AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,MAX(CHANNEL)                                                 AS CHNL_NM    /* 채널명 */
              ,{CHRT_TYPE}                                                  AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
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
        SELECT (SELECT LAST_YEAR FROM WT_WHERE)           AS MNTH_ANLS
              ,COALESCE(SUM(COGS          ) /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE(SUM("advertSales" ) /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE(SUM("advertFree"  ) /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE(SUM("salesFee"    ) /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE(SUM("transportFee") /** 1000000*/, 0) AS TRNS_AMT              
              ,COALESCE(SUM(COGS          ) /** 1000000*/, 0) +
               COALESCE(SUM("advertSales" ) /** 1000000*/, 0) +
               COALESCE(SUM("advertFree"  ) /** 1000000*/, 0) +
               COALESCE(SUM("salesFee"    ) /** 1000000*/, 0) +
               COALESCE(SUM("transportFee") /** 1000000*/, 0) AS COST_AMT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE LIKE (SELECT LAST_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT (SELECT THIS_YEAR FROM WT_WHERE)           AS MNTH_ANLS
              ,COALESCE(SUM(COGS          ) /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE(SUM("advertSales" ) /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE(SUM("advertFree"  ) /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE(SUM("salesFee"    ) /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE(SUM("transportFee") /** 1000000*/, 0) AS TRNS_AMT              
              ,COALESCE(SUM(COGS          ) /** 1000000*/, 0) +
               COALESCE(SUM("advertSales" ) /** 1000000*/, 0) +
               COALESCE(SUM("advertFree"  ) /** 1000000*/, 0) +
               COALESCE(SUM("salesFee"    ) /** 1000000*/, 0) +
               COALESCE(SUM("transportFee") /** 1000000*/, 0) AS COST_AMT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE LIKE (SELECT THIS_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT DATE                                  AS MNTH_ANLS
              ,COALESCE(COGS           /** 1000000*/, 0) AS COGS_AMT
              ,COALESCE("advertSales"  /** 1000000*/, 0) AS ADVR_AMT
              ,COALESCE("advertFree"   /** 1000000*/, 0) AS FREE_AMT
              ,COALESCE("salesFee"     /** 1000000*/, 0) AS SALE_AMT
              ,COALESCE("transportFee" /** 1000000*/, 0) AS TRNS_AMT              
              ,COALESCE(COGS           /** 1000000*/, 0) +
               COALESCE("advertSales"  /** 1000000*/, 0) +
               COALESCE("advertFree"   /** 1000000*/, 0) +
               COALESCE("salesFee"     /** 1000000*/, 0) +
               COALESCE("transportFee" /** 1000000*/, 0) AS COST_AMT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
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
              ,COST_AMT 
              ,CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.COST_ID   AS L_LGND_ID
              ,A.COST_NM   AS L_LGND_NM
              ,B.X_DT
              ,B.X_DT_SORT_KEY
              ,CASE 
                 WHEN A.COST_ID = 'COGS' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN COGS_AMT ELSE COGS_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'ADVR' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN ADVR_AMT ELSE ADVR_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'FREE' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN FREE_AMT ELSE FREE_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'SALE' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN SALE_AMT ELSE SALE_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'TRNS' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN TRNS_AMT ELSE TRNS_AMT / COST_AMT * 100 END
               END AS Y_VAL
              ,CHRT_TYPE
          FROM WT_COST A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT_SORT_KEY
          ,X_DT
          ,CASE WHEN CHRT_TYPE = 'AMT' THEN CAST(Y_VAL AS DECIMAL(20,0)) ELSE CAST(Y_VAL AS DECIMAL(20,2)) END AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT_SORT_KEY
          ,X_DT
