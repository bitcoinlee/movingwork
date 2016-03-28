

/*ԭʼ���ĵ������                ���İ�              2015.03.16           by  *���/

/*
��root��Ŀ¼�£�(ĳ���ʱ������)��
��ȡ�ļ�������·�������뵽fileindex_txt��fileindex_xls��
�ֱ�select into mvar����Ϊpathfile��
��ĳpathfile�����ֶε��룻
��һ��append�ϲ���
*/
/*/s/b related*/
/*
root, fileindex *(txt xls),(year month)(org)
*/
%include "E:\�½��ļ���\SAS\������.sas";

data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then 
call symput('chkmonth',cat(put(year(intnx('year',today(),-1,'end')),$4.),"12"));
else  
call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%put x=&chkmonth.;

%LET PATH=E:\�½��ļ���\SAS\���������Զ���\���������Զ���20150316;
%LET OUT_DATA=E:\�½��ļ���\&chkmonth.\NFCS;
%LET PATH_TXT="&PATH.\T01_TXT�������.sas";
%LET PATH_TXTER="&PATH.\T02_TXT�����������.sas";
%LET PATH_EXCEL="&PATH.\E01_EXCEL�������.sas";
%LET PATH_EXCELER="&PATH.\E02_EXCEL�����������.sas";
%LET PATH_EXCEL_TRAN="&PATH.\E03_EXCEL��ʽת��.sas";
%let root1=E:\NFCS\���ļ�����\&chkmonth.\data\;
%let root_er=E:\NFCS\���ļ�����\&chkmonth.\feedback\;
%let path_1=E:\NFCS\���ļ�����\&chkmonth.\;
%let path_er=E:\NFCS\���ļ�����\&chkmonth.\;
/*�����ݼ������������ļ���*/
%macro outcopy(NAME,dest);
%chkfile("&OUT_DATA.\&dest.");
LIBNAME COPYDATA "&OUT_DATA.\&dest.";
	DATA COPYDATA.&NAME.;
		SET &NAME.;
	RUN;
libname COPYDATA clear;
%mend;
/*����xls���ļ��������ݽṹ�����ͳ�����*/
%macro xlsstruct(setname,folder);
%chkfile("E:\�½��ļ���\&chkmonth.\NFCS\&folder.");
libname xls_s "E:\�½��ļ���\&chkmonth.\NFCS\&folder.";
	data &setname.;
		set xls_s.&setname.;
	if _n_^=0 then delete;
	run;
libname xls_s clear;
%mend;



%GetFileAndSubDirInfoInDir(E:\�½��ļ���\&chkmonth.\NFCS��������\�������,TXT,fileindex_txt, ,yes);
%GetFileAndSubDirInfoInDir(E:\�½��ļ���\&chkmonth.\NFCS��������\�������,XLS,fileindex_xls, ,yes);
%GetFileAndSubDirInfoInDir(E:\�½��ļ���\&chkmonth.\NFCS��������\�������,TXT,er_fileindex_txt, ,yes);
%GetFileAndSubDirInfoInDir(E:\�½��ļ���\&chkmonth.\NFCS��������\�������,XLS,er_fileindex_xls, ,yes);



/*XLS TXT�������ĵ���*/
ods listing close;
ods results off;
ODS TRACE OFF;
/*options noxwait mlogic=off mprint=off;*/

/*����ʹ��x����д���ı��ļ��ķ�ʽ�������ļ��б�*/
/*x dir &root1 /s/b >&path_1.file11.txt;*/
/*data fileindex;/*�����ⲿ�ļ�of�ļ�����·��,���ɻ������ϴ�����*/*/
/*infile "&path_1.file11.txt" dsd truncover lrecl=32767;*/
/*input x $2000.;*/
/*call scan(x,5,position1,length1,"\");*/
/*call scan(x,6,position2,length2,"\");*/
/*call scan(x,8,position3,length3,"\");*/
/*IF LENGTH(x)>82;*/
/*/*call scan()����position length,����substrn*/*/
/*uploaddate=substrn(x,position1,length1);*/
/*sorgcode=substrn(x,position2,length2);*/
/*filename=substrn(x,position3,length3);*/
/*filetype=upcase(substr(filename,length(filename)-2,3));*/
/*IF filetype='LSX' then filetype='XLS';*/
/*drop position1 length1 position2 length2 position3 length3;*/
/*run;*/

/*proc freq data=fileindex;*/
/*table sorgcode * filetype;*/
/*run;*/
/**/
/*data fileindex_sub;
/*set fileindex;*/
/*where sorgcode in (&org_select);*/
/*run;*/

/*data fileindex_xls fileindex_txt;*/
/*/*����xls and txt*/*/
/*set fileindex;*/
/*if filetype='XLS' then output fileindex_xls;*/
/*if filetype='TXT' then output fileindex_txt;*/
/*run;*/
;

/*����xls������*/
data _null_;/*xls*/
set fileindex_xls end=last;
if last then m=_n_;
call symput('xls_last',compress('xls'||m));
call symput('ul_xls',m);
run; 
%put &ul_xls;
proc sql noprint;
select NAME into :xls1-:&xls_last
from fileindex_xls;
quit;
%put &xls1;
%put &xls300;

/*����txt������*/
data _null_;
set fileindex_txt end=last;
if last then m=_n_;
call symput('txt_last',compress('txt'||m));
call symput('ul_txt',m);
run; 
%put &ul_txt;
%put &txt_last;
proc sql noprint;
select NAME into :txt1-:&txt_last 
from fileindex_txt;
quit;

/*����xls���ݽṹ*/
%xlsstruct(t_a,bw_xls);
%xlsstruct(t_pb,bw_xls);
%xlsstruct(t_pc,bw_xls);
%xlsstruct(t_pd,bw_xls);
%xlsstruct(t_s,bw_xls);
%xlsstruct(t_g,bw_xls);
%xlsstruct(t_e,bw_xls);
%xlsstruct(t_h,bw_xls);
%xlsstruct(t_t,bw_xls);

/*����er_xls���ݽṹ*/
%xlsstruct(er_xls,er_xls);

/*libname er_xls_s "E:\�½��ļ���\201502\NFCS\er_xls";*/
/*data er_xls;*/
/*	set er_xls_s.er_xls;*/
/*	if _n_^=0 then delete;*/
/*run;*/
/*libname er_xls_s clear;*/
/*Normal_xls����*/
%include &PATH_EXCEL.;
%include &PATH_EXCEL_TRAN.;
%macro cir;
%do i=1 %to &ul_xls;
%im_xls_pack(&&xls&i);
%end;
%mend;
%cir;
/*�޸ı������Ƶĳ������ñ�����*/
/*�޸����ݸ�ʽ������ֵ�ͱ���*/

/*Normal_txt����*/
%include &PATH_TXT.;
%macro file_out;
%do j=1 %to &ul_txt.;
%PQ_input(Pq_&j,&&txt&j);
%SQ_input(Sq_&j,&&txt&j);
%AQ_input(Aq_&j,&&txt&j);
%HQ_input(Hq_&j,&&txt&j);
%EQ_input(Eq_&j,&&txt&j);
%TQ_input(Tq_&j,&&txt&j);
%GQ_input(Gq_&j,&&txt&j);
/*&&txt&jΪ�������ã����Ҫ������&�ű�ʾ*/
%end;
%mend;
%file_out;


/*LIBNAME COPYDATA "&OUT_DATA.";*/
/*%macro outcopy(NAME);*/
/*	DATA COPYDATA.&NAME.;*/
/*		SET &NAME.;*/
/*	RUN;*/
/*%mend;*/

/*���ĵ���*/



/*Feedback����·�������*/
/*ODS TRACE OFF; options noxwait mlogic=off mprint=off;*/
/*x dir &root_er /s/b >&path_er.file12.txt;*/

/*data er_fileindex;*/
/*/*�����ⲿ�ļ�of�ļ�����·��,���ɻ������ϴ�����*//*call scan()����position length,����substrn*/*/
/*infile "&path_er.file12.txt" dsd truncover lrecl=32767;*/
/*input x $2000.;*/
/*call scan(x,3,position1,length1,"\");*/
/*call scan(x,4,position2,length2,"\");*/
/*uploaddate=substrn(x,position1,length1);*/
/*sorgcode=substrn(x,position2,length2);*/
/*drop position1 length1 position2 length2;*/
/*run;*/
/**/
/*data er_fileindex_sub;
/*set er_fileindex;ɸѡ����������*/
/*/*if substr(uploaddate,1,4)=&check_yy and substr(uploaddate,6,2)=&check_mon; */*/
/*/*where sorgcode in (&org_select);*/*/
/*/*run;*/*/
/**/
/*data er_fileindex_xls er_fileindex_txt;/*����xls and txt*/*/
set er_fileindex;
/*if substr(x,length(x)-2,3)='xls' then output er_fileindex_xls;*/
/*if substr(x,length(x)-2,3)='txt' then output er_fileindex_txt;;*/
/*run;*/

/*����ER_xls������*//*nobs=m ϵͳ����nobs�۲���*/
data _null_;/*xls*/
set er_fileindex_xls end=last;
if last then m=_n_;
call symput('exls_last',compress('exls'||m));
call symput('eul_xls',m);
run; 
%put &eul_xls;
proc sql noprint;
select NAME into :exls1-:&exls_last
from er_fileindex_xls;
quit;
%put &xls1;
%put &xls100;

/*Error_xls����*/
%include &PATH_EXCELER.;
%macro cir;
%do i=1 %to &eul_xls;
%fbim(&&exls&i,������Ϣ,er_xls&i);
%end;
%mend;

%cir;

%OUTCOPY(ER_xls);

/*����ER_txt������*/
data _null_;
set er_fileindex_txt end=last;
if last then m=_n_;
call symput('etxt_last',compress('etxt'||m));call symput('eul_txt',m);
run; 
%put &eul_txt;
proc sql noprint;
select NAME into :etxt1-:&etxt_last 
from er_fileindex_txt;
quit;

/*Error_txt����*/
%include &PATH_TXTER.;
%macro file_out;
%do j=1 %to &eul_txt;
%Er_PQ_input(Er_Pq_&j,&&Etxt&j);
%Er_SQ_input(Er_Sq_&j,&&Etxt&j);
%Er_AQ_input(Er_Aq_&j,&&Etxt&j);
%Er_HQ_input(Er_Hq_&j,&&Etxt&j);
%Er_EQ_input(Er_Eq_&j,&&Etxt&j);
%Er_TQ_input(Er_Tq_&j,&&Etxt&j);
%Er_GQ_input(Er_Gq_&j,&&Etxt&j);
%end;
%mend;
%file_out;
/*txt���ĵ���*/
%OUTCOPY(PQ,bw_txt);
%OUTCOPY(SQ,bw_txt);
%OUTCOPY(AQ,bw_txt);
%OUTCOPY(HQ,bw_txt);
%OUTCOPY(EQ,bw_txt);
%OUTCOPY(TQ,bw_txt);
%OUTCOPY(GQ,bw_txt);
/*xls���ĵ���*/
%OUTCOPY(T_a,bw_xls);
%OUTCOPY(T_pb,bw_xls);
%OUTCOPY(T_pc,bw_xls);
%OUTCOPY(T_pd,bw_xls);
%OUTCOPY(T_s,bw_xls);
%OUTCOPY(T_g,bw_xls);
%OUTCOPY(T_e,bw_xls);
%OUTCOPY(T_h,bw_xls);
%OUTCOPY(T_t,bw_xls);
/*xls��������*/
%OUTCOPY(Er_T_a,er_xls);
%OUTCOPY(Er_T_pb,er_xls);
%OUTCOPY(Er_T_pc,er_xls);
%OUTCOPY(Er_T_pd,er_xls);
%OUTCOPY(Er_T_s,er_xls);
%OUTCOPY(Er_T_g,er_xls);
%OUTCOPY(Er_T_e,er_xls);
%OUTCOPY(Er_T_h,er_xls);
%OUTCOPY(Er_T_t,er_xls);
/*TXT��������*/
%OUTCOPY(ER_PQ,er_txt);
%OUTCOPY(ER_SQ,er_txt);
%OUTCOPY(ER_AQ,er_txt);
%OUTCOPY(ER_HQ,er_txt);
%OUTCOPY(ER_EQ,er_txt);
%OUTCOPY(ER_TQ,er_txt);
%OUTCOPY(ER_GQ,er_txt);
ods listing;
ods results on;


/*������ ����ǩ*/
/*data t_pb;*/
/*	set t_pb;*/
/*	label col9=סլ�绰*/
/*		  col10=�ֻ�����*/
/*		  col11=��λ�绰*/
/*		  col12=��������*/
/*		  col13=ͨѶ��ַ*/
/*		  col14=ͨѶ��ַ��������*/
/*		  col15=������ַ*/
/*		  col16=��ż����*/
/*		  col17=��ż֤������*/
/*		  col18=��ż֤������*/
/*		  col19=��ż������λ*/
/*		  col20=��ż��ϵ�绰*/
/*		  col21=��һ��ϵ������*/
/*		  col22=��һ��ϵ�˹�ϵ*/
/*		  col23=��һ��ϵ�˵绰*/
/*		  col24=�ڶ���ϵ������*/
/*		  col25=�ڶ���ϵ�˹�ϵ*/
/*		  col26=�ڶ���ϵ�˵绰;*/
/*run;*/
/**/
/*data t_pc;*/
/*	set t_pc;*/
/*	label */
/*			col1=����*/
/*			col2=֤������*/
/*			col3=֤������*/
/*			col4=ְҵ*/
/*			col5=��λ����*/
/*			col6=��λ������ҵ*/
/*			col7=��λ��ַ*/
/*			col8=��λ��ַ��������*/
/*			col9=����λ������ʼ���*/
/*			col10=ְ��*/
/*			col11=ְ��*/
/*			col12=������;*/
/*run;*/
/**/
/*data t_pd;*/
/*	set t_pd;*/
/*	sorgcode=substr(filename,1,14);*/
/*run;*/
/**/
/*data t_pd;*/
/*	retain sorgcode;*/
/*	set t_pd;*/
/*	label   col0=����*/
/*			col1=֤������*/
/*			col2=֤������*/
/*			col3=��ס��ַ*/
/*			col4=��ס��ַ��������*/
/*			col5=��ס״��;*/
/*run;*/
/**/
/*data t_a;*/
/*	set t_a;*/
/*	rename */
/*col0=sorgcode */
/*col1=sloantype*/
/*col2=sloancompactcode */
/*col3=saccount */
/*col4=sareacode */
/*col5=ddateopened */
/*col6=ddateclosed */
/*col7=scurrency */
/*col8=icreditlimit */
/*col9=ishareaccount */
/*col10=imaxdebt */
/*col11=iguaranteeway */
/*col12=stermsfreq */
/*col13=imonthduration */
/*col14=imonthunpaid */
/*col15=streatypaydue */
/*col16=streatypayamount */
/*col17=dbillingdate */
/*col18=drecentpaydate */
/*col19=ischeduledamount */
/*col20=iactualpayamount */
/*col21=ibalance */
/*col22=icurtermspastdue */
/*col23=iamountpastdue */
/*col24=Iamountpastdue30 */
/*col25=Iamountpastdue60 */
/*col26=Iamountpastdue90 */
/*col27=Iamountpastdue180 */
/*col28=itermspastdue */
/*col29=imaxtermspastdue */
/*col30=iclass5stat */
/*col31=iaccountstat */
/*col32=Spaystat24month */
/*col33=iinfoindicator */
/*col34=sname */
/*col35=scerttype */
/*col36=scertno*/
/*;*/
/*run;*/
/**/


/*ֻҪ�ѽ���ϲ��Ϳ����ˣ���һ�����԰����ݼ��ϲ�*/
/*����ѡ����������Ϊͳ����
%macro ct(type);
%do i=1 %to &ul_xls;
PROC SQL NOPRINT;
create table n&type&i as 
select 
_col0 as orgobs format $20. ,
substr(filename,1,14) as sorgcode
from &type&i;
quit;
%end;

data &type;
set n&type.1 - n&type.77;
if sorgcode='��������03_1.x' then sorgcode='Q10155800H3200';
run;

proc sql noprint;
create table zstic&type as
select distinct 
count(orgobs) as nmiss_obs,
count(sorgcode) as total_obs,
sorgcode
from &type
group by sorgcode;
quit;

proc print data=zstic&type;run;
title "zstic&type"

%mend;

%ct(PB);
%ct(PC);
%ct(PD);
%ct(S);
%ct(A);
%ct(H);
%ct(E);
%ct(T);
%ct(G);

data zstatstic;
set 
ZsticPB(in=pb)
ZsticPC(in=pc)
ZsticPD(in=PD)
ZsticS (in=S)
ZsticA (in=A)
ZsticH (in=H)
ZsticE (in=E)
ZsticT (in=T)
ZsticG (in=G);
IF PB THEN TYPE='PB';
IF PC THEN TYPE='PC';
IF PD THEN TYPE='PD';
IF S THEN TYPE='S';
IF A THEN TYPE='A';
IF H THEN TYPE='H';
IF E THEN TYPE='E';
IF T THEN TYPE='T';
IF G THEN TYPE='G';
run;

*/
