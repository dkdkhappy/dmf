/* 1. 토픽별 바그래프 -  제품 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{TPIC_TYPE}            AS TPIC_TYPE       /* 토픽 1단계 (전체, 토픽선택, 효능, CS) ex) 효능 */
              ,{CATE_NM}              AS CATE_NM         /* 카테고리 명 하나를 입력한다. ex) '로션' */
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
          FROM REGEXP_SPLIT_TO_TABLE('', ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'668337502145,20332739108,35472276145,545378712840' */        
    ), WT_CATE_SPLT_ORG AS 
    (
        SELECT DISTINCT
               ID                                         AS PROD_ID
              ,brand									  as BRAND_NM
              ,TRIM(REGEXP_SPLIT_TO_TABLE(CATEGORY, '/')) AS CATE_NM
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
          where display  = 'O'
    ), WT_CATE_SPLT_RE AS 
    (
        SELECT DISTINCT
               PROD_ID
              ,BRAND_NM
              ,TRIM(REGEXP_SPLIT_TO_TABLE(CATE_NM, ',')) AS CATE_NM
          FROM WT_CATE_SPLT_ORG
         WHERE TRIM(CATE_NM) != '' 
    ), WT_CATE_SPLT AS 
    (
        SELECT CATE_NM
              ,PROD_ID
              ,BRAND_NM
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
                                                     WHEN X.TPIC_TYPE = '토픽선택' AND Y.TPIC_ITEM = 'CS'  THEN 'CS'
                                                     WHEN X.TPIC_TYPE = '토픽선택' AND Y.TPIC_ITEM = '효능'  THEN '효능'                                                          
                                                     WHEN X.TPIC_TYPE = '토픽선택' THEN A.TPIC_TYPE
                                                     WHEN X.TPIC_TYPE = '효능'     THEN '효능'
                                                     WHEN X.TPIC_TYPE = 'CS'       THEN 'CS'
                                                   END,
                                                   CASE 
                                                     WHEN X.TPIC_TYPE = '전체'                           THEN A.TPIC_ITEM
                                                     WHEN X.TPIC_TYPE = '토픽선택' AND Y.TPIC_ITEM = 'CS'  THEN A.TPIC_ITEM 
                                                     WHEN X.TPIC_TYPE = '토픽선택' AND Y.TPIC_ITEM = '효능'  THEN A.TPIC_ITEM 
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
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_{TAG}_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A 
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
    ), WT_DATA_TPIC AS 
    (
        SELECT 
        distinct 
		     a.PROD_ID
        	, review_raw.sf_{CHNL_L_ID}_prod_nm(a.PROD_ID) as prod_nm
        	, b.brand_nm as brnd_nm
          FROM WT_DATA_TPIC_SPLT a left join WT_CATE_SPLT b on (a.PROD_ID = b.PROD_ID)
         WHERE a.TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC)
    ) select * from WT_DATA_TPIC