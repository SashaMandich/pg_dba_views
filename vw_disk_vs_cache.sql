-- public.vw_disk_vs_cache source

create or replace view public.vw_disk_vs_cache as 
with all_tables as
  (select a_1.table_name,
          a_1.from_disk,
          a_1.from_cache
   from
     (select 'all'::text as table_name,
             sum(COALESCE(pg_statio_user_tables.heap_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.idx_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.toast_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.tidx_blks_read, 0::bigint)) as from_disk,
             sum(COALESCE(pg_statio_user_tables.heap_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.idx_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.toast_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.tidx_blks_hit, 0::bigint)) as from_cache
      from pg_statio_user_tables) a_1
   where (a_1.from_disk + a_1.from_cache) > 0::numeric ),
tables as
  (select a_1.table_name,
          a_1.from_disk,
          a_1.from_cache
   from
     (select pg_statio_user_tables.relname as table_name,
             COALESCE(pg_statio_user_tables.heap_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.idx_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.toast_blks_read, 0::bigint) + COALESCE(pg_statio_user_tables.tidx_blks_read, 0::bigint) as from_disk,
             COALESCE(pg_statio_user_tables.heap_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.idx_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.toast_blks_hit, 0::bigint) + COALESCE(pg_statio_user_tables.tidx_blks_hit, 0::bigint) as from_cache
      from pg_statio_user_tables) a_1
   where (a_1.from_disk + a_1.from_cache) > 0 )
select a.table_name as "table name",
       a.from_disk as "disk hits",
       round(a.from_disk / (a.from_disk + a.from_cache) * 100.0, 2) as "% disk hits",
       round(a.from_cache / (a.from_disk + a.from_cache) * 100.0, 2) as "% cache hits",
       a.from_disk + a.from_cache as "total hits"
from
  (select all_tables.table_name,
          all_tables.from_disk,
          all_tables.from_cache
   from all_tables
   union all select tables.table_name,
                    tables.from_disk,
                    tables.from_cache
   from tables) a
order by (case
              when a.table_name = 'all'::text then 0
              else 1
          end), a.from_disk desc;
