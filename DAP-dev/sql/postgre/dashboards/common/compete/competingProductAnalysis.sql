/* 4. 경쟁제품분석 - Stack Bar Chart SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_NM)        AS PROD_NM
          FROM REGEXP_SPLIT_TO_TABLE({PROD_NM}, '★') AS PROD_NM  /* 입력된 제품명을 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) 'M4 토너 에멀전 세트, 더마펌 모이스트베리어워터선밀크 M4 본품 50ml 공통' */
    ), WT_DATA AS
    (
        SELECT OWN_PROD_NAME     AS PROD_NM
              ,COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.{TAG}_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME IN (SELECT PROD_NM FROM WT_PROD_WHERE)
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
    ), WT_SUM AS
    (
        SELECT PROD_NM
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END AS CMPT_RANK
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END AS CMPT_ID
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END AS CMPT_NM
              ,SUM(TRDE_IDX)                                                         AS TRDE_IDX
          FROM WT_RANK A
      GROUP BY PROD_NM
              ,CASE WHEN CMPT_RANK <= 5 THEN CAST(CMPT_RANK AS TEXT) ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_ID                 ELSE '기타' END
              ,CASE WHEN CMPT_RANK <= 5 THEN CMPT_NM                 ELSE '기타' END
    ), WT_BASE AS
    (
        SELECT (SELECT SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_NM = A.PROD_NM) AS SORT_KEY
              ,A.PROD_NM
              ,CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,TRDE_IDX / SUM(TRDE_IDX) OVER(PARTITION BY A.PROD_NM) * 100 AS TRDE_RATE
          FROM WT_PROD_WHERE A LEFT OUTER JOIN WT_SUM B ON (A.PROD_NM = B.PROD_NM)
    )
    SELECT SORT_KEY                                        /* 정렬순서      */
          ,SUBSTRING(PROD_NM, 1, 30) AS PROD_NM            /* 자사 제품명   */
          ,CMPT_RANK                                       /* 경쟁제품 순위 */
          ,CMPT_ID                                         /* 경쟁제품 ID   */
          ,SUBSTRING(CMPT_NM, 1, 30) AS CMPT_NM            /* 경쟁제품 명   */
          ,TRDE_IDX                                        /* 거래지수      */
          ,CAST(TRDE_RATE AS DECIMAL(20,2)) AS TRDE_RATE   /* 거래지수 비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY
          ,CMPT_RANK COLLATE "ko_KR.utf8"