options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
libname nfcs "D:\����\201512";
%INCLUDE "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%include "E:\�½��ļ���\SAS\������.sas";
%format;

%let cunliang_end = mdy(7,31,2014);
%let cunliang_start = mdy(8,1,2013);
%let xinzeng_start = intnx('month',&cunliang_end.,6,'e');

PROC SORT DATA=nfcs.SINO_LOAN(KEEP= iloanid spin sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=sino_loan nodupkey;
	BY iloanid;
RUN;
proc sort data = nfcs.sino_person(keep = spin sorgcode SMOBILETEL dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_person nodupkey;
	by spin descending dgetdate;
run;
data sino_person;
	set sino_person;
	if spin = lag(spin) then delete;
drop
sorgcode
dgetdate
;
run;
proc sort data = nfcs.sino_person_certification(keep = spin sorgcode sname scerttype scertno dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_person_certification nodupkey;
	by spin descending dgetdate;
run;
data sino_person_certification;
	set sino_person_certification;
	if spin = lag(spin) then delete;
	if scerttype = '0';
drop
sorgcode
scerttype
dgetdate
;
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
		left join nfcs.sino_person_certification as T2
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



/*��������*/

proc sort data = nfcs.sino_loan(KEEP = iloanid spin sname scerttype scertno ddateopened dbillingdate ddateclosed smonthduration sorgcode istate Iamountpastdue30 Iamountpastdue60 Iamountpastdue90 Iamountpastdue180 WHERE = (SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_loan;
by iloanid descending dbillingdate;
run;
/*ÿ��ȡ���һ�ʻ����¼*/
data sino_loan;
	set sino_loan;
	yuefen = put(datepart(dbillingdate),yymmn6.);
	if scerttype = '0' and datepart(ddateclosed) > &cunliang_end. and datepart(ddateopened) <= &xinzeng_start.;
run;
data sino_loan;
	set sino_loan;
	if iloanid = lag(iloanid) and yuefen = lag(yuefen) then delete;
drop
sorgcode
scerttype
;
run;
proc sort data = sino_loan;
by spin ddateopened dbillingdate;
run;


/*�����˻���������*/
proc sql;
	create table shzx_ACCM as select
		spin
		,sname 
		,scertno
		,intnx("month",datepart(ddateopened),0,'b') as ddateopened format = yymmn6.
		,intnx("month",datepart(dbillingdate),0,'b') as yuefen format = yymmn6.
		,max((case when input(smonthduration,4.)=. or input(smonthduration,4.)= 0 then intck('month',datepart(ddateopened),datepart(ddateclosed)) else input(smonthduration,4.) end)) as smonthduration
		,(case when sum(sum(Iamountpastdue30),sum(Iamountpastdue60),sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue30
		,(case when sum(sum(Iamountpastdue60),sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue60
		,(case when sum(sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue90
	from sino_loan
/*(KEEP= iloanid spin sname scerttype scertno ddateopened dbillingdate sorgcode istate Iamountpastdue30 Iamountpastdue60 Iamountpastdue90 Iamountpastdue180)*/
	where &cunliang_start. <= datepart(ddateopened) <= &cunliang_end. and datepart(dbillingdate) <= %sysfunc(today())
	group by yuefen,spin
	order by yuefen,spin
;
quit;

data shzx_ACCM;
	set shzx_ACCM;
	if yuefen = lag(yuefen) and spin = lag(spin) then delete;
label
sName = ����
scertno = ֤������
ddateopened = �Ŵ�ʱ��
smonthduration = �Ŵ�����
yuefen = �����·�
Iamountpastdue30 = �Ƿ����30����������_�����˻�
Iamountpastdue60 = �Ƿ����60����������_�����˻�
Iamountpastdue90 = �Ƿ����90����������_�����˻�
;
run;

/*�������˻���������*/
proc sql;
	create table shzx_new as select
		spin
		,sname 
		,scertno
		,intnx("month",datepart(ddateopened),0,'b') as ddateopened format = yymmn6.
		,intnx("month",datepart(dbillingdate),0,'b') as yuefen format = yymmn6.
		,(case when input(smonthduration,4.)=. or input(smonthduration,4.)= 0 then intck('month',datepart(ddateopened),datepart(ddateclosed)) else input(smonthduration,4.) end) as smonthduration
		,(case when sum(sum(Iamountpastdue30),sum(Iamountpastdue60),sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue30_new
		,(case when sum(sum(Iamountpastdue60),sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue60_new
		,(case when sum(sum(Iamountpastdue90),sum(Iamountpastdue180)) > 0 then 1 else 0 end) as Iamountpastdue90_new
from sino_loan
	where &cunliang_end. < datepart(ddateopened) <= &xinzeng_start.
	group by yuefen,spin
	order by yuefen,spin
;
quit;

data shzx_new;
	set shzx_new;
	if yuefen = lag(yuefen) and spin = lag(spin) then delete;
label
sName = ����
scertno = ֤������
ddateopened = �Ŵ�ʱ��
smonthduration = �Ŵ�����
yuefen = �����·�
Iamountpastdue30_new = �Ƿ����30����������_�������˻�
Iamountpastdue60_new = �Ƿ����60����������_�������˻�
Iamountpastdue90_new = �Ƿ����90����������_�������˻�
;
run;





proc sql noprint;
	select count(distinct yuefen) into :n
	from shzx_accm
;
quit;
data _null_;
call symput('yuefen_n',compress('yuefen'||&n.));
run;
proc sql noprint;
	select distinct yuefen into :yuefen1-:&yuefen_n.
	from shzx_accm
;
quit;

/*��������*/
proc sql;
	create table shzx_person as select
		T4.SPIN
		,T4.sname label = "����"
		,put(md5(T4.scertno),$hex32.) as scertno_md5 label = "���֤_md5"
		,(case when substr(T2.SMOBILETEL,1,3) in ('133','153','170','180','181','189') then 0 else 1 end) as mobile_flag label = "�Ƿ�����ֻ�"
		,T1.DDATEFIRSTOPENED label = "�״�ʱ��"
		,(case when input(T3.smonthduration,4.)=. or input(T3.smonthduration,4.)= 0 then intck('month',datepart(T3.ddateopened),datepart(T3.ddateclosed)) else input(T3.smonthduration,4.) end) as smonthduration label = "����ʱ�����£�"
		,(case when T1.IMAXINUMTERMPASTDUE >= 3 then 1 else 0 end) as bad_flag label = "�û���ʶ"
		,"����90����������" as bad_defination label = "�û�����"
	from nfcs.Sino_person_loan_collect as T1
	left join sino_person as T2
	on T1.ipersonid = T2.spin
	left join sino_loan as T3
	on T1.ipersonid = T3.spin
	left join sino_person_certification as T4
	on T1.ipersonid = T4.spin
	where T1.ILOANCOUNT > 0 and &cunliang_start. <= datepart(T1.DDATEFIRSTOPENED) <= &cunliang_end. and &cunliang_start. <= datepart(T3.DDATEOPENED) <= &cunliang_end. and T4.scertno ^= ""
/*and T3.smonthduration > 0*/
;
quit;

data shzx_person;
	set shzx_person;
	if spin = lag(spin) then delete;
drop
spin
;
run;

proc sort data = shzx_person;
by scertno_new;
run;

/*���*/
libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\��������\��������-��֤����-20151212.xlsx";
	data xls.sheet1(dblabel = yes);
		set shzx_person;
	run;
libname xls clear;

/*libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\�������Ų�������.xlsx";*/
/*	data xls.sheet1(dblabel=yes);*/
/*		set Tianyi_test;*/
/*		if _n_ <= 500000;*/
/*	run;*/
/*libname xls clear;*/

