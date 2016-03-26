options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then
call symput('chkmonth',cat(put(year(today())-1,$4.),put(12,$2.)));
else call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%put x=&chkmonth.;
libname nfcs "D:\数据\&chkmonth.\";

/*根据当前日期，自动生成STAT_OP END START 已验证 2015.03.02 更新人：李楠 可先在日志中观察结果后再使用*/
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";
%format;
%let enddate = mdy(11,30,2015);
%chkfile(E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\双周报结果\&chkmonth.);
/*人数*/
PROC SQL;
	CREATE TABLE zkb_renshu AS SELECT
		intnx('month',datepart(dgetdate),0,'b') as yuefen label = "月份" format = yymmn6.
		,count(spin) as rukucount label = "入库总人数"
	FROM nfcs.SINO_PERSON_certification(keep=sorgcode spin dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY calculated yuefen
;
QUIT;

proc sort data=nfcs.SINO_PERSON_certification(keep= sorgcode scerttype scertno dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=zkb_weizhi nodup;
by scertno dgetdate;
run;

data zkb_weizhi;
	set zkb_weizhi;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '其他';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '其他';
run;

proc sql;
	create table _zkb_weizhi as select
	weizhi label = "省份"
	,count(weizhi) as weizhi_person label = "入库人数"
	from zkb_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;

/*有信贷记录的人数 贷款总笔数 贷款总额 信贷人身份证首次开立地址*/
PROC SORT DATA=nfcs.SINO_LOAN(KEEP= iloanid sorgcode DGETDATE icreditlimit imaxtermspastdue spin scerttype scertno WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=zkb_LOAN_BASE nodupkey;
	BY iloanid DGETDATE;
RUN;
data zkb_LOAN_BASE;
	set zkb_LOAN_BASE(drop = sorgcode);
	if iloanid = lag(iloanid) then delete;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '其他';
run;
PROC SQL;
	CREATE TABLE zkb_loan_renshu AS SELECT
		intnx('month',datepart(dgetdate),0,'b') as yuefen label = "月份" format = yymmn6.
		,COUNT(distinct spin) as loan_renshu label = "有贷款记录人数"
		,count(distinct iloanid) as rukuloan label = "贷款业务笔数（贷款）"
		,round(sum(ICREDITLIMIT)/10000,0.01) as money_all LABEL="贷款总额(万元)"
	FROM zkb_LOAN_BASE
	GROUP BY calculated yuefen
;
QUIT;
data zkb_loan_renshu;
	set zkb_loan_renshu;
	retain loan_renshu_accm;
	loan_renshu_accm = sum(loan_renshu_accm,loan_renshu);
label
loan_renshu_accm = 累计有贷款记录人数
;
run;
data zkb_loan_renshu;
retain yuefen loan_renshu loan_renshu_accm;
	set zkb_loan_renshu;
run;
proc sql;
	create table zkb_account_weizhi as select
		weizhi label = "省份"
		,count(weizhi) as weizhi_person label = "借款人数"
	from zkb_LOAN_BASE
	group by weizhi
	order by weizhi_person desc
;
quit;

proc sql;
	create table _zkb_yuqi as select
		weizhi label = "省份"
		,count(weizhi) as weizhi_person label = "借款人数"
	from zkb_LOAN_BASE
	where imaxtermspastdue >= 3
	group by weizhi
	order by weizhi_person desc
;
quit;

	

/*贷款申请人按身份证*/
proc sort data = nfcs.sino_loan_apply(keep= sorgcode scerttype scertno dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=zkb_apply_weizhi nodup;
by scertno dgetdate;
run;

data zkb_apply_weizhi;
	set zkb_apply_weizhi;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '其他';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '其他';
run;

proc sql;
	create table _zkb_apply_weizhi as select
	weizhi label = "省份"
	,count(weizhi) as weizhi_person label = "入库人数"
	from zkb_apply_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;

/*特殊交易人数*/
PROC SORT DATA=nfcs.Sino_LOAN_SPEC_TRADE(KEEP=sorgcode DGETDATE spin scerttype scertno WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=zkb_spec_BASE nodup;
	BY SORGCODE spin DGETDATE;
RUN;
data zkb_spec_BASE;
	set zkb_spec_BASE;
	if sorgcode = lag(sorgcode) and spin = lag(spin) then delete;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '其他';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '其他';

run;
proc sql;
	create table zkb_spec_renshu as select
/*		put(datepart(dgetdate),yymmn6.) as yuefen label = "月份"*/
		intnx('month',datepart(dgetdate),0,'b') as yuefen label = "月份" format = yymmn6.
		,count(distinct spin) as spec_renshu label = "特殊交易人数"
	from zkb_spec_BASE
	group by calculated yuefen
;
quit;

proc sql;
	create table _zkb_spec_weizhi as select
	weizhi label = "省份"
	,count(weizhi) as weizhi_person label = "入库人数"
	from zkb_apply_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;


/*查询、查得量*/
proc sql;
	create table zkb_cx as select
		intnx('month',datepart(dcreatetime),0,'b') as yuefen label = "月份" format = yymmn6.
		,intck('day',calculated yuefen,intnx('month',datepart(calculated yuefen),0,'e')) as tianshu label = "该月天数"
		,count(distinct iid) as chaxun_count label = "查询量"
		,sum(case when IREQUESTTYPE IN (0,1,2,6) then 1 else 0 end) as chade_count label = "查得量"
		from nfcs.sino_credit_record(keep = iid dcreatetime IREQUESTTYPE sorgcode WHERE=(datepart(dcreatetime)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
		group by calculated yuefen
		;
quit;

/*新增签约机构*/
proc sql;
	create table sino_log_org as select
	intnx('month',datepart(ttime),0,'b') as yuefen label = "月份" format = yymmn6.
	,substr(SDESCRIPTION,19,14) as sorgcode label = "机构代码" format = $14.
	,substr(calculated sorgcode,11,1) as nfcs_flag format = $1.
/*	新增机构信息(主键=Q10156500H8P00)*/
	from nfcs.sino_log(keep = SDESCRIPTION ttime where = (substr(SDESCRIPTION,1,12) = "新增机构信息" and datepart(ttime)<= &enddate. and substr(SDESCRIPTION,31,2) ='00' AND substr(SDESCRIPTION,19,14) not in ('Q10152900H0000' 'Q10152900H0001') and substr(SDESCRIPTION,19,1) ='Q'))
/*	where calculated %sysfunc(upcase(substr(calculated sorgcode,11,1))) ^= substr(sorgcode,11,1)*/
;
quit;
proc sort data = sino_log_org;
by sorgcode yuefen;
run;
data sino_log_org;
	set sino_log_org;
	if sorgcode = lag(sorgcode) then delete;
run;
proc sort data = sino_log_org;
by yuefen;
run;

proc sql;
	create table org_add as select
	yuefen
	,count(sorgcode) as org_add label = "当月新增签约机构"
	from sino_log_org
	group by yuefen
;
quit;

/*各月份首次报数机构*/
proc sort data = nfcs.sino_msg(keep = sorgcode DUPLOADTIME WHERE=(datepart(DUPLOADTIME)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_msg_1;
by sorgcode DUPLOADTIME;
run;
data sino_msg_1;
	set sino_msg_1;
	if sorgcode = lag(sorgcode) then delete;
run; 
proc sql;
	create table org_bs as select
	intnx('month',datepart(DUPLOADTIME),0,'b') as yuefen label = "月份" format = yymmn6.
	,count(distinct sorgcode) as org_bs label = "首次报数机构"
from sino_msg_1
	group by calculated yuefen
;
quit;
data org_bs;
	set org_bs;
	retain org_bs_accm;
	org_bs_accm = sum(org_bs_accm,org_bs);
label
org_bs_accm = 累计首次报数机构
;
run;


/*输出*/
proc sql;
	create table _zkb as select
	T1.yuefen
	,T6.*
/*	,T5.org_add*/
	,T1.rukucount
	,T2.*
	,T3.spec_renshu
/*	,T4.**/
	,(T4.chade_count/T4.chaxun_count) as cd_per label = "当月查得率" format = percent8.2
	,round(T4.chaxun_count/31,1) as cx_avg label = "当月日均查询量"
	from zkb_renshu as T1
	left join zkb_loan_renshu as T2
	on T1.yuefen = T2.yuefen
	left join zkb_spec_renshu as T3
	on T1.yuefen = T3.yuefen
	left join zkb_cx as T4
	on T1.yuefen = T4.yuefen
	left join org_add as T5
	on T1.yuefen = T5.yuefen
	left join org_bs as T6
	on T1.yuefen = T6.yuefen

;
quit;


libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\双周报结果\&chkmonth.\双周简报附表_&chkmonth..xlsx";
	data xls.'汇总表'n(dblabel=yes);
	set _zkb;
RUN;
/*	data xls.'各地区入库人数-按身份证'n(dblabel=yes);*/
/*	set _zkb_weizhi;*/
/*RUN;*/
	data xls.'申请地区分布-按身份证'n(dblabel=yes);
	set _zkb_apply_weizhi;
RUN;
	data xls."开户地区分布-按身份证"n(dblabel=yes);
	set zkb_account_weizhi;
RUN;
data xls."逾期-按身份证"n(dblabel=yes);
	set _zkb_yuqi;
RUN;
libname xls clear;

/*PROC EXPORT DATA=Work._zkb*/
/*OUTFILE="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\双周报结果\201512\双周简报附表_201512.csv"*/
/*DBMS= csv*/
/*label*/
/*REPLACE;*/
/*RUN;*/

/*加入DDE调用VBA，将工作簿中所有表的第一列设为年月格式*/


/*proc sgplot;*/
	


