%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
%format;
/*机构名称*/
data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set nfcs.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="机构代码"
		,T2.sorgname as sorgname label="机构名称"
/*		,T1.sareacode label="机构省市代码"*/
		from sino_org2 as T1 left join nfcs.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q" AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001');
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;

/*贷款业务表*/
proc sort data = nfcs.sino_loan(keep = sorgcode iloanid sloantype sareacode ddateopened ddateclosed icreditlimit iguaranteeway stermsfreq smonthduration dbillingdate itermspastdue imaxtermspastdue iaccountstat Spaystat24month spin where = (SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_loan;
	by sorgcode iloanid descending dbillingdate;
run;
data sino_loan;
	set sino_loan;
	if iloanid = lag(iloanid) and put(datepart(dbillingdate),$6.) = lag(put(datepart(dbillingdate),$6.)) then delete;
run;

/*选择及时性较好的逾期贷款业务*/
proc sql;
	create table loan_count_2 as select
		iloanid
		,count(*) as record_count
		,1-((input(smonthduration,2.) - calculated record_count)/input(smonthduration,2.)) as jishixing
	from sino_loan
	where iaccountstat in (1,2)
	group by iloanid
	having calculated jishixing between 0 and 1
;
run;
data loan_count_2;
	set loan_count_2;
	if iloanid = lag(iloanid) then delete;
	if jishixing < 0.9 or record_count < 6 then delete;
run;
proc sort data = loan_count_2;
	by descending jishixing descending record_count;
run;

/*正常贷款业务*/
proc sql;
	create table sino_loan_1 as select
		*
		from sino_loan
		where iloanid in (select iloanid from loan_count_2) and iaccountstat =1
;
quit;
data sino_loan_1;
	set sino_loan_1;
	if iloanid = lag(iloanid) then delete;
	if substr(Spaystat24month,24,1) ^= 'N' then delete;
run;
/*抽样*/
proc sort data = sino_loan_1;
	by SAREACODE;
run;
proc surveyselect data=sino_loan_1 out=sino_loan_1 method=srs samprate=0.06;  
strata SAREACODE;
run;

/*逾期贷款业务*/
proc sql;
	create table sino_loan_2 as select
		*
		from sino_loan
		where iloanid in (select iloanid from loan_count_2) and iaccountstat = 2
;
quit;
data sino_loan_2;
	retain SAREACODE;
	set sino_loan_2;
run;
/*已结清业务*/
data sino_loan_3;
	set sino_loan;
	if iloanid = lag(iloanid) then delete;
	if substr(Spaystat24month,24,1) ^= 'C' or iaccountstat ^= 3 or INDEXC(Spaystat24month,'*','N','1','C') >=12 then delete;
run;
/*选择及时性较好的已结清贷款业务*/
proc sort data = sino_loan_3;
	by SAREACODE;
run;
proc surveyselect data=sino_loan_3 out=sino_loan_3 method=srs samprate=0.007;  
strata SAREACODE;
run;
/*汇总*/
proc sql;
	create table _sino_loan_temp as select
		*
		from sino_loan_1
		union
		(select
		*
		from sino_loan_2)
		union
		(select
		*
		from sino_loan_3)
;
quit;
data _sino_loan_temp;
	set _sino_loan_temp;
	SAREACODE_NEW = put(substr(SAREACODE,1,2),$PROV_LEVEL.);
	SLOANTYPE_NEW = put(SLOANTYPE,$loan_level.);
	IGUARANTEEWAY_NEW = PUT(IGUARANTEEWAY,$Guar_level.);
	STERMSFREQ_NEW = PUT(STERMSFREQ,$Repay_freq.);
/*	IACCOUNTSTAT_NEW = PUT(IACCOUNTSTAT,$ACCOUNT_STAT.);*/
DROP
/*IACCOUNTSTAT*/
SAREACODE
SORGCODE
SLOANTYPE
IGUARANTEEWAY
STERMSFREQ
;
RENAME
/*IACCOUNTSTAT_NEW = IACCOUNTSTAT */
SAREACODE_NEW = SAREACODE
SLOANTYPE_NEW = SLOANTYPE
IGUARANTEEWAY_NEW = IGUARANTEEWAY
STERMSFREQ_NEW = STERMSFREQ
;
RUN;
DATA _sino_loan;
	retain iaccountstat iloanid sloantype sareacode ddateopened ddateclosed icreditlimit iguaranteeway stermsfreq smonthduration dbillingdate itermspastdue imaxtermspastdue Spaystat24month;
	set _sino_loan_temp;
label 
iaccountstat = 账户状态
iloanid = 贷款业务ID
sloantype = 贷款类别
sareacode = 发生地点
ddateopened = 开户日期
ddateclosed =到期日期
icreditlimit = 授信额度
iguaranteeway = 担保方式
stermsfreq = 还款频率
smonthduration = 还款月数
dbillingdate = 结算/应还款日期
itermspastdue = 累计逾期期数
imaxtermspastdue = 最高逾期期数
Spaystat24month = 24个月还款状态
;
run;
proc sort data = _sino_loan;
	by iaccountstat iloanid;
run;

/*贷款申请*/
data sino_loan_apply;
	set nfcs.sino_loan_apply;
	if _n_ > 200 then delete;
	keep
	sapplycode
	stype
	Imoney
	imonthcount
	sstate
	;
run;
data _sino_loan_apply;
	set sino_loan_apply;
	label
	sapplycode = 贷款申请号
	stype = 贷款申请类型
	Imoney = 贷款申请金额
	imonthcount = 贷款申请月数
	sstate = 贷款申请状态
	;
run;


/*个人基本信息*/
proc sql;
	create table sino_person as select
	T1.spin
/*	,T3.sname*/
/*	,T3.scertno*/
	,T1.dgetdate
	,t1.igender
	,t1.dbirthday
	,t1.imarriage
	,t1.iedulevel
	,t2.soccupation
	from nfcs.sino_person as T1
	left join nfcs.sino_person_employment as T2
	on T1.spin = T2.spin and t1.dgetdate = T2.dgetdate
/*	left join nfcs.sino_person_certification as T3*/
/*	on T1.spin = T3.spin and t1.dgetdate = T3.dgetdate*/
/*	where T3.scertno is not null*/
	order by spin
;
quit;

data sino_person;
	set sino_person;
	imarriage_new = put(imarriage,MARRIAGE_TYPE.);
	iedulevel_new = put(iedulevel,EDU_TYPE.);
	SOCCUPATION_NEW = PUT(SOCCUPATION,$OCCUPATION_TYPE.);
DROP
imarriage
iedulevel
SOCCUPATION
;
rename
imarriage_new = imarriage
iedulevel_new = iedulevel
SOCCUPATION_NEW = SOCCUPATION
;
run;

proc sort data = sino_person nodupkey;
	by spin descending dgetdate;
run;
data sino_person;
	set sino_person;
	if spin = lag(spin) then delete;
drop 
dgetdate
;
label
/*SNAME = 姓名*/
/*SCERTNO = 证件号码*/
IGENDER = 性别
DBIRTHDAY = 出生日期
imarriage = 婚姻状况
iedulevel = 学历
SOCCUPATION = 职业
;
run; 

/*总输出*/
proc sql;
	create table zhangwu as select
		T1.*
		,T2.*
	from _sino_loan as T1
	left join sino_person as T2
	ON T1.spin = T2.spin
;
quit;

proc sort data= zhangwu;
	by iloanid dbillingdate;
run;

data _zhangwu;
	set zhangwu;
	drop
	SPIN
	SamplingWeight
	SelectionProb
	;
run;


libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\张旿\20151028.xlsx";
	data xls.sheet1(dblabel = yes);
	set _zhangwu;
/*	data xls.sheet2(dblabel = yes);*/
/*	set _sino_loan_apply;*/
/*	data xls.sheet3(dblabel = yes);*/
/*	set sino_person;*/
run;
libname xls clear;




