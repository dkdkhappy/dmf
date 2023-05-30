/* 3. 도우인 내륙 채널 클릭한 사람 수  - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT} AS FR_DT  /* 사용자가 선택한 기간 - 시작일  ex) '2023-02-01'  */
              ,{TO_DT} AS TO_DT  /* 사용자가 선택한 기간 - 종료일  ex) '2023-02-13'  */
    ), WT_VIST AS 
    (
        SELECT CAST(CAST(DATE AS TEXT) AS DATE)         AS X_DT
              ,ROUND((SUM(PRODUCT_CLICKS)/SUM(PRODUCT_IMPRESSIONS))*100, 2)  AS VIST_CNT  /* 클릭한 사람수 */
          FROM DASH_RAW.OVER_{TAG}_TRANSACTION_OVERVIEW A
         WHERE  CAST(CAST(DATE AS TEXT) AS DATE)   BETWEEN (SELECT CAST(CAST(FR_DT AS TEXT) AS DATE)  FROM WT_WHERE) AND (SELECT CAST(CAST(TO_DT AS TEXT) AS DATE) FROM WT_WHERE)
      GROUP BY DATE
    ), WT_BASE AS
    (
        SELECT X_DT
              ,VIST_CNT
          FROM WT_VIST
    )
    SELECT X_DT
          ,VIST_CNT AS Y_VAL
      FROM WT_BASE
  ORDER BY X_DT