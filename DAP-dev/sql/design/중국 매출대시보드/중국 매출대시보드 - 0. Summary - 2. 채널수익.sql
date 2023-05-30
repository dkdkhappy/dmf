● 중국 매출대시보드 - 0. Summary - 2. 채널수익

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * 대시보드 중 CM분석의 Summary page

/* cmAnalysis.sql */
/* 0. 채널수익 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 테이블 DATE 컬럼 MAX 값임 */
SELECT              MAX(DATE)                                                AS BASE_MNTH  /* 기준월 */
      ,TO_CHAR(CAST(MAX(DATE)||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS FR_MNTH    /* 시작월 */
      ,             MAX(DATE)                                                AS TO_MNTH    /* 종료월 */
  FROM DASH.CM_ANALYSIS
 WHERE CHANNEL IN ('Tmall China', 'Tmall Global', 'Douyin China', 'Douyin Global')
   AND DATE   != 'ytd'
;


1. 중요정보 카드
    * 카드 정보로. CM의 기초적인 Revenue, COGS, Gross profit, Contribution Margin이 나와야함.

/* 1. 중요정보 카드 - 금액 SQL */
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
        SELECT MAX(DATE) AS BASE_MNTH  /* 기준월 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE    != 'ytd'
    ), WT_AMT AS
    (
        SELECT 1 AS JOIN_KEY
              ,SUM(REVENUE) AS REVENUE
              ,SUM(COGS   ) AS COGS
              ,SUM(GP     ) AS GP
              ,SUM(CM     ) AS CM
          FROM DASH.CM_ANALYSIS
         WHERE DATE     = (SELECT BASE_MNTH FROM WT_WHERE)
           AND CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
    ), WT_AMT_YOY AS
    (
        SELECT 1 AS JOIN_KEY
              ,SUM(REVENUE) AS REVENUE
              ,SUM(COGS   ) AS COGS
              ,SUM(GP     ) AS GP
              ,SUM(CM     ) AS CM
          FROM DASH.CM_ANALYSIS
         WHERE DATE     = (SELECT TO_CHAR(CAST(BASE_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') FROM WT_WHERE)
           AND CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
    ), WT_BASE AS
    (
        SELECT A.REVENUE                            AS REVN_AMT
              ,(A.REVENUE - B.REVENUE) / B.REVENUE  AS REVN_RATE
              ,A.COGS                               AS COGS_AMT
              ,(A.COGS    - B.COGS   ) / B.COGS     AS COGS_RATE
              ,A.GP                                 AS GP_AMT
              ,(A.GP      - B.GP     ) / B.GP       AS GP_RATE
              ,A.CM                                 AS CM_AMT
              ,(A.CM      - B.CM     ) / B.CM       AS CM_RATE
          FROM WT_AMT A LEFT OUTER JOIN WT_AMT_YOY B ON (A.JOIN_KEY = B.JOIN_KEY)
    )
    SELECT COALESCE(CAST(REVN_AMT  * 1000000  AS DECIMAL(20,2)), 0) AS REVN_AMT    /* Revenue             - 금액 */
          ,COALESCE(CAST(REVN_RATE * 100           AS DECIMAL(20,2)), 0) AS REVN_RATE   /* Revenue             - YoY  */
          ,COALESCE(CAST(COGS_AMT  * 1000000  AS DECIMAL(20,2)), 0) AS COGS_AMT    /* COGS                - 금액 */
          ,COALESCE(CAST(COGS_RATE * 100           AS DECIMAL(20,2)), 0) AS COGS_RATE   /* COGS                - YoY  */
          ,COALESCE(CAST(GP_AMT    * 1000000  AS DECIMAL(20,2)), 0) AS GP_AMT      /* Gross Profit        - 금액 */
          ,COALESCE(CAST(GP_RATE   * 100           AS DECIMAL(20,2)), 0) AS GP_RATE     /* Gross Profit        - YoY  */
          ,COALESCE(CAST(CM_AMT    * 1000000  AS DECIMAL(20,2)), 0) AS CM_AMT      /* Contribution Margin - 금액 */
          ,COALESCE(CAST(CM_RATE   * 100           AS DECIMAL(20,2)), 0) AS CM_RATE     /* Contribution Margin - YoY  */
      FROM WT_BASE
;

/* 1. 중요정보 카드 - Chart SQL */
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
        SELECT MAX(DATE) AS BASE_MNTH  /* 기준월 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE    != 'ytd'
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(BASE_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH  /* 기준월 -1년 */
          FROM WT_WHERE
    ), WT_BASE AS
    (
        SELECT 'REVN'       AS CHRT_KEY
              ,DATE         AS X_DT
              ,SUM(REVENUE) AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID   FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
      GROUP BY DATE
     UNION ALL
        SELECT 'COGS'       AS CHRT_KEY
              ,DATE         AS X_DT
              ,SUM(COGS)    AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID   FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
      GROUP BY DATE
     UNION ALL
        SELECT 'GP'         AS CHRT_KEY
              ,DATE         AS X_DT
              ,SUM(GP)      AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID   FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
      GROUP BY DATE
     UNION ALL
        SELECT 'CM'         AS CHRT_KEY
              ,DATE         AS X_DT
              ,SUM(CM)      AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID   FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
      GROUP BY DATE
    )
    SELECT CHRT_KEY
          ,X_DT
          ,COALESCE(CAST(Y_VAL * 1000000 AS DECIMAL(20,2)), 0) AS Y_VAL
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT
;

2. Contribution Margin Waterfall Chart
    * 분석기간을 설정하면, 해당 기간(월별임)동안 누적으로 waterfall그래프를 그려야함. 이때, 채널목표가 아래에 나와야함.

/* 2. Contribution Margin Waterfall Chart - 그래프 SQL */
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
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
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
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_CALC AS
    (
        SELECT CAST(CAST((REVN_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS REVN_AMT
              ,CAST(CAST((COGS_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS COGS_AMT
              ,CAST(CAST((ADVR_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS ADVR_AMT
              ,CAST(CAST((FREE_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS FREE_AMT
              ,CAST(CAST((SALE_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS SALE_AMT
              ,CAST(CAST((TRNS_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS TRNS_AMT
              ,CAST(CAST((REVN_AMT                                                       ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS REVN_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT                                            ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS COGS_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT                                 ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS ADVR_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT                      ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS FREE_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT           ) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS SALE_ALL
              ,CAST(CAST((REVN_AMT - COGS_AMT - ADVR_AMT - FREE_AMT - SALE_AMT - TRNS_AMT) * 1000000 AS DECIMAL(20,2)) AS TEXT) AS TRNS_ALL
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
              ,CASE WHEN COST_NM = '전체' THEN TRNS_ALL WHEN COST_NM = '수익' THEN '''-'''  WHEN COST_NM = '비용' THEN TRNS_ALL END AS VAL_7
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
;

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
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
    ), WT_DATA AS
    (
        SELECT COALESCE(SUM(REVENUE), 0) * 1000000 AS REVN_AMT
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
;

3. CM 그래프 시계열
    * 바그래프와 선그래프가 나오고, 12달 + 총 누적한개 포함 해야함.
    * 바그래프는 CM금액이 되고, 붉은색 선은 CM (%) 그리고 파란색은 목표 CM이 될것

/* 3. CM 그래프 시계열 - 시계열 그래프 SQL */
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
        SELECT :FR_MNTH  AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH  AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
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
        SELECT YM                  AS MNTH_TAGT
              ,AVG("cmPercTarget") AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY YM
    ), WT_ANLS AS
    (
        SELECT DATE          AS MNTH_ANLS
              ,SUM(CM)       AS CM_AMT
              ,AVG("cmPerc") AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,B.CM_AMT
              ,B.CM_RATE
              ,C.CM_TAGT
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
                              LEFT OUTER JOIN WT_TAGT C ON (A.COPY_MNTH = C.MNTH_TAGT)
     UNION ALL 
        SELECT 'YTD' AS X_DT
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
                 THEN B.CM_AMT * 1000000 
                 WHEN A.L_LGND_ID = 'CM_RATE'
                 THEN B.CM_RATE * 100
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
;

4. 채널별 CM Break Down
    * 채널별 CM을 나누어서 볼 수 있는 지표, 하단에 x축은 월별 지표이고, 스택그래프로 4개의 채널(Douyin Global, China, Tmall Global, China)의 값이 나타나야함.
    * 버튼을 누르면 100% 비중으로 stack bar그래프로 변환되어야함

/* 4. 채널별 CM Break Down - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:CHRT_TYPE AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
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
    ), WT_ANLS AS
    (
        SELECT DATE                                                                        AS MNTH_ANLS
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall China'   THEN CM END), 0) * 1000000 AS DCT_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Tmall Global'  THEN CM END), 0) * 1000000 AS DGT_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin China'  THEN CM END), 0) * 1000000 AS DCD_CM_AMT
              ,COALESCE(SUM(CASE WHEN CHANNEL = 'Douyin Global' THEN CM END), 0) * 1000000 AS DGD_CM_AMT
              ,COALESCE(SUM(CM                                             ), 0) * 1000000 AS CHNL_AMT
              ,(SELECT CHRT_TYPE FROM WT_WHERE)                                            AS CHRT_TYPE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCT_CM_AMT
              ,DGT_CM_AMT
              ,DCD_CM_AMT
              ,DGD_CM_AMT
              ,CHNL_AMT
              ,CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
     UNION ALL
        SELECT 'YTD Total' AS X_DT
              ,SUM(DCT_CM_AMT) AS DCT_CM_AMT
              ,SUM(DGT_CM_AMT) AS DGT_CM_AMT
              ,SUM(DCD_CM_AMT) AS DCD_CM_AMT
              ,SUM(DGD_CM_AMT) AS DGD_CM_AMT
              ,SUM(CHNL_AMT  ) AS CHNL_AMT
              ,MAX(CHRT_TYPE ) AS CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'Tmall China'   THEN CASE WHEN CHRT_TYPE = 'AMT' THEN DCT_CM_AMT ELSE DCT_CM_AMT / CHNL_AMT * 100 END
                 WHEN A.CHNL_ID = 'Tmall Global'  THEN CASE WHEN CHRT_TYPE = 'AMT' THEN DGT_CM_AMT ELSE DGT_CM_AMT / CHNL_AMT * 100 END
                 WHEN A.CHNL_ID = 'Douyin China'  THEN CASE WHEN CHRT_TYPE = 'AMT' THEN DCD_CM_AMT ELSE DCD_CM_AMT / CHNL_AMT * 100 END
                 WHEN A.CHNL_ID = 'Douyin Global' THEN CASE WHEN CHRT_TYPE = 'AMT' THEN DGD_CM_AMT ELSE DGD_CM_AMT / CHNL_AMT * 100 END
               END AS Y_VAL
              ,CASE
                 WHEN A.CHNL_ID = 'Tmall China'   THEN DCT_CM_AMT 
                 WHEN A.CHNL_ID = 'Tmall Global'  THEN DGT_CM_AMT 
                 WHEN A.CHNL_ID = 'Douyin China'  THEN DCD_CM_AMT 
                 WHEN A.CHNL_ID = 'Douyin Global' THEN DGD_CM_AMT 
               END AS CM_AMT
              ,CHRT_TYPE
          FROM WT_CHNL A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM  
          ,X_DT
          ,CAST(CASE WHEN CHRT_TYPE = 'RATE' AND SUM(CM_AMT) OVER(PARTITION BY X_DT) < 0 THEN Y_VAL * -1 ELSE Y_VAL END AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT
;

5. 채널별 CM % 추이
    * 채널별 CM의 %가 어떻계 변화하고 있는지 월별로 볼 수 있는 선 그래프가 필요함

/* 5. 채널별 CM % 추이 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
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
    ), WT_ANLS AS
    (
        SELECT DATE                                                             AS MNTH_ANLS
              ,AVG(CASE WHEN CHANNEL = 'Tmall China'   THEN "cmPerc" END) * 100 AS DCT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Tmall Global'  THEN "cmPerc" END) * 100 AS DGT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin China'  THEN "cmPerc" END) * 100 AS DCD_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin Global' THEN "cmPerc" END) * 100 AS DGD_CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCT_CM_RATE
              ,DGT_CM_RATE
              ,DCD_CM_RATE
              ,DGD_CM_RATE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'Tmall China'   THEN DCT_CM_RATE
                 WHEN A.CHNL_ID = 'Tmall Global'  THEN DGT_CM_RATE
                 WHEN A.CHNL_ID = 'Douyin China'  THEN DCD_CM_RATE
                 WHEN A.CHNL_ID = 'Douyin Global' THEN DGD_CM_RATE
               END AS Y_VAL
          FROM WT_CHNL A
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
;

6. CM 목표 및 달성 여부
    * 해당 사항은 레이를 뷰어로 각 채널의 목표 CM이랑, 누적 실적 그리고 달성여부 (누적 - 목표) 로 보여주면 됨

/* 6. CM 목표 및 달성 여부 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT :FR_MNTH   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,:TO_MNTH   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
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
          ,TO_CHAR(CASE WHEN CM_TAGT_AMT  = 0 THEN NULL ELSE CM_TAGT_AMT  END, 'FM999,999,999,999,990.00' ) AS CM_TAGT_AMT
          ,TO_CHAR(CASE WHEN CM_TAGT_RATE = 0 THEN NULL ELSE CM_TAGT_RATE END, 'FM999,999,999,999,990.00%') AS CM_TAGT_RATE
          ,TO_CHAR(CASE WHEN CM_CUM_AMT   = 0 THEN NULL ELSE CM_CUM_AMT   END, 'FM999,999,999,999,990.00' ) AS CM_CUM_AMT
          ,TO_CHAR(CASE WHEN CM_CUM_RATE  = 0 THEN NULL ELSE CM_CUM_RATE  END, 'FM999,999,999,999,990.00%') AS CM_CUM_RATE
          ,TO_CHAR(CASE WHEN CM_CALC_AMT  = 0 THEN NULL ELSE CM_CALC_AMT  END, 'FM999,999,999,999,990.00' ) AS CM_CALC_AMT
          ,TO_CHAR(CASE WHEN CM_CALC_RATE = 0 THEN NULL ELSE CM_CALC_RATE END, 'FM999,999,999,999,990.00%') AS CM_CALC_RATE
      FROM WT_BASE
  ORDER BY SORT_KEY
;
