options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
%INCLUDE "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%include "E:\�½��ļ���\SAS\������.sas";
%format;

PROC SORT DATA=mylib.SINO_LOAN(KEEP= iloanid spin sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=sino_loan nodupkey;
	BY iloanid;
RUN;
proc sort data = mylib.sino_person(keep = spin sorgcode SMOBILETEL WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_person nodupkey;
	by spin;
run;

/**/
proc sql;
	create table tianyi_test as select
		sname label = '����'
		,(case when scerttype = '0' then '���֤' else '����֤��' end) as scerttype label = '֤������'
		,scertno label = '֤������'
		,(case when T1.SMOBILETEL = '' then '���ֻ�����' when substr(T1.SMOBILETEL,1,3) in ('133','153','170','180','181','189')
		then '���ź���' else '������Ӫ��' end) as mobile_type label = '��������'
		from sino_person as T1
		left join mylib.sino_person_certification as T2
		on T1.spin = T2.spin
		order by (case when mobile_type = '���ź���' then 1 else 2 end)
	;
quit;



/**/
proc sql;
	create table tianyi as select
		T1.spin
		,SMOBILETEL
		,T2.spin as spin_T2
/*		,(case when T1.SMOBILETEL = '' then '���ֻ�����' when substr(T1.SMOBILETEL,1,3) in ('133','153','170','180','181','189')*/
/*		then '���ź���' else '������Ӫ��' end) as mobile_type label = '��������'*/
/*		,(case when T2.spin = '' then 'δ����ҵ��' else '�ѿ���ҵ��' end) as exist_loan label = '�Ƿ����ҵ��'*/
		from sino_person as T1
		left join sino_loan as T2
		on T1.spin = T2.spin
	;
quit;

data tianyi;
	set tianyi;
	if spin = lag(spin) then delete;
run;

data tianyi_new;
	set tianyi;
	if SMOBILETEL = '' then mobile_type = 'δ�����ֻ�����';
	else if substr(SMOBILETEL,1,3) in ('133','153','170','180','181','189') then mobile_type = '���ź���';
	else mobile_type = '������Ӫ��';
	if spin_T2 = '' then exist_loan = 'δ����ҵ��';
	else exist_loan = '�ѿ���ҵ��';
run;

proc sql;
	create table _tianyi as select
		mobile_type
		,exist_loan
		,count(*) as count
		from tianyi_new
		group by exist_loan,mobile_type
	;
quit;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\��������.xlsx";
	data xls.sheet1;
		set _tianyi;
	run;
libname xls clear;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\�������Ų�������.xlsx";
	data xls.sheet1(dblabel=yes);
		set Tianyi_test;
		if _n_ <= 500000;
	run;
libname xls clear;

