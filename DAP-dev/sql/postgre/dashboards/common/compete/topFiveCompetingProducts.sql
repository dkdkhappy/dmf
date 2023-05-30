/* 9. 경쟁 제품 TOP 5 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,{PROD_NM}                                                                           AS PROD_NM    /* 사용자가 선택한 제품명 ex) 'M4 토너 에멀전 세트'       */
    ), WT_DATA AS
    (
        SELECT COMPETE_ID        AS CMPT_ID
              ,KOR_NAME          AS CMPT_NM
              ,SUM(TRADE_INDEX)  AS TRDE_IDX
              ,MAX(DATE)         AS CMPT_MNTH_MAX
          FROM DASH.{TAG}_COMP_COMPETE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
      GROUP BY COMPETE_ID
              ,KOR_NAME
    ), WT_RANK AS
    (
        SELECT CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,CMPT_MNTH_MAX
              ,ROW_NUMBER() OVER(ORDER BY TRDE_IDX DESC, CMPT_MNTH_MAX DESC, CMPT_ID) AS CMPT_RANK
          FROM WT_DATA A
    ), WT_BASE AS
    (
        SELECT CMPT_RANK
              ,CMPT_ID
              ,CMPT_NM
              ,TRDE_IDX
              ,(SELECT MAX(ITEM_PIC)
                  FROM DASH.{TAG}_COMP_COMPETE X
                 WHERE X.COMPETE_ID    = A.CMPT_ID
                   AND X.DATE          = A.CMPT_MNTH_MAX
                   AND X.OWN_PROD_NAME = (SELECT PROD_NM FROM WT_WHERE)
               ) AS PROD_IMG
          FROM WT_RANK A
         WHERE CMPT_RANK <= 5
    )
    SELECT CMPT_RANK                                               /* 등수          */
          ,CMPT_ID                                                 /* 제품ID        */
          ,SUBSTRING(CMPT_NM, 1, 30)                  AS CMPT_NM   /* 제품명        */
          ,TO_CHAR(TRDE_IDX, 'FM999,999,999,999,990') AS TRDE_IDX  /* 누적 거래지수 */
          ,PROD_IMG                                                /* 제품 이미지   */
      FROM WT_BASE
  ORDER BY CMPT_RANK
  