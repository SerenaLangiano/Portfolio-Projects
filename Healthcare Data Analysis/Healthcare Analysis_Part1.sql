USE nhs_new;
-- Patient analysis by postcode and gender
WITH patients_groupedby_postcode AS (
    SELECT 
		postcode,
		COUNT(patient_id) AS total_patient_count,
        gender
	FROM 
		patient
	WHERE postcode is not NULL
	GROUP BY 
		postcode, gender
	ORDER BY 
		total_patient_count DESC, postcode ASC
)

SELECT * from patients_groupedby_postcode