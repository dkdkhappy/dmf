/* 3. 네이버 데이터 기준 성별 분포(남, 여), 연령별 분포, 정보성 상업성 비율 - 성별, 연령, 정보/상업 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE({KWRD_NM}, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_BASE AS
    (
        SELECT CAST(MALE        AS DECIMAL(20,2)) AS MALE_RATE
              ,CAST(FEMALE      AS DECIMAL(20,2)) AS FEME_RATE
              ,CAST(AGE_0_19    AS DECIMAL(20,2)) AS AGE_10_RATE
              ,CAST(AGE_20_29   AS DECIMAL(20,2)) AS AGE_20_RATE
              ,CAST(AGE_30_39   AS DECIMAL(20,2)) AS AGE_30_RATE
              ,CAST(AGE_40_49   AS DECIMAL(20,2)) AS AGE_40_RATE
              ,CAST(AGE_50_OVER AS DECIMAL(20,2)) AS AGE_50_RATE
              ,CAST(INFORM      AS DECIMAL(20,2)) AS INFO_RATE
              ,CAST(COMMERCIAL  AS DECIMAL(20,2)) AS COMM_RATE
          FROM KEYWORDPD.REL_NAVER_STAT
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    )
    SELECT MALE_RATE    /* 남성 비율 */
          ,FEME_RATE    /* 여성 비율 */
          ,AGE_10_RATE  /* 10대 비율 */
          ,AGE_20_RATE  /* 20대 비율 */
          ,AGE_30_RATE  /* 30대 비율 */
          ,AGE_40_RATE  /* 40대 비율 */
          ,AGE_50_RATE  /* 50대 이상 비율 */
          ,INFO_RATE    /* 정보성 비율 */
          ,COMM_RATE    /* 상업성 비율 */
      FROM WT_BASE