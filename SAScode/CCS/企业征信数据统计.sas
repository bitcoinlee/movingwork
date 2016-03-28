option compress=yes mprint mlogic noxwait;
libname ccs oracle user=datauser password=r9ck01qi path=ccs;
/******************************************************************************************************************************************/
/*date=today*/
/*%let today=mdy(11,1,2015);*/
/******************************************************************************************************************************************/
%let today=%sysfunc(today());
%let path=E:\林佳宁\月报\企业数统计;
%let month=%sysfunc(month(%sysfunc(today())));
%let d=%sysfunc(today(),yymmddn8.);
%let mon_now=intnx('month',&today.,0,'b');
%let mon_last=intnx('month',&today.,-1,'b');
%let mon_year=intnx('year',&today.,0,'b');

/******************************************************************************************************************************************/
/*信息采集量*/
/******************************************************************************************************************************************/
data ccsinfo;
 set ccs.eb_financinglease(where=(datepart(dgetdate) lt &mon_now.));
 pmonth=0;
 pyear=0;
 all=1;
 if datepart(dgetdate) ge &mon_last. then pmonth=1;
 if datepart(dgetdate) ge &mon_year. then pyear=1;
run;
proc means data=ccsinfo sum noprint;
 class financecode;
 var pmonth pyear all;
 output out= ccsinfosum(keep=financecode pmonth pyear all where=(financecode eq '')) sum(pmonth pyear all)=pmonth pyear all;
run;

/******************************************************************************************************************************************/
/*机构数*/
/******************************************************************************************************************************************/
proc sort data=ccsinfo;
 by financecode dgetdate;
run;
data ccsorg;
 set ccsinfo;
 by financecode dgetdate;
 if first.financecode;
run;
proc means data=ccsorg(keep=financecode pmonth pyear all) sum noprint;
 class financecode;
 var pmonth pyear all;
 output out=ccsorgsum(keep=financecode pmonth pyear all where=(financecode eq '')) sum(pmonth pyear all)=pmonth pyear all;
run;

/******************************************************************************************************************************************/
/*中小企业*/
/******************************************************************************************************************************************/
data guimo;
 set ccs.BB_ORGANSTATUS(where=(datepart(dgetdate) lt &mon_now.));
 pmonth=0;
 pyear=0;
 all=1;
 if datepart(dgetdate) ge &mon_last. then pmonth=1;
 if datepart(dgetdate) ge &mon_year. then pyear=1;
run;
proc sort data=guimo;
 by dgetdate;
run;
proc means data=guimo(where=(enterprisescale in ('3' '4'))) sum noprint;
 class ENTERPRISESCALE;
 var pmonth pyear all;
 output out= guimosum(keep=enterprisescale pmonth pyear all where=(enterprisescale eq ''))
        sum(pmonth pyear all)=pmonth pyear all;
run;

/******************************************************************************************************************************************/
/*企业数*/
/******************************************************************************************************************************************/
proc means data=guimo sum noprint;
 class enterprisescale;
 var pmonth pyear all;
 output out= guimosumall(keep=enterprisescale pmonth pyear all where=(enterprisescale eq ''))
        sum(pmonth pyear all)=pmonth pyear all;
run;

/******************************************************************************************************************************************/
/*涉农*/
/******************************************************************************************************************************************/
data farm;
 set ccs.bb_borrower(where=(datepart(dgetdate) lt &mon_now.));
 pmonth=0;
 pyear=0;
 all=1;
 if datepart(dgetdate) ge &mon_last. then pmonth=1;
 if datepart(dgetdate) ge &mon_year. then pyear=1;
run;
proc means data=farm(where=(substr(industrycode,1,1) eq 'a')) sum noprint;
 class INDUSTRYCODE;
 var pmonth pyear all;
 output out= farmsum(keep=industrycode pmonth pyear all where=(industrycode eq ''))
        sum(pmonth pyear all)=pmonth pyear all;
run;
data result_info;
 table='企业征信机构信息采集情况表';
 set ccsinfosum(drop=financecode);
run;
data result_org;
 table='企业征信机构信息提供者统计表';
 set ccsorgsum(drop=financecode);
 all=all-2;
run;
data result_mment;
 table='中小微企业数';
 set guimosum(drop=enterprisescale);
run;
data result_enter;
 length table $30.;
 label table='表名' pmonth="&month.月增量" pyear='当年累计' all='总累计';
 table='收录企业数';
 set guimosumall(drop=enterprisescale);
run;
data result_farm;
 table='涉农企业数';
 set farmsum(drop=industrycode);
run;
data resultall;
 set result_enter result_info result_org result_mment result_farm;
run;
libname myxls excel "&path.\企业征信_&d..xlsx";
data myxls.resultall(dblabel=YES);
 set resultall;
run;
libname myxls clear;


