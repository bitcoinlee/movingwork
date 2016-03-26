options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
%include "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%include "E:\�½��ļ���\SAS\������.sas";
%format;
PROC IMPORT OUT= WORK.ningbo DATAFILE = "E:\�½��ļ���\SAS\���ô���\�Զ���\��ʱ�Թ���\����\��������\��������-������.xls" DBMS=EXCEL REPLACE;
     RANGE="�����-����$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sort data = ningbo;
 by scertno;
run;
/*data ningbo;*/
/*	set ningbo;*/
/*	if scertno = lag(scertno) then delete;*/
/*	scerttype_temp = put(scerttype,$2.);*/
/*	drop*/
/*	scerttype*/
/*	;*/
/*	rename*/
/*	scerttype_temp = scerttype*/
/*	;*/
/*run;*/

proc sql;
	create table ningbo_mapping as select
		T1.*
		,T2.spin
		,(case when T2.spin is null then "��" else "��" end) as yesno label = "ƥ����"
		from ningbo as T1
		left join nfcs.Sino_person_certification as T2
		on strip(T1.sname) = strip(T2.sname) and strip(T1.scertno18) = strip(T2.SCERTNO)
		order by (case yesno when "��" then 1 else 2 end)
	;
quit;

/*���˻�����Ϣ����*/
proc sort	data = nfcs.sino_person(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person;
	set ningbo_person;
	if spin = lag(spin) then delete;
run;
proc sort	data =  nfcs.sino_person_employment(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person_employment nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person_employment;
	set ningbo_person_employment;
	if spin = lag(spin) then delete;
run;
proc sort	data =  nfcs.sino_person_address(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person_address nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person_address;
	set ningbo_person_address;
	if spin = lag(spin) then delete;
run;

/*�������벿��*/
proc sort data = nfcs.Sino_loan_apply(keep = spin sorgcode sapplycode ddate imoney sstate) out = ningbo_apply nodup;
	by spin descending ddate;
run;
data ningbo_apply_1;
	format org_count_apply 2. apply_count 2. final_date_apply yymmddd10.;
	set ningbo_apply;
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
data ningbo_apply_2;
	set ningbo_apply_1(keep = spin final_date_apply imoney);
		if spin = lag(spin) then delete;
	label
		imoney = ���һ��������
	;
run;

/*����ҵ�񲿷�*/
proc sort DATA=nfcs.SINO_LOAN(KEEP=sorgcode sareacode ddateopened icreditlimit spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=ningbo_LOAN_BASE_1 nodup;
	BY SPIN ddateopened;
RUN;

proc sql;
	create table ningbo_loan_0 as select
		spin
		,min(datepart(DDATEOPENED)) as DDATEOPENED format = yymmddd10. label = "��ʷ�״�����"
		,max(icreditlimit) as icreditlimit_his label ="��ʷ������Ŷ��"
	from ningbo_loan_base_1
	group by spin
	;
quit;

PROC SORT DATA=nfcs.SINO_LOAN(KEEP=sorgcode SACCOUNT sareacode sloantype ddateopened dbillingdate icreditlimit ibalance iamountpastdue itermspastdue imaxtermspastdue ITREATYPAYAMOUNT iaccountstat spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=ningbo_LOAN_BASE;
	BY SORGCODE SACCOUNT descending dbillingdate;
RUN;

data ningbo_LOAN_BASE_2;
	format ddateopened_temp yymmddd10. dbillingdate_temp yymmddd10.;
	set ningbo_LOAN_BASE;
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
	CREATE TABLE ningbo_loan_1 AS SELECT
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
	from ningbo_LOAN_BASE_2
	where iaccountstat in (1,2)
	group by spin
	having ibalance ^= 0
	;
quit;
data ningbo_loan_1;
	set ningbo_loan_1;
	if spin = lag(spin) then delete;
run;


/*������Ϣ*/
proc sql;
	create table ningbo_guarantee as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as danbao_count label = "���ⵣ������"
		,sum(iguaranteesum) as danbao_money label = "�ۼƵ������"
	from nfcs.sino_loan_guarantee
	where SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') and spin is not null
	group by spin
	;
quit;

/*���⽻����Ϣ*/ 
proc sql;
	create table ningbo_special as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as special_count label = "�����˴�������"
		,sum(ioccursum) as ioccursum label = "�������"
	from nfcs.Sino_loan_spec_trade
	where speculiartradetype = "2"
	group by spin
;
quit;

/*������*/
proc sql;
	create table ningbo_black as select
	spin
	,"��" as yesno_black label = "�Ƿ������"
	from nfcs.Sino_loan_spec_trade
	where speculiartradetype in ("6","7","8","9")
;
quit;
data ningbo_black;
	set ningbo_black;
	if spin = lag(spin) then delete;
run;


proc sql;
	create table _ningbo_mapping as select
		T1.*
/*		,max(T2.org_count_apply) as org_count_apply label = "�ۼ����������"*/
/*		,sum(T2.apply_count) as apply_count label = "��ǰ��;�������"*/
		,T9.*
		,T10.*
		,T11.*
		,T2.org_count_apply label = "�ۼ����������"
		,T2.apply_count label = "��ǰ��;�������"
		,T3.final_date_apply
		,T3.imoney
		,T4.*
		,T5.*
		,T6.*
		,T7.*
		,T8.*
		from ningbo_mapping(where = (yesno = "��")) as T1
		left join (select spin,max(org_count_apply) as org_count_apply,sum(apply_count) as apply_count from ningbo_apply_1 group by spin) as T2
		on T1.spin = T2.spin
		left join ningbo_apply_2 as T3
		on T1.spin = T3.spin
		left join ningbo_loan_0 as T4
		on T1.spin = T4.spin
		left join ningbo_loan_1 as T5
		on T1.spin = T5.spin
		left join ningbo_guarantee as T6
		on T1.spin = T6.spin
		left join ningbo_special as T7
		on T1.spin = T7.spin
		left join ningbo_black as T8
		on T1.spin = T8.spin
		left join ningbo_person as T9
		on T1.spin = T9.spin
		left join ningbo_person_employment as T10
		on T1.spin = T10.spin
		left join ningbo_person_address as T11
		on T1.spin = T11.spin
/*	order by (case T1.yesno when "��" then 1 else 2 end)*/
	;
quit;

data _ningbo_mapping;
	set _ningbo_mapping;
	if spin = lag(spin) then delete;
	drop
	spin
	;
run;
data _ningbo_mapping;
	set _ningbo_mapping;
	label
 sname ='����'
 scerttype ='֤������'
 scertno ='֤������'
 ssectionid_B ='�α�B'
 isex ='�Ա�'
 dbirthday ='��������'
 imarriage ='����״��'
 iedulevel ='���ѧ��'
 iedudegree ='���ѧλ'
 smatename ='��ż����'
 smatecerttype ='��ż֤������'
 smatecertno ='��ż֤������'
 smatecompany ='��ż������λ'
 smatetel ='��ż��ϵ�绰'
 shometel ='סլ�绰'
 smobiletel ='�ֻ�����'
 sofficetel ='��λ�绰'
 Semail ='��������'
 saddress ='ͨѶ��ַ'
 szip ='ͨѶ��ַ��������'
 sfirstcontactname ='��һ��ϵ������'
 sfirstcontactrelation ='��һ��ϵ�˹�ϵ'
 sfirstcontacttel ='��һ��ϵ����ϵ�绰'
 ssecondcontactname ='�ڶ���ϵ������'
 ssecondcontactrelation ='�ڶ���ϵ�˹�ϵ'
 ssecondcontacttel ='�ڶ���ϵ����ϵ�绰'
 sresidence ='������ַ'
 ssectionid_C ='�α�C'
 soccupation ='ְҵ'
 Scompany ='��λ����'
 sindustry ='��λ������ҵ'
 scompanyaddress ='��λ��ַ'
 scompanyzip ='��λ��������'
 sstartyear ='��ְ����'
 iposition ='ְ��'
 ititle ='ְ��'
 iannualincome ='������'
 ssectionid_D ='�α�D'
 saddress  ='��ס��ַ'
 szip  ='��ס��ַ��������'
 Scondition ='��ס״��';
run;


libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\��������\��������-������.xlsx";
	data xls.sheet3(dblabel=yes);
	set _ningbo_mapping;
RUN;
libname xls clear;
