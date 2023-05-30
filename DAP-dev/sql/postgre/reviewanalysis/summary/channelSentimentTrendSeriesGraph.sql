/* 4. 채널 별 긍부정 시계열 그래프 - 시계열 그래프 SQL */
/* 요구사항은 "제품을 선택하면 각 채널도 나오고 채널의 합도 나올 수 있도록 5개 (전체, 티몰 글로벌/내륙, 도우인 글로벌/내륙)" 이지만 */
/* 그런 제품번호는 없음. 모든 제품번호는 전체와 특정 한개의 채널만 나옴. */

WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)         AS FR_DT      /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)         AS TO_DT      /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
              ,COALESCE({PSNG_TYPE}, 'PSTV') AS PSNG_TYPE  /* 긍/부정 선택 (PSTV:긍정, NGTV:부정) ex) PSTV  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
              ,TRIM(PROD_ID)        AS PROD_NM
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'658100483482,652094627119,619327829460' */
    ), WT_PROD_ID AS
    (
        SELECT 'DGT' AS CHNL_ID
              ,ID    AS PROD_ID
              ,NAME  AS PROD_NM
          FROM REVIEW_RAW.OVER_TMALL_ID_NAME
         WHERE NAME in (SELECT PROD_ID FROM WT_PROD_WHERE)
           AND MARKET = 'global'
     UNION ALL
        SELECT 'DCT' AS CHNL_ID
              ,ID    AS PROD_ID
              ,NAME  AS PROD_NM
          FROM REVIEW_RAW.OVER_TMALL_ID_NAME
         WHERE NAME in (SELECT PROD_ID FROM WT_PROD_WHERE)
           AND MARKET = 'china'
     UNION ALL 
        SELECT 'DGD' AS CHNL_ID
              ,ID
              ,NAME
          FROM REVIEW_RAW.OVER_DOUYIN_ID_NAME
         WHERE NAME in (SELECT PROD_ID FROM WT_PROD_WHERE)
           AND MARKET = 'global'
     UNION ALL 
        SELECT 'DCD' AS CHNL_ID
              ,ID
              ,NAME
          FROM REVIEW_RAW.OVER_DOUYIN_ID_NAME
         WHERE NAME in (SELECT PROD_ID FROM WT_PROD_WHERE)
           AND MARKET = 'china'
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
    ), WT_COPY_CHNL AS
    (
        SELECT A.SORT_KEY AS CHNL_SORT_KEY
              ,A.CHNL_ID
              ,A.CHNL_NM
              ,(SELECT X.SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_NM = B.PROD_NM) AS SORT_KEY
              ,B.PROD_NM
          FROM WT_CHNL A
              ,(
                SELECT DISTINCT 
                       PROD_NM
                  FROM WT_PROD_WHERE
                 WHERE PROD_NM IN (SELECT PROD_NM FROM WT_PROD_WHERE)
               ) B
    ), WT_DATA_REVW AS
    (
        SELECT CHNL_ID
              ,PROD_NM                                                                  AS PROD_NM
              ,CAST(DATE                                              AS DATE         ) AS X_DT                           
              ,CAST(COUNT(*)                                          AS DECIMAL(20,2)) AS REVW_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (4, 5) THEN 1 END) AS DECIMAL(20,2)) AS PSTV_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (3   ) THEN 1 END) AS DECIMAL(20,2)) AS NTRL_CNT
              ,CAST(COUNT(CASE WHEN SENT_RATING IN (1, 2) THEN 1 END) AS DECIMAL(20,2)) AS NGTV_CNT
          FROM (
                    SELECT 'DCT' AS CHNL_ID
                          ,REVIEW_RAW.SF_TMALL_PROD_NM(A.PROD_ID) AS PROD_NM
                          ,A.*
                      FROM REVIEW_RAW.OVER_DCT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT X.PROD_ID FROM WT_PROD_ID X WHERE CHNL_ID = 'DCT')
                 UNION ALL 
                    SELECT 'DGT' AS CHNL_ID
                          ,REVIEW_RAW.SF_TMALL_PROD_NM(A.PROD_ID) AS PROD_NM
                          ,A.*
                      FROM REVIEW_RAW.OVER_DGT_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGT_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT X.PROD_ID FROM WT_PROD_ID X WHERE CHNL_ID = 'DGT')
                 UNION ALL 
                    SELECT 'DCD' AS CHNL_ID
                          ,REVIEW_RAW.SF_DOUYIN_PROD_NM(A.PROD_ID) AS PROD_NM
                          ,A.*
                      FROM REVIEW_RAW.OVER_DCD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DCD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT X.PROD_ID FROM WT_PROD_ID X WHERE CHNL_ID = 'DCD')
                 UNION ALL 
                    SELECT 'DGD' AS CHNL_ID
                          ,REVIEW_RAW.SF_DOUYIN_PROD_NM(A.PROD_ID) AS PROD_NM
                          ,A.*
                      FROM REVIEW_RAW.OVER_DGD_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_DGD_REVIEW_ABNORMAL F
                        ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
                     WHERE A.DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
                       AND A.PROD_ID IN (SELECT X.PROD_ID FROM WT_PROD_ID X WHERE CHNL_ID = 'DGD')
               ) A
      GROUP BY CHNL_ID
              ,PROD_NM
              ,DATE
    ), WT_FILL AS 
    (
      SELECT B.CHNL_ID
            ,B.PROD_NM
            ,B.X_DT
            ,COALESCE(A.REVW_CNT, 0) AS REVW_CNT
            ,COALESCE(A.PSTV_CNT, 0) AS PSTV_CNT
            ,COALESCE(A.NTRL_CNT, 0) AS NTRL_CNT
            ,COALESCE(A.NGTV_CNT, 0) AS NGTV_CNT
        FROM WT_DATA_REVW A 
  RIGHT JOIN (
        SELECT A.X_DT
              ,B.CHNL_ID
              ,B.PROD_NM
          FROM (SELECT GENERATE_SERIES(CAST(FR_DT AS DATE), CAST(TO_DT AS DATE), '1d') AS X_DT FROM WT_WHERE) A
    CROSS JOIN (SELECT DISTINCT CHNL_ID, PROD_NM FROM WT_DATA_REVW) B
      ORDER BY CHNL_ID, X_DT) B
          ON A.X_DT = B.X_DT AND A.CHNL_ID = B.CHNL_ID     
    ), WT_SUM AS
    (
        SELECT CHNL_ID
              ,PROD_NM
              ,X_DT
              ,REVW_CNT
              ,PSTV_CNT
              ,NTRL_CNT
              ,NGTV_CNT
              ,SUM(REVW_CNT) OVER(PARTITION BY CHNL_ID, PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS REVW_CUM
              ,SUM(PSTV_CNT) OVER(PARTITION BY CHNL_ID, PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS PSTV_CUM
              ,SUM(NTRL_CNT) OVER(PARTITION BY CHNL_ID, PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NTRL_CUM
              ,SUM(NGTV_CNT) OVER(PARTITION BY CHNL_ID, PROD_NM ORDER BY X_DT ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NGTV_CUM
              ,(SELECT PSNG_TYPE FROM WT_WHERE) AS PSNG_TYPE
          FROM WT_FILL A 
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
              ,A.PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_NM = A.PROD_NM
               ) AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,REVW_CNT
              ,REVW_CUM
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN REVW_CNT = 0 THEN 0 ELSE PSTV_CNT / REVW_CNT * 100 END
                 ELSE CASE WHEN REVW_CNT = 0 THEN 0 ELSE NGTV_CNT / REVW_CNT * 100 END
               END AS REVW_RATE
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN REVW_CUM = 0 THEN 0 ELSE PSTV_CUM / REVW_CUM * 100 END
                 ELSE CASE WHEN REVW_CUM = 0 THEN 0 ELSE NGTV_CUM / REVW_CUM * 100 END
               END AS REVW_RATE_CUM
          FROM WT_SUM A
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
              ,A.PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY
                  FROM WT_PROD_WHERE X
                 WHERE X.PROD_NM = A.PROD_NM
               ) AS SORT_KEY  /* 정렬순서 */
              ,X_DT
              ,SUM(REVW_CNT) AS REVW_CNT
              ,SUM(REVW_CUM) AS REVW_CUM
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN SUM(REVW_CNT) = 0 THEN 0 ELSE SUM(PSTV_CNT) / SUM(REVW_CNT) * 100 END
                 ELSE CASE WHEN SUM(REVW_CNT) = 0 THEN 0 ELSE SUM(NGTV_CNT) / SUM(REVW_CNT) * 100 END
               END AS REVW_RATE
              ,CASE 
                 WHEN PSNG_TYPE = 'PSTV' 
                 THEN CASE WHEN SUM(REVW_CUM) = 0 THEN 0 ELSE SUM(PSTV_CUM) / SUM(REVW_CUM) * 100 END
                 ELSE CASE WHEN SUM(REVW_CUM) = 0 THEN 0 ELSE SUM(NGTV_CUM) / SUM(REVW_CUM) * 100 END
               END AS REVW_RATE_CUM
          FROM WT_SUM A
      GROUP BY A.PROD_NM
              ,X_DT
              ,PSNG_TYPE
    )
      SELECT A.SORT_KEY                                /* 정렬순서 */
            ,A.CHNL_SORT_KEY
            ,A.PROD_NM                     AS PROD_ID  /* 제품코드 */
            ,A.PROD_NM ||' - '|| A.CHNL_NM AS PROD_NM  /* 제품 명  */
            ,COALESCE(B.X_DT, (SELECT FR_DT FROM WT_WHERE)) AS X_DT   /* 일자    */
            ,CAST(COALESCE(B.REVW_RATE    , 0) AS DECIMAL(20,2)) AS REVW_RATE      /* 리뷰 비율 - 시점 (라인) */
            ,CAST(COALESCE(B.REVW_RATE_CUM, 0) AS DECIMAL(20,2)) AS REVW_RATE_CUM  /* 리뷰 비율 - 누적 (라인) */
        FROM WT_COPY_CHNL A LEFT OUTER JOIN WT_BASE B ON (A.CHNL_ID = B.CHNL_ID AND A.PROD_NM = B.PROD_NM)
    ORDER BY A.SORT_KEY
            ,A.CHNL_SORT_KEY
            ,B.X_DT
    