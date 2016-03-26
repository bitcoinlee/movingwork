/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
data _null_;
ismonth = month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.), "0" ,put(month(today()),$1.)));
else call symput('chkmonth',cat(put(year(today()),$4.), put(month(today()),$2.)));
run;
data _null_;
ismonth = month(today());
if 1<ismonth<10 then 
call symput('currmonth',cat(put(year(today()),$4.), "年" ,put(month(today()),$1.), "月" ));
else call symput('currmonth',cat(put(year(today()),$4.), "年" ,put(month(today()),$2.), "月" ));
run;
libname nfcs "D:\数据\&chkmonth.\";
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";
%FORMAT;



proc sql;
	create table chaxun_liang as select
		T1.STOPORGCODE label = "机构代码"
/*		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "机构简称"*/
		,T2.sorgname
		,sum(T1.ISEARCHLIMIT) as ISEARCHLIMIT label = "查询量限制（包括下级机构）"
	from nfcs.sino_org(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2 on
	T1.STOPORGCODE = T2.sorgcode
	group by T1.STOPORGCODE
;
quit;

data chaxun_liang;
	set chaxun_liang;
	if STOPORGCODE = lag(STOPORGCODE) then delete;
rename 
STOPORGCODE = sorgcode
;
run;


proc sql;
	create table chaxun_type as select
		sorgcode
		,PUT(sorgcode,$SHORT_CD.) AS SHORT_NM label = "机构简称"
		,(case when sum(IPLATE) = 4 then "网络金融版" when sum(IPLATE) = 3 then "特殊交易版" end) as cx_type label = "查询权限类型"
/*		,(case when sum(IPLATE) = 3 then "√" else "" end) as cx_spec label = "特殊交易"*/
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by SHORT_NM
;
quit;

proc sql;
	create table chaxun_list as select
		T1.*
		,(case when T2.cx_type = "" then  "未开通权限" else T2.cx_type end) as cx_type label = "查询权限类型"
		from chaxun_liang as T1
		left join chaxun_type as T2
		on T1.sorgcode = T2.sorgcode
	;
quit;

data chaxun_list;
	set chaxun_list;
		if sorgcode = lag(sorgcode) then delete;
	if cx_type = "" then cx_type = "未开通权限";
run;

/*libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\临时性工作\市场\孔佳斌\查询权限清单_&chkmonth..xlsx";*/
/*data xls.sheet1(dblabel = yes);*/
/*set chaxun_list;*/
/*run;*/
/*libname xls clear;*/

PROC EXPORT DATA=Work.chaxun_list
OUTFILE="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\BD\孔佳斌\查询权限清单_&chkmonth..csv"
DBMS= csv
label
REPLACE;
RUN;
