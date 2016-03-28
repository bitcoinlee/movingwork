%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
%format;

/*申请数据验证*/
proc sql;
	create table shzx_app as select
		ipersonid as CustomerNO
		,sname as Name
		,scerttype as ID_TYPE
		,scertno as ID_NO
		,(case when sstate="2" then "A" WHEN sstate="3" then "D" end) as Status
		,put(datepart(dgetdate),yymmn6.) as yuefen
	from nfcs.sino_loan_apply(where = (SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001')))
	where sstate ne "1"
	order by yuefen,CustomerNO
;
quit;

data shzx_app;
	set shzx_app;
	if yuefen = lag(yuefen) and status = lag(status) and CustomerNO = lag(CustomerNO) then delete;
run;
proc sql;
		create table _shzx_app as select
		CustomerNO
		,Name
		,ID_TYPE
		,ID_NO
		,status
		,yuefen
		,count(status) as count
		from shzx_app
		group by yuefen,CustomerNO
;
quit;
data _shzx_app;
	set _shzx_app;
	if count > 1 then status = 'M';
	if yuefen = lag(yuefen)  and CustomerNO = lag(CustomerNO) then delete;
	drop 
	count
	;
run;

proc sql noprint;
	select count(distinct yuefen) into :n
	from _shzx_app
;
quit;
data _null_;
call symput('yuefen_last',compress('yuefen'||&n.));
run;
proc sql noprint;
	select distinct yuefen into :yuefen1-:&yuefen_last.
	from _shzx_app
;
quit;

%macro daochu(dataset);
%do i = 1 %to &n.;
	data &dataset._&&yuefen&i.;
		set &dataset.;
	if yuefen = &&yuefen&i.;
	drop
	yuefen
	;
	run;
PROC EXPORT DATA=&dataset._&&yuefen&i. OUTFILE="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\数据解读2\shzx_app_&&yuefen&i." DBMS=TAB;
DELIMITER=',';
RUN;
proc delete lib=work data = &dataset._&&yuefen&i.; 
run;
%end;
%mend;
%daochu(_shzx_app);

/*业务数据验证*/
proc sql;
	create table shzx_ACCM as select
		ipersonid as CustomerNO
		,sname as Name
		,scerttype as ID_TYPE
		,scertno as ID_NO
		,put(datepart(dbillingdate),yymmn6.) as yuefen
	from nfcs.sino_loan
	where iaccountstat not in (3,4,5) and SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001')
	order by yuefen,CustomerNO
;
quit;

data shzx_ACCM;
	set shzx_ACCM;
	if yuefen = lag(yuefen) and CustomerNO = lag(CustomerNO) then delete;
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


%macro daochu_accm(dataset);
%do i = 1 %to &n.;
	data &dataset._&&yuefen&i.;
		set &dataset.;
	if yuefen = &&yuefen&i.;
	drop
	yuefen
	;
	run;
PROC EXPORT DATA=&dataset._&&yuefen&i. OUTFILE="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\数据解读2\shzx_accm_&&&yuefen&&i..txt" DBMS=TAB;
DELIMITER=',';
RUN;
proc delete lib=work data = &dataset._&&yuefen&i.; 
run;
%end;
%mend;

%daochu_accm(shzx_accm);

/*数据条数*/
proc sql;
	create table qingdan_app as select
		yuefen
		,count(*) as count
	from _shzx_app
	group by yuefen
;
quit;
proc sql;
	create table qingdan_accm as select
		yuefen
		,count(*) as count
	from Shzx_accm
	group by yuefen
;
quit;
libname xls excel "E:\新建文件夹\201510\数字解读验证\验证数据提取单-附件.xlsx";
data xls.Qingdan_app(dblabel=yes);
	set Qingdan_app;
run;
data xls.qingdan_accm(dblabel=yes);
	set qingdan_accm;
run;
libname xls clear;


	




