options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
%let jiezhiriqi = mdy(3,31,2015);
DATA heliu_yuqi;
	SET mylib.SINO_LOAN(keep= sorgcode saccount dgetdate dbillingdate scertno icreditlimit iamountpastdue Iamountpastdue30 Iamountpastdue60 Iamountpastdue90 Iamountpastdue180 iaccountstat WHERE=(datepart(dgetdate) < &jiezhiriqi. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
RUN;

PROC SORT DATA=heliu_yuqi;
	BY SORGCODE SACCOUNT descending dbillingdate;
RUN;

data heliu_yuqi;
	set heliu_yuqi;
	if sorgcode=lag(sorgcode) and saccount = lag(saccount) then delete;
run;
data _heliu_yuqi;
	retain DGETDATE scertno icreditlimit iamountpastdue Iamountpastdue0;
	set heliu_yuqi;
	drop
	SORGCODE
	saccount
	DBILLINGDATE
	;
	Iamountpastdue0 = iamountpastdue - Iamountpastdue30 - Iamountpastdue60 - Iamountpastdue90 - Iamountpastdue180;
	label
	DGETDATE = 报送时间
	scertno = 证件号码
	icreditlimit = 授信额度
	iamountpastdue = 当前逾期总额
	Iamountpastdue0 = 逾期0-30天未归还贷款本金
	Iamountpastdue30 = 逾期31-60天未归还贷款本金
	Iamountpastdue60 = 逾期61-90天未归还贷款本金
	Iamountpastdue90 = 逾期91-180天未归还贷款本金
	Iamountpastdue180 = 逾期180天以上未归还贷款本金
	iaccountstat = 账户状态
	;
run;

/*人数*/
proc sql;
create table renshu_heliu as select
	spin
	,intnx("month",datepart(dgetdate),0,"b") as yuefen format = yymmd7.
	from mylib.sino_person_certification(keep = spin dgetdate sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
;
quit;

libname xls excel "C:\Users\Data Analyst\Desktop\常用代码\自动化\结果文件夹\临时性工作\何柳\逾期情况-V3.0.xlsx";
data xls.sheet2(dblabel=yes);
set _heliu_yuqi;
run;
libname xls clear;

/*proc sql;*/
/*	create table aaa as */
/*	select */
/*		* */
/*	from mylib.sino_org as a*/
/*	where a.sorgname like '%汇邦%'*/
/*	;*/
/*quit;*/
/**/
/*Q10154900HL000*/
/**/
/*proc sql;*/
/*	create table bbb as */
/*	select*/
/*		**/
/*	from mylib.sino_credit_record*/
/*	where SORGCODE='Q10154900HL000';*/
/*quit;*/
/**/
/**/
/*proc sql;*/
/*	create tale */

