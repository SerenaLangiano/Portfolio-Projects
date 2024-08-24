### Healthcare Data Analysis with SQL
**Code:** [`Ecommerce project MySQL queries.sql`](https://github.com/SerenaLangiano/Portfolio-Projects/blob/main/Ecommerce-Analysis/Ecommerce%20project%20MySQL%20queries.sql)

**Goal:** The goal of this project is to analyse patient demographics by postcode and gender to determine the distribution of patients across different areas. This analysis is aimed at identifying the most suitable areas with a balanced gender distribution for a research study. Additionally, for the top two postcode areas with the largest patient populations identified, patients are filtered based on specific clinical criteria (such as asthma diagnosis, medication history, smoking status, weight, COPD diagnosis, and opt-out preferences), allowing for generating a list of eligible patients for the study.

**Description:** The data is stored in four .csv files: medication, observation, patient and clinical_codes.

**Skills:** database, SQL, queries.

**Technology:** SQL

**Results:** The goal of the first part of the project is identifying the number of patients for each postcode, and their gender. LS99 9ZZ is the postcode with the highest number of patients. This is the starting point for the second part of the project.

 ![Alt text](https://github.com/SerenaLangiano/Portfolio-Projects/blob/eabe46a609cf60ab68609edd5afe0343656be955/Healthcare%20Data%20Analysis/Pictures/Figure1.jpg)

The goal of the second part of the project is identifying the most suitable patients for the research study within the top 2 postcodes. Patients shall meet the following criteria:

1) belong to the most suitable postcode areas in terms of patient count;
2) have asthma and are currently treating it;
3) have been prescribed either Formoterol Fumarate, Salmeterol Xinafoate, Vilanterol, Indacaterol, Olodaterol (or meds containing these ingredients) in the past 30 years;
4) are not currently smoking;
5) weight more than 40kg;
6) do not have a COPD diagnosis;
7) have not opted out of taking part in research or sharing their medical record.

![Alt text](https://github.com/SerenaLangiano/Portfolio-Projects/blob/eabe46a609cf60ab68609edd5afe0343656be955/Healthcare%20Data%20Analysis/Pictures/Figure2.jpg)

