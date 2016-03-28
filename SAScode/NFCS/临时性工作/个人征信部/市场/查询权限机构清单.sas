options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*根据当前日期，自动生成STAT_OP END START 已验证 2015.03.02 更新人：李楠 可先在日志中观察结果后再使用*/
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";

%FORMAT;
%let firstday = mdy(1,1,2015);
%let dayscount = intck('day',&firstday.,today());

/*签约机构数量*/
data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set mylib.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="机构代码"
		,T2.sorgname as sorgname label="机构名称"
/*		,T1.sareacode label="机构省市代码"*/
		from sino_org2 as T1 left join mylib.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q";
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;


proc sql;
	create table _chaxun_type as select
		sorgcode
		,(case IPLATE when 3 then "1" when 1 then "2" else "未开通" end) as chaxun_type label = "查询报告类型（1-特殊版、2-特殊版+网金版）"
	from mylib.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	order by sorgcode , (case when chaxun_type = "2" then 1 when chaxun_type = "1" then 2 else 3 end)
;
quit;
data _chaxun_type;
	set _chaxun_type;
	if sorgcode = lag(sorgcode) then delete;
run;

proc sql;
	create table cly as select
		T1.*
		,T2.*
		from _sino_org as T1
		left join _chaxun_type as T2
		on T1.sorgcode = T2.sorgcode
	where chaxun_type is not null
;
quit;
libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\BD\陈力阳\查询权限名单-1.xlsx";
data xls.sheet1(dblabel=yes);
	set cly;
run;
libname xls clear;
