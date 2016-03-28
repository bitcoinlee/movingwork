proc sort data = nfcs.sino_loan( keep= sorgcode iloanid dbillingdate sloantype icreditlimit where = (SUBSTR(sorgcode,1,1)='Q' AND sorgcode not in ('Q10152900H0000','Q10152900H0001'))) out = sino_loan_temp nodup;
by sorgcode iloanid dbillingdate;
run;
data sino_loan_temp;
	set sino_loan_temp;
	if iloanid = lag(iloanid) then delete;
run;
proc sql;
	create table sino_loan_t1 as select
		sorgcode label = "机构代码"
		,count(distinct iloanid) as loan_cnt label = "贷款总笔数"
		,sum(icreditlimit) as loan_sum label = "贷款总金额"
		,sum(case when sloantype = '91' then 1 else 0 end) as xiaofei_loan_cnt label = "消费类贷款总笔数"
		,sum(case when sloantype = '91' then icreditlimit else 0 end) as xiaofei_loan_sum label = "消费类贷款总金额"
		,calculated xiaofei_loan_cnt/calculated loan_cnt as per_cnt format = percent8.2 label = "消费类贷款笔数占比"
		,calculated xiaofei_loan_sum/calculated loan_sum as per_sum format = percent8.2 label = "消费类贷款金额占比"
	from sino_loan_temp
	group by sorgcode
	order by per_cnt desc
;
quit;

proc sql;
	create table sino_loan_t2 as select
		T2.sorgname
		,T2.shortname
		,T1.*
		from sino_loan_t1 as T1
	left join _sino_org as T2
	on T1.sorgcode = T2.sorgcode
	;
quit;
data sino_loan_t2;
	set sino_loan_t2(drop = sorgcode);
	if shortname = lag(shortname) then delete;
run;
proc sort data = sino_loan_t2;
by descending per_cnt;
run;

libname xls "E:\新建文件夹\201603\报送消费类贷款（不包括汽车）机构名单.xlsx";
data xls.sheet1(dblabel = yes);
	set Sino_loan_t2(where = (shortname ^= ''));
run;
libname xls clear;
