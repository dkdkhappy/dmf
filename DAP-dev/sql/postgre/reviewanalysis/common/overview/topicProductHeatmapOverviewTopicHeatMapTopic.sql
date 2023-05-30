/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (Y축 토픽) SQL */
/* 히트 맵은 Y축 데이터를 생성할 때 아래부터 위의 순서로 나와야한다. */
/* Data를 셋팅할때 [0, 0, 1]  [Y, X, Value] 로 셋팅하기 때문에...    */
/* SQL의 결과는 토픽 대주제가 기타의 경우에만 사용자가 입력한 제품 순서대로 정렬되어 리턴된다. */
WITH WT_WHERE AS
    (
        SELECT {TPIC_TYPE} AS TPIC_TYPE   /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(COALESCE({TPIC_ITEM}, ''), ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 1단계가 전체 이외의 경우 ex)'자극감,효능-미백,CS-배송' */        
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
                                                     WHEN X.TPIC_TYPE = '전체'     THEN '대주제'
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
    )
    SELECT SORT_KEY AS SORT_KEY_TPIC  /* 토픽 정렬순서 */
          ,TPIC_ITEM                  /* 토픽 상세항목 */
      FROM WT_COPY_TPIC
  ORDER BY SORT_KEY
  