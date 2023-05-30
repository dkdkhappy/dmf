/* 12. 채널 내 매출 순위 - Tmall  표 SQL */
/* 조건은 KR_YN, DEMA_YN 만 적용하면 됨. MLTI_YN, SHOP_ID는 추후 필요 시 사용하도록 지우지 않음. */
WITH WT_WHERE AS
    (
        SELECT {FR_MNTH}                 AS FR_MNTH           /* 사용자가 선택한 월 - 시작월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,{TO_MNTH}                 AS TO_MNTH           /* 사용자가 선택한 월 - 종료월  ※ 최초 셋팅값 : 이번달  ex) '2023-02'  */
              ,COALESCE({MLTI_YN}, '%')  AS MLTI_YN           /* 사용자가 선택한 화장품전문몰 제외  ex) 전체:%, 화장품전문몰 제외:N  */
              ,COALESCE({KR_YN}  , '%')  AS KR_YN             /* 사용자가 선택한 국가               ex) 전체:%, 한국:Y               */
              ,COALESCE({DEMA_YN}, '%')  AS DEMA_YN           /* 사용자가 선택한 더마여부           ex) 전체:%, 더마:Y, 더마 외:N    */
    ), WT_SHOP_WHERE AS
    (
        SELECT ROW_NUMBER() OVER ()                  AS SORT_KEY 
              ,TRIM(SHOP_ID)                         AS SHOP_ID
          FROM REGEXP_SPLIT_TO_TABLE({SHOP_ID}, ',') AS SHOP_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '67597230, 60637940, 492216636' */
         WHERE TRIM(SHOP_ID) <> ''
    ), WT_SHOP_RAW AS
    (
        SELECT CAST(SHOP_ID AS TEXT)                   AS SHOP_ID
              ,ARRAY_TO_STRING(ARRAY_AGG(COUNTRY),',') AS NATN_LIST
              ,COUNT(DISTINCT COUNTRY)                 AS NATN_CNT
              ,MAX(DERMA)                              AS DEMA_YN
          FROM DASH_RAW.OVER_TMALL_RANK_STORE_COUNTRY
      GROUP BY SHOP_ID
    ), WT_SHOP AS
    (
        SELECT SHOP_ID
              ,NATN_LIST 
              ,NATN_CNT
              ,CASE WHEN NATN_CNT > 1                      THEN 'Y' ELSE 'N' END AS MLTI_YN
              ,CASE WHEN POSITION('한국' IN NATN_LIST) > 0 THEN 'Y' ELSE 'N' END AS KR_YN
              ,CASE WHEN DEMA_YN = 1                       THEN 'Y' ELSE 'N' END AS DEMA_YN
          FROM WT_SHOP_RAW
    ), WT_SALE AS
    (
        SELECT DISTINCT
               A.SHOP_ID                              AS SHOP_ID
              ,A.SHOP_NAME                            AS SHOP_NM
              ,A.SALE_AMT                             AS SALE_AMT
              ,B.NATN_LIST                            AS NATN_NM
              ,B.NATN_CNT                             AS NATN_CNT
              ,B.MLTI_YN                              AS MLTI_YN
              ,B.KR_YN                                AS KR_YN
              ,CASE WHEN B.DEMA_YN = 'Y' THEN '●' END AS DEMA_YN
              ,A.BASE_TIME
          FROM DASH.TMALL_STORE_RANK_DATA A INNER JOIN WT_SHOP B
            ON (A.SHOP_ID = B.SHOP_ID)
         WHERE A.BASE_TIME BETWEEN (SELECT FR_MNTH FROM WT_WHERE) AND (SELECT TO_MNTH FROM WT_WHERE)
           AND B.MLTI_YN LIKE (SELECT MLTI_YN FROM WT_WHERE)
           AND B.KR_YN   LIKE (SELECT KR_YN   FROM WT_WHERE)
           AND B.DEMA_YN LIKE (SELECT DEMA_YN FROM WT_WHERE)
    ), WT_SUM AS
    (
        SELECT SHOP_ID        AS SHOP_ID
              ,SHOP_NM        AS SHOP_NM
              ,SUM(SALE_AMT)  AS SALE_AMT
              ,MAX(NATN_NM)   AS NATN_NM
              ,MAX(NATN_CNT)  AS NATN_CNT
              ,MAX(MLTI_YN)   AS MLTI_YN
              ,MAX(KR_YN)     AS KR_YN
              ,MAX(DEMA_YN)   AS DEMA_YN
          FROM WT_SALE
      GROUP BY SHOP_ID
              ,SHOP_NM
    ), WT_RATE AS
    (
        SELECT SHOP_ID
              ,SHOP_NM
              ,SALE_AMT / SUM(SALE_AMT) OVER() * 100 AS SALE_RATE
              ,SALE_AMT
              ,SUM(SALE_AMT) OVER()                  AS SALE_AMT_SUM
              ,NATN_NM
              ,NATN_CNT
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_SUM
    ), WT_BASE AS
    (
        SELECT --ROW_NUMBER() OVER(ORDER BY SALE_RATE DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
               ROW_NUMBER() OVER(ORDER BY SALE_AMT DESC NULLS LAST, SHOP_NM) AS SHOP_RANK
              ,SHOP_ID
              ,SHOP_NM
              ,TO_CHAR(SALE_RATE, 'FM999,999,999,999,990.0000') AS SALE_RATE
              ,SALE_AMT
              ,SALE_AMT_SUM
              ,CASE WHEN NATN_CNT = 1 THEN NATN_NM ELSE '다국적' END AS NATN_NM
              ,MLTI_YN
              ,KR_YN
              ,DEMA_YN
          FROM WT_RATE
    )
    SELECT SHOP_RANK                                                /* 순위             */
          ,SHOP_ID                                                  /* 상점ID           */
          ,SHOP_NM                                                  /* 상점명           */
          ,TO_CHAR(SALE_AMT, 'FM999,999,999,999,999') AS SALE_RATE  /* 거래지수         */
          ,NATN_NM                                                  /* 국가             */
          ,MLTI_YN                                                  /* 화장품전문몰여부 */
          ,KR_YN                                                    /* 한국여부         */
          ,DEMA_YN                                                  /* 더마여부         */
      FROM WT_BASE
     WHERE ((SELECT COUNT(*) FROM WT_SHOP_WHERE) > 0 AND SHOP_ID IN (SELECT SHOP_ID FROM WT_SHOP_WHERE))
        OR ((SELECT COUNT(*) FROM WT_SHOP_WHERE) = 0 )
  ORDER BY SHOP_RANK
--     LIMIT 300