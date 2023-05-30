SELECT BASE_DT               /* 기준일자               */
      ,BASE_DT_YOY           /* 기준일자          -1년 */
      ,FRST_DT_MNTH          /* 기준월의 1일           */
      ,FRST_DT_MNTH_YOY      /* 기준월의 1일      -1년 */
      ,FRST_DT_YEAR          /* 기준년의 1월 1일       */
      ,FRST_DT_YEAR_YOY      /* 기준년의 1월 1일  -1년 */
      ,FR_DT                 /* 기간조회 - 시작일자    */
      ,TO_DT                 /* 기간조회 - 종료일자    */
      ,BASE_YEAR             /* 기준년                 */
      ,BASE_YEAR_YOY         /* 기준년            -1년 */
      ,BASE_MNTH             /* 기준월                 */
      ,BASE_MNTH_YOY         /* 기준월            -1년 */
      ,TO_CHAR(TO_DATE(BASE_DT, 'YYYY-MM-DD') - INTERVAL '1 day', 'YYYY-MM-DD' )AS BASE_DT_DOD 
      , (SELECT MAX(DATE)
                FROM DASH.CM_ANALYSIS
                WHERE CHANNEL = TRIM('Tmall Global')
                AND DATE != 'ytd') AS CHANNEL_BASE_MNTH
  FROM DASH.DASH_INITIAL_DATE
