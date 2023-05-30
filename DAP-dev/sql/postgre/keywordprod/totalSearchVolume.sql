/* 2. Volume, Google Traffic, Naver Traffic, CPC -  전체 검색량 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ),WT_MON_G as (
     select MAX(cast(CONCAT(DATE, '-01') as DATE)) as END_MNTH  
     , MAX(cast(CONCAT(DATE, '-01') AS DATE) - INTERVAL '1 YEAR') AS STD_MNTH
 	 FROM KEYWORDPD.REL_GOOGLE_VOL
	 WHERE KEYWORD IN (SELECT  LOWER(KWRD_NM) FROM WT_WHERE)
    ), WT_G_VOL AS
    (
        SELECT COALESCE(SUM(VOLUME) OVER(), 0)                       AS VOL
              ,ROW_NUMBER() OVER(ORDER BY DATE DESC)                 AS SORT_KEY
              ,DATE                                                  AS MNTH
              ,COALESCE(VOLUME, 0)                                   AS MNTH_VOL
              ,COALESCE(LEAD(VOLUME, 1) OVER(ORDER BY DATE DESC), 0) AS MNTH_VOL_MOM
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD = (SELECT  LOWER(KWRD_NM) FROM WT_WHERE WHERE SORT_KEY = 1) and cast(CONCAT(DATE, '-01') as DATE)  between (select STD_MNTH from WT_MON_G) and (select END_MNTH from WT_MON_G) 
    ), WT_N_VOL AS
    (
        SELECT COALESCE(SUM(SEARCHVOLUME) OVER(), 0)                 AS VOL
              ,ROW_NUMBER() OVER(ORDER BY PERIOD DESC)               AS SORT_KEY
              ,PERIOD                                                AS MNTH
              ,COALESCE(SEARCHVOLUME, 0)                             AS MNTH_VOL
              ,COALESCE(LEAD(SEARCHVOLUME, 1) OVER(ORDER BY DATE DESC), 0) AS MNTH_VOL_MOM
          FROM KEYWORDPD.REL_NAVER_VOL
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1) and cast(CONCAT(PERIOD, '-01') as DATE)  between (select STD_MNTH from WT_MON_G) and (select END_MNTH from WT_MON_G)
    ), WT_G_CPC AS
    (
        SELECT CPC AS CPC
          FROM KEYWORDPD.REL_GOOGLE_STAT
         WHERE KEYWORD = (SELECT  LOWER(KWRD_NM) FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_MAX AS 
    (
        SELECT (SELECT COALESCE(MAX(VOL         ), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL    ), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_MNTH_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL_MOM), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_MNTH_VOL_MOM
              ,(SELECT COALESCE(MAX(VOL         ), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL    ), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_MNTH_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL_MOM), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_MNTH_VOL_MOM
              ,(SELECT          MAX(CPC         )     FROM WT_G_CPC                   ) AS G_CPC
              ,(select coalesce(SUM(MNTH_VOL_MOM), 0) from WT_G_VOL)					as G_VOL_MOM
              ,(select coalesce(SUM(MNTH_VOL_MOM), 0) from WT_N_VOL)					as N_VOL_MOM
              
    ) ,  WT_BASE AS
    (
        SELECT G_VOL + N_VOL AS T_VOL
        	  ,G_VOL_MOM + N_VOL_MOM as T_VOL_MOM
              ,CASE 
                 WHEN (G_VOL_MOM + N_VOL_MOM) = 0
                 THEN NULL
                 ELSE ((G_VOL + N_VOL) - (G_VOL_MOM + N_VOL_MOM)) / (G_VOL_MOM + N_VOL_MOM) * 100
               END AS T_VOL_RATE
              ,G_VOL
              ,CASE 
                 WHEN G_VOL_MOM = 0
                 THEN NULL
                 ELSE (G_VOL - G_VOL_MOM) / G_VOL_MOM * 100
               END AS G_VOL_RATE
              ,N_VOL
              ,CASE 
                 WHEN N_VOL_MOM = 0
                 THEN NULL
                 ELSE (N_VOL - N_VOL_MOM) / N_VOL_MOM * 100
               END AS N_VOL_RATE
              ,G_CPC
          FROM WT_MAX
    ) SELECT COALESCE(CAST(T_VOL      AS DECIMAL(20,0)), 0) AS T_VOL       /* Voume          - 전체 검색량   */
          ,COALESCE(CAST(T_VOL_RATE AS DECIMAL(20,2)), 0) AS T_VOL_RATE  /* Voume          - 증감률        */
          ,COALESCE(CAST(G_VOL      AS DECIMAL(20,0)), 0) AS G_VOL       /* Google Traffic - 구글 검색량   */
          ,COALESCE(CAST(G_VOL_RATE AS DECIMAL(20,2)), 0) AS G_VOL_RATE  /* Google Traffic - 증감률        */
          ,COALESCE(CAST(N_VOL      AS DECIMAL(20,0)), 0) AS N_VOL       /* Naver  Traffic - 네이버 검색량 */
          ,COALESCE(CAST(N_VOL_RATE AS DECIMAL(20,2)), 0) AS N_VOL_RATE  /* Naver  Traffic - 증감률        */
          ,COALESCE(CAST(G_CPC      AS DECIMAL(20,2)), 0) AS G_CPC       /* CPC            - 구글 CPC      */
      FROM WT_BASE
