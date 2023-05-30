/* 1. 중요정보 카드 - 금액 SQL */
WITH WT_WHERE AS
    (
        SELECT SUBSTRING(MAX(DATE), 1, 4) || '-01'  AS FR_MNTH  /* 기준월 */
              ,MAX(DATE)                            AS TO_MNTH  /* 기준월 */
              ,MAX(CHANNEL)                         AS CHNL_NM    /* 채널명 */
          FROM DASH.CM_ANALYSIS
         WHERE CHANNEL = TRIM({CHNL_NM}) /* 'Tmall Global' */
           AND DATE   != 'ytd'
    ), WT_AMT AS
    (
        SELECT 1 AS JOIN_KEY
              ,SUM(REVENUE) AS REVENUE
              ,SUM(COGS   ) AS COGS   
              ,SUM(GP     ) AS GP     
              ,SUM(CM     ) AS CM     
          FROM DASH.CM_ANALYSIS
         WHERE DATE BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE) 
           AND CHANNEL    = (SELECT CHNL_NM FROM WT_WHERE)
    ), WT_AMT_YOY AS
    (
        SELECT 1 AS JOIN_KEY
              ,SUM(REVENUE) AS REVENUE
              ,SUM(COGS   ) AS COGS   
              ,SUM(GP     ) AS GP     
              ,SUM(CM     ) AS CM     
          FROM DASH.CM_ANALYSIS
         WHERE DATE BETWEEN (SELECT TO_CHAR(CAST(FR_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') FROM WT_WHERE) AND
                            (SELECT TO_CHAR(CAST(TO_MNTH||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') FROM WT_WHERE)
           AND CHANNEL =    (SELECT CHNL_NM FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.REVENUE                            AS REVN_AMT
              ,(A.REVENUE - B.REVENUE) / B.REVENUE  AS REVN_RATE
              ,A.COGS                               AS COGS_AMT
              ,(A.COGS    - B.COGS)    / B.COGS     AS COGS_RATE
              ,A.GP                                 AS GP_AMT
              ,(A.GP      - B.GP)      / B.GP       AS GP_RATE
              ,A.CM                                 AS CM_AMT
              ,(A.CM      - B.CM)      / B.CM       AS CM_RATE
              ,CASE WHEN A.REVENUE = 0 THEN 0 ELSE A.COGS / A.REVENUE END AS GOGS_REVN_RATE
              ,CASE WHEN A.REVENUE = 0 THEN 0 ELSE A.GP   / A.REVENUE END AS GP_REVN_RATE
              ,CASE WHEN A.REVENUE = 0 THEN 0 ELSE A.CM   / A.REVENUE END AS CM_REVN_RATE
          FROM WT_AMT A LEFT OUTER JOIN WT_AMT_YOY B ON (A.JOIN_KEY = B.JOIN_KEY)
    )
    SELECT COALESCE(CAST(REVN_AMT       * 1000000  AS DECIMAL(20,0)), 0) AS REVN_AMT        /* Revenue             - 금액   */
          ,COALESCE(CAST(REVN_RATE      * 100      AS DECIMAL(20,2)), 0) AS REVN_RATE       /* Revenue             - YoY    */
          ,COALESCE(CAST(COGS_AMT       * 1000000  AS DECIMAL(20,0)), 0) AS COGS_AMT        /* COGS                - 금액   */
          ,COALESCE(CAST(COGS_RATE      * 100      AS DECIMAL(20,2)), 0) AS COGS_RATE       /* COGS                - YoY    */
          ,COALESCE(CAST(GP_AMT         * 1000000  AS DECIMAL(20,0)), 0) AS GP_AMT          /* Gross Profit        - 금액   */
          ,COALESCE(CAST(GP_RATE        * 100      AS DECIMAL(20,2)), 0) AS GP_RATE         /* Gross Profit        - YoY    */
          ,COALESCE(CAST(CM_AMT         * 1000000  AS DECIMAL(20,0)), 0) AS CM_AMT          /* Contribution Margin - 금액   */
          ,COALESCE(CAST(CM_RATE        * 100      AS DECIMAL(20,2)), 0) AS CM_RATE         /* Contribution Margin - YoY    */
          ,COALESCE(CAST(GOGS_REVN_RATE * 100      AS DECIMAL(20,2)), 0) AS GOGS_REVN_RATE  /* 매출대비 COGS                */
          ,COALESCE(CAST(GP_REVN_RATE   * 100      AS DECIMAL(20,2)), 0) AS GP_REVN_RATE    /* 매출대비 Gross Profit        */
          ,COALESCE(CAST(CM_REVN_RATE   * 100      AS DECIMAL(20,2)), 0) AS CM_REVN_RATE    /* 매출대비 Contribution Margin */
      FROM WT_BASE