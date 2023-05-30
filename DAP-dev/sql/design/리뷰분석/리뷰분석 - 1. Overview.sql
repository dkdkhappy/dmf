● 리뷰분석 - 1. Overview

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */

/* REVIEW 에서 사용하는 Function */

/* 제품명 Function */
CREATE OR REPLACE FUNCTION review_raw.sf_prod_nm(p_prod_id text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
    DECLARE V_PROD_NM text ;
BEGIN
    -- 제품 ID 뒤에 공백이 생기는 경우가 있어 LIKE로 변경
    SELECT COALESCE(MAX(NAME), '')
      INTO V_PROD_NM
      FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
     WHERE ID LIKE TRIM(P_PROD_ID)||'%' ;

    RETURN V_PROD_NM ;

END;
$function$
;

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




카테고리 : over_tmall_cat_apeal
토픽     : topic_table 이고 대주제는 first의 distict값을 쓰시면 됩니다 
토픽별 단어제외 목록 : topic_words의 단어를 사용하시면 됩니다


/* 1. 중요정보카드 - 수집 리뷰수, 긍정vs부정, 긍/부정 변환 1위 SQL */                  sentimentAnalysisReviewsStats.sql
/* 1. 중요정보카드 - Chart SQL */                                                      sentimentAnalysisReviewsStatsChart.sql
/* 2. 제품별 리뷰지도 - 트리 맵 그래프 SQL */                                            productReviewTreeMap.sql
/* 3. 토픽별/제품별 히트맵 overview - 토픽 대주제 선택 SQL */                          topicProductHeatmapOverviewTopic.sql
/* 3. 토픽별/제품별 히트맵 overview - 토픽 세부주제 선택 SQL */                        topicProductHeatmapOverviewSub.sql
/* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */                                 topicProductHeatmapOverviewProd.sql
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (Y축 토픽) SQL */                   topicProductHeatmapOverviewTopicHeatMapTopic.sql
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (X축 제품) SQL */                   topicProductHeatmapOverviewTopicHeatMapProd.sql
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */                              topicProductHeatmapOverviewTopicHeatMap.sql
/* 4. 제품별 토픽순위 Bar 그래프 - 바 그래프 SQL */                                        productTopicRankingBarChart.sql
/* 5. 카테고리별 / 토픽 100% 바그래프 - 카테고리 선택 SQL */                             categoryTopic100pBarChartCategory.sql
/* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 SQL */                                   categoryTopic100pBarChart.sql
/* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 전체, 카테고리, 자사제품 선택 SQL */   productSentimentChangeRankingPreMonth.sql
/* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */                       productSentimentChangeRankingPreMonthData.sql
/* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */                              productSentimentRatioTimeSeriesChart.sql
/* 8. 제품별 리뷰속성그래프 - 스택 바 그래프 SQL */                                        productReviewAttributeChart.sql


1. 중요정보카드
    ==> 기준일자는???   --> 전체
    ==> 리뷰 수의 기준은??? 
         테이블의 REVIEW_ID 컬럼 기준으로 Count
        (※ SENTENCE_ORDER 컬럼은 긴 문장을 단순히 Line 으로 나눈 Line 번호로 보임.)
        line기준 맞음


    * 전체 수집 리뷰수 : 총 누적 리뷰 수
        ==> 기준일자는???   전체
        ==> 리뷰그래프 기준기간은??? 월간기준 전체 
    * 수집된 리뷰의 긍정 부정 비중 : 누적 긍정 비율 
        ==> 긍정비율, 부정비율
	        전체리뷰(sentence order line) 중 긍정비율 전체 리뷰중 부정비율
    * 더마펌 제품 중 긍정 변화 1위 : 자사 제품 중 긍정비율의 MoM이 가장 높은 것
        ==> 제품명 + 증감률
    * 더마펌 제품 중 부정 변화 1위 : 자사 제품 중 부정비율의 MoM이 가장 낮은 것 
        ==> 제품명 + 증감률


    ※ 제품 마스터 테이블
        ==> OVER_TMALL_ID_NAME  중간 TMALL 은 고정인가? 도우인에서는???
            티몰은 고정이고 도우인은 따로 (추후 도우인쪽 SQL 테이블명 변수 처리 시 확인필요!!)



/* sentimentAnalysisReviewsStats.sql */
/* 1. 중요정보카드 - 수집 리뷰수, 긍정vs부정, 긍/부정 변환 1위 SQL */
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
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
    ), WT_REVW_DAY AS
    (
        SELECT CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE = (SELECT BASE_DT FROM WT_WHERE)
    ), WT_REVW_DAY_DOD AS
    (
        SELECT CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE = (SELECT BASE_DT_DOD FROM WT_WHERE)
    ), WT_CHNG AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH)                              AS DATE) FROM WT_WHERE) 
                        AND (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) FROM WT_WHERE)
      GROUP BY PROD_ID
    ), WT_CNHG_MOM AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH_MOM)                              AS DATE) FROM WT_WHERE) 
                        AND (SELECT CAST(DATE_TRUNC('MONTH', BASE_MNTH_MOM) + INTERVAL '1 MONTH - 1 DAY' AS DATE) FROM WT_WHERE) 
      GROUP BY PROD_ID
    ), WT_CHNG_RATE AS
    (
        SELECT A.PROD_ID
              ,(A.PSTV_CNT / A.REVW_CNT * 100) - (B.PSTV_CNT / B.REVW_CNT * 100) AS PSTV_RATE
              ,(A.NGTV_CNT / A.REVW_CNT * 100) - (B.NGTV_CNT / B.REVW_CNT * 100) AS NGTV_RATE
          FROM WT_CHNG A INNER JOIN WT_CNHG_MOM B ON (A.PROD_ID = B.PROD_ID)
    ), WT_CHGN_RANK AS
    (
        SELECT PROD_ID
              ,PSTV_RATE
              ,NGTV_RATE
              ,RANK() OVER(ORDER BY PSTV_RATE DESC, PROD_ID) AS PSTV_RANK
              ,RANK() OVER(ORDER BY NGTV_RATE DESC, PROD_ID) AS NGTV_RANK
          FROM WT_CHNG_RATE 
    ), WT_BASE AS
    (
        SELECT A.REVW_CNT
              ,CASE WHEN C.REVW_CNT = 0 THEN 0 ELSE (B.REVW_CNT - C.REVW_CNT) / C.REVW_CNT * 100 END AS REVW_RATE
              ,A.PSTV_CNT
              ,A.NTRL_CNT
              ,A.NGTV_CNT
              ,A.PSTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS PSTV_RATE
              ,A.NTRL_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS NTRL_RATE
              ,A.NGTV_CNT / (A.PSTV_CNT + A.NTRL_CNT + A.NGTV_CNT) * 100 AS NGTV_RATE
              ,REVIEW_RAW.SF_PROD_NM(D.PROD_ID) AS PSTV_PROD_NM
              ,D.PSTV_RATE                      AS PSTV_RATE_CHNG
              ,REVIEW_RAW.SF_PROD_NM(E.PROD_ID) AS NGTV_PROD_NM
              ,E.NGTV_RATE                      AS NGTV_RATE_CHNG
          FROM WT_REVW_TOTL    A
              ,WT_REVW_DAY     B
              ,WT_REVW_DAY_DOD C
              ,(
                SELECT PROD_ID
                      ,PSTV_RATE
                  FROM WT_CHGN_RANK
                 WHERE PSTV_RANK = 1
              ) D
              ,(
                SELECT PROD_ID
                      ,NGTV_RATE
                  FROM WT_CHGN_RANK
                 WHERE NGTV_RANK = 1
              ) E
    )
    SELECT COALESCE(CAST(REVW_CNT  AS DECIMAL(20,0)), 0) AS REVW_CNT    /* 전체 수집 리뷰 수     */
          ,COALESCE(CAST(REVW_RATE AS DECIMAL(20,2)), 0) AS REVW_RATE   /* 전체 수집 리뷰 증감률 */
          ,COALESCE(CAST(PSTV_CNT  AS DECIMAL(20,0)), 0) AS PSTV_CNT    /* 긍정 리뷰 수          */
          ,COALESCE(CAST(NTRL_CNT  AS DECIMAL(20,0)), 0) AS NTRL_CNT    /* 중립 리뷰 수          */
          ,COALESCE(CAST(NGTV_CNT  AS DECIMAL(20,0)), 0) AS NGTV_CNT    /* 부정 리뷰 수          */
          ,COALESCE(CAST(PSTV_RATE AS DECIMAL(20,2)), 0) AS PSTV_RATE   /* 긍정 리뷰 비율        */
          ,COALESCE(CAST(NTRL_RATE AS DECIMAL(20,2)), 0) AS NTRL_RATE   /* 중립 리뷰 비율        */
          ,COALESCE(CAST(NGTV_RATE AS DECIMAL(20,2)), 0) AS NGTV_RATE   /* 부정 리뷰 비율        */
          ,PSTV_PROD_NM                                                          /* 긍정 변화 제품명      */
          ,COALESCE(CAST(PSTV_RATE_CHNG AS DECIMAL(20,2)), 0) AS PSTV_RATE_CHNG  /* 긍정 변화 증감률      */
          ,NGTV_PROD_NM                                                          /* 부정 변화 제품명      */
          ,COALESCE(CAST(NGTV_RATE_CHNG AS DECIMAL(20,2)), 0) AS NGtV_RATE_CHNG  /* 부정 변화 증감률      */
      FROM WT_BASE
;

/* sentimentAnalysisReviewsStatsChart.sql */
/* 1. 중요정보카드 - Chart SQL */
WITH WT_BASE AS
    (
        SELECT TO_CHAR(DATE, 'YYYY-MM')        AS REVW_MNTH
              ,CAST(COUNT(*) AS DECIMAL(20,2)) AS REVW_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
      GROUP BY TO_CHAR(DATE, 'YYYY-MM')
    )
    SELECT REVW_MNTH AS X_DT  /* 리뷰 월 */
          ,REVW_CNT  AS V_VAL /* 리뷰 수 */
      FROM WT_BASE
  ORDER BY REVW_MNTH


2. 제품별 리뷰지도
    * 리뷰 트리 맵  : 선택한 기간에 대한 리뷰수가 크기, 리뷰 긍부정도가 색상인 트리맵 필요(트리는 드릴다운 될 수 있으면 좋겠음(브랜드, 제품) 순으로) 
        ==> 계층구조는???
            1 Level : 브랜드
            2 Level : 제품
            --여기까지 ---
            3 Level : 긍정, 부정 --> 이건 색깔로 표기합니다. 
              Value : 긍정, 부정 리뷰 수 --> 이건 리뷰수는 크기에 영향을 미칩니다
    필요 기능 : 
    [1] 기간 선택 기능  : 분석할 기간 선택 
        ==> 기준일자는???
            이전 3달

    [2] 비정상리뷰 포함기능 : 기본값 비정상리뷰 제외, 버튼을 클릭하면 비정상리뷰가 갯수로 포함된다.
        ==> 비정상 리뷰의 정의는???
            REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL.FAKE (1:비정상, 0:정상)


/* productReviewTreeMap.sql */
/* 2. 제품별 리뷰지도 - 트리 맵 그래프 SQL */
/* ※ OVER_DGT_REVIEW_SENTENCE_TABLE 테이블의 PROD_ID 컬럼 값 끝에 스페이스가 포함되어 있음 */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:WITH_FAKE            AS WITH_FAKE       /*  WITH_FAKE (Y:비정상리뷰 포함, 'N':비정상리뷰 불포함) 기본값 'N' */
    ), WT_PROD_TYPE AS
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
    ), WT_SUM AS
    (
        SELECT A.PROD_ID
              ,B.NAME    AS PROD_NM
              ,B.BRAND   AS BRND_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
               ) A LEFT OUTER JOIN 
               REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME B
            ON(A.PROD_ID = B.ID)
         WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
      GROUP BY A.PROD_ID
              ,B.NAME
              ,B.BRAND
    ), WT_BASE AS
    (
        SELECT A.PROD_ID
              ,COALESCE(B.PROD_NM , A.PROD_ID    ) AS PROD_NM
              ,COALESCE(B.BRND_NM , '브랜드 미상') AS BRND_NM
              ,COALESCE(B.SORT_KEY, 9            ) AS SORT_KEY 
              ,REVW_CNT
              ,PSTV_CNT
              ,NGTV_CNT
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_SUM A LEFT OUTER JOIN WT_PROD B 
            ON (A.PROD_ID = B.PROD_ID)
    )
    SELECT BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,REVW_CNT  /* 리뷰 수   */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정리뷰 비율 0 ~ 100 (색변경) */
          ,PROD_ID   /* 제품코드  */
      FROM WT_BASE
  ORDER BY SORT_KEY
          


3. 토픽별/제품별 히트맵 overview
    * 토픽별 히트맵 : 선택한 제품들과 기간 그리고 토픽의 히트맵 안의 색상은 토픽에 따른 긍정도 만약 정보가 없으면 빈칸 (색상없음) 
    * 사용자가 선택하기 쉽게 토픽에 대한 대주제 포함되어야함 

    필요 기능 : 
    기간 : 최근 3달 ()
    [1] 세로축 : 토픽들 , 가로축 : 제품들 (제품명이 너무 길면 15자에서 끊어야함)
    [2] 마우스오버 :  (제품 : 긍정비율 :: ) 등의 수치들이 나와야함
    [3] 토픽선택 : 대주제 선택(대주제, 효능관련, Cs관련, 전체, 기타 중 하나 선택) 그중 기타 선택시 세부주제 선택가능 복수선택 
        ==> 토픽 대주제 선정 :  대주제 : '색상','스킨타입', '효능', '가격', '사용방법', '자극감', '제형', '사용감', '품질', '향취', '제품타입', 'CS', 
            효능 : '효능_세정력', '효능_보습', '효능_전달력', '효능_유분조절','효능_리페어','효능_픽서', '효능_메이크업미용수식', '효능_장시간유지', :::{'효능_보습및유분조절'}:::제외:::, '효능_온화', '효능_자차'
            CS : 'CS_서비스', 'CS_반품',  'CS_배송'
            기타시 선택 가능하게
            테이블 만들어 놓기  --> 디비에다 만들기 
        ==> 토픽을 선택한다면 선택한 제품의 리뷰 중 해당 토픽에 해당하는 리뷰만 필터링 해서 긍정비율을 구하면 될까요??? 네 맞습니다 
    [4] 제품선택 : 제품들을 선택 복수선택 가능


/* topicProductHeatmapOverviewTopic.sql */
/* 3. 토픽별/제품별 히트맵 overview - 토픽 대주제 선택 SQL */
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


/* topicProductHeatmapOverviewSub.sql */
/* 3. 토픽별/제품별 히트맵 overview - 토픽 세부주제 선택 SQL */
/*    토픽 대주제 -> 기타 선택 시 조회                       */
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


/* topicProductHeatmapOverviewProd.sql */
/* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */
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


/* topicProductHeatmapOverviewTopicHeatMapTopic */
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (Y축 토픽) SQL */
/* 히트 맵은 Y축 데이터를 생성할 때 아래부터 위의 순서로 나와야한다. */
/* Data를 셋팅할때 [0, 0, 1]  [Y, X, Value] 로 셋팅하기 때문에...    */
/* SQL의 결과는 토픽 대주제가 기타의 경우에만 사용자가 입력한 제품 순서대로 정렬되어 리턴된다. */
WITH WT_WHERE AS
    (
        SELECT :TPIC_TYPE AS TPIC_TYPE   /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
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
                 THEN ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_WHERE X WHERE X.TPIC_ITEM = A.TPIC_ITEM) DESC) -1
                 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE  X WHERE X.TPIC_TYPE = A.TPIC_TYPE) DESC, TPIC_ITEM COLLATE "ko_KR.utf8" DESC) -1
               END AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
         WHERE (TPIC_TYPE = (SELECT CASE WHEN W.TPIC_TYPE = '전체' THEN A.TPIC_TYPE ELSE W.TPIC_TYPE END FROM WT_WHERE W) AND (SELECT TPIC_TYPE FROM WT_WHERE ) != '기타') 
            OR (TPIC_ITEM IN (SELECT TPIC_ITEM FROM WT_TPIC_WHERE) AND (SELECT TPIC_TYPE FROM WT_WHERE ) = '기타') 
    )
    SELECT SORT_KEY AS SORT_KEY_TPIC  /* 토픽 정렬순서 */
          ,TPIC_ITEM                  /* 토픽 상세항목 */
      FROM WT_TPIC
  ORDER BY SORT_KEY


/* topicProductHeatmapOverviewTopicHeatMapProd.sql */
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (X축 제품) SQL */
/* 히트 맵은 X축 데이터를 생성할 때 왼쪽에서 오른쪽 순서로 나와야한다. */
/* Data를 셋팅할때 [0, 0, 1]  [Y, X, Value] 로 셋팅하기 때문에...      */
/* SQL의 결과는 사용자가 입력한 제품 순서대로 정렬되어 리턴된다.       */
WITH WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ),WT_PROD_TYPE AS
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
    )
    SELECT SORT_KEY AS SORT_KEY_PROD /* 제품 정렬순서 */
          ,BRND_NM                   /* 브랜드 명     */
          ,PROD_NM                   /* 제품 명       */
          ,PROD_ID                   /* 제품코드      */
      FROM WT_PROD
  ORDER BY SORT_KEY


/* topicProductHeatmapOverviewTopicHeatMap.sql */
/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 SQL */
/*    조회결과 가공방법 ==> [[SORT_KEY_TPIC, SORT_KEY_PROD, PSTV_RATE], [SORT_KEY_TPIC, SORT_KEY_PROD, PSTV_RATE], ...] */
/*    제품에 해당하는 토픽이 없는 경우 리턴하지 않도록 개발함.  값이 없는 경우 빈칸이 되었으면 해서... */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:TPIC_TYPE            AS TPIC_TYPE       /* 토픽 대주제 (대주제, 효능, CS, 전체, 기타) ex) 효능 */
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
                 THEN ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_WHERE X WHERE X.TPIC_ITEM = A.TPIC_ITEM) DESC) -1
                 ELSE ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE  X WHERE X.TPIC_TYPE = A.TPIC_TYPE) DESC, TPIC_ITEM COLLATE "ko_KR.utf8" DESC) -1
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
          FROM WT_TPIC A
              ,WT_PROD B
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
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PROD_ID
              ,REVIEW_ID
              ,SENTENCE_ORDER
    ), WT_SUM AS
    (
        SELECT A.PROD_ID
              ,A.TPIC_ITEM
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.PROD_ID
              ,A.TPIC_ITEM
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY_TPIC
              ,A.SORT_KEY_PROD
              ,CASE WHEN (B.PSTV_CNT + B.NGTV_CNT) = 0 THEN 0 ELSE B.PSTV_CNT / (B.PSTV_CNT + B.NGTV_CNT) * 100 END AS PSTV_RATE
              ,A.TPIC_ITEM
              ,A.PROD_NM
              ,A.BRND_NM
          FROM WT_COPY A INNER JOIN WT_SUM B
            ON (A.PROD_ID = B.PROD_ID AND A.TPIC_ITEM = B.TPIC_ITEM)
    )
    SELECT SORT_KEY_TPIC
          ,SORT_KEY_PROD
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE
          ,TPIC_ITEM
          ,PROD_NM
          ,BRND_NM
      FROM WT_BASE
  ORDER BY SORT_KEY_TPIC
          ,SORT_KEY_PROD




4. 제품별 토픽순위 Bar 그래프
    * 바그래프 : 제품선택시 토픽 순위 나오는 바그래프 
    * 해당정보로 토픽별 히트맵 해석 지원 

    필요기능 
    [1] 가로축 : 토픽 
    [2] 세로축 : 긍정도 순서는 긍정 높은 순으로
    [3] 제품 선택 : 제품 선택가능하도록 
        ==> 제품은 하나만 선택
        ==> /* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */ 을 사용


/* productTopicRankingBarChart.sql */
/* 4. 제품별 토픽순위 Bar 그래프 - 바 그래프 SQL */
/*    조회기간은 3. 픽별/제품별 히트맵 overview 에서 선택한 기간을 사용한다. */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,:PROD_ID              AS PROD_ID         /* 제품번호 하나를 입력한다. ex) 617136486827 */
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
        SELECT TPIC_ITEM
          FROM WT_TPIC_DATA A
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
        SELECT A.PROD_ID
              ,A.TPIC_ITEM
              ,SUM(B.REVW_CNT) AS REVW_CNT
              ,SUM(B.PSTV_CNT) AS PSTV_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.PROD_ID
              ,A.TPIC_ITEM
    ), WT_BASE AS
    (
        SELECT A.PROD_ID
              ,A.TPIC_ITEM
              ,CASE WHEN (A.PSTV_CNT + A.NGTV_CNT) = 0 THEN 0 ELSE A.PSTV_CNT / (A.PSTV_CNT + A.NGTV_CNT) * 100 END AS PSTV_RATE
          FROM WT_SUM A
    )
    SELECT TPIC_ITEM                        AS X_ITEM /* 토픽 상세항목 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS Y_VAL  /* 긍정 리뷰 비율 */
      FROM WT_BASE
  ORDER BY PSTV_RATE DESC 
          ,TPIC_ITEM



5. 카테고리별 / 토픽 100% 바그래프
    * 카테고리선택 후 각 토픽에 대한 긍부정 비율이 가로 100%그래프로 나오는것 

    필요기능 : 
    [1] 카테고리 선택 기능 : 스킨, 로션 등 선택 
        ==> 카테고리는 OVER_TMALL_ID_NAME 테이블에서 CATEGORY 컬럼을 DISTINCT 해서 보여주면 될까요??? 넵 여기서 '/'기준 SPLIT 해서 보여주시면 되겠습니다,. 예시 ( 로션/에멀젼/포뮬러 --> 로션, 에멀젼, 포뮬러)
            SELECT DISTINCT CATEGORY FROM OVER_TMALL_ID_NAME
            --> 테이블로 만들어놓기 

    [2] 토픽별 100% 바그래프 : 긍정, 부정, 중립이 나오도록
        ==> 토픽이 Y축, 비율이 X축으로 100% 차도록 보여주면 될까요???

/* categoryTopic100pBarChartCategory.sql */
/* 5. 카테고리별 / 토픽 100% 바그래프 - 카테고리 선택 SQL */
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


/* categoryTopic100pBarChart.sql */
/* 5. 카테고리별 / 토픽 100% 바그래프 - 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT :CATE_NM              AS CATE_NM         /* 카테고리 명 하나를 입력한다. ex) '로션' */
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
        SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_TPIC_TYPE X WHERE X.TPIC_TYPE = A.TPIC_TYPE) DESC, TPIC_ITEM COLLATE "ko_KR.utf8" DESC) -1 AS SORT_KEY
              ,TPIC_ITEM
          FROM WT_TPIC_DATA A
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
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
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
              ,SUM(B.NTRL_CNT) AS NTRL_CNT
              ,SUM(B.NGTV_CNT) AS NGTV_CNT
          FROM WT_DATA_TPIC A INNER JOIN WT_DATA_REVW B 
            ON (A.PROD_ID = B.PROD_ID AND A.REVIEW_ID = B.REVIEW_ID AND A.SENTENCE_ORDER = B.SENTENCE_ORDER)
      GROUP BY A.TPIC_ITEM
    ), WT_BASE AS
    (
        SELECT A.TPIC_ITEM
              ,(SELECT SORT_KEY FROM WT_TPIC X WHERE X.TPIC_ITEM = A.TPIC_ITEM)       AS SORT_KEY
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.PSTV_CNT / A.REVW_CNT * 100 END AS PSTV_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NTRL_CNT / A.REVW_CNT * 100 END AS NTRL_RATE
              ,CASE WHEN A.REVW_CNT = 0 THEN 0 ELSE A.NGTV_CNT / A.REVW_CNT * 100 END AS NGTV_RATE
          FROM WT_SUM A
    )
    SELECT SORT_KEY
          ,TPIC_ITEM   /* 토픽 상세항목 */
          ,CAST(PSTV_RATE AS DECIMAL(20,2)) AS PSTV_RATE  /* 긍정 리뷰 비율 */
          ,CAST(NTRL_RATE AS DECIMAL(20,2)) AS NTRL_RATE  /* 중립 리뷰 비율 */
          ,CAST(NGTV_RATE AS DECIMAL(20,2)) AS NGTV_RATE  /* 부정 리뷰 비율 */
      FROM WT_BASE
  ORDER BY SORT_KEY



6. 전월대비 제품 긍정, 부정  비율변화 순위
    ==> 제품 이미지 표시가 필요한가요???
    * 전월대비 제품의 긍정, 부정 비율 순위가 나와야함
        ==> 긍정의 1 ~ 5위,  부정의 1 ~ 5위 
            순위, 긍정제품명, 부정제품명 이렇게 3개 컬럼으로 보여주면 될까요???
    * 구분 기준은 전체, 카테고리별, 자사제품 
        ==> 전체, 또는 카테고리를 선택할 수 있게 Select Box 를 만들어 주면 될까요?
        ==> 자사제품의 구분 방법은???
            제품 브랜드명 --> 더마펌 이 포함된 제품
            
    필요기능 : 
    [1] 구분기능 : 전체, 카테고리, 자사제품 기준 구분 
    [2]상위 5개 하위 5개 
    [3] 전달 대비 변화율 기준
        ==> 기간은 모든 데이터를 기준으로 하면 될까요??? --> 고민필요
        ==> 일단 오늘기준 전전달 vs 전달 Data를 비교는 SQL을 개발함. ex) 오늘(2023-03-01)의 경우 2023-01 vs. 2023-02

/* productSentimentChangeRankingPreMonth.sql */
/* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 전체, 카테고리, 자사제품 선택 SQL */
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
        SELECT ROW_NUMBER() OVER (ORDER BY CATE_NM COLLATE "ko_KR.utf8") + 1 AS SORT_KEY
              ,CATE_NM
          FROM WT_CATE_SPLT_RE
     UNION ALL
        SELECT '0'   AS SORT_KEY
             ,'전체' AS CATE_NM
     UNION ALL
        SELECT '1'       AS SORT_KEY
             ,'자사제품' AS CATE_NM
    )
    SELECT SORT_KEY  /* 정렬순서   */
          ,CATE_NM   /* 카테고리 명*/
      FROM WT_CATE_SPLT
  ORDER BY SORT_KEY


/* productSentimentChangeRankingPreMonthData.sql */
/* 6. 전월대비 제품 긍정, 부정  비율변화 순위 - 데이터 표 SQL */
/*    조회기간 : 오늘기준 전전달 vs 전달 Data를 비교          */
/*    ex) 오늘(2023-03-01)의 경우 2023-01 vs. 2023-02         */
/*    ※ 변화비율이 양수인 값만 나오는 것이 맞지 않을까?                                             */
/*    ※ 리뷰수가 일정 수 이상인 데이터만 대상으로 계산할 필요가 있어보임. (모든 긍/부정 비율은...)  */
WITH WT_WHERE AS
    (
        SELECT CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '1' MONTH)                              AS DATE) AS FR_DT      /* 오늘기준 -1개월  1일 ex) '2023-02-01' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '1' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT      /* 오늘기준 -1개월 말일 ex) '2023-02-28' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '2' MONTH)                              AS DATE) AS FR_DT_MOM  /* 오늘기준 -2개월  1일 ex) '2023-01-01' */
              ,CAST(DATE_TRUNC('MONTH', CAST(BASE_DT AS DATE) - INTERVAL '2' MONTH) + INTERVAL '1 MONTH - 1 DAY' AS DATE) AS TO_DT_MOM  /* 오늘기준 -2개월 말일 ex) '2023-01-31' */
              ,:CATE_NM              AS CATE_NM  /* 카테고리명 하나를 입력 또는 전체, 자사제품을 입력한다. ex) '스킨' */ 
          FROM REVIEW.REVIEW_INITIAL_DATE
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
         WHERE ((SELECT CATE_NM FROM WT_WHERE) != '자사제품' AND CATE_NM = CASE WHEN (SELECT CATE_NM FROM WT_WHERE) IN ('전체') THEN CATE_NM ELSE (SELECT CATE_NM FROM WT_WHERE) END)
            OR ((SELECT CATE_NM FROM WT_WHERE)  = '자사제품' AND (
                                                                    SELECT MAX(BRAND) 
                                                                      FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME X
                                                                     WHERE X.ID = A.PROD_ID
                                                                 ) = '더마펌')
    ), WT_REVW_SUM AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
      GROUP BY PROD_ID
    ), WT_REVW_SUM_MOM AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT_MOM FROM WT_WHERE) AND (SELECT TO_DT_MOM FROM WT_WHERE) 
           AND PROD_ID IN (SELECT PROD_ID FROM WT_CATE_SPLT)
      GROUP BY PROD_ID
    ), WT_REVW_RATE AS
    (
        SELECT PROD_ID
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM
    ), WT_REVW_RATE_MOM AS
    (
        SELECT PROD_ID
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
          FROM WT_REVW_SUM_MOM
    ), WT_REVW_COMP AS
    (
        SELECT A.PROD_ID
              ,A.PSTV_RATE - B.PSTV_RATE AS PSTV_CHNG
              ,A.NGTV_RATE - B.NGTV_RATE AS NGTV_CHNG
          FROM WT_REVW_RATE A INNER JOIN WT_REVW_RATE_MOM B 
            ON (A.PROD_ID = B.PROD_ID)
    ), WT_PSTV_RANK AS
    (
        SELECT PROD_ID
              ,PSTV_CHNG
              ,NGTV_CHNG
              ,ROW_NUMBER() OVER(ORDER BY PSTV_CHNG DESC, PROD_ID) AS PSTV_RANK
              ,ROW_NUMBER() OVER(ORDER BY NGTV_CHNG DESC, PROD_ID) AS NGTV_RANK
          FROM WT_REVW_COMP
    ), WT_BASE AS
    (
        SELECT A.REVW_RANK
              ,REVIEW_RAW.SF_PROD_NM(B.PROD_ID) AS PSTV_PROD_NM
              ,REVIEW_RAW.SF_PROD_NM(C.PROD_ID) AS NGTV_PROD_NM
              ,B.PSTV_CHNG
              ,C.NGTV_CHNG
              ,B.PSTV_RANK
              ,C.NGTV_RANK
          FROM WT_COPY A LEFT OUTER JOIN WT_PSTV_RANK B ON (A.REVW_RANK = B.PSTV_RANK)
                         LEFT OUTER JOIN WT_PSTV_RANK C ON (A.REVW_RANK = C.NGTV_RANK)
    )
    SELECT REVW_RANK                                     /* 순위 1~5 */
          ,PSTV_PROD_NM                                  /* 긍정비율 변화 Top5 제품명 */
          ,NGTV_PROD_NM                                  /* 부정비율 변화 Top5 제품명 */
          ,CAST(PSTV_CHNG AS DECIMAL(20,2)) AS PSTV_RATE /* 긍정비율 증감률           */ 
          ,CAST(NGTV_CHNG AS DECIMAL(20,2)) AS PSTV_RATE /* 부정비율 증감률           */
      FROM WT_BASE
     WHERE COALESCE(PSTV_PROD_NM, '') != '' OR COALESCE(NGTV_PROD_NM, '') != ''
  ORDER BY REVW_RANK



7. 제품별 긍부정 비율 시계열 그래프
    * 제품별 긍부정 비율 시계열그래프 : 기본값 누적을 기준으로 선택한 기간동안의 제품별 긍부정 비율을 나타내야함  
    * 누적 : 누적인지 시점별인지 선택하는
        ==> 속도를 생각하면 누적, 시점에 대한 라인도 같이 보여주는게...
    * 하단에는 바그래프통해 월별 리뷰수 보여주기
        ==> Legend : 선택한 제품의 긍정비율, 선택한 제품의 부정비율, 월별 리뷰수
        ==> Y 축   : 비율값
        ==> X 축   : 일자??? 월????  (* 하단에는 바그래프통해 월별 리뷰수 보여주기)
                     바는 월 말일에 생성하여 표시
                     일단 모든일자에 표시하기로 함.

    필요 기능 : 
    [1] 기간선택 : 분석기간 선택(캘린더 형태) 
        ==> 시작월, 종료월을 선택하는 캘린더인가요???
            다른 그래프처럼 최근 3개월을 조회함.
    [2] 누적 선택: 누적인지 시점별인지 선택 해야함
    [3] 제품선택 : 제품을 선택하는 것 복수선택 가능
        ==> /* 3. 토픽별/제품별 히트맵 overview - 제품 선택 SQL */ 을 사용

/* productSentimentRatioTimeSeriesChart.sql */
/* 7. 제품별 긍부정 비율 시계열 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,CAST(DATE                                              AS DATE         ) AS X_DT                           
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
              ,DATE
    ), WT_SUM AS
    (
        SELECT PROD_ID
              ,X_DT
              ,REVW_CNT
              ,PSTV_CNT
              ,NGTV_CNT
              ,SUM(REVW_CNT) OVER(PARTITION BY PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(PSTV_CNT) OVER(PARTITION BY PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(NGTV_CNT) OVER(PARTITION BY PROD_ID ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
          FROM WT_DATA_REVW A 
    ), WT_BASE AS
    (
        SELECT PROD_ID
              ,REVIEW_RAW.SF_PROD_NM(A.PROD_ID) AS PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY 
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE PSTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS PSTV_RATE
              ,CASE WHEN (PSTV_CNT + NGTV_CNT) = 0 THEN 0 ELSE NGTV_CNT / (PSTV_CNT + NGTV_CNT) * 100 END AS NGTV_RATE
              ,CASE WHEN (PSTV_CUM + NGTV_CUM) = 0 THEN 0 ELSE PSTV_CUM / (PSTV_CUM + NGTV_CUM) * 100 END AS PSTV_RATE_CUM
              ,CASE WHEN (PSTV_CUM + NGTV_CUM) = 0 THEN 0 ELSE NGTV_CUM / (PSTV_CUM + NGTV_CUM) * 100 END AS NGTV_RATE_CUM
          FROM WT_SUM A
    )
    SELECT SORT_KEY  /* 정렬순서 */
          ,PROD_ID   /* 제품코드 */
          ,PROD_NM   /* 제품 명  */
          ,X_DT      /* 일자    */
          ,CAST(PSTV_RATE     AS DECIMAL(20,2)) AS PSTV_RATE      /* 긍정리뷰 비율 - 시점 (라인) */
          ,CAST(NGTV_RATE     AS DECIMAL(20,2)) AS NGTV_RATE      /* 부정리뷰 비율 - 시점 (라인) */
          ,CAST(PSTV_RATE_CUM AS DECIMAL(20,2)) AS PSTV_RATE_CUM  /* 긍정리뷰 비율 - 누적 (라인) */
          ,CAST(NGTV_RATE_CUM AS DECIMAL(20,2)) AS NGTV_RATE_CUM  /* 부정리뷰 비율 - 누적 (라인) */
          ,REVW_CNT                  /* 리뷰 수 - 시점 (바) */
          ,REVW_CUM AS REVW_CNT_CUM  /* 리뷰 수 - 누적 (바) */
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT




8. 제품별 리뷰속성그래프
    * 리뷰속성 스택 바 그래프 : 선택한 기간과 제품별로 감성5단계 스택그래프 나와야함 X축은 제품명 Y 축은 리뷰 수 또는 %

    필요기능: 
    [1] 그래프 선택기능  : 리뷰수/퍼센트그래프 : 만약 퍼센트 그래프를 선택하면 100퍼센트 기준 동일한 높이의 리뷰 그래프가 나와야함 
        ==> eChart 기능 중 Line, Bar, Stack 변환 기능에 대해 설명드리기...
            https://echarts.apache.org/examples/en/editor.html?c=bar-brush
            https://echarts.apache.org/examples/en/editor.html?c=bar1
    [2] 그래프 순서는 리뷰 속성 순서로 젤 위에 1:강부정, 그다음 2 약부정 3 중립 4 긍정 5 강긍정
    [3] 기간 선택 기능 : 캘린더 기반 기간 선택 
    [4] 제품 선택 기능 제품들을 선택하는 기능 복수선택가능

/* productReviewAttributeChart.sql */
/* 8. 제품별 리뷰속성그래프 - 스택 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(:FR_DT AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST(:TO_DT AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE(:PROD_ID, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ), WT_DATA_REVW AS
    (
        SELECT PROD_ID
              ,CAST(COUNT(*)                                       AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_1_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_2_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_3_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_4_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_5_CNT
          FROM (
                SELECT A.*
                  FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PROD_ID
    ), WT_BASE AS
    (
        SELECT PROD_ID
              ,REVIEW_RAW.SF_PROD_NM(A.PROD_ID) AS PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY 
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_ID = A.PROD_ID
               ) AS SORT_KEY  /* 정렬순서 */
              ,REVW_CNT
              ,NGTV_1_CNT
              ,NGTV_2_CNT
              ,NTRL_3_CNT
              ,PSTV_4_CNT
              ,PSTV_5_CNT
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE NGTV_1_CNT / REVW_CNT * 100 END AS NGTV_1_RATE
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE NGTV_2_CNT / REVW_CNT * 100 END AS NGTV_2_RATE
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE NTRL_3_CNT / REVW_CNT * 100 END AS NTRL_3_RATE
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE PSTV_4_CNT / REVW_CNT * 100 END AS PSTV_4_RATE
              ,CASE WHEN REVW_CNT = 0 THEN 0 ELSE PSTV_5_CNT / REVW_CNT * 100 END AS PSTV_5_RATE
          FROM WT_DATA_REVW A
    )
    SELECT SORT_KEY     /* 정렬순서        */
          ,PROD_ID      /* 제품코드        */
          ,PROD_NM      /* 제품 명         */
          ,NGTV_1_CNT   /* 강부정 - 리뷰수 */
          ,NGTV_2_CNT   /* 약부정 - 리뷰수 */
          ,NTRL_3_CNT   /* 중립   - 리뷰수 */
          ,PSTV_4_CNT   /* 약긍정 - 리뷰수 */
          ,PSTV_5_CNT   /* 강긍정 - 리뷰수 */
          ,CAST(NGTV_1_RATE AS DECIMAL(20,2)) AS NGTV_1_RATE /* 강부정 - 퍼센트 */
          ,CAST(NGTV_2_RATE AS DECIMAL(20,2)) AS NGTV_2_RATE /* 약부정 - 퍼센트 */
          ,CAST(NTRL_3_RATE AS DECIMAL(20,2)) AS NTRL_3_RATE /* 중립   - 퍼센트 */
          ,CAST(PSTV_4_RATE AS DECIMAL(20,2)) AS PSTV_4_RATE /* 약긍정 - 퍼센트 */
          ,CAST(PSTV_5_RATE AS DECIMAL(20,2)) AS PSTV_5_RATE /* 강긍정 - 퍼센트 */
      FROM WT_BASE
  ORDER BY SORT_KEY
