● 리뷰분석 - 2. 토픽별 딥다이브

/* 0. 리뷰분석 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 어제임 오늘이 2023.03.04 일 경우 => 22023.03.03 */
SELECT TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY                      , 'YYYY-MM-DD') AS BASE_DT           /* 기준일자               */
      ,TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '1' YEAR , 'YYYY-MM-DD') AS BASE_DT_YOY       /* 기준일자          -1년 */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' DAY )                    , 'YYYY-MM-DD') AS FRST_DT_MNTH      /* 기준월의 1일           */
      ,TO_CHAR(DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1' YEAR)                    , 'YYYY-MM-DD') AS FRST_DT_MNTH_YOY  /* 기준월의 1일      -1년 */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' DAY )                    , 'YYYY-MM-DD') AS FRST_DT_YEAR      /* 기준년의 1월 1일       */
      ,TO_CHAR(DATE_TRUNC('YEAR' , CURRENT_DATE - INTERVAL '1' YEAR)                    , 'YYYY-MM-DD') AS FRST_DT_YEAR_YOY  /* 기준년의 1월 1일  -1년 */
      ,TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY  - INTERVAL '3' MONTH, 'YYYY-MM-DD') AS FR_DT             /* 기간조회 - 시작일자    */
      ,TO_CHAR(                    CURRENT_DATE - INTERVAL '1' DAY                      , 'YYYY-MM-DD') AS TO_DT             /* 기간조회 - 종료일자    */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY'   )                          AS BASE_YEAR         /* 기준년                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY'   )                          AS BASE_YEAR_YOY     /* 기준년            -1년 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY,                     'YYYY-MM')                          AS BASE_MNTH         /* 기준월                 */
      ,TO_CHAR(CURRENT_DATE - INTERVAL '1' DAY - INTERVAL '1' YEAR, 'YYYY-MM')                          AS BASE_MNTH_YOY     /* 기준월            -1년 */   


SELECT BASE_DT               /* 기준일자               */
      ,BASE_DT_YOY           /* 기준일자          -1년 */
      ,FRST_DT_MNTH          /* 기준월의 1일           */
      ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
      ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
      ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
      ,FR_DT                 /* 기간조회 - 시작일자    */
      ,TO_DT                 /* 기간조회 - 종료일자    */
      ,BASE_YEAR             /* 기준년                 */
      ,BASE_YEAR_YOY         /* 기준년            -1년 */
      ,BASE_MNTH             /* 기준월                 */
      ,BASE_MNTH_YOY         /* 기준월            -1년 */
  FROM REVIEW.REVIEW_INITIAL_DATE


1. 토픽별 바그래프
    * 토픽별 제품별 바그래프 : 선택한 기간과 토픽 그리고 제품들에 대한 Bar 그래프가 나와야함 
      ==> 토픽명 테이블 생성

    필요 기능 : 
    [1] 제품선택 : 제품선택 가능해야함 복수선택 
        ==> /* 1. 토픽별 바그래프 -  제품 선택 SQL */ 을 사용
    [2] 기간선택 : 분석 기간을 캘린더로 선택
    [3] 세부토픽 선택 : 토픽을 선택하는 기능 단수선택
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */ 을 사용
    [4] 그래프의 X축은 긍정비율, Y축은 제품명이고 순서대로 나열되야함 

/* viewReviewBarProd.sql */
/* 1. 토픽별 바그래프 -  제품 선택 SQL */
WITH WT_PROD_TYPE AS
    (
        SELECT CASE 
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END   AS BRND_SORT
              ,BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY BRND_SORT, BRND_NM COLLATE "ko_KR.utf8", PROD_NM COLLATE "ko_KR.utf8", PROD_ID) -1 AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE
    )
    SELECT SORT_KEY  /* 정렬순서  */
          ,BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,PROD_ID   /* 제품코드  */
      FROM WT_PROD
  ORDER BY SORT_KEY

/* viewReviewBar.sql */
/* 1. 토픽별 바그래프 - 바 그래프 SQL */
/*    입력된 제품번호를 순서로 리턴하며, 리뷰가 없어도 Null로 리턴한다. */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_ITEM            AS TPIC_ITEM       /* 토픽 세부주제 하나를 입력한다. ex) '효능-미백' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
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
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM = (SELECT TPIC_ITEM FROM WT_WHERE)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.PROD_ID
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY
              ,A.PROD_ID
              ,(
                SELECT COALESCE(MAX(NAME), '') 
                  FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                 WHERE X.ID = A.PROD_ID
               ) AS PROD_NM
              ,(
                SELECT COALESCE(MAX(BRAND), '') 
                  FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                 WHERE X.ID = A.PROD_ID
               ) AS BRND_NM
              ,CASE WHEN (B.PSTV_CNT + B.NGTV_CNT) = 0 THEN 0 ELSE B.PSTV_CNT / (B.PSTV_CNT + B.NGTV_CNT) * 100 END AS PSTV_RATE
          FROM WT_PROD_WHERE A LEFT OUTER JOIN WT_SUM B
            ON(A.PROD_ID = B.PROD_ID)
    )
    SELECT SORT_KEY  /* 정렬순서  */
          ,PROD_ID   /* 제품코드  */
          ,PROD_NM   /* 제품 명   */
          ,BRND_NM   /* 브랜드 명 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE  /* 긍정비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY




2. 조회토픽 리뷰수/긍정 리뷰 수
    ==> 조회 기간은???
    ==> X축은 일자? 월?
    * 조회된 카테고리별, 토픽의 긍정리뷰 수와 비율이 그래프로 나오도록 
    * line 그래프 : 긍정리뷰 비율 
    * Bar그래프 : 조회 토픽 리뷰 수 

    필요 기능 : 
    [1] 카테고리 선택 : 원하는 카테고리를 선택한다.
        ==> 카테고리는 OVER_TMALL_ID_NAME 테이블에서 CATEGORY 컬럼을 DISTINCT 해서 보여주면 될까요???
            SELECT DISTINCT CATEGORY FROM OVER_TMALL_ID_NAME 
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 카테고리 선택 SQL */ 을 사용
    [2] 토픽 선택 기능 : 토픽을 선택 
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 대주제 선택 SQL */ 을 사용
            /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */ 을 사용        
    [3] 라인, 바 그래프 


/* topicRadarCategory.sql */
/* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 카테고리 선택 SQL */
WITH WT_CATE_SPLT_ORG AS
    (
        SELECT DISTINCT
               TRIM(REGEXP_SPLIT_TO_TABLE(CATEGORY, '/')) AS CATE_NM
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
    ), WT_CATE_SPLT_RE AS 
    (
        SELECT DISTINCT
               TRIM(REGEXP_SPLIT_TO_TABLE(CATE_NM, ',')) AS CATE_NM
          FROM WT_CATE_SPLT_ORG
         WHERE TRIM(CATE_NM) != '' 
    ), WT_CATE_SPLT AS 
    (
        SELECT ROW_NUMBER() OVER (ORDER BY CATE_NM COLLATE "ko_KR.utf8") AS SORT_KEY
              ,CATE_NM
          FROM WT_CATE_SPLT_RE
    )
    SELECT SORT_KEY  /* 정렬순서   */
          ,CATE_NM   /* 카테고리 명*/
      FROM WT_CATE_SPLT
  ORDER BY SORT_KEY


/* topicRadarTpicType.sql */
/* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 대주제 선택 SQL */
WITH WT_BASE AS
    (
        SELECT 1 AS SORT_KEY, '대주제' AS TPIC_TYPE UNION ALL
        SELECT 2 AS SORT_KEY, '효능'   AS TPIC_TYPE UNION ALL
        SELECT 3 AS SORT_KEY, 'CS'     AS TPIC_TYPE UNION ALL
        SELECT 4 AS SORT_KEY, '전체'   AS TPIC_TYPE UNION ALL
        SELECT 5 AS SORT_KEY, '기타'   AS TPIC_TYPE 
    )
    SELECT SORT_KEY   /* 정렬순서    */
          ,TPIC_TYPE  /* 토픽 대주제 */
      FROM WT_BASE
  ORDER BY SORT_KEY


/* topicRadarTpicTypeSub.sql */
/* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */
WITH WT_TPIC_TYPE AS
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
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE X WHERE X.TPIC_TYPE = A.TPIC_TYPE), TPIC_ITEM COLLATE "ko_KR.utf8") AS SORT_KEY
              ,TPIC_TYPE
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
    )
    SELECT SORT_KEY   /* 정렬순서      */
          ,TPIC_TYPE  /* 토픽 대주제   */
          ,TPIC_ITEM  /* 토픽 상세항목 */
      FROM WT_TPIC
  ORDER BY SORT_KEY


/* topicRadarBar.sql */
/* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 바 그래프 SQL */
/*    선택한 모든 토픽을 리턴한다. 없는 값은 Null로 린턴 */
/*    값이 없는 경우 제외하려면 WT_BASE의 WT_TPIC A LEFT OUTER JOIN WT_SUM B 을 INNER JOIN으로 변경한다. */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:CATE_NM              AS CATE_NM         /* 카테고리 명 하나를 입력한다. ex) '로션' */
              ,:TPIC_TYPE            AS TPIC_TYPE       /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(:TPIC_ITEM, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
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
          FROM WT_CATE_SPLT_RE
         WHERE CATE_NM = (SELECT CATE_NM FROM WT_WHERE)
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
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
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
        SELECT A.SORT_KEY
              ,A.TPIC_ITEM
              ,B.REVW_CNT
              ,CASE WHEN (B.PSTV_CNT + B.NGTV_CNT) = 0 THEN 0 ELSE B.PSTV_CNT / (B.PSTV_CNT + B.NGTV_CNT) * 100 END AS PSTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_SUM B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
    )
    SELECT SORT_KEY    /* 정렬순서      */
          ,TPIC_ITEM   /* 토픽 상세항목 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정 리뷰비율 - 라인 */
          ,REVW_CNT    /* 리뷰 수 - 바 */
      FROM WT_BASE
  ORDER BY SORT_KEY




3. 토픽별 레이더 그래프
    * 토픽별 레이더 그래프 : 분석기간과 토픽들을 선택 후 제품에 대한 토픽 분석 (양 옆으로 2개가 있어서 긍정과 부정으로 구분 서로 비교할 수 있어야함)
        ==> 긍/부정 선택기능 추가 (그래프는 1개로)

    필요기능 : 
    [1] 제품선택 : 단수선택
        ==> /* 1. 토픽별 바그래프 -  제품 선택 SQL */
    [2] 토픽 선택 : 대주제 토픽(대주제, 효능관련, cS관련, 전체, 기타 등으로 단수선택) 및 기타 선택시 세부 주제 선택 가능 복수선택가능
        ==> 토픽 대주제 선정 :  대주제 : '색상','스킨타입', '효능', '가격', '사용방법', '자극감', '제형', '사용감', '품질', '향취', '제품타입', 'CS', 
            효능 : '효능_세정력', '효능_보습', '효능_전달력', '효능_유분조절','효능_리페어','효능_픽서', '효능_메이크업미용수식', '효능_장시간유지', '효능_보습및유분조절', '효능_온화', '효능_자차'
            CS : 'CS_서비스', 'CS_반품',  'CS_배송'
            기타시 선택 가능하게
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 대주제 선택 SQL */ 을 사용
            /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */ 을 사용        
    [3] 기간 선택 : 분석 기간 선택 기능


/* topicRadar.sql */
/* 3. 토픽별 레이더 그래프 - 레이더 그래프 SQL */
/*    선택한 모든 토픽을 리턴한다. 없는 값은 Null로 린턴 */
/*    값이 없는 경우 제외하려면 WT_BASE의 WT_TPIC A LEFT OUTER JOIN WT_SUM B 을 INNER JOIN으로 변경한다. */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_TYPE            AS TPIC_TYPE       /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
              ,:PROD_ID              AS PROD_ID         /* 제품번호 하나를 입력한다. ex) 617136486827 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(:TPIC_ITEM, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
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
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID = (SELECT PROD_ID FROM WT_WHERE)
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
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID = (SELECT PROD_ID FROM WT_WHERE)
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
        SELECT A.SORT_KEY
              ,A.TPIC_ITEM
              ,CASE WHEN (B.PSTV_CNT + B.NGTV_CNT) = 0 THEN 0 ELSE B.PSTV_CNT / (B.PSTV_CNT + B.NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (B.PSTV_CNT + B.NGTV_CNT) = 0 THEN 0 ELSE B.NGTV_CNT / (B.PSTV_CNT + B.NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_TPIC A INNER JOIN WT_SUM B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
    )
    SELECT SORT_KEY   /* 정렬순서      */
          ,TPIC_ITEM  /* 토픽 상세항목 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE  /* 긍정 리뷰비율 */
          ,CAST(NGTV_RATE AS DECIMAL(20,2)) AS NGTV_RATE  /* 부정 리뷰비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY



4. 레이더 부연설명 그래프
    * 토픽별 레이더 그래프에 따라서 하단에는 토픽 
    * 바그래프 높이는 긍정비율
    * 바그래프는 제품긍정비율, 평균긍정비율, 업계최고, 업계 최저 긍정비율
        ==> 업계 최고, 최저는 선택된 카테고리의 최대 최저

    필요기능 : 
    [1] 3의 토픽별 레이더그래프와 동일한 토픽이 선택되어야함


/* radarTooltip.sql */
/* 4. 레이더 부연설명 그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_TYPE            AS TPIC_TYPE       /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
              ,:PROD_ID              AS PROD_ID         /* 제품번호 하나를 입력한다. ex) 617136486827 */
    ), WT_TPIC_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(TPIC_ITEM)      AS TPIC_ITEM
          FROM REGEXP_SPLIT_TO_TABLE(:TPIC_ITEM, ',') AS TPIC_ITEM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. 토픽 대주제가 기타의 경우 ex)'자극감,효능-미백,CS-배송' */        
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
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
    ), WT_SUM AS
    (
        SELECT A.TPIC_ITEM
              ,A.PROD_ID
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.TPIC_ITEM
              ,A.PROD_ID
    ), WT_RATE AS
    (
        SELECT TPIC_ITEM
              ,PROD_ID
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT SORT_KEY
              ,L_LGND
              ,TPIC_ITEM 
              ,MAX(PSTV_RATE) AS PSTV_RATE
          FROM (
                    SELECT 1              AS SORT_KEY
                          ,'제품긍정비율' AS L_LGND
                          ,A.TPIC_ITEM
                          ,B.PSTV_RATE
                      FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
                        ON (A.TPIC_ITEM = B.TPIC_ITEM)
                     WHERE B.PROD_ID = (SELECT PROD_ID FROM WT_WHERE)
                 UNION ALL
                    SELECT 1              AS SORT_KEY
                          ,'제품긍정비율' AS L_LGND
                          ,A.TPIC_ITEM
                          ,NULL           AS PSTV_RATE
                      FROM WT_TPIC A
               ) A
      GROUP BY SORT_KEY
              ,L_LGND
              ,TPIC_ITEM
     UNION ALL
        SELECT 2              AS SORT_KEY
              ,'평균긍정비율' AS L_LGND
              ,A.TPIC_ITEM
              ,AVG(PSTV_RATE) AS PSTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY A.TPIC_ITEM
     UNION ALL
        SELECT 3              AS SORT_KEY
              ,'업계최고'     AS L_LGND
              ,A.TPIC_ITEM
              ,MAX(PSTV_RATE) AS PSTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY A.TPIC_ITEM
     UNION ALL
        SELECT 4              AS SORT_KEY
              ,'업계최저'     AS L_LGND
              ,A.TPIC_ITEM
              ,MIN(PSTV_RATE) AS PSTV_RATE
          FROM WT_TPIC A LEFT OUTER JOIN WT_RATE B
            ON (A.TPIC_ITEM = B.TPIC_ITEM)
      GROUP BY A.TPIC_ITEM
    )
    SELECT A.TPIC_ITEM  /* 토픽 상세항목 - X축 */
          ,B.L_LGND     /* Legend */
          ,CAST(B.PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정리뷰 비율 - Y축 */
      FROM WT_TPIC A LEFT OUTER JOIN WT_BASE B
        ON (A.TPIC_ITEM = B.TPIC_ITEM)
  ORDER BY A.SORT_KEY
          ,B.SORT_KEY




5. 토픽별 시계열 그래프
    * 선택한 기간에 따른 토픽별 시계열그래프 : 기본값 누적으로 선택한 기간에 따라 선택한 토픽과 시계열을 비교할 수 있다. 

    필요기능 : 
    [1] 기간 선택 : 분석에 필요한 기간 선택 캘린더 스타일 
    [2] 누적 또는 시점별 선택 : 누적분석을 실시할지 시점분석을 실시할지 정함 
    [3] 토픽 선택 : 토픽을 선택한다. 단수선택 
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */ 을 사용
    [4] 제품 선택 : 제품을 선택하는것 복수선택가능  
        ==> /* 1. 토픽별 바그래프 -  제품 선택 SQL */ 을 사용


/* topicTimeSeries.sql */
/* 5. 토픽별 시계열 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_ITEM            AS TPIC_ITEM       /* 토픽 세부주제 하나를 입력한다. ex) '효능-미백' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_COPY AS
    (
        SELECT CAST(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 DAYS') AS DATE) AS X_DT
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,DATE
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
              ,DATE
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM = (SELECT TPIC_ITEM FROM WT_WHERE)
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,DATE
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
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
        SELECT A.PROD_ID
              ,CAST(A.DATE AS DATE) AS X_DT
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER AND A.DATE = B.DATE)
      GROUP BY A.PROD_ID
              ,A.DATE
    ), WT_CUM AS
    (
        SELECT B.PROD_ID
              ,A.X_DT
              ,B.REVW_CNT
              ,B.PSTV_CNT
              ,B.NGTV_CNT
              ,SUM(B.REVW_CNT) OVER(PARTITION BY B.PROD_ID ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(B.PSTV_CNT) OVER(PARTITION BY B.PROD_ID ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(B.NGTV_CNT) OVER(PARTITION BY B.PROD_ID ORDER BY A.X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
          FROM WT_COPY A LEFT OUTER JOIN WT_SUM B 
            ON (A.X_DT = B.X_DT)
    ), WT_BASE AS
    (
        SELECT (
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY
              ,A.PROD_ID
              ,(
                SELECT COALESCE(MAX(NAME), '') 
                  FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                 WHERE X.ID = A.PROD_ID
               ) AS PROD_NM
              ,(
                SELECT COALESCE(MAX(BRAND), '') 
                  FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                 WHERE X.ID = A.PROD_ID
               ) AS BRND_NM
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CUM + NGTV_CUM) = 0 THEN 0 ELSE PSTV_CUM / (PSTV_CUM + NGTV_CUM) * 100 END AS PSTV_RATE_CUM
          FROM WT_PROD_WHERE A LEFT OUTER JOIN WT_CUM B
            ON(A.PROD_ID = B.PROD_ID)
    )
    SELECT SORT_KEY  /* 정렬순서 */
          ,PROD_ID   /* 제품코드 */
          ,PROD_NM   /* 제품 명  - Legend */
          ,X_DT      /* 일자     - X축    */
          ,CAST(PSTV_RATE     AS DECIMAL(20,2)) AS PSTV_RATE      /* 긍정리뷰 비율 - 시점 Y축 */
          ,CAST(PSTV_RATE_CUM AS DECIMAL(20,2)) AS PSTV_RATE_CUM  /* 긍정리뷰 비율 - 누적 Y축 */
          ,REVW_CNT                  /* 리뷰 수 - 시점 (데이터 확인용) */
          ,REVW_CUM AS REVW_CNT_CUM  /* 리뷰 수 - 누적 (데이터 확인용) */
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT



6. 워드 크라우드
    * 토픽에 대한 워드크라우드 : 기간/제품/토픽 선택시 가장 많이 나오는 워드들이 등장하여야함 (중문1개 국문1개) 

    필요기능: 
    [1] 제품선택 : 개별제품이 선택되도록 해야함 복수선택가능
        ==> /* 1. 토픽별 바그래프 -  제품 선택 SQL */ 을 사용
    [2] 기간 선택 : 분석기간을 캘린더로 선택가능 
    [3] 토픽선택 : 토픽을 선택할 수 있게 하여야함 단수선택 
        ==> /* 2. 조회토픽 리뷰수/긍정 리뷰 수 - 토픽 세부주제 선택 SQL */ 을 사용
    [4] 토픽단어 제외기능: 해당 기능이 선택되면, 선택된 토픽의 단어가 제외된다. 
        ==> 워드크라우드는 단어별 빈도 기준 top 30개 보여주는 것 
            토픽단어 제거시 토픽단어 제외후 top 30개 보여주기
            토픽별 단어는 Google Spreadsheet에 있으므로 추후 athena 업데이트 또는 spreadsheet 링크로 활용
            spreadsheet link = "https://docs.google.com/spreadsheets/d/1PsFqYcjoqfOiCwZBIGR2KpZIv7XLbkQMDu5vetsWCRM/edit?usp=sharing"

        ==> 중국어 기준으로 Top 30개를 조회 후 API(제공예정)를 이용하여 한글로 번역하여 한글기준 Top 30개를 보여준다.


/* wordCloud.sql */
/* 6. 워드 크라우드 - 워드 크라우드 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_ITEM            AS TPIC_ITEM       /* 토픽 세부주제 하나를 입력한다. ex) '효능-미백' */
              ,:EXCT_TOPIC           AS EXCT_TOPIC      /*  EXCT_TOPIC (N:전체, 'Y':토픽단어 제외) 기본값 'N' */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_COPY AS
    (
        SELECT CAST(GENERATE_SERIES((SELECT FR_DT FROM WT_WHERE), (SELECT TO_DT FROM WT_WHERE), '1 DAYS') AS DATE) AS X_DT
    ), WT_DATA_TPIC_SPLT AS 
    (
        SELECT PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,DATE
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
              ,COUNT_VECT                               AS WORD_LIST
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
              ,TPIC_ITEM
              ,REPLACE(WORD_LIST, '''', '"') AS WORD_LIST 
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM = (SELECT TPIC_ITEM FROM WT_WHERE)
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