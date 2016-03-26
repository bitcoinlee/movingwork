/*ά��ʱ��2014-11-12*/
%macro format_PB(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="������������",
cats(_col1) as sname format=$30. informat=$30. label="����",
cats(_col2) as scerttype format=$1. informat=$1. label="֤������",
cats(_col3) as scertno format=$18. informat=$18. label="֤������",
cats(_col4) as isex format=$1. informat=$1. label="�Ա�",
cats(_col5) as dbirthday format=$8. informat=$8. label="��������",
cats(_col6) as imarriage format=$2. informat=$2. label="����״��",
cats(_col7) as iedulevel format=$2. informat=$2. label="���ѧ��",
cats(_col8) as iedudegree format=$1. informat=$1. label="���ѧλ",
cats(_col9) as shometel format=$25. informat=$25. label="סլ�绰",
cats(_col10) as smobiletel format=$16. informat=$16. label="�ֻ�����",
cats(_col11) as sofficetel format=$25. informat=$25. label="��λ�绰",
cats(_col12) as Semail format=$30. informat=$30. label="��������",
cats(_col13) as saddress format=$60. informat=$60. label="��ס��ַ",
cats(_col14) as szip format=$6. informat=$6. label="��ס��ַ��������",
cats(_col15) as sresidence format=$60. informat=$60. label="������ַ",
cats(_col16) as smatename format=$30. informat=$30. label="��ż����",
cats(_col17) as smatecerttype format=$1. informat=$1. label="��ż֤������",
cats(_col18) as smatecertno format=$18. informat=$18. label="��ż֤������",
cats(_col19) as smatecompany format=$60. informat=$60. label="��ż������λ",
cats(_col20) as smatetel format=$25. informat=$25. label="��ż��ϵ��ʽ",
cats(_col21) as sfirstcontactname format=$30. informat=$30. label="��һ��ϵ������",
cats(_col22) as sfirstcontactrelation format=$1. informat=$1. label="��һ��ϵ�˹�ϵ",
cats(_col23) as sfirstcontacttel format=$25. informat=$25. label="��һ��ϵ����ϵ�绰",
cats(_col24) as ssecondcontactname format=$30. informat=$30. label="�ڶ���ϵ������",
cats(_col25) as ssecondcontactrelation format=$1. informat=$1. label="�ڶ���ϵ�˹�ϵ",
cats(_col26) as ssecondcontacttel format=$25. informat=$25. label="�ڶ���ϵ����ϵ�绰",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;

%macro format_PC(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="������������",
cats(_col1) as sname format=$30. informat=$30. label="����",
cats(_col2) as scerttype format=$1. informat=$1. label="֤������",
cats(_col3) as scertno format=$18. informat=$18. label="֤������",
cats(_col4) as soccupation format=$1. informat=$1. label="ְҵ",
cats(_col5) as scompany format=$60. informat=$60. label="��λ����",
cats(_col6) as sindustry format=$1. informat=$1. label="��λ������ҵ",
cats(_col7) as scompanyaddress format=$60. informat=$60. label="��λ��ַ",
cats(_col8) as scompanyzip format=$6. informat=$6. label="��λ��������",
cats(_col9) as sstartyear format=$4. informat=$4. label="����λ������ʼ���",
cats(_col10) as iposition format=$1. informat=$1. label="ְ��",
cats(_col11) as ititle format=$1. informat=$1. label="ְ��",
cats(_col12) as iannualincome format=$10. informat=$10. label="������",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;

%macro format_PD(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="������������",
cats(_col1) as sname format=$30. informat=$30. label="����",
cats(_col2) as scerttype format=$1. informat=$1. label="֤������",
cats(_col3) as scertno format=$18. informat=$18. label="֤������",
cats(_col4) as Daddress format=$60. informat=$60. label="��ס��ַ",
cats(_col5) as Dzip format=$6. informat=$6. label="��ס��ַ��������",
cats(_col6) as Dcondition format=$1. informat=$1. label="��ס״��",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;

%macro format_S(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="������������",
cats(_col1) as sapplycode format=$40. informat=$40. label="���������",
cats(_col2) as sname format=$30. informat=$30. label="����",
cats(_col3) as scerttype format=$1. informat=$1. label="֤������",
cats(_col4) as scertno format=$18. informat=$18. label="֤������",
cats(_col5) as stype format=$2. informat=$2. label="������������",
cats(_col6) as Imoney format=$10. informat=$10. label="����������",
cats(_col7) as imonthcount format=$6. informat=$6. label="������������",
cats(_col8) as ddate format=$8. informat=$8. label="��������ʱ��",
cats(_col9) as sstate format=$1. informat=$1. label="��������״̬",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;
/**/
/*%macro format_A(out);*/
/*proc sql noprint;*/
/*create table &out._f as*/
/*select */
/*cats(_col0) as col0  format=$14. informat=$14. label="������������",*/
/*cats(_col1) as col1  format=$2. informat=$2. label="��������",*/
/*cats(_col2) as col2  format=$60. informat=$60.  label="�����ͬ����",*/
/*cats(_col3) as col3 format=$40. informat=$40. label="����ҵ�����",*/
/*cats(_col4) as col4 format=$6. informat=$6. label="�����ص�",*/
/*cats(_col5) as col5 format=$8. informat=$8. label="��������",*/
/*cats(_col6) as col6 format=$8. informat=$8. label="��������",*/
/*cats(_col7) as col7 format=$3. informat=$3. label="����",*/
/*_col8 as col8 format=best12. informat=best12. label="���Ŷ��",*/
/*_col9 as col9 format=best12. informat=best12. label="�������Ŷ��",*/
/*_col10 as col10 format=best12. informat=best12. label="���ծ��",*/
/*cats(_col11) as col11 format=$1. informat=$1. label="������ʽ",*/
/*cats(_col12) as col12 format=$2. informat=$2. label="����Ƶ��",*/
/*cats(_col13) as col13 format=$3. informat=$3. label="��������",*/
/*cats(_col14) as col14 format=$3. informat=$3. label="ʣ�໹������",*/
/*cats(_col15) as col15 format=$3. informat=$3. label="Э����������",*/
/*_col16 as col16 format=best12. informat=best12. label="Э�������",*/
/*cats(_col17) as col17 format=$8. informat=$8. label="����/Ӧ��������",*/
/*cats(_col18) as col18 format=$8. informat=$8. label="���һ��ʵ�ʻ�������",*/
/*_col19  as col19 format=best12. informat=best12. label="����Ӧ������",*/
/*_col20  as col20 format=best12. informat=best12. label="ʵ�ʻ�����",*/
/*_col21  as col21 format=best12. informat=best12. label="���",*/
/*cats(_col22) as col22 format=$2. informat=$2. label="��ǰ��������",*/
/*_col23 as col23 format=best12. informat=best12. label="��ǰ�����ܶ�",*/
/*_col24 as col24 format=best12. informat=best12. label="����31-60��δ�黹�����",*/
/*_col25 as col25 format=best12. informat=best12. label="����61-90��δ�黹�����",*/
/*_col26 as col26 format=best12. informat=best12. label="����90-180��δ�黹�����",*/
/*_col27 as col27 format=best12. informat=best12. label="����180������δ�黹�����",*/
/*cats(_col28) as col28 format=$3. informat=$3. label="�ۼ���������",*/
/*cats(_col29) as col29 format=$2. informat=$2. label="�����������",*/
/*cats(_col30) as col30 format=$1. informat=$1. label="�弶����״̬",*/
/*cats(_col31) as col31 format=$1. informat=$1. label="�˻�״̬",*/
/*cats(_col32) as col32 format=$24. informat=$24. label="24�£��˻�������״̬",*/
/*cats(_col33) as col33 format=$1. informat=$1.  label="�˻�ӵ������Ϣ��ʾ",*/
/*cats(_col34) as col34 format=$30. informat=$30. label="����",*/
/*cats(_col35) as col35  format=$1. informat=$1. label="֤������",*/
/*cats(_col36) as col36 format=$18. informat=$18. label="֤������",*/
/*uploaddate format=$18. informat=$18. label="��������",*/
/*filename format=$30. informat=$30. label="�ļ�����"*/
/*from &out.;*/
/*quit;*/
/*%mend;*/

%macro format_A(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="������������",
cats(_col1) as sloantype  format=$2. informat=$2. label="��������",
cats(_col2) as sloancompactcode  format=$60. informat=$60. label="�����ͬ����",
cats(_col3) as saccount format=$40. informat=$40. label="����ҵ�����",
cats(_col4) as sareacode format=$6. informat=$6. label="�����ص�",
cats(_col5) as ddateopened format=$8. informat=$8. label="��������",
cats(_col6) as ddateclosed format=$8. informat=$8. label="��������",
cats(_col7) as scurrency format=$3. informat=$3. label="����",
_col8 as icreditlimit format=best12. informat=best12. label="���Ŷ��",
_col9 as ishareaccount format=best12. informat=best12. label="�������Ŷ��",
_col10 as imaxdebt format=best12. informat=best12. label="���ծ��",
cats(_col11) as iguaranteeway format=$1. informat=$1. label="������ʽ",
cats(_col12) as stermsfreq format=$2. informat=$2. label="����Ƶ��",
cats(_col13) as imonthduration format=$3. informat=$3. label="��������",
cats(_col14) as imonthunpaid format=$3. informat=$3. label="ʣ�໹������",
cats(_col15) as streatypaydue format=$3. informat=$3. label="Э����������",
_col16 as streatypayamount format=best12. informat=best12. label="Э���ڻ����",
cats(_col17) as dbillingdate format=$8. informat=$8. label="����/Ӧ��������",
cats(_col18) as drecentpaydate format=$8. informat=$8. label="���һ��ʵ�ʻ�������",
_col19 as ischeduledamount format=best12. informat=best12. label="����Ӧ������",
_col20 as iactualpayamount format=best12. informat=best12. label="����ʵ�ʻ�����",
_col21 as ibalance format=best12. informat=best12. label="���",
cats(_col22) as icurtermspastdue format=$2. informat=$2. label="��ǰ��������",
_col23 as iamountpastdue format=best12. informat=best12. label="��ǰ�����ܶ�",
_col24 as Iamountpastdue30 format=best12. informat=best12. label="����31-60��δ�黹�����",
_col25 as Iamountpastdue60 format=best12. informat=best12. label="����61-90��δ�黹�����",
_col26 as Iamountpastdue90 format=best12. informat=best12. label="����90-180��δ�黹�����",
_col27 as Iamountpastdue180 format=best12. informat=best12. label="����180������δ�黹�����",
cats(_col28) as itermspastdue format=$3. informat=$3. label="�ۼ���������",
cats(_col29) as imaxtermspastdue format=$2. informat=$2. label="�����������",
cats(_col30) as iclass5stat format=$1. informat=$1. label="�弶����״̬",
cats(_col31) as iaccountstat format=$1. informat=$1. label="�˻�״̬",
cats(_col32) as Spaystat24month format=$24. informat=$24. label="24�����˻�����״̬",
cats(_col33) as iinfoindicator format=$1. informat=$1.  label="�˻�ӵ������Ϣ��ʾ",
cats(_col34) as sname format=$30. informat=$30. label="����",
cats(_col35) as scerttype  format=$1. informat=$1. label="֤������",
cats(_col36) as scertno format=$18. informat=$18. label="֤������",
/*cats(_col37) as skeepcolumn format=$30. informat=$30. label="Ԥ���ֶ�",*/
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out.;
quit;
%mend;

%macro format_H(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14.informat=$14. label="������������",
cats(_col1) as sloancompactcode format=$60.informat=$60. label='�����ͬ����', 
cats(_col2) as dloancompactopened format=$8.informat=$8. label='�����ͬ��Ч����',
cats(_col3) as dloancompactclosed format=$8.informat=$8. label='�����ͬ��ֹ����',
cats(_col4) as scurrency format=$3.informat=$3. label='����',
cats(_col5) as iloancompactamount format=$10.informat=$10. label='�����ͬ���',
cats(_col6) as icompactstat format=$1.informat=$1. label='��ͬ״̬',
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;

%macro format_E(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="������������",
cats(_col1) as saccount format=$40. informat=$40. label="����ҵ�����",
cats(_col2) as sguaranteepersonname format=$30. informat=$30. label="����������",
cats(_col3) as sguaranteepersoncerttype format=$1. informat=$1. label="������֤������",
cats(_col4) as sguaranteepersoncertno format=$18. informat=$18. label="������֤������",
cats(_col5) as iguaranteesum format=$10. informat=$10. label="�������",
cats(_col6) as iguaranteestat format=$1. informat=$1. label="����״̬",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;

%macro format_T(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="������������",
cats(_col1) as saccount format=$40. informat=$40. label="����ҵ�����",
cats(_col2) as sinvestorpersonname format=$30. informat=$30. label="Ͷ��������",
cats(_col3) as sinvestorpersoncerttype format=$1. informat=$1. label="Ͷ����֤������",
cats(_col4) as sinvestorpersoncertno format=$18. informat=$18. label="Ͷ����֤������",
cats(_col5) as iinvestorsum format=$10. informat=$10. label="Ͷ�ʽ��",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;
%macro format_G(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="������������",
cats(_col1) as sname format=$30. informat=$30. label="����",
cats(_col2) as scerttype format=$1. informat=$1. label="֤������",
cats(_col3) as scertno format=$18. informat=$18. label="֤������",
cats(_col4) as saccount format=$40. informat=$40. label="����ҵ�����",
cats(_col5) as speculiartradetype format=$1. informat=$1. label="���⽻������",
cats(_col6) as doccurdate format=$8. informat=$8. label="��������",
cats(_col7) as ichangemonth format=$4. informat=$4. label="�������",
cats(_col8) as ioccursum format=$10. informat=$10. label="�������",
cats(_col9) as sdetailinfo format=$200. informat=$200. label="��ϸ��Ϣ",
uploaddate format=$18. informat=$18. label="��������",
filename format=$30. informat=$30. label="�ļ�����"
from &out;
quit;
%mend;


