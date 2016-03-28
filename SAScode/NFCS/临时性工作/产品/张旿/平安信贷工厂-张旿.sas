options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
%LET PATH=C:\Users\Data Analyst\Desktop\���ô���;
%LET PATH_000="&PATH.\�Զ���\000_FORMAT.sas";
%INCLUDE &PATH_000.;
%FORMAT;
PROC IMPORT OUT= WORK.pingan 
DATAFILE= "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\����ļ���\��ʱ�Թ���\ƽ���Ŵ�����-�ŕJ\�Ϻ��������Ų�������.xls" 
DBMS=EXCEL REPLACE;
RANGE="Sheet1$"; 
GETNAMES=YES;
MIXED=YES;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;
proc sort data = pingan;
 by scertno;
run;
data pingan;
	set pingan;
	if scertno = lag(scertno) then delete;
	scerttype_temp = put(scerttype,$2.);
	drop
	scerttype
	;
	rename
	scerttype_temp = scerttype
	;
run;

proc sql;
	create table pingan_mapping as select
		T1.*
		,T2.spin
		,(case when T2.spin is null then "��" else "��" end) as yesno label = "ƥ����"
		from pingan as T1
		left join mylib.Sino_person_certification as T2
		on strip(T1.name) = strip(T2.sname) and strip(T1.scerttype) = strip(T2.SCERTTYPE) and strip(T1.scertno) = strip(T2.SCERTNO)
	;
quit;

/*�������벿��*/
proc sort data = mylib.Sino_loan_apply(keep = spin sorgcode sapplycode ddate imoney sstate) out = pingan_apply nodup;
	by spin descending ddate;
run;
data pingan_apply_1;
	format org_count_apply 2. apply_count 2. final_date_apply yymmddd10.;
	set pingan_apply;
		org_count_apply = 1;
		if spin = lag(spin) and sorgcode ^= lag(sorgcode) then org_count_apply = org_count_apply + 1;
		if SSTATE = 1 then apply_count = 1;
		else apply_count = 0;
		if lag(SSTATE) = 1 and SSTATE ^= 1 and SAPPLYCODE = lag(SAPPLYCODE) then apply_count = -1;
		else apply_count = apply_count;
		final_date_apply = datepart(ddate);
	label
		org_count_apply = �ۼ����������
		final_date_apply = ���һ������ʱ��
	;
run;
data pingan_apply_2;
	set pingan_apply_1(keep = spin final_date_apply imoney);
		if spin = lag(spin) then delete;
	label
		imoney = ���һ��������
	;
run;

/*����ҵ�񲿷�*/
proc sort DATA=mylib.SINO_LOAN(KEEP=sorgcode ddateopened icreditlimit spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=pingan_LOAN_BASE_1 nodup;
	BY SPIN ddateopened;
RUN;

proc sql;
	create table Pingan_loan_0 as select
		spin
		,min(datepart(DDATEOPENED)) as DDATEOPENED format = yymmddd10. label = "��ʷ�״�����"
		,max(icreditlimit) as icreditlimit_his label ="��ʷ������Ŷ��"
	from Pingan_loan_base_1
	group by spin
	;
quit;

PROC SORT DATA=mylib.SINO_LOAN(KEEP=sorgcode SACCOUNT sareacode sloantype ddateopened dbillingdate icreditlimit ibalance iamountpastdue itermspastdue imaxtermspastdue ITREATYPAYAMOUNT iaccountstat spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=pingan_LOAN_BASE;
	BY SORGCODE SACCOUNT descending dbillingdate;
RUN;

data pingan_LOAN_BASE_2;
	format ddateopened_temp yymmddd10. dbillingdate_temp yymmddd10.;
	set pingan_LOAN_BASE;
	ddateopened_temp = datepart(ddateopened);
	dbillingdate_temp = datepart(dbillingdate);
	if sorgcode = lag(sorgcode) and SACCOUNT = lag(SACCOUNT) and spin = lag(spin) then delete;
	drop
	ddateopened dbillingdate
	;
	rename
	ddateopened_temp = ddateopened
	dbillingdate_temp = dbillingdate
	;
run;

PROC SQL;
	CREATE TABLE pingan_loan_1 AS SELECT
		spin
/*		,sareacode as sareacode label = "�����ֲ�"*/
		,PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.) as sareacode_group label = "�����ֲ�(��ʡ)"
		,PUT(SLOANTYPE,$LOAN_LEVEL.) as sloantype_group label = "�������"
/*		,sloantype as sloantype label = "�������"*/
		,count(distinct catx(sorgcode,saccount)) as loan_count label = "�������"
		,count(distinct sorgcode) as org_count label = "���������"
/*		,sum(icreditlimit) as icreditlimit label = "�����ܶ�"*/
		,put(put(sum(icreditlimit),PAY_AMT_level.),$PAY_AMT_CD.) as icreditlimit_group label = "�����ܶ�ֶΣ�"
		,sum(ibalance) as ibalance label = "�������"
/*		,sum(IAMOUNTPASTDUE) as IAMOUNTPASTDUE label = "��ǰ�����ܶ�"*/
		,put(put(sum(IAMOUNTPASTDUE),PAY_AMT_level.),$PAY_AMT_CD.) as IAMOUNTPASTDUE_group label = "��ǰ�����ܶ�(�ֶ�)"
		,sum(itermspastdue) AS itermspastdue label = "�ۼ����ڴ���"
		,max(imaxtermspastdue) as imaxtermspastdue label = "�����������"
/*		,COALESCE(input(ITREATYPAYAMOUNT,best12.),0) as TREATYPAYAMOUNT label = "ÿ��Ӧ�����"*/
		,COALESCE(max(COALESCE(input(ITREATYPAYAMOUNT,best12.),0) * imaxtermspastdue),IAMOUNTPASTDUE) as yuqi_max label = "������ڽ��"
	from pingan_LOAN_BASE_2
	where iaccountstat in (1,2)
	group by spin
	having ibalance ^= 0
	;
quit;
data pingan_loan_1;
	set pingan_loan_1;
	if spin = lag(spin) then delete;
run;


/*������Ϣ*/
proc sql;
	create table pingan_guarantee as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as danbao_count label = "���ⵣ������"
		,sum(iguaranteesum) as danbao_money label = "�ۼƵ������"
	from mylib.sino_loan_guarantee
	where SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') and spin is not null
	group by spin
	;
quit;

/*���⽻����Ϣ*/ 
proc sql;
	create table pingan_special as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as special_count label = "�����˴�������"
		,sum(ioccursum) as ioccursum label = "�������"
	from mylib.Sino_loan_spec_trade
	where speculiartradetype = "2"
	group by spin
;
quit;

/*������*/
proc sql;
	create table pingan_black as select
	spin
	,"" as yesno_bad label = "�Ƿ��û�"
	,"��" as yesno_black label = "�Ƿ������"
	from mylib.Sino_loan_spec_trade
	where speculiartradetype in ("6","7","8","9")
;
quit;



proc sql;
	create table _pingan_mapping as select
		T1.*
/*		,max(T2.org_count_apply) as org_count_apply label = "�ۼ����������"*/
/*		,sum(T2.apply_count) as apply_count label = "��ǰ��;�������"*/
		,T2.org_count_apply label = "�ۼ����������"
		,T2.apply_count label = "��ǰ��;�������"
		,T3.final_date_apply
		,T3.imoney
		,T4.*
		,T5.*
		,T6.*
		,T7.*
		,T8.*
		from pingan_mapping as T1
		left join (select spin,max(org_count_apply) as org_count_apply,sum(apply_count) as apply_count from pingan_apply_1 group by spin) as T2
		on T1.spin = T2.spin
		left join pingan_apply_2 as T3
		on T1.spin = T3.spin
		left join Pingan_loan_0 as T4
		on T1.spin = T4.spin
		left join Pingan_loan_1 as T5
		on T1.spin = T5.spin
		left join pingan_guarantee as T6
		on T1.spin = T6.spin
		left join pingan_special as T7
		on T1.spin = T7.spin
		left join pingan_black as T8
		on T1.spin = T8.spin
	order by (case T1.yesno when "��" then 1 else 2 end)
	;
quit;

data _pingan_mapping;
	set _pingan_mapping;
	drop
	scerttype
	spin
	;
	label
	name = ����
	scertno =���֤����
	;
run;

libname xls excel "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\����ļ���\��ʱ�Թ���\ƽ���Ŵ�����-�ŕJ\ƽ���Ŵ�����-V2.0.xlsx";
	data xls.sheet1(dblabel=yes);
	set _pingan_mapping;
RUN;
libname xls clear;

