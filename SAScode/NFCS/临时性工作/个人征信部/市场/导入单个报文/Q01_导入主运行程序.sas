
/*原始报文导入程序                第二版              2014.8.3           by  陈倍佳*/

/*
自root根目录下，(某检查时点批次)；
获取文件的完整路径，导入到fileindex_txt和fileindex_xls里
分别select into mvar，作为pathfile；
对某pathfile进行字段导入；
做一个append合并；
*/
/*/s/b related*/
/*
root, fileindex *(txt xls),(year month)(org)
*/
%LET PATH=C:\Users\cis\Desktop\常用代码;
%LET OUT_DATA=D:\原始报文数据集\8月\8月TXT;
%LET PATH_TXT="&PATH.\自动化\质量控制自动化\T01_TXT导入程序.sas";
%LET PATH_TXTER="&PATH.\自动化\质量控制自动化\T02_TXT反馈导入程序.sas";
%LET PATH_EXCEL="&PATH.\自动化\质量控制自动化\E01_EXCEL导入程序.sas";
%LET PATH_EXCELER="&PATH.\自动化\质量控制自动化\E02_EXCEL反馈导入程序.sas";
%LET PATH_EXCEL_TRAN="&PATH.\自动化\质量控制自动化\E03_EXCEL格式转换.sas";
%let root1=D:\数据\8月报文\data20140901\;
%let root_er=D:\数据\8月报文\feedback20140901\;
%let path_1=D:\数据\;
%let path_er=D:\;

/*XLS TXT正常报文导入*/
ODS TRACE OFF;
options noxwait mlogic=off mprint=off;
x dir &root1 /s/b >&path_1.file11.txt;

data fileindex;/*导入外部文件of文件完整路径,生成机构和上传日期*/
infile "&path_1.file11.txt" dsd truncover lrecl=32767;
input x $2000.;
call scan(x,5,position1,length1,"\");
call scan(x,6,position2,length2,"\");
call scan(x,8,position3,length3,"\");
IF LENGTH(x)>82;
/*call scan()生成position length,用于substrn*/
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

data fileindex_xls fileindex_txt;/*分离xls and txt*/
set fileindex;
if filetype='XLS' then output fileindex_xls;
if filetype='TXT' then output fileindex_txt;;
run;

/*生成xls类宏变量*/
data _null_;/*xls*/
set fileindex_xls end=last;
if last then m=_n_;
call symput('xls_last',compress('xls'||m));call symput('ul_xls',m);
run; %put &ul_xls;
proc sql noprint;select x into :xls1-:&xls_last
from fileindex_xls;
quit;%put &xls1;%put &xls11;

/*生成txt类宏变量*/
data _null_;
set fileindex_txt end=last;
if last then m=_n_;
call symput('txt_last',compress('txt'||m));call symput('ul_txt',m);
run; %put &ul_txt;
proc sql noprint;select x into :txt1-:&txt_last 
from fileindex_txt;quit;

/*Normal_xls导入*/
%include &PATH_EXCEL.;
%include &PATH_EXCEL_TRAN.;
%macro cir;
%do i=1 %to &ul_xls;
%im_xls_pack(&&xls&i);
%end;
%mend;
%cir;
/*修改变量名称的程序引用本程序*/
/*修改数据格式——数值型变量*/

/*Normal_txt导入*/
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


/*Feedback生成路径宏变量*/
ODS TRACE OFF; options noxwait mlogic=off mprint=off;
x dir &root_er /s/b >&path_er.file11.txt;

data er_fileindex;/*导入外部文件of文件完整路径,生成机构和上传日期*//*call scan()生成position length,用于substrn*/
infile "&path_er.file11.txt" dsd truncover lrecl=32767;
input x $2000.;
call scan(x,5,position1,length1,"\");
call scan(x,6,position2,length2,"\");
uploaddate=substrn(x,position1,length1);
sorgcode=substrn(x,position2,length2);
drop position1 length1 position2 length2;
run;

/*data er_fileindex_sub;set er_fileindex;/*筛选机构和年月*/
/*if substr(uploaddate,1,4)=&check_yy and substr(uploaddate,6,2)=&check_mon; */
/*where sorgcode in (&org_select);*/
/*run;*/

data er_fileindex_xls er_fileindex_txt;/*分离xls and txt*/
set er_fileindex;
if substr(x,length(x)-2,3)='xls' then output er_fileindex_xls;
if substr(x,length(x)-2,3)='txt' then output er_fileindex_txt;;
run;

/*生成ER_xls类宏变量*//*nobs=m 系统变量nobs观测数*/
data _null_;/*xls*/
set er_fileindex_xls end=last;
if last then m=_n_;
call symput('exls_last',compress('exls'||m));call symput('eul_xls',m);
run; %put &eul_xls;
proc sql noprint;select x into :exls1-:&exls_last
from er_fileindex_xls;
quit;%put &xls1;%put &xls11;

/*生成ER_txt类宏变量*/
data _null_;
set er_fileindex_txt end=last;
if last then m=_n_;
call symput('etxt_last',compress('etxt'||m));call symput('eul_txt',m);
run; %put &eul_txt;
proc sql noprint;select x into :etxt1-:&etxt_last 
from er_fileindex_txt;quit;

/*Error_xls导入*/
%include &PATH_EXCELER.;

%macro cir;
%do i=1 %to &eul_xls;
%fbim(&&exls&i,错误信息,er_xls&i);
%end;
%mend;

%cir;


/*Error_txt导入*/
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


/*只要把结果合并就可以了，进一步可以把数据集合并*/
/*仅挑选几个变量作为统计用
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
if sorgcode='征信数据03_1.x' then sorgcode='Q10155800H3200';
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
