/*编号:1*/
%macro GetFileAndSubDirInfoInDir(InDirPath,Filter,TargetTable,OutFilePath,Expand);
/**********************************************************************/
/* 此宏用于获得目标文件夹下所有文件及子文件夹的信息，并将此信息保存至 */
/* SAS表格或导出至txt文件中。其中，InDirPath是指定的目标文件夹路径，  */
/* 路径最后要加上\；Filter是文件过滤设置，支持*和?通配符，若需要导出  */
/* 所有文件列表，可以设置为空；TargetTable是保存文件信息的SAS表格，若 */
/* 不需要生成，可以设为空；OutFilePath是导出txt文件的路径，若不需要导 */
/* 出，可以设为空；Expand是标记变量，=Yes表示展开所有文件夹，列表最后 */
/* 包含文件及其所处文件夹信息，=NO表示只列出目标文件夹下第一层文件和  */
/* 文件夹的信息。                                                     */
/*                                                                    */
/* 最终得到的是含有目标文件夹下所有文件及子文件夹信息的SAS表格和存于  */
/* 指定路径的txt文件。                                                */
/*                                                                    */
/* 注意运行此宏可能会产生数量不等的错误信息，这是由于利用DIR命令得到  */
/* 结果表格纵向格式不一致引起的，但不会影响结果的正确性。             */
/*                                                                    */
/**********************************************************************/
/* 确保InDirPath后接\符号 */
%if %SYSFUNC(FIND(%SYSFUNC(REVERSE(&InDirPath)),\)) NE 1 %then %let InDirPath=&InDirPath.\;
/* 关闭显示LOG信息 */
options nosource nonotes errors=0;
/* 第一步：首先将InDirPath文件夹下所有文件的信息导出至OutFilePath文件中 */
/* 情形1：参数OutFilePath为完整文件路径情形 */
%if %SYSFUNC(FIND(&OutFilePath,%STR(.))) NE 0 %then %do;
/* 情形1-1：展开所有文件夹 */
%if %UPCASE(&Expand) EQ YES %then %do;
  %ChkFile(&OutFilePath);
  options noxwait xsync;
  x "dir &InDirPath.&Filter /s /a > &OutFilePath";
%end;
/* 情形1-2：不展开文件夹，只包含第一层子文件夹和文件的信息 */
%else %if %UPCASE(&Expand) EQ NO %then %do;
  %ChkFile(&OutFilePath);
  options noxwait xsync;
  x "dir &InDirPath.&Filter > &OutFilePath";
%end;
/* 情形1-3：错误输入Expand参数情形 */
%else %do;
  %put ERROR: The last parameter should be Yes or No, case insensitive and without quotes.;
  %goto exit;
%end;
%end;
/* 情形2：参数OutFilePath为空情形 */
%else %if %UPCASE(&OutFilePath) EQ %STR() %then %do;
/* 情形2-1：展开所有文件夹 */
%if %UPCASE(&Expand) EQ YES %then %do;
  options noxwait xsync;
  x "dir &InDirPath.&Filter /s /a > d:\GFASDIID_temp.txt";
  %let OutFilePath=d:\GFASDIID_temp.txt;
%end;
/* 情形2-2：不展开文件夹，只包含第一层子文件夹和文件的信息 */
%else %if %UPCASE(&Expand) EQ NO %then %do;
  options noxwait xsync;
  x "dir &InDirPath.&Filter > d:\GFASDIID_temp.txt";
  %let OutFilePath=d:\GFASDIID_temp.txt;
%end;
/* 情形2-3：错误输入Expand参数情形 */
%else %do;
  %put ERROR: The Expand should be Yes or No, case insensitive and without quotes.;
  %goto exit;
%end;
%end;
/* 情形3：错误输入OutFilePath参数情形 */
%else %do;
%put ERROR: The OutFilePath should contain the full path of directory, including filename and filename extension.;
%goto exit;
%end;
/* 第二步：接着将OutFilePath文件的信息导入SAS数据表中 */
/* 需要生成SAS数据表情形 */
%if %UPCASE(&TargetTable) NE %STR() %then %do;
/* 情形1：展开所有文件夹，此时从第4行开始读 */
%if %UPCASE(&Expand) EQ YES %then %do;
  data GFASDIID_temp;
   infile "&OutFilePath." firstobs=4 truncover;
   input DataString $ 1-1000 @; /* 读取的第一个变量，变量长度为10，@表示光标不下移，继续读取此行 */
   input @1 Date YYMMDD10. @13 Time TIME. @19 Bytes_temp $17. @37 FileName $64.;
   if (FIND(DataString,'<DIR>') EQ 0) AND (FIND(DataString,'\') NE 0 OR Date NE .);
   format Date YYMMDD10. Time HHMM.;
  run;
  data &TargetTable(drop=DataString Bytes_temp);
   retain Date Time Bytes FileName DirPath;
   set GFASDIID_temp;
   Bytes=INPUT(Bytes_temp,COMMA17.);
   format Bytes COMMA17.;
   if FIND(DataString,'\') NE 0 then DirPath=kCOMPRESS(DataString,'的目录');
   if Date NE .;
  run;
%end;
/* 情形2：不展开文件夹，只包含第一层子文件夹和文件的信息，此时从第8行开始读 */
%else %do;
  data GFASDIID_temp(drop=DataString);
   infile "&OutFilePath" firstobs=8 truncover;
   input DataString $ 1-1000 @; /* 读取的第一个变量，变量长度为10，@表示光标不下移，继续读取此行 */
   input @1 Date YYMMDD10. @13 Time TIME. @19 Bytes_temp $17. @37 FileName $64.;
   if Date NE .;
   format Date YYMMDD10. Time HHMM.;
  run;
  data &TargetTable(drop=Bytes_temp);
   retain FileName Dir Bytes Date Time;
   set GFASDIID_temp;
   Bytes=INPUT(Bytes_temp,COMMA17.);
   format Bytes COMMA17.;
   if Bytes EQ . then Dir='<DIR>';
   else Dir='';
  run;
%end;
%end;
/* 如需要在SAS的Output窗口中打印文件列表，请取消如下注释 */
/*proc print data=&TargetTable;*/
/*title1 "Files identified through saved file";*/
/*run;*/
/* 删除不必要的表格 */
proc delete data=GFASDIID_temp;
run;
/* 恢复显示LOG信息 */
options source notes errors=5;
%if &OutFilePath=d:\GFASDIID_temp.txt %then x "erase d:\GFASDIID_temp.txt";
%exit:
%mend;

/*%macro Demo();*/
/*%let InDirPath=e:\Works\;*/
/*%let Filter=*.sas;  /* 文件过滤设置，若需要导出所有文件列表，则设置为空即可，即Filter=; */*/
/*%let TargetTable=FileList;  /* 若不需要生成包含文件列表的SAS表格，则设为空，大小写不敏感 */*/
/*%let OutFilePath=;  /* 若不需要导出文件列表txt文件，则设为空，大小写不敏感 */*/
/*%let Expand=Yes;  /* =Yes表示展开所有文件夹，列表最后包含文件及其所处文件夹信息，否则=No，大小写不敏感 */*/
/*%GetFileAndSubDirInfoInDir(&InDirPath,&Filter,&TargetTable,&OutFilePath,&Expand);*/
/*%mend;*/


/*编号：2*/
%macro PrxChange(InputString,PrxString);

/**********************************************************************/
/* 此宏利用正则表达式的方法替换原始字符串的匹配子串为目标子串。其中， */
/* InputString是原始字符串；PrxString是指定子串的正则表达式，注意正则 */
/* 表达式要用/.../符号括起来。                                        */
/*                                                                    */
/* 最终原始字符串中的匹配子串替换为目标子串。注意用于替换子串的正则表 */
/* 达式形如：s/SourceString/TargetString/                             */
/*                                                                    */
/*                                      Created on 2012.8.6           */
/*                                      Modified on 2012.8.6          */
/**********************************************************************/

%local PrxStringID RegRt;

%let RegRt=0;
%let PrxStringID=%SYSFUNC(PRXPARSE(&PrxString));

%if &PrxStringID GT 0 %then %do;
        %let RegRt=%SYSFUNC(PRXCHANGE(&PrxStringID, -1, &InputString));                /* -1表示全部替换 */
%end;

%syscall PrxFree(PrxStringID);
%str(&RegRt)                /* 最后不需要加分号 */

%mend;


/*%macro Demo();*/
/**/
/*/* replace the matching string to target string */*/
/*%let zip=%PrxChange(InputString=Jones Fred,PrxString=s/(\w+) (\w+)/$2 $1/);*/
/*%put &zip;*/
/**/
/*%mend;*/

/*编号：3*/
%macro PrxMatch(InputString,PrxString);

/**********************************************************************/
/* 此宏利用正则表达式的方法检索字符串中是否包含有指定的子串。其中，   */
/* InputString是原始字符串；PrxString是指定子串的正则表达式，注意正则 */
/* 表达式要用/.../符号括起来。                                        */
/*                                                                    */
/* 最终若匹配成功，则返回1，否则返回0。                               */
/*                                                                    */
/* 另外，此宏选取自"Using PRX to Search and Replace Patterns in SAS   */
/* Programming"，并稍加改动。                                         */
/*                                                                    */
/*                                      Created on 2012.4.9           */
/*                                      Modified on 2012.4.9          */
/**********************************************************************/

%local PrxStringid regrt;

%let regrt=0;
%let PrxStringid=%sysfunc(prxparse(&PrxString));

%if &PrxStringid GT 0 %then %do;
        %let regrt=%sysfunc(prxmatch(&PrxStringid, &InputString));
%end;

%syscall prxfree(PrxStringid);
%str(&reg;rt)               /* 最后不需要加分号 */

%mend;


/*%macro Demo();*/
/**/
/*/* test whether there is a match or not */*/
/*%let zip=%PrxMatch(InputString=34567-2345,PrxString=/\d{5}-\d{4}/);*/
/*%put &zip;*/
/**/
/*%mend;*/

/*编号：4*/
%macro GetStatsForTable(SourceTable,TargetTable,ByFactors,InputVar,InputVarType,OutputVarType,Weight,Statistic);

/**********************************************************************/
/* 此宏计算所选变量的统计指标。其中SourceTable是含有所选变量的原始表 */
/* 格；TargetTable是结果表格；ByFactors是对统计量进行分组研究的分组变 */
/* 量，没有分组变量时可设置为空；InputVar是进行统计的目标变量，若需要 */
/* 统计全部变量、全部数值变量和全部字符变量，可分别设为_ALL_、 */
/* _NUMERIC_和_CHARACTER_；InputVarType是目标变量的类型，当Statistic= */
/* GMEAN时必须设置，=P表示价格变量，=R表示收益率变量；OutputVarType是 */
/* 输出变量的类型，=Origin表示不作处理，即输出变量名称等于目标变量的 */
/* 名称，并用_STAT_变量区分不同的统计量，=Suffix表示输出变量用不同的 */
/* 统计量作为后缀；Weight是权重变量；Statistic是指定的统计量，=All时 */
/* 同时计算N|MIN|MAX|MEAN|STD，也可以单独设置，可以设置的统计量如下所 */
/* 示： */
/* */
/* - Descriptive statistics keyword */
/* CSS RANGE CV SKEW KURT STD LCLM STDERR MAX SUM MEAN GMEAN(Geo- */
/* metric Mean) GSUM(Continued Product) SUMWGT MIN */
/* UCLM MODE USS N VAR SVAR(Semi-Variance) NMISS */
/* - Quantile statistics keyword */
/* MEDIAN P1 P5 P10 P25 P50 P75 P90 P95 P99 Q1 Q3 QRANGE */
/* - Hypothesis testing keyword */
/* PRT T */
/* */
/* 最终得到的是含有统计结果的结果表格&TargetTable。 */
/* */
/* Created on 2012.12.25 */
/* Modified on 2013.4.28 */
/**********************************************************************/

/* 检查TargetTable的存在性，若不存在则设为&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* 检查ByFactors的存在性 */
%if &ByFactors NE %STR() %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&ByFactors,FlagVarExists=GSFT_FlagVarExists1);

%if %SYSFUNC(FIND(&GSFT_FlagVarExists1,0)) NE 0 %then %do;
%put ERROR: The ByFactors "%SCAN(&ByFactors,%SYSFUNC(FIND(&GSFT_FlagVarExists1,0)))" does not exist in SourceTable, please check it again.;
%goto exit;
%end;

/* 逗号分隔的ByFactors_Comma用于SQL语句 */
%local ByFactors_Comma;

%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
%let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %do;
%let ByFactors_Comma=&ByFactors;
%end;
%end;


/* 检查InputVar的存在性 */
%if %SYSFUNC(FIND(&InputVar,%STR(:))) NE 0 %then %do;
%GetVarListForTable(SourceTable=&SourceTable,
TargetTable=,
OutputVar=GSFT_InputVar,
VarType=&InputVar);

%let InputVar=&GSFT_InputVar;
%end;

%if %UPCASE(&InputVar) NE _ALL_ AND %UPCASE(&InputVar) NE _NUMERIC_ AND %UPCASE(&InputVar) NE _CHARACTER_ %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=GSFT_FlagVarExists2);

%if %SYSFUNC(FIND(&GSFT_FlagVarExists2,0)) NE 0 %then %do;
%put ERROR: The InputVar %SCAN(&InputVar,%SYSFUNC(FIND(&GSFT_FlagVarExists2,0))) does not exist in SourceTable, please check it again.;
%goto exit;
%end;
%end;

/* 检查InputVarType的合法性 */
%if %UPCASE(&Statistic) EQ GMEAN %then %do;
%if (%UPCASE(&InputVarType) NE P) AND (%UPCASE(&InputVarType) NE R) %then %do;
%put ERROR: The InputVarType should be P or R, case insensitive and without quotes.;
%goto exit;
%end;
%end;

/* 拆分InputVar */
%SeparateString(InputString=&InputVar,OutputString=GSFT_InputVar);

/* 检查OutputVarType的合法性 */
%if &OutputVarType EQ %STR() %then %let OutputVarType=Origin;

%if (%UPCASE(&OutputVarType) NE ORIGIN) AND (%UPCASE(&OutputVarType) NE SUFFIX) %then %do;
%put ERROR: The OutputVarType should be Origin or Suffix, case insensitive and without quotes.;
%goto exit;
%end;

/* 检查Weight的唯一性和存在性 */
%if %SYSFUNC(FIND(&Weight,%STR( ))) NE 0 %then %do;
%put ERROR: There should be only one Weight, please check it again.;
%goto exit;
%end;

%if &Weight NE %STR() %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&Weight,FlagVarExists=GSFT_FlagVarExists3);

%if %SYSFUNC(FIND(&GSFT_FlagVarExists3,0)) NE 0 %then %do;
%put ERROR: The Weight "&Weight" does not exist in SourceTable, please check it again.;
%goto exit;
%end;
%end;

/* 检查Statistic的唯一性 */
%if %SYSFUNC(FIND(&Statistic,%STR( ))) NE 0 %then %do;
%put ERROR: There should be only one Statistic, please check it again.;
%goto exit;
%end;

/* 确认指定的统计量，N|MIN|MAX|MEAN|STD为StatGroup1，其他非特殊统计量为StatGroup2，SVAR为Group3，GMEAN为Group4 */
%let Statistic=%UPCASE(&Statistic);
%let GSFT_StatGroup1=%PrxMatch(InputString=&Statistic,PrxString=/((?<!\w)N(?!\w))|(MIN)|(MAX)|((?<!\w)MEAN(?!\w))|(STD)|(ALL)/);
/* 将正则表达式GSFT_StatGroup2分拆成两段，以免报错 */
%let GSFT_StatGroup2a=%PrxMatch(InputString=&Statistic,PrxString=/(CSS)|(RANGE)|(CV)|(SKEW)|(KURT)|(LCLM)|(STDERR)|((?<!\w)SUM(?!\w))|(SUMWGT)|(UCLM)|(MODE)|(USS)|((?<!\w)VAR(?!\w))|(NMISS)|(MEDIAN)/);
%let GSFT_StatGroup2b=%PrxMatch(InputString=&Statistic,PrxString=/(Q1)|(Q3)|(P1(?!0))|(P5)|(P10)|(P25)|(P50)|(P75)|(P90)|(P95)|(P99)|(QRANGE)|(PRT)|((?<!\w)T(?!\w))/);
%let GSFT_StatGroup3=%PrxMatch(InputString=&Statistic,PrxString=/(SVAR)/);
%let GSFT_StatGroup4=%PrxMatch(InputString=&Statistic,PrxString=/(GMEAN|GSUM)/);

%if &GSFT_StatGroup1 EQ 0 AND &GSFT_StatGroup2a EQ 0 AND &GSFT_StatGroup2b EQ 0 AND &GSFT_StatGroup3 EQ 0 AND &GSFT_StatGroup4 EQ 0 %then %do;
%put ERROR: The Statistic should be assigned properly, please check it again.;
%goto exit;
%end;

/* 开始进行计算 */
/* 第一步：得到统计量 */
/* 情形一：计算第一组统计量 */
%if &GSFT_StatGroup1 NE 0 %then %do;
%if &ByFactors NE %STR() %then %do;
proc sort data=&SourceTable;
by &ByFactors;
run;

proc means data=&SourceTable noprint;
by &ByFactors;
var &InputVar;
weight &Weight;
output out=GSFT_temp;
run;
%end;
%else %do;
proc means data=&SourceTable noprint;
var &InputVar;
weight &Weight;
output out=GSFT_temp;
run;
%end;

data &TargetTable;
set GSFT_temp;
%if &Statistic NE ALL %then %do;
if _stat_="&Statistic." then output &TargetTable;
%end;
run;
%end;
/* 情形二：计算第二组统计量 */
%else %if &GSFT_StatGroup2a NE 0 OR &GSFT_StatGroup2b NE 0 %then %do;
%if &ByFactors NE %STR() %then %do;
proc sort data=&SourceTable;
by &ByFactors;
run;

proc means data=&SourceTable noprint;
by &ByFactors;
var &InputVar;
weight &Weight;
output out=GSFT_temp &Statistic.=;
run;

data &TargetTable;
retain &ByFactors _TYPE_ _FREQ_ _STAT_ &InputVar;
set GSFT_temp;
_STAT_="&Statistic.";
run;
%end;
%else %do;
proc means data=&SourceTable noprint;
var &InputVar;
weight &Weight;
output out=GSFT_temp &Statistic.=;
run;

data &TargetTable;
retain &ByFactors _TYPE_ _FREQ_ _STAT_ &InputVar;
set GSFT_temp;
_STAT_="&Statistic.";
run;
%end;
%end;
/* 情形三：计算第三组统计量，SVAR，即半方差 */
%else %if &GSFT_StatGroup3 NE 0 %then %do;
/* 逗号分隔的ByFactors_Comma用于SQL语句 */
%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
%let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %let ByFactors_Comma=&ByFactors;

/* 第一步：计算分组均值 */
proc sql noprint;
create table GSFT_Mean as
select *,Count(*) as _FREQ_,
%do GSFT_i=1 %to &GSFT_InputVar_Num;
(mean(&&GSFT_InputVar_Var&GSFT_i.)) as &&GSFT_InputVar_Var&GSFT_i.._Mean
%if &GSFT_i NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
from &SourceTable
%if &ByFactors NE %STR() %then %do;
group by &ByFactors_Comma
%end;
;
quit;

/* 第二步：计算分组半离差平方 */
data GSFT_SqrDev;
set GSFT_Mean;
%do GSFT_j=1 %to &GSFT_InputVar_Num;
if &&GSFT_InputVar_Var&GSFT_j LT &&GSFT_InputVar_Var&GSFT_j.._Mean then &&GSFT_InputVar_Var&GSFT_j.._SqrDev=(&&GSFT_InputVar_Var&GSFT_j..-&&GSFT_InputVar_Var&GSFT_j.._Mean)**2;
else &&GSFT_InputVar_Var&GSFT_j.._SqrDev=0;
%end;
run;

/* 第三步：计算分组半方差 */
proc sql noprint;
create table &TargetTable as
select distinct
%if &ByFactors NE %STR() %then %do;
&ByFactors_Comma,
%end;
_FREQ_,
%do GSFT_k=1 %to &GSFT_InputVar_Num;
sum(&&GSFT_InputVar_Var&GSFT_k.._SqrDev)/_FREQ_ as &&GSFT_InputVar_Var&GSFT_k
%if &GSFT_k NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
from GSFT_SqrDev
%if &ByFactors NE %STR() %then %do;
group by &ByFactors_Comma
%end;
;
quit;

data &TargetTable;
retain &ByFactors _TYPE_ _FREQ_ _STAT_ &InputVar;
set &TargetTable;
_TYPE_=0;
_STAT_='SVAR';
run;
%end;
/* 情形四：计算第四组统计量，GMEAN（几何平均值）和GSUM（连乘积） */
%else %if &GSFT_StatGroup4 NE 0 %then %do;
%if %UPCASE(%SUBSTR(&InputVarType,1,1)) EQ P %then %do; /* 仅对InputVarType的首字母进行判断，P可代表Price/PNL */
proc sql noprint;
create table &TargetTable as
select distinct
%if &ByFactors NE %STR() %then %do;
&ByFactors_Comma,
%end;
%if %UPCASE(&Statistic) EQ GMEAN %then %do;
%do GSFT_i=1 %to &GSFT_InputVar_Num;
(exp(sum(log(&&GSFT_InputVar_Var&GSFT_i))))**(1/COUNT(*)) as &&GSFT_InputVar_Var&GSFT_i
%if &GSFT_i NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
%end;
%else %if %UPCASE(&Statistic) EQ GSUM %then %do;
%do GSFT_j=1 %to &GSFT_InputVar_Num;
(exp(sum(log(&&GSFT_InputVar_Var&GSFT_j)))) as &&GSFT_InputVar_Var&GSFT_j
%if &GSFT_j NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
%end;
from &SourceTable
%if &ByFactors NE %STR() %then %do;
group by &ByFactors_Comma
%end;
;
quit;
%end;
%else %if %UPCASE(%SUBSTR(&InputVarType,1,1)) EQ R %then %do;
proc sql noprint;
create table &TargetTable as
select distinct
%if &ByFactors NE %STR() %then %do;
&ByFactors_Comma,
%end;
%if %UPCASE(&Statistic) EQ GMEAN %then %do;
%do GSFT_i=1 %to &GSFT_InputVar_Num;
(exp(sum(log(1+&&GSFT_InputVar_Var&GSFT_i))))**(1/COUNT(*))-1 as &&GSFT_InputVar_Var&GSFT_i
%if &GSFT_i NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
%end;
%else %if %UPCASE(&Statistic) EQ GSUM %then %do;
%do GSFT_j=1 %to &GSFT_InputVar_Num;
exp(sum(log(1+&&GSFT_InputVar_Var&GSFT_j)))-1 as &&GSFT_InputVar_Var&GSFT_j
%if &GSFT_j NE &GSFT_InputVar_Num %then %do;
,
%end;
%end;
%end;
from &SourceTable
%if &ByFactors NE %STR() %then %do;
group by &ByFactors_Comma
%end;
;
quit;
%end;
%else %do;
%put ERROR: The parameter InputVarType should be P or R, case insensitive and without quotes.;
%goto exit;
%end;

data &TargetTable;
retain &ByFactors _TYPE_ _FREQ_ _STAT_ &InputVar;
set &TargetTable;
_TYPE_=0;
%if %UPCASE(&Statistic) EQ GMEAN %then %do;
_STAT_='GMEAN';
%end;
%if %UPCASE(&Statistic) EQ GSUM %then %do;
_STAT_='GSUM';
%end;
run;
%end;

/* 第二步：按要求输出表格 */
%if %UPCASE(&OutputVarType) EQ SUFFIX %then %do;
proc sql noprint;
select distinct _STAT_ into :GSFT_StatString separated by ' '
from &TargetTable;
quit;

%SeparateString(InputString=&GSFT_StatString,OutputString=GSFT_StatString);

data %do GSFT_m=1 %to &GSFT_StatString_Num;
GSFT_Output_&&GSFT_StatString_Var&GSFT_m(rename=(
%do GSFT_n=1 %to &GSFT_InputVar_Num;
&&GSFT_InputVar_Var&GSFT_n..=&&GSFT_InputVar_Var&GSFT_n.._&&GSFT_StatString_Var&GSFT_m
%end;
))
%end;
;
set &TargetTable;
%do GSFT_o=1 %to &GSFT_StatString_Num;
if _STAT_ EQ "&&GSFT_StatString_Var&GSFT_o" then output GSFT_Output_&&GSFT_StatString_Var&GSFT_o;
%end;
run;

data &TargetTable(drop=_STAT_);
merge %do GSFT_p=1 %to &GSFT_StatString_Num;
&&GSFT_Output_&&GSFT_StatString_Var&GSFT_p
%end;
;
by &ByFactors;
run;
%end;

/* 删除不必要的表格 */
proc datasets lib=work nolist;
delete GSFT_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=NavOfFund;*/
/*%let TargetTable=NavOfFund_GMean;*/
/*%let ByFactors=Fund_Code; /* 可设置为多个，用空格分隔 */*/
/*%let InputVar=Adj_NAV Unit_NAV;*/
/*%let InputVarType=; /* 当Statistic=GMEAN时必须设置，=P表示价格变量，=R表示收益率变量 */*/
/*%let OutputVarType=Suffix; /* 输出变量的类型，=Origin表示不作处理，=Suffix表示输出变量用不同的统计量作为后缀 */*/
/*%let Weight=; /* 仅为一个变量 */*/
/*%let Statistic=All; /* 仅为一个统计量 */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*/* 计算几何平均收益率的例子，且InputVar变量为价格变量 */*/
/*%let SourceTable=ReturnOfFund_Dy;*/
/*%let TargetTable=ReturnOfFund_GMean;*/
/*%let ByFactors=Fund_Code; /* 可设置为多个，用空格分隔 */*/
/*%let InputVar=Adj_NAV;*/
/*%let InputVarType=P; /* 当Statistic=GMEAN时必须设置，=P表示价格变量，=R表示收益率变量 */*/
/*%let OutputVarType=; /* 输出变量的类型，=Origin表示不作处理，=Suffix表示输出变量用不同的统计量作为后缀 */*/
/*%let Weight=; /* 仅为一个变量 */*/
/*%let Statistic=GMEAN; /* 仅为一个统计量 */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*/* 计算几何连乘积的例子，且InputVar变量为收益率变量 */*/
/*%let SourceTable=GARFP_AbnRetOfPort;*/
/*%let TargetTable=GARFP_AbnRetOfPort_GSUM;*/
/*%let ByFactors=Port_Code End_Yr End_Mt; /* 可设置为多个，用空格分隔 */*/
/*%let InputVar=Ret_Dy Ret_Bm AbnRet_Dy AbnRetRatio_Dy;*/
/*%let InputVarType=R; /* 当Statistic=GMEAN时必须设置，=P表示价格变量，=R表示收益率变量 */*/
/*%let OutputVarType=; /* 输出变量的类型，=Origin表示不作处理，=Suffix表示输出变量用不同的统计量作为后缀 */*/
/*%let Weight=; /* 仅为一个变量 */*/
/*%let Statistic=GSUM; /* 仅为一个统计量 */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*%mend;*/

/*编号:5*/
%macro GetCountForSeq(SourceTable,TargetTable,ByFactors,InputVar,OutputVar);

/**********************************************************************/
/* 此宏的作用是计算某数据表中指定变量的重复次数，即连续出现同一值的次 */
/* 数。其中，SourceTable是原始表格；TargetTable是结果表格；ByFactors  */
/* 是分组变量；InputVar是目标变量，可设置为多个，用空格分隔；Output_  */
/* Var是结果变量，其值为该观测值在序列中重复的次数，若不指定，则为原  */
/* 目标变量后加后缀_Cnt。注意，在运行本宏之前需要将原始表格进行合适的 */
/* 排序。                                                             */
/*                                                                    */
/* 最终得到包含原数据表中指定变量的重复次数的结果表格。               */
/*                                                                    */
/*                                      Created on 2012.12.21         */
/*                                      Modified on 2013.3.20         */
/**********************************************************************/

/* 检查TargetTable的存在性，若不存在则设为&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* 检查ByFactors的存在性 */
%if &ByFactors NE %STR() %then %do;
        %ChkVar(SourceTable=&SourceTable,InputVar=&ByFactors,FlagVarExists=GCFS_FlagVarExists1);

        %if %SYSFUNC(FIND(&GCFS_FlagVarExists1,0)) NE 0 %then %do;
                %put ERROR: The ByFactors "%SCAN(&ByFactors,%SYSFUNC(FIND(&GCFS_FlagVarExists1,0)))" does not exist in SourceTable, please check it again.;
                %goto exit;
        %end;
%end;

/* 检查InputVar的存在性 */
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=GCFS_FlagVarExists2);

%if %SYSFUNC(FIND(&GCFS_FlagVarExists2,0)) NE 0 %then %do;
        %put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&GCFS_FlagVarExists2,0)))" does not exist in SourceTable, please check it again.;
        %goto exit;
%end;

/* 拆分InputVar */
%SeparateString(InputString=&InputVar,OutputString=GCFS_InputVar);

/* 检查OutputVar的合法性 */
%if &OutputVar NE %STR() AND %SYSFUNC(COUNT(&InputVar,%STR( ))) NE %SYSFUNC(COUNT(&OutputVar,%STR( ))) %then %do;
        %put ERROR: The number of InputVar and OutputVar should be equal, please check it again.;
        %goto exit;
%end;

/* 若OutputVar为空，则设置为InputVar后加_Cnt后缀 */
%if &OutputVar EQ %STR() %then %do;
        %let OutputVar=%SYSFUNC(TRANWRD(&InputVar,%STR( ),_Cnt%STR( )))_Cnt;
%end;

/* 拆分OutputVar */
%SeparateString(InputString=&OutputVar,OutputString=GCFS_OutputVar);

/* 开始进行计算 */
/* 第一步：生成新的分组变量 */
data &TargetTable;
        set &SourceTable;
        GCFS_OrderVar=_N_;
run;

%do GCFS_i=1 %to &GCFS_InputVar_Num;
        data &TargetTable;
                set &TargetTable;
                retain GCFS_VarNo_&GCFS_i GCFS_ByFactors_&GCFS_i;
                by &ByFactors &&GCFS_InputVar_Var&GCFS_i NOTSORTED;
                if first.&&GCFS_InputVar_Var&GCFS_i then GCFS_VarNo_&GCFS_i.=1;
                else GCFS_VarNo_&GCFS_i.+1;
                if _N_=1 and first.&&GCFS_InputVar_Var&GCFS_i.=1 then GCFS_ByFactors_&GCFS_i.=1;
                else if first.&&GCFS_InputVar_Var&GCFS_i then GCFS_ByFactors_&GCFS_i.+1;
        run;
%end;

/* 第二步：得到计数变量 */
%do GCFS_j=1 %to &GCFS_InputVar_Num;
        proc sort data=&TargetTable;
                by GCFS_ByFactors_&GCFS_j DESCENDING GCFS_VarNo_&GCFS_j.;
        run;

        data &TargetTable(drop=GCFS_ByFactors_&GCFS_j GCFS_VarNo_&GCFS_j.);
                set &TargetTable;
                by GCFS_ByFactors_&GCFS_j;
                retain &&GCFS_OutputVar_Var&GCFS_j;
                if first.GCFS_ByFactors_&GCFS_j then &&GCFS_OutputVar_Var&GCFS_j=GCFS_VarNo_&GCFS_j;
        run;
%end;

/* 删除临时生成的OrderVar */
proc sort data=&TargetTable out=&TargetTable(drop=GCFS_OrderVar);
        by GCFS_OrderVar;
run;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=RankOfStk;*/
/*%let TargetTable=RankOfStk1;*/
/*%let ByFactors=;*/
/*%let InputVar=PE_Rank;                /* 需要处理的目标变量，可设置为多个，用空格分隔 */*/
/*%let OutputVar=;*/
/*%GetCountForSeq(&SourceTable,&TargetTable,&ByFactors,&InputVar,&OutputVar);*/
/**/
/*%mend;*/

/*编号：6*/
%macro ChkDummyVar(SourceTable,InputVar,FlagIsDummyVar);

/**********************************************************************/
/* 此宏的作用是检查某数据表中的指定变量是否为虚拟变量，即取值只能为0  */
/* 或1。其中，SourceTable是原始表格；InputVar是指定的变量，若为多个变 */
/* 量，请用空格分隔；FlagIsDummyVar是标记宏变量名称，=1表示变量为虚拟 */
/* 变量，否则=0，若有多个InputVar变量，则不同位置上的1或0代表相应的变 */
/* 量是否是虚拟变量。注意，若某变量除含有0或1之外，还含有缺失值，则仍 */
/* 然认为其为虚拟变量。                                               */
/*                                                                    */
/* 最终得到的是宏变量&FlagIsDummyVar，若该数据表中指定变量为虚拟变量，*/
/* 则&FlagIsDummyVar=1，否则=0，若为多个变量，则不同位置上的1或0代表  */
/* 相应的变量是否为虚拟变量。                                         */
/*                                                                    */
/*                                      Created on 2013.3.30          */
/*                                      Modified on 2013.3.30         */
/**********************************************************************/

%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
        %let CDV_LibName=%UPCASE(%SCAN(&SourceTable,1,.));
        %let CDV_MemName=%UPCASE(%SCAN(&SourceTable,2,.));
%end;
%else %do;
        %let CDV_LibName=WORK;
        %let CDV_MemName=%UPCASE(&SourceTable);
%end;

/* 检查SourceTable的存在性 */
%ChkDataSet(DataSet=&CDV_LibName..&CDV_MemName,FlagDataSetExists=CDV_FlagDataSetExists);

%if &CDV_FlagDataSetExists EQ 0 %then %do;
        %put ERROR: The DataSet &SourceTable does not exist, please check it again.;
        %goto exit;
%end;

/* 检查InputVar的存在性 */
%if %SYSFUNC(FIND(&InputVar,%STR(:))) NE 0 %then %do;
    %GetVarListForTable(SourceTable=&SourceTable,
        TargetTable=,
        OutputVar=CDV_InputVar,
        VarType=&InputVar);

  %let InputVar=&CDV_InputVar;
%end;

%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=CDV_FlagInputVarExists);

%if %SYSFUNC(FIND(&CDV_FlagInputVarExists,0)) NE 0 %then %do;
    %put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&CDV_FlagInputVarExists,0)))" does not exist in SourceTable, please check it again.;
    %goto exit;
%end;

/* 拆分InputVar */
%SeparateString(InputString=&InputVar,OutputString=CDV_InputVar);

/* 开始进行计算 */
%global &FlagIsDummyVar;

%let &FlagIsDummyVar=;

/* 检查InputVar的格式，若为字符型，则一定不是虚拟变量 */
%ChkVarType(SourceTable=&SourceTable,
        InputVar=&InputVar,
        FlagVarType=CDV_FlagInputVarType);

%do CDV_i=1 %to &CDV_InputVar_Num;
        %if %SUBSTR(%UPCASE(&CDV_FlagInputVarType),&CDV_i,1) EQ C %then %do;
                %let &FlagIsDummyVar=&&&FlagIsDummyVar..0;
        %end;
        %else %if %SUBSTR(%UPCASE(&CDV_FlagInputVarType),&CDV_i,1) EQ N %then %do;
                proc sql noprint;
                        select COUNT(&&CDV_InputVar_Var&CDV_i) into :CDV_NumOfNonDummyValue
                                from &SourceTable
                                where &&CDV_InputVar_Var&CDV_i NE 0 AND &&CDV_InputVar_Var&CDV_i NE 1;
                quit;

                %if &CDV_NumOfNonDummyValue GT 0 %then %do;
                        %let &FlagIsDummyVar=&&&FlagIsDummyVar..0;
                %end;
                %else %do;
                        %let &FlagIsDummyVar=&&&FlagIsDummyVar..1;
                %end;
        %end;
%end;

/* 若要显示&FlagIsDummyVar的值，请取消下面的注释 */
/*%put &FlagIsDummyVar=&&&FlagIsDummyVar;*/

%exit；
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Have;*/
/*%let InputVar=a b c d;*/
/*%let FlagIsDummyVar=FlagIsDummyVar1;*/
/*%ChkDummyVar(&SourceTable,&InputVar,&FlagIsDummyVar);*/
/**/
/*%put &FlagIsDummyVar1;*/
/**/
/*%mend;*/

/*编号：7*/
%macro DropEmptyTables(LibName,Filter);

/**********************************************************************/
/* 此宏用于删除指定逻辑库中的空表，也即观测值为零的表格。其中LibName  */
/* 是指定逻辑库名称；Filter是文件过滤设置，=Null时删除全部空表，包含  */
/* _和%等SQL中like子句的通配符时删除指定前后缀的空表，不包含任何通配  */
/* 符时删除指定空表，若指定表不为空则不删除。                         */
/*                                                                    */
/* 最终指定逻辑库下所有符合条件的空表全部被删除。                     */
/*                                                                    */
/*                                      Created on 2011.11.14         */
/*                                      Modified on 2012.4.25         */
/**********************************************************************/

%if &LibName EQ %STR() %then %let LibName=Work;
%if &Filter EQ %STR() %then %let Filter=Null;

%if %UPCASE(&Filter) EQ NULL %then %do;
        proc sql noprint;
                select count(memname) into :DET_EmptyTableNum
                        from SASHELP.Vtable
                        where UPCASE(libname) EQ UPCASE("&LibName") AND nobs EQ 0;
        quit;

        %if &DET_EmptyTableNum EQ 0 %then %do;
                %put NOTE: There is no empty table or dataset in the specified library, therefore none of table is dropped.;
                %goto exit;
        %end;
        %else %do;
                proc sql noprint;
                        select memname into :DET_EmptyTableList separated by ' '
                                from SASHELP.Vtable
                                where UPCASE(libname) EQ UPCASE("&LibName") AND nobs EQ 0;
                quit;
        %end;
%end;
%else %if (%SYSFUNC(FIND(&Filter,_)) NE 0) OR (%SYSFUNC(FIND(&Filter,%)) NE 0) %then %do;
        proc sql noprint;
                select count(memname) into :DET_EmptyTableNum
                        from SASHELP.Vtable
                        where UPCASE(libname) EQ UPCASE("&LibName") AND
                                UPCASE(memname) like UPCASE("&Filter") AND nobs EQ 0;
        quit;

        %if &DET_EmptyTableNum EQ 0 %then %do;
                %put NOTE: There is no empty table or dataset in the specified library, therefore none of table is dropped.;
                %goto exit;
        %end;
        %else %do;
                proc sql noprint;
                        select memname into :DET_EmptyTableList separated by ' '
                                from SASHELP.Vtable
                                where UPCASE(libname) EQ UPCASE("&LibName") AND
                                        UPCASE(memname) like UPCASE("&Filter") AND nobs EQ 0;
                quit;
        %end;
%end;
%else %do;
        proc sql noprint;
                select count(memname) into :DET_EmptyTableNum
                        from SASHELP.Vtable
                        where UPCASE(libname) EQ UPCASE("&LibName") AND
                                UPCASE(memname) EQ UPCASE("&Filter") AND nobs EQ 0;
        quit;

        %if &DET_EmptyTableNum EQ 0 %then %do;
                %put NOTE: There is no empty table or dataset in the specified library, therefore none of table is dropped.;
                %goto exit;
        %end;
        %else %do;
                proc sql noprint;
                        select memname into :DET_EmptyTableList separated by ' '
                                from SASHELP.Vtable
                                where UPCASE(libname) EQ UPCASE("&LibName") AND
                                        UPCASE(memname) EQ UPCASE("&Filter") AND nobs EQ 0;
                quit;
        %end;
%end;

proc sql noprint;
        %do DET_i=1 %to &DET_EmptyTableNum;
                %let DET_Dataset=%SCAN(&DET_EmptyTableList,&DET_i);
                drop table &LibName..&DET_Dataset;
        %end;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let LibName=Work;*/
/*%let Filter="a%";                /* =Null时删除全部空表；包含_和%等SQL中like子句的通配符时删除指定前后缀的空表，注意此时要加双引号；不包含任何通配符时删除指定空表 */*/
/*%DropEmptyTables(&LibName,&Filter);*/
/**/
/*%mend;*/

/*编号:8*/
%macro DeleteMissObs(SourceTable,TargetTable,MissingVar);
/**********************************************************************/
/* 此宏删除原表中指定变量为缺失值的观测。其中SourceTable是原始表格；  */
/* TargetTable是结果表格；MissingVar是可能含有缺失值的变量，=_Numeric_*/
/* 表示选择全部数值型变量，=_Character_表示选择全部字符型变量，=_All_ */
/* 表示选择全部变量，也可以选择多个变量，用空格分隔。                 */
/*                                                                    */
/* 最终结果表格中指定变量为缺失值的观测被删除。                       */
/*                                                                    */
/*                                      Created on 2013.1.10          */
/*                                      Modified on 2013.2.5          */
/**********************************************************************/

/* 检查TargetTable的存在性，若不存在则设为&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* 检查MissingVar的存在性 */
%if %SYSFUNC(FIND(&MissingVar,%STR(:))) NE 0 OR %SYSFUNC(FIND(&MissingVar,%STR(%%))) NE 0 %then %do;
    %GetVarListForTable(SourceTable=&SourceTable,
        TargetTable=,
        OutputVar=DMO_MissingVar,
        VarType=&MissingVar);

  %let MissingVar=&DMO_MissingVar;
%end;

%if (%UPCASE(&MissingVar) NE _NUMERIC_) AND (%UPCASE(&MissingVar) NE _CHARACTER_) AND (%UPCASE(&MissingVar) NE _ALL_) %then %do;
        %ChkVar(SourceTable=&SourceTable,InputVar=&MissingVar,FlagVarExists=DMO_FlagVarExists1);

        %if %SYSFUNC(FIND(&DMO_FlagVarExists1,0)) NE 0 %then %do;
                %put ERROR: The MissingVar "%SCAN(&MissingVar,%SYSFUNC(FIND(&DMO_FlagVarExists1,0)))" does not exist in SourceTable, please check it again.;
                %goto exit;
        %end;
%end;

/* 加引号的MissingVar_Quote用于SQL过程 */
%let MissingVar_Quote=%PrxChange(InputString=&MissingVar,PrxString=s/(\w+)/'$1'/);

/* 开始进行计算 */
%if %UPCASE(&MissingVar) EQ _NUMERIC_ %then %do;
        data &TargetTable(drop=DMO_i);
                set &SourceTable;
                array VarList _NUMERIC_;
                do DMO_i=1 to dim(VarList);
                        if VarList{DMO_i} EQ . then delete;
                end;
        run;
%end;
%else %if %UPCASE(&MissingVar) EQ _CHARACTER_ %then %do;
        data &TargetTable(drop=DMO_i);
                set &SourceTable;
                array VarList _CHARACTER_;
                do DMO_i=1 to dim(VarList);
                        if VarList{DMO_i} EQ '' then delete;
                end;
        run;
%end;
%else %if %UPCASE(&MissingVar) EQ _ALL_ %then %do;
        data &TargetTable(drop=DMO_i DMO_j);
                set &SourceTable;
                array VarList_Num _NUMERIC_;
                array VarList_Char _CHARACTER_;
                do DMO_i=1 to dim(VarList_Num);
                        if VarList_Num{DMO_i} EQ . then delete;
                end;
                do DMO_j=1 to dim(VarList_Char);
                        if VarList_Char{DMO_j} EQ '' then delete;
                end;
        run;
%end;
%else %do;
        %GetVarListForTable(SourceTable=&SourceTable,
                TargetTable=DMO_VarList,
                OutputVar=,
                VarType=_ALL_);

        %let DMO_VarList_Num=;
        %let DMO_VarList_Char=;

        proc sql noprint;
                select name into :DMO_VarList_Num separated by ' '
                        from DMO_VarList
                        where name in (&MissingVar_Quote.) and type EQ 1;                /* 数值型 */
                select name into :DMO_VarList_Char separated by ' '
                        from DMO_VarList
                        where name in (&MissingVar_Quote.) and type EQ 2;                /* 字符型 */
        quit;

        data &TargetTable(drop=DMO_i);
                set &SourceTable;
                %if %LENGTH(&DMO_VarList_Num) GT 0 %then %do;
                        array VarList_Num &DMO_VarList_Num;
                        do DMO_i=1 to dim(VarList_Num);
                                if VarList_Num{DMO_i} EQ . then delete;
                        end;
                %end;
                %if %LENGTH(&DMO_VarList_Char) GT 0 %then %do;
                        array VarList_Char &DMO_VarList_Char;
                        do DMO_i=1 to dim(VarList_Char);
                                if VarList_Char{DMO_i} EQ '' then delete;
                        end;
                %end;
        run;
%end;

/* 删除不必要的表格 */
proc datasets lib=work nolist;
        delete DMO_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=DailyPriceOfIndex;*/
/*%let TargetTable=DailyPriceOfIndex1;*/
/*%let MissingVar=_ALL_;                /* =_Numeric_表示选择全部数值型变量，=_Character表示选择全部字符型变量，=_All_表示选择全部变量，也可以选择多个变量，用空格分隔 */*/
/*%DeleteMissObs(&SourceTable,&TargetTable,&MissingVar);*/
/**/
/*%mend;*/

/*编号：9*/
%macro GetVarListForTable(SourceTable,TargetTable,OutputVar,VarType,UseLabel);

/**********************************************************************/
/* 此宏的作用是得到指定表格的变量列表。其中，SourceTable是原始表格；  */
/* TargetTable是结果表格；VarType是变量类型，=_Numeric_表示数值型，   */
/* =_Character_表示字符型，=_ALL_表示取得全部变量列表，=xx:表示以xx开 */
/* 头的所有变量，=xx%表示包含xx的所有变量；UseLabel是标记变量，=Yes表 */
/* 示用标签代替变量名，否则=No。                                      */
/*                                                                    */
/* 最终得到指定表格的变量列表。                                       */
/*                                                                    */
/*                                      Created on 2013.2.6           */
/*                                      Modified on 2013.2.17          */
/**********************************************************************/

/* 检查SourceTable的合法性 */
%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
        %let GVLFT_SourceLibName=%SCAN(&SourceTable,1,.);
        %let GVLFT_SourceDatasetName=%SCAN(&SourceTable,2,.);
%end;
%else %do;
        %let GVLFT_SourceLibName=WORK;
        %let GVLFT_SourceDatasetName=&SourceTable;
%end;

/* 检查TargetTable的存在性 */
%if &TargetTable EQ %STR() AND &OutputVar EQ %STR() %then %do;
        %put ERROR: The TargetTable and OutputVar should not be blank simultaneously, please check it again.;
        %goto exit;
%end;

%if &TargetTable EQ %STR() %then %let TargetTable=GVLFT_Res;

/* 检查VarType的非空性 */
%if &VarType EQ %STR() %then %let VarType=_All_;

/* 拆分VarType */
%SeparateString(InputString=&VarType,OutputString=GVLFT_VarType);

/* 检查UseLabel的合法性 */
%if &UseLabel EQ %STR() %then %let UseLabel=No;

%if %UPCASE(&UseLabel) NE YES AND %UPCASE(&UseLabel) NE NO %then %do;
        %put ERROR: The UseLabel should be Yes or No, case insensitive and without quotes.;
        %goto exit;
%end;

/* 开始计算 */
proc contents data=&SourceTable out=GVLFT_Temp noprint;
run;

%do GVLFT_i=1 %to &GVLFT_VarType_Num;
        %if %SYSFUNC(FIND(&&GVLFT_VarType_Var&GVLFT_i,%STR(:))) NE 0 %then %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and 
                                                UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.") and
                                                UPCASE(SUBSTR(name,1,%EVAL(%LENGTH(&&GVLFT_VarType_Var&GVLFT_i)-1))) EQ "%UPCASE(%SUBSTR(&&GVLFT_VarType_Var&GVLFT_i,1,%EVAL(%LENGTH(&&GVLFT_VarType_Var&GVLFT_i)-1)))"
                                        order by VARNUM;
                quit;
        %end;
        %else %if %UPCASE(&&GVLFT_VarType_Var&GVLFT_i) EQ _NUMERIC_ %then %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and 
                                                UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.") and
                                                UPCASE(type)='NUM'
                                        order by VARNUM;
                quit;
        %end;
        %else %if %UPCASE(&&GVLFT_VarType_Var&GVLFT_i) EQ _CHARACTER_ %then %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and 
                                                UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.") and
                                                UPCASE(type)='CHAR'
                                        order by VARNUM;
                quit;
        %end;
        %else %if %SYSFUNC(FIND(&&GVLFT_VarType_Var&GVLFT_i,%STR(%%))) NE 0 %then %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.") and
                                                UPCASE(name) like UPCASE("%%Mgr%")
                                        order by VARNUM;
                quit;
        %end;
        %else %if %UPCASE(&&GVLFT_VarType_Var&GVLFT_i) EQ _ALL_ %then %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.")
                                        order by VARNUM;
                quit;
        %end;
        %else %do;
                proc sql noprint;
                        create table GVLFT_Res_&GVLFT_i as
                                select * from GVLFT_Temp
                                        where UPCASE(libname)=UPCASE("&GVLFT_SourceLibName.") and UPCASE(memname)=UPCASE("&GVLFT_SourceDatasetName.") and
                                                UPCASE(name) EQ %UPCASE("&&GVLFT_VarType_Var&GVLFT_i.")
                                        order by VARNUM;
                quit;
        %end;
%end;

/* 合并上述表格 */
data &TargetTable;
        set
        %do GVLFT_j=1 %to &GVLFT_VarType_Num;
                GVLFT_Res_&GVLFT_j
        %end;
        ;
run;

%if &OutputVar NE %STR() %then %do;
        %global &OutputVar;

        %if %UPCASE(&UseLabel) EQ NO %then %do;
                proc sql noprint;
                        select name into :&OutputVar separated by ' '
                                from &TargetTable
                                order by VARNUM;
                quit;
        %end;
        %else %if %UPCASE(&UseLabel) EQ YES %then %do;
                proc sql noprint;
                        select label into :&OutputVar separated by ' '
                                from &TargetTable
                                order by VARNUM;
                quit;
        %end;
%end;

/* 删除不必要的表格 */
proc datasets lib=work nolist;
    delete GVLFT_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Zheng.TurnoverRate;*/
/*%let TargetTable=VarList;*/
/*%let OutputVar=VarString;*/
/*%let VarType=_All_;                /* =_Numerical_表示数值型，=_Character_表示字符型，=_ALL_表示取得全部变量列表，=xx:表示以xx开头的所有变量，=xx%表示包含xx的所有变量 */*/
/*%let UseLabel=Yes;                /* 标记变量，=Yes表示用标签代替变量名，否则=No */*/
/*%GetVarListForTable(&SourceTable,&TargetTable,&OutputVar,&VarType,&UseLabel);*/
/**/
/*%put &VarString;*/
/**/
/*%mend;*/

/*编号：10*/
%macro GetDataSetInfoInLib(LibName,Filter,TargetTable,OutFilePath,Detail);

/**********************************************************************/
/* 此宏用于获得目标逻辑库下所有数据集的信息，并将此信息保存至SAS表格 */
/* 或导出至txt文件中。其中，LibName是指定的逻辑库；Filter是数据集过滤 */
/* 设置，支持_和%通配符，若需要导出所有数据集列表，可以设置为空； */
/* TargetTable是保存数据集信息的SAS表格，若不需要生成，可以设为空； */
/* OutFilePath是导出txt文件的路径，若不需要导出，可以设为空；Detail是 */
/* 标记变量，=Yes表示导出数据集列表详情，否则=No。 */
/* */
/* 最终得到的是含有目标逻辑库下所有数据集信息的SAS表格和存于指定路径 */
/* 的txt文件。 */
/* */
/* Created on 2013.2.23 */
/* Modified on 2013.4.3 */
/**********************************************************************/

/* 检查TargetTable和OutFilePath的非同时为空性 */
%if &TargetTable EQ %STR() AND &OutFilePath EQ %STR() %then %do;
%put ERROR: The TargetTable and OutFilePath should not be blank simultaneously, please check it again.;
%goto exit;
%end;

%if &TargetTable EQ %STR() %then %let TargetTable=GDSIIL_Temp;

/* 检查OutFilePath的合法性，若后缀不存在或非TXT，则改为TXT */
%if &OutFilePath NE %STR() %then %do;
%if %SYSFUNC(FIND(&OutFilePath,%STR(.))) EQ 0 %then %do;
%let OutFilePath=%SYSFUNC(CATS(&OutFilePath,%STR(.TXT)));
%end;
%else %if %SYSFUNC(FIND(&OutFilePath,%STR(.))) NE 0 AND %UPCASE(%SCAN(&OutFilePath,-1,%STR(.))) NE TXT %then %do;
%let OutFilePath=%SYSFUNC(CATS(%SUBSTR(&OutFilePath,1,%LENGTH(&OutFilePath)-%LENGTH(%SCAN(&OutFilePath,-1,%STR(.)))),TXT));
%end;
%end;

/* 检查输入路径下是否存在同名文件，若存在则删除 */
%if &OutFilePath NE %STR() %then %do;
%ChkFile(&OutFilePath);
%end;

/* 检查Detail的合法性 */
%if &Detail EQ %STR() %then %let Detail=No;

%if %UPCASE(&Detail) NE YES AND %UPCASE(&Detail) NE NO %then %do;
%put ERROR: The Detail should be Yes or No, case insensitive and without quotes.;
%goto exit;
%end;

/* 开始进行计算 */
proc sql noprint;
create table &TargetTable as
select * from SASHELP.VTABLE
where libname EQ UPCASE("&LibName.")
%if %UPCASE(&Filter) NE %STR() %then %do;
and memname like UPCASE("&Filter.");
%end;
%else %do;
;
%end;
quit;

%if %UPCASE(&Detail) EQ NO %then %do;
data &TargetTable;
set &TargetTable(keep=libname memname);
run;
%end;

%if &OutFilePath NE %STR() %then %do;
%ExportToDelimitedFile(SourceTable=&TargetTable,
Delimiter='09'x,
PutNames=Yes,
OutFilePath=&OutFilePath);
%end;

/* 如需要在SAS的Output窗口中打印文件列表，请取消如下注释 */
/*proc print data=&TargetTable;*/
/*title1 "Files identified through saved file";*/
/*run;*/

/* 删除不必要的表格 */
proc datasets lib=work nolist;
delete GDSIIL_:;
quit;

%exit:
%mend;

/*%macro Demo();*/
/**/
/*%let LibName=Zheng;*/
/*%let Filter=r%; /* 文件过滤设置，若需要导出所有文件列表，则设置为空即可，即Filter=; */*/
/*%let TargetTable=FileList; /* 若不需要生成包含文件列表的SAS表格，则设为空，大小写不敏感 */*/
/*%let OutFilePath=d:\Temp\abc.txt; /* 若不需要导出文件列表txt文件，则设为空，大小写不敏感 */*/
/*%let Detail=Yes; /* =Yes表示在导出文件列表txt文件中包含InDirPath的详情，否则=No，大小写不敏感 */*/
/*%GetDataSetInfoInLib(&LibName,&Filter,&TargetTable,&OutFilePath,&Detail);*/
/**/
/*%mend;*/

/*编号：11*/
%macro FillMissWithNonMiss(SourceTable,TargetTable,ByFactors,MissingVar,OrderVar,Type);
/**********************************************************************/
/* 此宏对原表中含有缺失值的变量进行填补，其方法是将缺失值用上一个或下 */
/* 一个非缺失值来填补。其中SourceTable是原始表格；TargetTable是结果表 */
/* 格；ByFactors是分组变量；MissingVar是可能含有缺失值的变量，        */
/* =_Numeric_表示选择全部数值型变量，=_Character_表示选择全部字符型变 */
/* 量，=_All_表示选择全部变量，也可以选择多个变量，用空格分隔；Order_ */
/* Var是排列变量，可设置为多个，用空格分隔，默认按升序排列，若要降序  */
/* 排列，可在相应的变量后加DESCENDING；Type是缺失值的选取方式，       */
/* =Previous表示缺失值选取前一个非缺失值，=Next表示缺失值选取后一个非 */
/* 缺失值，=Mix表示用线性插值的方法填补缺失值（该方法只适用于数值型变 */
/* 量，对字符型变量若设为Mix，则自动用Previous的方法插值）。          */
/*                                                                    */
/* 最终结果表格中指定的含有缺失值的变量的缺失值被填补。               */
/*                                                                    */
/*                                      Created on 2011.9.28          */
/*                                      Modified on 2013.3.22         */
/**********************************************************************/

/* 检查TargetTable的存在性，若不存在则设为&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* 若SourceTable与TargetTable相同，则设FMWNM_res为&SourceTable */
%if %UPCASE(&SourceTable) EQ %UPCASE(&TargetTable) %then %let FMWNM_res=&SourceTable;
%else %let FMWNM_res=FMWNM_res;

data &FMWNM_res;
        set &SourceTable;
run;

/* 检查ByFactors的存在性 */
%if &ByFactors EQ %STR() %then %do;
        %let ByFactors=FMWNM_ByFactors;

        data &FMWNM_res;
                set &FMWNM_res;
                FMWNM_ByFactors=1;
        run;
%end;

%ChkVar(SourceTable=&FMWNM_res,InputVar=&ByFactors,FlagVarExists=FMWNM_FlagVarExists1);

%if %SYSFUNC(FIND(&FMWNM_FlagVarExists1,0)) NE 0 %then %do;
        %put ERROR: The ByFactors %SCAN(&ByFactors,%SYSFUNC(FIND(&FMWNM_FlagVarExists1,0))) does not exist in SourceTable, please check it again.;
        %goto exit;
%end;

%local LastByFactors;
%let LastByFactors=%SYSFUNC(SCAN(&ByFactors,-1,' '));

/* 逗号分隔的ByFactors_Comma用于SQL语句 */
%local ByFactors_Comma;

%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
        %let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %let ByFactors_Comma=&ByFactors;

/* 检查MissingVar的存在性 */
%if (%UPCASE(&MissingVar) NE _NUMERIC_) AND (%UPCASE(&MissingVar) NE _CHARACTER_) AND (%UPCASE(&MissingVar) NE _ALL_) %then %do;
        %ChkVar(SourceTable=&FMWNM_res,InputVar=&MissingVar,FlagVarExists=FMWNM_FlagVarExists2);

        %if %SYSFUNC(FIND(&FMWNM_FlagVarExists2,0)) NE 0 %then %do;
                %put ERROR: The MissingVar %SCAN(&ByFactors,%SYSFUNC(FIND(&FMWNM_FlagVarExists2,0))) does not exist in SourceTable, please check it again.;
                %goto exit;
        %end;
%end;

/* 检查OrderVar的存在性 */
%if &OrderVar EQ %STR() %then %do;
        %let OrderVar=FMWNM_OrderVar;

        data &FMWNM_res;
                set &FMWNM_res;
                FMWNM_OrderVar=_N_;
        run;                
%end;

%ChkVar(SourceTable=&FMWNM_res,InputVar=&OrderVar,FlagVarExists=FMWNM_FlagVarExists3);

%if %SYSFUNC(FIND(&FMWNM_FlagVarExists3,0)) NE 0 %then %do;
        %put ERROR: The OrderVar %SCAN(&OrderVar,%SYSFUNC(FIND(&FMWNM_FlagVarExists3,0))) does not exist in SourceTable, please check it again.;
        %goto exit;
%end;

/* 逗号分隔的OrderVar_Comma用于SQL语句 */
%local OrderVar_Comma;

%if &OrderVar NE %STR() %then %do;
        %if %SYSFUNC(FIND(&OrderVar,%STR( ))) NE 0 %then %do;
                %let OrderVar=%SYSFUNC(COMPBL(&OrderVar));                /* 压缩多余空格 */
                %let OrderVar_Comma=%PrxChange(InputString=&OrderVar,PrxString=s/ DESCENDING/DESCENDING/);                /* 解决DESCENDING的格式问题 */
                %let OrderVar_Comma=%SYSFUNC(TRANWRD(&OrderVar_Comma,%STR( ),ANCBS_Space));
                %let OrderVar_Comma=%PrxChange(InputString=&OrderVar_Comma,PrxString=s/DESCENDING/ DESCENDING/);
                %let OrderVar_Comma=%SYSFUNC(TRANWRD(&OrderVar_Comma,ANCBS_Space,%STR(,)));
        %end;
        %else %let OrderVar_Comma=&OrderVar;
%end;
%else %let OrderVar_Comma=;

/* 检查Type的存在性和合法性 */
%if &Type EQ %STR() %then %let Type=PREVIOUS;

%if (%UPCASE(&Type) NE PREVIOUS) AND (%UPCASE(&Type) NE NEXT) AND (%UPCASE(&Type) NE MIX) %then %do;
        %put ERROR: The Type should be PREVIOUS, NEXT or MIX, case insensitive and without quotes.;
        %goto exit;
%end;

/* 开始进行计算 */
/* 首先，根据Type设置对原始表格进行排序 */
%if %UPCASE(&Type) EQ PREVIOUS %then %do;
        proc sort data=&FMWNM_res;
                by &OrderVar;
        run;
%end;
%else %if (%UPCASE(&Type) EQ NEXT) OR (%UPCASE(&Type) EQ MIX) %then %do;                /* 将原表按&ByFactors逆序排序 */
        proc sort data=&FMWNM_res;
                by DESCENDING %SYSFUNC(TRANWRD(&OrderVar,%STR( ),%STR( )DESCENDING%STR( )));
        run;
%end;

/* 其次，对含有缺失值的变量进行补足 */
%if %UPCASE(&MissingVar) EQ _NUMERIC_ %then %do;
        %GetMissNum(SourceTable=&FMWNM_res,TargetTable=FMWNM_MissNumeric_temp,InputVar=_NUMERIC_);

        proc sql noprint;
                create table FMWNM_MissNumeric as
                        select *,monotonic() as _N_ from FMWNM_MissNumeric_temp
                                where MissNum GT 0;
        quit;

        proc sql noprint;
                select count(*) into :FMWNM_MissVarNum
                        from FMWNM_MissNumeric;
        quit;

        %if %UPCASE(&Type) NE MIX %then %do;
                %do FMWNM_i=1 %to &FMWNM_MissVarNum;
                        proc sql noprint;
                                select VarName into :FMWNM_MissVarName
                                        from FMWNM_MissNumeric
                                        where _N_ EQ &FMWNM_i;
                        quit;

                        data &FMWNM_res(drop=var_temp);
                                set &FMWNM_res;
                                retain var_temp;
                                %if %UPCASE(&Type) EQ PREVIOUS %then %do;
                                        by &ByFactors;
                                %end;
                                %else %if %UPCASE(&Type) EQ NEXT %then %do;
                                        by DESCENDING %SYSFUNC(TRANWRD(&ByFactors,%STR( ),%STR( )DESCENDING%STR( )));
                                %end;
                                if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                if &FMWNM_MissVarName NE . then var_temp=&FMWNM_MissVarName;
                                else &FMWNM_MissVarName=var_temp;
                        run;
                %end;
        %end;
        %else %do;
                %do FMWNM_i=1 %to &FMWNM_MissVarNum;
                        proc sql noprint;
                                select VarName into :FMWNM_MissVarName
                                        from FMWNM_MissNumeric
                                        where _N_ EQ &FMWNM_i;
                        quit;
                        
                        %let FMWNM_MissVarName=%SYSFUNC(STRIP(&FMWNM_MissVarName));

                        proc sort data=&FMWNM_res;
                                by DESCENDING %SYSFUNC(TRANWRD(&OrderVar,%STR( ),%STR( )DESCENDING%STR( )));
                        run;

                        data &FMWNM_res;
                                set &FMWNM_res;
                                retain &FMWNM_MissVarName._Diff;
                                by DESCENDING %SYSFUNC(TRANWRD(&ByFactors,%STR( ),%STR( )DESCENDING%STR( )));
                                if first.&LastByFactors then &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;
                                if first.&LastByFactors AND &FMWNM_MissVarName EQ . then &FMWNM_MissVarName._No=1;
                                else if &FMWNM_MissVarName NE . then do;
                                        &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;                /* 得到两个缺失值之间的差 */
                                        &FMWNM_MissVarName._No=0;                /* 得到缺失值的序号 */
                                end;
                                else if &FMWNM_MissVarName EQ . then do;
                                        &FMWNM_MissVarName._No+1;
                                end;
                        run;

                        proc sort data=&FMWNM_res;
                                by &OrderVar;
                        run;

                        data &FMWNM_res(drop=&FMWNM_MissVarName._Diff &FMWNM_MissVarName._No var_temp);
                                set &FMWNM_res;
                                retain var_temp;
                                by &ByFactors;
                                if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                if &FMWNM_MissVarName NE . then var_temp=&FMWNM_MissVarName;
                                else do;
                                        &FMWNM_MissVarName=var_temp+(&FMWNM_MissVarName._Diff-var_temp)/(&FMWNM_MissVarName._No+1);                /* 利用两个缺失值之间的差和缺失值的序号得到需要插入的值 */
                                        var_temp=&FMWNM_MissVarName;
                                end;
                        run;
                %end;
        %end;
%end;
%else %if %UPCASE(&MissingVar) EQ _CHARACTER_ %then %do;
        %GetMissNum(SourceTable=&FMWNM_res,TargetTable=FMWNM_MissChar_temp,InputVar=_CHARACTER_);

        proc sql noprint;
                create table FMWNM_MissChar as
                        select *,monotonic() as _N_ from FMWNM_MissChar_temp
                                where MissNum GT 0;
        quit;

        proc sql noprint;
                select count(*) into :FMWNM_MissVarNum
                        from FMWNM_MissChar;
        quit;

        %do FMWNM_j=1 %to &FMWNM_MissVarNum;
                        proc sql noprint;
                                select VarName into :FMWNM_MissVarName
                                        from FMWNM_MissChar
                                        where _N_ EQ &FMWNM_j;
                        quit;

                        data &FMWNM_res(drop=var_temp);
                                set &FMWNM_res;
                                retain var_temp;
                                %if (%UPCASE(&Type) EQ PREVIOUS) OR (%UPCASE(&Type) EQ MIX) %then %do;
                                        by &ByFactors;
                                %end;
                                %else %if %UPCASE(&Type) EQ NEXT %then %do;
                                        by DESCENDING %SYSFUNC(TRANWRD(&ByFactors,%STR( ),%STR( )DESCENDING%STR( )));
                                %end;
                                if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                if &FMWNM_MissVarName NE '' then var_temp=&FMWNM_MissVarName;
                                else &FMWNM_MissVarName=var_temp;
                        run;
        %end;
%end;
%else %do;
        %if %UPCASE(&MissingVar) EQ _ALL_ %then %do;
                %GetMissNum(SourceTable=&FMWNM_res,TargetTable=FMWNM_MissAll_temp,InputVar=_ALL_);
        %end;
        %else %do;                /* 若MissingVar为指定变量名称，则仅取指定变量的缺失值数量数据 */
                %GetMissNum(SourceTable=&FMWNM_res,TargetTable=FMWNM_MissAll_temp,InputVar=&MissingVar);
        %end;

        proc sql noprint;
                create table FMWNM_MissAll as
                        select *,monotonic() as _N_ from FMWNM_MissAll_temp
                                where MissNum GT 0;
        quit;

        proc sql noprint;
                select count(*) into :FMWNM_MissVarNum
                        from FMWNM_MissAll;
        quit;

        %do FMWNM_k=1 %to &FMWNM_MissVarNum;
                proc sql noprint;
                        select VarName,VarType into :FMWNM_MissVarName,:FMWNM_MissVarType
                                from FMWNM_MissAll
                                where _N_ EQ &FMWNM_k;
                quit;
                        
                %if %UPCASE(&Type) NE MIX %then %do;
                        data &FMWNM_res(drop=var_temp);
                                set &FMWNM_res;
                                retain var_temp;
                                %if %UPCASE(&Type) EQ PREVIOUS %then %do;
                                        by &ByFactors;
                                %end;
                                %else %if %UPCASE(&Type) EQ NEXT %then %do;
                                        by DESCENDING %SYSFUNC(TRANWRD(&ByFactors,%STR( ),%STR( )DESCENDING%STR( )));
                                %end;
                                if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                %if &FMWNM_MissVarType EQ N %then %do;
                                        if &FMWNM_MissVarName NE . then var_temp=&FMWNM_MissVarName;
                                        else &FMWNM_MissVarName=var_temp;
                                %end;
                                %else %do;
                                        if &FMWNM_MissVarName NE '' then var_temp=&FMWNM_MissVarName;
                                        else &FMWNM_MissVarName=var_temp;
                                %end;
                        run;
                %end;
                %else %do;
                        %let FMWNM_MissVarName=%SYSFUNC(STRIP(&FMWNM_MissVarName));
                        %if &FMWNM_MissVarType EQ N %then %do;
                                proc sort data=&FMWNM_res;
                                        by DESCENDING %SYSFUNC(TRANWRD(&OrderVar,%STR( ),%STR( )DESCENDING%STR( )));
                                run;

                                data &FMWNM_res;
                                        set &FMWNM_res;
                                        retain &FMWNM_MissVarName._Diff;
                                        by DESCENDING %SYSFUNC(TRANWRD(&ByFactors,%STR( ),%STR( )DESCENDING%STR( )));
                                        if first.&LastByFactors then &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;
                                        if first.&LastByFactors AND &FMWNM_MissVarName EQ . then &FMWNM_MissVarName._No=1;
                                        else if &FMWNM_MissVarName NE . then do;
                                                &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;                /* 得到两个缺失值之间的差 */
                                                &FMWNM_MissVarName._No=0;                /* 得到缺失值的序号 */
                                        end;
                                        else if &FMWNM_MissVarName EQ . then do;
                                                &FMWNM_MissVarName._No+1;
                                        end;
                                run;

                                proc sort data=&FMWNM_res;
                                        by &OrderVar;
                                run;

                                data &FMWNM_res(drop=&FMWNM_MissVarName._Diff &FMWNM_MissVarName._No var_temp);
                                        set &FMWNM_res;
                                        retain var_temp;
                                        by &ByFactors;
                                        if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                        if &FMWNM_MissVarName NE . then var_temp=&FMWNM_MissVarName;
                                        else do;
                                                &FMWNM_MissVarName=var_temp+(&FMWNM_MissVarName._Diff-var_temp)/(&FMWNM_MissVarName._No+1);                /* 利用两个缺失值之间的差和缺失值的序号得到需要插入的值 */
                                                var_temp=&FMWNM_MissVarName;
                                        end;
                                run;
                        %end;
                        %else %do;
                                data &FMWNM_res(drop=var_temp);
                                        set &FMWNM_res;
                                        retain var_temp;
                                        by &ByFactors;
                                        if first.&LastByFactors then var_temp=&FMWNM_MissVarName;
                                        if &FMWNM_MissVarName NE '' then var_temp=&FMWNM_MissVarName;
                                        else &FMWNM_MissVarName=var_temp;
                                run;
                        %end;
                %end;
        %end;
%end;

%if %UPCASE(&FMWNM_res) EQ %UPCASE(&TargetTable) %then %do;
        proc sort data=&TargetTable;
                by &OrderVar;
        run;
%end;
%else %do;
        proc sql noprint;
                create table &TargetTable as 
                        select * from &FMWNM_res
                        order by &OrderVar_Comma;
        quit;
%end;

/* 删除临时生成的ByFactors和OrderVar */
%if %UPCASE(&ByFactors) EQ FMWNM_BYFACTORS %then %do;
        data &TargetTable;
                set &TargetTable;
                drop FMWNM_ByFactors;
        run;
%end; 

%if %UPCASE(&OrderVar) EQ FMWNM_ORDERVAR %then %do;
        data &TargetTable;
                set &TargetTable;
                drop FMWNM_OrderVar;
        run;
%end; 

/* 删除不必要的表格 */
proc datasets lib=work nolist;
        delete FMWNM_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=a;*/
/*%let TargetTable=b;*/
/*%let ByFactors=;*/
/*%let MissingVar=_All_;                /* =_Numeric_表示选择全部数值型变量，=_Character表示选择全部字符型变量，=_All_表示选择全部变量，也可以选择多个变量，用空格分隔 */*/
/*%let OrderVar=;*/
/*%let Type=MIX;                /* 对缺失值进行处理的方法，=Previous、Next或MIX */*/
/*%FillMissWithNonMiss(&SourceTable,&TargetTable,&ByFactors,&MissingVar,&OrderVar,&Type);*/
/**/
/*%mend;*/

/*编号：12*/
%macro GetMissNum(SourceTable,TargetTable,InputVar);
/**********************************************************************/
/* 此宏的作用是统计原表中不同变量的缺失值数量。其中SourceTable是原始 */
/* 表格，SourceTable是结果表格；TargetTable是结果表格；InputVar是原始 */
/* 表格中的变量，可设多个变量，用空格分隔，也可如下设置：=_Numeric_表 */
/* 示统计全部数值型变量，=_Character_表示统计全部字符型变量，=_All_表 */
/* 示统计全部变量。 */
/* */
/* 最终结果表格中包含所有指定变量的名称、类型和相应的缺失值数量。 */
/* */
/* Created on 2013.5.8 */
/* Modified on 2013.5.8 */
/**********************************************************************/

/* 检查TargetTable的存在性 */
%if &TargetTable EQ %STR() %then %do;
%put ERROR: The TargetTable should not be blank, please check it again.;
%goto exit;
%end;

/* 检查InputVar的合法性 */
%if %UPCASE(&InputVar) NE _NUMERIC_ AND %UPCASE(&InputVar) NE _CHARACTER_ AND %UPCASE(&InputVar) NE _ALL_ %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=GMN_FlagVarExists);

%if %SYSFUNC(FIND(&GMN_FlagVarExists,0)) NE 0 %then %do;
%put ERROR: The InputVar should be _Numeric_, _Character_, _All_ or any variable name in SourceTable, case insensitive and without quotes.;
%put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&GMN_FlagVarExists,0)))" does not exist in SourceTable, please check it again.; 
%goto exit;
%end;
%end;

%if %UPCASE(&InputVar) EQ _NUMERIC_ %then %do;
proc contents data=&SourceTable position out=GMN_VarList(keep=name type varnum) noprint; 
run;

/* 检查数值型变量是否存在 */
%ChkValue(SourceTable=GMN_VarList,
InputVar=type,
Value=1,
FlagValueExists=GMN_FlagNumVarExists);

%if &GMN_FlagNumVarExists GT 0 %then %do;
proc sql noprint;
select NAME into :GMN_NumVarList separated by ' '
from GMN_VarList
where TYPE EQ 1;
quit;

/* 化简原始表格 */
data &TargetTable(keep=&GMN_NumVarList drop=GMN_i);
set &SourceTable;
array VarList &GMN_NumVarList;
do GMN_i=1 to dim(VarList);
if VarList{GMN_i} NE . then VarList{GMN_i}=0;
else VarList{GMN_i}=1;
end;
run;

%GetStatsForTable(SourceTable=&TargetTable,
TargetTable=&TargetTable,
ByFactors=,
InputVar=&GMN_NumVarList,
InputVarType=,
OutputVarType=,
Weight=,
Statistic=SUM);

proc transpose data=&TargetTable out=&TargetTable;
var &GMN_NumVarList;
run;

data &TargetTable(rename=(_NAME_=VarName _LABEL_=VarLabel COL1=MissNum));
retain _NAME_ _LABEL_ VarType COL1;
set &TargetTable;
VarType='N';
run;
%end;
%else %do;
%put ERROR: There is no numeric variable existed in SourceTable, please check it again.;
%goto exit;
%end;
%end;
%else %if %UPCASE(&InputVar) EQ _CHARACTER_ %then %do;
proc contents data=&SourceTable position out=GMN_VarList(keep=name type varnum) noprint; 
run;

/* 检查字符型变量是否存在 */
%ChkValue(SourceTable=GMN_VarList,
InputVar=type,
Value=2,
FlagValueExists=GMN_FlagCharVarExists);

%if &GMN_FlagCharVarExists GT 0 %then %do;
proc sql noprint;
select NAME,STRIP(NAME)||'_Temp' into :GMN_CharVarList separated by ' ',:GMN_CharVarList_Temp separated by ' '
from GMN_VarList
where TYPE EQ 2;
quit;

/* 化简原始表格 */
data &TargetTable(keep=&GMN_CharVarList_Temp drop=GMN_j);
set &SourceTable;
array VarList &GMN_CharVarList;
array VarList_Temp &GMN_CharVarList_Temp;
do GMN_j=1 to dim(VarList);
if VarList{GMN_j} NE "" then VarList_Temp{GMN_j}=0;
else VarList_Temp{GMN_j}=1;
end;
run;

%GetStatsForTable(SourceTable=&TargetTable,
TargetTable=&TargetTable,
ByFactors=,
InputVar=&GMN_CharVarList_Temp,
InputVarType=,
OutputVarType=,
Weight=,
Statistic=SUM);

proc transpose data=&TargetTable out=&TargetTable;
var &GMN_CharVarList_Temp;
run;

data &TargetTable(rename=(_NAME_=VarName _LABEL_=VarLabel COL1=MissNum));
retain _NAME_ _LABEL_ VarType COL1;
set &TargetTable;
VarType='C';
_NAME_=SUBSTR(_NAME_,1,LENGTH(_NAME_)-5);
run;
%end;
%else %do;
%put ERROR: There is no character variable existed in SourceTable, please check it again.;
%goto exit;
%end;
%end;
%else %do;
proc contents data=&SourceTable position out=GMN_VarList(keep=name type varnum) noprint; 
run;

/* 筛选指定的变量 */
%if %UPCASE(&InputVar) NE _ALL_ %then %do;
%let InputVar_Comma=%PrxChange(InputString=&InputVar,PrxString=s/(\w+)/'$1'/); /* 给InputVar中的代码加引号 */
%let InputVar_Comma=%SYSFUNC(TRANSLATE(&InputVar_Comma,%STR(,),%STR( ))); /* 替换InputVar中的空格为逗号 */

proc sql noprint;
create table GMN_VarList as
select * from GMN_VarList
where Name in (&InputVar_Comma)
order by Name;
quit;
%end;

/* 检查数值型变量是否存在 */
%ChkValue(SourceTable=GMN_VarList,
InputVar=type,
Value=1,
FlagValueExists=GMN_FlagNumVarExists);

/* 检查字符型变量是否存在 */
%ChkValue(SourceTable=GMN_VarList,
InputVar=type,
Value=2,
FlagValueExists=GMN_FlagCharVarExists);

%if &GMN_FlagNumVarExists GT 0 %then %do;
proc sql noprint;
select NAME into :GMN_NumVarList separated by ' '
from GMN_VarList
where TYPE EQ 1;
quit;

/* 化简原始表格 */
data GMN_NumMiss(keep=&GMN_NumVarList drop=GMN_k);
set &SourceTable;
array VarList &GMN_NumVarList;
do GMN_k=1 to dim(VarList);
if VarList{GMN_k} NE . then VarList{GMN_k}=0;
else VarList{GMN_k}=1;
end;
run;

%GetStatsForTable(SourceTable=GMN_NumMiss,
TargetTable=GMN_NumMiss,
ByFactors=,
InputVar=&GMN_NumVarList,
InputVarType=,
OutputVarType=,
Weight=,
Statistic=SUM);

proc transpose data=GMN_NumMiss out=GMN_NumMiss;
var &GMN_NumVarList;
run;

data GMN_NumMiss(rename=(_NAME_=VarName _LABEL_=VarLabel COL1=MissNum));
retain _NAME_ _LABEL_ VarType COL1;
set GMN_NumMiss;
VarType='N';
run;
%end;
%if &GMN_FlagCharVarExists GT 0 %then %do;
proc sql noprint;
select NAME,STRIP(NAME)||'_Temp' into :GMN_CharVarList separated by ' ',:GMN_CharVarList_Temp separated by ' '
from GMN_VarList
where TYPE EQ 2;
quit;

/* 化简原始表格 */
data GMN_CharMiss(keep=&GMN_CharVarList_Temp drop=GMN_l);
set &SourceTable;
array VarList &GMN_CharVarList;
array VarList_Temp &GMN_CharVarList_Temp;
do GMN_l=1 to dim(VarList);
if VarList{GMN_l} NE "" then VarList_Temp{GMN_l}=0;
else VarList_Temp{GMN_l}=1;
end;
run;

%GetStatsForTable(SourceTable=GMN_CharMiss,
TargetTable=GMN_CharMiss,
ByFactors=,
InputVar=&GMN_CharVarList_Temp,
InputVarType=,
OutputVarType=,
Weight=,
Statistic=SUM);

proc transpose data=GMN_CharMiss out=GMN_CharMiss;
var &GMN_CharVarList_Temp;
run;

data GMN_CharMiss(rename=(_NAME_=VarName _LABEL_=VarLabel COL1=MissNum));
retain _NAME_ _LABEL_ VarType COL1;
set GMN_CharMiss;
VarType='C';
_NAME_=SUBSTR(_NAME_,1,LENGTH(_NAME_)-5);
run;
%end;

data &TargetTable;
set
%if &GMN_FlagNumVarExists GT 0 %then %do;
GMN_NumMiss
%end;
%if &GMN_FlagCharVarExists GT 0 %then %do;
GMN_CharMiss
%end;
;
run;
%end;

/* 删除不必要的表格 */
proc datasets lib=work nolist;
delete GMN_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Cars;*/
/*%let TargetTable=MissNum;*/
/*%let InputVar=Cylinders; /* =_Numeric_表示统计全部数值型变量，=_Character_表示统计全部字符型变量，=_All_表示统计全部变量，大小写不敏感 */*/
/*%GetMissNum(&SourceTable,&TargetTable,&InputVar);*/
/**/
/*%mend;*/

/*编号：13*/
%macro ChkValue(SourceTable,InputVar,Value,FlagValueExists);

/**********************************************************************/
/* 此宏的作用是检查某数据表中是否含有指定变量为某特定值的观测。其中， */
/* SourceTable是原始表格；InputVar是指定的变量，且只能指定一个变量； */
/* Value是指定的值，字符串不需要加引号，可以设为多个值，用空格分隔； */
/* FlagValueExists是标记宏变量名称，=1表示原数据表中含有指定变量为某 */
/* 特定值的观测，否则=0。 */
/* */
/* 最终得到的是宏变量&FlagValueExists，不同位置上的数值表示对应的值是 */
/* 否在原表中的指定变量中存在，=1表示原数据表中含有指定变量为某特定值 */
/* 的观测，否则=0。 */
/* */
/* Created on 2012.11.6 */
/* Modified on 2012.11.12 */
/**********************************************************************/

/* 检查SourceTable的存在性 */
%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
%let CVL_LibName=%UPCASE(%SCAN(&SourceTable,1,.));
%let CVL_MemName=%UPCASE(%SCAN(&SourceTable,2,.));
%end;
%else %do;
%let CVL_LibName=WORK;
%let CVL_MemName=%UPCASE(&SourceTable);
%end;

%ChkDataSet(DataSet=&CVL_LibName..&CVL_MemName,FlagDataSetExists=CVL_FlagDataSetExists);

%if &CVL_FlagDataSetExists EQ 0 %then %do;
%put ERROR: The DataSet "&SourceTable." does not exist, please check it again.;
%goto exit;
%end;

/* 检查InputVar的唯一性 */
%if %SYSFUNC(FIND(&InputVar,%STR( ))) NE 0 %then %do;
%put ERROR: The InputVar should be only a single variable, please check it again.;
%goto exit;
%end;

/* 检查InputVar的存在性 */
%ChkVar(SourceTable=&CVL_LibName..&CVL_MemName,InputVar=&InputVar,FlagVarExists=CVL_FlagInputVarExists);

%if %SYSFUNC(FIND(&CVL_FlagInputVarExists,0)) NE 0 %then %do;
%put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&CV_FlagInputVarExists,0)))" does not exist in SourceTable, please check it again.;
%goto exit;
%end;

/* 开始进行计算 */
/* 拆分Value */
%SeparateString(InputString=&Value,OutputString=CVL_Value);

/* 为&FlagValueExists设置初始值 */
%do CVL_i=1 %to &CVL_Value_Num;
%let CVL_FlagValueExists_&CVL_i.=0;
%end;

/* 检查InputVar的格式 */
%ChkVarType(SourceTable=&CVL_LibName..&CVL_MemName,InputVar=&InputVar,FlagVarType=CVL_InputVarType);

%if &CVL_InputVarType EQ C %then %do;
%do CVL_j=1 %to &CVL_Value_Num;
data _null_;
set &SourceTable;
call symputx("CVL_FlagValueExists_&CVL_j.",'1');
where UPCASE(&InputVar)=UPCASE("&&CVL_Value_Var&CVL_j.");
run;
%end;
%end;
%else %if &CVL_InputVarType EQ N %then %do;
%do CVL_k=1 %to &CVL_Value_Num;
data _null_;
set &SourceTable;
call symputx("CVL_FlagValueExists_&CVL_k.",'1');
where &InputVar=&Value;
run;
%end;
%end;

/* 连接上述多个宏变量，生成&FlagValueExists */
%global &FlagValueExists;

%let &FlagValueExists=&CVL_FlagValueExists_1;

%do CVL_l=2 %to &CVL_Value_Num;
%let &FlagValueExists=&&&FlagValueExists.&&CVL_FlagValueExists_&CVL_l;
%end;

/* 若要显示&FlagValueExists的值，请取消下面的注释 */
/*%put &FlagValueExists=&&&FlagValueExists;*/

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Allretoffund_holding_temp1;*/
/*%let InputVar=End_Yr;*/
/*%let Value=2004; /* 字符串不需要加引号 */*/
/*%let FlagValueExists=FlagValueExists1;*/
/*%ChkValue(&SourceTable,&InputVar,&Value,&FlagValueExists);*/
/**/
/*%mend;*/

/*编号：14*/
%macro ChkVarFormat(SourceTable,InputVar,FlagVarFormat);

/**********************************************************************/
/* 此宏的作用是检查某数据表中指定变量的格式，如日期格式YYMMDD10.和字 */
/* 符串格式$40.。其中，SourceTable是原始表格；InputVar是指定的变量， */
/* 若为多个变量，请用空格分隔；FlagVarFormat是标记宏变量名称，若有多 */
/* 个InputVar变量，则用小数点分隔。 */
/* */
/* 最终得到的是宏变量&FlagVarFormat。 */
/* */
/* Created on 2012.9.7 */
/* Modified on 2012.9.18 */
/**********************************************************************/

%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
%let CVF_LibName=%UPCASE(%SCAN(&SourceTable,1,.));
%let CVF_MemName=%UPCASE(%SCAN(&SourceTable,2,.));
%end;
%else %do;
%let CVF_LibName=WORK;
%let CVF_MemName=%UPCASE(&SourceTable);
%end;

%ChkDataSet(DataSet=&CVF_LibName..&CVF_MemName,FlagDataSetExists=CVF_FlagDataSetExists);

%if &CVF_FlagDataSetExists EQ 1 %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=CVF_FlagVarExists);

%if %SYSFUNC(FIND(&CVF_FlagVarExists,0)) EQ 0 %then %do;
proc contents data=&SourceTable out=CVF_temp(keep=NAME TYPE FORMAT FORMATL) noprint;
run;

%global &FlagVarFormat;

%if %SYSFUNC(FIND(&InputVar,%STR( ))) NE 0 %then %do;
%SeparateString(InputString=&InputVar,OutputString=CVF);

%do CVF_i=1 %to &CVF_Num;
%let CVF_FlagVarExists&CVF_i=0;

data _null_;
set CVF_temp;
if UPCASE(NAME)=UPCASE("&&CVF_Var&CVF_i.") then do;
call symputx("CVF_FlagVarFormat&CVF_i",FORMAT);
call symputx("CVF_FlagVarFormatL&CVF_i",FORMATL);
end;
run;
%end;

%let &FlagVarFormat=&&CVF_FlagVarFormat1.&&CVF_FlagVarFormatL1;

%do CVF_j=2 %to &CVF_Num;
%let &FlagVarFormat=&&&FlagVarFormat.%STR(.)&&CVF_FlagVarFormat&CVF_j&&CVF_FlagVarFormatL&CVF_j;
%end;
%end;
%else %do;
data _null_;
set CVF_temp;
if UPCASE(NAME)=UPCASE("&InputVar.") then do;
call symputx("CVF_FlagVarFormat",FORMAT);
call symputx("CVF_FlagVarFormatL",FORMATL);
end;
run;

%let &FlagVarFormat=&CVF_FlagVarFormat.&CVF_FlagVarFormatL;
%end;
%end;
%else %do;
%put ERROR: There is no variable named %SCAN(&InputVar,%SYSFUNC(FIND(&CVF_FlagVarExists,0))), please check it again.;
%goto exit;
%end; 
%end;
%else %if &CVF_FlagDataSetExists EQ 0 %then %do;
%put ERROR: The DataSet "&SourceTable." does not exist, please check it again.;
%goto exit;
%end;
%else %do;
%put ERROR: There may be something wrong with the macro ChkDataSet, please contact the writer for help.;
%goto exit;
%end;

/* 若要显示&FlagVarFormat的值，请取消下面的注释 */
/*%put &FlagVarFormat=&&&FlagVarFormat;*/

/* 删除不必要的表格 */
proc delete data=CVF_temp;
run;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=AOQR_DetHoldingsOfFund_Chosen;*/
/*%let InputVar=End_Date Fund_Name Fund_Code;*/
/*%let FlagVarFormat=FlagVarFormat1;*/
/*%ChkVarFormat(&SourceTable,&InputVar,&FlagVarFormat);*/
/**/
/*%mend;*/

/*编号：15*/
%macro ChkVarType(SourceTable,InputVar,FlagVarType);

/**********************************************************************/
/* 此宏的作用是检查某数据表中指定变量的类型，即数值型或字符型。其中， */
/* SourceTable是原始表格；InputVar是指定的变量，若为多个变量，请用空 */
/* 格分隔；FlagVarType是标记宏变量名称，=N表示为数值型，=C表示为字符 */
/* 型，若有多个InputVar变量，则不同位置上的N或C代表相应变量的类型。 */
/* */
/* 最终得到的是宏变量&FlagVarType，=N表示指定变量为数值型，=C表示为字 */
/* 符型，若为多个变量，则不同位置上的N或C代表相应变量的类型。 */
/* */
/* Created on 2012.4.27 */
/* Modified on 2012.9.18 */
/**********************************************************************/

%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
%let CVT_LibName=%UPCASE(%SCAN(&SourceTable,1,.));
%let CVT_MemName=%UPCASE(%SCAN(&SourceTable,2,.));
%end;
%else %do;
%let CVT_LibName=WORK;
%let CVT_MemName=%UPCASE(&SourceTable);
%end;

%ChkDataSet(DataSet=&CVT_LibName..&CVT_MemName,FlagDataSetExists=CVT_FlagDataSetExists);

%if &CVT_FlagDataSetExists EQ 1 %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=CVT_FlagVarExists);

%if %SYSFUNC(FIND(&CVT_FlagVarExists,0)) EQ 0 %then %do;
proc contents data=&SourceTable out=CVT_temp(keep=NAME TYPE) noprint;
run;

%global &FlagVarType;

%if %SYSFUNC(FIND(&InputVar,%STR( ))) NE 0 %then %do;
%SeparateString(InputString=&InputVar,OutputString=CVT);

%do CVT_i=1 %to &CVT_Num;
%let CVT_FlagVarExists&CVT_i=0;

data _null_;
set CVT_temp;
if UPCASE(NAME)=UPCASE("&&CVT_Var&CVT_i.") then call symputx("CVT_FlagVarType&CVT_i",TYPE);
run;
%end;

%let &FlagVarType=&&CVT_FlagVarType1;

%do CVT_j=2 %to &CVT_Num;
%let &FlagVarType=&&&FlagVarType.&&CVT_FlagVarType&CVT_j;
%end;
%end;
%else %do;
%let &FlagVarType=0;

data _null_;
set CVT_temp;
if UPCASE(NAME)=UPCASE("&InputVar.") then call symputx("&FlagVarType.",TYPE);
run;
%end;

%let &FlagVarType=%SYSFUNC(TRANSLATE(&&&FlagVarType,NC,12)); /* 转换变量类型的显示方式，N表示数值型，C表示字符型 */
%end;
%else %do;
%put ERROR: There is no variable named %SCAN(&InputVar,%SYSFUNC(FIND(&CVT_FlagVarExists,0))), please check it again.;
%goto exit;
%end; 
%end;
%else %if &CVT_FlagDataSetExists EQ 0 %then %do;
%put ERROR: The DataSet "&SourceTable." does not exist, please check it again.;
%goto exit;
%end;
%else %do;
%put ERROR: There may be something wrong with the macro ChkDataSet, please contact the writer for help.;
%goto exit;
%end;

/* 若要显示&FlagVarType的值，请取消下面的注释 */
/*%put &FlagVarType=&&&FlagVarType;*/

/* 删除不必要的表格 */
proc delete data=CVT_temp;
run;

%exit:
%mend;

/*代码15的案例*/
/*%macro Demo();*/
/**/
/*%let SourceTable=Allretoffund_holding_temp1;*/
/*%let InputVar=End_Yr End_Mt End_Dy Stk_Name;*/
/*%let FlagVarType=FlagVarType1;*/
/*%ChkVarType(&SourceTable,&InputVar,&FlagVarType);*/
/**/
/*%mend;*/

/*编号：16*/
%macro ChkVar(SourceTable,InputVar,FlagVarExists);

/**********************************************************************/
/* 此宏的作用是检查某数据表中是否存在指定的变量。其中，SourceTable是 */
/* 原始表格；InputVar是指定的变量，若为多个变量，请用空格分隔；Flag_ */
/* VarExists是标记宏变量名称，=1表示变量存在，否则=0，若有多个InputVar*/
/* 变量，则不同位置上的1或0代表相应的变量是否存在。 */
/* */
/* 最终得到的是宏变量&FlagVarExists，若该数据表包含指定变量，则 */
/* &FlagVarExists=1，否则=0，若为多个变量，则不同位置上的1或0代表相应 */
/* 的变量是否存在。 */
/* */
/* Created on 2012.4.27 */
/* Modified on 2012.9.18 */
/**********************************************************************/

%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
%let CV_LibName=%UPCASE(%SCAN(&SourceTable,1,.));
%let CV_MemName=%UPCASE(%SCAN(&SourceTable,2,.));
%end;
%else %do;
%let CV_LibName=WORK;
%let CV_MemName=%UPCASE(&SourceTable);
%end;

%ChkDataSet(DataSet=&CV_LibName..&CV_MemName,FlagDataSetExists=CV_FlagDataSetExists);

%if &CV_FlagDataSetExists EQ 1 %then %do;
proc contents data=&SourceTable out=CV_temp(keep=name) noprint;
run;

%global &FlagVarExists;

%if %SYSFUNC(FIND(&InputVar,%STR( ))) NE 0 %then %do;
%SeparateString(InputString=&InputVar,OutputString=CV);

%do CV_i=1 %to &CV_Num;
%let CV_FlagVarExists&CV_i=0;

data _null_;
set CV_temp;
call symputx("CV_FlagVarExists&CV_i",'1');
where UPCASE(name)=UPCASE("&&CV_Var&CV_i.");
run;
%end;

%let &FlagVarExists=&&CV_FlagVarExists1;

%do CV_j=2 %to &CV_Num;
%let &FlagVarExists=&&&FlagVarExists.&&CV_FlagVarExists&CV_j;
%end;
%end;
%else %do;
%let &FlagVarExists=0;

data _null_;
set CV_temp;
call symputx("&FlagVarExists",'1');
where UPCASE(name)=UPCASE("&InputVar.");
run;
%end;
%end;
%else %if &CV_FlagDataSetExists EQ 0 %then %do;
%put ERROR: The DataSet &SourceTable does not exist, please check it again.;
%goto exit;
%end;
%else %do;
%put ERROR: There may be something wrong with the macro ChkDataSet, please contact the writer for help.;
%goto exit;
%end;

/* 若要显示&FlagVarExists的值，请取消下面的注释 */
/*%put &FlagVarExists=&&&FlagVarExists;*/

/* 删除不必要的表格 */
proc delete data=CV_temp;
run;

%exit:
%mend;

/*代码16案例*/
/*%macro Demo();*/
/**/
/*%let SourceTable=Allretoffund_holding_temp1;*/
/*%let InputVar=End_Yr End_Mt End_Dy End_Qt;*/
/*%let FlagVarExists=FlagVarExists1;*/
/*%ChkVar(&SourceTable,&InputVar,&FlagVarExists);*/
/*%let InputVar=End_Yr End_Mt End_Dy;*/
/*%let FlagVarExists=FlagVarExists2;*/
/*%ChkVar(&SourceTable,&InputVar,&FlagVarExists);*/
/**/
/*%mend;*/

/*编号：17*/
%macro ChkDataSet(DataSet,FlagDataSetExists);

/**********************************************************************/
/* 此宏用于检查指定的数据集是否存在。其中，DataSet是指定的数据集，若 */
/* 需要指定具体的逻辑库，则采用逻辑库.数据库的格式，可设多个数据集， */
/* 用空格分隔；FlagDataSetExists是标记宏变量名称，=1表示数据集存在， */
/* 否则=No，若指定了多个数据集，则不同位置上的1或0代表相应的数据集是 */
/* 否存在。另外需要注意，第一，当仅指定一个数据集时，若不指定逻辑库名 */
/* 称，而只指定数据集名称，此时若在SAS环境中只包含一个指定的数据集， */
/* 则标记宏变量FlagDataSetExists=1，若包含多个同名的数据集，则会报错；*/
/* 第二，当指定多个数据集时，若不指定逻辑库名称，则默认为WORK逻辑库。 */
/* */
/* 最终得到的是宏变量&FlagDataSetExists，若指定数据集存在，则有 */
/* &FlagDataSetExists=1，否则=0，若为多个数据集，则不同位置上的1或0代 */
/* 表相应的数据集是否存在。 */
/* */
/* Created on 2012.11.16 */
/* Modified on 2012.11.16 */
/**********************************************************************/

/* 检查DataSet的存在性 */
%if &DataSet EQ %STR( ) %then %do;
%put ERROR: The DataSet should not be blank, please check it again.;
%goto exit;
%end;

/* 开始进行计算 */
%global &FlagDataSetExists;

/* 情形一：仅设定一个数据集，此时若省略逻辑库名，则在所有逻辑库中查找同名的数据集并予以报告 */
%if %SYSFUNC(FIND(&DataSet,%STR( ))) EQ 0 %then %do;
/* 检查DataSet的合法性 */
%if %SYSFUNC(FIND(&DataSet,.)) NE 0 %then %do;
%let CDS_LibName=%UPCASE(%SCAN(&DataSet,1,.));
%let CDS_DataSet=%UPCASE(%SCAN(&DataSet,2,.));
%end;
%else %do;
%let CDS_LibName=%STR();
%let CDS_DataSet=%UPCASE(&DataSet);
%end;

%if &CDS_DataSet EQ %STR() %then %do;
%put ERROR: The DataSet should not be blank, please check it again.;
%goto exit;
%end;
%else %if &CDS_LibName NE %STR() %then %do;
%let &FlagDataSetExists=%SYSFUNC(EXIST(&CDS_LibName..&CDS_DataSet.));
%end;
%else %do;
proc sql noprint;
create table CDS_temp as
select * from sashelp.vtable
where memname="&CDS_DataSet";
quit;

proc sql noprint;
select count(*) into :CDS_DataSetNum from CDS_temp;
quit;

%if &CDS_DataSetNum EQ 0 %then %let &FlagDataSetExists=0;
%else %if &CDS_DataSetNum EQ 1 %then %let &FlagDataSetExists=1;
%else %do;
%put ERROR: There could be more than one DataSets with the same name appointed in different libraries, please reassign a LibName first.;
%goto exit;
%end;
%end;
%end;
/* 情形二：设定多个数据集，此时若省略逻辑库名，则默认为WORK逻辑库 */
%else %do;
%SeparateString(InputString=&DataSet,OutputString=CDS_DateSet);

%do CDS_i=1 %to &CDS_DateSet_Num;
/* 检查DataSet的合法性 */
%if %SYSFUNC(FIND(&&CDS_DateSet_Var&CDS_i,.)) NE 0 %then %do;
%let CDS_LibName_&CDS_i.=%UPCASE(%SCAN(&&CDS_DateSet_Var&CDS_i,1,.));
%let CDS_DataSet_&CDS_i=%UPCASE(%SCAN(&&CDS_DateSet_Var&CDS_i,2,.));
%end;
%else %do;
%let CDS_LibName_&CDS_i.=WORK;
%let CDS_DataSet_&CDS_i.=%UPCASE(&&CDS_DateSet_Var&CDS_i);
%end;

%let CDS_FlagDataSetExists_&CDS_i.=%SYSFUNC(EXIST(&&CDS_LibName_&CDS_i...&&CDS_DataSet_&CDS_i.));
%end;

%let &FlagDataSetExists=&&CDS_FlagDataSetExists_1;

%do CDS_j=2 %to &CDS_DateSet_Num;
%let &FlagDataSetExists=&&&FlagDataSetExists.&&CDS_FlagDataSetExists_&CDS_j;
%end;
%end;

/* 如果想要输出结果，请取消下面的注释 */
/*%put &&&FlagDataSetExists;*/

/* 删除不必要的表格 */
proc datasets lib=work nolist;
delete CDS_temp;
quit;


%exit:
%mend;

/*代码17案例*/
/*%macro Demo();*/
/**/
/*%let DataSet=Gfl_fundcodelist_mgrname Gfl_managersoffund; /* 数据集名称，可设为多个，用空格分隔 */*/
/*%let FlagDataSetExists=FlagDataSetExists1; /* 宏变量的名称，注意不能与参数名称相同*/*/
/*%ChkDataSet(&DataSet,&FlagDataSetExists);*/
/**/
/*%put &FlagDataSetExists1;*/
/**/
/*%mend;*/

/*编号：18*/
%macro SeparateString(InputString,OutputString);
/**********************************************************************/
/* 此宏用于将含有一组单词的字符串拆分为一个个的单词，并将这些单词依次 */
/* 存放于一系列宏变量之中。注意，字符串中单词的定义为由字母、数字和下 */
/* 下划线组成的一个整体，而分隔符可以为除字母、数字、下划线以及逗号之 */
/* 外的其他任意字符。其中InputString是所选的字符串，OutputString是输 */
/* 出的字符串前缀，不需要加最后的下划线。 */
/* */
/* 最终得到的是一组单词的宏变量&OutputString._Var1,&OutputString.Var2 */
/* 等以及字符串所含单词数量的宏变量&OutputString._Num。 */
/* */
/* Created on 2012.9.18 */
/* Modified on 2012.12.6 */
/**********************************************************************/

data SS_temp;
Str="&InputString";
run;

data SS_temp;
set SS_temp;
Words=0;
do while(SCAN(Str,Words+1,' ') NE "");
Words+1;
end;
run;

%global &OutputString._Num;

proc sql noprint;
select Words into :&OutputString._Num from SS_Temp;
quit;

%do SS_i=1 %to &&&OutputString._Num;
%global &OutputString._Var&SS_i;
%let &OutputString._Var&SS_i.=%SYSFUNC(SCAN(&InputString,&SS_i,' '));
%end;

/* 去除&OutputString._Num前后的空格 */
%let &OutputString._Num=%SYSFUNC(TRIM(&&&OutputString._Num));

/* 删除不必要的表格 */
proc delete data=SS_temp;
run;

%mend;

/*代码18案例*/
/*%macro Demo();*/
/**/
/*%let InputString=12 -24;*/
/*%let OutputString=a;*/
/*%SeparateString(&InputString,&OutputString);*/
/**/
/*%put &a_Num;*/
/*%put &a_Var2;*/
/**/
/*%mend;*/

/*编号：19*/
%macro ChkFile(OutFilePath);
/**********************************************************************/
/* 此宏的作用是检查指定路径的文件夹或文件是否存在。若指定路径包含文件 */
/* 名，则运行此宏后路径中包含的文件夹存在但文件不存在，方便以后操作； */
/* 若指定路径不包含文件名，则运行此宏后路径中包含的文件夹存在。其中， */
/* OutFilePath是指定的文件夹或文件路径。注意如果路径中包含文件名，则  */
/* 一定要写全文件名和其扩展名。                                       */
/*                                                                    */
/*                                      Created on 2011.9.29          */
/*                                      Modified on 2011.9.29         */
/**********************************************************************/

/* 情形1：当输入参数OutFilePath包含文件名时，注意文件名必须带后缀 */
%if %SYSFUNC(FIND(&OutFilePath,%Str(.))) NE 0 %then %do; 
        /* 得到OutFilePath中包含的文件名File和文件夹路径Dir */
        %let File=%SYSFUNC(SCAN(&OutFilePath,-1,\));
        %let Dir=%SYSFUNC(SUBSTR(&OutFilePath,1,%EVAL(%SYSFUNC(LENGTH(&OutFilePath))-%SYSFUNC(LENGTH(&File)))));

        options noxwait;

        %local rc1 fileref1;
        %local rc2 fileref2;
        %let rc1=%SYSFUNC(FILENAME(fileref1,&Dir));
        %let rc2=%SYSFUNC(FILENAME(fileref2,&OutFilePath));

        %if %SYSFUNC(FEXIST(&fileref1)) %then %do;
                %put NOTE: The directory "&Dir" exists.;
                %if %SYSFUNC(FEXIST(&fileref2)) %then %do;                /* 文件夹存在且文件也存在的情形 */
                        %SYSEXEC del &OutFilePath;
                        %put NOTE: The file "&File" also exists, and has been deleted.;
                        %end;
                %else %put NOTE: But the file "&File" does not exist.;                /* 文件夹存在且文件不存在的情形 */
                %end;
        %else %do;                /* 文件夹不存在的情形 */
                %SYSEXEC md &Dir;
                %put %SYSFUNC(SYSMSG()) The directory has been created.;
                %end; 

        %let rc1=%SYSFUNC(FILENAME(fileref1));
        %let rc2=%SYSFUNC(FILENAME(fileref2));
%end;

/* 情形2：当输入参数OutFilePath不包含文件名时 */
%else %do;
        options noxwait;

        %local rc fileref;
        %let rc=%SYSFUNC(FILENAME(fileref,&OutFilePath));
        %if %SYSFUNC(FEXIST(&fileref))  %then
                %put NOTE: The directory "&OutFilePath" exists.;
        %else %do; 
                %SYSEXEC md &OutFilePath;
                %put %SYSFUNC(SYSMSG()) The directory has been created.;
                %end; 
        %let rc=%SYSFUNC(FILENAME(fileref));
%end;

%mend;

/*编号19案例*/
/*%macro Demo();*/
/**/
/*%ChkFile(d:\temp\data.xls);*/
/**/
/*%mend;*/


/*编号：20*/
/*dopen()打开指定路径;dnum()返回一个路径下的成员个数;filename(x,y)将地址y的值赋给变量x;
dread()返回特定路径下某成员名字;*/
%MACRO GETFILES_IN_FOLDER(DIRNAME,TYP,DIRFILES)     ;/*参数有三个：路径，文件类型后缀,存入数据集*/
/*   %PUT %STR(----------->DIRNAME=&DIRNAME)        ;*/
/*   %PUT %STR(----------->TYP=&TYP)                ;*/
   /*str()作用与quote()类似，使宏内特殊变量可以解析*/
/*   %let rs=%sysfunc(exist(WORK.&DIRFILES.));*/
/*   %if rs ^= 0 %then %do;*/
   DATA WORK.&DIRFILES.                             ;     
   	RC = %sysfunc(FILENAME(DIR,&DIRNAME.))             ;/*把&DIRNAME值传给文件引用符"DIR"*/    
   	OPENFILE = %sysfunc(DOPEN(&DIR.));/*得到路径标示符OPENFILE，DOPEN是打开directory的sas内置函数*/
   %IF &OPENFILE. > 0 %THEN %DO                     ;/*如果OPENFILE>0表示正确打开路径*/        
     NUMMEM = %sysfunc(DNUM(OPENFILE))                  ;/*得到路径标示符OPENFILE中member的个数nummem*/        
     %DO II=1 %TO NUMMEM                      ;           
        NAME = %sysfunc(DREAD(OPENFILE,II))             ;/*用DREAD依次读取每个文件的名字到NAME*/           
        OUTPUT                              ;/*依次输出*/        
     %END;                                         
   %END;                                       
/*   %end;	 */
   KEEP NAME                                 ;/*只保留NAME列*/
RUN;                                            
PROC SORT                                      ;/*按照NAME排序*/     
    BY DESCENDING NAME                        ;
    %IF &TYP ^= ALL %THEN %DO                        ;/*是否过滤特定的文件类型&TYP*/     
      WHERE INDEX(UPCASE(NAME),UPCASE("&TYP.")); /*Y,则通过检索NAME是否包含&TYP的方式过滤文件类型*/
    %END                                           ;
RUN;                                            
%MEND;


/*编号：*/
/*生成混合矩阵 DSin 输入数据；ProbVar 估计违约概率变量；DVVar 实际违约状态变量；Cutoff 临界值；DSCM 混合矩阵数据集*/
%macro ConfMat(DSin, ProbVar, DVVar, Cutoff, DSCM);
data temp;
 set &DSin;
 if &ProbVar>=&Cutoff then _PDV=1;
  else _PDV=0;
 keep &DVVAR  _PDV;
run;

%local Ntotal P N TP TN FP FN;
proc sql noprint;
 select sum(&DVVar) into :P from temp;
 select count(*) into :Ntotal from temp;
 select sum(_PDV) into :TP from temp where &DVVar=1;
 select sum(_PDV) into :FP from temp where &DVVar=0; 
quit;
%let N=%eval(&Ntotal-&P);
%let FN=%eval(&P-&TP);
%let TN=%eval(&N-&FN);

/* Store the results in DSCM */
data &DSCM;
 TP=&TP;  TN=&TN;
 FP=&FP;  FN=&FN;
 P=&P;  N=&N;
 Ntotal=&Ntotal;
run;

/* Clean workspace */
proc datasets library=work nodetails nolist;
delete temp;
run; 
quit;

%mend;

/*编号：*/
/*生成用于绘制提升图的数据集，默认等分规模为10 DSin 输入数据；ProbVar 估计违约概率变量；DVVar 实际违约状态变量；DSLift 提升图结果数据集*/
%macro LiftChart(DSin, ProbVar, DVVar, DSLift);
/* Calculation of the Lift chart data from 
   the predicted probabilities DSin using 
   the PorbVar and DVVar. The lift chart data
   is stored in DSLift. We use 10 deciles. 
*/

/* Sort the observations using the predicted Probability in descending order*/
proc sort data=&DsIn;
	by descending &ProbVar;
run;

/* Find the total number of Positives */
%local P Ntot;
proc sql noprint;
	select sum(&DVVar) into:P from &DSin;
	select count(*) into: Ntot from &DSin;
quit;
%let N=%eval(&Ntot-&P); /* total Negative(Good) */

/* Get Count number of correct defaults per decile */
data &DSLift;
	set &DsIn nobs=nn ;
	by descending &ProbVar;
	retain Tile 1  SumP 0 TotP 0 SumN 0 TotN 0;
	Tile_size=ceil(NN/10);

	TilePer=Tile/10;

	label TilePer ='样本比例';
	label TileP='样本比例';

	if &DVVar=1 then SumP=SumP+&DVVar;
	else SumN=SumN+1;

	PPer=SumP/&P;			/* Positive  % */
	NPer=SumN/&N;           /* Negative % */

	label PPer='"好"客户的比例';
	label NPer='"坏"客户的比例';

	if _N_ = Tile*Tile_Size then 	do;
		output;
		if Tile <10 then  Tile=Tile+1;
	end;	

	keep TilePer PPer NPer;
run;

/* Add the zero value to the curve */
data temp;
 	TilePer=0;
	PPer=0;
	NPer=0;
run;
Data &DSLift;
  set temp &DSlift;
run;
%mend;

%macro PlotLift(DSLift);
/*绘制提升图*/

goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftitle=swissb ftext=swiss htitle=6 htext=4;

symbol1 color=red
        interpol=join
        value=dot
        height=3;

proc gplot data=&DSLift;
   plot PPer*TilePer / haxis=0 to 1 by 0.1
                    vaxis=0 to 1 by 0.1
                    hminor=3
                    vminor=1
 
                      vref=0.2 0.4 0.6 0.8 1.0
                    lvref=2
                    cvref=blue
                    caxis=blue
                    ctext=red;
run;
quit;
 
	goptions reset=all;
%mend;


/*编号：*/
/*使用洛伦兹曲线的数据计算基尼统计量 DSin 输入数据；ProbVar 估计违约概率变量；DVVar 实际违约状态变量；DSLorenz 包含洛伦兹曲线数据的数据集；M_Gini 基尼统计量值的返回值*/
%macro GiniStat(DSin, ProbVar, DVVar, DSLorenz, M_Gini);
/* Calculation of the Gini Statistic from the results of 
   a predictive model. DSin is the dataset with a dependent
   variable DVVar, and a predicted probability ProbVar. 
   The Gini coefficient is returnd in the parameter M_Gini. 
   DSLorenz contains the data of the Lorenz curve. 

*/
/* Sort the observations using the predicted Probability */
proc sort data=&DsIn;
by &ProbVar;
run;

/* Find the total number of responders */
proc sql noprint;
 select sum(&DVVar) into:NResp from &DSin;
 select count(*) into :NN from &DSin;
 quit;


 /* The base of calculation is 100  */

/* Get Count number of correct Responders per decile */
data &DSLorenz;
set &DsIn nobs=NN;
by &ProbVar;
retain tile 1  TotResp 0;
Tile_size=ceil(NN/100);

TotResp=TotResp+&DVVar;
TotRespPer=TotResp/&Nresp;

if _N_ = Tile*Tile_Size then 
  do;
  output;
   if Tile <100 then  
       do;
         Tile=Tile+1;
		 SumResp=0;
	   end;
  end;	
keep Tile TotRespPer;
run;
/* add the point of zero to the Lorenz data */
data temp;
 Tile=0;
 TotRespPer=0;
 run;
 Data &DSLorenz;
  set temp &DSLorenz;
run;


/* Scale the tile to represent percentage */
data &DSLorenz;
set &DSLorenz;
Tile=Tile/100;
label TotRespPer='“好”客户比例';
label Tile ='样本比例';

run;

/* produce a simple plot of the Lorenze cruve the uniform response 
   if the IPlot is set to 1 */

/* Calculate the Gini coefficient from the approximation of the Lorenz
   curve into a sequence of straight line segments and using the 
   trapezoidal integration approximation.
   G=1 - Sum_(k=1)^(n)[X_k - X_(k-1)]*[Y_k + Y_(k-1)]
*/
data _null_; /* use the null dataset for the summation */
retain Xk 0 Xk1 0 Yk 0 Yk1 0 G 1;
set &DSLorenz;
Xk=tile;
Yk=TotRespPer;
G=G-(Xk-Xk1)*(Yk+Yk1);

/* next iteration */
Xk1=Xk;
Yk1=Yk;

/* output the Gini Coefficient */
call symput ('G', compress(G));
run;
/* store the Gini coefficient in the parameter M_Gini */

%let &M_Gini=&G;
/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete temp ;
run;
quit;

%mend;


/*编号：*/
/*使用基尼统计量绘制洛伦兹曲线 DSLorenz 包含洛伦兹曲线数据的数据集*/
%macro PlotLorenz(DSLorenz);

goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftitle=swissb ftext=swiss htitle=6 htext=4;


symbol1 color=red
        interpol=join
        value=dot
        height=1;
 
  proc gplot data=&DSLorenz;
   plot TotRespPer*Tile / haxis=0 to 1 by 0.2
                    vaxis=0 to 1 by 0.2
                    hminor=3
                    vminor=1
 
                      vref=0.2 0.4 0.6 0.8 1.0
                    lvref=2
                    cvref=blue
                    caxis=blue
                    ctext=red;
run;
quit;
 
	goptions reset=all;
%mend;

/*编号：*/
/*使用K-S统计量绘制K-S曲线 DSin 输入数据；ProbVar 估计违约概率变量；DVVar 实际违约状态变量； DSKS 包含K-S曲线数据的数据集； M_Gini K-S统计量的返回值*/
/*K-S值的意义：K-S值越大，表示评分模型能够将“好”、“坏”客户区分开来的程度越大。*/
/*K-S 曲线：将所有申请者的信用评分由小到大排列，分别计算每一个分数之下“好”、“坏”帐户累计所占的百分比，再将这两种累计百分比与评分做在同一张图形上，得到K-S曲线。*/
/*K-S值：各分数下对应的累计“坏”帐户百分比与累计“好”帐户百分比之差的最大值。*/
%macro KSStat(DSin, ProbVar, DVVar, DSKS, M_KS);
/* Calculation of the KS Statistic from the results of 
   a predictive model. DSin is the dataset with a dependent
   variable DVVar, and a predicted probability ProbVar. 
   The KS statistic is returnd in the parameter M_KS. 
   DSKS contains the data of the Lorenz curve for good and bad
   as well as the KS Curve. 
*/

/* Sort the observations using the predicted Probability */
proc sort data=&DsIn;
by &ProbVar;
run;

/* Find the total number of Positives and Negatives */
proc sql noprint;
 select sum(&DVVar) into:P from &DSin;
 select count(*) into :Ntot from &DSin;
 quit;
 %let N=%eval(&Ntot-&P); /* Number of negative */


 /* The base of calculation is 100 tiles */

/* Count number of positive and negatives per tile, their proportions and 
    cumulative proportions decile */
data &DSKS;
set &DsIn nobs=NN;
by &ProbVar;
retain tile 1  totP  0 totN 0;
Tile_size=ceil(NN/100);

if &DVVar=1 then totP=totP+&DVVar;
else totN=totN+1;

Pper=totP/&P;
Nper=totN/&N;

/* end of tile? */
if _N_ = Tile*Tile_Size then 
  do;
  output;
   if Tile <100 then  
       do;
         Tile=Tile+1;
		 SumResp=0;
	   end;
  end;	
keep Tile Pper Nper;
run;

/* add the point of zero  */
data temp;
	 Tile=0;
	 Pper=0;
	 NPer=0;
run;

Data &DSKS;
  set temp &DSKS;
run;

 
/* Scale the tile to represent percentage and add labels*/
data &DSKS;
	set &DSKS;
	Tile=Tile/100;
	label Pper='Percent of Positives';
	label NPer ='Percent of Negatives';
	label Tile ='Percent of population';

	/* calculate the KS Curve */
	KS=NPer-PPer;
run;

/* calculate the KS statistic */

proc sql noprint;
 select max(KS) into :&M_KS from &DSKS;
run; quit;

/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete temp ;
run;
quit;

%mend;

/*编号：*/
/*使用K-S统计量绘制K-S曲线 DSKS 包含K-S曲线数据的数据集*/
%macro PlotKS(DSKS);
/* Plotting the KS curve using gplot using simple options */

 symbol1 value=dot color=red   interpol=join  height=1;
 legend1 position=top;
 symbol2 value=dot color=blue  interpol=join  height=1;
 symbol3 value=dot color=green interpol=join  height=1;

proc gplot data=&DSKS;

  plot( NPer PPer KS)*Tile / overlay legend=legend1;
 run;
quit;
 
	goptions reset=all;
%mend;


