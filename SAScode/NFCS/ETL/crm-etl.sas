libname crmlocal "D:\����\crm1\201602";

/*�ⲿ�˹�����������*/
PROC IMPORT OUT= WORK.shortname 
DATAFILE= "E:\�½��ļ���\201603\NFCS\�����ż������������0229.xlsx" 
DBMS=EXCEL REPLACE;
RANGE="Sheet1$"; 
GETNAMES=NO;
MIXED=YES;
SCANTEXT=YES;
USEDATE=YES;
SCANTIME=YES;
RUN;

data shortname;
	set shortname(where = (substr(F3,13,2)="00"));
run;

proc sql;
	update crm1.T_contract_order
	set EXTEND2 = (select strip(F4) from work.shortname where CUSTOMER_NAME = strip(F2))
;
quit;

proc sql;
	create table soc_t as select
		T1.*
		,T2.sorgname
		from soc as T1
		left join nfcs.sino_org as T2
		on T1.sorgcode = T2.sorgcode
	;
quit;

proc sql;
	create table org_crm as select
	(case sub_account_id when 'djw' then '�ſ���'
	when 'gwq' then '����ǿ'
	when 'zm' then '����'
	when 'llx' then '����ϣ'
	when 'xjq' then '������' 
	when 'zkb' then '�쿭��' end) as person
	,EXECUTE_START_DATE
	,CONTRACT_ORDER_SUBJECT
	,CUSTOMER_NAME as sorgname
	,EXTEND2 as shortname
	from crm1.T_contract_order
		where delete_flag = 0
	order by EXECUTE_START_DATE
;
quit;
