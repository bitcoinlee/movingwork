options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;
data heliu_spec;
	format yuefen yymmd7.;
	set nfcs.sino_loan_spec_trade(keep = sorgcode dgetdate spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
	by spin dgetdate;
	yuefen = intnx("month",datepart(dgetdate),0,"b");
run;
data heliu_spec;
	set heliu_spec;
	if spin = lag(spin) then delete;
run;

data sino_org2;
	retain STOPORGCODE SORGCODE SORGname;
	set nfcs.sino_org(keep=STOPORGCODE SORGCODE SORGname sareacode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
run;
proc sql;
	create table _sino_org as select
		T1.STOPORGCODE as sorgcode label="��������"
		,T2.sorgname as sorgname label="��������"
/*		,T1.sareacode label="����ʡ�д���"*/
		from sino_org2 as T1 left join nfcs.sino_org as T2
		on T1.STOPORGCODE = T2.SORGCODE
		where substr(T1.STOPORGCODE,1,1)= "Q";
quit;
proc sort data = _sino_org nodup;
	by sorgcode;
run;

proc sql;
	create table _heliu_spec as select
	T2.sorgname label =  "��������"
	,yuefen	label = "�����·�"
	,count(spin) as renshu label =  "���������ֻͳ���״Σ�"
	from heliu_spec as T1
	left join _sino_org as T2
	on T1.sorgcode = T2.sorgcode
	group by sorgname,yuefen
;
quit;

libname xls excel "E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\��ʱ�Թ���\��Ʒ\����\���⽻��.xlsx";
data xls.sheet1(dblabel=yes);
set _heliu_spec;
run;
libname xls clear;
