SELECT 
    job_title_short AS title,
    job_location AS location,
    --job_posted_date::date AS date (convert job_posted_date type from TIMESTAMP to DATE)
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time, --five hours prior (-5)
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM
    job_postings_fact
LIMIT 5;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY 
    month
ORDER BY job_posted_count DESC;

/* SELECT
    job_schedule_type,
    job_posted_date::date AS date,
    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    EXTRACT(YEAR FROM job_posted_date) AS date_year,
    EXTRACT(DAY FROM job_posted_date) AS date_day,
    AVG(salary_year_avg),
    AVG(salary_hour_avg)
FROM 
    job_postings_fact
WHERE 
    date_day > '01' AND date_month > '06' AND date_year > '2023'
GROUP BY 
    job_schedule_type;
/* HAVING
    job_posted_date > '2023-06-01' */

/* ORDER BY
    job_posted_date;*/
*/

SELECT 
    job_posted_date::date AS date
FROM job_postings_fact;



SELECT
    job_schedule_type,
    AVG(salary_year_avg) AS avg_yearly_salary,
    AVG(salary_hour_avg) AS avg_hourly_salary
FROM 
    job_postings_fact
WHERE 
    job_posted_date > '2023-06-01'
GROUP BY 
    job_schedule_type;



SELECT
    --job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York' AS date_time, --shows all date occurences / decided to go with max tho
    MAX(job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS first_post, /* shows first occurence date which serves us
     in this case as we want the table to only have 12 rows corresponding to each month */

    EXTRACT(MONTH FROM job_posted_date) AS date_month,
    COUNT(*) AS jobs_posted
FROM 
    job_postings_fact
WHERE 
    EXTRACT(YEAR FROM job_posted_date) = 2023
GROUP BY 
    date_month 
ORDER BY 
    date_month;

SELECT
	job_postings.job_id,
    job_postings.job_title_short,
    job_postings.company_id,
    job_postings.job_posted_date,
    job_postings.job_health_insurance,
    companies.name
FROM
	job_postings_fact AS job_postings 
LEFT JOIN company_dim AS companies
	ON job_postings.company_id = companies.company_id
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023
    AND EXTRACT(QUARTER FROM job_posted_date) = 2
    AND job_health_insurance = '1'
ORDER BY
    job_postings.job_posted_date;

    
