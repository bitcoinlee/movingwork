/*根据当前日期，自动生成STAT_OP END START 已验证 2015.03.02 更新人：李楠 可先在日志中观察结果后再使用*/
/*更新时间 2015-5-4 更新人：李楠*/
/*更新时间 20160227 更新人：李楠 更新内容：将输出方式改为ods+proc report*/
/*注意修改时间段;*/
%LET END=MDY(3,15,2016);
%LET START=MDY(3,1,2016);
%LET START_THREE = intnx('month',&START.,-2,'b');
%put &STAT_OP.;
%put &START.;
%put &END.;
%put &START_THREE.;
%put &curr_month.;
%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\config.sas";
%ChkFile(E:\新建文件夹\&curr_month.\NFCS);
%ChkFile(E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\&curr_month.);

/*%ChkFile(D:\数据\&STAT_OP.);*/
/*LIBNAME SSS "D:\数据\&STAT_OP.";*/
/*OPTIONS NOXWAIT MPRINT MLOGIC COMPRESS=YES;*/
options compress=yes mprint mlogic noxwait;
/*libname nfcs "C:\Users\linan\Documents\工作\NFCS库中数据\201602";*/
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%FORMAT;

/*贷款申请信息*/
PROC SQL;
	CREATE TABLE SQ AS SELECT
		sorgcode LABEL="机构代码"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname LABEL="机构简称"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="库中累计申请量-本期"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="库中累计申请量-上期"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="库中累计申请量-三月前"
	FROM (
	SELECT 
		P.SORGCODE
		,P.SAPPLYCODE
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &START. THEN 1 ELSE 0 END) AS LAST
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS NOW
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START_THREE. THEN 1 ELSE 0 END) AS LAST_THREE
	FROM NFCS.SINO_LOAN_APPLY(keep = SORGCODE SAPPLYCODE DGETDATE ISTATE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P
	WHERE P.ISTATE=0
	GROUP BY P.SORGCODE,P.SAPPLYCODE)
	GROUP BY sorgcode;
QUIT;

/*贷款业务信息*/

PROC SQL;
	CREATE TABLE LOAN AS SELECT
		sorgcode LABEL="机构代码"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname LABEL="机构简称"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="库中累计业务量-本期"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="库中累计业务量-上期"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="库中累计业务量-三月前"
	FROM (
	SELECT 
		P.SORGCODE
		,P.iloanid
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &START. THEN 1 ELSE 0 END) AS LAST
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS NOW
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START_THREE. THEN 1 ELSE 0 END) AS LAST_THREE
	FROM NFCS.SINO_LOAN(keep = SORGCODE iloanid DGETDATE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P
	GROUP BY P.SORGCODE,P.iloanid)
	GROUP BY sorgcode
;
QUIT;

/*个人身份信息*/

PROC SQL;
	CREATE TABLE SF AS SELECT
		sorgcode LABEL="机构代码"
/*		,PUT(SORGCODE,$SHORT_CD.) as shortname label = "机构简称"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="库中累计个人量-本期"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="库中累计个人量-上期"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="库中累计个人量-三月前"
	FROM (
	SELECT
		P.SORGCODE
		,P.DGETDATE
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &START. THEN 1 ELSE 0 END) AS LAST
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS NOW
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START_THREE. THEN 1 ELSE 0 END) AS LAST_THREE
	FROM NFCS.SINO_PERSON(keep = sorgcode spin DGETDATE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P
	group by P.SORGCODE,p.spin)
	GROUP BY SORGCODE;
QUIT;

/*特殊交易信息上报机构, 本期,上期*/

PROC SORT DATA=NFCS.Sino_LOAN_SPEC_TRADE(keep = SORGCODE SACCOUNT dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) OUT=SPEC_N1;
	BY SORGCODE SACCOUNT dgetdate;
RUN;
DATA SPEC_N1;
	SET SPEC_N1;
	if SORGCODE = lag(SORGCODE) and SACCOUNT = lag(SACCOUNT) then delete;
RUN;

PROC SQL;
 	CREATE TABLE SPEC AS SELECT
		sorgcode  LABEL="机构代码"
/*		,PUT(SORGCODE,$SHORT_CD.) as shortname label = "机构简称"*/
		,sum(case when DATEPART(DGETDATE) <= &END. then 1 else 0 end) as NOW LABEL= "库中累计特殊交易量-本期"
		,sum(case WHEN DATEPART(DGETDATE) <= &START. then 1 else 0 end) as LAST LABEL= "库中累计特殊交易量-上期"
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START_THREE. THEN 1 ELSE 0 END) AS LAST_THREE LABEL="库中累计特殊交易量-三月前"
	FROM SPEC_N1
	 Group By sorgcode;
QUIT;

/*入库及加载情况*/
PROC SQL;
	CREATE TABLE RK AS select 
		sorgcode LABEL="机构代码"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname label = "机构简称"*/
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&START. THEN itotalcount ELSE 0 END) AS LASTTOTAL LABEL="上期加载"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&START. THEN isuccesscount ELSE 0 END) AS LASTS LABEL="上期成功"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&END. THEN itotalcount ELSE 0 END) AS NOWTOTAL LABEL="本期加载"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&END. THEN isuccesscount ELSE 0 END) AS NOWS LABEL="本期成功"
	from (select p.sorgcode,p.DUPLOADTIME,p.itotalcount,p.isuccesscount from NFCS.sino_msg(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS p)  
group by sorgcode;
QUIT;

/* 查询量*/
/*本月查询量*/
PROC SQL;
	CREATE TABLE CX AS SELECT
		T2.stoporgcode as sorgcode LABEL="机构代码"
/*		PUT(SORGCODE,$SHORT_CD.) as shortname LABEL="机构名称"*/
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as cx_NOW LABEL="本期"
		,sum(case when DATEPART(dcreatetime) < &START. then 1 else 0 end) as cx_LAST LABEL="上期"
  		From NFCS.sino_credit_record(keep = sorgcode dcreatetime WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
		Group By stoporgcode
;
QUIT;

/*上月核定查询量*/
proc sql;
	create table cx_lastmonth as select
	STOPORGCODE as sorgcode LABEL="机构名称"
	,SUM(ISEARCHLIMIT) as ISEARCHLIMIT label = "上月日查询量限额（分支机构汇总统计）"
/*	,put(sorgcode,$short_cd.) as shortname */
	from nfcs.sino_org(keep = STOPORGCODE ISEARCHLIMIT)
	group by sorgcode
;
quit;
data cx_lastmonth;
	set cx_lastmonth;
	if sorgcode = lag(sorgcode) then delete;
run;


/*本月日查询均值及峰值*/
proc sql;
	CREATE TABLE CX_day AS SELECT
	T2.stoporgcode as sorgcode LABEL="机构代码"
	,datepart(T1.dcreatetime) as tian label = "发生日期" format = YYMMDDS10.
	,count(T1.dcreatetime) as chaxunliang label = "日查询量"
	,T2.ISEARCHLIMIT label = "上月日查询量限额"
	from NFCS.sino_credit_record(keep = sorgcode dcreatetime WHERE=(&START.<= datepart(dcreatetime) <= &END. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
	group by T1.sorgcode,calculated tian
	order by sorgcode,chaxunliang desc
;
quit;
data CX_day;
	set CX_day;
	if sorgcode = lag(sorgcode) and tian = lag(tian) then delete;
/*	shortname=PUT(sorgcode,$SHORT_CD.);*/
run;
data CX_max;
	set CX_day;
	if sorgcode = lag(sorgcode) then delete;
run;

/*最近一次查询、上报时间*/
proc sort data = NFCS.sino_credit_record(keep = dcreatetime SORGCODE WHERE=(datepart(dcreatetime) <= &END. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_credit_record;
by sorgcode descending dcreatetime;
run;
data sino_credit_record;
format cxtime_last YYMMDDS10.;
	set sino_credit_record;
	if sorgcode = lag(sorgcode) then delete;
	cxtime_last = datepart(dcreatetime);
/*	shortname = put(sorgcode,$short_cd.);*/
drop
dcreatetime
;
label
sorgcode = 机构代码
/*shortname = 机构简称*/
cxtime_last = 最近一次查询时间
;
run;
proc sort data = nfcs.sino_msg(keep = sorgcode DUPLOADTIME WHERE=(datepart(DUPLOADTIME) <= &END. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_msg;
by sorgcode descending DUPLOADTIME;
run;
data sino_msg;
format bstime_last YYMMDDS10.;
	set sino_msg;
	if sorgcode = lag(sorgcode) then delete;
	bstime_last = datepart(DUPLOADTIME);
/*	shortname = put(sorgcode,$short_cd.);*/
drop
DUPLOADTIME
;
label
sorgcode = 机构代码
/*shortname = 机构简称*/
bstime_last = 最近一次报送时间
;
run;


/* 查得量*/
PROC SQL;
	CREATE TABLE CD AS SELECT
		T2.stoporgcode as sorgcode LABEL="机构代码"
/*		PUT(SORGCODE,$SHORT_CD.) as shortname LABEL="机构名称"*/
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  CD_NOW LABEL="本期查得量"
		,sum(case when DATEPART(dcreatetime) < &START. then 1 else 0 end) as  CD_LAST LABEL="上期查得量"
  		From NFCS.sino_credit_record(keep = sorgcode dcreatetime IREQUESTTYPE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND IREQUESTTYPE IN (0,1,2,6))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
	Group By stoporgcode
;
QUIT;

/*提取全部机构代码*/
proc sql;
	create table sorgcode as select
	distinct stoporgcode as sorgcode
	from nfcs.sino_org(keep = sorgcode stoporgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001'))
	;
quit;
ods listing off;
proc datasets library=work;
     modify sorgcode;
   rename stoporgcode = sorgcode;
run;
quit;
ods listing;

/*是否全量报数机构（通过查询权限判断）*/
proc sql;
	create table chaxun_type as select
		T1.sorgcode label = "机构代码"
/*		,PUT(sorgcode,$SHORT_CD.) AS shortname label = "机构简称"*/
		,(case when sum(T1.IPLATE) = 4 then "√" else "" end) as cx_quanliang label = "全量查询权限"
		,(case when sum(T1.IPLATE) = 3 then "√" else "" end) as cx_spec label = "特殊交易查询权限"
		,(case when T2.SQUERYAUTH = '1' then "√" else "" end) as cx_SQUERYAUTH label = "身份认证查询权限"
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.stoporgcode
	group by T1.sorgcode
;
quit;

/*计算查询基准量*/
PROC SQL;
	CREATE TABLE ALL_THREE AS SELECT
		T5.sorgcode
		,sum(T1.now,T2.now,T3.now,T4.now) as all_now label = "四类数据累计量-当月"
		,sum(T1.LAST_THREE,T2.LAST_THREE,T3.LAST_THREE,T4.LAST_THREE) as all_three label = "四类数据累计量-三月前"
		,(calculated all_now - calculated all_three) as REQ_ADD label = "四类数据增加量"
		,(case when calculated REQ_ADD > 1000 then ROUND(calculated REQ_ADD*6/20,1) else ROUND(calculated REQ_ADD*8/20,1) end) as REQ_BASE label = "查询基准量"
	FROM sorgcode as T5
	left join sq as T1
	on T5.sorgcode = T1.sorgcode
	left join loan as T2
	on T5.sorgcode = T2.sorgcode
	left join sf as T3
	on T5.sorgcode = T3.sorgcode
	left join spec as T4
	on T5.sorgcode = T4.sorgcode
;
QUIT;

/*汇总*/
proc sql;
	create table result as select
		. as xuhao format = 4. informat = 4. label = "序号"
		,T1.sorgcode label = "机构代码"
		,PUT(T1.sorgcode,$SHORT_CD.) AS shortname label = "机构简称"
		,T15.person label = "专管员"
		,(case when T3.NOW is null and T5.NOW > 0 then "特殊交易"
			   when T3.NOW is null and T5.NOW is null then "未报送业务" 
				ELSE "已报送业务" end) as type label = "数据类型"
		,T2.NOW as SF_NOW label = "个人基本信息-本期"
		,T2.LAST as SF_LAST label = "个人基本信息-上期"
		,(T2.NOW - T2.LAST) as SF_ADD label = "个人基本信息-增长量"
		,T2.NOW/T2.LAST-1 as SF_per label = "个人基本信息-增长率" format = percent10.2
		,T3.NOW as LOAN_NOW label = "贷款业务信息-本期"
		,T3.LAST as LOAN_LAST label = "贷款业务信息-上期"
		,(T3.NOW - T3.LAST) as LOAN_add label = "贷款业务信息-增长量"
		,T3.NOW/T3.LAST-1 as LOAN_per label = "贷款业务信息-增长率" format = percent10.2
		,T4.NOW as SQ_NOW label = "贷款申请信息-本期"
		,T4.LAST as SQ_LAST label = "贷款申请信息-上期"
		,(T4.NOW - T4.LAST) as SQ_add label = "贷款申请信息-增长量"
		,T4.NOW/T4.LAST-1 as SQ_per label = "贷款申请信息-增长率" format = percent10.2
		,T5.NOW as SPEC_NOW label = "特殊交易信息-本期"
		,T5.LAST as SPEC_LAST label = "特殊交易信息-上期"
		,T5.NOW/T5.LAST-1 as SPEC_per label = "特殊交易信息-增长率" format = percent10.2
		,"" as score label = "评分情况"
		,T6.NOWS/T6.NOWTOTAL as succ_per label = "加载成功率" format = percent10.2
		,T7.cx_quanliang label = "是否具有全量查询权限"
		,T7.cx_spec label = "是否具有特殊交易查询权限"
		,T7.cx_SQUERYAUTH label = "是否具有身份认证查询权限"
		,T9.cx_now label = "截止本月底查询总量"
		,T9.cx_last label = "截止上月底查询总量"
		,T10.cd_now label = "截止本月底查得总量"
		,T10.cd_last label = "截止上月底查得总量"
		,T11.chaxunliang label = "本月日查询量峰值"
		,T11.tian label = "峰值发生日期"
		,T13.cxtime_last label = '最近一次查询时间'
		,T14.bstime_last label = '最近一次报送时间'
		,T12.all_three label = "四类数据累计量-三月前"
		,T12.all_now label = "四类数据累计量-当月"
		,T12.REQ_ADD label = '四类数据增加量'
		,T11.ISEARCHLIMIT label = '核定日查询量-上月'
		,T12.REQ_BASE label = '查询基准量'
		,%sysfunc(today()) as dgetdate format YYMMDDS10.
		from sorgcode as T1
		left join SF as T2
	on T1.sorgcode = T2.sorgcode
		left join LOAN as T3
	on T1.sorgcode = T3.sorgcode
		left join SQ as T4
	on T1.sorgcode = T4.sorgcode
		left join SPEC as T5
	on T1.sorgcode = T5.sorgcode
		left join RK as T6
	on T1.sorgcode = T6.sorgcode
		left join chaxun_type as T7
	on T1.sorgcode = T7.sorgcode
		left join CX as T9
	on T1.sorgcode = T9.sorgcode
		left join CD as T10
	on T1.sorgcode = T10.sorgcode
		left join cx_max as T11
	on T1.sorgcode = T11.sorgcode
		left join ALL_THREE as T12
	on T1.sorgcode = T12.sorgcode
		left join sino_credit_record as T13
	on T1.sorgcode = T13.sorgcode
		left join sino_msg as T14
	on T1.sorgcode = T14.sorgcode
		left join soc as T15
	on T1.sorgcode = T15.sorgcode
	order by (case when type = "已报送业务" then 1
					when type = "特殊交易" then 2 
					when type = "未报送业务" then 3 end),LOAN_NOW desc
;
quit;
data result;
	set result;
	if sorgcode = lag(sorgcode) then delete;
run;
data result;
	set result;
	xuhao = _n_;
run;

/*存入数据仓库*/
/*待完成*/
%macro save_dw(ToLib,ToDs,FromDs);
/*	%local did = %sysfunc(exist(&ToLib..&ToDs.));*/
/*	%local did2 = %sysfunc(exist(work.&FromDs.));*/
/*	%let tdy = %sysfunc(today());*/
	%if %sysfunc(exist(&ToLib..&ToDs.)) and %sysfunc(exist(work.&FromDs.)) %then %do;
	proc sql;
		Insert into &ToLib..&ToDs.
		select * from work.&FromDs.
	;
	update &ToLib..&ToDs.
	set dgetdate = %sysfunc(today());
	quit;	
	%end;
	%else %if %sysfunc(exist(&ToLib..&ToDs.)) = 0 and %sysfunc(exist(work.&FromDs.)) = 1 %then %do;
		data &ToLib..&ToDs.;
			set work.&FromDs.;
			dgetdate = today();
		label
			dgetdate = 获取日期;
		run;	
	%end;
run;
%mend;
	
%save_dw(dw,monthreport,result);

/*近三个月连续报送业务情况*/
proc sql;
	create table ruku as select
		sorgcode label = "机构代码"
		,intnx('month',datepart(dgetdate),0,'b') as yearmonth format=yymmn6. informat = yymmn6. label = "报送时间"
/*		,put(datepart(dgetdate),yymmn6.) as yearmonth label = "报送时间"*/
		,count(distinct iloanid) as loan_count label = "贷款业务记录数"
	from nfcs.sino_loan(keep = sorgcode saccount dgetdate iloanid WHERE=(&START_THREE. <= datepart(dgetdate) <= &END. and SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) 
	group by sorgcode, calculated yearmonth
	order by sorgcode,calculated yearmonth
;
quit;

proc transpose data = ruku out = _ruku(drop = _name_ _label_);
id yearmonth;
var loan_count;
by sorgcode;
run;

data _ruku;
	set _ruku;
	shortname = put(sorgcode,$short_cd.);
drop
sorgcode
;
label
shortname = 机构简称
;
run;

data _ruku;
retain shortname;
	set _ruku;
run;

/*E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\&curr_month.\NFCS运营月报-&STAT_OP..xls*/
ods tagsets.excelxp file="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\&curr_month.\NFCS运营月报-&STAT_OP..xls" style = printer
      options(sheet_name="NFCS运营月报" embedded_titles='yes' embedded_footnotes='yes' sheet_interval="bygroup");
proc report data = result NOWINDOWS headline headskip style(header)={background=lightgray foreground=black bold};
	columns xuhao sorgcode shortname person type ('报送情况' SF_NOW SF_LAST SF_ADD SF_per loan_NOW loan_LAST loan_ADD loan_per sq_NOW sq_LAST sq_ADD sq_per spec_NOW spec_LAST spec_per)
		('查询情况' cx_quanliang cx_spec cx_SQUERYAUTH cx_now cx_last cd_now cd_last chaxunliang tian) ('合规使用情况' cxtime_last bstime_last)
		('核定查询量所需参数' all_three all_now REQ_ADD ISEARCHLIMIT REQ_BASE);
	define xuhao / display '序号';
	define sorgcode / display width = 7;
	define shortname / display width = 6;
	define person / display;
	define type / display;
	define SF_NOW / display '个人信息/-本期';
	define SF_LAST / display '个人信息/-上期';
	define SF_ADD / display '个人信息/-本期增长量';
	define SF_PER / display '个人信息/-本期增长率';
	define loan_NOW / display '贷款信息/-本期';
	define loan_last / display '贷款信息/-上期';
	define loan_add / display '贷款信息/-本期增长量';
	define loan_per / display '贷款信息/-本期增长率';
	define sq_NOW / display '申请信息/-本期';
	define sq_last / display '申请信息/-上期';
	define sq_add / display '申请信息/-本期增长量';
	define sq_per / display '申请信息/-本期增长率';
	define spec_now / display '特殊交易信息/-本期';
	define spec_last / display '特殊交易信息/-上期';
	define spec_per / display '特殊交易信息/-本期增长率';
	define cx_quanliang / display '是否具有/全量查询权限';
	define cx_spec / display '是否具有特殊/交易查询权限';
	define cx_SQUERYAUTH / display '是否具有身份/认证查询权限';
	define cx_now / display '截止本月底/查询总量';
	define cx_last / display '截止上月底/查询总量';
	define cd_now / display '截止本月底/查得总量';
	define cd_last / display '截止上月底/查得总量';
	define all_three / display '四类数据/累计量-三月前';
	define all_now / display '四类数据/累计量-当月';
	define ISEARCHLIMIT / display '核定日查询量/-上月';
/*break after/ dol summarize;*/
/*rbreak after /summarize;*/
	footnote1 20160228：更新了报表结构;
quit;
/*proc report data = _ruku NOWINDOWS headline headskip style(header)={background=lightgray foreground=black};*/
ods tagsets.excelxp close;
  ods listing;

 




libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\&curr_month.\NFCS运营月报-&STAT_OP..xlsx";
	data xls.NFCS运营月度报表(dblabel=yes);
		set result;
	run;
data xls.近三月连续报送业务情况表(dblabel=yes);
	set _ruku;
RUN;
libname xls clear;

