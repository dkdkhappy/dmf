● 리뷰분석 - 3. Review

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


*. 조회조건 조정필요
   : 기간은 위로
   : 토픽 대주제, 세부주제
   : 긍부정,      제품명


0. 실제 리뷰 내용을 볼 수 있는 페이지
   제품명 제일 앞으로

1. 토픽을 선택하는 창 : 각기 다른 토픽 중 다양한 토픽을 복수선택 또는 전체 선택
2. 기간 선택을 통해 해당 기간 동안의 리뷰를 확인 할 수 있도록 해야함
3. 긍 부정 리뷰를 선택하여 긍정 또는 부정 아니면 전체 다보도록 해야함
4. 제품 명 선택하여 확인 가능하게 해야함. 복수 선택 가능
5. 리뷰 창이 나와야함. 토픽, 중국어 리뷰, 영문리뷰, 국문리뷰, 긍부정 단계나와야함 가능하다면, Sorting 기능이 있어 순서를 선택하여 볼 수 있었으면 함.

/* review.sql */
/* 1. Review - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_TYPE            AS TPIC_TYPE       /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
              ,:REVW_TYPE            AS REVW_TYPE       /* 긍/부정 (전체:'전체', 긍정:'긍정', 부정:'부정' ) ex) 효능 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(:TPIC_ITEM, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_TPIC_TYPE AS
    (
        SELECT 1 AS SORT_KEY, '대주제' AS TPIC_TYPE UNION ALL
        SELECT 2 AS SORT_KEY, '효능'   AS TPIC_TYPE UNION ALL
        SELECT 3 AS SORT_KEY, 'CS'     AS TPIC_TYPE UNION ALL
        SELECT 4 AS SORT_KEY, '전체'   AS TPIC_TYPE UNION ALL
        SELECT 5 AS SORT_KEY, '기타'   AS TPIC_TYPE 
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
         WHERE FIRST = '효능'
     UNION ALL
        SELECT DISTINCT
               'CS'     AS TPIC_TYPE
              ,TOTAL    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
         WHERE FIRST = 'CS'
    ), WT_TPIC AS
    (
        SELECT CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE ) = '기타'
                 THEN ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_WHERE X WHERE X.TPIC_ITEM = A.TPIC_ITEM))
                 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE  X WHERE X.TPIC_TYPE = A.TPIC_TYPE), TPIC_ITEM COLLATE "ko_KR.utf8")
               END AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
         WHERE (TPIC_TYPE = (SELECT CASE WHEN W.TPIC_TYPE = '전체' THEN A.TPIC_TYPE ELSE W.TPIC_TYPE END FROM WT_WHERE W) AND (SELECT TPIC_TYPE FROM WT_WHERE ) != '기타') 
            OR (TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC_WHERE) AND (SELECT TPIC_TYPE FROM WT_WHERE ) = '기타') 
    ), WT_PROD_TYPE AS
    (
        SELECT BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
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
                  FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
                              INNER JOIN REVIEW_RAW.OVER_DGT_TRANSLATED_SENTENCE_TABLE C 
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
              ,A.TPIC_ITEM       /* Review - 토픽     */
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
          ,PROD_NM                                   AS PROD_NM    /* 제품명            */
          ,ARRAY_TO_STRING(ARRAY_AGG(TPIC_ITEM),',') AS TPIC_ITEM  /* Review - 토픽     */
          ,REVW_CHN                                  AS REVW_CHN   /* Review - 중국어   */
          ,REVW_ENG                                  AS REVW_ENG   /* Review - 영어     */
          ,REVW_KOR                                  AS REVW_KOR   /* Review - 한국어   */
          ,REVW_TYPE                                 AS REVW_TYPE  /* Review - 긍부정   */
      FROM WT_BASE
  GROUP BY SORT_KEY_PROD
          ,PROD_NM
          ,REVW_CHN
          ,REVW_ENG
          ,REVW_KOR
          ,REVW_TYPE
  ORDER BY SORT_KEY_PROD