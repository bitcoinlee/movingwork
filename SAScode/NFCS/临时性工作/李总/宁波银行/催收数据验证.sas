options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
%include "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";
%format;
PROC IMPORT OUT= WORK.ningbo DATAFILE = "E:\新建文件夹\SAS\常用代码\自动化\临时性工作\李总\宁波银行\宁波银行-已整理.xls" DBMS=EXCEL REPLACE;
     RANGE="整理后-个人$"; 
     GETNAMES=YES;
     MIXED=YES;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

proc sort data = ningbo;
 by scertno;
run;
/*data ningbo;*/
/*	set ningbo;*/
/*	if scertno = lag(scertno) then delete;*/
/*	scerttype_temp = put(scerttype,$2.);*/
/*	drop*/
/*	scerttype*/
/*	;*/
/*	rename*/
/*	scerttype_temp = scerttype*/
/*	;*/
/*run;*/

proc sql;
	create table ningbo_mapping as select
		T1.*
		,T2.spin
		,(case when T2.spin is null then "否" else "是" end) as yesno label = "匹配结果"
		from ningbo as T1
		left join nfcs.Sino_person_certification as T2
		on strip(T1.sname) = strip(T2.sname) and strip(T1.scertno18) = strip(T2.SCERTNO)
		order by (case yesno when "是" then 1 else 2 end)
	;
quit;

/*个人基本信息部分*/
proc sort	data = nfcs.sino_person(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person;
	set ningbo_person;
	if spin = lag(spin) then delete;
run;
proc sort	data =  nfcs.sino_person_employment(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person_employment nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person_employment;
	set ningbo_person_employment;
	if spin = lag(spin) then delete;
run;
proc sort	data =  nfcs.sino_person_address(drop = iid ipersonid sorgcode smsgfilename ilineno itrust stoporgcode istate ipbcstate) out = ningbo_person_address nodupkey;
	by spin desending dgetdate;
run;
data ningbo_person_address;
	set ningbo_person_address;
	if spin = lag(spin) then delete;
run;

/*贷款申请部分*/
proc sort data = nfcs.Sino_loan_apply(keep = spin sorgcode sapplycode ddate imoney sstate) out = ningbo_apply nodup;
	by spin descending ddate;
run;
data ningbo_apply_1;
	format org_count_apply 2. apply_count 2. final_date_apply yymmddd10.;
	set ningbo_apply;
		org_count_apply = 1;
		if spin = lag(spin) and sorgcode ^= lag(sorgcode) then org_count_apply = org_count_apply + 1;
		if SSTATE = 1 then apply_count = 1;
		else apply_count = 0;
		if lag(SSTATE) = 1 and SSTATE ^= 1 and SAPPLYCODE = lag(SAPPLYCODE) then apply_count = -1;
		else apply_count = apply_count;
		final_date_apply = datepart(ddate);
	label
		org_count_apply = 累计申请机构数
		final_date_apply = 最近一次申请时间
	;
run;
data ningbo_apply_2;
	set ningbo_apply_1(keep = spin final_date_apply imoney);
		if spin = lag(spin) then delete;
	label
		imoney = 最近一次申请金额
	;
run;

/*贷款业务部分*/
proc sort DATA=nfcs.SINO_LOAN(KEEP=sorgcode sareacode ddateopened icreditlimit spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=ningbo_LOAN_BASE_1 nodup;
	BY SPIN ddateopened;
RUN;

proc sql;
	create table ningbo_loan_0 as select
		spin
		,min(datepart(DDATEOPENED)) as DDATEOPENED format = yymmddd10. label = "历史首贷日期"
		,max(icreditlimit) as icreditlimit_his label ="历史最大授信额度"
	from ningbo_loan_base_1
	group by spin
	;
quit;

PROC SORT DATA=nfcs.SINO_LOAN(KEEP=sorgcode SACCOUNT sareacode sloantype ddateopened dbillingdate icreditlimit ibalance iamountpastdue itermspastdue imaxtermspastdue ITREATYPAYAMOUNT iaccountstat spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=ningbo_LOAN_BASE;
	BY SORGCODE SACCOUNT descending dbillingdate;
RUN;

data ningbo_LOAN_BASE_2;
	format ddateopened_temp yymmddd10. dbillingdate_temp yymmddd10.;
	set ningbo_LOAN_BASE;
	ddateopened_temp = datepart(ddateopened);
	dbillingdate_temp = datepart(dbillingdate);
	if sorgcode = lag(sorgcode) and SACCOUNT = lag(SACCOUNT) and spin = lag(spin) then delete;
	drop
	ddateopened dbillingdate
	;
	rename
	ddateopened_temp = ddateopened
	dbillingdate_temp = dbillingdate
	;
run;

PROC SQL;
	CREATE TABLE ningbo_loan_1 AS SELECT
		spin
/*		,sareacode as sareacode label = "地区分布"*/
		,PUT(SUBSTR(SAREACODE,1,2),$PROV_LEVEL.) as sareacode_group label = "地区分布(按省)"
		,PUT(SLOANTYPE,$LOAN_LEVEL.) as sloantype_group label = "贷款类别"
/*		,sloantype as sloantype label = "贷款类别"*/
		,count(distinct catx(sorgcode,saccount)) as loan_count label = "贷款笔数"
		,count(distinct sorgcode) as org_count label = "贷款机构数"
/*		,sum(icreditlimit) as icreditlimit label = "贷款总额"*/
		,put(put(sum(icreditlimit),PAY_AMT_level.),$PAY_AMT_CD.) as icreditlimit_group label = "贷款总额（分段）"
		,sum(ibalance) as ibalance label = "贷款余额"
/*		,sum(IAMOUNTPASTDUE) as IAMOUNTPASTDUE label = "当前逾期总额"*/
		,put(put(sum(IAMOUNTPASTDUE),PAY_AMT_level.),$PAY_AMT_CD.) as IAMOUNTPASTDUE_group label = "当前逾期总额(分段)"
		,sum(itermspastdue) AS itermspastdue label = "累计逾期次数"
		,max(imaxtermspastdue) as imaxtermspastdue label = "最高逾期期数"
/*		,COALESCE(input(ITREATYPAYAMOUNT,best12.),0) as TREATYPAYAMOUNT label = "每期应还金额"*/
		,COALESCE(max(COALESCE(input(ITREATYPAYAMOUNT,best12.),0) * imaxtermspastdue),IAMOUNTPASTDUE) as yuqi_max label = "最高逾期金额"
	from ningbo_LOAN_BASE_2
	where iaccountstat in (1,2)
	group by spin
	having ibalance ^= 0
	;
quit;
data ningbo_loan_1;
	set ningbo_loan_1;
	if spin = lag(spin) then delete;
run;


/*担保信息*/
proc sql;
	create table ningbo_guarantee as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as danbao_count label = "对外担保笔数"
		,sum(iguaranteesum) as danbao_money label = "累计担保金额"
	from nfcs.sino_loan_guarantee
	where SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') and spin is not null
	group by spin
	;
quit;

/*特殊交易信息*/ 
proc sql;
	create table ningbo_special as select
		spin
		,count(distinct catx(sorgcode,iloanid)) as special_count label = "担保人代偿笔数"
		,sum(ioccursum) as ioccursum label = "发生金额"
	from nfcs.Sino_loan_spec_trade
	where speculiartradetype = "2"
	group by spin
;
quit;

/*黑名单*/
proc sql;
	create table ningbo_black as select
	spin
	,"是" as yesno_black label = "是否黑名单"
	from nfcs.Sino_loan_spec_trade
	where speculiartradetype in ("6","7","8","9")
;
quit;
data ningbo_black;
	set ningbo_black;
	if spin = lag(spin) then delete;
run;


proc sql;
	create table _ningbo_mapping as select
		T1.*
/*		,max(T2.org_count_apply) as org_count_apply label = "累计申请机构数"*/
/*		,sum(T2.apply_count) as apply_count label = "当前在途申请笔数"*/
		,T9.*
		,T10.*
		,T11.*
		,T2.org_count_apply label = "累计申请机构数"
		,T2.apply_count label = "当前在途申请笔数"
		,T3.final_date_apply
		,T3.imoney
		,T4.*
		,T5.*
		,T6.*
		,T7.*
		,T8.*
		from ningbo_mapping(where = (yesno = "是")) as T1
		left join (select spin,max(org_count_apply) as org_count_apply,sum(apply_count) as apply_count from ningbo_apply_1 group by spin) as T2
		on T1.spin = T2.spin
		left join ningbo_apply_2 as T3
		on T1.spin = T3.spin
		left join ningbo_loan_0 as T4
		on T1.spin = T4.spin
		left join ningbo_loan_1 as T5
		on T1.spin = T5.spin
		left join ningbo_guarantee as T6
		on T1.spin = T6.spin
		left join ningbo_special as T7
		on T1.spin = T7.spin
		left join ningbo_black as T8
		on T1.spin = T8.spin
		left join ningbo_person as T9
		on T1.spin = T9.spin
		left join ningbo_person_employment as T10
		on T1.spin = T10.spin
		left join ningbo_person_address as T11
		on T1.spin = T11.spin
/*	order by (case T1.yesno when "是" then 1 else 2 end)*/
	;
quit;

data _ningbo_mapping;
	set _ningbo_mapping;
	if spin = lag(spin) then delete;
	drop
	spin
	;
run;
data _ningbo_mapping;
	set _ningbo_mapping;
	label
 sname ='姓名'
 scerttype ='证件类型'
 scertno ='证件号码'
 ssectionid_B ='段标B'
 isex ='性别'
 dbirthday ='出生日期'
 imarriage ='婚姻状况'
 iedulevel ='最高学历'
 iedudegree ='最高学位'
 smatename ='配偶姓名'
 smatecerttype ='配偶证件类型'
 smatecertno ='配偶证件号码'
 smatecompany ='配偶工作单位'
 smatetel ='配偶联系电话'
 shometel ='住宅电话'
 smobiletel ='手机号码'
 sofficetel ='单位电话'
 Semail ='电子邮箱'
 saddress ='通讯地址'
 szip ='通讯地址邮政编码'
 sfirstcontactname ='第一联系人姓名'
 sfirstcontactrelation ='第一联系人关系'
 sfirstcontacttel ='第一联系人联系电话'
 ssecondcontactname ='第二联系人姓名'
 ssecondcontactrelation ='第二联系人关系'
 ssecondcontacttel ='第二联系人联系电话'
 sresidence ='户籍地址'
 ssectionid_C ='段标C'
 soccupation ='职业'
 Scompany ='单位名称'
 sindustry ='单位所属行业'
 scompanyaddress ='单位地址'
 scompanyzip ='单位邮政编码'
 sstartyear ='在职年限'
 iposition ='职务'
 ititle ='职称'
 iannualincome ='年收入'
 ssectionid_D ='段标D'
 saddress  ='居住地址'
 szip  ='居住地址邮政编码'
 Scondition ='居住状况';
run;


libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\宁波银行\宁波银行-已整理.xlsx";
	data xls.sheet3(dblabel=yes);
	set _ningbo_mapping;
RUN;
libname xls clear;
