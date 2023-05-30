/* 1. 중요정보 카드 - Chart SQL */
WITH WT_WHERE AS
    (
        SELECT MAX(DATE)     AS BASE_MNTH  /* 기준월 */
              ,MAX(CHANNEL)  AS CHNL_NM    /* 채널명 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = TRIM({CHNL_NM}) /* 'Tmall Global' */
           AND DATE   != 'ytd'
    ), WT_WHERE_YOY AS
    (
        SELECT TO_CHAR(CAST(BASE_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS BASE_MNTH  /* 기준월 -1년 */
          FROM WT_WHERE
    ), WT_BASE AS
    (
        SELECT 'REVN'              AS CHRT_KEY
              ,DATE                AS X_DT
              ,REVENUE  * 1000000  AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'COGS'              AS CHRT_KEY
              ,DATE                AS X_DT
              ,COGS    * 1000000   AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'GP'                AS CHRT_KEY
              ,DATE                AS X_DT
              ,GP      * 1000000   AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
     UNION ALL
        SELECT 'CM'                AS CHRT_KEY
              ,DATE                AS X_DT
              ,CM      * 1000000   AS Y_VAL
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL    = (SELECT CHNL_NM   FROM WT_WHERE)
           AND DATE BETWEEN (SELECT BASE_MNTH FROM WT_WHERE_YOY) AND (SELECT BASE_MNTH FROM WT_WHERE)
    )
    SELECT CHRT_KEY
          ,X_DT
          ,COALESCE(CAST(Y_VAL AS DECIMAL(20,0)), 0) AS Y_VAL
      FROM WT_BASE
  ORDER BY CHRT_KEY
          ,X_DT