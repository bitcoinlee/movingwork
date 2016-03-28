%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%format;
options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
libname nfcs "D:\数据\201510";

proc sql;
	create table person_nov as select
	T1.sorgcode label = "机构代码"
	,(case when T2.dgetdate is null then 0 else 1 end) as loan_flag label = "是否存在业务"
	from nfcs.Sino_person_certification(keep = sorgcode spin dgetdate where = (datepart(dgetdate)>mdy(11,1,2015))) as T1
	left join nfcs.sino_loan(keep = sorgcode spin dgetdate where = (datepart(dgetdate)>mdy(11,1,2015))) as T2
	on T1.spin = T2.spin and T1.sorgcode = T2.sorgcode
;
quit;

proc sql;
	create table _person_nov as select
	T1.sorgcode label = "机构代码"
	,T2.sorgname label = "机构名称"
	,count(loan_flag) as total label = "总入库人数"
	,sum(loan_flag) as loan_person label = "有业务人数"
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
shortname = 机构简称
;
run;

proc sort data = _person_nov;
by descending total;
run;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\朱总\NFCS新增入库人数情况分析_20151120.xlsx";
data xls.sheet1(dblabel = yes);
set _person_nov;
run;
libname xls clear;
