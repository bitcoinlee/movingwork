%include "E:\�½��ļ���\SAS\������.sas";
%include "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%format;
options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
libname nfcs "D:\����\201510";

proc sql;
	create table person_nov as select
	T1.sorgcode label = "��������"
	,(case when T2.dgetdate is null then 0 else 1 end) as loan_flag label = "�Ƿ����ҵ��"
	from nfcs.Sino_person_certification(keep = sorgcode spin dgetdate where = (datepart(dgetdate)>mdy(11,1,2015))) as T1
	left join nfcs.sino_loan(keep = sorgcode spin dgetdate where = (datepart(dgetdate)>mdy(11,1,2015))) as T2
	on T1.spin = T2.spin and T1.sorgcode = T2.sorgcode
;
quit;

proc sql;
	create table _person_nov as select
	T1.sorgcode label = "��������"
	,T2.sorgname label = "��������"
	,count(loan_flag) as total label = "���������"
	,sum(loan_flag) as loan_person label = "��ҵ������"
	from person_nov as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
	group by T1.sorgcode
;
quit;

data _person_nov;
retain sorgcode sorgname shortname;
	set _person_nov;
	if sorgcode = lag(sorgcode) then delete;
	shortname = put(sorgcode,$short_cd.);
label
shortname = �������
;
run;

proc sort data = _person_nov;
by descending total;
run;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\NFCS������������������_20151120.xlsx";
data xls.sheet1(dblabel = yes);
set _person_nov;
run;
libname xls clear;
