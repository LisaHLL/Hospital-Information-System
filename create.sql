
rem EE562 Project 3
rem HSIANG-LING LIN
rem lin643@ecn2

drop table GENERAL_WARD;
drop table SCREENING_WARD;
drop table PRE_SURGERY_WARD;
drop table POST_SURGERY_WARD;
drop table Patient_chart;
drop table DR_Schedule;

drop table Surgeon_Schedule;
drop table PATIENT_INPUT;

CREATE TABLE GENERAL_WARD
(
 Patient_Name varchar2(30),
 G_Admission_Date date,
 Patient_Type varchar2(10),
 CONSTRAINT chk_type
 CHECK ( Patient_Type IN ('Cardiac','Neuro','General'))
);


CREATE TABLE SCREENING_WARD
(
Patient_Name varchar2(30),
S_Admission_Date date,
Bed_No number,
Patient_Type varchar2(10)
);


CREATE TABLE PRE_SURGERY_WARD
(
Patient_Name varchar2(30),
Pre_Admission_Date date,
Bed_No number,
Patient_Type varchar2(10)
);


CREATE TABLE POST_SURGERY_WARD
(
Patient_Name varchar2(30),
Post_Admission_Date date,
Discharge_Date date,
Scount number,
Patient_Type varchar2(10)
);


CREATE TABLE Patient_Chart
(
Patient_Name varchar2(30),
Pdate date,
Temperature number,
BP number
);


CREATE TABLE DR_Schedule
(
Name varchar2(30),
Ward varchar2(20),
Duty_Date date
);


CREATE TABLE Surgeon_Schedule
(
Name varchar2(30),
Surgery_Date date
);


CREATE TABLE PATIENT_INPUT
(
Patient_Name varchar2(30),
General_ward_admission_date date,
Patient_Type varchar2(10)
);













