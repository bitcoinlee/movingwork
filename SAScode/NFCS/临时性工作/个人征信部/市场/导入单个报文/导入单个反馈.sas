%include "E:\�½��ļ���\SAS\���ô���\�Զ���\��ʱ�Թ���\�г�\���뵥������\T02_TXT�����������.sas";
%Er_AQ_input(aq,E:\�½��ļ���\201508\������\Q10151000H8300201504P5611.txt);
libname xls excel "E:\�½��ļ���\201508\������\Q10151000H8300201504P5611.xlsx";
data xls.sheet1(dblabel = yes);
	set aq;
run;
libname xls clear;

	
