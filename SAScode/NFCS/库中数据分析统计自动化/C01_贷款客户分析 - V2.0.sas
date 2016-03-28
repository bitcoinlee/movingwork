/*�ͻ����ָ�����*/
/*���ά�ȴ���ȸ��� �����ˣ���� ʱ�䣺2015-03-25 �Ѳ���*/
%MACRO CUST_ANALYSIS(STAT_DT);

%LET LAST_DT=INTNX('MONTH',&STAT_DT.,-1,'END');

/*����(T-1)���ݴ��� ȥ�ش���ȡ����һ��*/
PROC SORT DATA=SSS.Sino_person_certification(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND DATEPART(DGETDATE)<=&STAT_DT.))  OUT=SINO_PERSON_CERT ;
	BY SCERTNO DGETDATE;
RUN;
DATA SINO_PERSON_CERT1;
	SET SINO_PERSON_CERT;
	BY SCERTNO DGETDATE;
	IF LAST.SCERTNO;
RUN;

PROC SORT DATA=SSS.Sino_person(keep= spin DGETDATE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND DATEPART(DGETDATE)<=&STAT_DT.))  OUT=SINO_PERSON ;
	BY spin DGETDATE;
RUN;
DATA SINO_PERSON1;
	SET SINO_PERSON;
	BY spin DGETDATE;
	IF LAST.spin;
RUN;
/*����(T-2)���ݴ��� ȥ�ش���ȡ����һ��*/
PROC SORT DATA=SSS.Sino_person_certification(WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND DATEPART(DGETDATE)<=&LAST_DT.))  OUT=SINO_PERSON_CERT_O ;
	BY SCERTNO DGETDATE;
RUN;
DATA SINO_PERSON_CERT_01;
	SET SINO_PERSON_CERT_O;
	BY SCERTNO DGETDATE;
	IF LAST.SCERTNO;
RUN;

PROC SORT DATA=SSS.Sino_person(keep= spin DGETDATE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE^='Q10152900H0000' AND SORGCODE^='Q10152900H0001' AND DATEPART(DGETDATE)<=&LAST_DT.))  OUT=SINO_PERSON_O ;
	BY spin DGETDATE;
RUN;
DATA SINO_PERSON_01;
	SET SINO_PERSON_O;
	BY spin DGETDATE;
	IF LAST.spin;
RUN;


/*	1.	C01�ͻ��Ƿ���ҵ��ֲ������	*/
/*T-1��*/
PROC SQL;
	CREATE TABLE CUST_LOANIND AS SELECT
		 distinct A.spin as spin
		 ,(case when B.SACCOUNT is null then 0 else 1 end ) as loanind
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN (select distinct spin as spin,SACCOUNT from sss.sino_loan) AS B 
	ON A.spin = B.spin
	order by calculated loanind desc
	;
QUIT;

/*DATA CUST_LOANIND1;*/
/*	SET CUST_LOANIND;*/
/*	IF SACCOUNT^='' THEN LOANIND=1;*/
/*	ELSE LOANIND=0;*/
/*RUN;*/
/*T-2��*/
PROC SQL;
	CREATE TABLE CUST_LOANIND_0 AS SELECT
		 distinct A.spin as spin
		 ,(case when B.SACCOUNT is null then 0 else 1 end ) as loanind
	FROM SINO_PERSON_CERT_O AS A
	LEFT JOIN (select distinct spin as spin,SACCOUNT from sss.sino_loan) AS B 
	ON A.spin = B.spin
	order by calculated loanind desc
;
QUIT;

/*DATA CUST_LOANIND0;*/
/*	SET CUST_LOANIND_0;*/
/*	IF SACCOUNT^='' THEN LOANIND=1;*/
/*	ELSE LOANIND=0;*/
/*RUN;*/

proc sql noprint;
select count(DISTINCT SPIN) into:cust_total_now
from CUST_LOANIND
;

select count(DISTINCT SPIN) into:cust_total_last
from CUST_LOANIND_0;
quit;

/*T-2���д���ҵ��ͻ�ռ��*/
data _null_;
	set CUST_LOANIND_0(keep=loanind);
	retain CUST_CNT1 0 CUST_CNT2 0;
		if loanind=0 then CUST_CNT1=CUST_CNT1+1;
		else if loanind=1 then CUST_CNT2=CUST_CNT2+1;
	call symput('CUST_PER1',CUST_CNT1/sum(CUST_CNT1,CUST_CNT2));
	call symput('CUST_PER2',CUST_CNT2/sum(CUST_CNT1,CUST_CNT2));
run;

PROC SQL;
	CREATE TABLE C01 AS SELECT
		LOANIND label="�Ƿ���ҵ��"
		,COUNT(DISTINCT SPIN) AS CUST_CNT label="�����ͻ���"
		,calculated CUST_CNT/&cust_total_now. as per_now label="����ռ��"
	FROM CUST_LOANIND
	GROUP BY LOANIND;
QUIT;

proc iml;
	reset print;
	use C01;
	read all into m1;
	m2={&CUST_PER1.,&CUST_PER2.};
	m0=m1||m2;
	create C01_temp var{LOANIND,CUST_CNT,per_now,per_last};
	append from m0;
quit;

data C01;
	set C01_temp;
	if loanind=0 then loanind_1="δ����";
	else loanind_1="�ѷ���";
	PER_NOW_1=put(PER_NOW,percent8.2);
	PER_LAST_1=put(per_last,percent8.2);
	drop loanind PER_NOW per_last;
	rename loanind_1=loanind PER_NOW_1=PER_NOW PER_LAST_1=PER_LAST;
	label
	LOANIND_1="ҵ��״̬"
	CUST_CNT="���¿ͻ�����"
	PER_NOW_1="����ռ��"
	per_last_1="����ռ��"
	;
run;
data C01;
	retain loanind CUST_CNT PER_NOW;
	set C01;
run;

/*	2.	C02�ͻ��Ա�״���ֲ������*/
/*�������*/
PROC SQL;
	CREATE TABLE CUST_SEX_0 AS SELECT
		 A.SORGCODE
		 ,A.SCERTNO
		 ,B.imarriage
		 ,B.iedulevel
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
		 ,B.IGENDER
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B 
	ON  A.spin = B.spin
;
QUIT;

DATA CUST_SEX_1;
 	SET CUST_SEX_0;
	IF MOD(SUBSTR(SCERTNO,17,1),2)=1 THEN SEX=1;
	ELSE IF MOD(SUBSTR(SCERTNO,17,1),2)=0 THEN SEX =2;
	ELSE SEX=IGENDER;
	IF SEX=. or SEX=0 THEN SEX=9;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
DATA  CUST_SEX_2(KEEP=SHORT_NM DOC_TYPE SCERTNO);
	LENGTH SHORT_NM $30.
			DOC_TYPE $30.;
	SET CUST_SEX_1;
	IF SEX=0;
	DOC_TYPE=PUT(SCERTTYPE,$DOC_TYPE.);
RUN;

PROC SQL;
	CREATE TABLE CUST_SEX_0 AS SELECT
		 A.SORGCODE
		 ,A.SCERTNO
		 ,B.imarriage
		 ,B.iedulevel
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
		 ,B.IGENDER
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B 
	ON  A.spin=B.spin
;
QUIT;

DATA CUST_SEX_1;
 	SET CUST_SEX_0;
	IF MOD(SUBSTR(SCERTNO,17,1),2)=1 THEN SEX=1;
	ELSE IF MOD(SUBSTR(SCERTNO,17,1),2)=0 THEN SEX =2;
	ELSE SEX=IGENDER;
	IF SEX=. or SEX=0 THEN SEX=9;
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
RUN;
DATA  CUST_SEX_2(KEEP=SHORT_NM DOC_TYPE SCERTNO);
	LENGTH SHORT_NM $30.
			DOC_TYPE $30.;
	SET CUST_SEX_1;
	IF SEX=0;
	DOC_TYPE=PUT(SCERTTYPE,$DOC_TYPE.);
RUN;

/*�������*/
DATA CUST_SEX_T2_1;
 	SET SINO_PERSON_CERT_01(keep=SCERTNO);
	IF MOD(SUBSTR(SCERTNO,17,1),2)=1 THEN SEX=1;
	ELSE IF MOD(SUBSTR(SCERTNO,17,1),2)=0 THEN SEX=2;
	ELSE SEX=9;
	drop SCERTNO;
RUN;

data _null_;
	set CUST_SEX_T2_1;
	retain CUST_SEX_CNT1 0 CUST_SEX_CNT2 0 CUST_SEX_CNT9 0;
		if SEX=1 then CUST_SEX_CNT1=CUST_SEX_CNT1+1;
		else if SEX=2 then CUST_SEX_CNT2=CUST_SEX_CNT2+1;
		else CUST_SEX_CNT9=CUST_SEX_CNT9+1;
	call symput('CUST_SEX_PER1',CUST_SEX_CNT1/&cust_total_last.);
	call symput('CUST_SEX_PER2',CUST_SEX_CNT2/&cust_total_last.);
	call symput('CUST_SEX_PER9',CUST_SEX_CNT9/&cust_total_last.);
run;

/*����C02*/
PROC SQL;
	CREATE TABLE C02 AS SELECT
		SEX
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT
		,calculated CUST_CNT/&cust_total_now. as per_now label="����ռ��"
	FROM CUST_SEX_1
	GROUP BY SEX;
QUIT;

proc iml;
	reset print;
	use C02;
	read all into sex1;
	sex2={&CUST_SEX_PER1.,&CUST_SEX_PER2.,&CUST_SEX_PER9.};
	sex0=sex1||sex2;
	create C02_temp var{SEX,CUST_CNT,per_now,per_last};
	append from sex0;
quit;

data C02;
	set C02_temp;
	length SEX_1 $4.;
	if SEX=1 then SEX_1="��";
	else if SEX=2 then SEX_1="Ů";
	else SEX_1="����";
	PER_NOW_1=put(PER_NOW,percent8.2);
	PER_LAST_1=put(per_last,percent8.2);
	drop SEX PER_NOW per_last;
	rename SEX_1=SEX PER_NOW_1=PER_NOW PER_LAST_1=PER_LAST;
	label
	SEX_1="�Ա�"
	CUST_CNT="���¿ͻ�����"
	PER_NOW_1="����ռ��"
	per_last_1="����ռ��"
	;
run;
data C02;
	retain SEX CUST_CNT PER_NOW;
	set C02;
run;

/*3.	C03�ͻ�����״���ֲ������*/
/*ȫ��*/
/*T-1*/
PROC SQL;
	CREATE TABLE CUST_BIRTH AS SELECT
		 A.SCERTNO
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
		 ,B.IMARRIAGE
		 ,B.IEDULEVEL
		 ,B.IEDUDEGREE
		 ,B.IGENDER
	FROM SINO_PERSON_CERT1 AS A
	LEFT JOIN SINO_PERSON1 AS B ON A.spin=B.spin;
QUIT;

DATA CUST_BIRTH1;
	SET CUST_BIRTH;
	IF LENGTH(SCERTNO)=18 THEN BIRTH_DT=MDY(SUBSTR(SCERTNO,11,2),SUBSTR(SCERTNO,13,2),SUBSTR(SCERTNO,7,4));
	IF BIRTH_DT=. THEN BIRTH_DT=BIRTH;
	AGE_CD=PUT(intck('year',BIRTH_DT,&STAT_DT.),age_level.);
RUN;


PROC SQL;
	CREATE TABLE C03_TEMP1 AS SELECT
		AGE_CD
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT LABEL='�ܿͻ���'
		,put(calculated CUST_CNT/&cust_total_now.,percent8.2) as per_now label="���¸������ռ��"
	FROM CUST_BIRTH1
	GROUP BY AGE_CD;
QUIT;

/*T-2*/
PROC SQL;
	CREATE TABLE CUST_BIRTH_T2 AS SELECT
		 A.SCERTNO
		 ,DATEPART(B.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
		 ,(CASE WHEN LENGTH(SCERTNO)=18 THEN MDY(input(SUBSTR(SCERTNO,11,2),2.),input(SUBSTR(SCERTNO,13,2),2.),input(SUBSTR(SCERTNO,7,4),4.)) ELSE calculated BIRTH END) AS BIRTH_DT FORMAT=YYMMDD10. INFORMAT=YYMMDD10.
		 ,PUT(intck('year',calculated BIRTH_DT,&STAT_DT.),age_level.) AS AGE_CD
	FROM SINO_PERSON_CERT_01 AS A
	LEFT JOIN SINO_PERSON_01 AS B ON A.spin=B.spin;
QUIT;

PROC SQL;
	CREATE TABLE C03_TEMP2 AS SELECT
		AGE_CD
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT LABEL='�ܿͻ���'
		,put(calculated CUST_CNT/&cust_total_last.,percent8.2) as per_last label="���¸������ռ��"
	FROM CUST_BIRTH_T2
	GROUP BY AGE_CD;
QUIT;

/*����ҵ��*/
PROC SORT DATA=CUST_BIRTH1 NODUPKEY OUT=CUST_HIGH2;
	BY SCERTNO;
RUN;
PROC SQL;
	CREATE TABLE LOAN_CUST AS SELECT
		A.SCERTNO
		,COALESCE(B.imarriage,90) AS imarriage
		,COALESCE(B.iedulevel,99) AS iedulevel
		,B.AGE_CD
	FROM Cust_loanind1(WHERE=(LOANIND=1)) AS A
	LEFT JOIN Cust_high2 AS B ON A.SCERTNO=B.SCERTNO
	;
QUIT;

PROC SQL NOPRINT;
	SELECT COUNT(DISTINCT SCERTNO) INTO :CUST_LOAN_CNT
		FROM LOAN_CUST;
QUIT;

PROC SQL;
	CREATE TABLE C03_TEMP0 AS SELECT
		AGE_CD LABEL='����ֲ�'
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT LABEL='����ҵ��Ŀͻ���'
		,put(calculated CUST_CNT/&CUST_LOAN_CNT.,percent8.2) as per_now label="����ҵ�������οͻ�ռ��"
	FROM  LOAN_CUST
	GROUP BY AGE_CD;
QUIT;

data C03;
	merge C03_TEMP0(in=x) C03_TEMP1(rename=(CUST_CNT=CUST_CNT1 PER_NOW=PER_NOW1) in=y) C03_TEMP2(drop=CUST_CNT in=z);
		by AGE_CD;
		if x=y=z=1;
run;

/*4.	C04�ͻ�����״���ֲ������*/
/*PROC SQL;*/
/*	SELECT*/
/*		imarriage*/
/*		,COUNT(DISTINCT SCERTNO) AS CUST_CNT*/
/*	FROM CUST_BIRTH1*/
/*	GROUP BY imarriage;*/
/*QUIT;*/

/*����ҵ��Ŀͻ�*/
PROC SQL;
	CREATE TABLE C04_temp1 AS SELECT
		imarriage LABEL="����״��"
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT LABEL="����ҵ��Ŀͻ���"
		,put(calculated CUST_CNT/&CUST_LOAN_CNT.,percent8.2) as per_now label="ռ����ҵ��ͻ�����"
	FROM  LOAN_CUST
	GROUP BY imarriage;
QUIT;
/*ȫ���ͻ�*/
PROC SQL;
	CREATE TABLE C04_temp2 AS SELECT
		COALESCE(imarriage,90) AS imarriage LABEL="����״��"
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT_1 LABEL="�ͻ�����"
		,put(calculated CUST_CNT_1/&cust_total_now.,percent8.2) as per_now_1 label="ռ�ͻ�������"
	FROM  Cust_birth
	GROUP BY calculated imarriage;
QUIT;

DATA C04;
	MERGE C04_temp1(IN=X) C04_temp2(IN=Y);
		BY imarriage;
		IF Y=1;
		MARRIAGE_TYPE=put(imarriage,MARRIAGE_TYPE.);
		LABEL
		MARRIAGE_TYPE="����״��"
		;
RUN;

DATA C04;
	retain MARRIAGE_TYPE;
	SET C04;
		DROP imarriage;
RUN;


/*5.	C05�ͻ�ѧ��״���ֲ������*/


/*�������*/
PROC SQL;
	CREATE TABLE C05_temp2 AS SELECT
		COALESCE(iedulevel,99) AS iedulevel
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT_EDU LABEL="�ͻ�����"
		,put(calculated CUST_CNT_EDU/&cust_total_now.,percent8.2) AS PER_EDU LABEL="ռ�ͻ�������"
	FROM CUST_BIRTH1
	GROUP BY calculated iedulevel;
QUIT;

/*����ҵ��Ŀͻ���*/
PROC SQL;
	CREATE TABLE C05_temp1 AS SELECT
		iedulevel
		,COUNT(DISTINCT SCERTNO) AS CUST_CNT_EDU_LOAN LABEL="����ҵ��Ŀͻ���"
		,put(calculated CUST_CNT_EDU_LOAN/&CUST_LOAN_CNT.,percent8.2) AS PER_EDU_LOAN label="ռ����ҵ��ͻ�����"
	FROM  LOAN_CUST
	GROUP BY iedulevel;
QUIT;

DATA C05;
	MERGE C05_temp1(IN=X) C05_temp2(IN=Y);
		BY iedulevel;
		IF Y=1;
		EDU_TYPE=put(iedulevel,EDU_TYPE.);
		LABEL
		EDU_TYPE="ѧ��"
		;
RUN;

DATA C05;
	retain EDU_TYPE;
	SET C05;
		DROP iedulevel;
RUN;



/*%MEND CUST_ANALYSIS;*/
/*��� 2015-02-05*/
LIBNAME MYXLS EXCEL &OUTPATH_C01.;
DATA MYXLS."C01�Ƿ���ҵ��"n(dblabel=YES);
	SET C01;
RUN;
DATA MYXLS."C02�Ա�"n(dblabel=YES);
	SET C02;
RUN;
DATA MYXLS."C03����"n(dblabel=YES);
	SET C03;
RUN;
DATA MYXLS."C04����"n(dblabel=YES);
	SET C04;
RUN;
DATA MYXLS."C05ѧ��"n(dblabel=YES);
	SET C05;
RUN;
LIBNAME MYXLS CLEAR;
%MEND;
