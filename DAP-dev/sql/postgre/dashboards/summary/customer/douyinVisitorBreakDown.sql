/* 4. Douyin 방문자 수 Break Down - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYYMMDD') AS INTEGER) AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,CAST(TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYYMMDD') AS INTEGER) AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{FR_MNTH}                                                                                          AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                                          AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({CHRT_TYPE}, 'RATE')                                                                      AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'CNT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_DCD AS
    (
        SELECT 'DCD'                                                       AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_DCD
              ,SUM(PRODUCT_CLICKS_PERSON)                                  AS DCD_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DGD AS
    (
        SELECT 'DGD'                                                       AS CHNL_ID
              ,TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM') AS MNTH_DGD
              ,SUM(PRODUCT_CLICKS_PERSON)                                  AS DGD_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGD_TRANSACTION_OVERVIEW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(CAST(DATE AS TEXT), 'YYYYMMDD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCD_VIST_CNT
              ,DGD_VIST_CNT
              ,DCD_VIST_CNT + DGD_VIST_CNT AS CHNL_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCD B ON (A.COPY_MNTH = B.MNTH_DCD)
                              LEFT OUTER JOIN WT_DGD C ON (A.COPY_MNTH = C.MNTH_DGD)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCD' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DCD_VIST_CNT ELSE DCD_VIST_CNT / CHNL_CNT * 100 END
                 WHEN A.CHNL_ID = 'DGD' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DGD_VIST_CNT ELSE DGD_VIST_CNT / CHNL_CNT * 100 END
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