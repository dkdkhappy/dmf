/* 8. 제품별 리뷰속성그래프 - 스택 바 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST({FR_DT} AS DATE)  AS FR_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일 -3개월  ex) '2023-02-26'  */
              ,CAST({TO_DT} AS DATE)  AS TO_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 오늘(2023-02-27) -1일         ex) '2022-11-26'  */
    ), WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
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
                  FROM REVIEW_RAW.OVER_{TAG}_REVIEW_SENTENCE_TABLE A INNER JOIN REVIEW_RAW.OVER_{TAG}_REVIEW_ABNORMAL F
                    ON (A.PROD_ID = F.PROD_ID AND A.DATE = F.DATE AND A.REVIEW_ID = F.REVIEW_ID AND F.FAKE = 0)
               ) A
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND PROD_ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
      GROUP BY PROD_ID
    ), WT_SORT_KEY AS
    (
        SELECT AVG(SORT_KEY)                    AS SORT_KEY
              ,REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(A.PROD_ID) AS PROD_NM
          FROM WT_PROD_WHERE X
     LEFT JOIN WT_DATA_REVW A
            ON X.PROD_ID = A.PROD_ID
      GROUP BY PROD_NM
      ORDER BY SORT_KEY
    ), WT_SORT_KEY_NEW AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,PROD_NM              AS PROD_NM
          FROM WT_SORT_KEY
    ), WT_GROUP AS
    (
        SELECT REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(A.PROD_ID) AS PROD_NM  /* 제품 명 */
              ,(
                SELECT SORT_KEY
                  FROM WT_SORT_KEY_NEW X
                 WHERE X.PROD_NM = REVIEW_RAW.SF_{CHNL_L_ID}_PROD_NM(A.PROD_ID)
               ) AS SORT_KEY  /* 정렬순서 */
              ,SUM(REVW_CNT)   AS REVW_CNT
              ,SUM(NGTV_1_CNT) AS NGTV_1_CNT
              ,SUM(NGTV_2_CNT) AS NGTV_2_CNT
              ,SUM(NTRL_3_CNT) AS NTRL_3_CNT
              ,SUM(PSTV_4_CNT) AS PSTV_4_CNT
              ,SUM(PSTV_5_CNT) AS PSTV_5_CNT
          FROM WT_DATA_REVW A
      GROUP BY PROD_NM, SORT_KEY
    ), WT_BASE AS
    (
        SELECT PROD_NM  /* 제품 명 */
              ,SORT_KEY  /* 정렬순서 */
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
          FROM WT_GROUP A
    )
    SELECT SORT_KEY            /* 정렬순서        */
          ,PROD_NM AS PROD_ID  /* 제품코드        */
          ,PROD_NM             /* 제품 명         */
          ,NGTV_1_CNT          /* 강부정 - 리뷰수 */
          ,NGTV_2_CNT          /* 약부정 - 리뷰수 */
          ,NTRL_3_CNT          /* 중립   - 리뷰수 */
          ,PSTV_4_CNT          /* 약긍정 - 리뷰수 */
          ,PSTV_5_CNT          /* 강긍정 - 리뷰수 */
          ,CAST(NGTV_1_RATE AS DECIMAL(20,2)) AS NGTV_1_RATE /* 강부정 - 퍼센트 */
          ,CAST(NGTV_2_RATE AS DECIMAL(20,2)) AS NGTV_2_RATE /* 약부정 - 퍼센트 */
          ,CAST(NTRL_3_RATE AS DECIMAL(20,2)) AS NTRL_3_RATE /* 중립   - 퍼센트 */
          ,CAST(PSTV_4_RATE AS DECIMAL(20,2)) AS PSTV_4_RATE /* 약긍정 - 퍼센트 */
          ,CAST(PSTV_5_RATE AS DECIMAL(20,2)) AS PSTV_5_RATE /* 강긍정 - 퍼센트 */
      FROM WT_BASE
  ORDER BY SORT_KEY