
create EXTENSION pg_stat_statements;

create view as vw_highest_run_queries
as
select 
  query,
  calls,
  total_exec_time,
  rows,
  100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) as hit_percent
from 
  pg_stat_statements
order by 
  total_exec_time desc
limit 5;

/*
Additionally you will have to edit the following line in postgresql.conf

shared_preload_libraries = ''
To

shared_preload_libraries = 'pg_stat_statements'
A restart of the PSQL service is required.
*/
