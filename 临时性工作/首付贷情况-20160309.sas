%include "E:/新建文件夹/SAS/config.sas";
PROC SORT DATA=nfcs.sino_loan(KEEP=SORGCODE sareacode sloantype iloanid dbillingdate ibalance WHERE=(SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out = sino_loan_shoufu;
	BY iloanid descending dbillingdate;
RUN;
data sino_loan_shoufu;
	set sino_loan_shoufu;
	if intnx("month",datepart(dbillingdate),0,'b') = lag(intnx("month",datepart(dbillingdate),0,'b')) then delete;
run;

proc sql;
	create table shoufudai_org as select
		intnx("month",datepart(EXECUTE_START_DATE),0,'b') as yuefen label = "时间" format = yymmn6.
		,count(EXECUTE_START_DATE) as org_cnt
		from crm1.T_contract_order as T1
		where delete_flag = 0
		group by calculated yuefen
;
quit;
data shoufudai_org;
	set shoufudai_org;
	retain org_cnt_acc;
	org_cnt_acc = sum(org_cnt_acc,org_cnt);
/*	org_cnt_acc+org_cnt;*/
/*	format org_cnt_acc 8.;*/
run;


proc sql;
	create table shoufudai_loan as select
		intnx("month",datepart(dbillingdate),0,'b') as yuefen label = "时间" format = yymmn6.
/*		,count(distinct sorgcode) as org_cnt label = "报送业务数据的P2P平台数量"*/
		,round(sum(ibalance)/10000,1) as ibalance label = "P2P平台发放贷款余额（万元）"
		,count(iloanid) as loan_cnt label = "相应笔数"
		,round(sum(case when sloantype in ('11','12','13') then ibalance else 0 end)/10000,1) as ibalance_fang label = "其中：个人购房用途贷款余额"
		,sum(case when sloantype in ('11','12','13') then 1 else 0 end) as loan_cnt_fang label = "个人购房用途贷款相应笔数"
		,round(sum(case when sloantype in ('11','12','13') and substr(sareacode,1,4) = '4403' then ibalance else 0 end)/10000,1) as ibalance_sz label = "深圳客户个人购房用途贷款余额（万元）"
		,sum(case when sloantype in ('11','12','13') and substr(sareacode,1,4) = '4403' then 1 else 0 end) as loan_cnt_sz label = "深圳客户个人购房用途贷款笔数"
		,round(sum(case when sloantype in ('11','12','13') and substr(sareacode,1,3) = '310' then ibalance else 0 end)/10000,1) as ibalance_sh label = "上海客户个人购房用途贷款余额（万元）"
		,sum(case when sloantype in ('11','12','13') and substr(sareacode,1,3) = '310' then 1 else 0 end) as loan_cnt_sh label = "上海客户个人购房用途贷款笔数"
		,round(sum(case when sloantype in ('11','12','13') and substr(sareacode,1,3) = '110' then ibalance else 0 end)/10000,1) as ibalance_bj label = "北京客户个人购房用途贷款余额（万元）"
		,sum(case when sloantype in ('11','12','13') and substr(sareacode,1,3) = '110' then 1 else 0 end) as loan_cnt_bj label = "北京客户个人购房用途贷款笔数"
		,round(sum(case when sloantype in ('11','12','13') and substr(sareacode,1,4) = '4401' then ibalance else 0 end)/10000,1) as ibalance_gz label = "广州客户个人购房用途贷款余额（万元）"
		,sum(case when sloantype in ('11','12','13') and substr(sareacode,1,4) = '4401' then 1 else 0 end) as loan_cnt_gz label = "广州客户个人购房用途贷款笔数"
		from sino_loan_shoufu(where = (mdy(2,29,2016)>=datepart(dbillingdate)>=mdy(9,1,2015)))
		group by calculated yuefen
;
quit;

proc sql;
	create table shoufudai_org_type as select
		intnx("month",datepart(dbillingdate),0,'b') as yuefen label = "时间" format = yymmn6.
		,count(distinct sorgcode) as org_cnt_type label = "与房地产中介企业存在关联或合作关系的P2P平台数量"
		from sino_loan_shoufu(where = (mdy(2,29,2016)>=datepart(dbillingdate)>=mdy(9,1,2015)))
		where sloantype in ('11','12','13')
		group by calculated yuefen
;
quit;

proc sql;
	create table _shoufudai as select
		T1.yuefen
		,T1.org_cnt_acc label = "累计接入机构数量"
		,T2.*
		,T3.*
		from shoufudai_org as T1
		left join shoufudai_loan as T2
		ON t1.YUEFEN = T2.YUEFEN
		left join shoufudai_org_type as T3
		ON t1.YUEFEN = T3.YUEFEN
	where T2.yuefen is not null
;
QUIT;

proc sql;
	create table org_sfd as select
		T1.sorgcode
		,T1.sorgname
		,T1.shortname
		,sum(T2.ibalance) as ibalance_fang label = "其中：个人购房用途贷款余额"
		,count(T2.ibalance) as loan_cnt_fang label = "个人购房用途贷款相应笔数"
		from _sino_org as T1
		left join sino_loan_shoufu(where = (mdy(1,31,2016) >= datepart(dbillingdate) >= mdy(1,1,2016) and sorgcode in ("Q10152900H1W00" "Q10153000HW900" "Q10152900H1200"
 "Q10152900H1400" "Q10151000H3700" "Q10151000HB500" "Q10151000HC800" "Q10151000HCQ00" "Q10151000HH600" "Q10151000HHF00" "Q10152900H0900" "Q10152900H2Z00"
"Q10152900H3500" "Q10152900H5E00" "Q10152900H6500" "Q10152900HN700" "Q10152900HO800" "Q10153000HBI00" "Q10153900HJ800" "Q10155800H5400" "Q10155800HP000" "Q10155800HQ300"))) as T2
		on T1.sorgcode = T2.sorgcode
		where T2.sorgcode is not null
		group by T1.sorgcode
	;
quit;
data org_sfd;
	set org_sfd;
	if sorgcode = lag(sorgcode) then delete;
run;

libname xls excel "E:\新建文件夹\征信中心\接入业务方案\201603\调研表格-资信-标黄-更新.xlsx";
/*data xls.sheet1(dblabel = yes);*/
/*	set _shoufudai;*/
/*run;*/
data xls.sheet2(dblabel = yes);
	set org_sfd;
run;
libname xls clear;

