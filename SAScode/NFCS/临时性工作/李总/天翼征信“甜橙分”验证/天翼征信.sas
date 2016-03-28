options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*根据当前日期，自动生成STAT_OP END START 已验证 2015.03.02 更新人：李楠 可先在日志中观察结果后再使用*/
%INCLUDE "E:\新建文件夹\SAS\常用代码\自动化\000_FORMAT.sas";
%include "E:\新建文件夹\SAS\基础宏.sas";
%format;

PROC SORT DATA=mylib.SINO_LOAN(KEEP= iloanid spin sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))  OUT=sino_loan nodupkey;
	BY iloanid;
RUN;
proc sort data = mylib.sino_person(keep = spin sorgcode SMOBILETEL WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_person nodupkey;
	by spin;
run;

/**/
proc sql;
	create table tianyi_test as select
		sname label = '姓名'
		,(case when scerttype = '0' then '身份证' else '其他证件' end) as scerttype label = '证件类型'
		,scertno label = '证件号码'
		,(case when T1.SMOBILETEL = '' then '无手机号码' when substr(T1.SMOBILETEL,1,3) in ('133','153','170','180','181','189')
		then '电信号码' else '其他运营商' end) as mobile_type label = '号码类型'
		from sino_person as T1
		left join mylib.sino_person_certification as T2
		on T1.spin = T2.spin
		order by (case when mobile_type = '电信号码' then 1 else 2 end)
	;
quit;



/**/
proc sql;
	create table tianyi as select
		T1.spin
		,SMOBILETEL
		,T2.spin as spin_T2
/*		,(case when T1.SMOBILETEL = '' then '无手机号码' when substr(T1.SMOBILETEL,1,3) in ('133','153','170','180','181','189')*/
/*		then '电信号码' else '其他运营商' end) as mobile_type label = '号码类型'*/
/*		,(case when T2.spin = '' then '未开立业务' else '已开立业务' end) as exist_loan label = '是否存在业务'*/
		from sino_person as T1
		left join sino_loan as T2
		on T1.spin = T2.spin
	;
quit;

data tianyi;
	set tianyi;
	if spin = lag(spin) then delete;
run;

data tianyi_new;
	set tianyi;
	if SMOBILETEL = '' then mobile_type = '未报送手机号码';
	else if substr(SMOBILETEL,1,3) in ('133','153','170','180','181','189') then mobile_type = '电信号码';
	else mobile_type = '其他运营商';
	if spin_T2 = '' then exist_loan = '未开立业务';
	else exist_loan = '已开立业务';
run;

proc sql;
	create table _tianyi as select
		mobile_type
		,exist_loan
		,count(*) as count
		from tianyi_new
		group by exist_loan,mobile_type
	;
quit;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\天翼征信.xlsx";
	data xls.sheet1;
		set _tianyi;
	run;
libname xls clear;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\天翼征信测试数据.xlsx";
	data xls.sheet1(dblabel=yes);
		set Tianyi_test;
		if _n_ <= 500000;
	run;
libname xls clear;

