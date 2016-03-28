/*libname nfcs "D:\����\&curr_month.";*/
%INCLUDE "E:/�½��ļ���/SAS/���ô���/�Զ���/000_FORMAT.sas";
%include "E:/�½��ļ���/SAS/������.sas";
%include "E:/�½��ļ���/SAS/config.sas";

%let startdate = %sysfunc(mdy(3,1,2016));
%let enddate = %sysfunc(mdy(3,15,2016));
%let onemonthdate = %sysfunc(mdy(3,1,2016));
%let last_month= month(intnx('month',&enddate.,-1,'b'));
%let onemonthperiod = intck("day",&onemonthdate.,&enddate.);
/*����ȫ��������������ʱ���˹����*/
%let quanliang_org_cnt = 199;
/*ȫ��������������*/
%let ql_org_cnt_add = 3;
/*��ǩԼ������������ʱ���˹����*/
%let pot_org_cnt = 26;

%put &month.;
%put &year.;
%put y= &startdate.;
%put x= &enddate.;
%put z= &onemonthdate.;
%put zz= &onemonthperiod.;
%put x=&chkmonth.;
%put y= &curr_month.;

/*�ۼ�ǩԼ����*/
proc sql noprint;
	select count(distinct CUSTOMER_NAME) into :sign_org_cnt
		from crm1.T_contract_order(keep = CUSTOMER_NAME delete_flag EXTEND1)
	where delete_flag = 0 and EXTEND1 not in ('�ѷ���ͬ' '')
	;
quit;
/*��ǩԼ������������ʱ�˹���ȡ*/
/*proc sql noprint;*/
/*	select count(distinct CUSTOMER_NAME) into :pot_org_cnt*/
/*		from crm1.T_contract_order(keep = CUSTOMER_NAME delete_flag EXTEND1)*/
/*	where delete_flag = 0 and EXTEND1 in ('�ѷ���ͬ' '')*/
/*	;*/
/*quit;*/
%put &sign_org_cnt.;
/*%put &pot_org_cnt.;*/
/*ͳ�Ʊ�������������ⷽ���ѯ���������ɣ���������Ƿ�ɹ�*/
/*������������ͳ��*/
/*��ά�� 20150902*/

/*ȫ����������*/
proc sql;
	create table org1 as select
		distinct sorgcode as sorgcode
		,datepart(duploadtime) as dgetdate format = YYMMDDD10.
	 	FROM nfcs.sino_msg(keep= SORGCODE duploadtime WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(duploadtime) <= &enddate.))
		union
		(
		SELECT DISTINCT sorgcode as sorgcode
		,datepart(dgetdate) as dgetdate format = YYMMDDD10.
	 	FROM nfcs.Sino_LOAN_SPEC_TRADE(keep= SORGCODE dgetdate WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) <= &enddate.))
		)
		union
		(
		SELECT DISTINCT sorgcode as sorgcode
		,datepart(dgetdate) as dgetdate format = YYMMDDD10.
		 FROM nfcs.sino_loan_apply(keep= SORGCODE dgetdate WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) <= &enddate.))
		)
	order by sorgcode,dgetdate asc
;
quit;

data org1;
	set org1;
	if sorgcode = lag(sorgcode) then delete;
run;

proc sort data = org1 out=org2;
	by descending dgetdate;
run;

PROC SQL noprint;
	 SELECT count(DISTINCT(SORGCODE)) into: orgnum_1
	 FROM org1
	 where dgetdate <= &enddate.
;
QUIT;

PROC SQL noprint;
	 SELECT count(DISTINCT(SORGCODE)) into: orgnum_2
	 FROM org1
	 where dgetdate < &startdate.
;
QUIT;


%let orgnum_add= %sysevalf(&orgnum_1. - &orgnum_2.);

%put x=&orgnum_1.;
%put y=&orgnum_2.;
%put z=&orgnum_add.;
/*ͳ�ƻ�����������*/
/*PROC SQL;*/
/*	CREATE TABLE AREA AS SELECT*/
/*		DISTINCT(SUBSTR(SORGCODE,6,2)) AS AREACODE*/
/*	FROM ORG;*/
/*	;*/
/*QUIT;*/
/*ͳ�ƻ���count��*/
/*PROC SQL;*/
/*	CREATE TABLE AREACOUNT AS SELECT*/
/*		COUNT(AREACODE)+1 AS SUMAREA */
/*	FROM AREA*/
/*	;*/
/*QUIT;*/

/*ͳ�ƿͻ���*/
/*��֤��*/
PROC SQL;
	CREATE TABLE CUSTOM1 AS SELECT
/*		SNAME*/
/*		,scerttype*/
		scertno
		,dgetdate
		,spin
		,sorgcode
	FROM nfcs.sino_person_certification(keep = sorgcode scerttype scertno spin dgetdate)
	WHERE SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') 
	AND scerttype^='X' AND SUBSTR(scertno,1,1)^='0' and datepart(dgetdate) <= &enddate.
	ORDER BY spin;
QUIT;
PROC SORT DATA=CUSTOM1 NODUPRECS OUT=CUSTOM;
	 BY Spin dgetdate;
RUN;

data custom;
	set custom;
	if SPIN = LAG(SPIN) then delete;
run;
PROC SQL noprint;
	SELECT COUNT(distinct(spin)) into: custnum_1
	FROM CUSTOM
	where datepart(DGETDATE)<= &enddate.
	;
QUIT;
PROC SQL noprint;
	SELECT COUNT(distinct(spin)) into: custnum_2
	FROM CUSTOM
	where datepart(dgetdate) < &startdate.
;
QUIT;
%put x= &custnum_1.;
%put y= &custnum_2.;

data _null_;
	custadd= put(&custnum_1./&custnum_2. - 1,percent10.2);
	call symput("custadd",custadd);
run;
%put x=&custadd.;
/*���⽻������*/
DATA SPECIALTRADEPERSON;
	SET nfcs.Sino_LOAN_SPEC_TRADE(WHERE=(speculiartradetype in ('2' '6' '7' '8') and SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') AND datepart(DGETDATE)<=&enddate.));
RUN;
PROC SORT DATA=SPECIALTRADEPERSON NODUP;
	 BY SPIN;
RUN;
data SPECIALTRADEPERSON;
	set SPECIALTRADEPERSON;
	if spin = lag(spin) then delete;
run;
PROC SQL NOPRINT;
	SELECT COUNT(distinct spin) INTO: STPERNUM
	FROM SPECIALTRADEPERSON
	;
QUIT;
%PUT X=&STPERNUM.;

/*�Ŵ���¼��ͷͳ��*/
/*���е��Ŵ���¼*/
PROC SORT DATA=nfcs.sino_loan(KEEP=SORGCODE iloanid dgetdate SCERTNO SNAME SCERTTYPE SPIN icreditlimit ibalance iaccountstat WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) <= &enddate.)) out = loan1 nodup;
	BY iloanid dgetdate;
RUN;
/*�Ŵ���¼ȡ���һ��*/
DATA LOAN;
	SET LOAN1(drop = sorgcode);
	IF iloanid = lag(iloanid) then delete;
RUN;
/*ȡ��ҵ�����*/
DATA LOANCUS1;
	SET LOAN(KEEP=SCERTNO SNAME SCERTTYPE SPIN);
	IF SCERTTYPE^= 'X';
RUN;

PROC SORT DATA=LOANCUS1 NODUPRECS OUT =LOANCUS;
	BY SPIN;
RUN;
/*��ҵ�������*/
PROC SQL noprint;
	SELECT COUNT(distinct spin) into: LOANCUSnum
	FROM LOANCUS
; 
QUIT;
%put &LOANCUSnum.;
/*����ҵ���ܱ���*/
PROC SQL noprint;
	SELECT COUNT(distinct iloanid) into: LOANnum
	FROM LOAN
; 
QUIT;
%put &LOANnum.;
/*���´���ҵ���ܱ���*/
PROC SQL noprint;
	SELECT COUNT(distinct iloanid) into: LOANnum_2
	FROM LOAN
	WHERE datepart(dgetdate) < &startdate.
; 
QUIT;
%put &LOANnum_2.;
/*�����˻���������*/
data _null_;
	loan_num_inc = put(&LOANnum./&LOANnum_2. - 1,percent10.2);
	call symput("loan_num_inc",loan_num_inc);
run;
%put &loan_num_inc.;


/*�����ۼƴ�����*/
PROC SQL NOPRINT;
	SELECT round(SUM(icreditlimit)/100000000,2) INTO: LOANSUM_1
	FROM LOAN
	where datepart(DGETDATE) <= &enddate.
;
QUIT;
%put x=&LOANSUM_1.;
/*�����ۼƴ������*/
PROC SORT  DATA=nfcs.sino_loan(KEEP=SORGCODE iloanid dgetdate icreditlimit ibalance iaccountstat WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) < &enddate.)) OUT = LOAN_balance;
	BY iloanid descending dgetdate;
RUN;
DATA LOAN_balance;
	SET LOAN_balance;
	IF iloanid =lag(iloanid) then delete;
RUN;
PROC SQL NOPRINT;
	SELECT round(SUM(ibalance)/100000000,2) INTO: LOANbalance
	FROM LOAN_balance
	where datepart(DGETDATE) <= &enddate. and iaccountstat in (1,2)
;
QUIT;


/*���µ��ۼƴ�����*/
/*�Ŵ���¼ȡ���µ������һ��*/
PROC SORT  DATA=nfcs.sino_loan(KEEP=SORGCODE iloanid dgetdate icreditlimit WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) < &startdate.)) OUT=LOAN1_0;
	BY iloanid dgetdate;
RUN;
DATA LOAN_0;
	SET LOAN1_0;
	IF iloanid =lag(iloanid) then delete;
RUN;
PROC SQL NOPRINT;
	SELECT round(SUM(icreditlimit)/100000000,2) INTO: LOANSUM_2
	FROM LOAN_0
;
QUIT;
%put x=&LOANSUM_2;
/*�����ܶ�������*/
data _null_;
	loansumadd= put(&LOANSUM_1./&LOANSUM_2.-1,percent10.2);
	call symput("loansumadd",loansumadd);
run;
%put x=&loansumadd.;

/*���µ״������*/
PROC SORT  DATA=nfcs.sino_loan(KEEP=SORGCODE iloanid dgetdate icreditlimit ibalance iaccountstat WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(dgetdate) < &startdate.)) OUT = LOAN1_balance;
	BY iloanid descending dgetdate;
RUN;
DATA LOAN_0_balance;
	SET LOAN1_balance;
	IF iloanid =lag(iloanid) then delete;
RUN;

PROC SQL NOPRINT;
	SELECT round(SUM(ibalance)/100000000,2) INTO: LOANbalance_2
	FROM LOAN_0_balance
	where datepart(DGETDATE) < &startdate. and iaccountstat in (1,2)
;
QUIT;

/*�ۼƴ������������*/
data _null_;
	LOANbalanceadd = put(&LOANbalance./&LOANbalance_2. - 1,percent10.2);
	call symput("LOANbalanceadd",LOANbalanceadd);
run;
%put x=&LOANbalanceadd.;

/*�����ۼƴ���������*/
proc sort data = nfcs.sino_loan_apply(keep = sorgcode sapplycode spin dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=loan_apply_base nodup;
	by sorgcode sapplycode;
run;
data loan_apply_base;
	set loan_apply_base;
	if sorgcode = lag(sorgcode) and sapplycode = lag(sapplycode) then delete;
run;
PROC SQL NOPRINT;
	SELECT count(sorgcode) INTO: apply_count
	FROM loan_apply_base
	where datepart(DGETDATE) <= &enddate.
;
QUIT;
/*�����ۼƴ���������*/
proc sort data = nfcs.sino_loan_apply(keep = sorgcode sapplycode spin dgetdate WHERE=(datepart(dgetdate)< &startdate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=loan_apply_2 nodup;
	by sorgcode sapplycode;
run;
data loan_apply_2;
	set loan_apply_2;
	if sorgcode = lag(sorgcode) and sapplycode = lag(sapplycode) then delete;
run;

PROC SQL NOPRINT;
	SELECT count(sorgcode) INTO: apply_count_2
	FROM loan_apply_2
	where datepart(DGETDATE) < &startdate.
;
QUIT;
%put x=&apply_count_2.;

/*������������*/
data _null_;
	apply_countadd = put(&apply_count./&apply_count_2. - 1,percent10.2);
	call symput("apply_countadd",apply_countadd);
run;
%put x=&apply_countadd.;

/*�����������ϵ�����*/
DATA DUEM3;
	SET nfcs.sino_loan(KEEP=SORGCODE DGETDATE SPIN IAMOUNTPASTDUE90 IAMOUNTPASTDUE180 WHERE=(IAMOUNTPASTDUE90 ^= 0 or IAMOUNTPASTDUE180 ^= 0 AND SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and DATEPART(dgetdate)<=&enddate.));
	DROP
	SORGCODE
	DGETDATE
	IAMOUNTPASTDUE90
	IAMOUNTPASTDUE180
	;
RUN;

PROC SQL NOPRINT;
	SELECT COUNT(DISTINCT(SPIN)) INTO: M3PERNUM
	FROM DUEM3;
QUIT;
%PUT &M3PERNUM.;
/*�����ۼƳɹ������*/
proc sql noprint;
	select round(sum(itotalcount)/10000,2),round(sum(isuccesscount)/10000,2) into: totalsum_1,:succsum_1
	from nfcs.sino_msg
	where SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') AND datepart(duploadtime)<= &enddate.
;
quit;
/*���µ��ۼƳɹ������*/
proc sql noprint;
	select round(sum(isuccesscount)/10000,2) into: succsum_2
	from nfcs.sino_msg
	where SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') AND datepart(duploadtime) < &startdate.
;
quit;
/*���������ӱ���*/
data _null_;
	succaddper = put(100*(&succsum_1./&succsum_2.-1),5.2)||"%";
	call symputx("succaddper",succaddper,'G');
run;	
%put x= &succaddper.;

%put x= &totalsum_1.;
%put x= &succsum_1.;
%put x= &succsum_2.;

/*�����*/
data _null_;
/*put(x*100, 5.2)||"%";*/
	succinper=cat(put(100*&succsum_1./&totalsum_1.,5.2),"%");
	call symputx("succinper",succinper,'G');
run;
%put x=&succinper.;

/*��ѯ��������*/
PROC SQL noprint;
	SELECT count(DISTINCT(B.STOPORGCODE)) into :reqorgnum
	FROM nfcs.SINO_CREDIT_ORGPLATE as A
	left join nfcs.SINO_ORG as B
	on A.SORGCODE = B.SORGCODE
	where A.ISTATE=1;
	;
QUIT;
%put &reqorgnum.;

/*���е����ñ����ѯ��¼*/
/*���²�ѯ������*/
PROC SQL noprint;
	SELECT COUNT(sorgcode) into :currmonth_reqtotalnum
	FROM nfcs.sino_credit_record(keep = sorgcode drequesttime)
	WHERE SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and &startdate.<=datepart(drequesttime)<=&enddate.
;
QUIT;
/*���²�ѯ�õ���*/
PROC SQL noprint;
	SELECT COUNT(sorgcode) into :currmonth_reqsuccnum
	FROM nfcs.sino_credit_record(keep = sorgcode drequesttime IPERSONID)
	WHERE SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and &startdate.<=datepart(drequesttime)<=&enddate. and IPERSONID ^=0
;
QUIT;
/*���²����*/
data _null_;
	currmonth_reqper= put(&currmonth_reqsuccnum./&currmonth_reqtotalnum.,percent8.2);
	call symputx("currmonth_reqper",currmonth_reqper,'G');
run;
%put &currmonth_reqsuccnum.;
%put &currmonth_reqtotalnum.;
%put &currmonth_reqper.;

/*�ۼƲ�ѯ������*/
PROC SQL noprint;
	SELECT COUNT(sorgcode) into :reqtotalnum
	FROM nfcs.sino_credit_record(keep = sorgcode drequesttime)
	WHERE SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and datepart(drequesttime)<=&enddate.
;
QUIT;
/*�ۼƲ�ѯ�õ���*/
PROC SQL noprint;
	SELECT COUNT(SORGCODE) into :reqsuccnum
	FROM nfcs.sino_credit_record(keep = sorgcode drequesttime IPERSONID)
	WHERE SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and datepart(drequesttime)<=&enddate. and IPERSONID ^=0
;
QUIT;

/*�ۼƲ����*/
/*data _null_;*/
/*	reqper= put(&reqsuccnum./&reqtotalnum.,percent10.2);*/
/*	call symput("reqper",reqper);*/
/*run;*/
%put &reqsuccnum.;
%put &reqtotalnum.;
/*%put &reqper.;*/

/*�����վ���ѯ����*/
proc sql noprint;
	SELECT COUNT(sorgcode) into :twomonth_reqtotalnum
	FROM nfcs.sino_credit_record(keep = sorgcode drequesttime)
	WHERE SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and &onemonthdate.<= datepart(drequesttime)<= &enddate.
;
QUIT;

%put x=&twomonth_reqtotalnum.;
data _null_;
length twomonth_reqper 5.;
twomonth_reqper = &twomonth_reqtotalnum./(&onemonthperiod.+1);
call symputx("twomonth_reqper",compress(int(twomonth_reqper)),'G');
run;
%put x=&twomonth_reqper.;

/*��ֵ��Ʒ���*/
/*��ͨ������*/
proc sql noprint;
	select count(distinct stoporgcode) into : sfrz_cnt
		from nfcs.sino_org(where = (SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000','Q10152900H0001') and SQUERYAUTH = '1'))
	;
quit;
/*�ۼƲ�ѯ����-뼽�*/
proc sql noprint;
	select count(SREQUESTTYPE) into:sfrz_all
	from nfcs.CIAS_ORG_QUERY(keep = SREQUESTTYPE)
	;
quit;
/*�ۼƲ�ѯ����-���ű��ؿ�*/
proc sql noprint;
	select count(SREQUESTTYPE) into:sfrz_zx
	from nfcs.CIAS_ORG_QUERY(keep = SREQUESTTYPE where = (SREQUESTTYPE = '1'))
	;
quit;


%put &sfrz_cnt.;
%put &sfrz_all.;
%put &sfrz_zx.;


/*�������ݼ�*/
data dw.twsr;
	informat dgetdate yymmdd10. sign_org_cnt 12. pot_org_cnt 12. orgnum_add 12. orgnum_1 12. quanliang_org_cnt 12. 
	ql_org_cnt_add 12. custnum_1 12. LOANCUSnum 12. LOANnum 12. LOANSUM_1 12. LOANbalance 12. apply_count 12.
	STPERNUM 12. M3PERNUM 12. succsum_1 12. succaddper $10. succinper $10. reqorgnum 12. currmonth_reqtotalnum 12.
	currmonth_reqsuccnum 12. currmonth_reqper $10. reqtotalnum 12. reqsuccnum 12. twomonth_reqper 12.
	;
run;

/*%put  &startdate., &sign_org_cnt., &pot_org_cnt., &orgnum_add., &orgnum_1., &quanliang_org_cnt., &custnum_1.;*/
proc sql;
	insert into dw.twsr
/*(dgetdate,sign_org_cnt,pot_org_cnt,orgnum_add,orgnum_1,quanliang_org_cnt,custnum_1)*/
	values(&enddate., &sign_org_cnt., &pot_org_cnt., &orgnum_add., &orgnum_1., &quanliang_org_cnt.,
	&ql_org_cnt_add., &custnum_1., &LOANCUSnum., &LOANnum., &LOANSUM_1., &LOANbalance. ,&apply_count.,
	&STPERNUM., &M3PERNUM., &succsum_1., %unquote(&succaddper.) , &succinper. , &reqorgnum. , &currmonth_reqtotalnum. ,
	&currmonth_reqsuccnum., &currmonth_reqper. ,&reqtotalnum. ,&reqsuccnum. ,&twomonth_reqper.)
;
quit;

/*data dw.twsr;*/
/*	set dw.twsr;*/
/*	ql_org_cnt_add = dif(quanliang_org_cnt_);*/
/*run;*/

/*�������־*/
%let content = %qsysfunc(compress(%nrbquote(�������������)%qsysfunc(year(&enddate.))%nrbquote(��)%qsysfunc(month(&enddate.))%nrbquote(��)%qsysfunc(day(&enddate.))
%nrbquote(�գ������������ϵͳ�ۼ�ǩԼ����)&sign_org_cnt.%nrbquote(�ң�����)&pot_org_cnt.%nrbquote(�һ�����ǩԼ���򣻵���������������)&orgnum_add.%nrbquote(�ң����������ۼ�)&orgnum_1.%nrbquote(�ң�����)&quanliang_org_cnt.%nrbquote(�ұ�����ȫ�����ݣ�����������)
&ql_org_cnt_add.%nrbquote(�ҡ�)%nrbquote(��������ϵͳ��¼�ͻ�����)&custnum_1.%nrbquote(�ˣ���������)&custadd.%nrbquote(���д����¼������Ϊ)&LOANCUSnum.%nrbquote(�ˣ������˻��ۼ�����Ϊ)&LOANnum.%nrbquote(�ʣ���������)&loan_num_inc.
%nrbquote(���ۼƴ�����)&LOANSUM_1.%nrbquote(��Ԫ����������)&loansumadd. %nrbquote(���ۼƴ������)&LOANbalance.%nrbquote(��Ԫ����������) &LOANbalanceadd.%nrbquote(���ۼƴ���������Ϊ)&apply_count.%nrbquote(����������)&apply_countadd.
%nrbquote(����ǰ���⽻������)&STPERNUM.%nrbquote(�ˣ���ǰ�����������ϵ�����Ϊ)&M3PERNUM.%nrbquote(�ˣ�
�ۼƳɹ������)&succsum_1.%nrbquote(��������������)&succaddper. %nrbquote(����ʷƽ�������) &succinper.
%nrbquote(����ѯ�����Ϊ)&reqorgnum.%nrbquote(�һ�����ͨ�˲�ѯȨ�ޣ����²�ѯ����)&currmonth_reqtotalnum.%nrbquote(�ʣ����)&currmonth_reqsuccnum.%nrbquote(�ʣ������)&currmonth_reqper.%nrbquote(��
�ۼƲ�ѯ����)&reqtotalnum.%nrbquote(�ʣ����)&reqsuccnum.%nrbquote(�ʣ������վ���ѯ����)&twomonth_reqper.%nrbquote(�ʡ���ͨ�����֤����Ļ�������Ϊ)&sfrz_cnt.%nrbquote(�ң��ۼ�����֤��������Ϊ)
&sfrz_all.%nrbquote(�ʣ����У����ؿ���֤��������Ϊ)&sfrz_zx.%nrbquote(�ʡ�)));

%put &content.;


ods listing close;
ods rtf 
file="D:\˫�ܱ����.rtf"
author = "���";
data _null_;
%put  %qsysfunc(compress(%nrbquote(�������������)%qsysfunc(year(&enddate.))%nrbquote(��)%qsysfunc(month(&enddate.))%nrbquote(��)%qsysfunc(day(&enddate.))
%nrbquote(�գ������������ϵͳ�ۼ�ǩԼ����)&sign_org_cnt.%nrbquote(�ң�����)&pot_org_cnt.%nrbquote(�һ�����ǩԼ���򣻵���������������)&orgnum_add.%nrbquote(�ң����������ۼ�)&orgnum_1.%nrbquote(�ң�����)&quanliang_org_cnt.%nrbquote(�ұ�����ȫ�����ݣ�����������)
&ql_org_cnt_add.%nrbquote(�ҡ�)%nrbquote(��������ϵͳ��¼�ͻ�����)&custnum_1.%nrbquote(�ˣ���������)&custadd.%nrbquote(���д����¼������Ϊ)&LOANCUSnum.%nrbquote(�ˣ������˻��ۼ�����Ϊ)&LOANnum.%nrbquote(�ʣ���������)&loan_num_inc.
%nrbquote(���ۼƴ�����)&LOANSUM_1.%nrbquote(��Ԫ����������)&loansumadd. %nrbquote(���ۼƴ������)&LOANbalance.%nrbquote(��Ԫ����������) &LOANbalanceadd.%nrbquote(���ۼƴ���������Ϊ)&apply_count.%nrbquote(����������)&apply_countadd.
%nrbquote(����ǰ���⽻������)&STPERNUM.%nrbquote(�ˣ���ǰ�����������ϵ�����Ϊ)&M3PERNUM.%nrbquote(�ˣ�
�ۼƳɹ������)&succsum_1.%nrbquote(��������������)&succaddper. %nrbquote(����ʷƽ�������) &succinper.
%nrbquote(����ѯ�����Ϊ)&reqorgnum.%nrbquote(�һ�����ͨ�˲�ѯȨ�ޣ����²�ѯ����)&currmonth_reqtotalnum.%nrbquote(�ʣ����)&currmonth_reqsuccnum.%nrbquote(�ʣ������)&currmonth_reqper.%nrbquote(��
�ۼƲ�ѯ����)&reqtotalnum.%nrbquote(�ʣ����)&reqsuccnum.%nrbquote(�ʣ������վ���ѯ����)&twomonth_reqper.%nrbquote(�ʡ���ͨ�����֤����Ļ�������Ϊ)));
run;
ods rtf close;
ods listing;

/*ods select none; �ܹŹ֡� ;*/
/*proc print data=a(obs=1);run;ĳЩ���̣��˴���������proc print �� ���û����Щ���̣��򲻻ỻҳ�����*/
/*�������м���һЩ���ݴ������proc freq������ǰ���ods select none������Ҫ�� */
/*ods select all;*/
/*ods rtf text=&quot;�ڶ�����&quot;;*/
/*proc print data=a(obs=1);run; * ���� ��Ҫ��� ;*/

/*data txt;*/
/*   txt="&content.\par efg'";*/
/*run;*/
/*ods escapechar='~';*/
/*ods listing close;*/
/*ods rtf body="D:\tst.rtf";*/
/*proc report data=content nowd;*/
/*   column content;*/
/*   define content/display;*/
/*run;*/
/*ods rtf close;*/
/*ods listing;*/
