data _null_;
ismonth = month(today());
if 2<ismonth<11 then call symput('upmonth',cat(put(year(today()),$4.), "0" ,put(month(today())-1,$1.)));
else if ismonth >= 11 then call symput('upmonth',cat(put(year(today()),$4.), put(month(today()) -1 ,$2.)));
else call symput('upmonth',cat(put(year(today())-1,$4.),'12'));
run;
data _null_;
ismonth = month(today());
if ismonth<10 then call symput('currmonth',cat(put(year(today()),$4.),"年",put(month(today()),$1.),"月"));
else call symput('currmonth',cat(put(year(today()),$4.),"年",put(month(today()),$2.),"月"));
run;
data _null_;
ismonth=month(today());
if ismonth<10 then 
call symput('curr_month',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else call symput('curr_month',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
data _null_;
ismonth=month(today());
if ismonth > 11 then
call symput('STAT_OP',cat(put(year(today()),$4.),"年",put(month(intnx('month',today(),-1)),$2.),"月全量"));
else if ismonth=1 then call symput('STAT_OP',cat(put(year(today())-1,$4.),"年12月全量"));
else call symput('STAT_OP',cat(put(year(today()),$4.),"年",put(month(intnx('month',today(),-1)),$1.),"月全量"));
/*call symput('START',intnx('month',today(),-2,'end'));*/
/*call symput('END',intnx('month',today(),-1,'end'));*/
run;

%put &curr_month.;
%INCLUDE "E:/林佳宁/code/000_FORMAT.sas";
%include "E:/林佳宁/code/基础宏.sas";
%FORMAT;
/*%ChkFile(E:\新建文件夹\&chkmonth.\NFCS);*/

options compress=yes mprint mlogic noxwait NOQUOTELENMAX;
libname nfcs oracle user=datauser password=zlxdh7jf path=nfcs;
/*137.168.98.21 base*/
libname nfcstest oracle user=sinojfs password=sinojfs path=nfcstest;
/*137.168.99.114 base*/
libname nfcsback oracle user=sinojfs password=sinojfs path=nfcsback;
/*137.168.99.119 base*/ 
/*libname nfcsl "D:\数据\&curr_month.";*/
Libname crm1 odbc user=uperpcrm password=uperpcrm datasrc=crm;
/*libname nfcs "D:/数据/&curr_month.";*/
libname ccs oracle user=datauser password=r9ck01qi path=necs;
/*137.168.98.51*/
%let outfile = E:\林佳宁\逻辑校验结果\&curr_month.\;
libname dw "D:\数据\dw";

/*数据服务器*/
/*137.168.99.116 admin 1qaz2WSX*/
/*与征信系统交互测试服务器*/
/*137.168.99.119*/

data _null_;
call symputx('endday',intnx("month",%sysfunc(today()),0,'e'));
call symputx('firstday',intnx("month",%sysfunc(today()),0,'b'));
call symputx('firstday_one',intnx("month",%sysfunc(today()),-1,'b'));
call symputx('firstday_two',intnx("month",%sysfunc(today()),-2,'b'));
call symputx('firstday_three',intnx("month",%sysfunc(today()),-3,'b'));
run;

/*加入筛选时间*/
%put &outfile.;
%put &firstday.;
%put &firstday_two.;
/*导入机构名称、简称、专管员映射关系*/
PROC IMPORT OUT= WORK.soc DATAFILE= "E:/林佳宁/code/数据质量/soc.xlsx" DBMS=EXCEL REPLACE;
     SHEET="sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data soc;
	set soc;
rename
_COL0 = sorgcode
_COL1 = shortname
_COL2 = person
;
run;
data soc;
	set soc;
	if sorgcode = lag(sorgcode) then delete;
run;
proc sql;
	create table config as select
T1.*
from soc as T1
left join (select distinct sorgcode from nfcs.sino_msg) as T2
on T1.sorgcode = T2.sorgcode
where T2.sorgcode is not null
order by person
;
quit;

/*机构名称、简称、专管员*/
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="机构代码"
		,T2.sorgname as sorgname label="机构名称"
		,strip(T3.EXTEND2) as shortname label = '机构简称'
		,(case T3.sub_account_id when 'djw' then '杜俊玮'
	when 'gwq' then '顾文强'
	when 'zm' then '周敏'
	when 'llx' then '李亮希'
	when 'xjq' then '徐珈琪' 
	when 'zkb' then '朱凯博' 
	else '未指定' end) as person label = '专管员'
		,T4.SPROVINCENAME label = '省份'
		,t4.SCITYNAME label = '城市'
		,t4.SCOUNTYNAME label = '区'
		from nfcs.sino_org as T1 
		left join nfcs.sino_org as T2
		on T1.STOPORGCODE=T2.SORGCODE
		left join crm1.T_contract_order as T3
		on T2.sorgname = T3.CUSTOMER_NAME
		left join nfcs.sino_area as T4
		on T1.sareacode = t4.SAREACODE
		where T1.Slevel = '1' and substr(T1.STOPORGCODE,1,1)="Q" and T3.delete_flag = 0 and T3.EXTEND1 not in ('已发合同' '')
	order by T1.STOPORGCODE,T3.EXECUTE_START_DATE
;
quit;
DATA _sino_org;
	SET _sino_org;
	IF SORGCODE = LAG(SORGCODE) THEN DELETE;
RUN;

proc sort data = nfcs.sino_msg(keep = sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) out = sino_msg nodup;
by sorgcode;
run;
proc sql;
	create table soc as select
		T1.*
		,T2.shortname
		,T2.person
	from sino_msg as T1
		left join _sino_org as T2
		on T1.sorgcode = T2.sorgcode
;
quit;
data soc;
	set soc;
	if sorgcode = lag(sorgcode) then delete;
run;

/*导入NFCS全部标签名*/
%macro AddLabel(table);
%if &table. = "" %then %do;
proc sql noprint;
        select
            catx("=",ITABLECOLUMNNAME,SCOLNAME) into:label separated by " "
        from nfcs.Sino_msg_column
        ;
quit;
%end;
%else %do;
proc sql noprint;
        select
            catx("=",ITABLECOLUMNNAME,SCOLNAME) into:label separated by " "
        from nfcs.Sino_msg_column as T1
		where T1.ITABLENAME = "&table."
        ;
quit;
%end;
%mend;
/*示例程序*/
/*%AddLabel(sino_person);*/
/*data sino_person;*/
/*	set nfcs.sino_person;*/
/*	label*/
/*	&label.*/
/*;*/
/*run;*/
