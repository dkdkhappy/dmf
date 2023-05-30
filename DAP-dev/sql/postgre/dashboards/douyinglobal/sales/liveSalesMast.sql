/* 10. 라이브별 매출 정보 시계열 그래프 - 라이브별 선택 SQL */
WITH WT_WHERE AS
    (
        SELECT {FR_DT}  AS FR_DT           /* 사용자가 선택한 기간 - 시작일  ※ 최초 셋팅값 : 이번달 1일  ex) '2023-02-01'  */
              ,{TO_DT}  AS TO_DT           /* 사용자가 선택한 기간 - 종료일  ※ 최초 셋팅값 : 오늘  -1일  ex) '2023-02-13'  */
    ), WT_LIVE AS
    (
        SELECT DISTINCT
               ACCOUNT_NAME
          FROM DASH_RAW.OVER_{TAG}_ACCOUNT_COMPOSITION A
         WHERE TO_CHAR(CAST(CAST(DATE AS VARCHAR) AS DATE), 'YYYY-MM-DD') BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND ACCOUNT_NAME LIKE '%DERMAFIRM%'
         UNION
        SELECT '기타' AS ACCOUNT_NAME
    ) SELECT ACCOUNT_NAME AS LIVE_ID
            ,ACCOUNT_NAME AS LIVE_NM
      FROM WT_LIVE