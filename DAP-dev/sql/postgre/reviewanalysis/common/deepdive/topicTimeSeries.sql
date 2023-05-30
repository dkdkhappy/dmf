/* 5. 토픽별 시계열 그래프 - 시계열 그래프 SQL */
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
              ,DATE
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,DATE
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
              ,DATE
    ), WT_SUM AS
    (
        SELECT REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(A.PROD_ID)     AS PROD_NM
              ,STRING_AGG(DISTINCT A.PROD_ID, ', ') AS PROD_ID
              ,CAST(A.DATE AS DATE) AS X_DT
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER AND A.DATE = B.DATE)
      GROUP BY PROD_NM
              ,A.DATE
    ), WT_CUM AS
    (
        SELECT B.PROD_ID
              ,B.PROD_NM
              ,A.X_DT
              ,B.REVW_CNT
              ,B.PSTV_CNT
              ,B.NGTV_CNT
              ,SUM(B.REVW_CNT) OVER(PARTITION BY B.PROD_NM ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(B.PSTV_CNT) OVER(PARTITION BY B.PROD_NM ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(B.NGTV_CNT) OVER(PARTITION BY B.PROD_NM ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
          FROM WT_COPY A LEFT OUTER JOIN WT_SUM B 
            ON (A.X_DT = B.X_DT)
    ), WT_NAME_BRAND AS
    (
        SELECT DISTINCT ON(NAME) 
               NAME  AS PROD_NM
              ,BRAND AS BRND_NM
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
         WHERE NAME in (SELECT PROD_NM FROM WT_CUM)
    ), WT_SORT_KEY_NEW AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,A.PROD_NM
              ,A.BRND_NM
          FROM (SELECT PROD_NM, BRND_NM FROM WT_NAME_BRAND) A
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_SORT_KEY_NEW X
                 WHERE X.PROD_NM = A.PROD_NM
               ) AS SORT_KEY
              ,B.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE PSTV_CNT / REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN REVW_CUM = 0 THEN 0 ELSE PSTV_CUM / REVW_CUM * 100 END AS PSTV_RATE_CUM
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE NGTV_CNT / REVW_CNT * 100 END AS NGTV_RATE
              ,CASE WHEN REVW_CUM = 0 THEN 0 ELSE NGTV_CUM / REVW_CUM * 100 END AS NGTV_RATE_CUM
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SORT_KEY_NEW A LEFT OUTER JOIN WT_CUM B
            ON(A.PROD_NM = B.PROD_NM)
    )
    SELECT SORT_KEY  /* 정렬순서 */
          ,PROD_ID   /* 제품코드 */
          ,PROD_NM   /* 제품 명  - Legend */
          ,X_DT      /* 일자     - X축    */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE     ELSE NGTV_RATE     END AS DECIMAL(20,2)) AS PSTV_RATE      /* 긍정리뷰 비율 - 시점 Y축 */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE_CUM ELSE NGTV_RATE_CUM END AS DECIMAL(20,2)) AS PSTV_RATE_CUM  /* 긍정리뷰 비율 - 누적 Y축 */
          ,REVW_CNT                  /* 리뷰 수 - 시점 (데이터 확인용) */
          ,REVW_CUM AS REVW_CNT_CUM  /* 리뷰 수 - 누적 (데이터 확인용) */
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT