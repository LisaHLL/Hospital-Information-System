rem EE562 Project 3
rem HSIANG-LING LIN
rem lin643@ecn2


drop procedure Q1;
drop procedure Q2;
drop procedure Q3;
drop procedure Q4;
drop procedure Q5;
drop procedure Q6;
drop procedure Q8;
drop procedure Q9;

exec DBMS_OUTPUT.PUT_LINE('Q1');
CREATE PROCEDURE Q1
IS
CURSOR name_cur IS
	SELECT DISTINCT(Patient_Name)
	FROM GENERAL_WARD
	ORDER BY Patient_Name;

pname varchar2(30);
d_start date:='12/31/04';
d_end date:='12/31/04';
d_final date;
cnt_visit number:=0;
d_scrn date;
d_pre date;
d_post date;
days number:=0;
ptype varchar2(10);
num_surgery number;
surgery_chrg number;
reimburse number:=0;

BEGIN

OPEN name_cur;
LOOP
fetch name_cur into pname;
exit when name_cur%notfound;




	SELECT MAX(Discharge_Date) into d_final------------------------------------------------------------------------------------------------------------------------------------
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND extract(year from POST_SURGERY_WARD.Discharge_Date)=2005;
	
	LOOP 
	exit when d_final=d_start;
	cnt_visit:=cnt_visit+1;
	
	SELECT MIN(G_Admission_Date) into d_start
	FROM GENERAL_WARD
	WHERE Patient_Name=pname AND G_Admission_Date>=d_end;

	SELECT MIN(Discharge_Date) into d_end
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date>d_start;

	SELECT Patient_Type, Scount into ptype, num_surgery
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date=d_end;
	
	SELECT S_Admission_Date into d_scrn
	FROM SCREENING_WARD
	WHERE Patient_Name=pname AND d_start<S_Admission_Date AND S_Admission_Date<d_end;
	
	SELECT Post_Admission_Date into d_post
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND d_start<Post_Admission_Date AND Post_Admission_Date<d_end;

	begin
	SELECT Pre_Admission_Date into d_pre
	FROM PRE_SURGERY_WARD
	WHERE Patient_Name=pname AND d_start<Pre_Admission_Date AND Pre_Admission_Date<d_end;
	exception	
	when no_data_found
	then d_pre:=d_post;
	end;
	
	days:=days+(d_end-d_start);
	IF ptype='Cardiac' AND num_surgery=1
	THEN surgery_chrg:=2625;
	ELSIF ptype='Cardiac' AND num_surgery=2
	THEN surgery_chrg:=5075;
	ELSIF ptype='Neuro' AND num_surgery=1
	THEN surgery_chrg:=4250;
	ELSIF ptype='Neuro' AND num_surgery=2
	THEN surgery_chrg:=8250;
	ELSIF ptype='General'
	THEN surgery_chrg:=1625;
	END IF;

	reimburse:=reimburse+120+(d_scrn-d_start-3)*35+119+(d_pre-d_scrn-2)*52.5+(d_post-d_pre)*85.5+(d_end-d_post)*72+surgery_chrg;
	
	d_start:=d_end;
	END LOOP;------------------------------------------------------------------------------------------------------------------------------------------------------------------

	DBMS_OUTPUT.PUT_LINE('Patient Name: '||pname||' Number of visits: '||cnt_visit||' AVG stay: '||days/cnt_visit||' Total cost reimbursed: '||reimburse);
	
	cnt_visit:=0;
	reimburse:=0;
	days:=0;
	d_start:='12/31/04';
	d_end:='12/31/04';

END LOOP;

END;
/

exec Q1
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q2
exec DBMS_OUTPUT.PUT_LINE('Q2');
CREATE PROCEDURE Q2
IS
CURSOR name_cur IS
	SELECT DISTINCT(Patient_Name)
	FROM GENERAL_WARD
	ORDER BY Patient_Name;

pname varchar2(30);
d_start date:='12/31/04';
d_end date:='12/31/04';
d_final date;
cnt_visit number:=0;
d_scrn date;
d_pre date;
d_post date;
ptype varchar2(10);
num_surgery number;
surgery_chrg number;
reimburse number:=0;
cost number;
total_cost number:=0;
p_num number;

BEGIN
SELECT COUNT(DISTINCT(Patient_Name)) into p_num
FROM GENERAL_WARD;
OPEN name_cur;
LOOP
fetch name_cur into pname;
exit when name_cur%notfound;
	SELECT MAX(Discharge_Date) into d_final
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND extract(year from POST_SURGERY_WARD.Discharge_Date)=2005;
	
	LOOP 
	exit when d_final=d_start;
	cnt_visit:=cnt_visit+1;
	
	SELECT MIN(G_Admission_Date) into d_start
	FROM GENERAL_WARD
	WHERE Patient_Name=pname AND G_Admission_Date>=d_end;

	SELECT MIN(Discharge_Date) into d_end
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date>d_start;

	SELECT Patient_Type, Scount into ptype, num_surgery
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date=d_end;
	
	SELECT S_Admission_Date into d_scrn
	FROM SCREENING_WARD
	WHERE Patient_Name=pname AND d_start<S_Admission_Date AND S_Admission_Date<d_end;
	
	SELECT Post_Admission_Date into d_post
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND d_start<Post_Admission_Date AND Post_Admission_Date<d_end;

	begin
	SELECT Pre_Admission_Date into d_pre
	FROM PRE_SURGERY_WARD
	WHERE Patient_Name=pname AND d_start<Pre_Admission_Date AND Pre_Admission_Date<d_end;
	exception	
	when no_data_found
	then d_pre:=d_post;
	end;
	
	
	IF ptype='Cardiac' AND num_surgery=1
	THEN 
	cost:=875;
	surgery_chrg:=2625;
	ELSIF ptype='Cardiac' AND num_surgery=2
	THEN 
	cost:=1925;
	surgery_chrg:=5075;
	ELSIF ptype='Neuro' AND num_surgery=1
	THEN 
	cost:=750;
	surgery_chrg:=4250;
	ELSIF ptype='Neuro' AND num_surgery=2
	THEN 
	cost:=1750;
	surgery_chrg:=8250;
	ELSIF ptype='General'
	THEN 
	cost:=875;
	surgery_chrg:=1625;
	END IF;

	reimburse:=reimburse+120+(d_scrn-d_start-3)*35+119+(d_pre-d_scrn-2)*52.5+(d_post-d_pre)*85.5+(d_end-d_post)*72+surgery_chrg;
	total_cost:=total_cost+30+(d_scrn-d_start-3)*15+21+(d_pre-d_scrn-2)*17.5+(d_post-d_pre)*4.5+(d_end-d_post)*8+cost;
	d_start:=d_end;
	END LOOP;
	
	
	
	
	
	d_start:='12/31/04';
	d_end:='12/31/04';

END LOOP;
DBMS_OUTPUT.PUT_LINE('total cost: '||total_cost||' AVG cost per patient: '||total_cost/p_num ||'AVG cost reimbursed: '||reimburse/cnt_visit);
CLOSE name_cur;
END;
/
begin

Q2;

end;
/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q3
DBMS_OUTPUT.PUT_LINE('Q3');
set serveroutput on
CREATE PROCEDURE Q3

IS
CURSOR name_cur IS
	SELECT DISTINCT(Patient_Name)
	FROM GENERAL_WARD
	ORDER BY Patient_Name;
pname varchar2(30);


d_start date:='12/31/04';
d_end date:='12/31/04';
d1 date:='12/31/04';
d2 date:='12/31/04';
d_final date;

BEGIN
FOR i IN 1 .. 2 LOOP-- find the start date and end date of Bob's second visit
	SELECT MIN(G.G_Admission_Date),MIN(P.Discharge_Date) into d_start,d_end
	FROM GENERAL_WARD G, POST_SURGERY_WARD P
	WHERE G.G_Admission_Date>d_start AND P.Discharge_Date>d_end AND G.Patient_Name='Bob' AND P.Patient_Name='Bob';
END LOOP;

OPEN name_cur;
LOOP
fetch name_cur into pname;
exit when name_cur%notfound;
SELECT MAX(Discharge_Date) into d_final
FROM POST_SURGERY_WARD
WHERE Patient_Name=pname;
	LOOP
	exit when d2>=d_final;
		
		SELECT MIN(G.G_Admission_Date), MIN(Discharge_Date) into d1,d2
		FROM GENERAL_WARD G, POST_SURGERY_WARD P
		WHERE G.G_Admission_Date>d1 AND P.Discharge_Date>d2 AND G.Patient_Name=pname AND P.Patient_Name=pname;
		
		IF d1=d_start AND d2<d_end
		THEN DBMS_OUTPUT.PUT_LINE('Patient Name: '||pname||' Date: '||d1||'~'||d2);
		
		END IF;

	END LOOP;

d1:='12/31/04';
d2:='12/31/04';

END LOOP;


END;
/
exec Q3
--------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q4
exec DBMS_OUTPUT.PUT_LINE('Q4');
set serveroutput on

--------------------------------------------
CREATE TABLE query4
(
start_date date,
end_date date,
s_cnt number,
s_name varchar2(30)
);
CREATE TABLE surgeon_count
(
name varchar2(30),
num number
);
	insert into surgeon_count values('Dr.Smith',0);
	insert into surgeon_count values('Dr.Charles',0);
	insert into surgeon_count values('Dr.Richards',0);
	insert into surgeon_count values('Dr.Gower',0);
	insert into surgeon_count values('Dr.Taylor',0);
	insert into surgeon_count values('Dr.Rutherford',0);

---------------------------------------------

CREATE PROCEDURE Q4
IS



CURSOR x_cur IS--select surgery date(include first and second) and their surgeon name
	SELECT*
	FROM
	(	
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='General' AND (S.Name='Dr.Smith' OR S.Name='Dr.Richards')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date+2 AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date+2 AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
	ORDER BY d_surgery
	)X
	WHERE X.d_surgery>='1/1/05' AND X.d_surgery<='12/31/05';

pname varchar2(30);----
d1 date;------------------for cursor
s_name varchar2(30);---


s_name2 varchar2(30);
s_ct number:=0;--total surgeries
x1 number:=0;--smith
x2 number:=0;--charles
x3 number:=0;--richards
x4 number:=0;--gower
x5 number:=0;--taylor
x6 number:=0;--rutherford	

d_cur date;
d_start date;

BEGIN

	SELECT MIN(X.d_surgery) INTO d_cur
	FROM
	(	
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='General' AND (S.Name='Dr.Smith' OR S.Name='Dr.Richards')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date+2 AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Cardiac' AND (S.Name='Dr.Gower' OR S.Name='Dr.Charles')
	UNION
	SELECT P.Patient_Name, P.Post_Admission_Date+2 AS d_surgery, S.Name
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE P.Scount=2 AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Neuro' AND (S.Name='Dr.Taylor' OR S.Name='Dr.Rutherford')
	ORDER BY d_surgery
	)X
	WHERE X.d_surgery>='1/1/05' AND X.d_surgery<='12/31/05';

d_start:=d_cur;


OPEN x_cur;
LOOP
fetch x_cur into pname,d1,s_name;
exit when x_cur%notfound;
	IF d_cur=d1
	THEN
		s_ct:=s_ct+1;--count surgery numbers
		IF s_name='Dr.Smith' THEN x1:=x1+1;
		ELSIF s_name='Dr.Charles' THEN x2:=x2+1;
		ELSIF s_name='Dr.Richards' THEN x3:=x3+1;
		ELSIF s_name='Dr.Gower' THEN x4:=x4+1;
		ELSIF s_name='Dr.Taylor' THEN x5:=x5+1;
		ELSIF s_name='Dr.Rutherford' THEN x6:=x6+1;
		END IF;
		d_cur:=d_cur+1;
	
	ELSIF d_cur=d1+1
	THEN
		s_ct:=s_ct+1;--count surgery numbers
		IF s_name='Dr.Smith' THEN x1:=x1+1;
		ELSIF s_name='Dr.Charles' THEN x2:=x2+1;
		ELSIF s_name='Dr.Richards' THEN x3:=x3+1;
		ELSIF s_name='Dr.Gower' THEN x4:=x4+1;
		ELSIF s_name='Dr.Taylor' THEN x5:=x5+1;
		ELSIF s_name='Dr.Rutherford' THEN x6:=x6+1;
		END IF;
		
		
	
	ELSIF d1>d_cur
	THEN
		UPDATE surgeon_count SET num=x1 WHERE name='Dr.Smith';
		UPDATE surgeon_count SET num=x2 WHERE name='Dr.Charles';
		UPDATE surgeon_count SET num=x3 WHERE name='Dr.Richards';
		UPDATE surgeon_count SET num=x4 WHERE name='Dr.Gower';
		UPDATE surgeon_count SET num=x5 WHERE name='Dr.Taylor';
		UPDATE surgeon_count SET num=x6 WHERE name='Dr.Rutherford';
		
		declare
		CURSOR z_cur IS
		SELECT name
		FROM surgeon_count
		WHERE num=(select MAX(s.num) FROM surgeon_count s);
		begin
		OPEN z_cur;
		LOOP
		fetch z_cur into s_name2;	
		exit when z_cur%notfound;
		insert into query4 values(d_start,d_cur-1,s_ct,s_name2);	
		END LOOP;
		CLOSE z_cur;
		end;

		d_start:=d1;
		s_ct:=0;
		x1:=0;
		x2:=0;
		x3:=0;
		x4:=0;
		x5:=0;
		x6:=0;
		s_ct:=s_ct+1;--count surgery numbers, restart

		IF s_name='Dr.Smith' THEN x1:=x1+1;
		ELSIF s_name='Dr.Charles' THEN x2:=x2+1;
		ELSIF s_name='Dr.Richards' THEN x3:=x3+1;
		ELSIF s_name='Dr.Gower' THEN x4:=x4+1;
		ELSIF s_name='Dr.Taylor' THEN x5:=x5+1;
		ELSIF s_name='Dr.Rutherford' THEN x6:=x6+1;
		END IF;
		d_cur:=d1+1;
		
	
	
	
	END IF;

END LOOP;

IF d_cur=d1 OR d_cur=d1+1
THEN

	UPDATE surgeon_count SET num=x1 WHERE name='Dr.Smith';
	UPDATE surgeon_count SET num=x2 WHERE name='Dr.Charles';
	UPDATE surgeon_count SET num=x3 WHERE name='Dr.Richards';
	UPDATE surgeon_count SET num=x4 WHERE name='Dr.Gower';
	UPDATE surgeon_count SET num=x5 WHERE name='Dr.Taylor';
	UPDATE surgeon_count SET num=x6 WHERE name='Dr.Rutherford';	
	declare
	CURSOR y_cur IS
	SELECT name
	FROM surgeon_count
	WHERE num=(select MAX(s.num) FROM surgeon_count s);
	begin
	OPEN y_cur;
	LOOP
	fetch y_cur into s_name2;	
	exit when y_cur%notfound;
	insert into query4 values(d_start,d1,s_ct,s_name2);	
	END LOOP;
	CLOSE y_cur;
	end;
END IF;



END;
/


begin

Q4;

end;
/
select* 
from query4
order by s_cnt DESC;

drop table query4;
drop table surgeon_count;
----------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q5
exec DBMS_OUTPUT.PUT_LINE('Q5');
set serveroutput on
CREATE PROCEDURE Q5

IS
d date;
CURSOR d_cur IS -- this select the date that patient underwent second surgery in POST_S_W which is performed by Dr.Gower(C) or Dr.Taylor(N) in April
	SELECT P.Post_Admission_Date+2
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE '3/31/05'<P.Post_Admission_Date+2 AND P.Post_Admission_Date+2<'5/1/05' AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Cardiac' AND S.Name='Dr.Gower'
	UNION
	SELECT P.Post_Admission_Date+2
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE '3/31/05'<P.Post_Admission_Date+2 AND P.Post_Admission_Date+2<'5/1/05' AND P.Post_Admission_Date+2=Surgery_Date AND P.Patient_Type='Neuro' AND S.Name='Dr.Taylor'
	UNION	
	SELECT P.Post_Admission_Date
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE '3/31/05'<P.Post_Admission_Date AND P.Post_Admission_Date+2<'5/1/05' AND P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Cardiac' AND S.Name='Dr.Gower'
	UNION
	SELECT P.Post_Admission_Date
	FROM POST_SURGERY_WARD P, Surgeon_Schedule S
	WHERE '3/31/05'<P.Post_Admission_Date AND P.Post_Admission_Date+2<'5/1/05' AND P.Post_Admission_Date=Surgery_Date AND P.Patient_Type='Neuro' AND S.Name='Dr.Taylor';




d_start date;--record the start_date of each interval
d_end date:='4/30/05';

BEGIN

d_start:='4/1/05';
OPEN d_cur;
LOOP 
fetch d_cur into d;
exit when d_cur%notfound;
	IF d!=d_start
	THEN 
	DBMS_OUTPUT.PUT_LINE(d_start||'~'||(d-1));
	d_start:=d+1;	
	ELSIF d=d_start
	THEN
	d_start:=d+1;
	END IF;
END LOOP;

IF d<d_end--check the last interval if exists
THEN DBMS_OUTPUT.PUT_LINE(d+1||'~'||d_end);
END IF;



END;
/
exec Q5
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q6
exec DBMS_OUTPUT.PUT_LINE('Q6');

CREATE PROCEDURE Q6
IS


pname varchar2(30);
d_start date;
d_end date;
d_final date;
cnt_visit number:=0;
d_scrn date;
d_pre date;
d_post date;
ptype varchar2(10);
num_surgery number;
surgery_chrg number;
reimburse number:=0;
b_pre_ad date;

BEGIN

SELECT MIN(Post_Admission_Date) into b_pre_ad--b_pre_ad+2=the date bob underwent his second surgery
FROM POST_SURGERY_WARD 
WHERE Patient_Name='Bob' AND Post_Admission_Date>'1/1/05';--'4/1/05'is the admission date of Bob of his third visit

declare
	CURSOR name_cur IS
	SELECT Patient_Name, Discharge_Date
	FROM POST_SURGERY_WARD
	WHERE Discharge_Date>=b_pre_ad+2 AND Discharge_Date<b_pre_ad+5 AND Patient_Name!='Bob'
	ORDER BY Patient_Name;
begin

OPEN name_cur;
LOOP
fetch name_cur into pname, d_end;
exit when name_cur%notfound;
	
	SELECT Post_Admission_Date into d_post
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date=d_end;

	SELECT MAX(G_Admission_Date) into d_start
	FROM GENERAL_WARD
	WHERE Patient_Name=pname AND G_Admission_Date<d_end;
	
	begin
	SELECT Pre_Admission_Date into d_pre
	FROM PRE_SURGERY_WARD
	WHERE Patient_Name=pname AND d_start<Pre_Admission_Date AND Pre_Admission_Date<d_end;
	exception	
	when no_data_found
	then d_pre:=d_post;
	end;
	
	SELECT MAX(S_Admission_Date) into d_scrn
	FROM SCREENING_WARD
	WHERE Patient_Name=pname AND S_Admission_Date<d_end;
	
	SELECT MIN(G_Admission_Date) into d_start
	FROM GENERAL_WARD
	WHERE Patient_Name=pname AND G_Admission_Date<d_end;


	SELECT Patient_Type, Scount into ptype, num_surgery
	FROM POST_SURGERY_WARD
	WHERE Patient_Name=pname AND Discharge_Date=d_end;
	
	
	
	IF ptype='Cardiac' AND num_surgery=1
	THEN surgery_chrg:=2625;
	ELSIF ptype='Cardiac' AND num_surgery=2
	THEN surgery_chrg:=5075;
	ELSIF ptype='Neuro' AND num_surgery=1
	THEN surgery_chrg:=4250;
	ELSIF ptype='Neuro' AND num_surgery=2
	THEN surgery_chrg:=8250;
	ELSIF ptype='General'
	THEN surgery_chrg:=1625;
	END IF;

	reimburse:=120+(d_scrn-d_start-3)*35+119+(d_pre-d_scrn-2)*52.5+(d_post-d_pre)*85.5+(d_end-d_post)*72+surgery_chrg;
	

	DBMS_OUTPUT.PUT_LINE('Patient Name: '||pname||' Total cost reimbursed: '||reimburse);
	
	reimburse:=0;

END LOOP;

end;
END;
/

begin

Q6;

end;
/
---------------------
exec DBMS_OUTPUT.PUT_LINE('Q7');
SELECT P.Patient_name, P.Post_Admission_Date, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Patient_Type='Cardiac' AND '4/9/05'<=P.Post_Admission_Date AND P.Post_Admission_Date<'4/16/05' AND S.Surgery_Date=P.Post_Admission_Date AND (S.Name='Dr.Charles'OR S.Name='Dr.Gower')
UNION
SELECT P.Patient_Name, P.Post_Admission_Date+2, S.Name
FROM POST_SURGERY_WARD P, Surgeon_Schedule S
WHERE P.Patient_Type='Cardiac' AND '4/9/05'<=P.Post_Admission_Date+2 AND P.Post_Admission_Date+2<'4/16/05' AND S.Surgery_Date=P.Post_Admission_Date+2 AND (S.Name='Dr.Charles'OR S.Name='Dr.Gower')
UNION
SELECT P.Patient_name, P.Post_Admission_Date, D.Name
FROM POST_SURGERY_WARD P, DR_Schedule D
WHERE P.Patient_Type='Cardiac' AND '4/9/05'<=P.Post_Admission_Date AND P.Post_Admission_Date<'4/16/05' AND D.Duty_Date=P.Post_Admission_Date AND D.Ward='Surgery'
UNION
SELECT P.Patient_Name, P.Post_Admission_Date+2, D.Name
FROM POST_SURGERY_WARD P, DR_Schedule D
WHERE P.Patient_Type='Cardiac' AND '4/9/05'<=P.Post_Admission_Date+2 AND P.Post_Admission_Date+2<'4/16/05' AND D.Duty_Date=P.Post_Admission_Date+2 AND D.Ward='Surgery'
;
-------------------
set serveroutput on
exec DBMS_OUTPUT.PUT_LINE('Q8');
CREATE PROCEDURE Q8

IS
d_start date:='12/31/04';
d_end date:='12/31/04';
d_scr date;
d_pre date;
d_post date;
d date;--record of the start date of each interval
d1 date;

w_name varchar2(20);


BEGIN

FOR i IN 1 .. 3 LOOP-- find the start date and end date of Bob's third visit
	SELECT MIN(G.G_Admission_Date),MIN(P.Discharge_Date) into d_start,d_end
	FROM GENERAL_WARD G, POST_SURGERY_WARD P
	WHERE G.G_Admission_Date>d_start AND P.Discharge_Date>d_end AND G.Patient_Name='Bob' AND P.Patient_Name='Bob';
END LOOP;
	SELECT Post_Admission_Date into d_post
	FROM POST_SURGERY_WARD
	WHERE Patient_Name='Bob' AND Discharge_Date=d_end;
	
	begin
	SELECT Pre_Admission_Date into d_pre
	FROM PRE_SURGERY_WARD
	WHERE Patient_Name='Bob' AND d_start<Pre_Admission_Date AND Pre_Admission_Date<d_end;
	exception
	when no_data_found
	then d_pre:=d_post;
	end;

	SELECT S_Admission_Date into d_scr
	FROM SCREENING_WARD
	WHERE Patient_Name='Bob' AND d_start<S_Admission_Date AND S_Admission_Date<d_end;

DECLARE 
CURSOR x_cur IS
	SELECT Ward, Duty_Date
	FROM DR_Schedule
	WHERE Name='Adams' AND d_start<=Duty_Date AND Duty_Date<=d_end
	ORDER BY Duty_Date;
begin
d:=d_start;

OPEN x_cur;
LOOP 
fetch x_cur into w_name, d1;
exit when x_cur%notfound;
	IF d_start<=d1 AND d1<d_scr AND w_name='GENERAL_WARD'
	THEN	IF d!=d1 
		THEN 
		DBMS_OUTPUT.PUT_LINE(d||'~'||(d1-1)); 
		d:=d1+1; 
		END IF;
	ELSIF d_scr<=d1 AND d1<d_pre AND w_name='SCREENING_WARD'
	THEN	IF d!=d1
		THEN
		DBMS_OUTPUT.PUT_LINE(d||'~'||(d1-1)); 
		d:=d1+1;
		END IF;
	ELSIF d_pre<=d1 AND d1<d_post AND w_name='PRE_SURGERY_WARD'
	THEN	IF d!=d1
		THEN
		DBMS_OUTPUT.PUT_LINE(d||'~'||(d1-1)); 
		d:=d1+1;
		END IF;
	ELSIF d_post<=d1 AND d1<d_end AND w_name='POST_SURGERY_WARD'
	THEN	IF d!=d1
		THEN
		DBMS_OUTPUT.PUT_LINE(d||'~'||(d1-1)); 
		d:=d1+1;
		END IF;
	END IF;

END LOOP;

	IF d!=d1--for the last day
	THEN
	DBMS_OUTPUT.PUT_LINE(d||'~'||(d1)); 
	d:=d1+1;
	END IF;

end;

END;
/
exec Q8

------------
exec DBMS_OUTPUT.PUT_LINE('Q9');
CREATE PROCEDURE Q9

IS
d_start date:='12/31/04';
d_end date:='12/31/04';
d_final date;
days number:=0;
b_p number;
p_date date;
d1 date; --record the date of the begining of the wanted interval

BEGIN
SELECT MAX(Discharge_Date) into d_final
FROM POST_SURGERY_WARD
WHERE Patient_Name='Bob';

LOOP
exit when d_end=d_final;
SELECT MIN(G.G_Admission_Date), MIN(P.Discharge_Date) into d_start, d_end
FROM GENERAL_WARD G, POST_SURGERY_WARD P
WHERE G.Patient_Name='Bob' AND P.Patient_Name='Bob' AND G.G_Admission_Date>d_start AND P.Discharge_Date>d_end;
	DECLARE 
	CURSOR x_cur IS
		SELECT BP , Pdate
		FROM Patient_Chart
		WHERE Patient_Name='Bob' AND d_start<=Pdate AND Pdate<=d_end
		ORDER BY Pdate;
	begin
	OPEN x_cur;
	d1:=d_start;
	LOOP
	fetch x_cur into b_p, p_date;
	exit when x_cur%notfound;
	IF 110<=b_p AND b_p<=140
		THEN days:=days+1;
	ELSIF b_p<110 OR b_p>140
		THEN
		IF days>=2
		THEN DBMS_OUTPUT.PUT_LINE(p_date-days||'~'||(p_date-1)||' length: '||days);
		END IF;
		days:=0;
	END IF;
	END LOOP;
	end;
IF days>=2
THEN DBMS_OUTPUT.PUT_LINE((p_date-days+1)||'~'||(p_date)||' length: '||days);
END IF;
days:=0;
END LOOP;
END;
/

exec Q9
