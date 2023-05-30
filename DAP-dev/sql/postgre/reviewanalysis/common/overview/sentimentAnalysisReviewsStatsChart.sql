/* 1. 중요정보카드 - Chart SQL */
WITH WT_BASE AS
    (
        SELECT TO_CHAR(DATE, 'YYYY-MM')        AS REVW_MNTH
              ,CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
      GROUP BY TO_CHAR(DATE, 'YYYY-MM')
    )
    SELECT REVW_MNTH AS X_DT  /* 리뷰 월 */
          ,REVW_CNT  AS V_VAL /* 리뷰 수 */
      FROM WT_BASE
  ORDER BY REVW_MNTH