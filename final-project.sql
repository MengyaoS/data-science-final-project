--- create a new table for primary dataste 
DROP TABLE IF EXISTS raw_data.mdclone;
CREATE TABLE raw_data.mdclone (
    date_of_birth VARCHAR,
    gender_at_birth VARCHAR,
    ethnicity VARCHAR,
    race_primary VARCHAR,
    patient_id VARCHAR,
    cohort_reference_event_age_at_event FLOAT,
    cohort_reference_event_condition VARCHAR,
    cohort_reference_event_problem_onset_date_time FLOAT,
    bmi_age_at_event FLOAT,
    bmi_estimated_result FLOAT,
    bmi_measurement VARCHAR,
    bmi_measurement_date_time_days_from_reference FLOAT,
    demographic_age_at_event FLOAT,
    demographic_employment_status VARCHAR,
    demographic_home_3_digit_zipcode VARCHAR,
    copd_count INTEGER,
    ardds_count INTEGER,
    obesity_count INTEGER,
    diabetes_count INTEGER,
    hypertension_count INTEGER,
    dyslipidemia_count INTEGER,
    ibd_count INTEGER,
    chronic_liver_disease_count INTEGER,
    antiarrhythmics_count INTEGER,
    vasodilators_count INTEGER,
    statins_count INTEGER,
    anti_thrombotic_medication_count INTEGER,
    ischemic_heart_disease_age_at_event FLOAT,
    ischemic_heart_disease_condition VARCHAR,
    ischemic_heart_disease_problem_onset_date_time_days_from_reference FLOAT,
    congestive_heart_failure_age_at_event FLOAT,
    congestive_heart_failure_condition VARCHAR,
    congestive_heart_failure_problem_onset_date_time_days_from_reference FLOAT,
    stroke_age_at_event FLOAT,
    stroke_condition VARCHAR,
    stroke_problem_onset_date_time_days_from_reference FLOAT
);

--- create a new table for complimentary dataste (asc_data)
DROP TABLE IF EXISTS raw_data.acs;
CREATE TABLE raw_data.acs (      
    year INT,                
    zip_Code VARCHAR(10),    
    mean_income FLOAT,  
    mean_education FLOAT   
);


--- intermediate SQL query that was used in R script
WITH adjusted_mdclone AS (
    SELECT *,
           EXTRACT(YEAR FROM to_timestamp(cohort_reference_event_problem_onset_date_time)) AS year_of_diagnosis,
           CASE
               WHEN EXTRACT(YEAR FROM to_timestamp(cohort_reference_event_problem_onset_date_time)) < 2011 THEN 2011
               WHEN EXTRACT(YEAR FROM to_timestamp(cohort_reference_event_problem_onset_date_time)) > 2022 THEN 2022
               ELSE EXTRACT(YEAR FROM to_timestamp(cohort_reference_event_problem_onset_date_time))
           END AS adjusted_year,
           CAST(demographic_home_3_digit_zipcode AS TEXT) AS zip_code
    FROM raw_data.mdclone
),
acs_adjusted AS (
    SELECT zip_code, year, mean_income, mean_education
    FROM raw_data.acs
)

SELECT m.*, 
       a.mean_income, 
       a.mean_education
FROM adjusted_mdclone m
LEFT JOIN acs_adjusted a 
    ON m.zip_code = a.zip_code
    AND m.adjusted_year = a.year;