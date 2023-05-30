/* 5. 채널별 CM % 추이 - 그래프 SQL */
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
    ), WT_WHERE AS
    (
        SELECT {FR_MNTH}   AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}   AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{CHRT_TYPE} AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'AMT' 또는 'RATE' */
              ,          SUBSTRING(MAX(DATE), 1, 4)                         AS THIS_YEAR  /* 기준월 기준 올해 */
              ,CAST(CAST(SUBSTRING(MAX(DATE), 1, 4) AS INTEGER) -1 AS TEXT) AS LAST_YEAR  /* 기준월 기준 작년 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE    != 'ytd'
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
    ), WT_ANLS AS
    (
        SELECT (SELECT LAST_YEAR FROM WT_WHERE)                                 AS MNTH_ANLS
              ,AVG(CASE WHEN CHANNEL = 'Tmall China'   THEN "cmPerc" END) * 100 AS DCT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Tmall Global'  THEN "cmPerc" END) * 100 AS DGT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin China'  THEN "cmPerc" END) * 100 AS DCD_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin Global' THEN "cmPerc" END) * 100 AS DGD_CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE  LIKE (SELECT LAST_YEAR FROM WT_WHERE)||'%'
      GROUP BY DATE
     UNION ALL
        SELECT (SELECT THIS_YEAR FROM WT_WHERE)                                 AS MNTH_ANLS
              ,AVG(CASE WHEN CHANNEL = 'Tmall China'   THEN "cmPerc" END) * 100 AS DCT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Tmall Global'  THEN "cmPerc" END) * 100 AS DGT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin China'  THEN "cmPerc" END) * 100 AS DCD_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin Global' THEN "cmPerc" END) * 100 AS DGD_CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE  LIKE (SELECT THIS_YEAR FROM WT_WHERE)||'%'
      GROUP BY DATE
     UNION ALL
        SELECT DATE                                                             AS MNTH_ANLS
              ,AVG(CASE WHEN CHANNEL = 'Tmall China'   THEN "cmPerc" END) * 100 AS DCT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Tmall Global'  THEN "cmPerc" END) * 100 AS DGT_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin China'  THEN "cmPerc" END) * 100 AS DCD_CM_RATE
              ,AVG(CASE WHEN CHANNEL = 'Douyin Global' THEN "cmPerc" END) * 100 AS DGD_CM_RATE
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL   IN (SELECT CHNL_ID FROM WT_CHNL_WHERE)
           AND DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY DATE
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,A.SORT_KEY  AS X_DT_SORT_KEY
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
              ,B.X_DT_SORT_KEY
              ,CASE 
                 WHEN A.CHNL_ID = 'Tmall China'   THEN DCT_CM_RATE
                 WHEN A.CHNL_ID = 'Tmall Global'  THEN DGT_CM_RATE
                 WHEN A.CHNL_ID = 'Douyin China'  THEN DCD_CM_RATE
                 WHEN A.CHNL_ID = 'Douyin Global' THEN DGD_CM_RATE
               END AS Y_VAL
          FROM WT_CHNL_WHERE A
              ,WT_DATA B
    )
    SELECT SORT_KEY
          ,L_LGND_ID
          ,L_LGND_NM
          ,X_DT_SORT_KEY
          ,X_DT
          ,CAST(Y_VAL AS DECIMAL(20,2)) AS Y_VAL
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,X_DT_SORT_KEY
          ,X_DT