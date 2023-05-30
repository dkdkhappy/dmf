/* 4. 레이더 부연설명 그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,{PROD_ID}              AS PROD_ID         /* 제품번호 하나를 입력한다. ex) 617136486827 */
              ,{AVG_TYPE}             AS AVG_TYPE        /* 전체평균 또는 카테고리 평균 선택 (전체평균 : 전체, 카테고리 평균 : 카테고리) ex) 전체 */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */    
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
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE({TPIC_ITEM}, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
    ), WT_LGND_TYPE AS
    (
        SELECT 1  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '제품 긍정비율'     ELSE '제품 부정비율'     END AS L_LGND
    UNION ALL
        SELECT 2  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '평균 긍정비율'     ELSE '평균 부정비율'     END AS L_LGND
    UNION ALL
        SELECT 3  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율' END AS L_LGND
    UNION ALL
        SELECT 4  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율' END AS L_LGND
    UNION ALL
        SELECT 5  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '평균 긍정비율'     ELSE '평균 부정비율'     END AS L_LGND
    UNION ALL
        SELECT 6  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율' END AS L_LGND
    UNION ALL
        SELECT 7  AS SORT_KEY
              ,CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율' END AS L_LGND
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
        SELECT MIN(A.SORT_KEY) AS SORT_KEY
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,B.L_LGND
          FROM WT_TPIC      A
              ,WT_LGND_TYPE B
      GROUP BY CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
              ,L_LGND
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
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
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
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE((SELECT PROD_ID FROM WT_WHERE), ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_RATE AS
    (
        SELECT TPIC_ITEM
              ,PROD_ID
              ,PSTV_CNT
              ,NGTV_CNT
              ,REVW_CNT
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE PSTV_CNT / REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE NGTV_CNT / REVW_CNT * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND
              ,TPIC_ITEM 
              ,MAX(PSTV_RATE) AS PSTV_RATE
              ,MAX(NGTV_RATE) AS NGTV_RATE
          FROM (
                    SELECT 1   AS SORT_KEY
                          ,CASE
                             WHEN PSNG_TYPE = 'PSTV' THEN '제품 긍정비율' ELSE '제품 부정비율'
                           END AS L_LGND
                          ,CASE
                             WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체'
                             THEN CASE
                                    WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                                    WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                                    ELSE A.TPIC_ITEM
                                  END
                             ELSE A.TPIC_ITEM
                           END
			              ,CASE WHEN SUM(REVW_CNT) = 0 THEN 0 ELSE SUM(PSTV_CNT) / SUM(REVW_CNT) * 100 END AS PSTV_RATE
			              ,CASE WHEN SUM(REVW_CNT) = 0 THEN 0 ELSE SUM(NGTV_CNT) / SUM(REVW_CNT) * 100 END AS NGTV_RATE
                      FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
                        ON (A.TPIC_ITEM = B.TPIC_ITEM)
                     WHERE B.PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
                     group by sort_key, l_lgnd, a.TPIC_ITEM
                 UNION ALL
                    SELECT 1   AS SORT_KEY
                          ,CASE 
                             WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN '제품 긍정비율' ELSE '제품 부정비율'
                           END AS L_LGND
                          ,CASE 
                             WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                             THEN CASE 
                                    WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                                    WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                                    ELSE A.TPIC_ITEM
                                  END
                             ELSE A.TPIC_ITEM
                           END
                          ,NULL           AS PSTV_RATE
                          ,NULL           AS NGTV_RATE
                      FROM WT_TPIC A
               ) A
      GROUP BY SORT_KEY
              ,L_LGND
              ,TPIC_ITEM
     UNION ALL
        SELECT 2   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '평균 긍정비율' ELSE '평균 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,AVG(PSTV_RATE) AS PSTV_RATE
              ,AVG(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '평균 긍정비율' ELSE '평균 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
     UNION ALL
        SELECT 3   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,MAX(PSTV_RATE) AS PSTV_RATE
              ,MAX(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
     UNION ALL
        SELECT 4   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,MIN(PSTV_RATE) AS PSTV_RATE
              ,MIN(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
     UNION ALL
        SELECT 5   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '평균 긍정비율' ELSE '평균 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,AVG(PSTV_RATE) AS PSTV_RATE
              ,AVG(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
        WHERE PROD_ID IN (
                            SELECT X.PROD_ID
                              FROM WT_CATE_SPLT_RE X
                             WHERE X.CATE_NM IN (SELECT Y.CATE_NM FROM WT_CATE_SPLT_RE Y WHERE Y.PROD_ID IN (SELECT PROD_ID FROM WT_prod_WHERE))
                         )
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '평균 긍정비율' ELSE '평균 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
     UNION ALL
        SELECT 6   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,MAX(PSTV_RATE) AS PSTV_RATE
              ,MAX(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
        WHERE PROD_ID IN (
                            SELECT X.PROD_ID
                              FROM WT_CATE_SPLT_RE X
                             WHERE X.CATE_NM IN (SELECT Y.CATE_NM FROM WT_CATE_SPLT_RE Y WHERE Y.PROD_ID IN (SELECT PROD_ID FROM WT_prod_WHERE))
                         )
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최고 긍정비율' ELSE '업계최고 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
     UNION ALL
        SELECT 7   AS SORT_KEY
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율'
               END AS L_LGND
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END AS TPIC_ITEM
              ,MIN(PSTV_RATE) AS PSTV_RATE
              ,MIN(NGTV_RATE) AS NGTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
        WHERE PROD_ID IN (
                            SELECT X.PROD_ID
                              FROM WT_CATE_SPLT_RE X
                             WHERE X.CATE_NM IN (SELECT Y.CATE_NM FROM WT_CATE_SPLT_RE Y WHERE Y.PROD_ID IN (SELECT PROD_ID FROM WT_prod_WHERE))
                         )
      GROUP BY CASE 
                 WHEN PSNG_TYPE = 'PSTV' THEN '업계최저 긍정비율' ELSE '업계최저 부정비율'
               END
              ,CASE 
                 WHEN (SELECT TPIC_TYPE FROM WT_WHERE) = '전체' 
                 THEN CASE 
                        WHEN A.TPIC_ITEM LIKE '효능%' THEN '효능'
                        WHEN A.TPIC_ITEM LIKE 'CS%'   THEN 'CS'
                        ELSE A.TPIC_ITEM
                      END
                 ELSE A.TPIC_ITEM
               END
    )
    SELECT A.TPIC_ITEM  /* 토픽 상세항목 - X축 */
          ,A.L_LGND     /* Legend */
          ,CAST(CASE WHEN (SELECT PSNG_TYPE FROM WT_WHERE) = 'PSTV' THEN B.PSTV_RATE ELSE B.NGTV_RATE END AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정리뷰 비율 - Y축 */
      FROM WT_COPY_TPIC A LEFT OUTER JOIN WT_BASE B
        ON (A.TPIC_ITEM = B.TPIC_ITEM AND A.L_LGND = B.L_LGND AND (((SELECT AVG_TYPE FROM WT_WHERE) = '전체' AND B.SORT_KEY IN (1, 2, 3, 4)) OR ((SELECT AVG_TYPE FROM WT_WHERE) = '카테고리' AND B.SORT_KEY IN (1, 5, 6, 7))))
  ORDER BY A.SORT_KEY
          ,B.SORT_KEY