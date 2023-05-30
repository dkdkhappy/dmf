● 위생허가 스크리닝 - 2. DB 검색기


1. DB 검색기
/* 1. DB 검색기 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT '%'||UPPER(TRIM(:KEY_WORD))||'%' AS KEY_WORD 
    ), WT_BASE AS
    (
        SELECT "성분코드"                                AS KCIA_CD   /* 성분코드         */
              ,"성분명"                                  AS KR_NM     /* 국문 성분명      */
              ,"영문명"                                  AS EN_NM     /* 영문 성분명      */
              ,"중문명칭"                                AS CN_NM     /* 중문 성분명      */
              ,"CAS No"                                  AS CAS_NO    /* CAS No.          */
              ,"구명칭"                                  AS OLD_NM    /* 구 성분명        */
              ,"중국사용가능물질"                        AS USE_CN    /* 중국사용가능물질 */
              ,"씻어내는 제품 중 최고 역사 사용량"       AS WASH_OFF  /* 씻어내는 제품 중 최고 역사 사용량      */
              ,"씻어내지 않는 제품 중 최고 역사 사용량"  AS LEAV_ON   /* 씻어내지 않는 제품 중 최고 역사 사용량 */
              ,"사용제한물질"                            AS LIMT_MAT  /* 사용제한물질     */
              ,"EWG"                                     AS EWG_DATE  /* EWG              */
              ,"화해"                                    AS HWA_DATA  /* 화해             */
              ,"메이리슈싱"                              AS MEI_DATA  /* 메이리슈싱       */
          FROM MAT_SCREENING.MAT_SCRENNING_SEARCHDB
         WHERE UPPER("성분명")   LIKE (SELECT KEY_WORD FROM WT_WHERE)
            OR UPPER("영문명")   LIKE (SELECT KEY_WORD FROM WT_WHERE)
            OR UPPER("중문명칭") LIKE (SELECT KEY_WORD FROM WT_WHERE)
         LIMIT 100
    )
    SELECT KCIA_CD   /* 성분코드         */
          ,KR_NM     /* 국문 성분명      */
          ,EN_NM     /* 영문 성분명      */
          ,CN_NM     /* 중문 성분명      */
          ,CAS_NO    /* CAS No.          */
          ,OLD_NM    /* 구 성분명        */
          ,USE_CN    /* 중국사용가능물질 */
          ,WASH_OFF  /* 씻어내는 제품 중 최고 역사 사용량      */
          ,LEAV_ON   /* 씻어내지 않는 제품 중 최고 역사 사용량 */
          ,LIMT_MAT  /* 사용제한물질     */
          ,EWG_DATE  /* EWG              */
          ,HWA_DATA  /* 화해             */
          ,MEI_DATA  /* 메이리슈싱       */
      FROM WT_BASE
  ORDER BY KCIA_CD