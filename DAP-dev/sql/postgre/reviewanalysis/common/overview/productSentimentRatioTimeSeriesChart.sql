/* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_CAST AS
    (
        SELECT REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(PROD_ID)             AS PROD_NM
              ,CAST(DATE                         AS DATE) AS X_DT
              ,CASE WHEN SENT_RATING IN (4, 5) THEN 1 END AS PSTV
              ,CASE WHEN SENT_RATING IN (3   ) THEN 1 END AS NTRL
              ,CASE WHEN SENT_RATING IN (1, 2) THEN 1 END AS NGTV
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_NM
              ,X_DT                           
              ,CAST(COUNT(*)    AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(PSTV) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(NTRL) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(NGTV) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM WT_CAST A
      GROUP BY PROD_NM
              ,X_DT
    ), WT_SUM AS
    (
        SELECT PROD_NM
              ,X_DT
              ,REVW_CNT
              ,PSTV_CNT
              ,NGTV_CNT
              ,SUM(REVW_CNT) OVER(PARTITION BY PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(PSTV_CNT) OVER(PARTITION BY PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(NGTV_CNT) OVER(PARTITION BY PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
          FROM WT_DATA_REVW A 
    ), WT_BASE AS
    (
        SELECT PROD_NM
              ,ROW_NUMBER() OVER ()             AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
              ,CASE WHEN (PSTV_CUM + NGTV_CUM) = 0 THEN 0 ELSE PSTV_CUM / (PSTV_CUM + NGTV_CUM) * 100 END AS PSTV_RATE_CUM
              ,CASE WHEN (PSTV_CUM + NGTV_CUM) = 0 THEN 0 ELSE NGTV_CUM / (PSTV_CUM + NGTV_CUM) * 100 END AS NGTV_RATE_CUM
          FROM WT_SUM A
    )
    SELECT SORT_KEY  /* 정렬순서 */
          ,PROD_NM                              AS PROD_ID   /* 제품 명  */
          ,PROD_NM   /* 제품 명  */
          ,X_DT      /* 일자    */
          ,CAST(PSTV_RATE     AS DECIMAL(20,2)) AS PSTV_RATE      /* 긍정리뷰 비율 - 시점 (라인) */
          ,CAST(NGTV_RATE     AS DECIMAL(20,2)) AS NGTV_RATE      /* 부정리뷰 비율 - 시점 (라인) */
          ,CAST(PSTV_RATE_CUM AS DECIMAL(20,2)) AS PSTV_RATE_CUM  /* 긍정리뷰 비율 - 누적 (라인) */
          ,CAST(NGTV_RATE_CUM AS DECIMAL(20,2)) AS NGTV_RATE_CUM  /* 부정리뷰 비율 - 누적 (라인) */
          ,REVW_CNT                  /* 리뷰 수 - 시점 (바) */
          ,REVW_CUM AS REVW_CNT_CUM  /* 리뷰 수 - 누적 (바) */
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT
