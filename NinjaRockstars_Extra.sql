--EXTRA QUESTIONS AND QUERIES - 6


--1.Which Service Type Patients have more death rate
select S."Service", count(RA."Patient_ID") FILTER(Where("DischargeDisposition" = 'Expired')) as "count1"
from "ReAdmissionRegistry" RA join "DischargeDisposition" DD
on RA."Discharge_ID" = DD."Discharge_ID"
join "Service" S
on S."Service_ID" = RA."Service_ID"
group by S."Service" order by count1 desc

-- 2.Mortality Distribution In ICU Service Based On Primary Diagnosis
select S."Service", PD."PrimaryDiagnosis", count(RA."Patient_ID") 
from "ReAdmissionRegistry" RA join "DischargeDisposition" DD
on RA."Discharge_ID" = DD."Discharge_ID"
join "Service" S
on S."Service_ID" = RA."Service_ID"
join "PrimaryDiagnosis" PD
on PD."Diagnosis_ID" = RA."Diagnosis_ID"
where "DischargeDisposition" = 'Expired'
group by S."Service", PD."PrimaryDiagnosis" HAVING "Service" = 'ICU' order by 1,2

--3. Which Primary Diagnosis Patients has Maximum LOS

SELECT "PrimaryDiagnosis",TRUNC(CAST(AVG("ExpectedLOS") AS DECIMAL),2) AS AVG_los 
FROM public."ReAdmissionRegistry" JOIN public."PrimaryDiagnosis" 
ON "PrimaryDiagnosis"."Diagnosis_ID" = "ReAdmissionRegistry"."Diagnosis_ID"
GROUP BY "PrimaryDiagnosis" ORDER by AVG_los DESC LIMIT 1

--4.Percentage of Male and Female Patients in Hospital DB

SELECT "Gender", ((COUNT("Patient_ID")*100)/(Select count("Patient_ID") from "Patients"))||'%' as Percentage 
From "Patients" P JOIN "Gender" G
ON P."Gender_ID" = G."Gender_ID" 
group by  "Gender"

--5.Display the output as below
 SELECT  
 CASE     
     WHEN "Gender" = 'Male' THEN overlay("FirstName" placing 'Mr.' from 1 for 0)
     WHEN "Gender" = 'Female' THEN overlay("FirstName"  placing 'Ms.' from 1 for 0)
 END AS "First_Name" 
 ,"LastName"
From "Patients" P JOIN "Gender" G
ON P."Gender_ID" = G."Gender_ID" 

-- 6.Rank Primary Diagnosis based on Transfer Rate 

With Perc_CTE AS
(
select PD."PrimaryDiagnosis" as Primary_Diagnosis, count(D."Patient_ID") FILTER (where ("DischargeDisposition" = 'Transfer')) as P_count
FROM "Discharges" D join "PrimaryDiagnosis" PD
on D."Diagnosis_ID"= PD."Diagnosis_ID"
join "DischargeDisposition" DD
on D."Discharge_ID" = DD."Discharge_ID"
group by PD."PrimaryDiagnosis" order by P_count DESC
) 
Select Primary_Diagnosis,P_count,Dense_Rank() OVER(order by P_count DESC) as DiagnosisRank from Perc_CTE

