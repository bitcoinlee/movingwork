options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*根据当前日期，自动生成STAT_OP END START 已验证 2015.03.02 更新人：李楠 可先在日志中观察结果后再使用*/
%INCLUDE "C:\Users\Data Analyst\Desktop\常用代码\自动化\000_FORMAT.sas";
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

/*累计报送、入库数量*/
/*报送数据类型*/
/*proc sql;*/
/*	create table baosong_jiekou as select*/
/*	SORGCODE*/
/*	,"接口报送" as type label = "签约类型"*/
/*	,sum(itotalcount) as itotalcount label= "报送记录数"*/
/*	,sum(isuccesscount) as isuccesscount label = "成功记录数"*/
/*	from mylib.sino_msg(keep= SORGCODE duploadtime itotalcount isuccesscount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))*/
/*	group by SORGCODE*/
/*,calculated qishu*/
/*	;*/
/*quit;*/
/*特殊交易在线录入机构*/
/*proc sql;*/
/*	create table baosong_luru as select*/
/*		sorgcode*/
/*		,"在线录入" as type label = "签约类型"*/
/*		,count(sorgcode) as itotalcount label= "报送记录数"*/
/*		,count(sorgcode) as isuccesscount label = "成功记录数"*/
/*	from mylib.Sino_LOAN_SPEC_TRADE(keep= SORGCODE dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))*/
/*	group by sorgcode*/
/*	;*/
/*quit;*/
/*计算全部报送机构*/
/*proc sql;*/
/*	create table _baosong as select*/
/*	**/
/*	from baosong_jiekou*/
/*	union*/
/*	select * */
/*	from baosong_luru*/
/*;*/
/*quit; */
/*PROC SORT DATA=_baosong OUT=_baosong nodupkey;*/
/*	BY SORGCODE;*/
/*RUN;*/
/*data _baosong;*/
/*	set _baosong;*/
/*	if sorgcode = lag(sorgcode) then delete;*/
/*run;*/

/*累计入库记录数*/
/*1.贷款申请信息*/
PROC SQL;
	CREATE TABLE ruku_SQ AS SELECT
		SORGCODE LABEL="机构代码"
		,COUNT(SAPPLYCODE) as rukucount label = "入库人次（申请）"
	FROM mylib.SINO_LOAN_APPLY(keep=sorgcode SAPPLYCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*2.贷款业务信息*/

PROC SQL;
	CREATE TABLE ruku_LOAN AS SELECT
		SORGCODE LABEL="机构代码"
		,COUNT(SACCOUNT) as rukucount label = "入库贷款记录数"
	FROM mylib.SINO_LOAN(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*3.个人身份信息*/

PROC SQL;
	CREATE TABLE ruku_SF AS SELECT
		SORGCODE  LABEL="机构代码"
		,count(spin) as rukucount label = "入库人数（身份）"
	FROM mylib.SINO_PERSON(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*4.特殊交易*/
proc sql;
	create table ruku_spec as select
		SORGCODE  LABEL="机构代码"
		,count(SACCOUNT) as rukucount label = "特殊交易数量"
	from mylib.Sino_LOAN_SPEC_TRADE(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;
proc sql;
	create table _ruku_spec as select
		SORGCODE  LABEL="机构代码"
		,count(distinct spin) as rukucount label = "入库人数(特殊)"
	from mylib.Sino_LOAN_SPEC_TRADE(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;

/*贷款金额、贷款人数、待收金额、贷款账户数*/
PROC SORT DATA=mylib.SINO_LOAN(KEEP=sorgcode SACCOUNT DGETDATE icreditlimit ibalance iaccountstat spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=LOAN_BASE0 ;
BY SORGCODE SACCOUNT descending DGETDATE;
RUN;

DATA LOAN_BASE;
	SET LOAN_BASE0;
	BY SORGCODE SACCOUNT descending DGETDATE;
	IF first.SACCOUNT;
RUN;

PROC SQL;
 	create table _loan_detail as SELECT
		sorgcode
		,count(distinct saccount) as rukuloan label = "入库账户数（贷款）"
		,round(sum(ICREDITLIMIT)/10000,0.01) as money_all LABEL="入库累计放款总额(万元)"
		,count(distinct spin) as loanperson label = "入库累计借款人数"
		,round(sum(ibalance)/10000,0.01) as money_daishou label = "入库贷款余额(万元)"
  	From LOAN_BASE
	group by sorgcode
;
QUIT;

/*5.合计*/
data ruku_total;
	set Ruku_loan;
run;
proc append base = ruku_total data= Ruku_sf force;
run;
proc append base = ruku_total data = Ruku_spec force;
run;
proc append base = ruku_total data= Ruku_sq force;
run;
proc sql;
	create table _ruku as select
	SORGCODE
	,sum(rukucount) as rukurecord label = "入库记录数（贷款、申请、身份、特殊）"
	from ruku_total
	group by sorgcode
	;
quit;
data _ruku_sf;
	set ruku_sf;
	rename 
	rukucount = ruku_sf
	;
run;

data _ruku_sq;
	set ruku_sq;
	rename 
	rukucount = ruku_sq
	;
run;
data _ruku_spec;
	set _ruku_spec;
	rename 
	rukucount = ruku_spec
	;
run;


/*计算报送期数的基准表*/
data baosong_jiekou_base;
	format duploadtime_new yymmd7.;
	set mylib.sino_msg(keep= SORGCODE duploadtime WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
	by sorgcode;
	duploadtime_new = intnx('month',datepart(duploadtime),0,'b');
	if SORGCODE=lag(SORGCODE) and duploadtime_new = lag(duploadtime_new) then delete;
	retain duploadtime_new;
	drop duploadtime;
	rename
	duploadtime_new = duploadtime;
	label
	duploadtime_new = 报送月份
	;
run;
proc sort data = baosong_jiekou_base nodup;
	by sorgcode descending duploadtime;
run;
/*总计报送期数*/
proc sql;
	create table _baosong_jiekou_qishu as select
	sorgcode
	,count(duploadtime) as qishu label= "总计报送期数"
	from baosong_jiekou_base
	group by sorgcode
	;
quit;
/*总计应报送期数 待添加*/

/*最近一次连续报数结束时间、持续期数*/
data baosong_jiekou_zuihou;
	set baosong_jiekou_base;
	retain duploadtime;
	if SORGCODE=lag(SORGCODE) and intck('month',duploadtime,lag(duploadtime)) ^= 1 then delete;
run;
/*暂时需要手动重复执行，执行至观测数不再减少为止，待更新*/
data baosong_jiekou_zuihou;
	set baosong_jiekou_zuihou;
	if SORGCODE=lag(SORGCODE) and intck('month',duploadtime,lag(duploadtime)) ^= 1 then delete;
run;
/*用于替换手动重复执行 待更新*/
/*proc sql noprint;*/
/*select count(distinct sorgcode)*/
/*into :soccount*/
/*from baosong_jiekou_base*/
/*;*/
/*select distinct sorgcode*/
/*into :soc1-:soc%left(&soccount.)*/
/*from baosong_jiekou_base*/
/*;*/
/*quit;*/
/*%put &soc200.;*/
/*%macro baosong_jiekou_zuihou;*/
/*	%do i=1 %to &soccount. %by 1;*/
/*	data &&soc&i._temp;*/
/*	set baosong_jiekou_base(where=(sorgcode = &&soc&i.));*/
/*	run;*/
/*	data &&soc&i.;*/
/*	set &&soc&i._temp;*/
/*	if intck('month',duploadtime,lag_N_(duploadtime)) ^= _N_-1 then delete;*/
/*	run;*/
/*	proc append data = baosong_jiekou_zuihou base = work.&&soc&i. force;*/
/*	run;*/
/*	proc delete work.&&soc&i._temp;*/
/*	run;*/
/*	proc delete work.&&soc&i.;*/
/*	run;*/
/*	%end;*/
/*%mend;*/
/*%baosong_jiekou_zuihou;*/


	



/*1.最近一次连续报数结束时间*/
data _baosong_zhongzhi_shijian;
	retain sorgcode;
	set baosong_jiekou_base;
	by sorgcode;
	if first.sorgcode;
	label
	duploadtime = 最近报送月份
	;
run;
/*2.最近一次连续报数持续期数*/
proc sql; 
	create table _baosong_zhongzhi_qishu as select
	sorgcode
	,count(duploadtime) as qishu_zhongzhi label="最近报数持续期数"
	from baosong_jiekou_zuihou
	group by sorgcode
	;
quit;
/*查询类数据基准数据集*/
proc sql;
	create table chaxun_base as select
	B.stoporgcode
	,A.dcreatetime
	,(case when A.IREQUESTTYPE in (0,1,2,6) then 1 else 0 end) as shifouchade
	from mylib.sino_credit_record(keep= SORGCODE dcreatetime IREQUESTTYPE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as A
	left join mylib.sino_org as B
	on A.sorgcode = B.SORGCODE
	order by stoporgcode
;
quit;
data chaxun_base;
	format chaxunriqi yymmddn8.;
	set chaxun_base;
	by stoporgcode;
	chaxunriqi = datepart(dcreatetime);
	drop
	dcreatetime
	;
	rename
	stoporgcode = sorgcode
	;
	label
	stoporgcode = 机构代码
	;
run;
	

/*第一次查询时间 最后一次查询时间*/
proc sql;
	create table _chaxun_shijian as select
	sorgcode
	,max(chaxunriqi) as _chaxun_last label = "最近一次查询时间" FORMAT= YYMMDD10. informat=YYMMDD10.
	,min(chaxunriqi) as _chaxun_first label = "第一次查询时间" format = YYMMDD10. informat=YYMMDD10.
	from chaxun_base
	group by sorgcode
	;
quit;
/*累计查询量*/
proc sql;
	create table _chaxun_leiji as select
		sorgcode
		,count(shifouchade) as chaxunliang label = "累计查询量"
		,sum(shifouchade) as chadeliang label = "累计查得量"
	from chaxun_base
	group by sorgcode
	;
quit;
/*2015年日均查询量*/
proc sql;
	create table _chaxun_2015rijun as select
	sorgcode
	,round(count(shifouchade)/&dayscount.,0.1) as rijunchaxun label = "2015年日均查询量"
	from chaxun_base(where=(chaxunriqi > &firstday.))
	group by sorgcode
	;
quit;
/*日查询峰值*/
proc sql;
	create table chaxun_fengzhi as select
		sorgcode
		,chaxunriqi
		,count(shifouchade) as richaxun label="日查询量峰值"
	from Chaxun_base
	group by sorgcode,chaxunriqi
	;
quit;
proc sort data = chaxun_fengzhi nodupkey;
	by sorgcode descending richaxun;
run;
data _chaxun_fengzhi;
	set chaxun_fengzhi;
	by sorgcode;
	if sorgcode = lag(sorgcode) and richaxun <= lag(richaxun) then delete;
	rename
	chaxunriqi = fengzhiriqi
	;
	label
	chaxunriqi = 峰值发生日期
	sorgcode = 机构代码
	;
run;

/*汇总并输出*/
proc sql;
	create table _lizong as select
		T1.sorgcode
		,T1.sorgname
		,(case when rukuloan> 0 and ruku_spec> 0 then "贷款业务+特殊交易" 
		else when rukuloan> 0 and ruku_spec= 0 or rukuloan ^='' then "贷款业务"
		else when rukuloan = 0 or rukuloan ^='' and ruku_spec > 0 then "特殊交易" else "未报送" end) as type label = "报送类型"
		,itotalcount
		,isuccesscount
		,rukurecord
/*		,rukucount*/
/*做比较用*/
		,rukuloan label = "入库贷款记录数"
		,ruku_sq
/*	`	,T18.rukucount as ruku_sq_2*/
		,ruku_sf
/*		,T17.rukucount as ruku_sf_2*/
		,ruku_spec
		,money_all
		,loanperson
		,money_daishou
		,qishu
		,duploadtime
		,qishu_zhongzhi
		,_chaxun_first
		,_chaxun_last
		,chaxunliang
		,chadeliang
		,rijunchaxun
		,richaxun
		,fengzhiriqi
/*		left join _baosong as T9*/
/*		on T1.sorgcode = T9.sorgcode*/
		from _sino_org as T1
		left join _baosong_jiekou_qishu as T2
		on T1.sorgcode = T2.sorgcode
		left join _ruku as T10
		on T1.sorgcode = T10.sorgcode
		left join _baosong_zhongzhi_shijian as T3
		on T1.sorgcode = T3.sorgcode
		left join _baosong_zhongzhi_qishu as T4
		on T1.sorgcode = T4.sorgcode
		left join _chaxun_shijian as T5
		on T1.sorgcode = T5.sorgcode
		left join _chaxun_leiji as T6
		on T1.sorgcode = T6.sorgcode
		left join _chaxun_2015rijun as T7
		on T1.sorgcode = T7.sorgcode
		left join _chaxun_fengzhi as T8
		on T1.sorgcode = T8.sorgcode
/*		left join _ruku_loan as T12*/
/*		on T1.sorgcode = T12.sorgcode*/
		left join _ruku_sf as T13
		on T1.sorgcode = T13.sorgcode
		left join _ruku_sq as T11
		on T1.sorgcode = T11.sorgcode
		left join _ruku_spec as T14
		on T1.sorgcode = T14.sorgcode
		left join _loan_detail as T15
		on T1.sorgcode = T15.sorgcode

/*		left join ruku_loan as T16*/
/*		on T1.sorgcode = T16.sorgcode*/
/*		left join ruku_sf as T17*/
/*		on T1.sorgcode = T17.sorgcode*/
/*		left join ruku_sq as T18*/
/*		on T1.sorgcode = T18.sorgcode*/

	order by (case type when '接口报送' then 1 when '在线录入' then 2 else 3 end), rukurecord desc
		;
quit;
libname xls excel "C:\Users\Data Analyst\Desktop\常用代码\自动化\结果文件夹\临时性工作\李总20150430-V1.3.xlsx";
	data xls.sheet1(dblabel=yes);
	set _lizong;
RUN;
libname xls clear;


