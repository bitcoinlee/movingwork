

/*原始报文导入程序                第四版              2015.03.16           by  *李楠/

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
%include "E:\新建文件夹\SAS\基础宏.sas";

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

%LET PATH=E:\新建文件夹\SAS\质量控制自动化\质量控制自动化20150316;
%LET OUT_DATA=E:\新建文件夹\&chkmonth.\NFCS;
%LET PATH_TXT="&PATH.\T01_TXT导入程序.sas";
%LET PATH_TXTER="&PATH.\T02_TXT反馈导入程序.sas";
%LET PATH_EXCEL="&PATH.\E01_EXCEL导入程序.sas";
%LET PATH_EXCELER="&PATH.\E02_EXCEL反馈导入程序.sas";
%LET PATH_EXCEL_TRAN="&PATH.\E03_EXCEL格式转换.sas";
%let root1=E:\NFCS\报文及反馈\&chkmonth.\data\;
%let root_er=E:\NFCS\报文及反馈\&chkmonth.\feedback\;
%let path_1=E:\NFCS\报文及反馈\&chkmonth.\;
%let path_er=E:\NFCS\报文及反馈\&chkmonth.\;
/*将数据集导出至备份文件夹*/
%macro outcopy(NAME,dest);
%chkfile("&OUT_DATA.\&dest.");
LIBNAME COPYDATA "&OUT_DATA.\&dest.";
	DATA COPYDATA.&NAME.;
		SET &NAME.;
	RUN;
libname COPYDATA clear;
%mend;
/*导入xls报文及反馈数据结构，降低出错率*/
%macro xlsstruct(setname,folder);
%chkfile("E:\新建文件夹\&chkmonth.\NFCS\&folder.");
libname xls_s "E:\新建文件夹\&chkmonth.\NFCS\&folder.";
	data &setname.;
		set xls_s.&setname.;
	if _n_^=0 then delete;
	run;
libname xls_s clear;
%mend;



%GetFileAndSubDirInfoInDir(E:\新建文件夹\&chkmonth.\NFCS报送问题\旺金金融,TXT,fileindex_txt, ,yes);
%GetFileAndSubDirInfoInDir(E:\新建文件夹\&chkmonth.\NFCS报送问题\旺金金融,XLS,fileindex_xls, ,yes);
%GetFileAndSubDirInfoInDir(E:\新建文件夹\&chkmonth.\NFCS报送问题\旺金金融,TXT,er_fileindex_txt, ,yes);
%GetFileAndSubDirInfoInDir(E:\新建文件夹\&chkmonth.\NFCS报送问题\旺金金融,XLS,er_fileindex_xls, ,yes);



/*XLS TXT正常报文导入*/
ods listing close;
ods results off;
ODS TRACE OFF;
/*options noxwait mlogic=off mprint=off;*/

/*不再使用x命令写入文本文件的方式来建立文件列表*/
/*x dir &root1 /s/b >&path_1.file11.txt;*/
/*data fileindex;/*导入外部文件of文件完整路径,生成机构和上传日期*/*/
/*infile "&path_1.file11.txt" dsd truncover lrecl=32767;*/
/*input x $2000.;*/
/*call scan(x,5,position1,length1,"\");*/
/*call scan(x,6,position2,length2,"\");*/
/*call scan(x,8,position3,length3,"\");*/
/*IF LENGTH(x)>82;*/
/*/*call scan()生成position length,用于substrn*/*/
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
/*/*分离xls and txt*/*/
/*set fileindex;*/
/*if filetype='XLS' then output fileindex_xls;*/
/*if filetype='TXT' then output fileindex_txt;*/
/*run;*/
;

/*生成xls类宏变量*/
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

/*生成txt类宏变量*/
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

/*导入xls数据结构*/
%xlsstruct(t_a,bw_xls);
%xlsstruct(t_pb,bw_xls);
%xlsstruct(t_pc,bw_xls);
%xlsstruct(t_pd,bw_xls);
%xlsstruct(t_s,bw_xls);
%xlsstruct(t_g,bw_xls);
%xlsstruct(t_e,bw_xls);
%xlsstruct(t_h,bw_xls);
%xlsstruct(t_t,bw_xls);

/*导入er_xls数据结构*/
%xlsstruct(er_xls,er_xls);

/*libname er_xls_s "E:\新建文件夹\201502\NFCS\er_xls";*/
/*data er_xls;*/
/*	set er_xls_s.er_xls;*/
/*	if _n_^=0 then delete;*/
/*run;*/
/*libname er_xls_s clear;*/
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
%do j=1 %to &ul_txt.;
%PQ_input(Pq_&j,&&txt&j);
%SQ_input(Sq_&j,&&txt&j);
%AQ_input(Aq_&j,&&txt&j);
%HQ_input(Hq_&j,&&txt&j);
%EQ_input(Eq_&j,&&txt&j);
%TQ_input(Tq_&j,&&txt&j);
%GQ_input(Gq_&j,&&txt&j);
/*&&txt&j为两重引用，因此要打两次&号表示*/
%end;
%mend;
%file_out;


/*LIBNAME COPYDATA "&OUT_DATA.";*/
/*%macro outcopy(NAME);*/
/*	DATA COPYDATA.&NAME.;*/
/*		SET &NAME.;*/
/*	RUN;*/
/*%mend;*/

/*报文导出*/



/*Feedback生成路径宏变量*/
/*ODS TRACE OFF; options noxwait mlogic=off mprint=off;*/
/*x dir &root_er /s/b >&path_er.file12.txt;*/

/*data er_fileindex;*/
/*/*导入外部文件of文件完整路径,生成机构和上传日期*//*call scan()生成position length,用于substrn*/*/
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
/*set er_fileindex;筛选机构和年月*/
/*/*if substr(uploaddate,1,4)=&check_yy and substr(uploaddate,6,2)=&check_mon; */*/
/*/*where sorgcode in (&org_select);*/*/
/*/*run;*/*/
/**/
/*data er_fileindex_xls er_fileindex_txt;/*分离xls and txt*/*/
set er_fileindex;
/*if substr(x,length(x)-2,3)='xls' then output er_fileindex_xls;*/
/*if substr(x,length(x)-2,3)='txt' then output er_fileindex_txt;;*/
/*run;*/

/*生成ER_xls类宏变量*//*nobs=m 系统变量nobs观测数*/
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

/*Error_xls导入*/
%include &PATH_EXCELER.;
%macro cir;
%do i=1 %to &eul_xls;
%fbim(&&exls&i,错误信息,er_xls&i);
%end;
%mend;

%cir;

%OUTCOPY(ER_xls);

/*生成ER_txt类宏变量*/
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
/*txt报文导出*/
%OUTCOPY(PQ,bw_txt);
%OUTCOPY(SQ,bw_txt);
%OUTCOPY(AQ,bw_txt);
%OUTCOPY(HQ,bw_txt);
%OUTCOPY(EQ,bw_txt);
%OUTCOPY(TQ,bw_txt);
%OUTCOPY(GQ,bw_txt);
/*xls报文导出*/
%OUTCOPY(T_a,bw_xls);
%OUTCOPY(T_pb,bw_xls);
%OUTCOPY(T_pc,bw_xls);
%OUTCOPY(T_pd,bw_xls);
%OUTCOPY(T_s,bw_xls);
%OUTCOPY(T_g,bw_xls);
%OUTCOPY(T_e,bw_xls);
%OUTCOPY(T_h,bw_xls);
%OUTCOPY(T_t,bw_xls);
/*xls反馈导出*/
%OUTCOPY(Er_T_a,er_xls);
%OUTCOPY(Er_T_pb,er_xls);
%OUTCOPY(Er_T_pc,er_xls);
%OUTCOPY(Er_T_pd,er_xls);
%OUTCOPY(Er_T_s,er_xls);
%OUTCOPY(Er_T_g,er_xls);
%OUTCOPY(Er_T_e,er_xls);
%OUTCOPY(Er_T_h,er_xls);
%OUTCOPY(Er_T_t,er_xls);
/*TXT反馈导出*/
%OUTCOPY(ER_PQ,er_txt);
%OUTCOPY(ER_SQ,er_txt);
%OUTCOPY(ER_AQ,er_txt);
%OUTCOPY(ER_HQ,er_txt);
%OUTCOPY(ER_EQ,er_txt);
%OUTCOPY(ER_TQ,er_txt);
%OUTCOPY(ER_GQ,er_txt);
ods listing;
ods results on;


/*改名字 补标签*/
/*data t_pb;*/
/*	set t_pb;*/
/*	label col9=住宅电话*/
/*		  col10=手机号码*/
/*		  col11=单位电话*/
/*		  col12=电子邮箱*/
/*		  col13=通讯地址*/
/*		  col14=通讯地址邮政编码*/
/*		  col15=户籍地址*/
/*		  col16=配偶姓名*/
/*		  col17=配偶证件类型*/
/*		  col18=配偶证件号码*/
/*		  col19=配偶工作单位*/
/*		  col20=配偶联系电话*/
/*		  col21=第一联系人姓名*/
/*		  col22=第一联系人关系*/
/*		  col23=第一联系人电话*/
/*		  col24=第二联系人姓名*/
/*		  col25=第二联系人关系*/
/*		  col26=第二联系人电话;*/
/*run;*/
/**/
/*data t_pc;*/
/*	set t_pc;*/
/*	label */
/*			col1=姓名*/
/*			col2=证件类型*/
/*			col3=证件号码*/
/*			col4=职业*/
/*			col5=单位名称*/
/*			col6=单位所属行业*/
/*			col7=单位地址*/
/*			col8=单位地址邮政编码*/
/*			col9=本单位工作起始年份*/
/*			col10=职务*/
/*			col11=职称*/
/*			col12=年收入;*/
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
/*	label   col0=姓名*/
/*			col1=证件类型*/
/*			col2=证件号码*/
/*			col3=居住地址*/
/*			col4=居住地址邮政编码*/
/*			col5=居住状况;*/
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
