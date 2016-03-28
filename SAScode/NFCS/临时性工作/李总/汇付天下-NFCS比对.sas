/*libname sss "D:\数据\2015年4月全量";*/
options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;

/*上海地区机构名单*/
data sino_org;
	retain SORGCODE SORGname ;
	set mylib.sino_org(keep= SORGCODE SORGname Slevel sareacode where = (Slevel = '1' and sareacode = '310000' and sorgcode not in ('Q10152900H0000' '11111111111111' 'Q10152900H0001')));
	drop
	Slevel
	sareacode
	;
	label
	SORGCODE = 机构代码
	sorgname = 机构名称
	;
run;

/*已报数机构*/
proc sql;
	create table baosong_jiekou as select
	distinct SORGCODE
	,"已报送" as status label = "报送状态"
	from mylib.sino_msg(keep= SORGCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	;
quit;
/*报送业务机构*/
PROC SQL;
	CREATE TABLE baosong_LOAN AS SELECT
		distinct SORGCODE LABEL="机构代码"
		,"是" as status3 label = "贷款业务"
	FROM mylib.SINO_LOAN(keep=sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
;
QUIT;
/*报送特殊交易机构*/
proc sql;
	create table baosong_luru as select
		distinct sorgcode
		,"是" as status2 label = "特殊交易"
	from mylib.Sino_LOAN_SPEC_TRADE(keep= SORGCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	;
quit;

/*报送贷款业务笔数*/
proc sort data = mylib.SINO_LOAN(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_loan nodupkey;
	by sorgcode saccount;
quit;
PROC SQL;
	CREATE TABLE ruku_LOAN AS SELECT
		SORGCODE LABEL="机构代码"
		,COUNT(SACCOUNT) as rukucount label = "入库贷款记录数"
	FROM sino_loan
	GROUP BY SORGCODE
;
QUIT;

/*3.个人身份信息*/
PROC SQL;
	CREATE TABLE ruku_SF AS SELECT
		SORGCODE  LABEL="机构代码"
		,count(spin) as rukucount2 label = "入库人数（身份）"
	FROM mylib.sino_person_certification(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*汇总并输出*/
proc sql;
	create table _huifu as select
		T1.sorgcode
		,T1.sorgname
		,status
		,status2
		,status3
		,rukucount
		,rukucount2
		from sino_org as T1 left join Baosong_jiekou as T9
		on T1.sorgcode = T9.sorgcode
		left join Baosong_loan as T2
		on T1.sorgcode = T2.sorgcode
		left join Baosong_luru as T10
		on T1.sorgcode = T10.sorgcode
		left join Ruku_loan as T3
		on T1.sorgcode = T3.sorgcode
		left join Ruku_sf as T4
		on T1.sorgcode = T4.sorgcode
order by (case when status ^= '' then 1 else 2 end)
		;
quit;

libname  myxls  EXCEL "D:/汇付天下-V1.0.xls";
data myxls.sheet1(dblabel=YES);
set _huifu;
run;
libname myxls clear;
