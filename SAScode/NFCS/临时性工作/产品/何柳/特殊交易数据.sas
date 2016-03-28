options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
data heliu_spec;
	format yuefen yymmd7.;
	set nfcs.sino_loan_spec_trade(keep = sorgcode dgetdate spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
	by spin dgetdate;
	yuefen = intnx("month",datepart(dgetdate),0,"b");
run;
data heliu_spec;
	set heliu_spec;
	if spin = lag(spin) then delete;
run;

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set nfcs.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="机构代码"
		,T2.sorgname as sorgname label="机构名称"
/*		,T1.sareacode label="机构省市代码"*/
		from sino_org2 as T1 left join nfcs.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q";
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;

proc sql;
	create table _heliu_spec as select
	T2.sorgname label =  "机构名称"
	,yuefen	label = "报送月份"
	,count(spin) as renshu label =  "入库人数（只统计首次）"
	from heliu_spec as T1
	left join _sino_org as T2
	on T1.sorgcode = T2.sorgcode
	group by sorgname,yuefen
;
quit;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\产品\何柳\特殊交易.xlsx";
data xls.sheet1(dblabel=yes);
set _heliu_spec;
run;
libname xls clear;
