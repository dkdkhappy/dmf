/* 4. 제품별 토픽순위 Bar 그래프 - 바 그래프 SQL */
/*    조회기간은 3. 픽별/제품별 히트맵 overview 에서 선택한 기간을 사용한다. */
WITH WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */    
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
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID = (SELECT PROD_ID FROM WT_WHERE)
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
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
    ), WT_SUM AS
    (
        SELECT A.TPIC_ITEM
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.TPIC_ITEM
    ), WT_BASE AS
    (
        SELECT X.TPIC_ITEM
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.PSTV_CNT / A.REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NGTV_CNT / A.REVW_CNT * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_TPIC X LEFT OUTER JOIN WT_SUM A ON (X.TPIC_ITEM = A.TPIC_ITEM)
    )
    SELECT TPIC_ITEM                                                                             AS X_ITEM /* 토픽 상세항목 */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS Y_VAL  /* 긍정 리뷰 비율 */
      FROM WT_BASE
  ORDER BY CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) DESC NULLS LAST
          ,TPIC_ITEM NULLS LAST
