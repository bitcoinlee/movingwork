options compress=yes mprint mlogic noxwait noxsync;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/**/
/*%let month= %sysfunc(month(%sysfunc(today())));*/
/*%let year= %sysfunc(year(%sysfunc(today())));*/
/*����ǰ��Ҫά������*/
%LET END = MDY(01,26,2016) ;
%put &end.;
%let d=%sysfunc(&end.,yymmddn8.);
/*ֱ�ӵ��õײ�FORMAT �޸��ˣ���� 2015-04-14 ����֤*/
%INCLUDE "E:\�ּ���\000_FORMAT.sas";
%FORMAT;

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set mylib.sino_org(keep=STOPORGCODE SORGCODE SORGname);
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as upcode label="������������"
		,T2.sorgname as upfullname label="������������"
		,T1.SORGCODE as downcode label="�ӻ�������"
		,T1.sorgname as downname label="�ӻ�������"
		from sino_org2 as T1 left join mylib.sino_org as T2
		on T1.STOPORGCODE=T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)="Q";
quit;


DATA CX1;
/*length SHORT_NM $5.;*/
	SET mylib.sino_credit_record(DROP= IID IUSERID SNAME SCERTTYPE SCERTNO SORGNAME SDEPNAME SUSERNAME SFILEPATH SSERIALNUMBER DREQUESTTIME SCERTTYPENAME WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND DATEPART(dcreatetime) <= &END.));
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
	if substr(SHORT_NM,1,1) = "Q" then SHORT_NM = "δ��������";

RUN;

/* ��ѯ��*/
PROC SQL;
	CREATE TABLE CX AS SELECT
		SHORT_NM LABEL="��������"
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as HISCX LABEL="��ʷ��ѯ��"
		,sum(case when DATEPART(dcreatetime) = &END. then 1 else 0 end) as DAYCX LABEL="���ղ�ѯ��"
  		From CX1
 		Group By SHORT_NM;
QUIT;

/* �����*/

PROC SQL;
	CREATE TABLE CD AS SELECT
		SHORT_NM LABEL="��������"
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  HISCD LABEL="��ʷ�����"
		,sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end) as  DAYCD LABEL="���ղ����"
  		From CX1(WHERE=(IREQUESTTYPE IN (0,1,2,6)))
 		Group By SHORT_NM;
QUIT;


/*����*/

PROC SQL;
	CREATE TABLE CXSIGN1 AS SELECT
		A.SHORT_NM
		,A.HISCX
		,COALESCE(B.HISCD,0) AS HISCD LABEL="��ʷ�����"
		,A.DAYCX
		,COALESCE(B.DAYCD,0) AS DAYCD LABEL="���ղ����"
	FROM CX AS A
	LEFT JOIN CD AS B
	ON A.SHORT_NM=B.SHORT_NM
	ORDER BY  HISCX DESC,HISCD DESC;
	
	CREATE TABLE CXSIGN AS SELECT
		MONOTONIC() AS ORDER1 LABEL="���"
		,*
	FROM CXSIGN1;
QUIT;

/*��������ѯ�� Դ����:CX1 CD1 �ھ������������� 2015-04-16 ��� ����֤*/
PROC SQL;
	CREATE TABLE CX_PROV AS SELECT
		put(sorgcode,$ORGAREA_CD.) as PROVINCE LABEL="ʡ��"
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as HISCX LABEL="��ʷ��ѯ��"
		,sum(case when DATEPART(dcreatetime) = &END. then 1 else 0 end) as DAYCX LABEL="���ղ�ѯ��"
  		From CX1
 		Group By calculated PROVINCE;
QUIT;

/*proc sql noprint;*/
/*	select sum(HISCX) into :HISCXSUM*/
/*	from CX*/
/*;*/
/*quit;*/
/*%put &HISCXSUM.;*/
/*data CX_PROV_1;*/
/*format HISCXRANK percent8.2;*/
/*informat HISCXRANK percent8.2;*/
/*set CX_PROV;*/
/*	HISCXRANK = round(HISCX/&HISCXSUM.,2);*/
/*	label*/
/*	HISCXRANK = ��ʷ��ѯ��ռ��*/
/*	;*/
/*run;*/
/*data CX_PROV;*/
/*	retain PROVINCE HISCX HISCXRANK*/
/*	set CX_PROV;*/
/*run;*/


PROC SQL;
	CREATE TABLE CD_PROV AS SELECT
		put(sorgcode,$ORGAREA_CD.) as PROVINCE LABEL="ʡ��"
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  HISCD LABEL="��ʷ�����"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCD LABEL="���ղ����"
  		From CX1(WHERE=(IREQUESTTYPE IN (0,1,2,6)))
 		Group By calculated PROVINCE
;
QUIT;
PROC SQL;
	CREATE TABLE CXCD_PROV AS SELECT
		A.PROVINCE
		,A.HISCX
		,COALESCE(B.HISCD,0) AS HISCD LABEL="��ʷ�����"
		,A.DAYCX
		,COALESCE(B.DAYCD,0) AS DAYCD LABEL="���ղ����"
	FROM CX_PROV AS A
	LEFT JOIN CD_PROV AS B
	ON A.PROVINCE = B.PROVINCE
	ORDER BY HISCX DESC,HISCD DESC;
DATA CXCD_PROV;
retain index;
	set CXCD_PROV;
	length index 3.;
	index=_n_;
	label
	index=���
	;
run;


/*��ѯԭ��ͳ��*/
PROC SQL;
	CREATE TABLE REASON AS SELECT
		SHORT_NM LABEL="��������"
		,SREASON LABEL="���ղ�ѯԭ��"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCX LABEL="���ղ�ѯ��"
		,SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end) as  DAYCD LABEL="���ղ����"
		,PUT(SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end),PERCENT8.2) AS CD_RATIO LABEL="���ղ����" 
  	From CX1(WHERE=(DATEPART(dcreatetime) =&END.))
 	Group By SHORT_NM,SREASON
	ORDER BY DAYCX DESC,DAYCD DESC;
QUIT;



PROC SQL;
	CREATE TABLE REASON_T AS SELECT
		SREASON LABEL="��ѯԭ��"
		,sum(case when DATEPART(dcreatetime)  <=&END. then 1 else 0 end) as  HISCX LABEL="��ʷ��ѯ��"
		,SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end) as  HISCD LABEL="��ʷ�����"
		,PUT(SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime)  <=&END. then 1 else 0 end),PERCENT8.2) AS HIS_CD_RATIO LABEL="��ʷ�����"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCX LABEL="���ղ�ѯ��"
		,SUM(CASE WHEN IPERSONID^=0 AND DATEPART(dcreatetime)  =&END. THEN 1 else 0 end) as  DAYCD LABEL="���ղ����"
		,PUT(SUM(CASE WHEN IPERSONID^=0 AND DATEPART(dcreatetime) =&END. THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end),PERCENT8.2) AS DAY_CD_RATIO LABEL="���ղ����"  
  	From CX1(WHERE=(DATEPART(dcreatetime) <= &END.))
 	Group By SREASON
	ORDER BY HISCX DESC,HISCD DESC;
QUIT;



/*����������ͳ�� 2015-04-13 ��� ����֤*/

PROC SQL;
	CREATE TABLE LOAN_TODAY AS SELECT
		DISTINCT B.sorgname as sorgname label="��������ҵ��������"
			from mylib.sino_loan(where=(DATEPART(DGETDATE) = &END.)) as A
		left join mylib.sino_org as B
		on A.SORGCODE = B.SORGCODE
		where A.sorgcode not in (select distinct sorgcode from mylib.sino_loan where DATEPART(DGETDATE) < &end.)
;
quit;
/*%put &end.;*/
/*data _null_;*/
/*%let dsid=%sysfunc(open(LOAN_TODAY));*/
/*%let anobs=%sysfunc(attrn(&DSID,ANOBS));*/
/*%let rc=%sysfunc(close(&dsid));*/
/*if &anobs. > 0 then do*/
/*run;*/

/*����������ģ�� 2015-07-15 �ּ���*/
x 'E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\NFCS��ѯ���ͳ��ģ��.xls';
filename ex dde 'excel|E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\[NFCS��ѯ���ͳ��ģ��.xls]��ѯʹ�����ͳ�Ʊ�!r3c1:r200c10';
data _null_;
 set cxsign;
 file ex;
 put order1 short_nm hiscx hiscd daycx daycd;
run;
filename ex dde 'excel|E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\[NFCS��ѯ���ͳ��ģ��.xls]��ʡ�в�ѯ���ͳ�Ʊ�!r3c1:r200c10';
data _null_;
 set cxcd_prov;
 file ex;
 put index province hiscx hiscd daycx daycd;
run;
filename ex dde 'excel|E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\[NFCS��ѯ���ͳ��ģ��.xls]�������ղ�ѯԭ��ͳ�Ʊ�!r3c1:r200c10';
data _null_;
 set reason;
 file ex;
 put short_nm sreason daycx daycd cd_ratio;
run;
filename ex dde 'excel|E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\[NFCS��ѯ���ͳ��ģ��.xls]��ѯԭ����ʷͳ�Ʊ�!r3c1:r200c10';
data _null_;
 set reason_t;
 file ex;
 put sreason hiscx hiscd his_cd_ratio daycx daycd day_cd_ratio;
run;
filename ex dde 'excel|E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\[NFCS��ѯ���ͳ��ģ��.xls]��������ҵ��������!r2c1:r200c10';
data _null_;
 set loan_today;
 file ex;
 put sorgname;
run;
filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("macro")]';
 put "[save.as(""E:\�ּ���\ÿ�ջ�����ѯͳ�ƽ��\NFCS��ѯ���ͳ��\NFCS��ѯ���ͳ��_&d..xls"")]";
 put '[quit]';
run;
