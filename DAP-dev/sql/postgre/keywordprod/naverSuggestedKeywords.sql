/* 6. Naver 연관 키워드 List - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_BASE_DT as (
    SELECT (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '1 MONTH') AS BASE_DT
    , (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '13 MONTH') AS BASE_DT_YOY
	 FROM keywordpd.rel_naver_stat 
	 LIMIT 1), WT_BASE AS
    (
        SELECT KEYWORD       AS KWRD_NM
              ,VOLUME        AS N_VOL
              ,ADCOMPETITION AS N_COMP
              ,ROW_NUMBER() OVER(ORDER BY VOLUME DESC NULLS LAST) AS N_RANK
          FROM KEYWORDPD.REL_NAVER_RELKEY A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ) , WT_YVOL as (
        SELECT BASE_KEYWORD       AS KWRD_NM
          ,SUM(searchvolume)        AS N_VOL_YOY
      FROM KEYWORDPD.rel_naver_vol A
     WHERE A.BASE_KEYWORD IN (SELECT KWRD_NM FROM WT_BASE)         
     and (cast(CONCAT(period, '-01') AS DATE) between  (select BASE_DT_YOY from WT_BASE_DT) and  (select BASE_DT from WT_BASE_DT))
     group by BASE_KEYWORD

    )SELECT A.KWRD_NM                                           /* 키워드 명         */
          ,TO_CHAR(A.N_VOL, 'FM999,999,999,999,999') AS N_VOL  /* 과거 1달전 검색량 */
          ,TO_CHAR(coalesce (B.N_VOL_YOY, 0),'FM999,999,999,999,999' ) as  N_VOL_YOY /* 과거 1년간 검색량 */
          ,N_COMP                                            /* 경쟁률            */
      FROM WT_BASE A left join WT_YVOL b on A.KWRD_NM = B.KWRD_NM
  ORDER BY coalesce(B.N_VOL_YOY, 0) DESC, A.N_VOL DESC