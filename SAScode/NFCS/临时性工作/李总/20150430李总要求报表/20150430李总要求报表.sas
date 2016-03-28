options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
%INCLUDE "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\000_FORMAT.sas";
%FORMAT;
%let firstday = mdy(1,1,2015);
%let dayscount = intck('day',&firstday.,today());

/*ǩԼ��������*/
data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set mylib.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="��������"
		,T2.sorgname as sorgname label="��������"
/*		,T1.sareacode label="����ʡ�д���"*/
		from sino_org2 as T1 left join mylib.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q";
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;

/*�ۼƱ��͡��������*/
/*������������*/
/*proc sql;*/
/*	create table baosong_jiekou as select*/
/*	SORGCODE*/
/*	,"�ӿڱ���" as type label = "ǩԼ����"*/
/*	,sum(itotalcount) as itotalcount label= "���ͼ�¼��"*/
/*	,sum(isuccesscount) as isuccesscount label = "�ɹ���¼��"*/
/*	from mylib.sino_msg(keep= SORGCODE duploadtime itotalcount isuccesscount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))*/
/*	group by SORGCODE*/
/*,calculated qishu*/
/*	;*/
/*quit;*/
/*���⽻������¼�����*/
/*proc sql;*/
/*	create table baosong_luru as select*/
/*		sorgcode*/
/*		,"����¼��" as type label = "ǩԼ����"*/
/*		,count(sorgcode) as itotalcount label= "���ͼ�¼��"*/
/*		,count(sorgcode) as isuccesscount label = "�ɹ���¼��"*/
/*	from mylib.Sino_LOAN_SPEC_TRADE(keep= SORGCODE dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))*/
/*	group by sorgcode*/
/*	;*/
/*quit;*/
/*����ȫ�����ͻ���*/
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

/*�ۼ�����¼��*/
/*1.����������Ϣ*/
PROC SQL;
	CREATE TABLE ruku_SQ AS SELECT
		SORGCODE LABEL="��������"
		,COUNT(SAPPLYCODE) as rukucount label = "����˴Σ����룩"
	FROM mylib.SINO_LOAN_APPLY(keep=sorgcode SAPPLYCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*2.����ҵ����Ϣ*/

PROC SQL;
	CREATE TABLE ruku_LOAN AS SELECT
		SORGCODE LABEL="��������"
		,COUNT(SACCOUNT) as rukucount label = "�������¼��"
	FROM mylib.SINO_LOAN(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*3.���������Ϣ*/

PROC SQL;
	CREATE TABLE ruku_SF AS SELECT
		SORGCODE  LABEL="��������"
		,count(spin) as rukucount label = "�����������ݣ�"
	FROM mylib.SINO_PERSON(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*4.���⽻��*/
proc sql;
	create table ruku_spec as select
		SORGCODE  LABEL="��������"
		,count(SACCOUNT) as rukucount label = "���⽻������"
	from mylib.Sino_LOAN_SPEC_TRADE(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;
proc sql;
	create table _ruku_spec as select
		SORGCODE  LABEL="��������"
		,count(distinct spin) as rukucount label = "�������(����)"
	from mylib.Sino_LOAN_SPEC_TRADE(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	group by sorgcode
;
quit;

/*������������������ս������˻���*/
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
		,count(distinct saccount) as rukuloan label = "����˻��������"
		,round(sum(ICREDITLIMIT)/10000,0.01) as money_all LABEL="����ۼƷſ��ܶ�(��Ԫ)"
		,count(distinct spin) as loanperson label = "����ۼƽ������"
		,round(sum(ibalance)/10000,0.01) as money_daishou label = "���������(��Ԫ)"
  	From LOAN_BASE
	group by sorgcode
;
QUIT;

/*5.�ϼ�*/
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
	,sum(rukucount) as rukurecord label = "����¼����������롢��ݡ����⣩"
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


/*���㱨�������Ļ�׼��*/
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
	duploadtime_new = �����·�
	;
run;
proc sort data = baosong_jiekou_base nodup;
	by sorgcode descending duploadtime;
run;
/*�ܼƱ�������*/
proc sql;
	create table _baosong_jiekou_qishu as select
	sorgcode
	,count(duploadtime) as qishu label= "�ܼƱ�������"
	from baosong_jiekou_base
	group by sorgcode
	;
quit;
/*�ܼ�Ӧ�������� �����*/

/*���һ��������������ʱ�䡢��������*/
data baosong_jiekou_zuihou;
	set baosong_jiekou_base;
	retain duploadtime;
	if SORGCODE=lag(SORGCODE) and intck('month',duploadtime,lag(duploadtime)) ^= 1 then delete;
run;
/*��ʱ��Ҫ�ֶ��ظ�ִ�У�ִ�����۲������ټ���Ϊֹ��������*/
data baosong_jiekou_zuihou;
	set baosong_jiekou_zuihou;
	if SORGCODE=lag(SORGCODE) and intck('month',duploadtime,lag(duploadtime)) ^= 1 then delete;
run;
/*�����滻�ֶ��ظ�ִ�� ������*/
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


	



/*1.���һ��������������ʱ��*/
data _baosong_zhongzhi_shijian;
	retain sorgcode;
	set baosong_jiekou_base;
	by sorgcode;
	if first.sorgcode;
	label
	duploadtime = ��������·�
	;
run;
/*2.���һ������������������*/
proc sql; 
	create table _baosong_zhongzhi_qishu as select
	sorgcode
	,count(duploadtime) as qishu_zhongzhi label="���������������"
	from baosong_jiekou_zuihou
	group by sorgcode
	;
quit;
/*��ѯ�����ݻ�׼���ݼ�*/
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
	stoporgcode = ��������
	;
run;
	

/*��һ�β�ѯʱ�� ���һ�β�ѯʱ��*/
proc sql;
	create table _chaxun_shijian as select
	sorgcode
	,max(chaxunriqi) as _chaxun_last label = "���һ�β�ѯʱ��" FORMAT= YYMMDD10. informat=YYMMDD10.
	,min(chaxunriqi) as _chaxun_first label = "��һ�β�ѯʱ��" format = YYMMDD10. informat=YYMMDD10.
	from chaxun_base
	group by sorgcode
	;
quit;
/*�ۼƲ�ѯ��*/
proc sql;
	create table _chaxun_leiji as select
		sorgcode
		,count(shifouchade) as chaxunliang label = "�ۼƲ�ѯ��"
		,sum(shifouchade) as chadeliang label = "�ۼƲ����"
	from chaxun_base
	group by sorgcode
	;
quit;
/*2015���վ���ѯ��*/
proc sql;
	create table _chaxun_2015rijun as select
	sorgcode
	,round(count(shifouchade)/&dayscount.,0.1) as rijunchaxun label = "2015���վ���ѯ��"
	from chaxun_base(where=(chaxunriqi > &firstday.))
	group by sorgcode
	;
quit;
/*�ղ�ѯ��ֵ*/
proc sql;
	create table chaxun_fengzhi as select
		sorgcode
		,chaxunriqi
		,count(shifouchade) as richaxun label="�ղ�ѯ����ֵ"
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
	chaxunriqi = ��ֵ��������
	sorgcode = ��������
	;
run;

/*���ܲ����*/
proc sql;
	create table _lizong as select
		T1.sorgcode
		,T1.sorgname
		,(case when rukuloan> 0 and ruku_spec> 0 then "����ҵ��+���⽻��" 
		else when rukuloan> 0 and ruku_spec= 0 or rukuloan ^='' then "����ҵ��"
		else when rukuloan = 0 or rukuloan ^='' and ruku_spec > 0 then "���⽻��" else "δ����" end) as type label = "��������"
		,itotalcount
		,isuccesscount
		,rukurecord
/*		,rukucount*/
/*���Ƚ���*/
		,rukuloan label = "�������¼��"
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

	order by (case type when '�ӿڱ���' then 1 when '����¼��' then 2 else 3 end), rukurecord desc
		;
quit;
libname xls excel "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����20150430-V1.3.xlsx";
	data xls.sheet1(dblabel=yes);
	set _lizong;
RUN;
libname xls clear;


