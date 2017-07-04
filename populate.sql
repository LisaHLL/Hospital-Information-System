

----------------------------------------------------------------------------------------------------
ALTER SESSION SET NLS_DATE_FORMAT='MM/DD/YY';
--using procedure to populate random temperature and BP. i is the number of days to populate and fecha as an argument is start-date
CREATE PROCEDURE populate_patient_chart(name IN varchar2,fecha IN date)

IS
n pls_integer;
x number;
y number;
d date;
BEGIN

	d:=fecha;
	for i IN 1.. 365 LOOP
	n := dbms_random.value(1,5);
	x:=96+n;
	y:=10*n+100;
	d:=d+1;
	insert into Patient_Chart values(name,d,x,y);	
	END LOOP;

END;
/


begin

populate_patient_chart('Alex','1/1/05');

end;
/

begin

populate_patient_chart('Alice','1/1/05');

end;
/

begin

populate_patient_chart('Bob','1/1/05');

end;
/

begin

populate_patient_chart('Charlie','1/1/05');

end;
/

begin

populate_patient_chart('David','1/1/05');

end;
/

begin

populate_patient_chart('Earl','1/1/05');

end;
/

begin

populate_patient_chart('Frank','1/1/05');

end;
/

begin

populate_patient_chart('George','1/1/05');

end;
/

begin

populate_patient_chart('Hank','1/1/05');

end;
/

begin

populate_patient_chart('Iris','1/1/05');

end;
/

begin

populate_patient_chart('Jerry','1/1/05');

end;
/

begin

populate_patient_chart('Kevin','1/1/05');

end;
/

begin

populate_patient_chart('Liz','1/1/05');

end;
/

begin

populate_patient_chart('Monica','1/1/05');

end;
/

begin

populate_patient_chart('Neo','1/1/05');

end;
/

begin

populate_patient_chart('Oscar','1/1/05');

end;
/

begin

populate_patient_chart('Penny','1/1/05');

end;
/

begin

populate_patient_chart('Quin','1/1/05');

end;
/

begin

populate_patient_chart('Ross','1/1/05');

end;
/

begin

populate_patient_chart('Sally','1/1/05');

end;
/

begin

populate_patient_chart('Ted','1/1/05');

end;
/

begin

populate_patient_chart('Ursula','1/1/05');

end;
/

begin

populate_patient_chart('Vivia','1/1/05');

end;
/

begin

populate_patient_chart('Wes','1/1/05');

end;
/

begin

populate_patient_chart('X','1/1/05');

end;
/

begin

populate_patient_chart('Y','1/1/05');

end;
/

begin

populate_patient_chart('Z','1/1/05');

end;
/
--populate general ward

CREATE PROCEDURE populate_db

IS
name varchar2(30);
Gdate date;
Ptype varchar2(10);

CURSOR x_cur IS 
	SELECT *
	FROM PATIENT_INPUT;


BEGIN

OPEN x_cur;
LOOP
fetch x_cur into name, Gdate, Ptype;
exit when x_cur%notfound;
insert into GENERAL_WARD values(name, Gdate, Ptype);
END LOOP;
CLOSE x_cur;



END;
/

insert into PATIENT_INPUT values('Bob','1/1/05','Cardiac');
insert into PATIENT_INPUT values('Alex','1/3/05','Cardiac');
insert into PATIENT_INPUT values('Alice','1/3/05','General');
insert into PATIENT_INPUT values('Charlie','1/3/05','Neuro');
insert into PATIENT_INPUT values('David','1/4/05','General');
insert into PATIENT_INPUT values('Earl','1/4/05','General');
insert into PATIENT_INPUT values('Frank','1/4/05','Cardiac');
insert into PATIENT_INPUT values('George','1/5/05','Cardiac');
insert into PATIENT_INPUT values('Hank','1/6/05','Neuro');
insert into PATIENT_INPUT values('Iris','1/7/05','Neuro');
insert into PATIENT_INPUT values('Alex','1/31/05','Cardiac');
insert into PATIENT_INPUT values('Jerry','2/1/05','General');
insert into PATIENT_INPUT values('Kevin','2/1/05','Neuro');
insert into PATIENT_INPUT values('Bob','2/1/05','Cardiac');
insert into PATIENT_INPUT values('Bob','3/1/05','Cardiac');
insert into PATIENT_INPUT values('Bob','4/1/05','Cardiac');
insert into PATIENT_INPUT values('Liz','4/1/05','Neuro');
insert into PATIENT_INPUT values('Monica','4/3/05','Cardiac');
insert into PATIENT_INPUT values('Neo','4/5/05','Neuro');
insert into PATIENT_INPUT values('Oscar','4/7/05','Cardiac');
insert into PATIENT_INPUT values('Penny','4/10/05','Neuro');
insert into PATIENT_INPUT values('Quin','4/11/05','General');
insert into PATIENT_INPUT values('Ross','4/18/05','General');
insert into PATIENT_INPUT values('Sally','4/19/05','Neuro');
insert into PATIENT_INPUT values('Ted','4/19/05','Neuro');
insert into PATIENT_INPUT values('Ursula','5/1/05','Cardiac');
insert into PATIENT_INPUT values('Vivia','5/11/05','Cardiac');
insert into PATIENT_INPUT values('Wes','5/31/05','Neuro');
insert into PATIENT_INPUT values('Kevin','7/1/05','Neuro');
insert into PATIENT_INPUT values('Quin','7/11/05','General');
insert into PATIENT_INPUT values('X','8/19/05','Neuro');
insert into PATIENT_INPUT values('Y','9/18/05','General');
insert into PATIENT_INPUT values('Z','9/19/05','Cardiac');
insert into PATIENT_INPUT values('Neo','9/30/05','Neuro');

exec populate_db






