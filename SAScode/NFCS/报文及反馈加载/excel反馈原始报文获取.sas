%let reqmonth=201503;
LIBNAME BW_XLS "E:\新建文件夹\&reqmonth.\NFCS\bw_xls";
LIBNAME ER_XLS "E:\新建文件夹\&reqmonth.\NFCS\er_xls";
/*将XLS反馈与XLS报文进行匹配*/

/*作用：给每条xls报文文件赋序号，以便与反馈文件中的行号匹配*/
%MACRO ORDER_NM(TNAME);
PROC SORT DATA=&TNAME. OUT=&TNAME.;
	BY UPLOADDATE FILENAME;
DATA &TNAME._1;
	length type $12.;
	SET &TNAME.;
	BY UPLOADDATE FILENAME;
	RETAIN INDEX;
	IF FIRST.FILENAME THEN INDEX=1;
		ELSE INDEX=INDEX+1;
	if upcase(substr("&TNAME",3,1))="S" then type="贷款申请信息";
	else if upcase(substr("&TNAME",3,1))="A" then type="贷款业务信息";
	else if upcase(substr("&TNAME",4,1))="B" then type="身份信息";
	else if upcase(substr("&TNAME",4,1))="C" then type="职业信息";
	else if upcase(substr("&TNAME",4,1))="D" then type="居住信息";
	else if upcase(substr("&TNAME",3,1))="G" then type="特殊交易信息";
	else if upcase(substr("&TNAME",3,1))="E" then type="担保信息";
	else if upcase(substr("&TNAME",3,1))="T" then type="投资人信息";
	else if upcase(substr("&TNAME",3,1))="H" then type="贷款合同信息";
	LABEL
	type=报文类型
	index=报文记录行数
	;
RUN;
%MEND;
%ORDER_NM(T_a);
%ORDER_NM(T_e);
%ORDER_NM(T_g);
%ORDER_NM(T_h);
%ORDER_NM(T_pb);
%ORDER_NM(T_pc);
%ORDER_NM(T_pd);
%ORDER_NM(T_s);
%ORDER_NM(T_t);

/*DATA ER_XLS_1;*/
/*	SET ER_XLS.ER_XLS;*/
/*	DATE1=MDY(SUBSTR(uploaddate,6,2),SUBSTR(uploaddate,9,2),SUBSTR(uploaddate,1,4));*/
/*RUN;*/
PROC SQL;
	CREATE TABLE ER_XLS_1 AS SELECT 
		*
/*	FROM ER_XLS1(WHERE=intnx('month',today(),-1,'b')>=DATE1>=intnx('month',today(),-1,'e')))*/
/*	WHERE SUBSTR(FILENAME,1,24) IN (SELECT SUBSTR(FILENAME,1,24) FROM T_A_1) ;*/
		FROM ER_XLS
		where SUBSTR(sorgcode,1,14) in (select sorgcode from soc)
		order by sorgcode,type,SERRORCODE;
QUIT;

/*PROC SORT DATA=ER_XLS_1;*/
/*	BY sorgcode type SERRORCODE;*/
/*RUN;*/
/*用于生成反馈解析*/
/*DATA ER_XLS_2;*/
/*	SET ER_XLS_G;*/
/*	BY sorgcode type SERRORCODE;*/
/*	IF LAST.SERRORCODE;*/
/*RUN;*/
/*用于将反馈和报文匹配*/
DATA ER_XLS_2;
	FORMAT index_new 8.;
	INFORMAT index_new 8.;
	SET ER_XLS_1;
	index_new=INPUT(index,8.)-1;
	DROP inde;
	rename
	index_new=index;
	label
	index="报文记录行数"
	;
RUN;

%MACRO MAPPING_XLS_ER(TNAME);
PROC SQL;
	CREATE TABLE ER_&TNAME. AS SELECT
		T1.*
		,T2.*
	FROM ER_XLS_2 AS T1
	LEFT JOIN &TNAME._1 AS T2
	ON SUBSTR(T1.FILENAME,1,24)=SUBSTR(T2.FILENAME,1,24)
	AND T1.type=T2.type
	AND T1.INDEX=T2.INDEX
	where T2.type is not null and T2.sorgcode in (select sorgcode from soc);
QUIT;

data ER_&TNAME.;
	retain filename type index;
	set ER_&TNAME.;
run;
%mend;

%MAPPING_XLS_ER(T_A);
%MAPPING_XLS_ER(T_e);
%MAPPING_XLS_ER(T_g);
%MAPPING_XLS_ER(T_h);
%MAPPING_XLS_ER(T_pb);
%MAPPING_XLS_ER(T_pc);
%MAPPING_XLS_ER(T_pd);
%MAPPING_XLS_ER(T_t);
%MAPPING_XLS_ER(T_s);


/**/



/*输出结果*/
/*PROC EXPORT DATA=ER_TA outFILE="E:\新建文件夹\9月\NFCS\第四部分.xlsx"*/
/*	dbms=excel replace;*/
/*	sheetname="er_XLS";*/
/*run;*/
