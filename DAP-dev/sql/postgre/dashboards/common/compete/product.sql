/* 2. 제품선택(복수선택가능) 자사의 Tmall 제품선택창 - 제품선택 SQL */
/*    제품 Select Box 에서 사용, 여기에서는 제품ID가 아닌 제품명을 사용한다. */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
    ), WT_PROD AS
    (
        SELECT DISTINCT
               OWN_PROD_NAME AS PROD_NM
          FROM DASH.{TAG}_COMP_COMPETE A
         /* WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE) */
         WHERE COALESCE(OWN_PROD_NAME, '') != ''
    )
    SELECT PROD_NM
      FROM WT_PROD
  ORDER BY PROD_NM COLLATE "ko_KR.utf8"