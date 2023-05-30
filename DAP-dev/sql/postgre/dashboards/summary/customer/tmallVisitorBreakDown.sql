/* 2. Tmall 방문자 수 Break Down - 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{FR_MNTH}                                                                           AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                           AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({CHRT_TYPE}, 'RATE')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'CNT' 또는 'RATE' */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
    ), WT_DCT AS
    (
        SELECT 'DCT'                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM') AS MNTH_DCT
              ,SUM(PRODUCT_VISITORS)                                      AS DCT_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DCT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DGT AS
    (
        SELECT 'DGT'                                                      AS CHNL_ID
              ,TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM') AS MNTH_DGT
              ,SUM(PRODUCT_VISITORS)                                      AS DGT_VIST_CNT  /* 방문자수 */
          FROM DASH_RAW.OVER_DGT_OVERALL_STORE A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY TO_CHAR(TO_DATE(STATISTICS_DATE, 'YYYY-MM-DD'), 'YYYY-MM')
    ), WT_DATA AS
    (
        SELECT A.COPY_MNTH AS X_DT
              ,DCT_VIST_CNT
              ,DGT_VIST_CNT
              ,DCT_VIST_CNT + DGT_VIST_CNT AS CHNL_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM WT_COPY_MNTH A LEFT OUTER JOIN WT_DCT B ON (A.COPY_MNTH = B.MNTH_DCT)
                              LEFT OUTER JOIN WT_DGT C ON (A.COPY_MNTH = C.MNTH_DGT)
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID   AS L_LGND_ID
              ,A.CHNL_NM   AS L_LGND_NM
              ,B.X_DT
              ,CASE 
                 WHEN A.CHNL_ID = 'DCT' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DCT_VIST_CNT ELSE DCT_VIST_CNT / CHNL_CNT * 100 END
                 WHEN A.CHNL_ID = 'DGT' THEN CASE WHEN CHRT_TYPE = 'CNT' THEN DGT_VIST_CNT ELSE DGT_VIST_CNT / CHNL_CNT * 100 END
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