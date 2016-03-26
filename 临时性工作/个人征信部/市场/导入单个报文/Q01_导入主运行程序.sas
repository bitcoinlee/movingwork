
/*ԭʼ���ĵ������                �ڶ���              2014.8.3           by  �±���*/

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
%LET PATH=C:\Users\cis\Desktop\���ô���;
%LET OUT_DATA=D:\ԭʼ�������ݼ�\8��\8��TXT;
%LET PATH_TXT="&PATH.\�Զ���\���������Զ���\T01_TXT�������.sas";
%LET PATH_TXTER="&PATH.\�Զ���\���������Զ���\T02_TXT�����������.sas";
%LET PATH_EXCEL="&PATH.\�Զ���\���������Զ���\E01_EXCEL�������.sas";
%LET PATH_EXCELER="&PATH.\�Զ���\���������Զ���\E02_EXCEL�����������.sas";
%LET PATH_EXCEL_TRAN="&PATH.\�Զ���\���������Զ���\E03_EXCEL��ʽת��.sas";
%let root1=D:\����\8�±���\data20140901\;
%let root_er=D:\����\8�±���\feedback20140901\;
%let path_1=D:\����\;
%let path_er=D:\;

/*XLS TXT�������ĵ���*/
ODS TRACE OFF;
options noxwait mlogic=off mprint=off;
x dir &root1 /s/b >&path_1.file11.txt;

data fileindex;/*�����ⲿ�ļ�of�ļ�����·��,���ɻ������ϴ�����*/
infile "&path_1.file11.txt" dsd truncover lrecl=32767;
input x $2000.;
call scan(x,5,position1,length1,"\");
call scan(x,6,position2,length2,"\");
call scan(x,8,position3,length3,"\");
IF LENGTH(x)>82;
/*call scan()����position length,����substrn*/
uploaddate=substrn(x,position1,length1);
sorgcode=substrn(x,position2,length2);
file_name=substrn(x,position3,length3);
filetype=upcase(substr(file_name,length(file_name)-2,3));
IF filetype='LSX' then filetype='XLS';
drop position1 length1 position2 length2 position3 length3;
run;

/*proc freq data=fileindex;*/
/*table sorgcode * filetype;*/
/*run;*/

/*data fileindex_sub;set fileindex;*/
/*where sorgcode in (&org_select);*/
/*run;*/

data fileindex_xls fileindex_txt;/*����xls and txt*/
set fileindex;
if filetype='XLS' then output fileindex_xls;
if filetype='TXT' then output fileindex_txt;;
run;

/*����xls������*/
data _null_;/*xls*/
set fileindex_xls end=last;
if last then m=_n_;
call symput('xls_last',compress('xls'||m));call symput('ul_xls',m);
run; %put &ul_xls;
proc sql noprint;select x into :xls1-:&xls_last
from fileindex_xls;
quit;%put &xls1;%put &xls11;

/*����txt������*/
data _null_;
set fileindex_txt end=last;
if last then m=_n_;
call symput('txt_last',compress('txt'||m));call symput('ul_txt',m);
run; %put &ul_txt;
proc sql noprint;select x into :txt1-:&txt_last 
from fileindex_txt;quit;

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
%do j=1 %to &ul_txt;
%PQ_input(Pq_&j,&&txt&j);
%SQ_input(Sq_&j,&&txt&j);
%AQ_input(Aq_&j,&&txt&j);
%HQ_input(Hq_&j,&&txt&j);
%EQ_input(Eq_&j,&&txt&j);
%TQ_input(Tq_&j,&&txt&j);
%GQ_input(Gq_&j,&&txt&j);
%end;
%mend;
%file_out;

LIBNAME COPYDATA "&OUT_DATA.";
%macro outcopy(NAME);
	DATA COPYDATA.&NAME.;
		SET &NAME.;
	RUN;
%mend;
%OUTCOPY(PQ);
%OUTCOPY(SQ);
%OUTCOPY(AQ);
%OUTCOPY(HQ);
%OUTCOPY(EQ);
%OUTCOPY(TQ);
%OUTCOPY(GQ);


/*Feedback����·�������*/
ODS TRACE OFF; options noxwait mlogic=off mprint=off;
x dir &root_er /s/b >&path_er.file11.txt;

data er_fileindex;/*�����ⲿ�ļ�of�ļ�����·��,���ɻ������ϴ�����*//*call scan()����position length,����substrn*/
infile "&path_er.file11.txt" dsd truncover lrecl=32767;
input x $2000.;
call scan(x,5,position1,length1,"\");
call scan(x,6,position2,length2,"\");
uploaddate=substrn(x,position1,length1);
sorgcode=substrn(x,position2,length2);
drop position1 length1 position2 length2;
run;

/*data er_fileindex_sub;set er_fileindex;/*ɸѡ����������*/
/*if substr(uploaddate,1,4)=&check_yy and substr(uploaddate,6,2)=&check_mon; */
/*where sorgcode in (&org_select);*/
/*run;*/

data er_fileindex_xls er_fileindex_txt;/*����xls and txt*/
set er_fileindex;
if substr(x,length(x)-2,3)='xls' then output er_fileindex_xls;
if substr(x,length(x)-2,3)='txt' then output er_fileindex_txt;;
run;

/*����ER_xls������*//*nobs=m ϵͳ����nobs�۲���*/
data _null_;/*xls*/
set er_fileindex_xls end=last;
if last then m=_n_;
call symput('exls_last',compress('exls'||m));call symput('eul_xls',m);
run; %put &eul_xls;
proc sql noprint;select x into :exls1-:&exls_last
from er_fileindex_xls;
quit;%put &xls1;%put &xls11;

/*����ER_txt������*/
data _null_;
set er_fileindex_txt end=last;
if last then m=_n_;
call symput('etxt_last',compress('etxt'||m));call symput('eul_txt',m);
run; %put &eul_txt;
proc sql noprint;select x into :etxt1-:&etxt_last 
from er_fileindex_txt;quit;

/*Error_xls����*/
%include &PATH_EXCELER.;

%macro cir;
%do i=1 %to &eul_xls;
%fbim(&&exls&i,������Ϣ,er_xls&i);
%end;
%mend;

%cir;


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
%OUTCOPY(ER_PQ);
%OUTCOPY(ER_SQ);
%OUTCOPY(ER_AQ);
%OUTCOPY(ER_HQ);
%OUTCOPY(ER_EQ);
%OUTCOPY(ER_TQ);
%OUTCOPY(ER_GQ);


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
