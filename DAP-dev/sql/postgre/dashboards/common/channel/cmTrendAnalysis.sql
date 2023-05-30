/* 6. CM Trend 분석 - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}                                                    AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                    AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,MAX(CHANNEL)                                                 AS CHNL_NM    /* 채널명 */
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
        SELECT (SELECT LAST_YEAR FROM WT_WHERE)  AS MNTH_TAGT
              ,SUM("cmPercTarget")               AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM   LIKE (SELECT LAST_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT (SELECT THIS_YEAR FROM WT_WHERE)  AS MNTH_TAGT
              ,SUM("cmPercTarget")               AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM   LIKE (SELECT THIS_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT YM             AS MNTH_TAGT
              ,"cmPercTarget" AS CM_TAGT
          FROM DASH.CM_TARGET
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND YM BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_ANLS AS
    (
        SELECT (SELECT LAST_YEAR FROM WT_WHERE)  AS MNTH_ANLS
              ,SUM(CM)                           AS CM_AMT
              ,AVG("cmPerc")                     AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE LIKE (SELECT LAST_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT (SELECT THIS_YEAR FROM WT_WHERE)  AS MNTH_ANLS
              ,SUM(CM)                           AS CM_AMT
              ,AVG("cmPerc")                     AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE LIKE (SELECT THIS_YEAR FROM WT_WHERE)||'%'
     UNION ALL
        SELECT DATE     AS MNTH_ANLS
              ,CM       AS CM_AMT
              ,"cmPerc" AS CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,A.SORT_KEY  AS X_DT_SORT_KEY
              ,B.CM_AMT
              ,B.CM_RATE
              ,C.CM_TAGT
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_ANLS B ON (A.COPY_MNTH = B.MNTH_ANLS)
                              LEFT OUTER JOIN WT_TAGT C ON (A.COPY_MNTH = C.MNTH_TAGT)
--      UNION ALL 
--         SELECT 'YTD Total'   AS X_DT
--               ,9999          AS X_DT_SORT_KEY
--               ,SUM(A.CM_AMT) AS CM_AMT
--               ,NULL AS CM_RATE
--               ,NULL AS CM_TAGT
--           FROM WT_ANLS A LEFT OUTER JOIN WT_TAGT B ON (A.MNTH_ANLS = B.MNTH_TAGT)
--          WHERE MNTH_TAGT = (SELECT THIS_YEAR FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.L_LGND_ID
              ,A.L_LGND_NM
              ,B.X_DT
              ,B.X_DT_SORT_KEY
              ,CASE 
                 WHEN A.L_LGND_ID = 'CM_AMT'
                 THEN B.CM_AMT  --* 1000000 
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
          ,X_DT_SORT_KEY
          ,X_DT
          ,CASE WHEN L_LGND_ID = 'CM_AMT' THEN CAST(Y_VAL AS DECIMAL(20,0)) ELSE CAST(Y_VAL AS DECIMAL(20,2)) END AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT_SORT_KEY
          ,X_DT
