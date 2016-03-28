%include "E:/�½��ļ���/SAS/config.sas";
%let enddate = %sysfunc(mdy(2,29,2016));
%put x= &enddate.;

/*libname ccs "D:\����\CCS\&curr_month.";*/

/*������������*/
proc sql;
	create table ccs_org as select
		distinct T1.sorgcode as FINANCECODE label = "��������"
		,T2.sorgname as sorgname label = "��������"
/*		,datepart(duploadtime) as dgetdate format = YYMMDDD10.*/
	 	FROM ccs.sino_msg(where = (substr(sorgcode,1,1) ^= 'Q')) as T1
		left join ccs.sino_org as T2
		on T1.sorgcode = T2.sorgcode
;
quit;
/*(keep= SORGCODE duploadtime WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001') and datepart(duploadtime) <= &enddate.))*/

/**********************�����ͻ�����ͳ����Ϣ**************************/

/*��ҵ��ͻ���*/
PROC SQL;
	CREATE TABLE CUS_CNT  AS SELECT
		E.FINANCECODE AS FINANCECODE LABEL='��������'
		,COUNT(DISTINCT E.ENTERPRISEID) AS CUS_CNT LABEL='����ҵ��ͻ�����'
	FROM CCS.EB_FINANCINGLEASE_CON AS E
	where datepart(dgetdate) <= &enddate.
	GROUP BY E.FINANCECODE
	;
QUIT;
/*��ͬ�����ܽ��*/
PROC SQL;
	CREATE TABLE CON_CNT AS SELECT 
		A.FINANCECODE AS FINANCECODE LABEL = '��������'
		,COUNT(DISTINCT COPERATIONID) AS CON_CNT LABEL = '��ͬ����'
		,SUM(INPUT(A.LEASESUM,12.)) AS LEASESUM LABEL = '�����ܽ��'
	FROM  CCS.EB_FINANCINGLEASE AS A
	where datepart(dgetdate) <= &enddate.
	GROUP BY A.FINANCECODE
;
QUIT;

/*����ҵ���� �����ܽ��*/
proc sort data = CCS.EB_FINANCINGLEASE_RENTAL(keep = FINANCECODE dgetdate DBOPERATIONID RENTALDEGREE OVERDUEAMOUNT) out = EB_FINANCINGLEASE_RENTAL;
	by FINANCECODE DBOPERATIONID desending RENTALDEGREE;
run;
data EB_FINANCINGLEASE_RENTAL;
	set EB_FINANCINGLEASE_RENTAL;
	if DBOPERATIONID = lag(DBOPERATIONID) then delete;
	OVERDUEAMOUNT_n = input(OVERDUEAMOUNT,12.);
drop 
OVERDUEAMOUNT
;
run;
PROC SQL;
	CREATE TABLE DEFAULT_CNT AS SELECT 
		A.FINANCECODE AS FINANCECODE LABEL = '��������'
		,COUNT(DISTINCT DBOPERATIONID) AS OVERDUE_CNT LABEL = '����ҵ����'
		,SUM(A.OVERDUEAMOUNT_n) AS OVERDUEAMOUNT LABEL = '�����ܽ��'
	FROM  EB_FINANCINGLEASE_RENTAL(where = (OVERDUEAMOUNT_n > 0)) AS A
	where datepart(dgetdate) <= &enddate.
	GROUP BY A.FINANCECODE
;
QUIT;

/*����*/

proc sql;
	create table CCS_OPT_2W as select
	T1.*
	,T2.*
	,T3.*
	,T4.*
	from ccs_org as T1
	left join CUS_CNT as T2
	on T1.FINANCECODE = T2.FINANCECODE
	left join CON_CNT as T3
	on T1.FINANCECODE = T3.FINANCECODE
	left join DEFAULT_CNT as T4
	on T1.FINANCECODE = T4.FINANCECODE
;
quit;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\˫�ܱ����\CCS\CCS˫�ܼ�_&curr_month..xls";
data xls.sheet1(dblabel = yes);
set CCS_OPT_2W;
run;
libname xls clear;
/*data CCS_OPT_2W;*/
/*	format text $2000.;*/
/*	set CCS_OPT_2W;*/
/*	text = %sysfunc(catx()*/


