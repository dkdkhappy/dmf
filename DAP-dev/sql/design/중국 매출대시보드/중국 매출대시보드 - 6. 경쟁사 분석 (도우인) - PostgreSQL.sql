● 중국 매출대시보드 - 6. 경쟁사 분석 (도우인)

/* 아래 SQL은 PostgreSQL 문법으로 작성되어 있음!!! */

0. 화면 설명
    * 리뷰분석 경쟁사를 확인할 수 있는 경쟁사 분석 페이지 (페이지 중 도우인 탭)
    * 도우인은 제품별 정보가 없어서, 제품별로는 나눌수는 없고, 몰 전체 기준 이탈자들 대상으로 확인

1. 도우인 경쟁사 비중
    * 분석기간을 선택하는 기능(calendar) 월단위
    * 카테고리 선택 / 샵 여부 선택(샵인지 제품인지 선택)
    * 이탈한 삽(제품)들에 대한 PIE그래프 제공 (어떤제품에 가장 많이 이탈했는지 확인 가능)

/* 1. 도우인 경쟁사 비중 - 카테고리 선택 SQL */
WITH WT_BASE AS
    (
        SELECT CATEGORY_NO   AS CATE_NO
              ,CATEGORY_NAME AS CATE_NM
          FROM DASH_RAW.OVER_DOUYIN_ITEM_RANK_CATEGORY
         WHERE CATEGORY_NAME != '전체'
    )
    SELECT CATE_NO
          ,CATE_NM
      FROM WT_BASE
  ORDER BY CATE_NO
;

/* 1. 도우인 경쟁사 비중 - Pie Chart SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,COALESCE(:CATE_NO,   '20029')                                                      AS CATE_NO    /* 사용자가 선택한 카테고리 ex) '20029' (메이크업/향수/미용 도구) 또는 '20085' (미용 및 스킨케어) */
              ,COALESCE(:CHRT_TYPE, 'SHOP')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'SHOP' 또는 'PROD' */
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
        SELECT SHOP_ID           AS SHOP_ID
              ,SHOP_LOGO_URL     AS SHOP_URL
              ,PRODUCT_ID        AS PROD_ID
              ,PRODUCT_IMAGE_URL AS PROD_URL
              ,LOST_POPULARITY   AS LOST_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH_RAW.COMP_DGD_COMPETE
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
    ), WT_BASE AS 
    (
        SELECT CASE WHEN A.COL_RANK <= 5 THEN B.COL_NM ELSE '기타' END AS COL_NM
              ,SUM(A.LOST_CNT)                                         AS LOST_CNT
          FROM WT_RANK A LEFT OUTER JOIN WT_COL_NM B ON (A.CHRT_TYPE = B.CHRT_TYPE AND A.COL_ID = B.COL_ID)
      GROUP BY CASE WHEN A.COL_RANK <= 5 THEN B.COL_NM ELSE '기타' END
    )
    SELECT COL_NM                                                       AS COL_NM
          ,LOST_CNT                                                     AS LOST_CNT
          ,CAST(LOST_CNT / SUM(LOST_CNT) OVER() * 100 AS DECIMAL(20,2)) AS LOST_RATE
      FROM WT_BASE
  ORDER BY CASE WHEN COL_NM = '기타' THEN 2 ELSE 1 END
          ,LOST_CNT DESC
;


2. 도우인 경쟁사 시계열 그래프
    * 시계열 그래프로 상위 5가지 제품의 이탈자 수가 얼마나 변화하는지 누적그래프로 볼 수 있게 한다.
    * 누적그래프 제공시 어떤제품으로 언제 가장 많이 이탈하는지 확인이 가능할 것
    * 검색정보 기본 Top5

/* 2. 도우인 경쟁사 시계열 그래프 - 시계열 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,COALESCE(:CATE_NO,   '20029')                                                      AS CATE_NO    /* 사용자가 선택한 카테고리 ex) '20029' (메이크업/향수/미용 도구) 또는 '20085' (미용 및 스킨케어) */
              ,COALESCE(:CHRT_TYPE, 'SHOP')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'SHOP' 또는 'PROD' */
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
          FROM DASH_RAW.COMP_DGD_COMPETE
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
          ,COL_ID   AS L_LGND_ID
          ,COL_NM   AS L_LGND_NM
          ,X_DT
          ,LOST_CNT AS Y_VAL
      FROM WT_BASE A
  ORDER BY SORT_KEY
          ,X_DT
;


3. 도우인 경쟁사 목록
    * 상위 5개 제품 표기 
    * 순위, 제품(샵) 이미지, 제품(샵) 명

/* 3. 도우인 경쟁사 목록 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT TO_CHAR(CAST(:FR_MNTH||'-01' AS DATE)                              , 'YYYY-MM-DD') AS FR_DT      /* 사용자가 선택한 월 - 시작월 기준  1일 ex) '2023-02-01' */
              ,TO_CHAR(CAST(:TO_MNTH||'-01' AS DATE) + INTERVAL '1 MONTH - 1 DAY' , 'YYYY-MM-DD') AS TO_DT      /* 사용자가 선택한 월 - 종료월 기준 말일 ex) '2023-02-28' */
              ,COALESCE(:CATE_NO,   '20029')                                                      AS CATE_NO    /* 사용자가 선택한 카테고리 ex) '20029' (메이크업/향수/미용 도구) 또는 '20085' (미용 및 스킨케어) */
              ,COALESCE(:CHRT_TYPE, 'SHOP')                                                       AS CHRT_TYPE  /* 사용자가 선택한 그래프타입 ex) 'SHOP' 또는 'PROD' */
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
        SELECT SHOP_ID           AS SHOP_ID
              ,SHOP_LOGO_URL     AS SHOP_URL
              ,PRODUCT_ID        AS PROD_ID
              ,PRODUCT_IMAGE_URL AS PROD_URL
              ,LOST_POPULARITY   AS LOST_CNT
              ,(SELECT CHRT_TYPE FROM WT_WHERE) AS CHRT_TYPE
          FROM DASH_RAW.COMP_DGD_COMPETE
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
    ), WT_BASE AS 
    (
        SELECT A.COL_RANK AS SORT_KEY
              ,A.COL_ID
              ,B.COL_NM
              ,A.COL_URL
              ,LOST_CNT
          FROM WT_RANK A LEFT OUTER JOIN WT_COL_NM B ON (A.CHRT_TYPE = B.CHRT_TYPE AND A.COL_ID = B.COL_ID)
         WHERE COL_RANK <= 5
    )
    SELECT SORT_KEY    /* 정렬순서            */
          ,COL_ID      /* 샵(제품) ID         */
          ,COL_NM      /* 샵(제품) 명         */
          ,COL_URL     /* 샵(제품) 이미지 URL */
      FROM WT_BASE
  ORDER BY SORT_KEY
;