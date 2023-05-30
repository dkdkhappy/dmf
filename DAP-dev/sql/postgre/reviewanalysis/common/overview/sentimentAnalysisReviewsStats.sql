/* 1. 중요정보카드 - 수집 리뷰수, 긍정vs부정, 긍/부정 변환 1위 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(BASE_DT                                                            AS DATE) AS BASE_DT           /* 기준일자 (어제)        */
              ,CAST(CAST(FRST_DT_MNTH AS DATE) - INTERVAL '0' MONTH - INTERVAL '1' DAY AS DATE) AS FRST_DT_MNTH      /* 기준일자 (어제)   -1월 */
              ,CAST(CAST(FRST_DT_MNTH AS DATE) - INTERVAL '1' MONTH - INTERVAL '1' DAY AS DATE) AS FRST_DT_MNTH_MOM  /* 기준일자 (어제)   -2월 */
              ,CAST(CAST(BASE_DT      AS DATE) - INTERVAL '1' MONTH                    AS DATE) AS BASE_MNTH         /* 기준일자 (어제)   -1월 */
              ,CAST(CAST(BASE_DT      AS DATE) - INTERVAL '2' MONTH                    AS DATE) AS BASE_MNTH_MOM     /* 기준일자 (어제)   -2월 */
          FROM REVIEW.REVIEW_INITIAL_DATE
    ), WT_REVW_TOTL AS
    (
        SELECT CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
    ), WT_REVW_DAY AS
    (
        SELECT CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE <= (SELECT FRST_DT_MNTH FROM WT_WHERE)
    ), WT_REVW_DAY_DOD AS
    (
        SELECT CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE <= (SELECT FRST_DT_MNTH_MOM FROM WT_WHERE)
    ), WT_CHNG AS
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
         WHERE DATE BETWEEN (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH)                              AS DATE) FROM WT_WHERE) 
                        AND (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) FROM WT_WHERE)
      GROUP BY PROD_ID
    ), WT_CNHG_MOM AS
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
         WHERE DATE BETWEEN (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH_MOM)                              AS DATE) FROM WT_WHERE) 
                        AND (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH_MOM) + INTERVAL '1 MONTH - 1 DAY' AS DATE) FROM WT_WHERE) 
      GROUP BY PROD_ID
    ), WT_CHNG_RATE AS
    (
        SELECT A.PROD_ID
              ,(A.PSTV_CNT / A.REVW_CNT * 100) - (B.PSTV_CNT / B.REVW_CNT * 100) AS PSTV_RATE
              ,(A.NGTV_CNT / A.REVW_CNT * 100) - (B.NGTV_CNT / B.REVW_CNT * 100) AS NGTV_RATE
          FROM WT_CHNG A INNER JOIN WT_CNHG_MOM B ON (A.PROD_ID = B.PROD_ID)
    ), WT_CHGN_RANK AS
    (
        SELECT PROD_ID
              ,PSTV_RATE
              ,NGTV_RATE
              ,RANK() OVER(ORDER BY PSTV_RATE DESC, PROD_ID) AS PSTV_RANK
              ,RANK() OVER(ORDER BY NGTV_RATE DESC, PROD_ID) AS NGTV_RANK
          FROM WT_CHNG_RATE
         WHERE PROD_ID IN (SELECT ID FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME WHERE BRAND = '더마펌')
    ), WT_BASE AS
    (
        SELECT A.REVW_CNT
              ,CASE WHEN C.REVW_CNT = 0 THEN 0 ELSE (B.REVW_CNT - C.REVW_CNT) / C.REVW_CNT * 100 END AS REVW_RATE
              -- ,A.PSTV_CNT
              -- ,A.NTRL_CNT
              -- ,A.NGTV_CNT
              ,(B.PSTV_CNT / (B.PSTV_CNT + B.NTRL_CNT + B.NGTV_CNT) * 100) - (C.PSTV_CNT / (C.PSTV_CNT + C.NTRL_CNT + C.NGTV_CNT) * 100) AS PSTV_CNT
              ,(B.NTRL_CNT / (B.PSTV_CNT + B.NTRL_CNT + B.NGTV_CNT) * 100) - (C.NTRL_CNT / (C.PSTV_CNT + C.NTRL_CNT + C.NGTV_CNT) * 100) AS NTRL_CNT
              ,(B.NGTV_CNT / (B.PSTV_CNT + B.NTRL_CNT + B.NGTV_CNT) * 100) - (C.NGTV_CNT / (C.PSTV_CNT + C.NTRL_CNT + C.NGTV_CNT) * 100) AS NGTV_CNT
              ,(A.PSTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100) AS PSTV_RATE
              ,(A.NTRL_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100) AS NTRL_RATE
              ,(A.NGTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100) AS NGTV_RATE
              ,REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(D.PROD_ID) AS PSTV_PROD_NM
              ,D.PSTV_RATE                      AS PSTV_RATE_CHNG
              ,REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(E.PROD_ID) AS NGTV_PROD_NM
              ,E.NGTV_RATE                      AS NGTV_RATE_CHNG
          FROM WT_REVW_TOTL    A
              ,WT_REVW_DAY     B
              ,WT_REVW_DAY_DOD C
              ,(
                SELECT PROD_ID
                      ,PSTV_RATE
                  FROM WT_CHGN_RANK
                 WHERE PSTV_RANK = 1
              ) D
              ,(
                SELECT PROD_ID
                      ,NGTV_RATE
                  FROM WT_CHGN_RANK
                 WHERE NGTV_RANK = 1
              ) E
    )
    SELECT COALESCE(CAST(REVW_CNT  AS DECIMAL(20,0)), 0) AS REVW_CNT    /* 전체 수집 리뷰 수     */
          ,COALESCE(CAST(REVW_RATE AS DECIMAL(20,2)), 0) AS REVW_RATE   /* 전체 수집 리뷰 증감률 */
          ,COALESCE(CAST(PSTV_CNT  AS DECIMAL(20,2)), 0) AS PSTV_CNT    /* 긍정 리뷰 증감률      */
          ,COALESCE(CAST(NTRL_CNT  AS DECIMAL(20,2)), 0) AS NTRL_CNT    /* 중립 리뷰 증감률      */
          ,COALESCE(CAST(NGTV_CNT  AS DECIMAL(20,2)), 0) AS NGTV_CNT    /* 부정 리뷰 증감률      */
          ,COALESCE(CAST(PSTV_RATE AS DECIMAL(20,2)), 0) AS PSTV_RATE   /* 긍정 리뷰 비율        */
          ,COALESCE(CAST(NTRL_RATE AS DECIMAL(20,2)), 0) AS NTRL_RATE   /* 중립 리뷰 비율        */
          ,COALESCE(CAST(NGTV_RATE AS DECIMAL(20,2)), 0) AS NGTV_RATE   /* 부정 리뷰 비율        */
          ,PSTV_PROD_NM                                                          /* 긍정 변화 제품명      */
          ,COALESCE(CAST(PSTV_RATE_CHNG AS DECIMAL(20,2)), 0) AS PSTV_RATE_CHNG  /* 긍정 변화 증감률      */
          ,NGTV_PROD_NM                                                          /* 부정 변화 제품명      */
          ,COALESCE(CAST(NGTV_RATE_CHNG AS DECIMAL(20,2)), 0) AS NGtV_RATE_CHNG  /* 부정 변화 증감률      */
      FROM WT_BASE