# SECTION: Dataset Overview & Metadata
SELECT *
FROM clean_smartwatch_data;

# SECTION: Sanity Checks on Cleaned Data
SELECT *
FROM clean_smartwatch_data
WHERE heart_rate > 200
   OR step_count <= 0
   OR sleep_duration < 0
   OR blood_oxygen > 100;
/* 
The main outliers in this dataset are heart_rate entries >200 bpm...
per Google and additional sources: 200 is typically the highest heart rate before risks of death
*/

SELECT COUNT(*)
FROM clean_smartwatch_data
WHERE heart_rate > 200;
-- There are 44 records with a heart_rate of >200

# SECTION: User-Level Summary Statistics
SELECT user_id,
       ROUND(AVG(sleep_duration),2) AS avg_sleep,
       ROUND(AVG(stress_level),2) AS avg_stress,
       ROUND(AVG(heart_rate),2) AS avg_hr,
       ROUND(SUM(step_count),2) AS total_steps
FROM clean_smartwatch_data
GROUP BY user_id;

# Risk Profiling & Early Indicators
SELECT *
	FROM (
	SELECT 
		user_id,
		ROUND(AVG(heart_rate),2) AS avg_heart_rate,
		ROUND(AVG(sleep_duration),2) AS avg_sleep,
		ROUND(AVG(step_count),2) AS avg_steps,
        activity_level,
		CASE 
			WHEN AVG(heart_rate) > 100 AND AVG(sleep_duration) < 5 THEN 'Potential Cardiovascular Risk'
			WHEN AVG(heart_rate) > 100 AND AVG(step_count) < 3000 THEN 'High HR with Low Activity'
			ELSE 'Normal'
		END AS risk_flag
	FROM clean_smartwatch_data
	GROUP BY user_id, activity_level
	ORDER BY avg_heart_rate DESC
) risk_levels
WHERE risk_flag != 'Normal'
AND activity_level = 'Sedentary'
ORDER BY 6 DESC;
-- Those that fall into this bin should likely see a doctor regarding their heart health

# SECTION: Grouped Trend Analyses
SELECT 
    CASE 
        WHEN sleep_duration < 4 THEN '<4hr'
        WHEN sleep_duration BETWEEN 4 AND 6 THEN '4-6hr'
        WHEN sleep_duration BETWEEN 6 AND 8 THEN '6-8hr'
        WHEN sleep_duration BETWEEN 8 AND 10 THEN '8-10hr'
        ELSE '10hr+'
    END AS sleep_range,
    COUNT(*) user_count,
    AVG(stress_level) avg_stress_level
FROM clean_smartwatch_data
WHERE sleep_duration IS NOT NULL
GROUP BY sleep_range
ORDER BY 1;
-- There seems to be a subtle trend where more sleep correlates to less stress, noticed after 6hr+ threshold

SELECT 
    CASE 
        WHEN step_count < 2000 THEN '<2k'
        WHEN step_count BETWEEN 2000 AND 4999 THEN '2-5k'
        WHEN step_count BETWEEN 5000 AND 9999 THEN '5-10k'
        WHEN step_count BETWEEN 10000 AND 14999 THEN '10-15k'
        ELSE '>15k'
    END AS steps_bin,
    COUNT(*) user_count,
    AVG(heart_rate) avg_heart_rate
FROM clean_smartwatch_data
WHERE step_count IS NOT NULL AND heart_rate IS NOT NULL
GROUP BY steps_bin;
-- There is a small upward trend in average heart rate and an increased step count

-- Exploring the obvious - relevance of activity level to hear rate
SELECT 
    activity_level, 
    COUNT(heart_rate) AS Count,
    AVG(heart_rate) AS avg_heartrate
FROM clean_smartwatch_data
WHERE activity_level IS NOT NULL
GROUP BY activity_level
ORDER BY 3 DESC;
-- Despite expectations, heart rate is stable across activity levels

# SECTION: Interesting Anomalies & Edge Cases
SELECT 
    user_id, 
    COUNT(*) AS Count, 
    AVG(heart_rate) AS avg_heart_rate
FROM clean_smartwatch_data
WHERE user_id IN 
    (SELECT user_id
     FROM (SELECT user_id, COUNT(*)
           FROM clean_smartwatch_data
           GROUP BY user_id
           HAVING COUNT(*) > 1) dup_ids)
  AND heart_rate IS NOT NULL
GROUP BY user_id
ORDER BY 3 DESC;
/* 
Users with heart rates over 200 bpm could be due to sensor errors, 
	high intensity workouts, or other factors.
Typically, as count increases, the average lowered to 70-90 bpm
*/
