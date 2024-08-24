USE nhs_new;

-- Step 1: Finding the 2 top postcodes for patient count
WITH top_postcodes AS (
    SELECT 
		postcode,
		COUNT(patient_id) AS total_patient_count
	FROM 
		patient
	WHERE postcode is not NULL
	GROUP BY 
		postcode
	ORDER BY 
		total_patient_count DESC, postcode ASC
	LIMIT 2
),

-- Step 2: Finding list of patients with asthma, i.e. refsetid 999012891000230104
asthma_patients AS (
    SELECT DISTINCT
        p.patient_id
    FROM 
        patient p
    JOIN 
        observation_tot o ON p.registration_guid = o.registration_guid -- I need patient_id from p, refset_simple_id from cc and emis_original_term from o 
    JOIN 
        clinical_codes cc ON o.emis_code_id = cc.code_id -- o table: column 'emis_original_term' cointains info on asthma resolution
    WHERE 
        cc.refset_simple_id = '999012891000230104' -- Asthma refset
        AND o.emis_original_term NOT LIKE '%resolved%'
        AND p.postcode IN (SELECT postcode FROM top_postcodes)
	), 

-- Step 3: Finding list of patients that have been prescribed with certain meds in the last 30 years
medication_patients AS (
    SELECT DISTINCT
        p.patient_id
    FROM 
        patient p
    JOIN 
        medication_tot m ON p.registration_guid = m.registration_guid -- I need effective_date from m, patient_id from p, snomed_concept_id and parent_code_id from cc
    JOIN 
        clinical_codes cc ON m.emis_code_id = cc.code_id
    WHERE 
        p.postcode IN (SELECT postcode FROM top_postcodes)
        AND (
            cc.snomed_concept_id IN (
                '129490002', -- Formoterol Fumarate
                '108606009', -- Salmeterol Xinafoate
                '702408004', -- Vilanterol
                '702801003', -- Indacaterol
                '704459002'  -- Olodaterol
            )
            OR cc.parent_code_id IN (
                '591221000033116', -- Formoterol Fumarate
                '717321000033118', -- Salmeterol Xinafoate
                '1215621000033114', -- Vilanterol
                '972021000033115', -- Indacaterol
                '1223821000033118' -- Olodaterol
            )
        )
        AND m.effective_date >= DATE_ADD(CURDATE(), interval -30 year) -- Subtract 30 years from current date
),

-- Step 4: Finding a list with current smokers, i.e. refsetid 999004211000230104
smoker_exclusions AS (
    SELECT DISTINCT
        p.patient_id
    FROM 
        patient p
    JOIN 
        observation_tot o ON p.registration_guid = o.registration_guid -- I need patient_id from p, refset_simple_id from cc
    JOIN 
        clinical_codes cc ON o.emis_code_id = cc.code_id
    WHERE 
        cc.refset_simple_id = '999004211000230104' -- Smoker refset
        AND p.postcode IN (SELECT postcode FROM top_postcodes)
),

-- Step 5: Finding list of patients weighting 40kg, i.e. snomed_concept_id 27113001
weight_exclusions AS (
    SELECT DISTINCT
        p.patient_id
    FROM 
        patient p
    JOIN 
        observation_tot o ON p.registration_guid = o.registration_guid -- I need patient_id from p, snomed_concept_id from o
    WHERE 
        o.snomed_concept_id = '27113001' -- Snomed_concept_id for Weight
        AND p.postcode IN (SELECT postcode FROM top_postcodes)
), 

-- Step 6: Finding list of patients with COPD diagnosis, i.e. refsetid 999011571000230107
copd_exclusions AS (
    SELECT DISTINCT
        p.patient_id
    FROM 
        patient p
    JOIN 
        observation_tot o ON p.registration_guid = o.registration_guid -- I need patient_id from p, refset_simple_id from cc and emis_original_term from o
    JOIN 
        clinical_codes cc ON o.emis_code_id = cc.code_id
    WHERE 
        cc.refset_simple_id = '999011571000230107' -- COPD refset
        AND o.emis_original_term NOT LIKE '%resolved%' -- emis_original_term column from o contains info on COPD resolution
        AND p.postcode IN (SELECT postcode FROM top_postcodes)
),

-- Step 7: Finding list of patients that have opt out of taking part in research or sharing their medical record 
opt_out_exclusions AS (
	SELECT DISTINCT
		p.patient_id
	FROM 
		patient p
    JOIN
        observation_tot o ON p.registration_guid = o.registration_guid -- I need patient_id from p, columns with headers containing 'opt_out' in o and m
	JOIN 
		medication_tot m ON p.registration_guid = m.registration_guid
	WHERE 
		(o.opt_out_93c1_flag=TRUE
        OR o.opt_out_9nd19nu09nu4_flag=TRUE
        OR o.opt_out_9nd19nu0_flag=TRUE
        OR o.opt_out_9nu0_flag=TRUE
        OR m.opt_out_93c1_flag=TRUE
        OR m.opt_out_9nd19nu09nu4_flag=TRUE
        OR m.opt_out_9nd19nu0_flag=TRUE
        OR m.opt_out_9nu0_flag=TRUE)
        AND p.postcode IN (SELECT postcode FROM top_postcodes)
	)
-- Final step: Return a list of eligible patients, i.e.: 
-- 1) belong to the most suitable postcode areas in terms of patient count;
-- 2) have asthma and are currently treating it;
-- 3) have been prescribed either Formoterol Fumarate, Salmeterol Xinafoate, Vilanterol, Indacaterol, Olodaterol (or meds containing these ingredients) in the past 30 years;
-- 4) are not currently smoking;
-- 5) weight more than 40kg;
-- 6) do not have a COPD diagnosis;
-- 7) have not opted out of taking part in research or sharing their medical record.
 
SELECT DISTINCT
	p.patient_id,
    p.postcode,
    CONCAT(p.patient_surname, " ", p.patient_givenname) AS full_name,    
    p.date_of_birth,
    p.age,
    p.gender,
    p.registration_guid AS registration_id,
	m.emis_registration_organisation_guid AS organisation_id
FROM 
	patient p
LEFT JOIN
	medication_tot m ON p.registration_guid = m.registration_guid
WHERE
	(p.patient_id IN (SELECT patient_id FROM asthma_patients)
    OR p.patient_id IN (SELECT patient_id FROM medication_patients)) 
    AND(p.date_of_death is NULL                                          -- To exclude dead patients
    AND p.patient_id NOT IN (SELECT patient_id FROM smoker_exclusions)
    AND p.patient_id NOT IN (SELECT patient_id FROM weight_exclusions)
    AND p.patient_id NOT IN (SELECT patient_id FROM copd_exclusions)
    AND p.patient_id NOT IN (SELECT patient_id FROM opt_out_exclusions))