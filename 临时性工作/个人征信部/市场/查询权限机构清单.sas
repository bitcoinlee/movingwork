options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
/*���ݵ�ǰ���ڣ��Զ�����STAT_OP END START ����֤ 2015.03.02 �����ˣ���� ��������־�й۲�������ʹ��*/
%INCLUDE "E:\�½��ļ���\SAS\���ô���\�Զ���\000_FORMAT.sas";
%include "E:\�½��ļ���\SAS\������.sas";

%FORMAT;
%let firstday = mdy(1,1,2015);
%let dayscount = intck('day',&firstday.,today());

/*ǩԼ��������*/
data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set mylib.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="��������"
		,T2.sorgname as sorgname label="��������"
/*		,T1.sareacode label="����ʡ�д���"*/
		from sino_org2 as T1 left join mylib.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q";
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;


proc sql;
	create table _chaxun_type as select
		sorgcode
		,(case IPLATE when 3 then "1" when 1 then "2" else "δ��ͨ" end) as chaxun_type label = "��ѯ�������ͣ�1-����桢2-�����+����棩"
	from mylib.Sino_credit_orgplate(where = (IPLATE^=2 and ISTATE =1 and SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	order by sorgcode , (case when chaxun_type = "2" then 1 when chaxun_type = "1" then 2 else 3 end)
;
quit;
data _chaxun_type;
	set _chaxun_type;
	if sorgcode = lag(sorgcode) then delete;
run;

proc sql;
	create table cly as select
		T1.*
		,T2.*
		from _sino_org as T1
		left join _chaxun_type as T2
		on T1.sorgcode = T2.sorgcode
	where chaxun_type is not null
;
quit;
libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\BD\������\��ѯȨ������-1.xlsx";
data xls.sheet1(dblabel=yes);
	set cly;
run;
libname xls clear;
