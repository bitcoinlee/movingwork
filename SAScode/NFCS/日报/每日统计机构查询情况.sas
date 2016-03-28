options compress=yes mprint mlogic noxwait noxsync;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/**/
/*%let month= %sysfunc(month(%sysfunc(today())));*/
/*%let year= %sysfunc(year(%sysfunc(today())));*/
/*运行前需要维护日期*/
%LET END = MDY(01,26,2016) ;
%put &end.;
%let d=%sysfunc(&end.,yymmddn8.);
/*直接调用底层FORMAT 修改人：李楠 2015-04-14 已验证*/
%INCLUDE "E:\林佳宁\000_FORMAT.sas";
%FORMAT;

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set mylib.sino_org(keep=STOPORGCODE SORGCODE SORGname);
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as upcode label="顶级机构代码"
		,T2.sorgname as upfullname label="顶级机构名称"
		,T1.SORGCODE as downcode label="子机构代码"
		,T1.sorgname as downname label="子机构名称"
		from sino_org2 as T1 left join mylib.sino_org as T2
		on T1.STOPORGCODE=T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)="Q";
quit;


DATA CX1;
/*length SHORT_NM $5.;*/
	SET mylib.sino_credit_record(DROP= IID IUSERID SNAME SCERTTYPE SCERTNO SORGNAME SDEPNAME SUSERNAME SFILEPATH SSERIALNUMBER DREQUESTTIME SCERTTYPENAME WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001') AND DATEPART(dcreatetime) <= &END.));
	SHORT_NM=PUT(SORGCODE,$SHORT_CD.);
	if substr(SHORT_NM,1,1) = "Q" then SHORT_NM = "未命名机构";

RUN;

/* 查询量*/
PROC SQL;
	CREATE TABLE CX AS SELECT
		SHORT_NM LABEL="报数机构"
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as HISCX LABEL="历史查询量"
		,sum(case when DATEPART(dcreatetime) = &END. then 1 else 0 end) as DAYCX LABEL="当日查询量"
  		From CX1
 		Group By SHORT_NM;
QUIT;

/* 查得量*/

PROC SQL;
	CREATE TABLE CD AS SELECT
		SHORT_NM LABEL="报数机构"
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  HISCD LABEL="历史查得量"
		,sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end) as  DAYCD LABEL="当日查得量"
  		From CX1(WHERE=(IREQUESTTYPE IN (0,1,2,6)))
 		Group By SHORT_NM;
QUIT;


/*汇总*/

PROC SQL;
	CREATE TABLE CXSIGN1 AS SELECT
		A.SHORT_NM
		,A.HISCX
		,COALESCE(B.HISCD,0) AS HISCD LABEL="历史查得量"
		,A.DAYCX
		,COALESCE(B.DAYCD,0) AS DAYCD LABEL="当日查得量"
	FROM CX AS A
	LEFT JOIN CD AS B
	ON A.SHORT_NM=B.SHORT_NM
	ORDER BY  HISCX DESC,HISCD DESC;
	
	CREATE TABLE CXSIGN AS SELECT
		MONOTONIC() AS ORDER1 LABEL="序号"
		,*
	FROM CXSIGN1;
QUIT;

/*各地区查询量 源数据:CX1 CD1 口径：按机构代码 2015-04-16 李楠 已验证*/
PROC SQL;
	CREATE TABLE CX_PROV AS SELECT
		put(sorgcode,$ORGAREA_CD.) as PROVINCE LABEL="省市"
		,sum(case when DATEPART(dcreatetime) <= &END. then 1 else 0 end) as HISCX LABEL="历史查询量"
		,sum(case when DATEPART(dcreatetime) = &END. then 1 else 0 end) as DAYCX LABEL="当日查询量"
  		From CX1
 		Group By calculated PROVINCE;
QUIT;

/*proc sql noprint;*/
/*	select sum(HISCX) into :HISCXSUM*/
/*	from CX*/
/*;*/
/*quit;*/
/*%put &HISCXSUM.;*/
/*data CX_PROV_1;*/
/*format HISCXRANK percent8.2;*/
/*informat HISCXRANK percent8.2;*/
/*set CX_PROV;*/
/*	HISCXRANK = round(HISCX/&HISCXSUM.,2);*/
/*	label*/
/*	HISCXRANK = 历史查询量占比*/
/*	;*/
/*run;*/
/*data CX_PROV;*/
/*	retain PROVINCE HISCX HISCXRANK*/
/*	set CX_PROV;*/
/*run;*/


PROC SQL;
	CREATE TABLE CD_PROV AS SELECT
		put(sorgcode,$ORGAREA_CD.) as PROVINCE LABEL="省市"
		,sum(case when DATEPART(dcreatetime) <=&END. then 1 else 0 end) as  HISCD LABEL="历史查得量"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCD LABEL="当日查得量"
  		From CX1(WHERE=(IREQUESTTYPE IN (0,1,2,6)))
 		Group By calculated PROVINCE
;
QUIT;
PROC SQL;
	CREATE TABLE CXCD_PROV AS SELECT
		A.PROVINCE
		,A.HISCX
		,COALESCE(B.HISCD,0) AS HISCD LABEL="历史查得量"
		,A.DAYCX
		,COALESCE(B.DAYCD,0) AS DAYCD LABEL="当日查得量"
	FROM CX_PROV AS A
	LEFT JOIN CD_PROV AS B
	ON A.PROVINCE = B.PROVINCE
	ORDER BY HISCX DESC,HISCD DESC;
DATA CXCD_PROV;
retain index;
	set CXCD_PROV;
	length index 3.;
	index=_n_;
	label
	index=序号
	;
run;


/*查询原因统计*/
PROC SQL;
	CREATE TABLE REASON AS SELECT
		SHORT_NM LABEL="报数机构"
		,SREASON LABEL="当日查询原因"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCX LABEL="当日查询量"
		,SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end) as  DAYCD LABEL="当日查得量"
		,PUT(SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end),PERCENT8.2) AS CD_RATIO LABEL="当日查得率" 
  	From CX1(WHERE=(DATEPART(dcreatetime) =&END.))
 	Group By SHORT_NM,SREASON
	ORDER BY DAYCX DESC,DAYCD DESC;
QUIT;



PROC SQL;
	CREATE TABLE REASON_T AS SELECT
		SREASON LABEL="查询原因"
		,sum(case when DATEPART(dcreatetime)  <=&END. then 1 else 0 end) as  HISCX LABEL="历史查询量"
		,SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end) as  HISCD LABEL="历史查得量"
		,PUT(SUM(CASE WHEN IPERSONID^=0 THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime)  <=&END. then 1 else 0 end),PERCENT8.2) AS HIS_CD_RATIO LABEL="历史查得率"
		,sum(case when DATEPART(dcreatetime)  =&END. then 1 else 0 end) as  DAYCX LABEL="当日查询量"
		,SUM(CASE WHEN IPERSONID^=0 AND DATEPART(dcreatetime)  =&END. THEN 1 else 0 end) as  DAYCD LABEL="当日查得量"
		,PUT(SUM(CASE WHEN IPERSONID^=0 AND DATEPART(dcreatetime) =&END. THEN 1 else 0 end)/sum(case when DATEPART(dcreatetime) =&END. then 1 else 0 end),PERCENT8.2) AS DAY_CD_RATIO LABEL="当日查得率"  
  	From CX1(WHERE=(DATEPART(dcreatetime) <= &END.))
 	Group By SREASON
	ORDER BY HISCX DESC,HISCD DESC;
QUIT;



/*新增入库情况统计 2015-04-13 李楠 已验证*/

PROC SQL;
	CREATE TABLE LOAN_TODAY AS SELECT
		DISTINCT B.sorgname as sorgname label="新增贷款业务入库机构"
			from mylib.sino_loan(where=(DATEPART(DGETDATE) = &END.)) as A
		left join mylib.sino_org as B
		on A.SORGCODE = B.SORGCODE
		where A.sorgcode not in (select distinct sorgcode from mylib.sino_loan where DATEPART(DGETDATE) < &end.)
;
quit;
/*%put &end.;*/
/*data _null_;*/
/*%let dsid=%sysfunc(open(LOAN_TODAY));*/
/*%let anobs=%sysfunc(attrn(&DSID,ANOBS));*/
/*%let rc=%sysfunc(close(&dsid));*/
/*if &anobs. > 0 then do*/
/*run;*/

/*导入数据至模板 2015-07-15 林佳宁*/
x 'E:\林佳宁\每日机构查询统计结果\NFCS查询情况统计模板.xls';
filename ex dde 'excel|E:\林佳宁\每日机构查询统计结果\[NFCS查询情况统计模板.xls]查询使用情况统计表!r3c1:r200c10';
data _null_;
 set cxsign;
 file ex;
 put order1 short_nm hiscx hiscd daycx daycd;
run;
filename ex dde 'excel|E:\林佳宁\每日机构查询统计结果\[NFCS查询情况统计模板.xls]各省市查询情况统计表!r3c1:r200c10';
data _null_;
 set cxcd_prov;
 file ex;
 put index province hiscx hiscd daycx daycd;
run;
filename ex dde 'excel|E:\林佳宁\每日机构查询统计结果\[NFCS查询情况统计模板.xls]机构当日查询原因统计表!r3c1:r200c10';
data _null_;
 set reason;
 file ex;
 put short_nm sreason daycx daycd cd_ratio;
run;
filename ex dde 'excel|E:\林佳宁\每日机构查询统计结果\[NFCS查询情况统计模板.xls]查询原因历史统计表!r3c1:r200c10';
data _null_;
 set reason_t;
 file ex;
 put sreason hiscx hiscd his_cd_ratio daycx daycd day_cd_ratio;
run;
filename ex dde 'excel|E:\林佳宁\每日机构查询统计结果\[NFCS查询情况统计模板.xls]新增贷款业务入库机构!r2c1:r200c10';
data _null_;
 set loan_today;
 file ex;
 put sorgname;
run;
filename ex dde 'excel|system';
data _null_;
 file ex;
 put '[run("macro")]';
 put "[save.as(""E:\林佳宁\每日机构查询统计结果\NFCS查询情况统计\NFCS查询情况统计_&d..xls"")]";
 put '[quit]';
run;
