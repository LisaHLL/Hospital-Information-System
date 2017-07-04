rem EE562 Project 3
rem HSIANG-LING LIN
rem lin643@ecn2
select* from genral_ward;
select* from screening_ward;
select* from pre_surgery_ward;
select* from post_surgery_ward;
begin

dr_sch;

end;
/

begin

surgeon;

end;
/
select* from dr_schedule;
select* from surgeon_schedule;

CREATE VIEW Patient_Surgery_View AS 
SELECT P.Patient_Name, P.Post_Admission_Date, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
UNION
SELECT P.Patient_Name, P.Post_Admission_Date, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
UNION
SELECT P.Patient_Name, P.Post_Admission_Date, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='General' AND (S.Name='Dr.Smith' OR S.Name='Dr.Richards')
UNION
SELECT P.Patient_Name, P.Post_Admission_Date+2, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
UNION
SELECT P.Patient_Name, P.Post_Admission_Date+2, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
;


SELECT* FROM Patient_Surgery_View;
