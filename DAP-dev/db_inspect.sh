#!/bin/bash
PGPASSWORD=$PGPASSWORD

table_list=$(psql -h dap-database.cuwldr2bamdp.ap-northeast-2.rds.amazonaws.com -p 5432 -d postgres -U postgres -c "select tablename from pg_tables where schemaname='dash'" | awk 'NR>2' | sed 's/(.*)//')
python manage.py inspectdb $table_list --database=dash > dashboards/models.py