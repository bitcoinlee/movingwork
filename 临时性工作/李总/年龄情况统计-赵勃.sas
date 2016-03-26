PROC SQL;
	CREATE TABLE nfcs_age AS SELECT
		 A.spin
		 ,DATEPART(A.dbirthday) AS BIRTH FORMAT=YYMMDD10. INFORMAT=YYMMDD10. label = "生日_报送"
		 ,(CASE WHEN LENGTH(SCERTNO)=18 THEN MDY(input(SUBSTR(SCERTNO,11,2),2.),input(SUBSTR(SCERTNO,13,2),2.),input(SUBSTR(SCERTNO,7,4),4.)) ELSE calculated BIRTH END) AS BIRTH_DT FORMAT=YYMMDD10. INFORMAT=YYMMDD10. label = "生日_证件号码"
	FROM nfcs.sino_person AS A
	LEFT JOIN nfcs.sino_person_certification AS B 
	ON A.spin=B.spin
	order by calculated BIRTH
;
QUIT;
data nfcs_age;
	set nfcs_age;
	if BIRTH = . or BIRTH > mdy(1,1,2010) or BIRTH < MDY(1,1,1920) then BIRTH = BIRTH_DT;
	age = intck('year',BIRTH,today());
run;
proc sort data = nfcs_age;
by age;
run;
proc sql;
	create table age_sort as select
		intck('year',BIRTH_DT,today()) as age label = "年龄"
		,count(*) label = "人数"
		from nfcs_age
	group by calculated age
;
quit;

libname xls excel "E:\新建文件夹\SAS\常用代码\自动化\结果文件夹\临时性工作\李总\年龄抽样.xlsx";
data xls.sheet1(dblabel = yes);
	set age_sort;
run;
libname xls clear;
