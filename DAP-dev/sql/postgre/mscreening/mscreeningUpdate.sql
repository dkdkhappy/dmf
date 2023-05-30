
/* 1. DB 목록 및 업데이트 일자 - 표 SQL */
WITH WT_BASE AS
    (
        SELECT INDEX       AS SORT_KEY
              ,DBNAME      AS DB_NM
              ,LAST_UPDATE AS LAST_DT
              ,NO_OF_ROWS  AS DATA_CNT
              ,UPDATE_FREQ AS UPDT_TYPE
          FROM MAT_SCREENING.MAT_SCRENNING_BASEDB
    )
    SELECT SORT_KEY                                                /* 정렬순서           */
          ,DB_NM                                                   /* DB 명칭            */
          ,LAST_DT                                                 /* 마지막 업데이트    */
          ,TO_CHAR(DATA_CNT, 'FM999,999,999,999,990') AS DATA_CNT  /* DATA 보유량        */
          ,UPDT_TYPE                                               /* 수시 업데이트 여부 */
      FROM WT_BASE
  ORDER BY SORT_KEY