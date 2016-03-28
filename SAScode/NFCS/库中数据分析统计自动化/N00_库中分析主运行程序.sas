OPTIONS MPRINT MLOGIC NOXWAIT COMPRESS=YES;/*ѡ������*/
libname sss oracle user=datauser password=zlxdh7jf path=p2p;

/*���ڸ���format��SMONTHDURATION*/
/*proc sql;*/
/*	create table all_SMONTHDURATION as select*/
/*		distinct SMONTHDURATION*/
/*		from nfcs.sino_loan*/
/*;*/
/*quit;*/
/*filename myfile "C:\Users\Data Analyst\Desktop\���ô���\�Զ���\All_smonthduration.txt";*/
/*data _null_;*/
/*set All_smonthduration;*/
/*file myfile;*/
/*put SMONTHDURATION;*/
/*run;*/

data _null_;
ismonth=month(today());
if 1 > ismonth > 10 then
call symput('STAT_OP',cat(put(year(today()),$4.),"��",put(month(intnx('month',today(),-1)),$2.),"��ȫ��"));
else if ismonth=1 then call symput('STAT_OP',cat(put(year(today())-1,$4.),"��12��ȫ��"));
else call symput('STAT_OP',cat(put(year(today()),$4.),"��",put(month(intnx('month',today(),-1)),$1.),"��ȫ��"));
run;
%put &STAT_OP.;
%LET STAT_DT=intnx('month',today(),-1,'end');
%LET LAST_DT=INTNX('MONTH',&STAT_DT.,-1,'END');
/*LIBNAME SSS "D:\����\&STAT_OP.";*/
%LET PATH=E:\�½��ļ���\SAS\���ô���;
%LET PATH_000="&PATH.\�Զ���\000_FORMAT.sas";
/*�������������������*/
%LET PATH_D01="&PATH.\�Զ���\�������ݷ���ͳ���Զ���\D01_�����������.sas";
/*һ�����������������*/
%LET PATH_B01="&PATH.\�Զ���\�������ݷ���ͳ���Զ���\B01_һ��ҵ�����.sas";
/*�������ڷ�����������*/
%LET PATH_O01="&PATH.\�Զ���\�������ݷ���ͳ���Զ���\O01_�������ڷ���.sas";
/*����ͻ�������������*/
%LET PATH_C01="&PATH.\�Զ���\�������ݷ���ͳ���Զ���\C01_����ͻ�����.sas";
/*��¼������������*/
%LET PATH_F01="&PATH.\�Զ���\�������ݷ���ͳ���Զ���\FL_��¼.sas";
/*������*/
%LET OUTPATH_D01="&PATH.\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\�����������&STAT_OP..XLS";
%LET OUTPATH_B01="&PATH.\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\һ��ҵ�����&STAT_OP..XLS";
%LET OUTPATH_O01="&PATH.\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\�������ڷ���&STAT_OP..XLS";
%LET OUTPATH_C01="&PATH.\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\����ͻ�����&STAT_OP..XLS";
%LET OUTPATH_F01="&PATH.\�Զ���\����ļ���\�������ݷ���ͳ�ƽ��\���з�����¼&STAT_OP..XLS";
%INCLUDE &PATH_000.;
%INCLUDE &PATH_D01.;
%INCLUDE &PATH_B01.;
%INCLUDE &PATH_O01.;
%INCLUDE &PATH_C01.;
%INCLUDE &PATH_F01.;
%FORMAT;
%AREA_ANALYSIS(&STAT_DT);
%LOAN_ANALYSIS(&STAT_DT);
%OVERDUE_ANALYSIS(&STAT_DT);
%CUST_ANALYSIS(&STAT_DT);
%FL(&STAT_DT);
ods html;
