● 중국 매출대시보드 - 2. 채널수익

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */

1. CM분석 데이터 중 이번달 Revenue에 해당하는 금액을 나타냄. (YoY)와 색상기능 필요 누적기준으로
2. GOGS에 해당하는 금액카드 YoY와 색상기능 필요
3. Gross Profit에 해당하는 금액카드 상동
4. CM에 해당하는 금액카드 상동


SELECT * 
  FROM DASH.CM_ANALYSIS
 WHERE channel  = 'Tmall Global';
 
SELECT * 
  FROM dash.cm_target 
 WHERE channel  = 'Tmall Global';
 

/* cmAnalysis.sql */
/* 0. 채널수익 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 테이블 DATE 컬럼 MAX 값임 */
/*    'Tmall Global' 는 변수 처리 필요     */
SELECT              MAX(DATE)                                                AS BASE_MNTH  /* 기준월 */
      ,TO_CHAR(CAST(MAX(DATE)||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS FR_MNTH    /* 시작월 */
      ,             MAX(DATE)                                                AS TO_MNTH    /* 종료월 */
  FROM DASH.CM_ANALYSIS
 WHERE CHANNEL = TRIM(:CHNL_NM) /* 'Tmall Global' */
   AND DATE   != 'ytd'
;


/* importantInfoCardData.sql */
/* 1. 중요정보 카드 - 금액 SQL */
/*    'Tmall Global' 는 변수 처리 필요     */
WITH WT_WHERE AS
    (
        SELECT MAX(DATE)     AS BASE_MNTH  /* 기준월 */
              ,MAX(CHANNEL)  AS CHNL_NM    /* 채널명 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = TRIM(:CHNL_NM) /* 'Tmall Global' */
           AND DATE   != 'ytd'
    ), WT_AMT AS
    (
        SELECT 1 AS JOIN_KEY
              ,REVENUE
              ,COGS
              ,GP
              ,CM
          FROM DASH.CM_ANALYSIS
         WHERE (DATE, CHANNEL) = (SELECT BASE_MNTH, CHNL_NM FROM WT_WHERE)
    ), WT_AMT_YOY AS
    (
        SELECT 1 AS JOIN_KEY
              ,REVENUE
              ,COGS
              ,GP
              ,CM
          FROM DASH.CM_ANALYSIS
         WHERE (DATE, CHANNEL) = (SELECT TO_CHAR(CAST(BASE_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM'), CHNL_NM FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.REVENUE                               AS REVN_AMT
              ,A.REVENUE - B.REVENUE / B.REVENUE * 100 AS REVN_RATE
              ,A.COGS                                  AS COGS_AMT
              ,A.COGS    - B.COGS    / B.COGS    * 100 AS COGS_RATE
              ,A.GP                                    AS GP_AMT
              ,A.GP      - B.GP      / B.GP      * 100 AS GP_RATE
              ,A.CM                                    AS CM_AMT
              ,A.CM      - B.CM      / B.CM      * 100 AS CM_RATE
          FROM WT_AMT A LEFT OUTER JOIN WT_AMT_YOY B ON (A.JOIN_KEY = B.JOIN_KEY)
    )
    SELECT COALESCE(CAST(REVN_AMT  AS DECIMAL(20,2)), 0) AS REVN_AMT    /* Revenue             - 금액 */
          ,COALESCE(CAST(REVN_RATE AS DECIMAL(20,2)), 0) AS REVN_RATE   /* Revenue             - YoY  */
          ,COALESCE(CAST(COGS_AMT  AS DECIMAL(20,2)), 0) AS COGS_AMT    /* COGS                - 금액 */
          ,COALESCE(CAST(COGS_RATE AS DECIMAL(20,2)), 0) AS COGS_RATE   /* COGS                - YoY  */
          ,COALESCE(CAST(GP_AMT    AS DECIMAL(20,2)), 0) AS GP_AMT      /* Gross Profit        - 금액 */
          ,COALESCE(CAST(GP_RATE   AS DECIMAL(20,2)), 0) AS GP_RATE     /* Gross Profit        - YoY  */
          ,COALESCE(CAST(CM_AMT    AS DECIMAL(20,2)), 0) AS CM_AMT      /* Contribution Margin - 금액 */
          ,COALESCE(CAST(CM_RATE   AS DECIMAL(20,2)), 0) AS CM_RATE     /* Contribution Margin - YoY  */
      FROM WT_BASE


/* importantInfoCardChart.sql */
/* 1. 중요정보 카드 - Chart SQL */
WITH WT_WHERE AS
    (
        SELECT MAX(DATE)     AS BASE_MNTH  /* 기준월 */
              ,MAX(CHANNEL)  AS CHNL_NM    /* 채널명 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = TRIM(:CHNL_NM) /* 'Tmall Global' */
           AND DATE   != 'ytd'
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(BASE_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH  /* 기준월 -1년 */
          FROM WT_WHERE
    ), WT_BASE AS
    (
        SELECT 'REVN'  AS CHRT_KEY
              ,DATE    AS X_DT
              ,REVENUE AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'COGS'  AS CHRT_KEY
              ,DATE    AS X_DT
              ,COGS    AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'GP'    AS CHRT_KEY
              ,DATE    AS X_DT
              ,GP      AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'CM'    AS CHRT_KEY
              ,DATE    AS X_DT
              ,CM      AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
    )
    SELECT CHRT_KEY
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,2)), 0) AS Y_VAL
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT


5. Contribution Margin Waterfall Chart
   * 분석기간 선택시, 해당기간동안 누적 워터폴 그래프로 나타님. 이 중 채널목표 CM(%)에 따른 금액 기준 --- 선으로 표기

/* waterFallChart.sql */
/* 5. Contribution Margin Waterfall Chart - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM  AS CHNL_NM    /* 채널명 ex) 'Tmall Global' */ 
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
        SELECT CAST(CAST(REVN_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS REVN_AMT  
              ,CAST(CAST(COGS_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS COGS_AMT
              ,CAST(CAST(ADVR_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS ADVR_AMT
              ,CAST(CAST(FREE_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS FREE_AMT
              ,CAST(CAST(SALE_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS SALE_AMT
              ,CAST(CAST(TRNS_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS TRNS_AMT
              ,CAST(CAST(REVN_AMT                                                        AS DECIMAL(20,2)) AS TEXT) AS REVN_ALL
              ,CAST(CAST(REVN_AMT - COGS_AMT                                             AS DECIMAL(20,2)) AS TEXT) AS COGS_ALL
              ,CAST(CAST(REVN_AMT - COGS_AMT - ADVR_AMT                                  AS DECIMAL(20,2)) AS TEXT) AS ADVR_ALL
              ,CAST(CAST(REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT                       AS DECIMAL(20,2)) AS TEXT) AS FREE_ALL
              ,CAST(CAST(REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT            AS DECIMAL(20,2)) AS TEXT) AS SALE_ALL
              ,CAST(CAST(REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT - TRNS_AMT AS DECIMAL(20,2)) AS TEXT) AS TRNS_ALL
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
          ,VAL_1||', '||VAL_2||', '||VAL_3||', '||VAL_4||', '||VAL_5||', '||VAL_6  AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY


/* waterFallChartCmLine.sql */
/* 5. Contribution Margin Waterfall Chart - CM Line SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM  AS CHNL_NM    /* 채널명 ex) 'Tmall Global' */ 
    ), WT_BASE AS
    (
        SELECT AVG("cmPercTarget") AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    )
    SELECT CM_TAGT
      FROM WT_BASE


6. Contribution Margin 월별 트렌드 분석
   * Y축 두개 그래프, 왼쪽은 금액, 오른쪽은 CM %로 나타내고 X축은 월별 마지막은 YTD(해당연도 종합) 표기, 목표 CM(%)선을 오른쪽 Y그래프에 맞춰서 표기

/* cmTrendAnalysis.sql */
/* 6. Contribution Margin 월별 트렌드 분석 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM  AS CHNL_NM    /* 채널명 ex) 'Tmall Global' */ 
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_COPY AS
    (
        SELECT 1              AS SORT_KEY
              ,'CM_AMT'       AS L_LGND_ID  /* CM 금액 */ 
              ,'CM 금액'      AS L_LGND_NM 
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'CM_RATE'      AS L_LGND_ID  /* CM %    */ 
              ,'CM %'         AS L_LGND_NM 
     UNION ALL
        SELECT 3              AS SORT_KEY
              ,'CM_TAGT'      AS L_LGND_ID  /* 목표 CM(%) */ 
              ,'목표 CM(%)'   AS L_LGND_NM 
    ), WT_TAGT AS
    (
        SELECT YM             AS MNTH_TAGT
              ,"cmPercTarget" AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_ANLS AS
    (
        SELECT DATE     AS MNTH_ANLS
              ,CM       AS CM_AMT
              ,"cmPerc" AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,B.CM_AMT
              ,B.CM_RATE
              ,C.CM_TAGT
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
                              LEFT OUTER JOIN WT_TAGT C ON (A.COPY_MNTH = C.MNTH_TAGT)
     UNION ALL 
        SELECT 'YTD Total' AS X_DT
              ,SUM(A.CM_AMT) AS CM_AMT
              ,NULL AS CM_RATE
              ,NULL AS CM_TAGT
          FROM WT_ANLS A LEFT OUTER JOIN WT_TAGT B ON (A.MNTH_ANLS = B.MNTH_TAGT)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.L_LGND_ID
              ,A.L_LGND_NM
              ,B.X_DT AS X_DT
              ,CASE 
                 WHEN A.L_LGND_ID = 'CM_AMT'
                 THEN B.CM_AMT
                 WHEN A.L_LGND_ID = 'CM_RATE'
                 THEN B.CM_RATE
                 WHEN A.L_LGND_ID = 'CM_TAGT'
                 THEN B.CM_TAGT
               END AS Y_VAL
          FROM WT_COPY A,
               WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  /* CM 금액:Bar, CM %:Line, 목표 CM(%):Line ※ 점선 */
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT


7. 비용 항목 별 월별 트렌드 분석
   * 비용선택 dropdown이 필요하고, 선택한 비용에 대한 바그래프로 쭉 나오고, 마지막은 YTD Total 그리고 선그래프는 매출 대비 비중으로 오른쪽 Y로 사용

/* selectedCostCmTrendAnalysis.sql */
/* 7.비용 항목 별 월별 트렌드 분석 - 비용 선택 SQL */
WITH WT_BASE AS
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
    )
    SELECT SORT_KEY
          ,COST_ID
          ,COST_NM
      FROM WT_BASE
  ORDER BY SORT_KEY

/* selectedCostCmTrendAnalysisChart.sql */
/* 7.비용 항목 별 월별 트렌드 분석 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM  AS CHNL_NM    /* 채널명 ex) 'Tmall Global'       */ 
              ,:COST_ID  AS COST_ID    /* 사용자가 선택한 비용 ex) 'COGS' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_COPY AS
    (
        SELECT 1              AS SORT_KEY
              ,'AMT'          AS L_LGND_ID  /* 금액 */ 
              ,'금액'         AS L_LGND_NM 
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'RATE'         AS L_LGND_ID  /* CM(%) */ 
              ,'CM(%)'        AS L_LGND_NM 
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
        SELECT DATE                            AS MNTH_ANLS
              ,COALESCE(COGS              , 0) AS COGS_AMT
              ,COALESCE("advertSales"     , 0) AS ADVR_AMT
              ,COALESCE("advertFree"      , 0) AS FREE_AMT
              ,COALESCE("salesFee"        , 0) AS SALE_AMT
              ,COALESCE("transportFee"    , 0) AS TRNS_AMT
              ,COALESCE("cogsPerc"        , 0) AS COGS_RATE
              ,COALESCE("advertSalesPerc" , 0) AS ADVR_RATE
              ,COALESCE("advertFreePerc"  , 0) AS FREE_RATE
              ,COALESCE("salesFeePerc"    , 0) AS SALE_RATE
              ,COALESCE("transportFeePerc", 0) AS TRNS_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,COGS_AMT
              ,ADVR_AMT
              ,FREE_AMT
              ,SALE_AMT
              ,TRNS_AMT
              ,COGS_RATE
              ,ADVR_RATE
              ,FREE_RATE
              ,SALE_RATE
              ,TRNS_RATE
              ,(SELECT COST_ID FROM WT_WHERE)  AS COST_ID
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.L_LGND_ID
              ,(SELECT COST_NM FROM WT_COST X WHERE X.COST_ID = B.COST_ID)||' '||A.L_LGND_NM AS L_LGND_NM
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
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT


8. 비용항목 Breakdown
   * 비용항목에 대해 Stack바 그래프로 나타나야함. 100%버튼이라는게 필요하고 이걸 누르면 금액기준이 아닌 100%기준 Stack 바 그래프가 나와야함.

/* costItemBreakdown.sql */
/* 8. 비용항목 Breakdown - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHNL_NM   AS CHNL_NM    /* 채널명 ex) 'Tmall Global'       */ 
              ,:CHRT_TYPE AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
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
        SELECT DATE                            AS MNTH_ANLS
              ,COALESCE(COGS              , 0) AS COGS_AMT
              ,COALESCE("advertSales"     , 0) AS ADVR_AMT
              ,COALESCE("advertFree"      , 0) AS FREE_AMT
              ,COALESCE("salesFee"        , 0) AS SALE_AMT
              ,COALESCE("transportFee"    , 0) AS TRNS_AMT              
              ,COALESCE(COGS              , 0) +
               COALESCE("advertSales"     , 0) +
               COALESCE("advertFree"      , 0) +
               COALESCE("salesFee"        , 0) +
               COALESCE("transportFee"    , 0) AS COST_AMT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
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
              ,CASE 
                 WHEN A.COST_ID = 'COGS' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN COGS_AMT ELSE COGS_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'ADVR' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN ADVR_AMT ELSE ADVR_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'FREE' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN FREE_AMT ELSE FREE_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'SALE' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN SALE_AMT ELSE SALE_AMT / COST_AMT * 100 END
                 WHEN A.COST_ID = 'TRNS' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN TRNS_AMT ELSE TRNS_AMT / COST_AMT * 100 END
               END AS Y_VAL
          FROM WT_COST A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
