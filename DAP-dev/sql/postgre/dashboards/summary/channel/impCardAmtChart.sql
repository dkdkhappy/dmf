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
          ,COALESCE(CAST(Y_VAL * 1000000 AS DECIMAL(20,0)), 0) AS Y_VAL
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT