/*libname sss "D:\����\2015��4��ȫ��";*/
options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;

/*�Ϻ�������������*/
data sino_org;
	retain SORGCODE SORGname ;
	set mylib.sino_org(keep= SORGCODE SORGname Slevel sareacode where = (Slevel = '1' and sareacode = '310000' and sorgcode not in ('Q10152900H0000' '11111111111111' 'Q10152900H0001')));
	drop
	Slevel
	sareacode
	;
	label
	SORGCODE = ��������
	sorgname = ��������
	;
run;

/*�ѱ�������*/
proc sql;
	create table baosong_jiekou as select
	distinct SORGCODE
	,"�ѱ���" as status label = "����״̬"
	from mylib.sino_msg(keep= SORGCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	;
quit;
/*����ҵ�����*/
PROC SQL;
	CREATE TABLE baosong_LOAN AS SELECT
		distinct SORGCODE LABEL="��������"
		,"��" as status3 label = "����ҵ��"
	FROM mylib.SINO_LOAN(keep=sorgcode WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
;
QUIT;
/*�������⽻�׻���*/
proc sql;
	create table baosong_luru as select
		distinct sorgcode
		,"��" as status2 label = "���⽻��"
	from mylib.Sino_LOAN_SPEC_TRADE(keep= SORGCODE WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	;
quit;

/*���ʹ���ҵ�����*/
proc sort data = mylib.SINO_LOAN(keep=sorgcode saccount WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001'))) out = sino_loan nodupkey;
	by sorgcode saccount;
quit;
PROC SQL;
	CREATE TABLE ruku_LOAN AS SELECT
		SORGCODE LABEL="��������"
		,COUNT(SACCOUNT) as rukucount label = "�������¼��"
	FROM sino_loan
	GROUP BY SORGCODE
;
QUIT;

/*3.���������Ϣ*/
PROC SQL;
	CREATE TABLE ruku_SF AS SELECT
		SORGCODE  LABEL="��������"
		,count(spin) as rukucount2 label = "�����������ݣ�"
	FROM mylib.sino_person_certification(keep=sorgcode spin WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')))
	GROUP BY SORGCODE
;
QUIT;

/*���ܲ����*/
proc sql;
	create table _huifu as select
		T1.sorgcode
		,T1.sorgname
		,status
		,status2
		,status3
		,rukucount
		,rukucount2
		from sino_org as T1 left join Baosong_jiekou as T9
		on T1.sorgcode = T9.sorgcode
		left join Baosong_loan as T2
		on T1.sorgcode = T2.sorgcode
		left join Baosong_luru as T10
		on T1.sorgcode = T10.sorgcode
		left join Ruku_loan as T3
		on T1.sorgcode = T3.sorgcode
		left join Ruku_sf as T4
		on T1.sorgcode = T4.sorgcode
order by (case when status ^= '' then 1 else 2 end)
		;
quit;

libname  myxls  EXCEL "D:/�㸶����-V1.0.xls";
data myxls.sheet1(dblabel=YES);
set _huifu;
run;
libname myxls clear;
