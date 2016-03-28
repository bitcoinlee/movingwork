%include "E:\�½��ļ���\SAS\������.sas";
%include "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%format;
data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then
call symput('chkmonth',cat(put(year(today())-1,$4.),put(12,$2.)));
else call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%chkfile("E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\&chkmonth.");
options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
libname nfcs 'D:\����\&chkmonth.';
proc sort data = nfcs.sino_loan(keep = sorgcode saccount dbillingdate ddateopened ddateclosed SMONTHDURATION icreditlimit streatypaydue ITREATYPAYAMOUNT ischeduledamount iamountpastdue iamountpastdue iaccountstat WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out = loan_int_base nodupkey;
by sorgcode saccount desending dbillingdate;
run;
data loan_int_base;
	set loan_int_base;
	if sorgcode =lag(sorgcode) and saccount = lag(saccount) then delete;
run;

data loan_int_1;
	format interest percent8.2;
	informat interest percent8.2;
	format interest_year_single percent8.2;
	informat interest_year_single percent8.2;
	format STREATYPAYDUE_num 2.;
	format ITREATYPAYAMOUNT_num best12.;
	set loan_int_base;
	if STREATYPAYDUE in ('U' 'X') or ITREATYPAYAMOUNT = 'U' then delete;
	if STREATYPAYDUE = 'O' then STREATYPAYDUE_num = 1;
	STREATYPAYDUE_num = input(STREATYPAYDUE,2.);
	ITREATYPAYAMOUNT_NUM = INPUT(ITREATYPAYAMOUNT,BEST12.);
	interest = round((ITREATYPAYAMOUNT * STREATYPAYDUE / ICREDITLIMIT - 1),0.0001);
	MONTHDURATION = input(SMONTHDURATION,4.);
	CREDITLIMIT = put(put(ICREDITLIMIT,PAY_AMT_level.),$PAY_AMT_CD.);
/*	if interest <= 0 then delete;*/
	interest_year_single = round(interest * 12 /MONTHDURATION,0.0001);
	label
	MONTHDURATION = ����ʱ��(��)
	interest_year_single = �껯������(�ٷֱ�)
	CREDITLIMIT = �������
	;
run;

/*ods html close;*/
ods graphics on/reset
imagefmt=png
imagemap=on
imagename="����ʱ��-��Ϣɢ��ͼ";
/*ods html file="Boxplot-Body.html" */
ODS LISTING GPATH="E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\&chkmonth." style = default image_dpi=300;
/*ods select fit;*/
/*��������ɫ��-����ʱ��-���� ͼ*/
Proc sgplot data=loan_int_1(where = (0.12<=interest_year_single<=0.3));
title "����ʱ��-��Ϣɢ��ͼ";
scatter x= MONTHDURATION y= interest_year_single/ group = CREDITLIMIT;
/*plot _col1*_col0=group /haxis=axis1 vaxis=axis2;*/
label CREDITLIMIT="�������";
yaxis min=0 max=0.4 ;
run;
ods graphics off;
ods html close;


/*X:�����ʱ��-Y:����-�����׼���� ͼ*/

/*������-���� ͼ*/

/*���ʷֶ�-������ ��*/

/*��Ȩӯ����� = ��������������-����-�ʽ�ɱ�*/
