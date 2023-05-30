● 리뷰분석 - 0. Summary

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */


0. 화면 설명
    * Summary 페이지의 목표 : 리뷰 분석의 Summary 페이지를 보는 것
    * 주요 기능 : 채널별 비교와 합산 값 확인
    * 그래프 확대기능 요청
    * 기간선택전체

/* 데이터 확인이 필요함.. 일단 집계 테이블은 사용하지 않고, Raw Data를 집계하여 사용함. */
WITH WT_BASE AS
    (
        SELECT REVIEW_CNT       AS REVW_CNT   /* 자사제품 전체 리뷰수 */
              ,REVIEW_DIFF_DOD  AS REVW_RATE  /* 업데이트 된 리뷰수(어제 대비 오늘) */
              ,REVIEW_SENT_POS  AS PSTV_RATE  /* 긍정 리뷰 비율 */
              ,REVIEW_SENT_NEU  AS NTRL_RATE  /* 중립 리뷰 비율 */
              ,REVIEW_SENT_NEG  AS NGTV_RATE  /* 부정 리뷰 비율 */
          FROM REVIEW.SUM_IMPCARDAMTDATA
    )
    SELECT CAST(REVW_CNT  AS DECIMAL(20,0)) AS REVW_CNT   /* 자사제품 전체 리뷰수 */
          ,CAST(REVW_RATE AS DECIMAL(20,2)) AS REVW_RATE  /* 업데이트 된 리뷰수(어제 대비 오늘) */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE  /* 긍정 리뷰 비율 */
          ,CAST(NTRL_RATE AS DECIMAL(20,2)) AS NTRL_RATE  /* 중립 리뷰 비율 */
          ,CAST(NGTV_RATE AS DECIMAL(20,2)) AS NGTV_RATE  /* 부정 리뷰 비율 */
      FROM WT_BASE
;


/* 기존 제품명을 구하던 Function(REVIEW_RAW.SF_PROD_NM), Table(REVIEW_RAW.OVER_TMALL_ID_NAME)은 Tmall만을 위한 테이블로 Summary에서는 사용하지 않음. */
/* 대신 REVIEW_RAW.OVER_{channel}_BASE_TABLE 의 BRAND와 PROD_NAME을 사용함 */

1. 중요정보 카드
    * 카드 : 자사제품 전체리뷰수, 긍부정 값, 업데이트 된 리뷰수 (어제 대비 오늘)
/* 1. 중요정보카드 - 전체리뷰수, 긍부정 값, 업데이트 된 리뷰수 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(BASE_DT                                    AS DATE) AS BASE_DT        /* 기준일자 (어제)        */
              ,CAST(CAST(BASE_DT AS DATE) - INTERVAL '1' DAY   AS DATE) AS BASE_DT_DOD    /* 기준일자 (어제)   -1일 */
              ,CAST(CAST(BASE_DT AS DATE) - INTERVAL '1' MONTH AS DATE) AS BASE_MNTH      /* 기준일자 (어제)   -1월 */
              ,CAST(CAST(BASE_DT AS DATE) - INTERVAL '2' MONTH AS DATE) AS BASE_MNTH_MOM  /* 기준일자 (어제)   -2월 */
          FROM REVIEW.REVIEW_INITIAL_DATE
    ), WT_REVW_TOTL AS
    (
        SELECT CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
    ), WT_REVW_DAY AS
    (
        SELECT CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_REVW_DAY_DOD AS
    (
        SELECT CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE = (SELECT BASE_DT_DOD FROM WT_WHERE)
    ), WT_BASE AS
    (
        SELECT A.REVW_CNT
              ,B.REVW_CNT AS REVW_TDAY_CNT
              ,C.REVW_CNT AS REVW_YDAY_CNT
              ,CASE WHEN C.REVW_CNT = 0 THEN 0 ELSE (B.REVW_CNT - C.REVW_CNT) / C.REVW_CNT END AS REVW_RATE
              ,B.REVW_CNT - C.REVW_CNT AS REVW_DIFF
              ,A.PSTV_CNT
              ,A.NTRL_CNT
              ,A.NGTV_CNT
              ,A.PSTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS PSTV_RATE
              ,A.NTRL_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS NTRL_RATE
              ,A.NGTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS NGTV_RATE
          FROM WT_REVW_TOTL    A
              ,WT_REVW_DAY     B
              ,WT_REVW_DAY_DOD C
    )
    SELECT COALESCE(CAST(REVW_CNT      AS DECIMAL(20,0)), 0) AS REVW_CNT       /* 전체 수집 리뷰 수     */
          ,COALESCE(CAST(REVW_TDAY_CNT AS DECIMAL(20,0)), 0) AS REVW_TDAY_CNT  /* 오늘 수집 리뷰 수     */
          ,COALESCE(CAST(REVW_YDAY_CNT AS DECIMAL(20,0)), 0) AS REVW_YDAY_CNT  /* 어제 수집 리뷰 수     */
          ,COALESCE(CAST(REVW_RATE     AS DECIMAL(20,2)), 0) AS REVW_RATE      /* 전체 수집 리뷰 증감률 */
          ,COALESCE(CAST(PSTV_CNT      AS DECIMAL(20,0)), 0) AS PSTV_CNT       /* 긍정 리뷰 수          */
          ,COALESCE(CAST(NTRL_CNT      AS DECIMAL(20,0)), 0) AS NTRL_CNT       /* 중립 리뷰 수          */
          ,COALESCE(CAST(NGTV_CNT      AS DECIMAL(20,0)), 0) AS NGTV_CNT       /* 부정 리뷰 수          */
          ,COALESCE(CAST(PSTV_RATE     AS DECIMAL(20,2)), 0) AS PSTV_RATE      /* 긍정 리뷰 비율        */
          ,COALESCE(CAST(NTRL_RATE     AS DECIMAL(20,2)), 0) AS NTRL_RATE      /* 중립 리뷰 비율        */
          ,COALESCE(CAST(NGTV_RATE     AS DECIMAL(20,2)), 0) AS NGTV_RATE      /* 부정 리뷰 비율        */
          ,COALESCE(CAST(REVW_DIFF     AS DECIMAL(20,0)), 0) AS REVW_DIFF      /* 업데이트 된 리뷰수    */
      FROM WT_BASE
;

/* 1. 중요정보카드 - Chart SQL */
WITH WT_BASE AS
    (
        SELECT TO_CHAR(DATE, 'YYYY-MM')        AS REVW_MNTH
              ,CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
      GROUP BY TO_CHAR(DATE, 'YYYY-MM')
    )
    SELECT REVW_MNTH AS X_DT  /* 리뷰 월 */
          ,REVW_CNT  AS V_VAL /* 리뷰 수 */
      FROM WT_BASE
  ORDER BY REVW_MNTH
;

2. 채널 별 리뷰 지도
    * 채널 (tmall-global/china, douyin-global/china)의 토픽별 채널별 자사제품들의 map chart 작성 제품은 자사제품들을 매칭하여 비교

/* 2. 채널 별 리뷰 지도 - 채널 선택 SQL */
WITH WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    )
    SELECT SORT_KEY   /* 정렬순서 */
          ,CHNL_ID    /* 채널 ID  */
          ,CHNL_NM    /* 채널 명  */
      FROM WT_CHNL
  ORDER BY SORT_KEY
;

/* 2. 채널 별 리뷰 지도 - 토픽 선택 SQL */
WITH WT_TPIC_DATA AS
    (
        SELECT '전체'   AS TPIC_ITEM
     UNION ALL
        SELECT DISTINCT
               FIRST    AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE
    ), WT_TPIC AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY CASE WHEN TPIC_ITEM = '전체' THEN '' ELSE TPIC_ITEM END COLLATE "ko_KR.utf8") AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
    )
    SELECT SORT_KEY   /* 정렬순서      */
          ,TPIC_ITEM  /* 토픽 상세항목 */
      FROM WT_TPIC
  ORDER BY SORT_KEY
;

/* 2. 채널 별 리뷰 지도 - 트리 맵 그래프 SQL */
/* 기존 트리 맵 그래프는 브랜드별로 나누어 보여지고 브랜드를 클릭하면 제품이 나오는 구조임 */
/* Summary의 경우는 요구사항이 브랜드가 더마펌만 나오도록 요구하였기 때문에 */
/* Root -> 브랜드 -> 제품 이 아니고 Root -> 제품으로 변경이 필요함 */ 
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)         AS FR_DT      /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)         AS TO_DT      /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,COALESCE(:WITH_FAKE, 'N'   ) AS WITH_FAKE  /*  WITH_FAKE (Y:비정상리뷰 포함, 'N':비정상리뷰 불포함) 기본값 'N' */
              ,COALESCE(:CHNL_ID,   'DGT' ) AS CHNL_ID    /* 채널 ID */
              ,COALESCE(:TPIC_ITEM, '전체') AS TPIC_ITEM  /* 토픽 대주제 (전체, 효능, CS,) ex) 효능 */
              ,COALESCE(:PSNG_TYPE, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */
    ), WT_PROD AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DCT' = (SELECT CHNL_ID FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DGT' = (SELECT CHNL_ID FROM WT_WHERE)
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DCD' = (SELECT CHNL_ID FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND 'DGD' = (SELECT CHNL_ID FROM WT_WHERE)
    ), WT_TPIC AS
    (
        SELECT DISTINCT
               FIRST AS TPIC_ITEM
          FROM REVIEW_RAW.TOPIC_TABLE A
         WHERE FIRST = CASE WHEN (SELECT TPIC_ITEM FROM WT_WHERE) = '전체' THEN FIRST ELSE (SELECT TPIC_ITEM FROM WT_WHERE) END
    ), WT_DATA_TPIC_SPLT AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TRIM(REGEXP_SPLIT_TO_TABLE(TOPICS, '/')) AS TPIC_ITEM
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCT' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGT' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCD' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_TOPIC_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGD' = (SELECT CHNL_ID FROM WT_WHERE)
               ) A
    ), WT_DATA_TPIC AS
    (
        SELECT DISTINCT
               CHNL_ID
              ,PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
              ,TPIC_ITEM
          FROM WT_DATA_TPIC_SPLT
         WHERE TPIC_ITEM IN (SELECT X.TPIC_ITEM FROM WT_TPIC X)
    ), WT_DATA_REVW AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NAME AS PROD_NM
              ,B.BRAND     AS BRND_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCT' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGT' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DCD' = (SELECT CHNL_ID FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND 'DGD' = (SELECT CHNL_ID FROM WT_WHERE)
               ) A LEFT OUTER JOIN 
               WT_PROD B
            ON (A.CHNL_ID = B.CHNL_ID AND A.DATE = B.DATE AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID)
         WHERE B.BRAND = '더마펌'
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NAME
              ,B.BRAND
    ), WT_SUM AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
              ,SUM(REVW_CNT) AS REVW_CNT
              ,SUM(PSTV_CNT) AS PSTV_CNT
              ,SUM(NTRL_CNT) AS NTRL_CNT
              ,SUM(NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_REVW A INNER JOIN
               WT_DATA_TPIC B
            ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
    ), WT_BASE AS
    (
        SELECT PROD_ID
              ,COALESCE(PROD_NM , PROD_ID      ) AS PROD_NM
              ,COALESCE(BRND_NM , '브랜드 미상') AS BRND_NM
              ,REVW_CNT
              ,PSTV_CNT
              ,NTRL_CNT
              ,NGTV_CNT
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NTRL_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NTRL_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SUM A
    )
    SELECT BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,REVW_CNT  /* 리뷰 수   */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS REVW_RATE /* 긍/부정 리뷰 비율 0 ~ 100 (색변경) */
          ,PROD_ID   /* 제품코드  */
      FROM WT_BASE
  ORDER BY BRND_NM
          ,PROD_NM
;

3. 전월 대비 긍정/부정 비율 변화
    * 전월대비 긍정 부정 순위가 채널별로 (tmall-global/china, douyin-global/china) 나올 수 있도록
    * 제품 명이 나와아됨

/* 3. 전월 대비 긍정/부정 비율 변화 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '1' MONTH)                              AS DATE) AS FR_DT      /* 오늘기준 -1개월  1일 ex) '2023-02-01' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '1' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT      /* 오늘기준 -1개월 말일 ex) '2023-02-28' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '2' MONTH)                              AS DATE) AS FR_DT_MOM  /* 오늘기준 -2개월  1일 ex) '2023-01-01' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '2' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT_MOM  /* 오늘기준 -2개월 말일 ex) '2023-01-31' */
              ,COALESCE(:PSNG_TYPE, 'PSTV')                                                                               AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PGTV  */
          FROM REVIEW.REVIEW_INITIAL_DATE
    ), WT_CHNL AS
    (
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_COPY AS
    (
        SELECT 1 AS REVW_RANK
     UNION ALL
        SELECT 2 AS REVW_RANK
     UNION ALL
        SELECT 3 AS REVW_RANK
     UNION ALL
        SELECT 4 AS REVW_RANK
     UNION ALL
        SELECT 5 AS REVW_RANK
    ), WT_COPY_CHNL AS
    (
        SELECT SORT_KEY
              ,CHNL_ID
              ,CHNL_NM
              ,REVW_RANK
          FROM WT_CHNL A
              ,WT_COPY B
    ), WT_PROD AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_PROD_MOM AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE)
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
              ,REVIEW_ID
              ,DATE
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE)
    ), WT_REVW_SUM AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,B.PROD_NAME AS PROD_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
               ) A LEFT OUTER JOIN 
               WT_PROD B
            ON (A.CHNL_ID = B.CHNL_ID AND A.DATE = B.DATE AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID)
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,B.PROD_NAME
        HAVING COUNT(*) > 100
    ), WT_REVW_SUM_MOM AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,B.PROD_NAME AS PROD_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
               ) A LEFT OUTER JOIN 
               WT_PROD_MOM B
            ON (A.CHNL_ID = B.CHNL_ID AND A.DATE = B.DATE AND A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID)
      GROUP BY A.CHNL_ID
              ,A.PROD_ID
              ,B.PROD_NAME
        HAVING COUNT(*) > 100
    ), WT_REVW_RATE AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,PROD_NM
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NTRL_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NTRL_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM
    ), WT_REVW_RATE_MOM AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,PROD_NM
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NTRL_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NTRL_RATE
              ,CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM_MOM
    ), WT_REVW_COMP AS
    (
        SELECT A.CHNL_ID
              ,A.PROD_ID
              ,A.PROD_NM
              ,A.PSTV_RATE - B.PSTV_RATE AS PSTV_CHNG
              ,A.NGTV_RATE - B.NGTV_RATE AS NGTV_CHNG
          FROM WT_REVW_RATE A INNER JOIN WT_REVW_RATE_MOM B 
            ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID)
    ), WT_PSTV_RANK AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,PROD_NM
              ,PSTV_CHNG
              ,NGTV_CHNG
              ,ROW_NUMBER() OVER(PARTITION BY CHNL_ID ORDER BY PSTV_CHNG DESC, PROD_ID) AS PSTV_RANK
              ,ROW_NUMBER() OVER(PARTITION BY CHNL_ID ORDER BY NGTV_CHNG DESC, PROD_ID) AS NGTV_RANK
          FROM WT_REVW_COMP
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.CHNL_ID
              ,A.REVW_RANK
              ,B.PROD_NM AS PSTV_PROD_NM
              ,C.PROD_NM AS NGTV_PROD_NM
              ,B.PSTV_CHNG
              ,C.NGTV_CHNG
              ,B.PSTV_RANK
              ,C.NGTV_RANK
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_COPY_CHNL A LEFT OUTER JOIN WT_PSTV_RANK B ON (A.CHNL_ID = B.CHNL_ID AND A.REVW_RANK = B.PSTV_RANK)
                              LEFT OUTER JOIN WT_PSTV_RANK C ON (A.CHNL_ID = C.CHNL_ID AND A.REVW_RANK = C.NGTV_RANK)
    )
    SELECT REVW_RANK  /* 순위 1~5 */
          ,MAX(     CASE WHEN CHNL_ID = 'DGT' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_PROD_NM ELSE NGTV_PROD_NM END END                  ) AS DGT_PROD_NM  /* 티몰 글로벌   - 변화 Top5 제품명 */
          ,MAX(     CASE WHEN CHNL_ID = 'DCT' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_PROD_NM ELSE NGTV_PROD_NM END END                  ) AS DCT_PROD_NM  /* 티몰 내륙     - 변화 Top5 제품명 */
          ,MAX(     CASE WHEN CHNL_ID = 'DGD' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_PROD_NM ELSE NGTV_PROD_NM END END                  ) AS DGD_PROD_NM  /* 도우인 글로벌 - 변화 Top5 제품명 */
          ,MAX(     CASE WHEN CHNL_ID = 'DCD' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_PROD_NM ELSE NGTV_PROD_NM END END                  ) AS DCD_PROD_NM  /* 도우인 내륙   - 변화 Top5 제품명 */
          ,MAX(CAST(CASE WHEN CHNL_ID = 'DGT' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_CHNG    ELSE NGTV_CHNG    END END AS DECIMAL(20,2))) AS DGT_RATE     /* 티몰 글로벌   - 변화 Top5 제품명 */
          ,MAX(CAST(CASE WHEN CHNL_ID = 'DCT' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_CHNG    ELSE NGTV_CHNG    END END AS DECIMAL(20,2))) AS DCT_RATE     /* 티몰 내륙     - 변화 Top5 제품명 */
          ,MAX(CAST(CASE WHEN CHNL_ID = 'DGD' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_CHNG    ELSE NGTV_CHNG    END END AS DECIMAL(20,2))) AS DGD_RATE     /* 도우인 글로벌 - 변화 Top5 제품명 */
          ,MAX(CAST(CASE WHEN CHNL_ID = 'DCD' THEN CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_CHNG    ELSE NGTV_CHNG    END END AS DECIMAL(20,2))) AS DCD_RATE     /* 도우인 내륙   - 변화 Top5 제품명 */
      FROM WT_BASE
  GROUP BY REVW_RANK
  ORDER BY REVW_RANK
;

4. 채널 별 긍부정 시계열 그래프
    * 제품을 선택하면 각 채널도 나오고 채널의 합도 나올 수 있도록 5개 (전체, 티몰 글로벌/내륙, 도우인 글로벌/내륙)

/* 4. 채널 별 긍부정 시계열 그래프 - 제품 선택 */
WITH WT_PROD_TYPE AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END       AS BRND_SORT
              ,BRAND     AS BRND_NM
              ,PROD_NAME AS PROD_NM
              ,PROD_ID   AS PROD_ID
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END       AS BRND_SORT
              ,BRAND     AS BRND_NM
              ,PROD_NAME AS PROD_NM
              ,PROD_ID   AS PROD_ID
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END       AS BRND_SORT
              ,BRAND     AS BRND_NM
              ,PROD_NAME AS PROD_NM
              ,PROD_ID   AS PROD_ID
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,CASE
                 WHEN BRAND = '더마펌'     THEN 1 
                 WHEN BRAND = '더블유랩'   THEN 2
                 WHEN BRAND = '닥터마인드' THEN 3
                 ELSE 9 
               END       AS BRND_SORT
              ,BRAND     AS BRND_NM
              ,PROD_NAME AS PROD_NM
              ,PROD_ID   AS PROD_ID
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
    ), WT_PROD_ALL AS
    (
        SELECT DISTINCT 
               BRND_SORT
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY BRND_SORT, BRND_NM COLLATE "ko_KR.utf8", PROD_NM COLLATE "ko_KR.utf8", PROD_ID) AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_ALL
    )
    SELECT SORT_KEY  /* 정렬순서  */
          ,BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,PROD_ID   /* 제품코드  */
      FROM WT_PROD
  ORDER BY SORT_KEY
;

/* 4. 채널 별 긍부정 시계열 그래프 - 시계열 그래프 SQL */
/* 요구사항은 "제품을 선택하면 각 채널도 나오고 채널의 합도 나올 수 있도록 5개 (전체, 티몰 글로벌/내륙, 도우인 글로벌/내륙)" 이지만 */
/* 그런 제품번호는 없음. 모든 제품번호는 전체와 특정 한개의 채널만 나옴. */

WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)         AS FR_DT      /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)         AS TO_DT      /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,COALESCE(:PSNG_TYPE, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'658100483482,652094627119,619327829460' */
    ), WT_CHNL AS
    (
        SELECT 0                AS SORT_KEY
              ,'ALL'            AS CHNL_ID
              ,'전체'           AS CHNL_NM
     UNION ALL
        SELECT 1                AS SORT_KEY
              ,'DCT'            AS CHNL_ID
              ,'Tmall 내륙'     AS CHNL_NM
     UNION ALL
        SELECT 2                AS SORT_KEY
              ,'DGT'            AS CHNL_ID
              ,'Tmall 글로벌'   AS CHNL_NM
     UNION ALL
        SELECT 3                AS SORT_KEY
              ,'DCD'            AS CHNL_ID
              ,'Douyin 내륙'    AS CHNL_NM
     UNION ALL
        SELECT 4                AS SORT_KEY
              ,'DGD'            AS CHNL_ID
              ,'Douyin 글로벌'  AS CHNL_NM
    ), WT_PROD_TYPE AS
    (
        SELECT 'DCT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
          FROM REVIEW_RAW.OVER_DCT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGT' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
          FROM REVIEW_RAW.OVER_DGT_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
          FROM REVIEW_RAW.OVER_DCD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,BRAND
              ,PROD_NAME
              ,PROD_ID
          FROM REVIEW_RAW.OVER_DGD_BASE_TABLE A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    ), WT_PROD AS
    (
        SELECT DISTINCT
               CHNL_ID
              ,PROD_ID   AS PROD_ID
              ,PROD_NAME AS PROD_NM
          FROM WT_PROD_TYPE
    ), WT_DATA_REVW AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,CAST(DATE                                              AS DATE         ) AS X_DT                           
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID, A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
               ) A
      GROUP BY CHNL_ID
              ,PROD_ID
              ,DATE
    ), WT_SUM AS
    (
        SELECT CHNL_ID
              ,PROD_ID
              ,X_DT
              ,REVW_CNT
              ,PSTV_CNT
              ,NTRL_CNT
              ,NGTV_CNT
              ,SUM(REVW_CNT) OVER(PARTITION BY CHNL_ID, PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(PSTV_CNT) OVER(PARTITION BY CHNL_ID, PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(NTRL_CNT) OVER(PARTITION BY CHNL_ID, PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NTRL_CUM
              ,SUM(NGTV_CNT) OVER(PARTITION BY CHNL_ID, PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_DATA_REVW A 
    ), WT_BASE AS
    (
        SELECT A.CHNL_ID
              ,(
                SELECT CHNL_NM
                  FROM WT_CHNL X
                 WHERE X.CHNL_ID = A.CHNL_ID
               ) AS CHNL_NM
              ,(
                SELECT SORT_KEY
                  FROM WT_CHNL X
                 WHERE X.CHNL_ID = A.CHNL_ID
               ) AS CHNL_SORT_KEY  /* 정렬순서 */
              ,A.PROD_ID
              ,B.PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END
                 ELSE CASE WHEN (PSTV_CNT + NTRL_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NTRL_CNT + NGTV_CNT) * 100 END
               END AS REVW_RATE
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN (PSTV_CUM + NTRL_CNT + NGTV_CUM) = 0 THEN 0 ELSE PSTV_CUM / (PSTV_CUM + NTRL_CNT + NGTV_CUM) * 100 END
                 ELSE CASE WHEN (PSTV_CUM + NTRL_CNT + NGTV_CUM) = 0 THEN 0 ELSE NGTV_CUM / (PSTV_CUM + NTRL_CNT + NGTV_CUM) * 100 END
               END AS REVW_RATE_CUM
          FROM WT_SUM A LEFT OUTER JOIN WT_PROD B ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID)
     UNION ALL
        SELECT 'ALL' AS CHNL_ID
              ,(
                SELECT CHNL_NM
                  FROM WT_CHNL X
                 WHERE X.CHNL_ID = 'ALL'
               ) AS CHNL_NM
              ,(
                SELECT SORT_KEY
                  FROM WT_CHNL X
                 WHERE X.CHNL_ID = 'ALL'
               ) AS CHNL_SORT_KEY  /* 정렬순서 */
              ,A.PROD_ID
              ,B.PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,SUM(REVW_CNT) AS REVW_CNT
              ,SUM(REVW_CUM) AS REVW_CUM
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(PSTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END
                 ELSE CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(NGTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END
               END AS REVW_RATE
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN (SUM(PSTV_CUM) + SUM(NTRL_CNT) + SUM(NGTV_CUM)) = 0 THEN 0 ELSE SUM(PSTV_CUM) / (SUM(PSTV_CUM) + SUM(NTRL_CNT) + SUM(NGTV_CUM)) * 100 END
                 ELSE CASE WHEN (SUM(PSTV_CUM) + SUM(NTRL_CNT) + SUM(NGTV_CUM)) = 0 THEN 0 ELSE SUM(NGTV_CUM) / (SUM(PSTV_CUM) + SUM(NTRL_CNT) + SUM(NGTV_CUM)) * 100 END
               END AS REVW_RATE_CUM
          FROM WT_SUM A LEFT OUTER JOIN WT_PROD B ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_ID = B.PROD_ID)
      GROUP BY A.PROD_ID
              ,B.PROD_NM
              ,X_DT
              ,PSNG_TYPE
    )
    SELECT SORT_KEY                              /* 정렬순서 */
          ,CHNL_SORT_KEY
          ,PROD_ID                               /* 제품코드 */
          ,PROD_NM ||' - '|| CHNL_NM AS PROD_NM  /* 제품 명  */
          ,X_DT                                  /* 일자    */
          ,CAST(REVW_RATE     AS DECIMAL(20,2)) AS REVW_RATE      /* 리뷰 비율 - 시점 (라인) */
          ,CAST(REVW_RATE_CUM AS DECIMAL(20,2)) AS REVW_RATE_CUM  /* 리뷰 비율 - 누적 (라인) */
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,CHNL_SORT_KEY
          ,X_DT
;