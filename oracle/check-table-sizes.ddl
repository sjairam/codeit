SELECT
    t.table_name,
    t.num_rows,
    ROUND(NVL(ts.data_size,0) / 1024 / 1024, 2) AS data_mb,
    ROUND(NVL(ts.index_size,0) / 1024 / 1024, 2) AS index_mb,
    ROUND((NVL(ts.data_size,0) + NVL(ts.index_size,0)) / 1024 / 1024, 2) AS total_mb
FROM
    user_tables t
LEFT JOIN (
    SELECT
        segment_name,
        SUM(CASE WHEN segment_type = 'TABLE' THEN bytes ELSE 0 END) AS data_size,
        SUM(CASE WHEN segment_type = 'INDEX' THEN bytes ELSE 0 END) AS index_size
    FROM
        user_segments
    GROUP BY
        segment_name
) ts
ON t.table_name = ts.segment_name
ORDER BY total_mb DESC;
