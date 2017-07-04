--drop trigger trg_gen;
--drop trigger trg_scr;
--drop trigger trg_pre;
--drop trigger trg_post;
drop function fun_find_b_num;
drop function find_bed_num2;
drop procedure dr_sch;
drop procedure surgeon;
drop function chk;
drop function chk2;
drop function chk4;
drop function chk3;
drop function chk5;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--find bed number for trigger1
CREATE FUNCTION fun_find_b_num
	(fecha IN date)
RETURN NUMBER

IS

Type bedarray IS VARRAY(5) OF NUMBER;

bed_num bedarray;

CURSOR name_cur IS 
	
	WITH temp_pre AS (select Patient_Name, Pre_Admission_Date+2, Patient_Type from PRE_SURGERY_WARD)
	SELECT X.p_name
	FROM	(
		SELECT P.Patient_Name AS p_name, P.Post_Admission_Date AS d1, P.Patient_Type
		FROM POST_SURGERY_WARD P
		MINUS
		SELECT *
		FROM temp_pre)X
	WHERE X.d1> fecha
	UNION
	SELECT Patient_Name
	FROM PRE_SURGERY_WARD
	WHERE PRE_SURGERY_WARD.Pre_Admission_Date>fecha;

pname varchar2(30);
i number;
b_num number;



BEGIN
bed_num:=bedarray(1,2,3,4,5);
i:=1;

OPEN name_cur;

LOOP 
	fetch name_cur into pname;
	exit when name_cur%notfound;
	SELECT Bed_No into b_num
	FROM SCREENING_WARD
	WHERE Patient_Name=pname AND S_Admission_Date=(SELECT MAX(S_Admission_Date) FROM SCREENING_WARD WHERE Patient_Name=pname);
	bed_num(b_num):=0;
END LOOP;
CLOSE name_cur;

LOOP
exit when bed_num(i)!=0;
i:=i+1;
END LOOP;

return bed_num(i);

	
END;
/

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--trigger1
CREATE TRIGGER trg_gen
AFTER INSERT ON GENERAL_WARD 
FOR EACH ROW
DECLARE
x number;
d date;
x2 number;
d2 date;
bed number;
pname varchar2(30);
d_scr date;

BEGIN
	SELECT MAX(S_Admission_Date) INTO d_scr
	FROM SCREENING_WARD;
	IF d_scr<:new.G_Admission_Date+3 OR d_scr IS NULL
	THEN d_scr:=:new.G_Admission_Date+3;
	END IF;
	
	begin
	WITH temp_pre AS (select Patient_Name, Pre_Admission_Date+2, Patient_Type from PRE_SURGERY_WARD)
	SELECT COUNT(*), MIN(d1) into x, d
	FROM	(
		SELECT P.Patient_Name, P.Post_Admission_Date AS d1, P.Patient_Type
		FROM POST_SURGERY_WARD P
		MINUS
		SELECT *
		FROM temp_pre)
	WHERE d1> d_scr;
	exception
	when no_data_found then
	d:=null;
	end;
	

	begin
	SELECT COUNT(*), MIN(PRE_SURGERY_WARD.Pre_Admission_Date) into x2, d2
	FROM PRE_SURGERY_WARD
	WHERE PRE_SURGERY_WARD.Pre_Admission_Date>d_scr;
	exception
	when no_data_found then
	d2:=null;
	end;
	

	IF x+x2<5--not full
	THEN
	bed:=fun_find_b_num(d_scr);
	insert into SCREENING_WARD values(:new.Patient_Name, d_scr, bed, :new.Patient_Type);
	ELSIF x+x2>=5--full
	THEN
		IF d>d2 OR d is NULL
		THEN
		bed:=fun_find_b_num(d2);
		
		insert into SCREENING_WARD values(:new.Patient_Name, d2, bed, :new.Patient_Type);

		ELSIF d2>=d OR d2 is NULL
		THEN
		bed:=fun_find_b_num(d);
		
		insert into SCREENING_WARD values(:new.Patient_Name, d, bed, :new.Patient_Type);
		
		
		END IF;
	END IF;

	

END;
/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--find bed number for trigger2
CREATE FUNCTION find_bed_num2
	(fecha2 IN date)
RETURN NUMBER

IS

Type bedarray2 IS VARRAY(4) OF NUMBER;

bed_num2 bedarray2;

CURSOR name_cur2 IS 
	
	SELECT Patient_Name
	FROM POST_SURGERY_WARD
	WHERE POST_SURGERY_WARD.Post_Admission_Date>fecha2;

pname2 varchar2(30);
i2 number;
b_num2 number;



BEGIN
bed_num2:=bedarray2(1,2,3,4);
i2:=1;

OPEN name_cur2;

LOOP 
	fetch name_cur2 into pname2;
	exit when name_cur2%notfound;
	SELECT Bed_No into b_num2
	FROM PRE_SURGERY_WARD
	WHERE Patient_Name=pname2 AND Pre_Admission_Date=(SELECT MAX(Pre_Admission_Date) FROM PRE_SURGERY_WARD WHERE Patient_Name=pname2);
	bed_num2(b_num2):=0;
END LOOP;
CLOSE name_cur2;

LOOP
exit when bed_num2(i2)!=0;
i2:=i2+1;
END LOOP;

return bed_num2(i2);

	
END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--trigger2

CREATE TRIGGER trg_scr
AFTER INSERT ON SCREENING_WARD
FOR EACH ROW
DECLARE

x number;
d date;

d1 date;
t number;
b number;
ct number:=0;
d_pre date;
b_num2 number;

BEGIN
	SELECT MAX(Pre_Admission_Date) INTO d_pre
	FROM PRE_SURGERY_WARD;
	IF d_pre<:new.S_Admission_Date+3 OR d_pre IS NULL
	THEN d_pre:=:new.S_Admission_Date+3;
	END IF;

	SELECT count(*), MIN(P.Post_Admission_Date) INTO x,d
	FROM POST_SURGERY_WARD P
	WHERE P.Post_Admission_Date> d_pre;
	
	DECLARE
	CURSOR x_cur IS
	SELECT p.Pdate, p.Temperature, p.BP
	FROM Patient_Chart p
	WHERE p.Pdate<=d AND p.Pdate> =:new.S_Admission_Date AND p.Patient_Name= :new.Patient_Name
	ORDER BY p.Pdate;
	BEGIN
	OPEN x_cur;
	LOOP
	fetch x_cur into d1,t,b;
	exit when x_cur%notfound OR ct=4;	
	IF t<=100 AND t>=97 AND b<=140 AND b>=110
	THEN	
	ct:=ct+1;
	ElSE
	ct:=0;

	END IF;
	END LOOP;
	CLOSE x_cur;
	END;

	
	
	IF x=4 AND ct<4
	THEN 
	b_num2:= find_bed_num2(d);	
	insert into PRE_SURGERY_WARD values (:new.Patient_Name,d,b_num2,:new.Patient_Type);
	ELSIF x=4 AND ct=4
	THEN insert into POST_SURGERY_WARD values (:new.Patient_Name,d1,NULL,1,:new.Patient_Type);
	ELSIF x<4
	THEN
	b_num2:=find_bed_num2(d_pre);
	insert into PRE_SURGERY_WARD values (:new.Patient_Name,d_pre,b_num2,:new.Patient_Type);

	END IF;
	


END;
/


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--

CREATE TRIGGER trg_pre
AFTER INSERT ON PRE_SURGERY_WARD
FOR EACH ROW

BEGIN
	insert into POST_SURGERY_WARD values (:new.Patient_Name, :new.Pre_Admission_Date+2,NULL,1,:new.Patient_Type);

END;
/

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--trigger3
CREATE TRIGGER trg_post
BEFORE INSERT ON POST_SURGERY_WARD
FOR EACH ROW

DECLARE
pname varchar2(30);
t number;
b number;
ct number:=0;

CURSOR x_cur IS
	SELECT p.Patient_Name, p.Temperature, p.BP
	FROM Patient_Chart p
	WHERE p.Pdate>=:new.Post_Admission_Date AND p.Pdate<:new.Post_Admission_Date+2 AND p.Patient_Name=:new.Patient_Name;



pname2 varchar2(30);
b2 number;
ct2 number:=0;

CURSOR y_cur IS
	SELECT p.Patient_Name, p.BP
	FROM Patient_Chart p
	WHERE p.Pdate>=:new.Post_Admission_Date AND p.Pdate<:new.Post_Admission_Date+2 AND p.Patient_Name=:new.Patient_Name;

fecha date:=:new.Post_Admission_Date;

BEGIN

OPEN x_cur;
LOOP
fetch x_cur into pname, t, b;
exit when x_cur%notfound;
IF t<=100 AND t>=97 AND b<=140 AND b>=110
THEN ct:=ct+1;

END IF;
END LOOP;
CLOSE x_cur;


OPEN y_cur;
LOOP
fetch y_cur into pname2, b2;
exit when y_cur%notfound;
IF b2<=140 AND b2>=110
THEN ct2:=ct2+1;

END IF;
END LOOP;
CLOSE y_cur;


	IF :new.Patient_Type='General'
	THEN 
	:new.Discharge_Date:=fecha+2;

	ELSIF :new.Patient_Type='Neuro'
	THEN
		IF ct=2
		THEN
		:new.Discharge_Date:=fecha+2;

		ELSIF ct<2
		THEN
		:new.Discharge_Date:=fecha+4;
		:new.Scount:=2;

		
		END IF;
	ELSIF :new.Patient_Type='Cardiac'
	THEN
		IF ct2=2
		THEN
		:new.Discharge_Date:=:new.Post_Admission_Date+2;
	
		ELSIF ct2<2
		THEN
		:new.Discharge_Date:=:new.Post_Admission_Date+4;
		:new.Scount:=2;
		

		END IF;
	END IF;
END;
/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--procedure for dr_schedule
ALTER SESSION SET NLS_DATE_FORMAT='MM/DD/YY';
CREATE PROCEDURE dr_sch

IS 

fecha date:='01/01/05';

BEGIN


for n IN 1 .. 52 LOOP

	for m IN 1 .. 7 LOOP
		
		IF m=1
		THEN
		insert into DR_Schedule values('Dr.James','GENERAL_WARD',fecha);
		insert into DR_Schedule values('Dr.Robert','SCREENING_WARD',fecha);
		insert into DR_Schedule values('Dr.Mike','PRE_SURGERY_WARD',fecha);
		insert into DR_Schedule values('Dr.Adams','POST_SURGERY_WARD',fecha);
		insert into DR_Schedule values('Dr.Tracey','Surgery',fecha);

		ELSIF m=2
		THEN
		insert into DR_Schedule values('Dr.James','GENERAL_WARD',fecha+1);
		insert into DR_Schedule values('Dr.Robert','SCREENING_WARD',fecha+1);
		insert into DR_Schedule values('Dr.Mike','PRE_SURGERY_WARD',fecha+1);
		insert into DR_Schedule values('Dr.Adams','POST_SURGERY_WARD',fecha+1);
		insert into DR_Schedule values('Dr.Tracey','Surgery',fecha+1);
		insert into DR_Schedule values('Dr.Rick','Surgery',fecha+1);
		ELSIF m=3
		THEN
		insert into DR_Schedule values('Dr.Robert','GENERAL_WARD',fecha+2);
		insert into DR_Schedule values('Dr.Mike','SCREENING_WARD',fecha+2);
		insert into DR_Schedule values('Dr.Adams','PRE_SURGERY_WARD',fecha+2);
		insert into DR_Schedule values('Dr.Tracey','POST_SURGERY_WARD',fecha+2);
		insert into DR_Schedule values('Dr.Rick','Surgery',fecha+2);
		ELSIF m=4
		THEN
		insert into DR_Schedule values('Dr.Mike','GENERAL_WARD',fecha+3);
		insert into DR_Schedule values('Dr.Adams','SCREENING_WARD',fecha+3);
		insert into DR_Schedule values('Dr.Tracey','PRE_SURGERY_WARD',fecha+3);
		insert into DR_Schedule values('Dr.Rick','POST_SURGERY_WARD',fecha+3);
		insert into DR_Schedule values('Dr.James','Surgery',fecha+3);
		ELSIF m=5
		THEN
		insert into DR_Schedule values('Dr.Adams','GENERAL_WARD',fecha+4);
		insert into DR_Schedule values('Dr.Tracey','SCREENING_WARD',fecha+4);
		insert into DR_Schedule values('Dr.Rick','PRE_SURGERY_WARD',fecha+4);
		insert into DR_Schedule values('Dr.James','POST_SURGERY_WARD',fecha+4);
		insert into DR_Schedule values('Dr.Robert','Surgery',fecha+4);
		--insert into DR_Schedule values('Rick','Surgery',fecha+4);
		ELSIF m=6
		THEN
		insert into DR_Schedule values('Dr.Tracey','GENERAL_WARD',fecha+5);
		insert into DR_Schedule values('Dr.Rick','SCREENING_WARD',fecha+5);
		insert into DR_Schedule values('Dr.James','PRE_SURGERY_WARD',fecha+5);
		insert into DR_Schedule values('Dr.Robert','POST_SURGERY_WARD',fecha+5);
		insert into DR_Schedule values('Dr.Mike','Surgery',fecha+5);
		ELSIF m=7
		THEN
		insert into DR_Schedule values('Dr.Rick','GENERAL_WARD',fecha+6);
		insert into DR_Schedule values('Dr.James','SCREENING_WARD',fecha+6);
		insert into DR_Schedule values('Dr.Robert','PRE_SURGERY_WARD',fecha+6);
		insert into DR_Schedule values('Dr.Mike','POST_SURGERY_WARD',fecha+6);
		insert into DR_Schedule values('Dr.Adams','Surgery',fecha+6);
		

		END IF;
	
	END LOOP;
fecha:=fecha+7;
END LOOP;
insert into DR_Schedule values('Dr.James','GENERAL_WARD',fecha);
insert into DR_Schedule values('Dr.Robert','SCREENING_WARD',fecha);
insert into DR_Schedule values('Dr.Mike','PRE_SURGERY_WARD',fecha);
insert into DR_Schedule values('Dr.Adams','POST_SURGERY_WARD',fecha);
insert into DR_Schedule values('Dr.Tracey','Surgery',fecha);

END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--surgeon schedule

ALTER SESSION SET NLS_DATE_FORMAT='MM/DD/YY';
CREATE PROCEDURE surgeon

IS 

fecha date:='01/01/05';

BEGIN


for n IN 1 .. 52 LOOP

	for m IN 1 .. 7 LOOP
		
		IF m=1
		THEN
		insert into Surgeon_Schedule values('Dr.Richards',fecha);
		insert into Surgeon_Schedule values('Dr.Gower',fecha);
		insert into Surgeon_Schedule values('Dr.Rutherford',fecha);
		ELSIF m=2
		THEN
		insert into Surgeon_Schedule values('Dr.Smith',fecha+1);
		insert into Surgeon_Schedule values('Dr.Charles',fecha+1);
		insert into Surgeon_Schedule values('Dr.Taylor',fecha+1);
		
		ELSIF m=3
		THEN
		insert into Surgeon_Schedule values('Dr.Smith',fecha+2);
		insert into Surgeon_Schedule values('Dr.Charles',fecha+2);
		insert into Surgeon_Schedule values('Dr.Taylor',fecha+2);
		
		ELSIF m=4
		THEN
		insert into Surgeon_Schedule values('Dr.Richards',fecha+3);
		insert into Surgeon_Schedule values('Dr.Gower',fecha+3);
		insert into Surgeon_Schedule values('Dr.Rutherford',fecha+3);
		ELSIF m=5
		THEN
		insert into Surgeon_Schedule values('Dr.Richards',fecha+4);
		insert into Surgeon_Schedule values('Dr.Gower',fecha+4);
		insert into Surgeon_Schedule values('Dr.Rutherford',fecha+4);
		ELSIF m=6
		THEN
		insert into Surgeon_Schedule values('Dr.Smith',fecha+5);
		insert into Surgeon_Schedule values('Dr.Charles',fecha+5);
		insert into Surgeon_Schedule values('Dr.Taylor',fecha+5);
		ELSIF m=7
		THEN
		insert into Surgeon_Schedule values('Dr.Richards',fecha+6);
		insert into Surgeon_Schedule values('Dr.Gower',fecha+6);
		insert into Surgeon_Schedule values('Dr.Rutherford',fecha+6);

		END IF;
	
	END LOOP;
fecha:=fecha+7;
END LOOP;

insert into Surgeon_Schedule values('Dr.Richards',fecha);
insert into Surgeon_Schedule values('Dr.Gower',fecha);
insert into Surgeon_Schedule values('Dr.Rutherford',fecha);
END;
/

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--This function take junior doctor's name as an argument and then check if they work 6 days per week(which takes doctor's names as an argument)
CREATE FUNCTION chk
	(doctor_name IN varchar2)
	
RETURN NUMBER

IS

ct number;
fecha date:='1/1/05';
d1 date;
d2 date;

BEGIN

FOR i IN 1 .. 52 LOOP
	d1:=fecha+(i-1)*7;--start date
	d2:=fecha+((i*7)-1);--end date
	SELECT COUNT(*) INTO ct
	FROM DR_Schedule d
	WHERE d.Name=doctor_name AND d1<=d.Duty_Date AND d.Duty_Date<=d2;
	IF ct!=6
	THEN DBMS_OUTPUT.PUT_LINE('THE DOCTOR '|| doctor_name || ' DOES NOT WORK 6 DAYS A WEEK');
	END IF;
END LOOP;

return 0; 
END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--check if doctor works in the same ward for 3 consecutive days

CREATE FUNCTION chk2
	(doctor_name IN varchar2)
RETURN NUMBER

IS

CURSOR x_cur IS 
	SELECT d.Ward, d.Duty_Date
	FROM DR_Schedule d
	WHERE d.Name=doctor_name
	ORDER BY d.Duty_Date;

wname varchar2(20);
ddate date;
fecha date:='1/1/05';
ct number:=0;
w varchar2(20):=NULL;
BEGIN

OPEN x_cur;
LOOP
fetch x_cur into wname, ddate;
exit when x_cur%notfound OR ct=2;
IF fecha=ddate AND w=wname
THEN
ct:=ct+1;
fecha:=ddate+1;
ELSIF fecha!=ddate OR w!=wname
THEN
ct:=0;
fecha:=ddate+1;
w:=wname;

END IF;
END LOOP;

IF ct=2
THEN DBMS_OUTPUT.PUT_LINE('Doctor '||doctor_name||' works 3 consecutive days');
ELSE
return 0;
END IF;

END;
/

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--This checks the constraint that every ward has one doctor

CREATE FUNCTION chk4
	(w_name IN varchar2)
RETURN NUMBER

IS

x number;

fecha date:='1/1/05';
d date;

BEGIN

FOR i IN 1 .. 365 LOOP
	d:=fecha+i-1;
	SELECT count(*) into x
	FROM DR_Schedule
	WHERE Duty_Date=d AND Ward=w_name;
	
	
	
	IF x=0
	THEN raise_application_error(-20005,w_name||' at '||d||' has nobody on duty!');
	ELSIF x>1
	THEN raise_application_error(-20005,w_name||' at '||d||' has more than one doctor on duty!');
	
	END IF;
END LOOP;
return 0;

END;
/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--this check that everyday has at least one nuero and one cardiac surgeon
CREATE FUNCTION chk3
	
RETURN NUMBER

IS

fecha date :='1/1/05';
d date;
x number;
y number;

BEGIN

FOR i IN 1 .. 364 LOOP
	d:=fecha+i-1;
	SELECT count(*) into x
	FROM Surgeon_Schedule
	WHERE Surgery_Date=d AND (Name='Dr.Charles' OR Name='Dr.Gower');
	
	SELECT count(*) into y
	FROM Surgeon_Schedule
	WHERE Surgery_Date=d AND (Name='Dr.Taylor' OR Name='Dr.Rutherford');
	
	IF x+y=0
	THEN raise_application_error(-20004,'Surgeon Schedule wrong! '||d|| ' has no Cardiac and Neuro surgeons.');
	END IF;	

	IF x=0
	THEN raise_application_error(-20002,'Surgeon Schedule wrong! '||d|| ' has no Cardiac Surgeon.');
	ELSIF y=0
	THEN raise_application_error(-20003,'Surgeon Schedule wrong! '||d|| ' has no Neuro Surgeon.');
	
	END IF;
END LOOP;

return 0;


END;
/

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--this check each surgeon work according to their schedule
SET SERVEROUTPUT ON
CREATE FUNCTION chk5
RETURN NUMBER

IS 
x number;

s1 number;
s2 number;
s3 number;
s4 number;
s5 number;
s6 number;
fecha date:='12/31/04';
d date;
BEGIN

FOR i IN 1 .. 365 LOOP
	x:=MOD(i, 7);
	d:=fecha+i;
	IF x=1
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should be on duty at '||d);
		ELSIF s2=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should be on duty at '||d);
		ELSIF s3=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should be on duty at '||d);
		ELSIF s4=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should not be on duty at '||d);
		ELSIF s5=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should not be on duty at '||d);
		ELSIF s6=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should not be on duty at '||d);
		END IF;
	ELSIF x=2
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should not be on duty at '||d);
		ELSIF s2=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should not be  on duty at '||d);
		ELSIF s3=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should not be on duty at '||d);
		ELSIF s4=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should be on duty at '||d);
		ELSIF s5=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should be on duty at '||d);
		ELSIF s6=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should be on duty at '||d);
		END IF;
	ELSIF x=3
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should not be on duty at '||d);
		ELSIF s2=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should not be  on duty at '||d);
		ELSIF s3=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should not be on duty at '||d);
		ELSIF s4=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should be on duty at '||d);
		ELSIF s5=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should be on duty at '||d);
		ELSIF s6=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should be on duty at '||d);
		END IF;
	ELSIF x=4
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should be on duty at '||d);
		ELSIF s2=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should be on duty at '||d);
		ELSIF s3=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should be on duty at '||d);
		ELSIF s4=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should not be on duty at '||d);
		ELSIF s5=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should not be on duty at '||d);
		ELSIF s6=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should not be on duty at '||d);
		END IF;
	ELSIF x=5
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should be on duty at '||d);
		ELSIF s2=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should be on duty at '||d);
		ELSIF s3=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should be on duty at '||d);
		ELSIF s4=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should not be on duty at '||d);
		ELSIF s5=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should not be on duty at '||d);
		ELSIF s6=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should not be on duty at '||d);
		END IF;
	ELSIF x=6
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should not be on duty at '||d);
		ELSIF s2=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should not be  on duty at '||d);
		ELSIF s3=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should not be on duty at '||d);
		ELSIF s4=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should be on duty at '||d);
		ELSIF s5=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should be on duty at '||d);
		ELSIF s6=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should be on duty at '||d);
		END IF;
	ELSIF x=0
	THEN
		SELECT count(*) into s1
		FROM Surgeon_Schedule
		WHERE Name='Dr.Richards' AND Surgery_Date=d;
		SELECT count(*) into s2
		FROM Surgeon_Schedule
		WHERE Name='Dr.Gower' AND Surgery_Date=d;
		SELECT count(*) into s3
		FROM Surgeon_Schedule
		WHERE Name='Dr.Rutherford' AND Surgery_Date=d;
		SELECT count(*) into s4
		FROM Surgeon_Schedule
		WHERE Name='Dr.Smith' AND Surgery_Date=d;
		SELECT count(*) into s5
		FROM Surgeon_Schedule
		WHERE Name='Dr.Charles' AND Surgery_Date=d;
		SELECT count(*) into s6
		FROM Surgeon_Schedule
		WHERE Name='Dr.Taylor' AND Surgery_Date=d;
		IF s1=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Richards should be on duty at '||d);
		ELSIF s2=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Gower should be on duty at '||d);
		ELSIF s3=0 THEN DBMS_OUTPUT.PUT_LINE('Dr.Rutherford should be on duty at '||d);
		ELSIF s4=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Smith should not be on duty at '||d);
		ELSIF s5=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Charles should not be on duty at '||d);
		ELSIF s6=1 THEN DBMS_OUTPUT.PUT_LINE('Dr.Taylor should not be on duty at '||d);
		END IF;
	END IF;
END LOOP;


return 0;
END;
/

