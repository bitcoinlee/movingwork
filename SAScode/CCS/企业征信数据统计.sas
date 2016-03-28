option compress=yes mprint mlogic noxwait;
libname ccs oracle user=datauser password=r9ck01qi path=ccs;
/******************************************************************************************************************************************/
/*date=today*/
/*%let today=mdy(11,1,2015);*/
/******************************************************************************************************************************************/
%let today=%sysfunc(today());
%let path=E:\�ּ���\�±�\��ҵ��ͳ��;
%let month=%sysfunc(month(%sysfunc(today())));
%let d=%sysfunc(today(),yymmddn8.);
%let mon_now=intnx('month',&today.,0,'b');
%let mon_last=intnx('month',&today.,-1,'b');
%let mon_year=intnx('year',&today.,0,'b');

/******************************************************************************************************************************************/
/*��Ϣ�ɼ���*/
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
/*������*/
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
/*��С��ҵ*/
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
/*��ҵ��*/
/******************************************************************************************************************************************/
proc means data=guimo sum noprint;
 class enterprisescale;
 var pmonth pyear all;
 output out= guimosumall(keep=enterprisescale pmonth pyear all where=(enterprisescale eq ''))
        sum(pmonth pyear all)=pmonth pyear all;
run;

/******************************************************************************************************************************************/
/*��ũ*/
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
 table='��ҵ���Ż�����Ϣ�ɼ������';
 set ccsinfosum(drop=financecode);
run;
data result_org;
 table='��ҵ���Ż�����Ϣ�ṩ��ͳ�Ʊ�';
 set ccsorgsum(drop=financecode);
 all=all-2;
run;
data result_mment;
 table='��С΢��ҵ��';
 set guimosum(drop=enterprisescale);
run;
data result_enter;
 length table $30.;
 label table='����' pmonth="&month.������" pyear='�����ۼ�' all='���ۼ�';
 table='��¼��ҵ��';
 set guimosumall(drop=enterprisescale);
run;
data result_farm;
 table='��ũ��ҵ��';
 set farmsum(drop=industrycode);
run;
data resultall;
 set result_enter result_info result_org result_mment result_farm;
run;
libname myxls excel "&path.\��ҵ����_&d..xlsx";
data myxls.resultall(dblabel=YES);
 set resultall;
run;
libname myxls clear;


