/*sheetҳ	������	λ��	 �������	�������� */
PROC SQL;
	CREATE TABLE ER_XLS (
		_COL0 as type CHAR(20)  FORMAT=$20. INFORMAT=$20. LABEL='��������'
		,_COL1 as index CHAR(4) FORMAT=$4. INFORMAT=$4. LABEL='����������'
		,_COL2 as scolumn CHAR(4) FORMAT=$4. INFORMAT=$4. LABEL='����������'
		,_COL3 as SERRORCODE CHAR(6) FORMAT=$6. INFORMAT=$6. LABEL='�������'
		,_COL4 as SERRORNOTE CHAR(800) FORMAT=$800. INFORMAT=$800. LABEL='��������'
		,uploaddate CHAR(15) FORMAT=$15. INFORMAT=$15. LABEL='��������'
		,filename CHAR(40) FORMAT=$40. INFORMAT=$40. LABEL='�ļ�����'
		,sorgcode CHAR(20) FORMAT=$20. INFORMAT=$20. LABEL='��������'
	);
QUIT;


%macro fbim(path,worktable,out);
proc import datafile="&path" 
DBMS=excel out=&out replace;
sheet="&worktable";
run;

QUIT;
DATA &out;set &out;
x="&path";
call scan(x,5,position1,length1,"\");
call scan(x,8,position2,length2,"\");
uploaddate=substrn(x,position1,length1);
filename=substrn(x,position2,length2);
sorgcode=substr(filename,1,14);
wordtype=substr(filename,length(filename)-2,3);
drop position1 length1 position2 length2 x;
run;

DATA &out;set &out;
array check(1) _col0;
if check(1)=' ' or check(1)='.' then delete;run;
PROC APPEND BASE=ER_XLS DATA=&OUT. FORCE;
PROC SQL;
	DROP TABLE &OUT.;
QUIT;
%mend;
