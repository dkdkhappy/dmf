/* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */
/*    조회기간 : 오늘기준 전전달 vs 전달 Data를 비교          */
/*    ex) 오늘(2023-03-01)의 경우 2023-01 vs. 2023-02         */
/*    ※ 변화비율이 양수인 값만 나오는 것이 맞지 않을까?                                             */
/*    ※ 리뷰수가 일정 수 이상인 데이터만 대상으로 계산할 필요가 있어보임. (모든 긍/부정 비율은...)  */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' MONTH)                              AS DATE) AS FR_DT      /* 오늘기준 -1개월  1일 ex) '2023-02-01' */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT      /* 오늘기준 -1개월 말일 ex) '2023-02-28' */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '2' MONTH)                              AS DATE) AS FR_DT_MOM  /* 오늘기준 -2개월  1일 ex) '2023-01-01' */
              ,CAST(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '2' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT_MOM  /* 오늘기준 -2개월 말일 ex) '2023-01-31' */
              ,{CATE_NM}              AS CATE_NM  /* 카테고리명 하나를 입력 또는 전체, 자사제품을 입력한다. ex) '스킨' */ 
    ), WT_COPY AS
    (
        SELECT 1 AS REVW_RANK
     UNION ALL
        SELECT 2 AS REVW_RANK
     UNION ALL
        SELECT 3 AS REVW_RANK
     UNION ALL
        SELECT 4 AS REVW_RANK
     UNION ALL
        SELECT 5 AS REVW_RANK
    ), WT_CATE_SPLT_ORG AS 
    (
        SELECT DISTINCT
               ID                                         AS PROD_ID
              ,TRIM(REGEXP_SPLIT_TO_TABLE(CATEGORY, '/')) AS CATE_NM
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
    ), WT_CATE_SPLT_RE AS 
    (
        SELECT DISTINCT
               PROD_ID
              ,TRIM(REGEXP_SPLIT_TO_TABLE(CATE_NM, ',')) AS CATE_NM
          FROM WT_CATE_SPLT_ORG
         WHERE TRIM(CATE_NM) != '' 
    ), WT_CATE_SPLT AS 
    (
        SELECT CATE_NM
              ,PROD_ID
          FROM WT_CATE_SPLT_RE A
         WHERE ((SELECT CATE_NM FROM WT_WHERE) != '자사제품' AND CATE_NM = CASE WHEN (SELECT CATE_NM FROM WT_WHERE) IN ('전체') THEN CATE_NM ELSE (SELECT CATE_NM FROM WT_WHERE) END)
            OR ((SELECT CATE_NM FROM WT_WHERE)  = '자사제품' AND (
                                                                    SELECT MAX(BRAND) 
                                                                      FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                                                                     WHERE X.ID = A.PROD_ID
                                                                 ) = '더마펌')
    ), WT_REVW_SUM AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
      GROUP BY PROD_ID
    ), WT_REVW_SUM_MOM AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
           AND PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
      GROUP BY PROD_ID
    ), WT_REVW_RATE AS
    (
        SELECT PROD_ID
              ,CASE WHEN (sum(PSTV_CNT) + sum(NGTV_CNT)) = 0 THEN 0 ELSE sum(PSTV_CNT) / sum(REVW_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (sum(PSTV_CNT) + sum(NGTV_CNT)) = 0 THEN 0 ELSE sum(NGTV_CNT) / sum(REVW_CNT) * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM
          where revw_cnt >= 20
	      group by prod_id
          
    ), WT_REVW_RATE_MOM AS
    (
        SELECT PROD_ID
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / REVW_CNT * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM_MOM
    ), WT_REVW_COMP AS
    (
        SELECT A.PROD_ID
              ,A.PSTV_RATE - B.PSTV_RATE AS PSTV_CHNG
              ,A.NGTV_RATE - B.NGTV_RATE AS NGTV_CHNG
          FROM WT_REVW_RATE A INNER JOIN WT_REVW_RATE_MOM B 
            ON (A.PROD_ID = B.PROD_ID)
    ), WT_PSTV_RANK AS
    (
        SELECT PROD_ID
              ,PSTV_CHNG
              ,NGTV_CHNG
              ,ROW_NUMBER() OVER(ORDER BY PSTV_CHNG DESC, PROD_ID) AS PSTV_RANK
              ,ROW_NUMBER() OVER(ORDER BY NGTV_CHNG DESC, PROD_ID) AS NGTV_RANK
          FROM WT_REVW_COMP
    ), WT_BASE AS
    (
        SELECT A.REVW_RANK
              ,REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(B.PROD_ID) AS PSTV_PROD_NM
              ,REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(C.PROD_ID) AS NGTV_PROD_NM
              ,B.PSTV_CHNG
              ,C.NGTV_CHNG
              ,B.PSTV_RANK
              ,C.NGTV_RANK
          FROM WT_COPY A LEFT OUTER JOIN WT_PSTV_RANK B ON (A.REVW_RANK = B.PSTV_RANK)
                         LEFT OUTER JOIN WT_PSTV_RANK C ON (A.REVW_RANK = C.NGTV_RANK)
    )
    SELECT REVW_RANK                                     /* 순위 1~5 */
          ,PSTV_PROD_NM                                  /* 긍정비율 변화 Top5 제품명 */
          ,NGTV_PROD_NM                                  /* 부정비율 변화 Top5 제품명 */
          ,CAST(PSTV_CHNG AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정비율 증감률           */ 
          ,CAST(NGTV_CHNG AS DECIMAL(20,2)) AS PSTV_RATE /* 부정비율 증감률           */
      FROM WT_BASE
     WHERE COALESCE(PSTV_PROD_NM, '') != '' OR COALESCE(NGTV_PROD_NM, '') != ''
  ORDER BY REVW_RANK
