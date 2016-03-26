/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
/*����ʱ�� 2015-5-4 �����ˣ����*/
/*����ʱ�� 20160227 �����ˣ���� �������ݣ��������ʽ��Ϊods+proc report*/
/*ע���޸�ʱ���;*/
%LET END=MDY(3,15,2016);
%LET START=MDY(3,1,2016);
%LET START_THREE = intnx('month',&START.,-2,'b');
%put &STAT_OP.;
%put &START.;
%put &END.;
%put &START_THREE.;
%put &curr_month.;
%include "E:\�½��ļ���\SAS\������.sas";
%include "E:\�½��ļ���\SAS\config.sas";
%ChkFile(E:\�½��ļ���\&curr_month.\NFCS);
%ChkFile(E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&curr_month.);

/*%ChkFile(D:\����\&STAT_OP.);*/
/*LIBNAME SSS "D:\����\&STAT_OP.";*/
/*OPTIONS NOXWAIT MPRINT MLOGIC COMPRESS=YES;*/
options compress=yes mprint mlogic noxwait;
/*libname nfcs "C:\Users\linan\Documents\����\NFCS��������\201602";*/
%INCLUDE "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%FORMAT;

/*����������Ϣ*/
PROC SQL;
	CREATE TABLE SQ AS SELECT
		sorgcode LABEL="��������"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname LABEL="�������"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="�����ۼ�������-����"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="�����ۼ�������-����"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="�����ۼ�������-����ǰ"
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

/*����ҵ����Ϣ*/

PROC SQL;
	CREATE TABLE LOAN AS SELECT
		sorgcode LABEL="��������"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname LABEL="�������"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="�����ۼ�ҵ����-����"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="�����ۼ�ҵ����-����"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="�����ۼ�ҵ����-����ǰ"
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

/*���������Ϣ*/

PROC SQL;
	CREATE TABLE SF AS SELECT
		sorgcode LABEL="��������"
/*		,PUT(SORGCODE,$SHORT_CD.) as shortname label = "�������"*/
		,SUM(CASE WHEN NOW=0 THEN 0 ELSE 1 END) AS NOW LABEL="�����ۼƸ�����-����"
		,SUM(CASE WHEN LAST=0 THEN 0 ELSE 1 END) AS LAST LABEL="�����ۼƸ�����-����"
		,SUM(CASE WHEN LAST_THREE = 0 THEN 0 ELSE 1 END) AS LAST_THREE LABEL="�����ۼƸ�����-����ǰ"
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

/*���⽻����Ϣ�ϱ�����, ����,����*/

PROC SORT DATA=NFCS.Sino_LOAN_SPEC_TRADE(keep = SORGCODE SACCOUNT dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) OUT=SPEC_N1;
	BY SORGCODE SACCOUNT dgetdate;
RUN;
DATA SPEC_N1;
	SET SPEC_N1;
	if SORGCODE = lag(SORGCODE) and SACCOUNT = lag(SACCOUNT) then delete;
RUN;

PROC SQL;
 	CREATE TABLE SPEC AS SELECT
		sorgcode  LABEL="��������"
/*		,PUT(SORGCODE,$SHORT_CD.) as shortname label = "�������"*/
		,sum(case when DATEPART(DGETDATE) <= &END. then 1 else 0 end) as NOW LABEL= "�����ۼ����⽻����-����"
		,sum(case WHEN DATEPART(DGETDATE) <= &START. then 1 else 0 end) as LAST LABEL= "�����ۼ����⽻����-����"
		,SUM(CASE WHEN DATEPART(DGETDATE) < &START_THREE. THEN 1 ELSE 0 END) AS LAST_THREE LABEL="�����ۼ����⽻����-����ǰ"
	FROM SPEC_N1
	 Group By sorgcode;
QUIT;

/*��⼰�������*/
PROC SQL;
	CREATE TABLE RK AS select 
		sorgcode LABEL="��������"
/*		,PUT(sorgcode,$SHORT_cd.) as shortname label = "�������"*/
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&START. THEN itotalcount ELSE 0 END) AS LASTTOTAL LABEL="���ڼ���"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&START. THEN isuccesscount ELSE 0 END) AS LASTS LABEL="���ڳɹ�"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&END. THEN itotalcount ELSE 0 END) AS NOWTOTAL LABEL="���ڼ���"
		,sum(CASE WHEN DATEPART(DUPLOADTIME)<=&END. THEN isuccesscount ELSE 0 END) AS NOWS LABEL="���ڳɹ�"
	from (select p.sorgcode,p.DUPLOADTIME,p.itotalcount,p.isuccesscount from NFCS.sino_msg(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001')) AS p)  
group by sorgcode;
QUIT;

/* ��ѯ��*/
/*���²�ѯ��*/
PROC SQL;
	CREATE TABLE CX AS SELECT
		T2.stoporgcode as sorgcode LABEL="��������"
/*		PUT(SORGCODE,$SHORT_CD.) as shortname LABEL="��������"*/
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as cx_NOW LABEL="����"
		,sum(case when DATEPART(dcreatetime) < &START. then 1 else 0 end) as cx_LAST LABEL="����"
  		From NFCS.sino_credit_record(keep = sorgcode dcreatetime WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
		Group By stoporgcode
;
QUIT;

/*���º˶���ѯ��*/
proc sql;
	create table cx_lastmonth as select
	STOPORGCODE as sorgcode LABEL="��������"
	,SUM(ISEARCHLIMIT) as ISEARCHLIMIT label = "�����ղ�ѯ���޶��֧��������ͳ�ƣ�"
/*	,put(sorgcode,$short_cd.) as shortname */
	from nfcs.sino_org(keep = STOPORGCODE ISEARCHLIMIT)
	group by sorgcode
;
quit;
data cx_lastmonth;
	set cx_lastmonth;
	if sorgcode = lag(sorgcode) then delete;
run;


/*�����ղ�ѯ��ֵ����ֵ*/
proc sql;
	CREATE TABLE CX_day AS SELECT
	T2.stoporgcode as sorgcode LABEL="��������"
	,datepart(T1.dcreatetime) as tian label = "��������" format = YYMMDDS10.
	,count(T1.dcreatetime) as chaxunliang label = "�ղ�ѯ��"
	,T2.ISEARCHLIMIT label = "�����ղ�ѯ���޶�"
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

/*���һ�β�ѯ���ϱ�ʱ��*/
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
sorgcode = ��������
/*shortname = �������*/
cxtime_last = ���һ�β�ѯʱ��
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
sorgcode = ��������
/*shortname = �������*/
bstime_last = ���һ�α���ʱ��
;
run;


/* �����*/
PROC SQL;
	CREATE TABLE CD AS SELECT
		T2.stoporgcode as sorgcode LABEL="��������"
/*		PUT(SORGCODE,$SHORT_CD.) as shortname LABEL="��������"*/
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  CD_NOW LABEL="���ڲ����"
		,sum(case when DATEPART(dcreatetime) < &START. then 1 else 0 end) as  CD_LAST LABEL="���ڲ����"
  		From NFCS.sino_credit_record(keep = sorgcode dcreatetime IREQUESTTYPE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND IREQUESTTYPE IN (0,1,2,6))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.sorgcode
	Group By stoporgcode
;
QUIT;

/*��ȡȫ����������*/
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

/*�Ƿ�ȫ������������ͨ����ѯȨ���жϣ�*/
proc sql;
	create table chaxun_type as select
		T1.sorgcode label = "��������"
/*		,PUT(sorgcode,$SHORT_CD.) AS shortname label = "�������"*/
		,(case when sum(T1.IPLATE) = 4 then "��" else "" end) as cx_quanliang label = "ȫ����ѯȨ��"
		,(case when sum(T1.IPLATE) = 3 then "��" else "" end) as cx_spec label = "���⽻�ײ�ѯȨ��"
		,(case when T2.SQUERYAUTH = '1' then "��" else "" end) as cx_SQUERYAUTH label = "�����֤��ѯȨ��"
	from nfcs.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) as T1
	left join nfcs.sino_org as T2
	on T1.sorgcode = T2.stoporgcode
	group by T1.sorgcode
;
quit;

/*�����ѯ��׼��*/
PROC SQL;
	CREATE TABLE ALL_THREE AS SELECT
		T5.sorgcode
		,sum(T1.now,T2.now,T3.now,T4.now) as all_now label = "���������ۼ���-����"
		,sum(T1.LAST_THREE,T2.LAST_THREE,T3.LAST_THREE,T4.LAST_THREE) as all_three label = "���������ۼ���-����ǰ"
		,(calculated all_now - calculated all_three) as REQ_ADD label = "��������������"
		,(case when calculated REQ_ADD > 1000 then ROUND(calculated REQ_ADD*6/20,1) else ROUND(calculated REQ_ADD*8/20,1) end) as REQ_BASE label = "��ѯ��׼��"
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

/*����*/
proc sql;
	create table result as select
		. as xuhao format = 4. informat = 4. label = "���"
		,T1.sorgcode label = "��������"
		,PUT(T1.sorgcode,$SHORT_CD.) AS shortname label = "�������"
		,T15.person label = "ר��Ա"
		,(case when T3.NOW is null and T5.NOW > 0 then "���⽻��"
			   when T3.NOW is null and T5.NOW is null then "δ����ҵ��" 
				ELSE "�ѱ���ҵ��" end) as type label = "��������"
		,T2.NOW as SF_NOW label = "���˻�����Ϣ-����"
		,T2.LAST as SF_LAST label = "���˻�����Ϣ-����"
		,(T2.NOW - T2.LAST) as SF_ADD label = "���˻�����Ϣ-������"
		,T2.NOW/T2.LAST-1 as SF_per label = "���˻�����Ϣ-������" format = percent10.2
		,T3.NOW as LOAN_NOW label = "����ҵ����Ϣ-����"
		,T3.LAST as LOAN_LAST label = "����ҵ����Ϣ-����"
		,(T3.NOW - T3.LAST) as LOAN_add label = "����ҵ����Ϣ-������"
		,T3.NOW/T3.LAST-1 as LOAN_per label = "����ҵ����Ϣ-������" format = percent10.2
		,T4.NOW as SQ_NOW label = "����������Ϣ-����"
		,T4.LAST as SQ_LAST label = "����������Ϣ-����"
		,(T4.NOW - T4.LAST) as SQ_add label = "����������Ϣ-������"
		,T4.NOW/T4.LAST-1 as SQ_per label = "����������Ϣ-������" format = percent10.2
		,T5.NOW as SPEC_NOW label = "���⽻����Ϣ-����"
		,T5.LAST as SPEC_LAST label = "���⽻����Ϣ-����"
		,T5.NOW/T5.LAST-1 as SPEC_per label = "���⽻����Ϣ-������" format = percent10.2
		,"" as score label = "�������"
		,T6.NOWS/T6.NOWTOTAL as succ_per label = "���سɹ���" format = percent10.2
		,T7.cx_quanliang label = "�Ƿ����ȫ����ѯȨ��"
		,T7.cx_spec label = "�Ƿ�������⽻�ײ�ѯȨ��"
		,T7.cx_SQUERYAUTH label = "�Ƿ���������֤��ѯȨ��"
		,T9.cx_now label = "��ֹ���µײ�ѯ����"
		,T9.cx_last label = "��ֹ���µײ�ѯ����"
		,T10.cd_now label = "��ֹ���µײ������"
		,T10.cd_last label = "��ֹ���µײ������"
		,T11.chaxunliang label = "�����ղ�ѯ����ֵ"
		,T11.tian label = "��ֵ��������"
		,T13.cxtime_last label = '���һ�β�ѯʱ��'
		,T14.bstime_last label = '���һ�α���ʱ��'
		,T12.all_three label = "���������ۼ���-����ǰ"
		,T12.all_now label = "���������ۼ���-����"
		,T12.REQ_ADD label = '��������������'
		,T11.ISEARCHLIMIT label = '�˶��ղ�ѯ��-����'
		,T12.REQ_BASE label = '��ѯ��׼��'
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
	order by (case when type = "�ѱ���ҵ��" then 1
					when type = "���⽻��" then 2 
					when type = "δ����ҵ��" then 3 end),LOAN_NOW desc
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

/*�������ݲֿ�*/
/*�����*/
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
			dgetdate = ��ȡ����;
		run;	
	%end;
run;
%mend;
	
%save_dw(dw,monthreport,result);

/*����������������ҵ�����*/
proc sql;
	create table ruku as select
		sorgcode label = "��������"
		,intnx('month',datepart(dgetdate),0,'b') as yearmonth format=yymmn6. informat = yymmn6. label = "����ʱ��"
/*		,put(datepart(dgetdate),yymmn6.) as yearmonth label = "����ʱ��"*/
		,count(distinct iloanid) as loan_count label = "����ҵ���¼��"
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
shortname = �������
;
run;

data _ruku;
retain shortname;
	set _ruku;
run;

/*E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&curr_month.\NFCS��Ӫ�±�-&STAT_OP..xls*/
ods tagsets.excelxp file="E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&curr_month.\NFCS��Ӫ�±�-&STAT_OP..xls" style = printer
      options(sheet_name="NFCS��Ӫ�±�" embedded_titles='yes' embedded_footnotes='yes' sheet_interval="bygroup");
proc report data = result NOWINDOWS headline headskip style(header)={background=lightgray foreground=black bold};
	columns xuhao sorgcode shortname person type ('�������' SF_NOW SF_LAST SF_ADD SF_per loan_NOW loan_LAST loan_ADD loan_per sq_NOW sq_LAST sq_ADD sq_per spec_NOW spec_LAST spec_per)
		('��ѯ���' cx_quanliang cx_spec cx_SQUERYAUTH cx_now cx_last cd_now cd_last chaxunliang tian) ('�Ϲ�ʹ�����' cxtime_last bstime_last)
		('�˶���ѯ���������' all_three all_now REQ_ADD ISEARCHLIMIT REQ_BASE);
	define xuhao / display '���';
	define sorgcode / display width = 7;
	define shortname / display width = 6;
	define person / display;
	define type / display;
	define SF_NOW / display '������Ϣ/-����';
	define SF_LAST / display '������Ϣ/-����';
	define SF_ADD / display '������Ϣ/-����������';
	define SF_PER / display '������Ϣ/-����������';
	define loan_NOW / display '������Ϣ/-����';
	define loan_last / display '������Ϣ/-����';
	define loan_add / display '������Ϣ/-����������';
	define loan_per / display '������Ϣ/-����������';
	define sq_NOW / display '������Ϣ/-����';
	define sq_last / display '������Ϣ/-����';
	define sq_add / display '������Ϣ/-����������';
	define sq_per / display '������Ϣ/-����������';
	define spec_now / display '���⽻����Ϣ/-����';
	define spec_last / display '���⽻����Ϣ/-����';
	define spec_per / display '���⽻����Ϣ/-����������';
	define cx_quanliang / display '�Ƿ����/ȫ����ѯȨ��';
	define cx_spec / display '�Ƿ��������/���ײ�ѯȨ��';
	define cx_SQUERYAUTH / display '�Ƿ�������/��֤��ѯȨ��';
	define cx_now / display '��ֹ���µ�/��ѯ����';
	define cx_last / display '��ֹ���µ�/��ѯ����';
	define cd_now / display '��ֹ���µ�/�������';
	define cd_last / display '��ֹ���µ�/�������';
	define all_three / display '��������/�ۼ���-����ǰ';
	define all_now / display '��������/�ۼ���-����';
	define ISEARCHLIMIT / display '�˶��ղ�ѯ��/-����';
/*break after/ dol summarize;*/
/*rbreak after /summarize;*/
	footnote1 20160228�������˱���ṹ;
quit;
/*proc report data = _ruku NOWINDOWS headline headskip style(header)={background=lightgray foreground=black};*/
ods tagsets.excelxp close;
  ods listing;

 




libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&curr_month.\NFCS��Ӫ�±�-&STAT_OP..xlsx";
	data xls.NFCS��Ӫ�¶ȱ���(dblabel=yes);
		set result;
	run;
data xls.��������������ҵ�������(dblabel=yes);
	set _ruku;
RUN;
libname xls clear;

