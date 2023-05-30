/* 6. 채널 내 라이브 매출 순위 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT CAST(CAST({FR_MNTH} || '-01' AS DATE) AS TEXT)                                                  AS FR_DT /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,TO_CHAR(CAST({TO_MNTH} || '-01' AS DATE) + INTERVAL '1' MONTH - INTERVAL '1' DAY, 'YYYY-MM-DD') AS TO_DT /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{MLTI_YN} AS MLTI_YN /* 사용자가 선택한 화장품전문몰 제외  ex) 전체:%, 화장품전문몰 제외:N  */
              ,{KR_YN}   AS KR_YN   /* 사용자가 선택한 국가               ex) 전체:%, 한국:Y               */
              ,{DEMA_YN} AS DEMA_YN /* 사용자가 선택한 더마여부           ex) 전체:%, 더마:Y, 더마 외:N    */
    ), WT_SHOP_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY 
              ,TRIM(SHOP_ID)                         AS SHOP_ID
          FROM REGEXP_SPLIT_TO_TABLE({SHOP_ID}, ',') AS SHOP_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '67597230, 60637940, 492216636' */
         WHERE TRIM(SHOP_ID) <> ''
    ), WT_SHOP_RAW AS
    (
        SELECT NICKNAME AS SHOP_NAME_CN
              ,''       AS NATN_LIST
              ,1        AS NATN_CNT
              ,0        AS DEMA_YN
          FROM DASH_RAW.OVER_{TAG}_LIVE_RANK_DATA
    ), WT_SHOP AS
    (
        SELECT SHOP_NAME_CN
              ,NATN_LIST
              ,NATN_CNT
              ,CASE WHEN NATN_CNT > 1                      THEN 'Y' ELSE 'N' END AS MLTI_YN
              ,CASE WHEN POSITION('한국' IN NATN_LIST) > 0 THEN 'Y' ELSE 'N' END AS KR_YN
              ,CASE WHEN DEMA_YN = 1                       THEN 'Y' ELSE 'N' END AS DEMA_YN
          FROM WT_SHOP_RAW
    ), WT_SALE AS
    (
        SELECT DISTINCT
               A.NICKNAME                             AS SHOP_ID
              ,C.LIVE_NAME_KR                         AS SHOP_NM
              ,A.TRADE_INDEX                          AS SALE_AMT
              ,B.NATN_LIST                            AS NATN_NM
              ,B.NATN_CNT                             AS NATN_CNT
              ,B.MLTI_YN                              AS MLTI_YN
              ,B.KR_YN                                AS KR_YN
              ,CASE WHEN B.DEMA_YN = 'Y' THEN '●' END AS DEMA_YN
              ,A.DATE
          FROM DASH_RAW.OVER_{TAG}_LIVE_RANK_DATA A 
          INNER JOIN WT_SHOP B ON (A.NICKNAME = B.SHOP_NAME_CN)
           LEFT JOIN DASH_RAW.OVER_DOUYIN_LIVE_NAME C ON (A.NICKNAME = C.LIVE_NAME_CN)
         WHERE A.DATE BETWEEN (SELECT FR_DT   FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND A.CATEGORY = '20085'
           AND B.MLTI_YN LIKE (SELECT MLTI_YN FROM WT_WHERE)
           AND B.KR_YN   LIKE (SELECT KR_YN   FROM WT_WHERE)
           AND B.DEMA_YN LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SHOP_ID        AS SHOP_ID
              ,SHOP_NM        AS SHOP_NM
              ,SUM(SALE_AMT) / (CAST((SELECT TO_DT FROM WT_WHERE) AS DATE) - CAST((SELECT FR_DT FROM WT_WHERE) AS DATE))  AS SALE_AMT
              ,MAX(NATN_NM)   AS NATN_NM
              ,MAX(NATN_CNT)  AS NATN_CNT
              ,MAX(MLTI_YN)   AS MLTI_YN
              ,MAX(KR_YN)     AS KR_YN
              ,MAX(DEMA_YN)   AS DEMA_YN
          FROM WT_SALE
      GROUP BY SHOP_ID
              ,SHOP_NM
    ), WT_BASE AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY SALE_AMT DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
              ,SHOP_ID
              ,SHOP_NM
              ,SALE_AMT
              ,CASE WHEN NATN_CNT = 1 THEN NATN_NM ELSE '다국적' END AS NATN_NM
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_SUM
    )
    SELECT SHOP_RANK
          ,SHOP_ID
          ,SHOP_NM
          ,CAST(SALE_AMT AS DECIMAL(20,2)) AS SALE_RATE
          ,NATN_NM
          ,MLTI_YN
          ,KR_YN
          ,DEMA_YN
      FROM WT_BASE
     WHERE ((SELECT COUNT(*) FROM WT_SHOP_WHERE) > 0 AND SHOP_ID IN (SELECT SHOP_ID FROM WT_SHOP_WHERE))
        OR ((SELECT COUNT(*) FROM WT_SHOP_WHERE) = 0 )
  ORDER BY SHOP_RANK
     LIMIT 300

