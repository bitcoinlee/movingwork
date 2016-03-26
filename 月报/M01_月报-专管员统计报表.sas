options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
libname nfcs "D:\数据\201512";
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";
%FORMAT;

%LET START=MDY(11,1,2015);
%LET START_THREE = intnx('month',&START.,-2,'b');
%LET START_SIX = intnx('month',&START.,-5,'b');
%LET END =MDY(11,30,2015);
data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then
call symput('chkmonth',cat(put(year(today())-1,$4.),put(12,$2.)));
else call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%put x=&chkmonth.;

/*data soc;*/
/*	set soc;*/
/*	rename*/
/*	_col0 = sorgcode*/
/*	_col1 = shortname*/
/*	_col2 = person*/
/*	;*/
/*	label*/
/*	_col0 = 机构代码*/
/*	_col1 = 机构简称*/
/*	_col2 = 专管员*/
/*	;*/
/*run;*/


/*个人身份信息*/

/*PROC SQL;*/
/*	CREATE TABLE SF AS SELECT*/
/*		SORGCODE label = "机构代码"*/
/*		,SUM(CASE WHEN &START. <= DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS SF_NOW LABEL="本期"*/
/*		,SUM(CASE WHEN DATEPART(DGETDATE) < &START. THEN 1 ELSE 0 END) AS SF_HIST LABEL="存量"*/
/*	FROM (*/
/*	SELECT*/
/*		P.DGETDATE*/
/*		,P.SORGCODE*/
/*	FROM NFCS.SINO_PERSON(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P)*/
/*	GROUP BY sorgcode;*/
/*QUIT;*/

/*贷款业务信息*/

PROC SQL;
	CREATE TABLE LOAN AS SELECT
		sorgcode LABEL="机构代码"
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS LOAN_NOW LABEL="贷款业务笔数-截至本期"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LOAN_HIST LABEL="贷款业务笔数-截至上期"
	FROM (
	SELECT 
		P.SORGCODE
		,P.ILOANID
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START. THEN 1 ELSE 0 END) AS LAST
		,SUM(CASE WHEN DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS NOW
	FROM NFCS.SINO_LOAN(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P 
	GROUP BY P.SORGCODE,P.ILOANID)
	GROUP BY sorgcode;
QUIT;



/*贷款申请信息*/
/*PROC SQL;*/
/*	CREATE TABLE SQ AS SELECT*/
/*		sorgcode LABEL="机构代码"*/
/*		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS APPLY_NOW LABEL="本期"*/
/*		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS APPLY_HIST LABEL="存量"*/
/*	FROM (*/
/*	SELECT */
/*		P.SORGCODE*/
/*		,P.SAPPLYCODE*/
/*		,SUM(CASE WHEN DATEPART(DGETDATE) < &START. THEN 1 ELSE 0 END) AS LAST*/
/*		,SUM(CASE WHEN &START. <= DATEPART(DGETDATE) <= &END. THEN 1 ELSE 0 END) AS NOW*/
/*	FROM NFCS.SINO_LOAN_APPLY(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS P*/
/*	WHERE P.ISTATE=0*/
/*	GROUP BY P.SORGCODE,P.SAPPLYCODE)*/
/*	GROUP BY sorgcode;*/
/*QUIT;*/

/*特殊交易信息上报机构*/

/*PROC SORT DATA=NFCS.Sino_LOAN_SPEC_TRADE(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) OUT=SPEC_N1;*/
/*	BY SORGCODE SACCOUNT;*/
/*RUN;*/
/**/
/*data SPEC_N1;*/
/*	set SPEC_N1;*/
/*	if SORGCODE = lag(SORGCODE) and SACCOUNT = lag(SACCOUNT) then delete;*/
/*run;*/
/**/
/*PROC SQL;*/
/* 	CREATE TABLE SPEC AS SELECT*/
/*		sorgcode  LABEL="机构代码"*/
/*		,sum(case when &START. <= DATEPART(DGETDATE) <= &END. then 1 else 0 end) as SPEC_NOW LABEL="本期"*/
/*		,sum(case WHEN DATEPART(DGETDATE) < &START. then 1 else 0 end) as SPEC_HIST LABEL="存量"	*/
/*	FROM (*/
/*		Select */
/*			p.DGETDATE*/
/*			, p.SORGCODE*/
/*        From SPEC_N1 AS p*/
/*      )*/
/*	 Group By sorgcode;*/
/*QUIT;*/

/**/

/*是否首次报送*/
/*substr(sorgcode,11,1) = upcase(substr(sorgcode,11,1))*/
proc sort data = nfcs.sino_msg(keep = sorgcode duploadtime WHERE=( SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_msg_shouci;
	by sorgcode duploadtime;
run;
data sino_msg_shouci;
	set sino_msg_shouci;
	if sorgcode = lag(sorgcode) then delete;
	if datepart(duploadtime) < &START. then delete;
	shouci = 1;
drop
duploadtime
;
label
shouci = 是否首次报送
;
run;

/*是否连续报送*/
proc sql;
	create table ruku_A as select
		sorgcode label =  "机构代码"
		,intnx('month',datepart(dgetdate),0,'b') as yearmonth format=yymmn6. informat = yymmn6. label = "报送时间"
		,count(distinct iloanid) as loan_count label = "贷款业务记录数"
	from nfcs.sino_loan(keep = sorgcode saccount dgetdate iloanid WHERE=(&START_SIX. <= datepart(dgetdate) <= &END. and SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) 
	group by sorgcode, calculated yearmonth
	order by sorgcode,calculated yearmonth
;
quit;
proc sql;
	create table lianxu as select
		sorgcode
		,count(*) as baosong_count
		from ruku_A
		group by sorgcode
	;
quit;
data lianxu;
	set lianxu;
	if baosong_count = 6 then baosong_six = 1;
	if 3 <= baosong_count then baosong_three = 1;
	baosong_one = 1;
label
baosong_six = 是否过去六个月连续报送业务
baosong_three = 是否过去六个月中至少三个月报送业务
baosong_one = 是否过去六个月中至少一个月报送业务
;
drop
baosong_count
;
run;

/*proc transpose data = ruku_A out = ruku_A(drop = _name_ _label_);*/
/*id yearmonth;*/
/*var loan_count;*/
/*by sorgcode;*/
/*run;*/
/*data ruku_A;*/
/*	set ruku_A;*/
/*	array num{*} _numeric_;*/
/*do i=1 to dim(num);*/
/*if num{i} > 0 then num{i} =1;*/
/*end;*/
/*run;*/
/*proc means*/

/*加载量加载率*/
PROC SQL;
	CREATE TABLE RK AS select 
		sorgcode LABEL="机构代码"
		,sum(CASE WHEN DATEPART(DUPLOADTIME) THEN itotalcount ELSE 0 END) AS LASTTOTAL LABEL="历史报文记录数"
		,sum(CASE WHEN DATEPART(DUPLOADTIME) THEN isuccesscount ELSE 0 END) AS LASTS LABEL="历史加载成功数"
		,calculated LASTS/calculated LASTTOTAL AS HIST_PER  format = PERCENTN8.2 LABEL="历史加载成功率"
		,sum(CASE WHEN &START. <= DATEPART(DUPLOADTIME)<=&END. THEN itotalcount ELSE 0 END) AS NOWTOTAL LABEL="本期报文记录数"
		,sum(CASE WHEN &START. <= DATEPART(DUPLOADTIME)<=&END. THEN isuccesscount ELSE 0 END) AS NOWS LABEL="本期加载成功数"
		,calculated NOWS/calculated NOWTOTAL AS NOW_PER format = PERCENTN8.2 LABEL="本期加载成功率"
	from (select p.sorgcode,p.DUPLOADTIME,p.itotalcount,p.isuccesscount from NFCS.sino_msg(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS p )  
group by sorgcode;
QUIT;

data rk;
	set rk;
	if HIST_PER >= 0.9 then HIST_SHIFOU =1;
	if NOW_PER >= 0.95 then NOW_SHIFOU =1;
drop
	LASTTOTAL LASTS NOWTOTAL NOWS HIST_PER NOW_PER
;
label
HIST_SHIFOU = 是否历史报文加载率高于90%
NOW_SHIFOU = 是否当月报文加载率高于95%
;
run;

/*及时性*/

/*总体及时率*/
proc sql;
	create table dmonth as select
	distinct(intnx('month',datepart(DBILLINGDATE),0,'b')) as dmonth FORMAT=yymmn6. INFORMAT=yymmn6.
	from nfcs.sino_loan(keep = DBILLINGDATE)
	where today() > calculated dmonth > mdy(7,1,2013)
;
quit;

/*需要维护 用proc expand代替笛卡尔积*/
proc sql;
	create table sino_loan_1 as select
		SORGCODE
		,iloanid
		,intnx('month',datepart(DDATEOPENED),0,'b') as omonth FORMAT=yymmn6. INFORMAT=yymmn6.
		,intnx('month',datepart(DDATECLOSED),0,'b') as cmonth FORMAT=yymmn6. INFORMAT=yymmn6.
		,intnx('month',datepart(DBILLINGDATE),0,'b') as dmonth FORMAT=yymmn6. INFORMAT=yymmn6.
	from nfcs.sino_loan(keep = SORGCODE iloanid DDATEOPENED DDATECLOSED DBILLINGDATE iaccountstat where=(sorgcode like 'Q%' and datepart(DBILLINGDATE) < today() and iaccountstat in (1,2)))
	order by iloanid,dmonth
;
quit;
data sino_loan_1;
	length sorgcode_1 $14.;
	set sino_loan_1;
		sorgcode_1=substr(sorgcode,1,14);
	drop sorgcode;
	rename sorgcode_1=sorgcode;
run;
data sino_loan_1;
	set sino_loan_1;
	if iloanid = lag(iloanid) and dmonth = lag(dmonth) then delete;
run;
proc sql;
	create table sorgcodeiloanid_ as select
		sorgcode
		,iloanid
		,omonth
		,cmonth
		from sino_loan_1;
quit;

proc sort in=sorgcodeiloanid_ nodupkey;
by sorgcode iloanid;
run;

proc sql;
	create table sino_loan_2 as select 
		Sorgcodeiloanid_.SORGCODE
		,Sorgcodeiloanid_.iloanid
		,Sorgcodeiloanid_.omonth
		,Sorgcodeiloanid_.cmonth
		,dmonth.dmonth
		from Sorgcodeiloanid_,dmonth;
quit;

data sino_loan_2;
	length sorgcode_1 $14.;
	set sino_loan_2;
		if omonth<=dmonth and dmonth<=cmonth;
	sorgcode_1=substr(sorgcode,1,14);
	drop sorgcode;
	rename sorgcode_1 = sorgcode;
run;
proc sort in=sino_loan_2;
	by sorgcode iloanid dmonth;
run;
proc sort in=sino_loan_1 nodupkey;
	by sorgcode iloanid dmonth;
run;

proc sql;
	create table _loan_missed_ as select
		t1.sorgcode label='机构代码'
		,t1.iloanid label='业务编号'
		,t1.omonth label='贷款业务开立月份'
		,t1.cmonth label='贷款业务终止月份'
		,t1.dmonth label='账期'
		,t2.dmonth as dmonth1
		,(case when dmonth1 is not null then 1 else 0 end) as status label='入库状态'
		from sino_loan_2 as t1
		left join sino_loan_1 as t2
		on t1.sorgcode=t2.sorgcode and t1.iloanid=t2.iloanid and t1.dmonth=t2.dmonth;
quit;

proc sql;
	create table _loan_m_sta_ as select
		t1.sorgcode
		,count(t1.iloanid) as total label = "应入库业务总量"
		,sum(t1.status) as innfcs label = "已入库业务总量"
		,calculated innfcs/calculated total as percent label = "及时率" format = percent8.2
		from _loan_missed_ as t1
		group by sorgcode
		having calculated percent >=0.8
;
quit;

/*当月及时率*/
/*data sino_loan_1*/

/*完整性*/

/*准确性*/

/*连接专管员表和各机构情况表*/
proc sql;
	create table org_curr as select
		T1.sorgcode label = "机构代码"
		,T1.person label = "专管员"
/*		,T2.SF_NOW label = "个人基本信息-增量"*/
/*		,T2.SF_HIST  label = "个人基本信息-存量"*/
		,T3.LOAN_NOW - T3.LOAN_HIST as LOAN_ADD label = "贷款业务笔数-本月增量"
		,T3.LOAN_HIST label = "贷款业务笔数-历史存量"
/*		,T4.apply_NOW label = "贷款申请信息-增量"*/
/*		,T4.apply_HIST label = "贷款申请信息-存量"*/
/*		,T5.SPEC_NOW label = "特殊交易信息-增量"*/
/*		,T5.SPEC_HIST label = "特殊交易信息-存量"*/
		,T6.*
		,T7.*
		,T8.*
		,(case when T9.percent ^= . then 1 else 0 end) as percent label = '是否总体及时率高于80%'
		from SOC as T1
/*		left join SF as T2*/
/*		on T1.SORGCODE = T2.SORGCODE*/
		left join LOAN as T3
		on T1.SORGCODE = T3.SORGCODE
/*		left join SQ as T4*/
/*		on T1.SORGCODE = T4.SORGCODE*/
/*		left join SPEC as T5*/
/*		on T1.SORGCODE = T5.SORGCODE*/
		left join sino_msg_shouci as T6
		on T1.SORGCODE = T6.SORGCODE
		left join lianxu as T7
		on T1.SORGCODE = T7.SORGCODE
		left join RK as T8
		on T1.SORGCODE = T8.SORGCODE
		left join _loan_m_sta_ as T9
		on T1.SORGCODE = T9.SORGCODE
;
quit;

/*各专管员情况（当月）*/
proc sql;
	create table person_curr as select
	person label = "专管员"
/*	,SUM(SF_NOW) as SF_NOW label = "个人基本信息-增量"*/
/*	,SUM(SF_HIST) as SF_HIST  label = "个人基本信息-存量"*/
	,SUM(loan_add) as LOAN_add label = "贷款业务笔数-本月增量"
	,SUM(LOAN_HIST) as LOAN_HIST label = "贷款业务笔数-历史存量"
/*	,SUM(apply_NOW) as apply_NOW label = "贷款申请信息-增量"*/
/*	,SUM(apply_HIST) as apply_HIST label = "贷款申请信息-存量"*/
/*	,SUM(SPEC_NOW) as SPEC_NOW label = "特殊交易信息-增量"*/
/*	,SUM(SPEC_HIST) as SPEC_HIST label = "特殊交易信息-存量"*/
	,SUM(SHOUCI) as SHOUCI label = "首次报送机构数量"
	,sum(baosong_six) as baosong_six label = "近六月连续报送业务数据机构数量"
	,sum(baosong_three) as baosong_three label = "近六月至少三个月报送业务机构数量"
	,sum(baosong_one) as baosong_one label = "近六月中至少一个月报送业务机构数量"
	,sum(HIST_SHIFOU) as HIST_SHIFOU label = '历史报文加载率高于90%的机构数量'
	,sum(NOW_SHIFOU) as NOW_SHIFOU label = '当月报文加载率高于95%的机构数量'
	,sum(percent) as per_jishi label = '总体及时率高于80%的机构数量'
	,0 as per_zhunque label = '总体准确率高于80%的机构数量'
	,0 as per_wanzheng label = '总体完整率高于80%的机构数量'
	from org_curr
	group by person
;
quit;


/*各专管员变动情况*/
/*导入上月情况*/
PROC IMPORT OUT= WORK.person_last DATAFILE= "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\专管员\专管员情况统计表_201511.xlsx" DBMS=EXCEL REPLACE;
     SHEET="本月专管员指标情况"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
data person_last;
	set person_last;
rename
_COL0 = person
_COL4 = baosong_six
_COL5 = baosong_three
_COL6 = baosong_one
_COL7 = HIST_SHIFOU
_COL8 = NOW_SHIFOU
_COL9 = per_jishi
_COL10 = per_zhunque
_COL11 = per_wanzheng
;
run;

proc sql;
	create table person_change as select
	T1.person
	,T1.baosong_six - T2.baosong_six as six_change label = "近六月连续报送业务机构数量-变动"
	,T1.baosong_three - T2.baosong_three as three_change label = "近六月中至少三个月报送业务机构数量-变动"
	,T1.baosong_one - T2.baosong_one as one_change label = "近六月中至少一个月报送业务机构数量-变动"
	,T1.HIST_SHIFOU - T2.HIST_SHIFOU as HIST_SHIFOU_change label = '历史报文加载率高于90%的机构数量-变动'
	,T1.NOW_SHIFOU - T2.NOW_SHIFOU as NOW_SHIFOU_change label = '当月报文加载率高于95%的机构数量-变动'
	,T1.per_jishi - T2.per_jishi as per_jishi_change label = '总体及时率高于80%的机构数量-变动'
	,T1.per_zhunque - T2.per_zhunque as per_zhunque_change label = '总体准确率高于80%的机构数量-变动'
	,T1.per_wanzheng - T2.per_wanzheng as per_wanzheng_change label = '总体完整率高于80%的机构数量-变动'
	from person_curr as T1
	left join person_last as T2
	on T1.person = T2.person
;
quit;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\月报结果\专管员\专管员情况统计表_&chkmonth..xlsx";
data xls.各机构情况(dblabel = yes);
set org_curr;
run;
data xls.本月专管员指标情况(dblabel = yes);
set person_curr;
run;
data xls.专管员指标变化情况(dblabel = yes);
set person_change;
run;
libname xls clear;

		
