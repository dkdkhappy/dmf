/* 8. 경쟁제품 등수변화 - 평행그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{FR_MNTH}                                                                           AS FR_MNTH    /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                                                                           AS TO_MNTH    /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{PROD_NM}                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_COPY_MNTH AS
    (
        SELECT TO_CHAR(GENERATE_SERIES((SELECT CAST(FR_MNTH||'-01' AS DATE) FROM WT_WHERE), (SELECT CAST(TO_MNTH||'-01' AS DATE) FROM WT_WHERE), '1 MONTH'), 'YYYY-MM') AS COPY_MNTH
    ), WT_DATA_AMT AS
    (
        SELECT BASE_TIME
              ,PROD_ID
              ,SUM(CAST(SALE_AMT AS DECIMAL(20,0))) AS SALE_AMT
          FROM DASH.TMALL_ITEM_RANK_DATA
         WHERE BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
      GROUP BY BASE_TIME
              ,PROD_ID
    ), WT_AMT_RANK AS
    (
        SELECT BASE_TIME AS AMT_MNTH
              ,PROD_ID   AS PROD_ID
              ,SALE_AMT  AS SALE_AMT
              ,ROW_NUMBER() OVER(PARTITION BY BASE_TIME ORDER BY SALE_AMT DESC, PROD_ID) AS AMT_RANK
          FROM WT_DATA_AMT
    ), WT_DATA AS
    (
        SELECT OWN_PROD_NAME     AS PROD_NM
              ,COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.{TAG}_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY OWN_PROD_NAME
              ,COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT PROD_NM
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,CMPT_MNTH_MAX
              ,ROW_NUMBER() OVER(PARTITION BY PROD_NM ORDER BY TRDE_IDX DESC, CMPT_MNTH_MAX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_RANK_MNTH AS
    (
        SELECT A.COPY_MNTH
              ,B.PROD_NM
              ,B.CMPT_ID
              ,B.CMPT_NM
              ,B.TRDE_IDX
              ,B.CMPT_RANK
          FROM WT_COPY_MNTH A
              ,WT_RANK      B
        WHERE B.CMPT_RANK <= 5
    ), WT_RANK_AMT_JOIN AS
    (
        SELECT A.PROD_NM
              ,A.CMPT_ID
              ,A.CMPT_NM
              ,A.TRDE_IDX
              ,A.CMPT_RANK
              ,A.COPY_MNTH
              ,COALESCE(CAST(B.AMT_RANK AS TEXT), '') AS AMT_RANK
          FROM WT_RANK_MNTH A LEFT OUTER JOIN WT_AMT_RANK B ON (A.COPY_MNTH = B.AMT_MNTH AND A.CMPT_ID = B.PROD_ID)
    ), WT_BASE AS 
    (
        SELECT CMPT_RANK
              ,CMPT_NM
              ,ARRAY_TO_STRING(ARRAY_AGG(COPY_MNTH ORDER BY COPY_MNTH),',') AS AMT_MNTH_LIST
              ,ARRAY_TO_STRING(ARRAY_AGG(AMT_RANK  ORDER BY COPY_MNTH),',') AS AMT_RANK_LIST
          FROM WT_RANK_AMT_JOIN
      GROUP BY CMPT_RANK
              ,CMPT_NM
    )
    SELECT CMPT_RANK                                                                  /* 경쟁제품 지수 등수 */
          ,SUBSTRING(CMPT_NM, 1, 15)                                   AS P_CATE_VAL  /* 경쟁제품 명        */
          ,AMT_RANK_LIST || ',''' || SUBSTRING(CMPT_NM, 1, 15) || '''' AS S_DATA      /* 경쟁제품 AMT 등수  */
      FROM WT_BASE
  ORDER BY CMPT_RANK