OPTIONS MPRINT MLOGIC NOXWAIT COMPRESS=YES;
%LET STAT_OP=8��ȫ��;
%LET STAT_DT=MDY(8,31,2014);
LIBNAME SSS "D:\����\&STAT_OP.";

%LET PATH0=C:\Users\cis\Desktop\���ô���;
%LET PATH1="&PATH0.\�Զ���\000_FORMAT.sas";
%LET PATH2="&PATH0.\�Զ���\���������Զ���\��������ָ�����.sas";
%LET OUTPATH="&PATH0.\�Զ���\����ļ���\�������ֽ��\��������ָ��&STAT_OP..xls";
%INCLUDE &PATH1.;%FORMAT;
%INCLUDE &PATH2.;
%SCORE(&STAT_DT);

