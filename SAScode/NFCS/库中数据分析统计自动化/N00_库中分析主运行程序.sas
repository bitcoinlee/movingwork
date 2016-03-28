OPTIONS MPRINT MLOGIC NOXWAIT COMPRESS=YES;/*选项设置*/
libname sss oracle user=datauser password=zlxdh7jf path=p2p;

/*用于更新format中SMONTHDURATION*/
/*proc sql;*/
/*	create table all_SMONTHDURATION as select*/
/*		distinct SMONTHDURATION*/
/*		from nfcs.sino_loan*/
/*;*/
/*quit;*/
/*filename myfile "C:\Users\Data Analyst\Desktop\常用代码\自动化\All_smonthduration.txt";*/
/*data _null_;*/
/*set All_smonthduration;*/
/*file myfile;*/
/*put SMONTHDURATION;*/
/*run;*/

data _null_;
ismonth=month(today());
if 1 > ismonth > 10 then
call symput('STAT_OP',cat(put(year(today()),$4.),"年",put(month(intnx('month',today(),-1)),$2.),"月全量"));
else if ismonth=1 then call symput('STAT_OP',cat(put(year(today())-1,$4.),"年12月全量"));
else call symput('STAT_OP',cat(put(year(today()),$4.),"年",put(month(intnx('month',today(),-1)),$1.),"月全量"));
run;
%put &STAT_OP.;
%LET STAT_DT=intnx('month',today(),-1,'end');
%LET LAST_DT=INTNX('MONTH',&STAT_DT.,-1,'END');
/*LIBNAME SSS "D:\数据\&STAT_OP.";*/
%LET PATH=E:\新建文件夹\SAS\常用代码;
%LET PATH_000="&PATH.\自动化\000_FORMAT.sas";
/*贷款地区分析程序运行*/
%LET PATH_D01="&PATH.\自动化\库中数据分析统计自动化\D01_贷款地区分析.sas";
/*一般情况分析程序运行*/
%LET PATH_B01="&PATH.\自动化\库中数据分析统计自动化\B01_一般业务分析.sas";
/*贷款逾期分析程序运行*/
%LET PATH_O01="&PATH.\自动化\库中数据分析统计自动化\O01_贷款逾期分析.sas";
/*贷款客户分析程序运行*/
%LET PATH_C01="&PATH.\自动化\库中数据分析统计自动化\C01_贷款客户分析.sas";
/*附录分析程序运行*/
%LET PATH_F01="&PATH.\自动化\库中数据分析统计自动化\FL_附录.sas";
/*结果输出*/
%LET OUTPATH_D01="&PATH.\自动化\结果文件夹\库中数据分析统计结果\贷款地区分析&STAT_OP..XLS";
%LET OUTPATH_B01="&PATH.\自动化\结果文件夹\库中数据分析统计结果\一般业务分析&STAT_OP..XLS";
%LET OUTPATH_O01="&PATH.\自动化\结果文件夹\库中数据分析统计结果\贷款逾期分析&STAT_OP..XLS";
%LET OUTPATH_C01="&PATH.\自动化\结果文件夹\库中数据分析统计结果\贷款客户分析&STAT_OP..XLS";
%LET OUTPATH_F01="&PATH.\自动化\结果文件夹\库中数据分析统计结果\库中分析附录&STAT_OP..XLS";
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
