options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
%INCLUDE "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%include "E:\�½��ļ���\SAS\������.sas";
%format;

%let enddate = mdy(10,31,2015);
/*����*/
PROC SQL;
	CREATE TABLE zkb_renshu AS SELECT
		put(datepart(dgetdate),yymmn6.) as yuefen label = "�·�"
		,count(spin) as rukucount label = "���������"
	FROM mylib.SINO_PERSON_certification(keep=sorgcode spin dgetdate WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY calculated yuefen
;
QUIT;

proc sort data=mylib.SINO_PERSON_certification(keep= sorgcode scerttype scertno dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=zkb_weizhi nodup;
by scertno dgetdate;
run;

data zkb_weizhi;
	set zkb_weizhi;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '����';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '����';
run;

proc sql;
	create table _zkb_weizhi as select
	weizhi label = "ʡ��"
	,count(weizhi) as weizhi_person label = "�������"
	from zkb_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;

/*���Ŵ���¼������ �����ܱ��� �����ܶ� �Ŵ������֤�״ο�����ַ*/
PROC SORT DATA=mylib.SINO_LOAN(KEEP=sorgcode SACCOUNT DGETDATE icreditlimit imaxtermspastdue spin scerttype scertno WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=zkb_LOAN_BASE nodupkey;
	BY SORGCODE SACCOUNT descending DGETDATE;
RUN;
data zkb_LOAN_BASE;
	set zkb_LOAN_BASE;
	if sorgcode = lag(sorgcode) and SACCOUNT = lag(SACCOUNT) then delete;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '����';
run;
PROC SQL;
	CREATE TABLE zkb_loan_renshu AS SELECT
		put(datepart(dgetdate),yymmn6.) as yuefen label = "�·�"
		,COUNT(distinct spin) as loan_renshu label = "�д����¼����"
		,count(distinct catx(sorgcode,saccount)) as rukuloan label = "����ҵ����������"
		,round(sum(ICREDITLIMIT)/10000,0.01) as money_all LABEL="�����ܶ�(��Ԫ)"
	FROM zkb_LOAN_BASE
	GROUP BY calculated yuefen
;
QUIT;
proc sql;
	create table zkb_account_weizhi as select
		weizhi label = "ʡ��"
		,count(weizhi) as weizhi_person label = "�������"
	from zkb_LOAN_BASE
	group by weizhi
	order by weizhi_person desc
;
quit;

proc sql;
	create table _zkb_yuqi as select
			weizhi label = "ʡ��"
		,count(weizhi) as weizhi_person label = "�������"
	from zkb_LOAN_BASE
	where imaxtermspastdue >= 3
	group by weizhi
	order by weizhi_person desc
;
quit;

	

/*���������˰����֤*/
proc sort data = mylib.sino_loan_apply(keep= sorgcode scerttype scertno dgetdate WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out=zkb_apply_weizhi nodup;
by scertno dgetdate;
run;

data zkb_apply_weizhi;
	set zkb_apply_weizhi;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '����';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '����';
run;

proc sql;
	create table _zkb_apply_weizhi as select
	weizhi label = "ʡ��"
	,count(weizhi) as weizhi_person label = "�������"
	from zkb_apply_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;

/*���⽻������*/
PROC SORT DATA=mylib.Sino_LOAN_SPEC_TRADE(KEEP=sorgcode DGETDATE spin scerttype scertno WHERE=(datepart(dgetdate)<= &enddate. and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=zkb_spec_BASE nodup;
	BY SORGCODE spin DGETDATE;
RUN;
data zkb_spec_BASE;
	set zkb_spec_BASE;
	if sorgcode = lag(sorgcode) and spin = lag(spin) then delete;
	if scerttype = "0" then weizhi = put(substr(scertno,1,2),$PROV_CD.);
	else weizhi = '����';
	if substr(weizhi,1,1) in ("0" "9") then weizhi = '����';

run;
proc sql;
	create table zkb_spec_renshu as select
		put(datepart(dgetdate),yymmn6.) as yuefen label = "�·�"
		,count(distinct spin) as spec_renshu label = "����������"
	from zkb_spec_BASE
	group by calculated yuefen
;
quit;

proc sql;
	create table _zkb_spec_weizhi as select
	weizhi label = "ʡ��"
	,count(weizhi) as weizhi_person label = "�������"
	from zkb_apply_weizhi
	group by weizhi
	order by calculated weizhi_person desc
;		
run;


/*��ѯ�������*/
DATA CX1;
	SET mylib.sino_credit_record(DROP= IID IUSERID SNAME SCERTTYPE SCERTNO SORGNAME SDEPNAME SUSERNAME SFILEPATH SSERIALNUMBER DREQUESTTIME SCERTTYPENAME WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
/*	DATEPART(dcreatetime);*/
RUN;
proc sql;
	create table zkb_cx as select
		put(DATEPART(dcreatetime),yymmn6.) as yuefen label = "�·�"
		,count(distinct iid) as chaxun_count label = "��ѯ��"
		,sum(case when IREQUESTTYPE IN (0,1,2,6) then 1 else 0 end) as chade_count label = "�����"
		from mylib.sino_credit_record(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
		group by calculated yuefen
		;
quit;

/*���*/
proc sql;
	create table _zkb as select
	T1.*
	,T2.*
	,T3.spec_renshu
	,T4.*
	from zkb_renshu as T1
	left join zkb_loan_renshu as T2
	on T1.yuefen = T2.yuefen
	left join zkb_spec_renshu as T3
	on T1.yuefen = T3.yuefen
	left join zkb_cx as T4
	on T1.yuefen = T4.yuefen

;
quit;



libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\����20150808-V2.0.xlsx";
	data xls.sheet1(dblabel=yes);
	set _zkb;
RUN;
	data xls.sheet3(dblabel=yes);
	set _zkb_weizhi;
RUN;
	data xls.'��������ֲ�-�����֤'n(dblabel=yes);
	set _zkb_apply_weizhi;
RUN;
	data xls."���������ֲ�-�����֤"n(dblabel=yes);
	set zkb_account_weizhi;
RUN;
data xls."����-�����֤"n(dblabel=yes);
	set _zkb_yuqi;
RUN;
libname xls clear;

