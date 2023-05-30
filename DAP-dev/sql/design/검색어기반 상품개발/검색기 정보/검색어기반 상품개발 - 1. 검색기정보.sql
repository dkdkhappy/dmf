● 검색어기반 상품개발 - 1. 검색기정보

0. 화면 설명
    * 검색어기반 상품개발에서 특정검색어를 검색할 경우, 해당 검색어에 대한 정보가 나타나도록
    * 특수검색은 가능하나, 2,3,4,5,6 정보는 제시된 검색어 중 제일 앞의 검색어 정보만 나타내고, 그 다음 검색어 들은 Volume trend 만 나타나도록


1. Keyword Analysis (Lastest Update : YYYY-MM-DD)
    * 분석할 수 있는 키워드 입력 및 마지막 업데이트 일자
        ==> 마지막 업데이트 일자를 가져오는 테이블, 컬럼
	        SELECT date FROM keywordpd.rel_naver_stat ;
        ==> 키워드는 사용자가 직접 입력


/* initData.sql */
/* 1. Keyword Analysis -  마지막 업데이트 일자 SQL */
SELECT DATE AS BASE_DT
  FROM keywordpd.rel_naver_stat 
 LIMIT 1;


2. Volume, Google Traffic, Naver Traffic, CPC
   왼쪽부터, 구글+네이버 검색량 합, 구글 검색량, 네이버 검색량, 구글 CPC
    ==> 조회 기간은?
    * 구글   검색량 
        ==> 테이블 : keywordpd.rel_google_vol
            컬럼   : keyword - 기준 키워드
                     date    - 기준월
                     volume  - 검색량
    * 네이버 검색량 
        ==> 테이블 : keywordpd.rel_naver_vol
            컬럼   : base_keyword - 기준 키워드
                     period       - 기준월
                     searchvolume - 검색량
    * 구글 CPC
        ==> 테이블 : keywordpd.rel_google_stat
            컬럼   : keyword - 기준 키워드
                     date    - 기준월
                     cpc     - CPC
        ==> CPC 는 미국달러(USD) 인가요? CPC 앞에 통화기호 때문에 문의 드립니다.


/* totalSearchVolume.sql */
/* 2. Volume, Google Traffic, Naver Traffic, CPC -  전체 검색량 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_VOL AS
    (
        SELECT COALESCE(SUM(VOLUME) OVER(), 0)                       AS VOL
              ,ROW_NUMBER() OVER(ORDER BY DATE DESC)                 AS SORT_KEY
              ,DATE                                                  AS MNTH
              ,COALESCE(VOLUME, 0)                                   AS MNTH_VOL
              ,COALESCE(LEAD(VOLUME, 1) OVER(ORDER BY DATE DESC), 0) AS MNTH_VOL_MOM
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_N_VOL AS
    (
        SELECT COALESCE(SUM(SEARCHVOLUME) OVER(), 0)                 AS VOL
              ,ROW_NUMBER() OVER(ORDER BY PERIOD DESC)               AS SORT_KEY
              ,PERIOD                                                AS MNTH
              ,COALESCE(SEARCHVOLUME, 0)                             AS MNTH_VOL
              ,COALESCE(LEAD(SEARCHVOLUME, 1) OVER(ORDER BY DATE DESC), 0) AS MNTH_VOL_MOM
          FROM KEYWORDPD.REL_NAVER_VOL
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_G_CPC AS
    (
        SELECT CPC AS CPC
          FROM KEYWORDPD.REL_GOOGLE_STAT
         WHERE KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_MAX AS 
    (
        SELECT (SELECT COALESCE(MAX(VOL         ), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL    ), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_MNTH_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL_MOM), 0) FROM WT_G_VOL WHERE SORT_KEY = 1) AS G_MNTH_VOL_MOM
              ,(SELECT COALESCE(MAX(VOL         ), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL    ), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_MNTH_VOL
              ,(SELECT COALESCE(MAX(MNTH_VOL_MOM), 0) FROM WT_N_VOL WHERE SORT_KEY = 1) AS N_MNTH_VOL_MOM
              ,(SELECT          MAX(CPC         )     FROM WT_G_CPC                   ) AS G_CPC
    ), WT_BASE AS
    (
        SELECT G_VOL + N_VOL AS T_VOL
              ,CASE 
                 WHEN (G_MNTH_VOL_MOM + N_MNTH_VOL_MOM) = 0
                 THEN NULL
                 ELSE ((G_MNTH_VOL + N_MNTH_VOL) - (G_MNTH_VOL_MOM + N_MNTH_VOL_MOM)) / (G_MNTH_VOL_MOM + N_MNTH_VOL_MOM) * 100
               END AS T_VOL_RATE
              ,G_VOL
              ,CASE 
                 WHEN G_MNTH_VOL_MOM = 0
                 THEN NULL
                 ELSE (G_MNTH_VOL - G_MNTH_VOL_MOM) / G_MNTH_VOL_MOM * 100
               END AS G_VOL_RATE
              ,N_VOL
              ,CASE 
                 WHEN N_MNTH_VOL_MOM = 0
                 THEN NULL
                 ELSE (N_MNTH_VOL - N_MNTH_VOL_MOM) / N_MNTH_VOL_MOM * 100
               END AS N_VOL_RATE
              ,G_CPC
          FROM WT_MAX
    )
    SELECT COALESCE(CAST(T_VOL      AS DECIMAL(20,0)), 0) AS T_VOL       /* Voume          - 전체 검색량   */
          ,COALESCE(CAST(T_VOL_RATE AS DECIMAL(20,2)), 0) AS T_VOL_RATE  /* Voume          - 증감률        */
          ,COALESCE(CAST(G_VOL      AS DECIMAL(20,0)), 0) AS G_VOL       /* Google Traffic - 구글 검색량   */
          ,COALESCE(CAST(G_VOL_RATE AS DECIMAL(20,2)), 0) AS G_VOL_RATE  /* Google Traffic - 증감률        */
          ,COALESCE(CAST(N_VOL      AS DECIMAL(20,0)), 0) AS N_VOL       /* Naver  Traffic - 네이버 검색량 */
          ,COALESCE(CAST(N_VOL_RATE AS DECIMAL(20,2)), 0) AS N_VOL_RATE  /* Naver  Traffic - 증감률        */
          ,COALESCE(CAST(G_CPC      AS DECIMAL(20,2)), 0) AS G_CPC       /* CPC            - 구글 CPC      */
      FROM WT_BASE


/* totalSearchVolumeChart.sql */
/* 2. Volume, Google Traffic, Naver Traffic, CPC -  Chart SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_VOL AS
    (
        SELECT ROW_NUMBER() OVER(ORDER BY DATE DESC)                 AS SORT_KEY
              ,DATE                                                  AS MNTH
              ,COALESCE(VOLUME, 0)                                   AS MNTH_VOL
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
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



3. 네이버 데이터 기준 성별 분포(남, 여), 연령별 분포, 정보성 상업성 비율
    * 공통사항
        ==> 테이블 : keywordpd.rel_naver_stat
            컬럼   : base_keyword - 기준 키워드
                     ※ 분포 비율은 avg로 처리
    * 네이버 데이터 기준 성별 분포(남, 여)
        ==> 컬럼   : male         - 분포 비율(남)
                     female       - 분포 비율(여)
                     ※ 기준키워드/기준일 별 male + female = 100%
    * 연령별 분포
        ==> 컬럼   : age_0_19     -  0~19세 비율
                     age_20_29    - 20~29세 비율
                     age_30_39    - 30~39세 비율
                     age_40_49    - 40~49세 비율
                     age_50_over  - 50세 이상 비율
                     ※ 기준키워드/기준일 별 age_0_19 + age_20_29 + age_30_39 + age_40_49 + age_50_over = 100%
    * 정보성 상업성 비율
        ==> 컬럼   : inform       - 정보성 비율
                     commercial   - 상업성 비율
                     ※ 기준키워드/기준일 별 inform + commercial = 100%


/* genderAgeInterestChart.sql */
/* 3. 네이버 데이터 기준 성별 분포(남, 여), 연령별 분포, 정보성 상업성 비율 - 성별, 연령, 정보/상업 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
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


4. Volume Time trend
    * 검색한 정보에 대한 Time trend (월별 검색량 기준 월별만 가능함)
        ==> 월별 구글+네이버 검색량을 입력한 키워드별로 Line 으로 표시
        ==> 기획파일에 있는 일별/주별/월별은 적용하지 않음.

/* volumeTimeTrend.sql */
/* 4. Volume Time trend - 시계열 그래프 SQL*/
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_VOL AS
    (
        SELECT KEYWORD             AS KWRD_NM                                                
              ,DATE                AS MNTH
              ,COALESCE(VOLUME, 0) AS MNTH_VOL
          FROM KEYWORDPD.REL_GOOGLE_VOL
         WHERE KEYWORD IN (SELECT KWRD_NM FROM WT_WHERE)
    ), WT_N_VOL AS
    (
        SELECT BASE_KEYWORD              AS KWRD_NM                                                
              ,PERIOD                    AS MNTH
              ,COALESCE(SEARCHVOLUME, 0) AS MNTH_VOL
          FROM KEYWORDPD.REL_NAVER_VOL
         WHERE BASE_KEYWORD IN (SELECT KWRD_NM FROM WT_WHERE )
    ), WT_JOIN AS
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
    SELECT KWRD_NM  AS L_LGND  /* 검색 키워드 */
          ,MNTH     AS X_DT    /* 검색량 월 */
          ,MNTH_VOL AS Y_VAL   /* 검색량    */
      FROM WT_BASE
  ORDER BY SORT_KEY


5. Google 연관 키워드 List
    * 구글 연관키워드 리스트(정보 : 키워드 명, 과거 1달전 검색량, CPC)
        ==> 테이블 : keywordpd.rel_google_stat
            컬럼   : keyword      - 기준 키워드
    * 키워드명, 과거 1달전 검색량
        ==> 컬럼   : keyword                   - 관련 키워드
                     ????                      - 검색량
		             rel_google_stat 테이블에 검색량 컬럼 추가 (Volumn) 하기로 함.
    * CPC
        ==> 컬럼   : CPC

/* googleSuggestedKeywords.sql */
/* 5. Google 연관 키워드 List - 표 SQL*/
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_G_REL AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.REL_GOOGLE A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_BASE AS
    (
        SELECT A.KEYWORD AS KWRD_NM
              ,B.VOLUME  AS G_VOL
              ,B.CPC     AS G_CPC
              ,ROW_NUMBER() OVER(ORDER BY B.VOLUME DESC NULLS LAST) AS G_RANK
          FROM WT_G_REL A LEFT OUTER JOIN KEYWORDPD.REL_GOOGLE_STAT B
            ON (A.KEYWORD = B.KEYWORD)
    )
    SELECT KWRD_NM                                           /* 키워드 명         */
          ,TO_CHAR(G_VOL, 'FM999,999,999,999,999') AS G_VOL  /* 과거 1달전 검색량 */
          ,G_CPC                                             /* CPC               */
      FROM WT_BASE
  ORDER BY G_RANK




6. Naver 연관 키워드 List
    * 네이버 연관키워드 리스트(정보 : 키워드 명, 과거 1달전 검색량, CPC)
    ==> 키워드 명, 과거 1달전 검색량, 경쟁률 (※ CPC 대신)
    ==> 테이블 : keywordpd.rel_naver_relkey

/* naverSuggestedKeywords.sql */
/* 6. Naver 연관 키워드 List - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '스킨, 로션' */
    ), WT_BASE AS
    (
        SELECT KEYWORD       AS KWRD_NM
              ,VOLUME        AS N_VOL
              ,ADCOMPETITION AS N_COMP
              ,ROW_NUMBER() OVER(ORDER BY VOLUME DESC NULLS LAST) AS N_RANK
          FROM KEYWORDPD.REL_NAVER_RELKEY A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    )
    SELECT KWRD_NM                                           /* 키워드 명         */
          ,TO_CHAR(N_VOL, 'FM999,999,999,999,999') AS N_VOL  /* 과거 1달전 검색량 */
          ,N_COMP                                            /* 경쟁률            */
      FROM WT_BASE
  ORDER BY N_RANK



7. Top 10 비교
    * 검색량 기준 top 10 비교시 겹치는 것은 중간에 나오게
        ==> 연관 키워드 관련 테이블
            구글   : keywordpd.rel_google_stat
            네이버 : keywordpd.rel_naver_relkey

/* top10NetworkComparisonChart.sql */
/* 7. Top 10 비교 - 네트워크 그래프 SQL */
WITH WT_WHERE AS
    (
        SELECT ROW_NUMBER() OVER () AS SORT_KEY
              ,TRIM(KWRD_NM)        AS KWRD_NM
          FROM REGEXP_SPLIT_TO_TABLE(:KWRD_NM, ',') AS KWRD_NM  /* 콤마(,)로 구분된 문자열을 ROW로 만든다. ex) '마스크' */
    ), WT_G_REL AS
    (
        SELECT DISTINCT
               KEYWORD
          FROM KEYWORDPD.REL_GOOGLE A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_G_RANK AS
    (
        SELECT A.KEYWORD                                                                            AS KWRD_NM
              ,ROW_NUMBER() OVER(ORDER BY B.VOLUME DESC NULLS LAST, A.KEYWORD COLLATE "ko_KR.utf8") AS G_RANK
              ,B.VOLUME                                                                             AS G_VOL
          FROM WT_G_REL A LEFT OUTER JOIN KEYWORDPD.REL_GOOGLE_STAT B
            ON (A.KEYWORD = B.KEYWORD)
    ), WT_N_RANK AS
    (
        SELECT KEYWORD                                                                          AS KWRD_NM
              ,ROW_NUMBER() OVER(ORDER BY VOLUME DESC NULLS LAST, KEYWORD COLLATE "ko_KR.utf8") AS N_RANK
              ,VOLUME                                                                           AS N_VOL
          FROM KEYWORDPD.REL_NAVER_RELKEY A
         WHERE BASE_KEYWORD = (SELECT KWRD_NM FROM WT_WHERE WHERE SORT_KEY = 1)
    ), WT_BASE AS 
    (
        SELECT 'GOOGLE' AS NODE_KEY
              ,KWRD_NM
              ,G_VOL    AS VOL
              ,G_RANK   AS RANK
          FROM WT_G_RANK
         WHERE G_RANK <= 10
     UNION ALL
        SELECT 'NAVER' AS NODE_KEY
              ,KWRD_NM
              ,N_VOL   AS VOL
              ,N_RANK  AS RANK
          FROM WT_N_RANK
         WHERE N_RANK <= 10
    )
    SELECT NODE_KEY /* GOOGLE, NAVER */
          ,KWRD_NM  /* 키워드 명     */
          ,VOL      /* 조회량        */
          ,RANK     /* 순위          */
      FROM WT_BASE
  ORDER BY NODE_KEY
          ,RANK
