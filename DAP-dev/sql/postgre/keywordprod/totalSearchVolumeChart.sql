/* 2. Volume, Google Traffic, Naver Traffic, CPC -  Chart SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_VOL AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY DATE DESC)                 AS SORT_KEY
              ,DATE                                                  AS MNTH
              ,COALESCE(VOLUME, 0)                                   AS MNTH_VOL
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD = (SELECT  LOWER(KWRD_NM) FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_N_VOL AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY PERIOD DESC)               AS SORT_KEY
              ,PERIOD                                                AS MNTH
              ,COALESCE(SEARCHVOLUME, 0)                             AS MNTH_VOL
          FROM KEYWORDPD.REL_NAVER_VOL
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_BASE AS
    (
        SELECT 'TOTAL'                                           AS CHRT_KEY 
              ,COALESCE(A.MNTH, B.MNTH)                          AS MNTH
              ,COALESCE(A.MNTH_VOL, 0) + COALESCE(B.MNTH_VOL, 0) AS MNTH_VOL
          FROM WT_G_VOL A FULL OUTER JOIN WT_N_VOL B ON (A.MNTH = B.MNTH)
     UNION ALL
        SELECT 'GOOGLE' AS CHRT_KEY
              ,MNTH
              ,MNTH_VOL
          FROM WT_G_VOL
     UNION ALL
        SELECT 'NAVER' AS CHRT_KEY
              ,MNTH
              ,MNTH_VOL
          FROM WT_N_VOL
    )
    SELECT CHRT_KEY           /* TOTAL, GOOGLE, NAVER */
          ,MNTH     AS X_DT   /* 검색량 월 */
          ,MNTH_VOL AS Y_VAL  /* 검색량    */
      FROM WT_BASE