/*维护时间2014-11-12*/
%macro format_PB(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sname format=$30. informat=$30. label="姓名",
cats(_col2) as scerttype format=$1. informat=$1. label="证件类型",
cats(_col3) as scertno format=$18. informat=$18. label="证件号码",
cats(_col4) as isex format=$1. informat=$1. label="性别",
cats(_col5) as dbirthday format=$8. informat=$8. label="出生日期",
cats(_col6) as imarriage format=$2. informat=$2. label="婚姻状况",
cats(_col7) as iedulevel format=$2. informat=$2. label="最高学历",
cats(_col8) as iedudegree format=$1. informat=$1. label="最高学位",
cats(_col9) as shometel format=$25. informat=$25. label="住宅电话",
cats(_col10) as smobiletel format=$16. informat=$16. label="手机号码",
cats(_col11) as sofficetel format=$25. informat=$25. label="单位电话",
cats(_col12) as Semail format=$30. informat=$30. label="电子邮箱",
cats(_col13) as saddress format=$60. informat=$60. label="居住地址",
cats(_col14) as szip format=$6. informat=$6. label="居住地址邮政编码",
cats(_col15) as sresidence format=$60. informat=$60. label="户籍地址",
cats(_col16) as smatename format=$30. informat=$30. label="配偶姓名",
cats(_col17) as smatecerttype format=$1. informat=$1. label="配偶证件类型",
cats(_col18) as smatecertno format=$18. informat=$18. label="配偶证件号码",
cats(_col19) as smatecompany format=$60. informat=$60. label="配偶工作单位",
cats(_col20) as smatetel format=$25. informat=$25. label="配偶联系方式",
cats(_col21) as sfirstcontactname format=$30. informat=$30. label="第一联系人姓名",
cats(_col22) as sfirstcontactrelation format=$1. informat=$1. label="第一联系人关系",
cats(_col23) as sfirstcontacttel format=$25. informat=$25. label="第一联系人联系电话",
cats(_col24) as ssecondcontactname format=$30. informat=$30. label="第二联系人姓名",
cats(_col25) as ssecondcontactrelation format=$1. informat=$1. label="第二联系人关系",
cats(_col26) as ssecondcontacttel format=$25. informat=$25. label="第二联系人联系电话",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;

%macro format_PC(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sname format=$30. informat=$30. label="姓名",
cats(_col2) as scerttype format=$1. informat=$1. label="证件类型",
cats(_col3) as scertno format=$18. informat=$18. label="证件号码",
cats(_col4) as soccupation format=$1. informat=$1. label="职业",
cats(_col5) as scompany format=$60. informat=$60. label="单位名称",
cats(_col6) as sindustry format=$1. informat=$1. label="单位所属行业",
cats(_col7) as scompanyaddress format=$60. informat=$60. label="单位地址",
cats(_col8) as scompanyzip format=$6. informat=$6. label="单位邮政编码",
cats(_col9) as sstartyear format=$4. informat=$4. label="本单位工作起始年份",
cats(_col10) as iposition format=$1. informat=$1. label="职务",
cats(_col11) as ititle format=$1. informat=$1. label="职称",
cats(_col12) as iannualincome format=$10. informat=$10. label="年收入",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;

%macro format_PD(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sname format=$30. informat=$30. label="姓名",
cats(_col2) as scerttype format=$1. informat=$1. label="证件类型",
cats(_col3) as scertno format=$18. informat=$18. label="证件号码",
cats(_col4) as Daddress format=$60. informat=$60. label="居住地址",
cats(_col5) as Dzip format=$6. informat=$6. label="居住地址邮政编码",
cats(_col6) as Dcondition format=$1. informat=$1. label="居住状况",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;

%macro format_S(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sapplycode format=$40. informat=$40. label="贷款申请号",
cats(_col2) as sname format=$30. informat=$30. label="姓名",
cats(_col3) as scerttype format=$1. informat=$1. label="证件类型",
cats(_col4) as scertno format=$18. informat=$18. label="证件号码",
cats(_col5) as stype format=$2. informat=$2. label="贷款申请类型",
cats(_col6) as Imoney format=$10. informat=$10. label="贷款申请金额",
cats(_col7) as imonthcount format=$6. informat=$6. label="贷款申请月数",
cats(_col8) as ddate format=$8. informat=$8. label="贷款申请时间",
cats(_col9) as sstate format=$1. informat=$1. label="贷款申请状态",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;
/**/
/*%macro format_A(out);*/
/*proc sql noprint;*/
/*create table &out._f as*/
/*select */
/*cats(_col0) as col0  format=$14. informat=$14. label="网贷机构代码",*/
/*cats(_col1) as col1  format=$2. informat=$2. label="贷款类型",*/
/*cats(_col2) as col2  format=$60. informat=$60.  label="贷款合同号码",*/
/*cats(_col3) as col3 format=$40. informat=$40. label="贷款业务号码",*/
/*cats(_col4) as col4 format=$6. informat=$6. label="发生地点",*/
/*cats(_col5) as col5 format=$8. informat=$8. label="开户日期",*/
/*cats(_col6) as col6 format=$8. informat=$8. label="到期日期",*/
/*cats(_col7) as col7 format=$3. informat=$3. label="币种",*/
/*_col8 as col8 format=best12. informat=best12. label="授信额度",*/
/*_col9 as col9 format=best12. informat=best12. label="共享授信额度",*/
/*_col10 as col10 format=best12. informat=best12. label="最大负债额",*/
/*cats(_col11) as col11 format=$1. informat=$1. label="担保方式",*/
/*cats(_col12) as col12 format=$2. informat=$2. label="还款频率",*/
/*cats(_col13) as col13 format=$3. informat=$3. label="还款月数",*/
/*cats(_col14) as col14 format=$3. informat=$3. label="剩余还款月数",*/
/*cats(_col15) as col15 format=$3. informat=$3. label="协定还款期数",*/
/*_col16 as col16 format=best12. informat=best12. label="协定还款额",*/
/*cats(_col17) as col17 format=$8. informat=$8. label="结算/应还款日期",*/
/*cats(_col18) as col18 format=$8. informat=$8. label="最近一次实际还款日期",*/
/*_col19  as col19 format=best12. informat=best12. label="本月应还款金额",*/
/*_col20  as col20 format=best12. informat=best12. label="实际还款金额",*/
/*_col21  as col21 format=best12. informat=best12. label="余额",*/
/*cats(_col22) as col22 format=$2. informat=$2. label="当前逾期期数",*/
/*_col23 as col23 format=best12. informat=best12. label="当前逾期总额",*/
/*_col24 as col24 format=best12. informat=best12. label="逾期31-60天未归还贷款本金",*/
/*_col25 as col25 format=best12. informat=best12. label="逾期61-90天未归还贷款本金",*/
/*_col26 as col26 format=best12. informat=best12. label="逾期90-180天未归还贷款本金",*/
/*_col27 as col27 format=best12. informat=best12. label="逾期180天以上未归还贷款本金",*/
/*cats(_col28) as col28 format=$3. informat=$3. label="累计逾期期数",*/
/*cats(_col29) as col29 format=$2. informat=$2. label="最高逾期期数",*/
/*cats(_col30) as col30 format=$1. informat=$1. label="五级分类状态",*/
/*cats(_col31) as col31 format=$1. informat=$1. label="账户状态",*/
/*cats(_col32) as col32 format=$24. informat=$24. label="24月（账户）还款状态",*/
/*cats(_col33) as col33 format=$1. informat=$1.  label="账户拥有者信息提示",*/
/*cats(_col34) as col34 format=$30. informat=$30. label="姓名",*/
/*cats(_col35) as col35  format=$1. informat=$1. label="证件类型",*/
/*cats(_col36) as col36 format=$18. informat=$18. label="证件号码",*/
/*uploaddate format=$18. informat=$18. label="更新日期",*/
/*filename format=$30. informat=$30. label="文件名称"*/
/*from &out.;*/
/*quit;*/
/*%mend;*/

%macro format_A(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sloantype  format=$2. informat=$2. label="贷款类型",
cats(_col2) as sloancompactcode  format=$60. informat=$60. label="贷款合同号码",
cats(_col3) as saccount format=$40. informat=$40. label="贷款业务号码",
cats(_col4) as sareacode format=$6. informat=$6. label="发生地点",
cats(_col5) as ddateopened format=$8. informat=$8. label="开户日期",
cats(_col6) as ddateclosed format=$8. informat=$8. label="到期日期",
cats(_col7) as scurrency format=$3. informat=$3. label="币种",
_col8 as icreditlimit format=best12. informat=best12. label="授信额度",
_col9 as ishareaccount format=best12. informat=best12. label="共享授信额度",
_col10 as imaxdebt format=best12. informat=best12. label="最大负债额",
cats(_col11) as iguaranteeway format=$1. informat=$1. label="担保方式",
cats(_col12) as stermsfreq format=$2. informat=$2. label="还款频率",
cats(_col13) as imonthduration format=$3. informat=$3. label="还款月数",
cats(_col14) as imonthunpaid format=$3. informat=$3. label="剩余还款月数",
cats(_col15) as streatypaydue format=$3. informat=$3. label="协定还款期数",
_col16 as streatypayamount format=best12. informat=best12. label="协定期还款额",
cats(_col17) as dbillingdate format=$8. informat=$8. label="结算/应还款日期",
cats(_col18) as drecentpaydate format=$8. informat=$8. label="最近一次实际还款日期",
_col19 as ischeduledamount format=best12. informat=best12. label="本月应还款金额",
_col20 as iactualpayamount format=best12. informat=best12. label="本月实际还款金额",
_col21 as ibalance format=best12. informat=best12. label="余额",
cats(_col22) as icurtermspastdue format=$2. informat=$2. label="当前逾期期数",
_col23 as iamountpastdue format=best12. informat=best12. label="当前逾期总额",
_col24 as Iamountpastdue30 format=best12. informat=best12. label="逾期31-60天未归还贷款本金",
_col25 as Iamountpastdue60 format=best12. informat=best12. label="逾期61-90天未归还贷款本金",
_col26 as Iamountpastdue90 format=best12. informat=best12. label="逾期90-180天未归还贷款本金",
_col27 as Iamountpastdue180 format=best12. informat=best12. label="逾期180天以上未归还贷款本金",
cats(_col28) as itermspastdue format=$3. informat=$3. label="累计逾期期数",
cats(_col29) as imaxtermspastdue format=$2. informat=$2. label="最高逾期期数",
cats(_col30) as iclass5stat format=$1. informat=$1. label="五级分类状态",
cats(_col31) as iaccountstat format=$1. informat=$1. label="账户状态",
cats(_col32) as Spaystat24month format=$24. informat=$24. label="24个月账户还款状态",
cats(_col33) as iinfoindicator format=$1. informat=$1.  label="账户拥有者信息提示",
cats(_col34) as sname format=$30. informat=$30. label="姓名",
cats(_col35) as scerttype  format=$1. informat=$1. label="证件类型",
cats(_col36) as scertno format=$18. informat=$18. label="证件号码",
/*cats(_col37) as skeepcolumn format=$30. informat=$30. label="预留字段",*/
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out.;
quit;
%mend;

%macro format_H(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14.informat=$14. label="网贷机构代码",
cats(_col1) as sloancompactcode format=$60.informat=$60. label='贷款合同号码', 
cats(_col2) as dloancompactopened format=$8.informat=$8. label='贷款合同生效日期',
cats(_col3) as dloancompactclosed format=$8.informat=$8. label='贷款合同终止日期',
cats(_col4) as scurrency format=$3.informat=$3. label='币种',
cats(_col5) as iloancompactamount format=$10.informat=$10. label='贷款合同金额',
cats(_col6) as icompactstat format=$1.informat=$1. label='合同状态',
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;

%macro format_E(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as saccount format=$40. informat=$40. label="贷款业务号码",
cats(_col2) as sguaranteepersonname format=$30. informat=$30. label="担保人姓名",
cats(_col3) as sguaranteepersoncerttype format=$1. informat=$1. label="担保人证件类型",
cats(_col4) as sguaranteepersoncertno format=$18. informat=$18. label="担保人证件号码",
cats(_col5) as iguaranteesum format=$10. informat=$10. label="担保金额",
cats(_col6) as iguaranteestat format=$1. informat=$1. label="担保状态",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;

%macro format_T(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as saccount format=$40. informat=$40. label="贷款业务号码",
cats(_col2) as sinvestorpersonname format=$30. informat=$30. label="投资人姓名",
cats(_col3) as sinvestorpersoncerttype format=$1. informat=$1. label="投资人证件类型",
cats(_col4) as sinvestorpersoncertno format=$18. informat=$18. label="投资人证件号码",
cats(_col5) as iinvestorsum format=$10. informat=$10. label="投资金额",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;
%macro format_G(out);
proc sql noprint;
create table &out._f as
select 
cats(_col0) as sorgcode  format=$14. informat=$14. label="网贷机构代码",
cats(_col1) as sname format=$30. informat=$30. label="姓名",
cats(_col2) as scerttype format=$1. informat=$1. label="证件类型",
cats(_col3) as scertno format=$18. informat=$18. label="证件号码",
cats(_col4) as saccount format=$40. informat=$40. label="贷款业务号码",
cats(_col5) as speculiartradetype format=$1. informat=$1. label="特殊交易类型",
cats(_col6) as doccurdate format=$8. informat=$8. label="发生日期",
cats(_col7) as ichangemonth format=$4. informat=$4. label="变更月数",
cats(_col8) as ioccursum format=$10. informat=$10. label="发生金额",
cats(_col9) as sdetailinfo format=$200. informat=$200. label="明细信息",
uploaddate format=$18. informat=$18. label="更新日期",
filename format=$30. informat=$30. label="文件名称"
from &out;
quit;
%mend;


