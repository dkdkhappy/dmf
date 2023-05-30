/* 0. 리뷰분석 화면에서 기본 셋팅에 필요한 일자들...        */
/*    기준일자는 어제임 오늘이 2023.03.04 일 경우 => 22023.03.03 */
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
  FROM REVIEW.REVIEW_INITIAL_DATE
