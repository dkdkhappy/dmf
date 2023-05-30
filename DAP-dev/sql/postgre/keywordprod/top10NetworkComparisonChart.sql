WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '마스크' */
    ),  WT_BASE_DT AS 
    (
    	SELECT (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '1 MONTH') AS BASE_DT
    		 , (cast(CONCAT(substr(DATE, 0, 8), '-01') AS DATE) - INTERVAL '13 MONTH') AS BASE_DT_YOY
	 	  FROM keywordpd.rel_naver_stat 
	 	  LIMIT 1
	 ), WT_G_REL AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.REL_GOOGLE A
         WHERE BASE_KEYWORD = (SELECT lower(KWRD_NM) FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_G_REL_TREND AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.REL_GOOGLE_TREND_REL A
         WHERE BASE_KEYWORD = (SELECT lower(KWRD_NM) FROM WT_WHERE WHERE SORT_KEY = 1)
    ) , WT_G_REL_FULL AS(
        SELECT KEYWORD
        FROM WT_G_REL
        UNION
        SELECT KEYWORD 
        FROM WT_G_REL_TREND 
    ), WT_G_RANK_MOM AS
    (
        SELECT A.KEYWORD                                                                            AS KWRD_NM
              ,ROW_NUMBER() OVER(ORDER BY B.VOLUME DESC NULLS LAST, A.KEYWORD COLLATE "ko_KR.utf8") AS G_RANK_MOM
              ,coalesce(B.VOLUME, 0)                                                                               AS G_VOL_MOM
          FROM WT_G_REL_FULL A LEFT OUTER JOIN KEYWORDPD.REL_GOOGLE_STAT B
            ON (A.KEYWORD = B.KEYWORD)
    ), WT_G_RANK_YOY as (
	    SELECT KEYWORD       AS KWRD_NM
          	  ,ROW_NUMBER() OVER(ORDER BY SUM(coalesce (VOLUME, 0))  DESC NULLS LAST, A.KEYWORD COLLATE "ko_KR.utf8") AS G_RANK_YOY
              , SUM(coalesce (VOLUME, 0	))    																		  AS G_VOL_YOY
      	FROM KEYWORDPD.rel_GOOGLE_VOL A
     	WHERE A.KEYWORD IN (SELECT KWRD_NM FROM WT_G_RANK_MOM)         
     	and (cast(CONCAT(DATE, '-01') AS DATE) between  (select BASE_DT_YOY from WT_BASE_DT) and  (select BASE_DT from WT_BASE_DT))
     	group by KEYWORD

    ),  WT_N_RANK_MOM AS
    (
        SELECT KEYWORD                                                                          AS KWRD_NM
              ,ROW_NUMBER() OVER(ORDER BY VOLUME DESC NULLS LAST, KEYWORD COLLATE "ko_KR.utf8") AS N_RANK_mom
              ,coalesce(VOLUME, 0)                                                                           AS N_VOL_mom
          FROM KEYWORDPD.REL_NAVER_RELKEY A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_N_RANK_YOY as (
	  	SELECT BASE_KEYWORD      																AS KWRD_NM
	    	  ,ROW_NUMBER() OVER(ORDER BY SUM(coalesce (searchvolume,0)) DESC NULLS LAST, base_keyword  COLLATE "ko_KR.utf8") AS N_RANK_yoy
          	  ,SUM(coalesce (searchvolume,0))        															AS N_VOL_YOY
     	 FROM KEYWORDPD.rel_naver_vol A
     	WHERE A.BASE_KEYWORD IN (SELECT KWRD_NM FROM WT_N_RANK_MOM)         
     	and (cast(CONCAT(period, '-01') AS DATE) between  (select BASE_DT_YOY from WT_BASE_DT) and  (select BASE_DT from WT_BASE_DT))
     	group by BASE_KEYWORD
     
     

    ), WT_N_RANK as (
   		select A.KWRD_NM 
  	    	  ,ROW_NUMBER() OVER(ORDER BY coalesce (A.N_VOL_MOM,0) DESC NULLS LAST, A.KWRD_NM  COLLATE "ko_KR.utf8") as N_RANK_MOM
	    	  ,coalesce (A.N_VOL_MOM,0) as  N_VOL_MOM
	    	  ,ROW_NUMBER() OVER(ORDER BY coalesce (B.N_VOL_YOY,0) DESC NULLS LAST, A.KWRD_NM  COLLATE "ko_KR.utf8") as N_RANK_YOY
	    	  ,coalesce (B.N_VOL_YOY,0) as  N_VOL_YOY
    
    	from WT_N_RANK_MOM A left outer join WT_N_RANK_YOY B on A.KWRD_NM = B.KWRD_NM
    ) , WT_G_RANK as (
   		select A.KWRD_NM 
  	    	  ,ROW_NUMBER() OVER(ORDER BY coalesce (A.G_VOL_MOM,0) DESC NULLS LAST, A.KWRD_NM  COLLATE "ko_KR.utf8") as G_RANK_MOM
	    	  ,coalesce (A.G_VOL_MOM,0) as  G_VOL_MOM
	    	  ,ROW_NUMBER() OVER(ORDER BY coalesce (B.G_VOL_YOY,0) DESC NULLS LAST, A.KWRD_NM  COLLATE "ko_KR.utf8") as G_RANK_YOY
	    	  ,coalesce (B.G_VOL_YOY,0) as  G_VOL_YOY
    
    	from WT_G_RANK_MOM A left outer join WT_G_RANK_YOY B on A.KWRD_NM = B.KWRD_NM
    ),  WT_BASE AS 
    (
        SELECT 'GOOGLE' AS NODE_KEY
              ,KWRD_NM
              ,G_VOL_{VOL}    AS VOL
              ,G_RANK_{VOL}   as RANK
          FROM WT_G_RANK
         WHERE G_RANK_{VOL} <= 30
     UNION ALL
        SELECT 'NAVER' AS NODE_KEY
              ,KWRD_NM
              ,N_VOL_{VOL}   AS VOL
              ,N_RANK_{VOL}   as RANK
          FROM WT_N_RANK
         WHERE N_RANK_{VOL} <= 30
    )
    SELECT NODE_KEY /* GOOGLE, NAVER */
          ,KWRD_NM  /* 키워드 명     */
          ,VOL      /* 조회량        */
          ,RANK     /* 순위          */
      FROM WT_BASE
  ORDER BY NODE_KEY
          ,RANK
    


  