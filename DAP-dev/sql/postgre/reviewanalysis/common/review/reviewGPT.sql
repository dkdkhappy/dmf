/* 1. Review - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,{REVW_TYPE}            AS REVW_TYPE       /* 긍/부정 (전체:'전체', 긍정:'긍정', 부정:'부정' ) ex) 효능 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE({TPIC_ITEM}, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
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
    ), WT_PROD_TYPE AS
    (
        SELECT BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_TMALL_ID_NAME
         WHERE ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_ID = A.PROD_ID)) AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE A
    ), WT_COPY AS
    (
        SELECT A.SORT_KEY AS SORT_KEY_TPIC
              ,A.TPIC_ITEM
              ,B.SORT_KEY AS SORT_KEY_PROD
              ,B.PROD_NM
              ,B.PROD_ID
              ,B.BRND_NM
          FROM WT_TPIC A
              ,WT_PROD B
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,ROW_NUMBER() OVER(PARTITION BY PROD_ID ORDER BY DATE, REVIEW_ID, SENTENCE_ORDER) AS SORT_KEY_LINE
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_DATA_TPIC AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,SORT_KEY_LINE
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,SPLIT_REVIEWS
              ,CASE 
                 WHEN SENT_RATING IN (4, 5) THEN '긍정'
                 WHEN SENT_RATING IN (3   ) THEN '중립'
                 WHEN SENT_RATING IN (1, 2) THEN '부정'
               END AS REVW_TYPE
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_SUM AS
    (
        SELECT A.PROD_ID
              ,A.TPIC_ITEM
              ,A.SORT_KEY_LINE
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.SPLIT_REVIEWS  AS REVW_CHN
              ,C.ENG            AS REVW_ENG
              ,C.KOR            AS REVW_KOR
              ,B.REVW_TYPE      AS REVW_TYPE
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
                              INNER JOIN REVIEW_RAW.OVER_{TAG}_TRANSLATED_SENTENCE_TABLE C 
            ON (A.PROD_ID = C.PROD_ID AND A.REVIEW_ID = C.REVIEW_ID AND A.SENTENCE_ORDER = C.SENTENCE_ORDER)
         WHERE B.REVW_TYPE LIKE (SELECT CASE WHEN REVW_TYPE = '전체' THEN '%' ELSE REVW_TYPE END FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT DISTINCT
               A.SORT_KEY_TPIC   /* 토픽     정렬순서 */
              ,A.SORT_KEY_PROD   /* 제품     정렬순서 */
              ,B.SORT_KEY_LINE   /* 리뷰라인 정렬순서 */
              ,B.REVIEW_ID       /* 리뷰ID            */
              ,B.SENTENCE_ORDER  /* 리뷰라인 순서     */
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM  /* Review - 토픽     */
              --,A.TPIC_ITEM
              ,A.PROD_ID         /* 제품ID            */
              ,A.PROD_NM         /* 제품명            */
              ,A.BRND_NM         /* 브랜드명          */
              ,B.REVW_CHN        /* Review - 중국어   */
              ,B.REVW_ENG        /* Review - 영어     */
              ,B.REVW_KOR        /* Review - 한국어   */
              ,B.REVW_TYPE       /* Review - 긍부정   */
          FROM WT_COPY A INNER JOIN WT_SUM B
            ON (A.PROD_ID = B.PROD_ID AND A.TPIC_ITEM = B.TPIC_ITEM)
    )
    SELECT SORT_KEY_PROD
          ,PROD_NM                                             AS PROD_NM    /* 제품명            */
          ,ARRAY_TO_STRING(ARRAY_AGG(DISTINCT TPIC_ITEM),', ') AS TPIC_ITEM  /* Review - 토픽     */
          ,REVW_CHN                                            AS REVW_CHN   /* Review - 중국어   */
          ,REVW_ENG                                            AS REVW_ENG   /* Review - 영어     */
          ,REVW_KOR                                            AS REVW_KOR   /* Review - 한국어   */
          ,REVW_TYPE                                           AS REVW_TYPE  /* Review - 긍부정   */
          ,split_part(review_id, '-',2) 					   as DATE 
      FROM WT_BASE
  GROUP BY SORT_KEY_PROD
          ,PROD_NM
          ,REVW_CHN
          ,REVW_ENG
          ,REVW_KOR
          ,REVW_TYPE
          ,split_part(review_id, '-',2) 
  ORDER BY SORT_KEY_PROD, split_part(review_id, '-',2) desc
  limit 80