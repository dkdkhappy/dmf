/* 1. DB 검색기 - 표 SQL */
WITH WT_WHERE AS
    (
        SELECT '%'||UPPER(TRIM({KEY_WORD}))||'%' AS KEY_WORD 
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
              ,"중국 준용 방부제"                        AS CH_PRESER /* 중국준용 방부제 */
              ,"중국 준용 자외선차단제"                        AS CH_SUNSCREEN /* 중국준용 자외선차단제 */
              ,"CI_Check"                                 AS CH_CI /* 중국준용 색조 */
              ,"Global_CITES_경고"                                 AS G_CITES /* G_CITEW */
              ,"CN_CITES_경고"                                 AS CH_CITES /* 중국준용 색조 */              
              ,"EWG"                                     AS EWG_DATE  /* EWG              */
              ,"화해"                                    AS HWA_DATA  /* 화해             */
              ,"메이리슈싱"                              AS MEI_DATA  /* 메이리슈싱       */
              ,"CIR_Link"                              AS CIR_DATA  /* CIR Link       */
              
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
          ,CH_PRESER
          ,CH_SUNSCREEN
          ,CH_PRESER
          ,CH_CI
          ,G_CITES
          ,CH_CITES
          ,EWG_DATE  /* EWG              */
          ,HWA_DATA  /* 화해             */
          ,MEI_DATA  /* 메이리슈싱       */
          ,CIR_DATA  /* CIR DATA       */
      FROM WT_BASE
  ORDER BY KCIA_CD