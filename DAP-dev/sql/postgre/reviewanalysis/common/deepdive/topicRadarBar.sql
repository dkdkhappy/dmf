/* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 바 그래프 SQL */
/*    선택한 모든 토픽을 리턴한다. 없는 값은 Null로 린턴 */
/*    값이 없는 경우 제외하려면 WT_BASE의 WT_TPIC A LEFT OUTER JOIN WT_SUM B 을 INNER JOIN으로 변경한다. */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{CATE_NM}              AS CATE_NM         /* 카테고리 명 하나를 입력한다. ex) '로션' */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */    
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(COALESCE({TPIC_ITEM}, ''), ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
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
    ), WT_COPY_TPIC AS
    (
        SELECT MIN(SORT_KEY) AS SORT_KEY
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
          FROM WT_TPIC A
      GROUP BY CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
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
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC)
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
        SELECT CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.TPIC_ITEM
              ,B.REVW_CNT
              ,CASE WHEN B.REVW_CNT = 0 THEN 0 ELSE B.PSTV_CNT / B.REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN B.REVW_CNT = 0 THEN 0 ELSE B.NGTV_CNT / B.REVW_CNT * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_COPY_TPIC A LEFT OUTER JOIN WT_SUM B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
    )
    SELECT SORT_KEY    /* 정렬순서      */
          ,TPIC_ITEM   /* 토픽 상세항목 */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정 리뷰비율 - 라인 */
          ,REVW_CNT    /* 리뷰 수 - 바 */
      FROM WT_BASE
  ORDER BY SORT_KEY
