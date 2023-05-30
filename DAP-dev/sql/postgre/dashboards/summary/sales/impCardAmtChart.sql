/* 1. 중요정보 카드 - Chart SQL */
WITH WT_BASE AS
    (
        SELECT CHRT_KEY                                           /* 그래프 키 (DAY, MNTH, YEAR) */
              ,X_DT                                               /* 일자                      */
              ,Y_VAL_SALE_RMB - Y_VAL_REFD_RMB AS Y_VAL_SALE_RMB  /* 매출 - 위안화 (환불제외)  */
              ,Y_VAL_REFD_RMB                                     /* 환불 - 위안화             */
              ,Y_VAL_SALE_KRW - Y_VAL_REFD_KRW AS Y_VAL_SALE_KRW  /* 매출 - 원화 (환불제외)    */
              ,Y_VAL_REFD_KRW                                     /* 환불 - 원화               */
          FROM DASH.SUM_IMPCARDAMTCHART
    )
    SELECT CHRT_KEY                                                 /* 그래프 키 (DAY, MNTH, YEAR) */
          ,TO_CHAR(X_DT, 'YYYY-MM-DD')           AS X_DT
          ,CAST(Y_VAL_SALE_RMB AS DECIMAL(20,0)) AS Y_VAL_SALE_RMB  /* 매출 - 위안화 */
          ,CAST(Y_VAL_REFD_RMB AS DECIMAL(20,0)) AS Y_VAL_REFD_RMB  /* 환불 - 위안화 */
          ,CAST(Y_VAL_SALE_KRW AS DECIMAL(20,0)) AS Y_VAL_SALE_KRW  /* 매출 - 원화   */
          ,CAST(Y_VAL_REFD_KRW AS DECIMAL(20,0)) AS Y_VAL_REFD_KRW  /* 환불 - 원화   */
      FROM WT_BASE