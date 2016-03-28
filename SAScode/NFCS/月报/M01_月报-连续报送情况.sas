%include "E:\�½��ļ���\SAS\������.sas";
%include "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%format;

data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then
call symput('chkmonth',cat(put(year(today())-1,$4.),put(12,$2.)));
else call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%put x=&chkmonth.;
%let today = %sysfunc(today(),YYMMDDN8.);
%ChkFile(E:\�½��ļ���\&chkmonth.\NFCS);
%ChkFile(E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&chkmonth.);

options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
%LET END=MDY(11,30,2015);
%LET START=MDY(8,1,2015);

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set nfcs.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="��������"
		,T2.sorgname as sorgname label="��������"
/*		,T1.sareacode label="����ʡ�д���"*/
		from sino_org2 as T1 
		left join nfcs.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q"
;
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;

proc sql;
	create table ruku as select
		sorgcode label =  "��������"
		,intnx('month',datepart(dgetdate),0,'b') as yearmonth format=yymmn6. informat = yymmn6. label = "����ʱ��"
/*		,put(datepart(dgetdate),yymmn6.) as yearmonth label = "����ʱ��"*/
		,count(distinct iloanid) as loan_count label = "����ҵ���¼��"
	from nfcs.sino_loan(keep = sorgcode saccount dgetdate iloanid WHERE=(&START. <= datepart(dgetdate) <= &END. and SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) 
	group by sorgcode, calculated yearmonth
	order by sorgcode,calculated yearmonth desc
;
quit;

proc sql;
	create table _ruku as select
	T1.*
	,T2.*
	from _sino_org as T1
	left join ruku as T2
	on T1.sorgcode = T2.sorgcode 
	where T2.yearmonth is not null
	order by sorgcode,yearmonth desc
;
quit;

proc transpose data = ruku out = _ruku(drop = _name_ _label_);
id yearmonth;
var loan_count;
by sorgcode;
run;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&chkmonth.\�±�-��������ҵ�����.xlsx";
	data xls.sheet1(dblabel=yes);
	set _ruku;
RUN;
libname xls clear;
