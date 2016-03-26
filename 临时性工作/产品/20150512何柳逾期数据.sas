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
	DGETDATE = ����ʱ��
	scertno = ֤������
	icreditlimit = ���Ŷ��
	iamountpastdue = ��ǰ�����ܶ�
	Iamountpastdue0 = ����0-30��δ�黹�����
	Iamountpastdue30 = ����31-60��δ�黹�����
	Iamountpastdue60 = ����61-90��δ�黹�����
	Iamountpastdue90 = ����91-180��δ�黹�����
	Iamountpastdue180 = ����180������δ�黹�����
	iaccountstat = �˻�״̬
	;
run;

/*����*/
proc sql;
create table renshu_heliu as select
	spin
	,intnx("month",datepart(dgetdate),0,"b") as yuefen format = yymmd7.
	from mylib.sino_person_certification(keep = spin dgetdate sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
;
quit;

libname xls excel "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\����ļ���\��ʱ�Թ���\����\�������-V3.0.xlsx";
data xls.sheet2(dblabel=yes);
set _heliu_yuqi;
run;
libname xls clear;

/*proc sql;*/
/*	create table aaa as */
/*	select */
/*		* */
/*	from mylib.sino_org as a*/
/*	where a.sorgname like '%���%'*/
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

