/* 2. 제품별 리뷰지도 - 트리 맵 그래프 SQL */
/* ※ OVER_{TAG}_REVIEW_SENTENCE_TABLE 테이블의 PROD_ID 컬럼 값 끝에 스페이스가 포함되어 있음 */

WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,{WITH_FAKE}            AS WITH_FAKE       /*  WITH_FAKE (Y:비정상리뷰 포함, 'N':비정상리뷰 불포함) 기본값 'N' */
              ,{CATE_NM} 			  AS CATE_NM  		 /*  제품 카테고리 설정 */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */    
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
          WHERE DISPLAY = 'O'
    ), WT_PROD AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY BRND_SORT, BRND_NM COLLATE "ko_KR.utf8", PROD_NM COLLATE "ko_KR.utf8", PROD_ID) -1 AS SORT_KEY
              ,BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE
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
    ), WT_DATA_REVW AS
    (
        SELECT A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NM AS PROD_NM
              ,B.BRND_NM     AS BRND_NM
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT A.*
                      FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND CASE WHEN (SELECT WITH_FAKE FROM WT_WHERE) = 'Y' THEN 0 ELSE F.FAKE END = 0)
                     WHERE (A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)) and A.PROD_ID in (select PROD_ID from WT_CATE_SPLT)
               ) A LEFT OUTER JOIN 
               WT_PROD B
            ON (A.PROD_ID = B.PROD_ID)
      GROUP BY A.PROD_ID
              ,A.REVIEW_ID
              ,A.SENTENCE_ORDER
              ,B.PROD_NM
              ,B.BRND_NM
    ), WT_SUM AS
    (
        SELECT A.PROD_ID
              ,A.PROD_NM    AS PROD_NM
              ,A.BRND_NM   AS BRND_NM
              ,SUM(REVW_CNT) AS REVW_CNT
              ,SUM(PSTV_CNT) AS PSTV_CNT
              ,SUM(NTRL_CNT) AS NTRL_CNT
              ,SUM(NGTV_CNT) AS NGTV_CNT
     	FROM WT_DATA_REVW A 
      GROUP by A.PROD_ID
              ,A.PROD_NM
              ,A.BRND_NM
    ), WT_BASE_tmp as (
     SELECT A.PROD_ID
              ,COALESCE(B.PROD_NM , A.PROD_ID    ) AS PROD_NM
              ,COALESCE(B.BRND_NM , '브랜드 미상') AS BRND_NM
              ,COALESCE(B.SORT_KEY, 9            ) AS SORT_KEY 
              ,REVW_CNT
              ,PSTV_CNT
              ,NGTV_CNT
          FROM WT_SUM A LEFT OUTER JOIN WT_PROD B 
            ON (A.PROD_ID = B.PROD_ID)
 
    ),  WT_BASE AS
    (
        SELECT STRING_AGG(DISTINCT PROD_ID, ', ') AS PROD_ID
              ,PROD_NM
              ,BRND_NM
              ,SUM(REVW_CNT)              as REVW_CNT
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(PSTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS PSTV_RATE
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(NTRL_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS NTRL_RATE
              ,CASE WHEN (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) = 0 THEN 0 ELSE SUM(NGTV_CNT) / (SUM(PSTV_CNT) + SUM(NTRL_CNT) + SUM(NGTV_CNT)) * 100 END AS NGTV_RATE
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_SUM A
          group by prod_nm, brnd_nm
    )
    SELECT BRND_NM   /* 브랜드 명 */
          ,PROD_NM   /* 제품 명   */
          ,REVW_CNT  /* 리뷰 수   */
          ,CAST(CASE WHEN PSNG_TYPE = 'PSTV' THEN PSTV_RATE ELSE NGTV_RATE END AS DECIMAL(20,2)) AS pstv_RATE /* 긍/부정 리뷰 비율 0 ~ 100 (색변경) */
          ,PROD_ID   /* 제품코드  */
      FROM WT_BASE
  ORDER BY BRND_NM
          ,PROD_NM