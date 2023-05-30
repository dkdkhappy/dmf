/* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 (대주제) SQL */
WITH WT_WHERE AS
    (
        SELECT {CATE_NM}              AS CATE_NM         /* 카테고리 명 하나를 입력한다. ex) '로션' */
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
         WHERE CATE_NM = (SELECT CASE WHEN X.CATE_NM = '전체' THEN A.CATE_NM ELSE X.CATE_NM END FROM WT_WHERE X)
    ), WT_TPIC_TYPE AS
    (
        SELECT 1 AS SORT_KEY, '대주제'   AS TPIC_TYPE UNION ALL
        SELECT 2 AS SORT_KEY, '효능'     AS TPIC_TYPE UNION ALL
        SELECT 3 AS SORT_KEY, 'CS'       AS TPIC_TYPE 
    ), WT_TPIC_DATA AS
    (
        SELECT DISTINCT
               '대주제' AS TPIC_TYPE
              ,FIRST    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
     UNION ALL
        SELECT DISTINCT
               '효능'   AS TPIC_TYPE
              ,TOTAL    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
         WHERE FIRST  = '효능'
           AND TOTAL != '효능'
     UNION ALL
        SELECT DISTINCT
               'CS'     AS TPIC_TYPE
              ,TOTAL    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
         WHERE FIRST = 'CS'
    ), WT_TPIC_WHERE AS
    (
        SELECT TPIC_ITEM
          FROM WT_TPIC_DATA A
    ), WT_TPIC AS
    (
        SELECT DISTINCT
               CASE 
                 WHEN TPIC_ITEM LIKE '효능%' THEN '효능'
                 WHEN TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                 ELSE TPIC_ITEM
               END AS TPIC_ITEM
          FROM WT_TPIC_DATA A
    ), WT_DATA_TPIC_SPLT AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
    ), WT_DATA_TPIC AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,CASE 
                 WHEN TPIC_ITEM LIKE '효능%' THEN '효능'
                 WHEN TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                 ELSE TPIC_ITEM
               END AS TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC_WHERE)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
      GROUP BY PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
    ), WT_SUM AS
    (
        SELECT A.TPIC_ITEM
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.TPIC_ITEM
    ), WT_BASE AS
    (
        SELECT X.TPIC_ITEM
              ,ROW_NUMBER() OVER(ORDER BY X.TPIC_ITEM COLLATE "ko_KR.utf8" DESC)      AS SORT_KEY
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.PSTV_CNT / A.REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NTRL_CNT / A.REVW_CNT * 100 END AS NTRL_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NGTV_CNT / A.REVW_CNT * 100 END AS NGTV_RATE
          FROM WT_TPIC X LEFT OUTER JOIN WT_SUM A ON (X.TPIC_ITEM = A.TPIC_ITEM)
    )
    SELECT SORT_KEY
          ,TPIC_ITEM   /* 토픽 상세항목 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE  /* 긍정 리뷰 비율 */
          ,CAST(NTRL_RATE AS DECIMAL(20,2)) AS NTRL_RATE  /* 중립 리뷰 비율 */
          ,CAST(NGTV_RATE AS DECIMAL(20,2)) AS NGTV_RATE  /* 부정 리뷰 비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY
