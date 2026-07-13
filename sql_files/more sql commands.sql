--January
CREATE TABLE january_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

--February
CREATE TABLE february_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

--March
CREATE TABLE march_jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;


--CASE

SELECT
    COUNT(job_id) AS number_of_jobs,
    --job_title_short,
    --job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'On-site'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;



SELECT
    job_id,
    job_title_short,
    CASE
        WHEN salary_year_avg > 100000 THEN 'High'
        WHEN salary_year_avg BETWEEN 70000 AND 100000 THEN 'Standard'
        ELSE 'Low'
    END AS salary_range 
    
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'



SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN salary_year_avg > 100000 THEN 'High'
        WHEN salary_year_avg BETWEEN 70000 AND 100000 THEN 'Standard'
        ELSE 'Low'
    END AS salary_range 
    
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    salary_range


--sub_queries temporary result set

SELECT *
FROM(
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs;


--CTE (Commun Table Expression) temporary result set

WITH january_jobs AS(
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)

SELECT * 
FROM january_jobs;

SELECT 
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
    ORDER BY company_id
)



WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
    ORDER BY 
        company_id
)
SELECT company_dim.name AS company_name,
        company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY total_jobs DESC




SELECT 
    top_skills.skill_id,
    skills_dim.skills,
    top_skills.job_count
FROM(
    SELECT
        skill_id,
        COUNT(job_id) AS job_count
    FROM
        skills_job_dim
    GROUP BY
        skill_id
    ORDER BY
        skill_id
    LIMIT 5
) AS top_skills

LEFT JOIN skills_dim 
ON top_skills.skill_id = skills_dim.skill_id;



SELECT
    number_job_company.company_id,
    number_job_company.number_of_jobs,
    
    CASE
        WHEN number_job_company.number_of_jobs > 50 THEN 'Large'
        WHEN number_job_company.number_of_jobs BETWEEN 10 AND 50 THEN 'Medium'
        ELSE 'Small'
    END
FROM(SELECT
    COUNT(job_id) AS number_of_jobs,
    company_id
from job_postings_fact
GROUP BY company_id
ORDER BY company_id) AS number_job_company




WITH remote_jobs_skills AS(
    SELECT 
        --skills_to_job.job_id,
        skill_id,
        --job_postings.job_work_from_home
        COUNT(*) AS skill_count
    FROM
        skills_job_dim AS skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = skills_to_job.job_id
    WHERE
        job_postings.job_work_from_home = true AND job_postings.job_title_short = 'Data Analyst'
    GROUP BY 
        skill_id
)

SELECT
    skills.skill_id,
    skills AS skill_name,
    skill_count
FROM remote_jobs_skills
INNER JOIN skills_dim AS skills ON skills.skill_id = remote_jobs_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT (5);

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    january_jobs

UNION ALL

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    february_jobs

UNION ALL -- we use the key word 'ALL' to get even the duplicated rows

SELECT
    job_title_short,
    company_id,
    job_location
FROM 
    march_jobs


--Practice Problem 8


SELECT 
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_location,
    quarter1_job_postings.job_via,
    quarter1_job_postings.job_posted_date::date,
    quarter1_job_postings.salary_year_avg
    
FROM(
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT * 
    FROM march_jobs
) AS quarter1_job_postings
WHERE
    quarter1_job_postings.salary_year_avg > 70000 AND quarter1_job_postings.job_title_short = 'Data Analyst'
ORDER BY
    quarter1_job_postings.salary_year_avg DESC



SELECT 
    quarter1_job_postings.job_id,
    quarter1_job_postings.job_title_short,
    quarter1_job_postings.job_posted_date::date,
    skills_job_dim.skill_id,
    skills_dim.skills AS skill_name,
    skills_dim.type AS skill_type
FROM(
    SELECT * 
    FROM january_jobs
    UNION ALL
    SELECT * 
    FROM february_jobs
    UNION ALL
    SELECT * 
    FROM march_jobs
) AS quarter1_job_postings
LEFT JOIN skills_job_dim
    ON quarter1_job_postings.job_id = skills_job_dim.job_id
LEFT JOIN skills_dim
    ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    salary_year_avg > 70000;




