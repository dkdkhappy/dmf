/* 2. 도우인 경쟁사 시계열 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST({FR_MNTH}||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST({TO_MNTH}||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,COALESCE({CATE_NO},   '20029')                                                      AS CATE_NO    /* 사용자가 선택한 카테고리 ex) '20029' (메이크업/향수/미용 도구) 또는 '20085' (미용 및 스킨케어) */
              ,COALESCE({CHRT_TYPE}, 'SHOP')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'SHOP' 또는 'PROD' */
    ), WT_COL_NM AS
    (
        SELECT 'SHOP'               AS CHRT_TYPE
              ,SHOP_ID              AS COL_ID
              ,MAX(SHOP_NAME_KR)    AS COL_NM
          FROM DASH_RAW.OVER_DOUYIN_STORE_NAME
      GROUP BY SHOP_ID
     UNION ALL
        SELECT 'PROD'               AS CHRT_TYPE
              ,PRODUCT_ID           AS COL_ID
              ,MAX(PRODUCT_NAME_KR) AS COL_NM
          FROM DASH_RAW.OVER_DOUYIN_PROD_NAME_KR
      GROUP BY PRODUCT_ID
    ), WT_DATA AS
    (
        SELECT DATE
              ,SHOP_ID           AS SHOP_ID
              ,SHOP_LOGO_URL     AS SHOP_URL
              ,PRODUCT_ID        AS PROD_ID
              ,PRODUCT_IMAGE_URL AS PROD_URL
              ,LOST_POPULARITY   AS LOST_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH_RAW.COMP_{TAG}_COMPETE
         WHERE DATE BETWEEN (SELECT FR_DT FROM WT_WHERE) AND (SELECT TO_DT FROM WT_WHERE)
           AND CATEGORY = (SELECT CATE_NO FROM WT_WHERE)
    ), WT_SUM_RANK AS
    (
        SELECT CHRT_TYPE
              ,    CASE WHEN CHRT_TYPE = 'SHOP' THEN SHOP_ID  ELSE PROD_ID  END  AS COL_ID
              ,MAX(CASE WHEN CHRT_TYPE = 'SHOP' THEN SHOP_URL ELSE PROD_URL END) AS COL_URL
              ,SUM(LOST_CNT)                                                     AS LOST_CNT
         FROM WT_DATA
     GROUP BY CHRT_TYPE
             ,COL_ID
    ), WT_RANK AS 
    (
        SELECT CHRT_TYPE
              ,COL_ID
              ,COL_URL
              ,LOST_CNT
              ,ROW_NUMBER() OVER(ORDER BY LOST_CNT DESC, COL_ID) AS COL_RANK
         FROM WT_SUM_RANK
    ), WT_SUM AS
    (
        SELECT CHRT_TYPE
              ,DATE                                                              AS X_DT
              ,    CASE WHEN CHRT_TYPE = 'SHOP' THEN SHOP_ID  ELSE PROD_ID  END  AS COL_ID
              ,MAX(CASE WHEN CHRT_TYPE = 'SHOP' THEN SHOP_URL ELSE PROD_URL END) AS COL_URL
              ,SUM(LOST_CNT)                                                     AS LOST_CNT
         FROM WT_DATA
     GROUP BY CHRT_TYPE
             ,DATE
             ,COL_ID
    ), WT_BASE AS 
    (
        SELECT A.X_DT
              ,A.COL_ID
              ,B.COL_NM
              ,SUM(A.LOST_CNT) AS LOST_CNT
          FROM WT_SUM A LEFT OUTER JOIN WT_COL_NM B ON (A.CHRT_TYPE = B.CHRT_TYPE AND A.COL_ID = B.COL_ID)
         WHERE A.COL_ID IN (SELECT COL_ID FROM WT_RANK WHERE COL_RANK <= 5)
      GROUP BY A.X_DT
              ,A.COL_ID
              ,B.COL_NM
    )
    SELECT (SELECT COL_RANK FROM WT_RANK X WHERE X.COL_ID = A.COL_ID AND X.COL_RANK <= 5) AS SORT_KEY
          ,COL_ID                   AS L_LGND_ID
          ,SUBSTRING(COL_NM, 1, 30) AS L_LGND_NM
          ,X_DT
          ,LOST_CNT                 AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT