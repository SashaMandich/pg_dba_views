create or replace view public.vw_index_usage 
as
select 
  pt.tablename,
  t.indexname,
  to_char(pc.reltuples, '999,999,999,999'::text) as totalrows,
  pg_size_pretty(pg_relation_size(quote_ident(pt.tablename::text)::regclass)) as tablesize,
  pg_size_pretty(pg_relation_size(quote_ident(t.indexrelname::text)::regclass)) as indexsize,
  to_char(t.idx_scan, '999,999,999,999'::text) as totalnumberofscan,
  to_char(t.idx_tup_read, '999,999,999,999'::text) as totaltupleread,
  to_char(t.idx_tup_fetch, '999,999,999,999'::text) as totaltuplefetched
from 
  pg_tables pt
  left join pg_class pc on pt.tablename = pc.relname
  left join
    (select pc_1.relname as tablename,
            pc2.relname as indexname,
            psai.idx_scan,
            psai.idx_tup_read,
            psai.idx_tup_fetch,
            psai.indexrelname
     from pg_index pi
     join pg_class pc_1 on pc_1.oid = pi.indrelid
     join pg_class pc2 on pc2.oid = pi.indexrelid
     join pg_stat_all_indexes psai on pi.indexrelid = psai.indexrelid) t on pt.tablename = t.tablename
where 
  pt.schemaname = 'public'::name
order by 
    pt.tablename;
