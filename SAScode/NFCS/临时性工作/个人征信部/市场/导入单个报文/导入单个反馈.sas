%include "E:\新建文件夹\SAS\常用代码\自动化\临时性工作\市场\导入单个报文\T02_TXT反馈导入程序.sas";
%Er_AQ_input(aq,E:\新建文件夹\201508\陈力阳\Q10151000H8300201504P5611.txt);
libname xls excel "E:\新建文件夹\201508\陈力阳\Q10151000H8300201504P5611.xlsx";
data xls.sheet1(dblabel = yes);
	set aq;
run;
libname xls clear;

	
