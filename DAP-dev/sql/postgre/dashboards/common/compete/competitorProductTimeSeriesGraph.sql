/* 7. 경쟁제품 시계열 그래프 - 시계열그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{PROD_NM}                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_DATA AS
    (
        SELECT TO_CHAR(CAST(DATE AS DATE), 'YYYY-MM') AS CMPT_MNTH
              ,COMPETE_ID                             AS CMPT_ID
              ,KOR_NAME                               AS CMPT_NM
              ,SUM(TRADE_INDEX)                       AS TRDE_IDX
          FROM DASH.{TAG}_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY TO_CHAR(CAST(DATE AS DATE), 'YYYY-MM')
              ,COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT CMPT_MNTH
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,ROW_NUMBER() OVER(PARTITION BY CMPT_MNTH ORDER BY TRDE_IDX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_SUM AS
    (
        SELECT CMPT_MNTH
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END AS CMPT_RANK
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END AS CMPT_ID
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END AS CMPT_NM
              ,SUM(TRDE_IDX)                                                         AS TRDE_IDX
          FROM WT_RANK A
      GROUP BY CMPT_MNTH
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END
    ), WT_BASE AS
    (
        SELECT CMPT_MNTH
              ,CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,TRDE_IDX / SUM(TRDE_IDX) OVER(PARTITION BY CMPT_MNTH) * 100 AS TRDE_RATE
          FROM WT_SUM A
    )
    SELECT CMPT_MNTH                                      /* 기준월        */
          ,CMPT_RANK                                      /* 경쟁제품 순위 */
          ,CMPT_ID                                        /* 경쟁제품 ID   */
          ,SUBSTRING(CMPT_NM, 1, 30) AS CMPT_NM           /* 경쟁제품 명   */
          ,TRDE_IDX                                       /* 거래지수      */
          ,CAST(TRDE_RATE AS DECIMAL(20,2)) AS TRDE_RATE  /* 거래지수 비율 */
      FROM WT_BASE
  ORDER BY CMPT_MNTH
          ,CMPT_RANK COLLATE "ko_KR.utf8"