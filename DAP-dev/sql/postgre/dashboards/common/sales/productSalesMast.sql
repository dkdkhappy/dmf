/* 8. 제품별 매출 정보 시계열 그래프 - 제품별 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_PROD AS
    (
        SELECT DISTINCT
               CAST(PRODUCT_ID AS VARCHAR) AS PRODUCT_ID
          FROM DASH_RAW.OVER_{TAG}_OVERALL_PRODUCT_URL A
         WHERE STATISTICS_DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
    )
    SELECT A.PRODUCT_ID   AS PROD_ID
          ,A.PRODUCT_NAME AS PROD_NM
      FROM DASH_RAW.OVER_{TAG}_ID_NAME_URL A INNER JOIN WT_PROD B ON (A.PRODUCT_ID = B.PRODUCT_ID)
     WHERE COALESCE(A.PRODUCT_NAME, '') <> ''
  ORDER BY PRODUCT_NAME COLLATE "ko_KR.utf8"