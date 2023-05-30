/* 0. 채널수익 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 테이블 DATE 컬럼 MAX 값임 */
/*    'Tmall Global' 는 변수 처리 필요     */
SELECT              MAX(DATE)                                                AS BASE_MNTH  /* 기준월 */
      ,TO_CHAR(CAST(MAX(DATE)||'-01' AS DATE)- INTERVAL '1' YEAR, 'YYYY-MM') AS FR_MNTH    /* 시작월 */
      ,             MAX(DATE)                                                AS TO_MNTH    /* 종료월 */
  FROM DASH.CM_ANALYSIS
 WHERE CHANNEL = TRIM({CHNL_NM}) /* 'Tmall Global' */
   AND DATE   != 'ytd'