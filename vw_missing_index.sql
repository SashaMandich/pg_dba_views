create or replace view public.vw_missing_index 
as
select 
	pg_stat_all_tables.relname as tablename,
	to_char(pg_stat_all_tables.seq_scan, '999,999,999,999'::text) as totalseqscan,
	to_char(pg_stat_all_tables.idx_scan, '999,999,999,999'::text) as totalindexscan,
	to_char(pg_stat_all_tables.n_live_tup, '999,999,999,999'::text) as tablerows,
	pg_size_pretty(pg_relation_size(pg_stat_all_tables.relname::regclass)) as tablesize
from 
	pg_stat_all_tables
where 
	pg_stat_all_tables.schemaname = 'public'::name
  and (50 * pg_stat_all_tables.seq_scan) > pg_stat_all_tables.idx_scan
	and pg_stat_all_tables.n_live_tup > 10000
  and pg_relation_size(pg_stat_all_tables.relname::regclass) > 5000000
order by 
	pg_stat_all_tables.relname;
