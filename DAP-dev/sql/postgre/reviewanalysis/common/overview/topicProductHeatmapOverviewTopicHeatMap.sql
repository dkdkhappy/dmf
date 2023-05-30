/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */
/*    조회결과 가공방법 ==> [[SORT_KEY_TPIC, SORT_KEY_PROD, PSTV_RATE], [SORT_KEY_TPIC, SORT_KEY_PROD, PSTV_RATE], ...] */
/*    제품에 해당하는 토픽이 없는 경우 리턴하지 않도록 개발함.  값이 없는 경우 빈칸이 되었으면 해서... */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */    
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(COALESCE({TPIC_ITEM}, ''), ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 1단계가 전체 이외의 경우 ex)'자극감,효능-미백,CS-배송' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(COALESCE({PROD_ID}, ''), ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
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
                 THEN ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_WHERE X WHERE X.TPIC_ITEM = A.TPIC_ITEM) DESC) -1
                 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE  X WHERE X.TPIC_TYPE = A.TPIC_TYPE) DESC, TPIC_ITEM COLLATE "ko_KR.utf8" DESC) -1
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
    ), WT_PROD_TYPE AS
    (
        SELECT BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
         WHERE ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_ID = A.PROD_ID)) -1 AS SORT_KEY
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
          FROM WT_COPY_TPIC A
              ,WT_PROD      B
    ), WT_RAW AS
    (
        SELECT A.*
          FROM REVIEW_RAW.OVER_{TAG}_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
            ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
    ), WT_DATA_TPIC_SPLT AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM WT_RAW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
     UNION ALL 
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,(REGEXP_SPLIT_TO_ARRAY(TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')), '-'))[1] AS TPIC_ITEM
          FROM WT_RAW A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)    
      GROUP BY
           PROD_ID
          ,REVIEW_ID
          ,SENTENCE_ORDER
          ,TPIC_ITEM
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
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
    ), WT_SUM AS
    (
        SELECT A.PROD_ID
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,SUM(COALESCE(B.REVW_CNT, 0)) AS REVW_CNT
              ,SUM(COALESCE(B.PSTV_CNT, 0)) AS PSTV_CNT
              ,SUM(COALESCE(B.NTRL_CNT, 0)) AS NTRL_CNT
              ,SUM(COALESCE(B.NGTV_CNT, 0)) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.PROD_ID
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
    ), WT_SENT AS
    (
        SELECT A.SORT_KEY_TPIC
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,A.TPIC_ITEM
              ,A.PROD_NM
              ,A.BRND_NM
          FROM WT_COPY A INNER JOIN WT_SUM B
            ON (A.PROD_ID = B.PROD_ID AND A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY A.SORT_KEY_TPIC
              ,A.TPIC_ITEM
              ,A.PROD_NM
              ,A.BRND_NM
    ), WT_SORT_KEY_NEW AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY_PROD
              ,A.PROD_NM 
          FROM (SELECT DISTINCT PROD_NM FROM WT_COPY) A
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY_TPIC
              ,B.SORT_KEY_PROD
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.PSTV_CNT / A.REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NGTV_CNT / A.REVW_CNT * 100 END AS NGTV_RATE
              ,A.TPIC_ITEM
              ,A.PROD_NM
              ,A.BRND_NM
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SENT A
     LEFT JOIN WT_SORT_KEY_NEW B 
            ON A.PROD_NM = B.PROD_NM
    )    
    SELECT SORT_KEY_TPIC
          ,SORT_KEY_PROD
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS PSTV_RATE
          ,TPIC_ITEM
          ,PROD_NM
          ,BRND_NM
      FROM WT_BASE
  ORDER BY SORT_KEY_TPIC
          ,SORT_KEY_PROD
