create database mydb;

use mydb;

-- Create the 'usage' table
CREATE TABLE u_usage (
    user_id VARCHAR(3),
    usage_date DATE,
    usage_location VARCHAR(10),
    time_spent INT
);

-- Insert data into the 'usage' table
INSERT INTO u_usage (user_id, usage_date, usage_location, time_spent)
VALUES
    ('aaa', '2019-01-03', 'US', 38),
    ('aaa', '2019-02-01', 'US', 12),
    ('aaa', '2019-03-04', 'US', 30),
    ('bbb', '2019-01-03', 'US', 20),
    ('bbb', '2019-02-04', 'Canada', 31),
    ('ccc', '2019-01-16', 'US', 40),
    ('ddd', '2019-02-08', 'US', 45);

select * from u_usage;

-- Create the 'registration_data' table
CREATE TABLE registration_data (
    user_id VARCHAR(3),
    registration_date DATE
);

-- Insert data into the 'registration_data' table
INSERT INTO registration_data (user_id, registration_date)
VALUES
    ('aaa', '2019-01-03'),
    ('bbb', '2019-01-02'),
    ('ccc', '2019-01-15'),
    ('ddd', '2019-02-07');
    
select * from registration_data;

WITH MonthlyUsage AS (
    SELECT
        u.user_id,
        r.registration_date AS reg_date,
        u.usage_date,
        TIMESTAMPDIFF(MONTH, r.registration_date, u.usage_date) AS month_diff,
        u.time_spent
    FROM
        u_usage u
    JOIN
        registration_data r ON u.user_id = r.user_id
)
, RetentionMetrics AS (
    SELECT
        DATE_FORMAT(reg_date, '%b, %Y') AS registration_month,
        COUNT(DISTINCT user_id) AS total_users,
        COUNT(DISTINCT CASE WHEN month_diff = 0 THEN user_id END) AS m1_retention,
        COUNT(DISTINCT CASE WHEN month_diff = 1 THEN user_id END) AS m2_retention,
        COUNT(DISTINCT CASE WHEN month_diff = 2 THEN user_id END) AS m3_retention
    FROM
        MonthlyUsage
    WHERE
        month_diff <= 2 AND time_spent >= 30
    GROUP BY
        registration_month
)
SELECT
    registration_month,
    total_users,
    CONCAT(ROUND((m1_retention / total_users) * 100, 2), '%') AS m1_retention,
    CONCAT(ROUND((m2_retention / total_users) * 100, 2), '%') AS m2_retention,
    CONCAT(ROUND((m3_retention / total_users) * 100, 2), '%') AS m3_retention
FROM
    RetentionMetrics
ORDER BY
    registration_month;