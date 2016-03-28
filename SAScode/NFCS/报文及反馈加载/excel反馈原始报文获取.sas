%let reqmonth=201503;
LIBNAME BW_XLS "E:\�½��ļ���\&reqmonth.\NFCS\bw_xls";
LIBNAME ER_XLS "E:\�½��ļ���\&reqmonth.\NFCS\er_xls";
/*��XLS������XLS���Ľ���ƥ��*/

/*���ã���ÿ��xls�����ļ�����ţ��Ա��뷴���ļ��е��к�ƥ��*/
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
	if upcase(substr("&TNAME",3,1))="S" then type="����������Ϣ";
	else if upcase(substr("&TNAME",3,1))="A" then type="����ҵ����Ϣ";
	else if upcase(substr("&TNAME",4,1))="B" then type="�����Ϣ";
	else if upcase(substr("&TNAME",4,1))="C" then type="ְҵ��Ϣ";
	else if upcase(substr("&TNAME",4,1))="D" then type="��ס��Ϣ";
	else if upcase(substr("&TNAME",3,1))="G" then type="���⽻����Ϣ";
	else if upcase(substr("&TNAME",3,1))="E" then type="������Ϣ";
	else if upcase(substr("&TNAME",3,1))="T" then type="Ͷ������Ϣ";
	else if upcase(substr("&TNAME",3,1))="H" then type="�����ͬ��Ϣ";
	LABEL
	type=��������
	index=���ļ�¼����
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
/*�������ɷ�������*/
/*DATA ER_XLS_2;*/
/*	SET ER_XLS_G;*/
/*	BY sorgcode type SERRORCODE;*/
/*	IF LAST.SERRORCODE;*/
/*RUN;*/
/*���ڽ������ͱ���ƥ��*/
DATA ER_XLS_2;
	FORMAT index_new 8.;
	INFORMAT index_new 8.;
	SET ER_XLS_1;
	index_new=INPUT(index,8.)-1;
	DROP inde;
	rename
	index_new=index;
	label
	index="���ļ�¼����"
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



/*������*/
/*PROC EXPORT DATA=ER_TA outFILE="E:\�½��ļ���\9��\NFCS\���Ĳ���.xlsx"*/
/*	dbms=excel replace;*/
/*	sheetname="er_XLS";*/
/*run;*/
