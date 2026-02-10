
/* Project: Student Engagement Analysis
    Author: Mokshagna Vuppala
    Description: 
    This query calculates the conversion rates and average time-to-value metrics.
    I used a Common Table Expression (CTE) 'student_journey' to first aggregate 
    the raw data, creating a clean intermediate table before calculating the final KPIs.
*/

WITH student_journey AS (
    -- CTE: Aggregate first-time events for each student
    SELECT 
        si.student_id,
        si.date_registered,
        MIN(se.date_watched) AS first_date_watched,
        MIN(sp.date_purchased) AS first_date_purchased,
        DATEDIFF(MIN(se.date_watched), si.date_registered) AS days_to_start_watching,
        DATEDIFF(MIN(sp.date_purchased), MIN(se.date_watched)) AS days_to_purchase
    FROM
        student_info si
    JOIN 
        student_engagement se ON si.student_id = se.student_id
    -- LEFT JOIN is critical here to keep students who never purchased
    LEFT JOIN 
        student_purchases sp ON si.student_id = sp.student_id
    GROUP BY 
        si.student_id
    HAVING 
        -- Ensure we only keep valid logical sequences (watch before purchase)
        first_date_purchased IS NULL 
        OR first_date_watched <= first_date_purchased
)

-- Final KPI Calculation
SELECT 
    -- 1. Conversion Rate: (Purchasers / Total Watchers) * 100
    ROUND(COUNT(first_date_purchased) / COUNT(student_id) * 100, 2) AS conversion_rate,
    
    -- 2. Avg Days: Registration -> First Watch
    ROUND(AVG(days_to_start_watching), 2) AS avg_days_to_start,
    
    -- 3. Avg Days: First Watch -> Purchase (for those who bought)
    ROUND(AVG(days_to_purchase), 2) AS avg_days_to_purchase
FROM
    student_journey;
