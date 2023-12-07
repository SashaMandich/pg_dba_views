select
	activity.pid,
	activity.usename,
	activity.query,
	blocking.pid as blocking_id,
	blocking.query as blocking_query
from
	pg_stat_activity as activity
join pg_stat_activity as blocking on
	blocking.pid = any(pg_blocking_pids(activity.pid));
