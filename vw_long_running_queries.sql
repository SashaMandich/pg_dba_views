select
	pid,
	user,
	pg_stat_activity.query_start,
	now() - pg_stat_activity.query_start as query_time,
	query,
	state,
	wait_event_type,
	wait_event
from
	pg_stat_activity
where
	(now() - pg_stat_activity.query_start) > interval '5 minutes';
