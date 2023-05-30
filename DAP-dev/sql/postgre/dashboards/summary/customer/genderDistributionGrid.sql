/* 7. 방문자 성별 데이터 뷰어 - 표 SQL */
WITH WT_COPY AS
    (
        SELECT 1            AS SORT_KEY
              ,'女'         AS GNDR_ID
              ,'여성'       AS GNDR_NM 
     UNION ALL
        SELECT 2            AS SORT_KEY
              ,'未知'       AS GNDR_ID
              ,'미상'       AS GNDR_NM 
     UNION ALL
        SELECT 3            AS SORT_KEY
              ,'男'         AS GNDR_ID
              ,'남성'       AS GNDR_NM 
    ), WT_DCT AS
    (
        SELECT 'DCT'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCT_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DGT AS
    (
        SELECT 'DGT'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DGT_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DCD AS
    (
        SELECT 'DCD'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV) AS VIST_CNT
          FROM DASH_RAW.CRM_DCD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_DGD AS
    (
        SELECT 'DGD'   AS CHNL_ID
              ,NAME    AS GNDR_ID
              ,SUM(UV::FLOAT8) AS VIST_CNT  /*UV 컬럼 Type이 Text라서 FLOAT8로 변환함. */
          FROM DASH_RAW.CRM_DGD_PROD_VISIT_GENDER
       GROUP BY NAME
    ), WT_BASE AS
    (
        SELECT A.SORT_KEY
              ,A.GNDR_ID
              ,A.GNDR_NM
              ,COALESCE(B.VIST_CNT, 0) + COALESCE(C.VIST_CNT, 0) + COALESCE(D.VIST_CNT, 0) + COALESCE(E.VIST_CNT, 0) AS TOTL_VIST_CNT
              ,B.VIST_CNT AS DCT_VIST_CNT
              ,C.VIST_CNT AS DGT_VIST_CNT
              ,D.VIST_CNT AS DCD_VIST_CNT
              ,E.VIST_CNT AS DGD_VIST_CNT
          FROM WT_COPY A LEFT OUTER JOIN WT_DCT B ON (A.GNDR_ID = B.GNDR_ID)
                         LEFT OUTER JOIN WT_DGT C ON (A.GNDR_ID = C.GNDR_ID)
                         LEFT OUTER JOIN WT_DCD D ON (A.GNDR_ID = D.GNDR_ID)
                         LEFT OUTER JOIN WT_DGD E ON (A.GNDR_ID = E.GNDR_ID)
    )
    SELECT SORT_KEY
          ,GNDR_NM
          ,TO_CHAR(TOTL_VIST_CNT, 'FM999,999,999,999,999') AS TOTL_VIST_CNT  /* 전체 */
          ,TO_CHAR(DCT_VIST_CNT , 'FM999,999,999,999,999') AS DCT_VIST_CNT   /* Tmall 내륙    - Tmall China   */
          ,TO_CHAR(DGT_VIST_CNT , 'FM999,999,999,999,999') AS DGT_VIST_CNT   /* Tmall 글로벌  - Tmall Global  */
          ,TO_CHAR(DCD_VIST_CNT , 'FM999,999,999,999,999') AS DCD_VIST_CNT   /* Douyin 내륙   - Douyin China  */
          ,TO_CHAR(DGD_VIST_CNT , 'FM999,999,999,999,999') AS DGD_VIST_CNT   /* Douyin 글로벌 - Douyin Global */
      FROM WT_BASE
  ORDER BY SORT_KEY