/* Index Create or Drop SQL 생성 */
WITH WT_IDX AS
    (
        /* Schema : dash_raw */
        /* statistics_date */
        SELECT SCHEMANAME                                                         AS SCHEMA_NM
              ,                               TABLENAME || '_statistics_date_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (statistics_date)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash_raw'
           AND (TABLENAME LIKE 'over_%_overall_store'
            OR  TABLENAME LIKE 'over_%_overall_product'
            OR  TABLENAME LIKE 'over_%_overall_product_url'
            OR  TABLENAME LIKE 'over_%_shop_by_hour')
     UNION ALL
        /* product_id */
        SELECT SCHEMANAME                                                    AS SCHEMA_NM
              ,                               TABLENAME || '_product_id_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (product_id)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash_raw'
           AND (TABLENAME LIKE 'over_%_overall_product'
            OR  TABLENAME LIKE 'over_%_overall_product_url')
     UNION ALL
        /* author_id */
        SELECT SCHEMANAME                                                    AS SCHEMA_NM
              ,                               TABLENAME || '_author_id_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (author_id)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash_raw'
           AND TABLENAME = 'over_douyin_live_name'
     UNION ALL
        /* date */
        SELECT SCHEMANAME                                                    AS SCHEMA_NM
              ,                               TABLENAME || '_date_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (date)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash_raw'
           AND TABLENAME = 'over_macro_ex_krw_cny'
     UNION ALL    
        /* Schema : review_raw */
        /* fake abnormal */
        SELECT SCHEMANAME                                                                     AS SCHEMA_NM
              ,                               TABLENAME || '_fake_idx'                        AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' ("date",prod_id,review_id,fake)' AS IDX_SQL   
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'review_raw'
           AND TABLENAME LIKE 'over_%_review_abnormal'
     UNION ALL    
        /* fake review_sentence */
        SELECT SCHEMANAME                                                                AS SCHEMA_NM
              ,                               TABLENAME || '_fake_idx'                   AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' ("date",prod_id,review_id)' AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'review_raw'
           AND TABLENAME LIKE 'over_%_review_sentence_table'
     UNION ALL    
        /* fake topic_sentence */
        SELECT SCHEMANAME                                                                AS SCHEMA_NM
              ,                               TABLENAME || '_fake_idx'                   AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' ("date",prod_id,review_id)' AS IDX_SQL   
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'review_raw'
           AND TABLENAME LIKE 'over_%_topic_sentence_table'
     UNION ALL    
        /* prod_id sentence_table */
        SELECT SCHEMANAME                                                 AS SCHEMA_NM
              ,                               TABLENAME || '_prod_id_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (prod_id)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'review_raw'
           AND TABLENAME LIKE 'over_%_review_sentence_table'
           AND TABLENAME LIKE 'over_%_topic_sentence_table'
     UNION ALL    
        /* date base_table */
        SELECT SCHEMANAME                                                 AS SCHEMA_NM
              ,                               TABLENAME || '_date_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (date)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'review_raw'
           AND TABLENAME LIKE 'over_%_base_table'
     UNION ALL    
        /* Schema : keywordpd */
        /* keyword */
        SELECT SCHEMANAME                                                 AS SCHEMA_NM
              ,                               TABLENAME || '_keyword_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (keyword)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'keywordpd'
           AND TABLENAME IN ('rel_google_stat', 'rel_google_vol')
     UNION ALL    
        /* base_keyword */
        SELECT SCHEMANAME                                                      AS SCHEMA_NM
              ,                               TABLENAME || '_base_keyword_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (base_keyword)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'keywordpd'
           AND TABLENAME IN ('rel_google', 'rel_naver_stat', 'rel_naver_vol', 'rel_naver_relkey')
     UNION ALL
        /* base_time */
        SELECT SCHEMANAME                                                   AS SCHEMA_NM
              ,                               TABLENAME || '_base_time_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (base_time)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash'
           AND TABLENAME IN ('tmall_store_rank_data', 'tmall_item_rank_data')
     UNION ALL
        /* prod_id */
        SELECT SCHEMANAME                                                   AS SCHEMA_NM
              ,                               TABLENAME || '_prod_id_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (prod_id)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash'
           AND TABLENAME IN ('tmall_item_rank_data')
     UNION ALL
        /* date */
        SELECT SCHEMANAME                                              AS SCHEMA_NM
              ,                               TABLENAME || '_date_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (date)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash'
           AND TABLENAME IN ('dgt_comp_compete')
     UNION ALL
        /* own_prod_name */
        SELECT SCHEMANAME                                                       AS SCHEMA_NM
              ,                               TABLENAME || '_own_prod_name_idx' AS IDX_NM
              ,' ON ' || SCHEMANAME || '.' || TABLENAME || ' (own_prod_name)'   AS IDX_SQL
          FROM pg_catalog.pg_tables
         WHERE SCHEMANAME = 'dash'
           AND TABLENAME IN ('dgt_comp_compete')
    )
    SELECT 'DROP   INDEX IF     EXISTS ' || SCHEMA_NM || '.' || IDX_NM            || ' ;' AS DOP_SQL 
          ,'CREATE INDEX IF NOT EXISTS ' ||                     IDX_NM || IDX_SQL || ' ;' AS CREATE_SQL
      FROM WT_IDX
     WHERE IDX_NM LIKE 'over_%' OR IDX_NM LIKE '%keyword_idx' OR IDX_NM LIKE '%base_time_idx' OR IDX_NM LIKE 'dgt_comp%'
;


/* Index 확인 SQL */
        SELECT * 
          FROM pg_catalog.pg_indexes 
         WHERE SCHEMANAME = 'dash_raw'
           AND INDEXNAME  LIKE '%_idx' 
           AND (TABLENAME LIKE 'over_%_overall_store'
            OR  TABLENAME LIKE 'over_%_overall_product'
            OR  TABLENAME LIKE 'over_%_overall_product_url'
            OR  TABLENAME LIKE 'over_%_shop_by_hour'
            OR  TABLENAME LIKE 'over_douyin_live_name'
            OR  TABLENAME LIKE 'over_macro_ex_krw_cny')
     UNION ALL
        SELECT * 
          FROM pg_catalog.pg_indexes 
         WHERE SCHEMANAME = 'review_raw'
           AND INDEXNAME  LIKE '%_idx' 
           AND (TABLENAME LIKE 'over_%_review_abnormal'
            OR  TABLENAME LIKE 'over_%_review_sentence_table'
            OR  TABLENAME LIKE 'over_%_topic_sentence_table'
            OR  TABLENAME LIKE 'over_%_base_table') 
     UNION ALL
        SELECT * 
          FROM pg_catalog.pg_indexes 
         WHERE SCHEMANAME = 'keywordpd'
           AND INDEXNAME  LIKE '%_idx' 
           AND TABLENAME    IN ('rel_google_stat', 'rel_google_vol', 'rel_google', 'rel_naver_stat', 'rel_naver_vol', 'rel_naver_relkey')
     UNION ALL
        SELECT * 
          FROM pg_catalog.pg_indexes 
         WHERE SCHEMANAME = 'dash'
           AND INDEXNAME  LIKE '%_idx' 
           AND TABLENAME    IN ('tmall_store_rank_data', 'tmall_item_rank_data')
     UNION ALL
        SELECT * 
          FROM pg_catalog.pg_indexes 
         WHERE SCHEMANAME = 'dash'
           AND INDEXNAME  LIKE '%_idx' 
           AND TABLENAME    IN ('dgt_comp_compete')
;


/* Locked SQL Kill SQL */
    SELECT B.RELNAME
          ,A.LOCKTYPE
          ,PAGE
          ,VIRTUALTRANSACTION
          ,PID
          ,MODE
          ,GRANTED
          --,PG_TERMINATE_BACKEND(PID)
      FROM PG_LOCKS A,
           PG_STAT_ALL_TABLES B
     WHERE A.RELATION = B.RELID
       AND B.RELNAME NOT LIKE 'pg%'
  ORDER BY RELATION
;


