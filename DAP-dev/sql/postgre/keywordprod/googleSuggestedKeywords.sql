/* 5. Google 연관 키워드 List - 표 SQL*/
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,lower(TRIM(KWRD_NM))        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_REL AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.REL_GOOGLE A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_G_TREND_REL AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.rel_google_trend_rel  A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_G_REL_TTL as (
    select KEYWORD 
    from WT_G_REL
    union 
    select KEYWORD 
    from WT_G_TREND_REL
    
    ), WT_BASE_DT AS (
    SELECT (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '1 MONTH') AS BASE_DT
    , (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '13 MONTH') AS BASE_DT_YOY
	 FROM keywordpd.rel_naver_stat 
	 LIMIT 1
	 ), WT_BASE AS
    (
        SELECT A.KEYWORD AS KWRD_NM
              ,coalesce(B.VOLUME, 0 )  AS G_VOL
              ,COALESCE(B.CPC, 0)     AS G_CPC
              ,ROW_NUMBER() OVER(ORDER BY B.VOLUME DESC NULLS LAST) AS G_RANK
          FROM WT_G_REL_TTL A LEFT OUTER JOIN KEYWORDPD.REL_GOOGLE_STAT B
            ON (A.KEYWORD = B.KEYWORD)
    ), WT_YVOL as (
    SELECT KEYWORD       AS KWRD_NM
          , SUM(coalesce (VOLUME, 0))        AS G_VOL_YOY
      FROM KEYWORDPD.rel_GOOGLE_VOL A
     WHERE A.KEYWORD IN (SELECT KWRD_NM FROM WT_BASE)         
     and (cast(CONCAT(DATE, '-01') AS DATE) between  (select BASE_DT_YOY from WT_BASE_DT) and  (select BASE_DT from WT_BASE_DT))
     group by KEYWORD

    ) 
    SELECT A.KWRD_NM                                           /* 키워드 명         */
          ,TO_CHAR(A.G_VOL, 'FM999,999,999,999,999') AS G_VOL  /* 과거 1달전 검색량 */
          ,TO_CHAR(coalesce(B.G_VOL_YOY, 0), 'FM999,999,999,999,999') AS G_VOL_YOY  /* 과거 1달전 검색량 */
          ,G_CPC                                             /* CPC               */
      FROM WT_BASE  A left outer join WT_YVOL B on A.KWRD_NM = B.KWRD_NM
  ORDER BY coalesce(B.G_VOL_YOY, 0) desc, coalesce(A.G_VOL, 0) DESC
