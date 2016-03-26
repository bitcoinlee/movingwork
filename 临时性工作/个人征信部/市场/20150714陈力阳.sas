%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
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
%let today=%sysfunc(today(),YYMMDDN8.);
%ChkFile(E:\新建文件夹\&chkmonth.\NFCS);

options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set nfcs.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="机构代码"
		,T2.sorgname as sorgname label="机构名称"
/*		,T1.sareacode label="机构省市代码"*/
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
		sorgcode label =  "机构代码"
		,intnx('month',datepart(dgetdate),0,'b') as yearmonth format=yymmn6. informat = yymmn6. label = "报送时间"
		,count(distinct iloanid) as loan_count label = "贷款业务记录数"
	from nfcs.sino_loan(keep = sorgcode saccount dgetdate iloanid WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) 
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

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\BD\陈力阳\陈力阳_&today..xlsx";
	data xls.sheet1(dblabel=yes);
	set _ruku;
RUN;
libname xls clear;
