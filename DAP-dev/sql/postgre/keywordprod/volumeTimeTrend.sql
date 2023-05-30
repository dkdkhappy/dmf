/* 4. Volume Time trend - 시계열 그래프 SQL*/
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_MON_G as (
     select MAX(cast(CONCAT(DATE, '-01') as DATE)) as END_MNTH  
     , MAX(cast(CONCAT(DATE, '-01') AS DATE) - INTERVAL '1 YEAR') AS STD_MNTH
 	 FROM KEYWORDPD.REL_GOOGLE_VOL
	 WHERE KEYWORD IN (SELECT  LOWER(KWRD_NM) FROM WT_WHERE)
    ), WT_G_VOL AS
    (
        SELECT KEYWORD             AS KWRD_NM                                                
              , DATE               AS MNTH
              ,COALESCE(VOLUME, 0) AS MNTH_VOL
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD IN (SELECT  LOWER(KWRD_NM) FROM WT_WHERE) and cast(CONCAT(DATE, '-01') as DATE)  between (select STD_MNTH from WT_MON_G) and (select END_MNTH from WT_MON_G) 
    ) , WT_N_VOL AS
    (
        SELECT BASE_KEYWORD              AS KWRD_NM                                                
              ,PERIOD                    AS MNTH
              ,COALESCE(SEARCHVOLUME, 0) AS MNTH_VOL
          FROM KEYWORDPD.REL_NAVER_VOL
         WHERE BASE_KEYWORD IN (SELECT KWRD_NM FROM WT_WHERE ) and cast(CONCAT(period , '-01') as DATE)  between (select STD_MNTH from WT_MON_G) and (select END_MNTH from WT_MON_G)
    ) , WT_JOIN AS
    (
        SELECT COALESCE(A.KWRD_NM, B.KWRD_NM)                    AS KWRD_NM
              ,COALESCE(A.MNTH, B.MNTH)                          AS MNTH
              ,COALESCE(A.MNTH_VOL, 0) + COALESCE(B.MNTH_VOL, 0) AS MNTH_VOL
          FROM WT_G_VOL A FULL OUTER JOIN WT_N_VOL B 
            ON (A.KWRD_NM = B.KWRD_NM AND A.MNTH = B.MNTH)
    ), WT_BASE AS 
    (
        SELECT (SELECT SORT_KEY FROM WT_WHERE X WHERE X.KWRD_NM = A.KWRD_NM) AS SORT_KEY
              ,KWRD_NM
              ,MNTH
              ,MNTH_VOL
          FROM WT_JOIN A
    )
    SELECT lower(KWRD_NM)  AS L_LGND  /* 검색 키워드 */
          ,MNTH     AS X_DT    /* 검색량 월 */
          ,sum(MNTH_VOL) AS Y_VAL   /* 검색량    */
      FROM WT_BASE
	  group by lower(KWRD_NM), x_dt
      ORDER BY X_DT

