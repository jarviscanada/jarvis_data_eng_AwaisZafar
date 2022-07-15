select cpu_number,id,total_mem
from host_info
order by total_mem desc;

CREATE FUNCTION round5(ts timestamp) RETURNS timestamp AS
$$
BEGIN
    RETURN date_trunc('hour', ts) + date_part('minute', ts):: int / 5 * interval '5 min';
END;
$$
    LANGUAGE PLPGSQL;

Select host_id,host_info.hostname,round5(host_usage.timestamp),AVG((host_info.total_mem)-(memory_free)) as avg_used_mem_percentage
from host_usage, host_info
group by host_id,host_info.hostname,host_usage.timestamp;







