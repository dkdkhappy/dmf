/* 3. 토픽별/제품별 히트맵 overview - 히트 맵 그래프 (X축 제품) SQL */
/* 히트 맵은 X축 데이터를 생성할 때 왼쪽에서 오른쪽 순서로 나와야한다. */
/* Data를 셋팅할때 [0, 0, 1]  [Y, X, Value] 로 셋팅하기 때문에...      */
/* SQL의 결과는 사용자가 입력한 제품 순서대로 정렬되어 리턴된다.       */
WITH WT_PROD_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY 
              ,TRIM(PROD_ID)        AS PROD_ID
          FROM REGEXP_SPLIT_TO_TABLE({PROD_ID}, ',') AS PROD_ID  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex)'617136486827,621909301972,43249505908,12669264079' */        
    ),WT_PROD_TYPE AS
    (
        SELECT BRAND AS BRND_NM
              ,NAME  AS PROD_NM
              ,ID    AS PROD_ID
          FROM REVIEW_RAW.OVER_{CHNL_L_ID}_ID_NAME
         WHERE ID IN (SELECT PROD_ID FROM WT_PROD_WHERE)
    ), WT_PROD AS
    (
        SELECT BRND_NM
              ,PROD_NM
              ,PROD_ID
          FROM WT_PROD_TYPE A
      GROUP BY BRND_NM, PROD_NM, PROD_ID
    )
    SELECT ROW_NUMBER() OVER(ORDER BY (SELECT SORT_KEY FROM WT_PROD_WHERE X WHERE X.PROD_ID = A.PROD_ID)) -1 AS SORT_KEY
          ,BRND_NM                         /* 브랜드 명     */
          ,PROD_NM                         /* 제품 명       */
          ,PROD_ID
      FROM WT_PROD A
  ORDER BY SORT_KEY
