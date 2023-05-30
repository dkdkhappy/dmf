/* 6. 워드 크라우드 - 워드 크라우드 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,{EXCT_TOPIC}           AS EXCT_TOPIC      /* EXCT_TOPIC (N:전체, 'Y':토픽단어 제외) 기본값 'N' */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(COALESCE({TPIC_ITEM}, ''), ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_COPY AS
    (
        SELECT CAST(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 DAYS') AS DATE) AS X_DT
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
    ), WT_TPIC AS
    (
        SELECT CASE
                 WHEN (SELECT COUNT(*) FROM WT_TPIC_WHERE WHERE TRIM(TPIC_ITEM) != '' ) > 0
                 THEN ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_WHERE X WHERE X.TPIC_ITEM = A.TPIC_ITEM))
                 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE  X WHERE X.TPIC_TYPE = A.TPIC_TYPE), TPIC_ITEM COLLATE "ko_KR.utf8")
               END AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
         WHERE (TPIC_TYPE, TPIC_ITEM) IN (
                                            SELECT CASE
                                                     WHEN X.TPIC_TYPE = '전체'     THEN A.TPIC_TYPE --'대주제'
                                                     WHEN X.TPIC_TYPE = '토픽선택' THEN A.TPIC_TYPE
                                                     WHEN X.TPIC_TYPE = '효능'     THEN '효능'
                                                     WHEN X.TPIC_TYPE = 'CS'       THEN 'CS'
                                                   END,
                                                   CASE 
                                                     WHEN X.TPIC_TYPE = '전체'                           THEN A.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = '토픽선택'                       THEN Y.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = '효능'     AND Y.TPIC_ITEM  = '' THEN A.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = '효능'     AND Y.TPIC_ITEM != '' THEN Y.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = 'CS'       AND Y.TPIC_ITEM  = '' THEN A.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = 'CS'       AND Y.TPIC_ITEM != '' THEN Y.TPIC_ITEM
                                                   END
                                              FROM WT_WHERE      X
                                                  ,WT_TPIC_WHERE Y
                                         )
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,DATE
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
              ,COUNT_VECT                               AS WORD_LIST
              ,CASE 
                 WHEN SENT_RATING IN (4, 5) THEN 'PSTV'
                 WHEN SENT_RATING IN (3   ) THEN 'NTRL'
                 WHEN SENT_RATING IN (1, 2) THEN 'NGTV'
               END AS PSNG_TYPE
          FROM (
                SELECT A.*, B.SENT_RATING 
                  FROM REVIEW_RAW.OVER_{TAG}_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                                                                    INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE B
                    ON (A.PROD_ID = B.PROD_ID AND A.DATE = B.DATE AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_DATA_TPIC AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TPIC_ITEM
              ,REPLACE(WORD_LIST, '''', '"') AS WORD_LIST 
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC)
           AND PSNG_TYPE  = (SELECT PSNG_TYPE FROM WT_WHERE)
    ), WT_WORD_SPLT AS
    (
        SELECT A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,A.TPIC_ITEM
              ,X.KEY                          AS WORD_ITEM
              ,CAST(X.VALUE AS DECIMAL(20,0)) AS WORD_CNT
          FROM WT_DATA_TPIC A CROSS JOIN LATERAL JSONB_EACH(CAST(A.WORD_LIST AS JSONB)) X
    ), WT_WORD_SUM AS
    (
        SELECT WORD_ITEM
              ,SUM(WORD_CNT) AS WORD_CNT
          FROM WT_WORD_SPLT
      GROUP BY WORD_ITEM 
    ), WT_BASE AS 
    (
        SELECT WORD_ITEM
              ,WORD_CNT
              ,ROW_NUMBER() OVER(ORDER BY WORD_CNT DESC) AS WORD_RANK 
          FROM WT_WORD_SUM
    )
    SELECT WORD_ITEM   /* 토픽에 대한 워드         */
          ,WORD_CNT    /* 빈도수   - 데이터 확인용 */
          ,WORD_RANK   /* 빈도순위 - 데이터 확인용 */
      FROM WT_BASE
  ORDER BY WORD_RANK
     LIMIT 30