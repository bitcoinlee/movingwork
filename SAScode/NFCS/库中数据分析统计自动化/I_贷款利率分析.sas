%include "E:\新建文件夹\SAS\基础宏.sas";
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%format;
data _null_;
ismonth=month(today());
if 1<ismonth<10 then 
call symput('chkmonth',cat(put(year(today()),$4.),"0",put(month(today()),$1.)));
else if ismonth=1 then
call symput('chkmonth',cat(put(year(today())-1,$4.),put(12,$2.)));
else call symput('chkmonth',cat(put(year(today()),$4.),put(month(today()),$2.)));
run;
%chkfile("E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\库中数据分析统计结果\&chkmonth.");
options compress=yes mprint mlogic noxwait;
/*libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;*/
libname nfcs 'D:\数据\&chkmonth.';
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
	MONTHDURATION = 贷款时长(月)
	interest_year_single = 年化收益率(百分比)
	CREDITLIMIT = 贷款金额划分
	;
run;

/*ods html close;*/
ods graphics on/reset
imagefmt=png
imagemap=on
imagename="贷款时长-利息散点图";
/*ods html file="Boxplot-Body.html" */
ODS LISTING GPATH="E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\库中数据分析统计结果\&chkmonth." style = default image_dpi=300;
/*ods select fit;*/
/*机构（颜色）-贷款时长-利率 图*/
Proc sgplot data=loan_int_1(where = (0.12<=interest_year_single<=0.3));
title "贷款时长-利息散点图";
scatter x= MONTHDURATION y= interest_year_single/ group = CREDITLIMIT;
/*plot _col1*_col0=group /haxis=axis1 vaxis=axis2;*/
label CREDITLIMIT="贷款金额划分";
yaxis min=0 max=0.4 ;
run;
ods graphics off;
ods html close;


/*X:贷款开立时间-Y:利率-贷款基准利率 图*/

/*贷款金额-利率 图*/

/*利率分段-逾期率 表*/

/*加权盈利情况 = 各机构利率收入-坏账-资金成本*/
