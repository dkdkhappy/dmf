/* 2. 채널 별 리뷰 지도 - 트리 맵 그래프 SQL */
/* 기존 트리 맵 그래프는 브랜드별로 나누어 보여지고 브랜드를 클릭하면 제품이 나오는 구조임 */
/* Summary의 경우는 요구사항이 브랜드가 더마펌만 나오도록 요구하였기 때문에 */
/* Root -> 브랜드 -> 제품 이 아니고 Root -> 제품으로 변경이 필요함 */ 
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)         AS FR_DT      /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)         AS TO_DT      /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,COALESCE({WITH_FAKE}, 'N'   ) AS WITH_FAKE  /*  WITH_FAKE (Y:비정상리뷰 포함, 'N':비정상리뷰 불포함) 기본값 'N' */
              ,COALESCE({CHNL_ID},   'ALL' ) AS CHNL_ID    /* 채널 ID */
              ,COALESCE({TPIC_ITEM}, '전체') AS TPIC_ITEM  /* 토픽 대주제 (전체, 효능, CS,) ex) 효능 */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */
    ), WT_PROD AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,BRAND
              ,REVIEW_RAW.SF_TMALL_PROD_NM(PROD_ID) AS PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DCT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCT' ELSE X.CHNL_ID END FROM WT_WHERE X)
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,BRAND
              ,REVIEW_RAW.SF_TMALL_PROD_NM(PROD_ID) AS PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DGT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGT' ELSE X.CHNL_ID END FROM WT_WHERE X)
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,BRAND
              ,REVIEW_RAW.SF_DOUYIN_PROD_NM(PROD_ID) AS PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DCD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCD' ELSE X.CHNL_ID END FROM WT_WHERE X)
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,BRAND
              ,REVIEW_RAW.SF_DOUYIN_PROD_NM(PROD_ID) AS PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DGD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGD' ELSE X.CHNL_ID END FROM WT_WHERE X)
    ), WT_TPIC AS
    (
        SELECT DISTINCT
               FIRST AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE A
         WHERE FIRST = CASE WHEN (SELECT TPIC_ITEM FROM WT_WHERE) = '전체' THEN FIRST ELSE (SELECT TPIC_ITEM FROM WT_WHERE) END
    ), WT_DATA_TPIC_SPLT AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCT' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGT' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCD' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGD' ELSE X.CHNL_ID END FROM WT_WHERE X)
               ) A
    ), WT_DATA_TPIC AS
    (
        SELECT DISTINCT
               CHNL_ID
              ,PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT X.TPIC_ITEM FROM WT_TPIC X)
    ), WT_DATA_REVW AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NAME AS PROD_NM
              ,B.BRAND     AS BRND_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCT' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGT' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGT' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DCD' ELSE X.CHNL_ID END FROM WT_WHERE X)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGD' = (SELECT CASE WHEN X.CHNL_ID = 'ALL' THEN 'DGD' ELSE X.CHNL_ID END FROM WT_WHERE X)
               ) A LEFT OUTER JOIN 
               WT_PROD B
            ON (A.CHNL_ID = B.CHNL_ID AND A.DATE = B.DATE AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID)
         WHERE B.BRAND = '더마펌'
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NAME
              ,B.BRAND
    ), WT_SUM AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
              ,SUM(REVW_CNT) AS REVW_CNT
              ,SUM(PSTV_CNT) AS PSTV_CNT
              ,SUM(NTRL_CNT) AS NTRL_CNT
              ,SUM(NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_REVW A INNER JOIN
               WT_DATA_TPIC B
            ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
    ), WT_BASE_TMP as (
		    SELECT PROD_ID
              ,COALESCE(PROD_NM , PROD_ID      ) AS PROD_NM
              ,COALESCE(BRND_NM , '브랜드 미상') AS BRND_NM
              ,REVW_CNT
              ,PSTV_CNT
              ,NTRL_CNT
              ,NGTV_CNT
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SUM A
    ),   WT_BASE AS
    (
        SELECT STRING_AGG(DISTINCT PROD_ID, ', ') AS PROD_ID
              ,PROD_NM
              ,BRND_NM
              ,SUM(REVW_CNT)              as REVW_CNT
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(PSTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS PSTV_RATE
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(NTRL_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS NTRL_RATE
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(NGTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SUM A
          group by prod_nm, brnd_nm
    )
    SELECT BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,REVW_CNT  /* 리뷰 수   */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS REVW_RATE /* 긍/부정 리뷰 비율 0 ~ 100 (색변경) */
          ,PROD_ID   /* 제품코드  */
      FROM WT_BASE
  ORDER BY BRND_NM
          ,PROD_NM