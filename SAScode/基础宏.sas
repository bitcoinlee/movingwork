/*���:1*/
%macro GetFileAndSubDirInfoInDir(InDirPath,Filter,TargetTable,OutFilePath,Expand);
/**********************************************************************/
/* �˺����ڻ��Ŀ���ļ����������ļ������ļ��е���Ϣ����������Ϣ������ */
/* SAS���򵼳���txt�ļ��С����У�InDirPath��ָ����Ŀ���ļ���·����  */
/* ·�����Ҫ����\��Filter���ļ��������ã�֧��*��?ͨ���������Ҫ����  */
/* �����ļ��б���������Ϊ�գ�TargetTable�Ǳ����ļ���Ϣ��SAS����� */
/* ����Ҫ���ɣ�������Ϊ�գ�OutFilePath�ǵ���txt�ļ���·����������Ҫ�� */
/* ����������Ϊ�գ�Expand�Ǳ�Ǳ�����=Yes��ʾչ�������ļ��У��б���� */
/* �����ļ����������ļ�����Ϣ��=NO��ʾֻ�г�Ŀ���ļ����µ�һ���ļ���  */
/* �ļ��е���Ϣ��                                                     */
/*                                                                    */
/* ���յõ����Ǻ���Ŀ���ļ����������ļ������ļ�����Ϣ��SAS���ʹ���  */
/* ָ��·����txt�ļ���                                                */
/*                                                                    */
/* ע�����д˺���ܻ�����������ȵĴ�����Ϣ��������������DIR����õ�  */
/* �����������ʽ��һ������ģ�������Ӱ��������ȷ�ԡ�             */
/*                                                                    */
/**********************************************************************/
/* ȷ��InDirPath���\���� */
%if %SYSFUNC(FIND(%SYSFUNC(REVERSE(&InDirPath)),\)) NE 1 %then %let InDirPath=&InDirPath.\;
/* �ر���ʾLOG��Ϣ */
options nosource nonotes errors=0;
/* ��һ�������Ƚ�InDirPath�ļ����������ļ�����Ϣ������OutFilePath�ļ��� */
/* ����1������OutFilePathΪ�����ļ�·������ */
%if %SYSFUNC(FIND(&OutFilePath,%STR(.))) NE 0 %then %do;
/* ����1-1��չ�������ļ��� */
%if %UPCASE(&Expand) EQ YES %then %do;
  %ChkFile(&OutFilePath);
  options noxwait xsync;
  x "dir &InDirPath.&Filter /s /a > &OutFilePath";
%end;
/* ����1-2����չ���ļ��У�ֻ������һ�����ļ��к��ļ�����Ϣ */
%else %if %UPCASE(&Expand) EQ NO %then %do;
  %ChkFile(&OutFilePath);
  options noxwait xsync;
  x "dir &InDirPath.&Filter > &OutFilePath";
%end;
/* ����1-3����������Expand�������� */
%else %do;
  %put ERROR: The last parameter should be Yes or No, case insensitive and without quotes.;
  %goto exit;
%end;
%end;
/* ����2������OutFilePathΪ������ */
%else %if %UPCASE(&OutFilePath) EQ %STR() %then %do;
/* ����2-1��չ�������ļ��� */
%if %UPCASE(&Expand) EQ YES %then %do;
  options noxwait xsync;
  x "dir &InDirPath.&Filter /s /a > d:\GFASDIID_temp.txt";
  %let OutFilePath=d:\GFASDIID_temp.txt;
%end;
/* ����2-2����չ���ļ��У�ֻ������һ�����ļ��к��ļ�����Ϣ */
%else %if %UPCASE(&Expand) EQ NO %then %do;
  options noxwait xsync;
  x "dir &InDirPath.&Filter > d:\GFASDIID_temp.txt";
  %let OutFilePath=d:\GFASDIID_temp.txt;
%end;
/* ����2-3����������Expand�������� */
%else %do;
  %put ERROR: The Expand should be Yes or No, case insensitive and without quotes.;
  %goto exit;
%end;
%end;
/* ����3����������OutFilePath�������� */
%else %do;
%put ERROR: The OutFilePath should contain the full path of directory, including filename and filename extension.;
%goto exit;
%end;
/* �ڶ��������Ž�OutFilePath�ļ�����Ϣ����SAS���ݱ��� */
/* ��Ҫ����SAS���ݱ����� */
%if %UPCASE(&TargetTable) NE %STR() %then %do;
/* ����1��չ�������ļ��У���ʱ�ӵ�4�п�ʼ�� */
%if %UPCASE(&Expand) EQ YES %then %do;
  data GFASDIID_temp;
   infile "&OutFilePath." firstobs=4 truncover;
   input DataString $ 1-1000 @; /* ��ȡ�ĵ�һ����������������Ϊ10��@��ʾ��겻���ƣ�������ȡ���� */
   input @1 Date YYMMDD10. @13 Time TIME. @19 Bytes_temp $17. @37 FileName $64.;
   if (FIND(DataString,'<DIR>') EQ 0) AND (FIND(DataString,'\') NE 0 OR Date NE .);
   format Date YYMMDD10. Time HHMM.;
  run;
  data &TargetTable(drop=DataString Bytes_temp);
   retain Date Time Bytes FileName DirPath;
   set GFASDIID_temp;
   Bytes=INPUT(Bytes_temp,COMMA17.);
   format Bytes COMMA17.;
   if FIND(DataString,'\') NE 0 then DirPath=kCOMPRESS(DataString,'��Ŀ¼');
   if Date NE .;
  run;
%end;
/* ����2����չ���ļ��У�ֻ������һ�����ļ��к��ļ�����Ϣ����ʱ�ӵ�8�п�ʼ�� */
%else %do;
  data GFASDIID_temp(drop=DataString);
   infile "&OutFilePath" firstobs=8 truncover;
   input DataString $ 1-1000 @; /* ��ȡ�ĵ�һ����������������Ϊ10��@��ʾ��겻���ƣ�������ȡ���� */
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
/* ����Ҫ��SAS��Output�����д�ӡ�ļ��б���ȡ������ע�� */
/*proc print data=&TargetTable;*/
/*title1 "Files identified through saved file";*/
/*run;*/
/* ɾ������Ҫ�ı�� */
proc delete data=GFASDIID_temp;
run;
/* �ָ���ʾLOG��Ϣ */
options source notes errors=5;
%if &OutFilePath=d:\GFASDIID_temp.txt %then x "erase d:\GFASDIID_temp.txt";
%exit:
%mend;

/*%macro Demo();*/
/*%let InDirPath=e:\Works\;*/
/*%let Filter=*.sas;  /* �ļ��������ã�����Ҫ���������ļ��б�������Ϊ�ռ��ɣ���Filter=; */*/
/*%let TargetTable=FileList;  /* ������Ҫ���ɰ����ļ��б��SAS�������Ϊ�գ���Сд������ */*/
/*%let OutFilePath=;  /* ������Ҫ�����ļ��б�txt�ļ�������Ϊ�գ���Сд������ */*/
/*%let Expand=Yes;  /* =Yes��ʾչ�������ļ��У��б��������ļ����������ļ�����Ϣ������=No����Сд������ */*/
/*%GetFileAndSubDirInfoInDir(&InDirPath,&Filter,&TargetTable,&OutFilePath,&Expand);*/
/*%mend;*/


/*��ţ�2*/
%macro PrxChange(InputString,PrxString);

/**********************************************************************/
/* �˺�����������ʽ�ķ����滻ԭʼ�ַ�����ƥ���Ӵ�ΪĿ���Ӵ������У� */
/* InputString��ԭʼ�ַ�����PrxString��ָ���Ӵ���������ʽ��ע������ */
/* ���ʽҪ��/.../������������                                        */
/*                                                                    */
/* ����ԭʼ�ַ����е�ƥ���Ӵ��滻ΪĿ���Ӵ���ע�������滻�Ӵ�������� */
/* ��ʽ���磺s/SourceString/TargetString/                             */
/*                                                                    */
/*                                      Created on 2012.8.6           */
/*                                      Modified on 2012.8.6          */
/**********************************************************************/

%local PrxStringID RegRt;

%let RegRt=0;
%let PrxStringID=%SYSFUNC(PRXPARSE(&PrxString));

%if &PrxStringID GT 0 %then %do;
        %let RegRt=%SYSFUNC(PRXCHANGE(&PrxStringID, -1, &InputString));                /* -1��ʾȫ���滻 */
%end;

%syscall PrxFree(PrxStringID);
%str(&RegRt)                /* �����Ҫ�ӷֺ� */

%mend;


/*%macro Demo();*/
/**/
/*/* replace the matching string to target string */*/
/*%let zip=%PrxChange(InputString=Jones Fred,PrxString=s/(\w+) (\w+)/$2 $1/);*/
/*%put &zip;*/
/**/
/*%mend;*/

/*��ţ�3*/
%macro PrxMatch(InputString,PrxString);

/**********************************************************************/
/* �˺�����������ʽ�ķ��������ַ������Ƿ������ָ�����Ӵ������У�   */
/* InputString��ԭʼ�ַ�����PrxString��ָ���Ӵ���������ʽ��ע������ */
/* ���ʽҪ��/.../������������                                        */
/*                                                                    */
/* ������ƥ��ɹ����򷵻�1�����򷵻�0��                               */
/*                                                                    */
/* ���⣬�˺�ѡȡ��"Using PRX to Search and Replace Patterns in SAS   */
/* Programming"�����ԼӸĶ���                                         */
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
%str(&reg;rt)               /* �����Ҫ�ӷֺ� */

%mend;


/*%macro Demo();*/
/**/
/*/* test whether there is a match or not */*/
/*%let zip=%PrxMatch(InputString=34567-2345,PrxString=/\d{5}-\d{4}/);*/
/*%put &zip;*/
/**/
/*%mend;*/

/*��ţ�4*/
%macro GetStatsForTable(SourceTable,TargetTable,ByFactors,InputVar,InputVarType,OutputVarType,Weight,Statistic);

/**********************************************************************/
/* �˺������ѡ������ͳ��ָ�ꡣ����SourceTable�Ǻ�����ѡ������ԭʼ�� */
/* ��TargetTable�ǽ�����ByFactors�Ƕ�ͳ�������з����о��ķ���� */
/* ����û�з������ʱ������Ϊ�գ�InputVar�ǽ���ͳ�Ƶ�Ŀ�����������Ҫ */
/* ͳ��ȫ��������ȫ����ֵ������ȫ���ַ��������ɷֱ���Ϊ_ALL_�� */
/* _NUMERIC_��_CHARACTER_��InputVarType��Ŀ����������ͣ���Statistic= */
/* GMEANʱ�������ã�=P��ʾ�۸������=R��ʾ�����ʱ�����OutputVarType�� */
/* ������������ͣ�=Origin��ʾ��������������������Ƶ���Ŀ������� */
/* ���ƣ�����_STAT_�������ֲ�ͬ��ͳ������=Suffix��ʾ��������ò�ͬ�� */
/* ͳ������Ϊ��׺��Weight��Ȩ�ر�����Statistic��ָ����ͳ������=Allʱ */
/* ͬʱ����N|MIN|MAX|MEAN|STD��Ҳ���Ե������ã��������õ�ͳ���������� */
/* ʾ�� */
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
/* ���յõ����Ǻ���ͳ�ƽ���Ľ�����&TargetTable�� */
/* */
/* Created on 2012.12.25 */
/* Modified on 2013.4.28 */
/**********************************************************************/

/* ���TargetTable�Ĵ����ԣ�������������Ϊ&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* ���ByFactors�Ĵ����� */
%if &ByFactors NE %STR() %then %do;
%ChkVar(SourceTable=&SourceTable,InputVar=&ByFactors,FlagVarExists=GSFT_FlagVarExists1);

%if %SYSFUNC(FIND(&GSFT_FlagVarExists1,0)) NE 0 %then %do;
%put ERROR: The ByFactors "%SCAN(&ByFactors,%SYSFUNC(FIND(&GSFT_FlagVarExists1,0)))" does not exist in SourceTable, please check it again.;
%goto exit;
%end;

/* ���ŷָ���ByFactors_Comma����SQL��� */
%local ByFactors_Comma;

%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
%let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %do;
%let ByFactors_Comma=&ByFactors;
%end;
%end;


/* ���InputVar�Ĵ����� */
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

/* ���InputVarType�ĺϷ��� */
%if %UPCASE(&Statistic) EQ GMEAN %then %do;
%if (%UPCASE(&InputVarType) NE P) AND (%UPCASE(&InputVarType) NE R) %then %do;
%put ERROR: The InputVarType should be P or R, case insensitive and without quotes.;
%goto exit;
%end;
%end;

/* ���InputVar */
%SeparateString(InputString=&InputVar,OutputString=GSFT_InputVar);

/* ���OutputVarType�ĺϷ��� */
%if &OutputVarType EQ %STR() %then %let OutputVarType=Origin;

%if (%UPCASE(&OutputVarType) NE ORIGIN) AND (%UPCASE(&OutputVarType) NE SUFFIX) %then %do;
%put ERROR: The OutputVarType should be Origin or Suffix, case insensitive and without quotes.;
%goto exit;
%end;

/* ���Weight��Ψһ�Ժʹ����� */
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

/* ���Statistic��Ψһ�� */
%if %SYSFUNC(FIND(&Statistic,%STR( ))) NE 0 %then %do;
%put ERROR: There should be only one Statistic, please check it again.;
%goto exit;
%end;

/* ȷ��ָ����ͳ������N|MIN|MAX|MEAN|STDΪStatGroup1������������ͳ����ΪStatGroup2��SVARΪGroup3��GMEANΪGroup4 */
%let Statistic=%UPCASE(&Statistic);
%let GSFT_StatGroup1=%PrxMatch(InputString=&Statistic,PrxString=/((?<!\w)N(?!\w))|(MIN)|(MAX)|((?<!\w)MEAN(?!\w))|(STD)|(ALL)/);
/* ��������ʽGSFT_StatGroup2�ֲ�����Σ����ⱨ�� */
%let GSFT_StatGroup2a=%PrxMatch(InputString=&Statistic,PrxString=/(CSS)|(RANGE)|(CV)|(SKEW)|(KURT)|(LCLM)|(STDERR)|((?<!\w)SUM(?!\w))|(SUMWGT)|(UCLM)|(MODE)|(USS)|((?<!\w)VAR(?!\w))|(NMISS)|(MEDIAN)/);
%let GSFT_StatGroup2b=%PrxMatch(InputString=&Statistic,PrxString=/(Q1)|(Q3)|(P1(?!0))|(P5)|(P10)|(P25)|(P50)|(P75)|(P90)|(P95)|(P99)|(QRANGE)|(PRT)|((?<!\w)T(?!\w))/);
%let GSFT_StatGroup3=%PrxMatch(InputString=&Statistic,PrxString=/(SVAR)/);
%let GSFT_StatGroup4=%PrxMatch(InputString=&Statistic,PrxString=/(GMEAN|GSUM)/);

%if &GSFT_StatGroup1 EQ 0 AND &GSFT_StatGroup2a EQ 0 AND &GSFT_StatGroup2b EQ 0 AND &GSFT_StatGroup3 EQ 0 AND &GSFT_StatGroup4 EQ 0 %then %do;
%put ERROR: The Statistic should be assigned properly, please check it again.;
%goto exit;
%end;

/* ��ʼ���м��� */
/* ��һ�����õ�ͳ���� */
/* ����һ�������һ��ͳ���� */
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
/* ���ζ�������ڶ���ͳ���� */
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
/* �����������������ͳ������SVAR�����뷽�� */
%else %if &GSFT_StatGroup3 NE 0 %then %do;
/* ���ŷָ���ByFactors_Comma����SQL��� */
%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
%let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %let ByFactors_Comma=&ByFactors;

/* ��һ������������ֵ */
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

/* �ڶ����������������ƽ�� */
data GSFT_SqrDev;
set GSFT_Mean;
%do GSFT_j=1 %to &GSFT_InputVar_Num;
if &&GSFT_InputVar_Var&GSFT_j LT &&GSFT_InputVar_Var&GSFT_j.._Mean then &&GSFT_InputVar_Var&GSFT_j.._SqrDev=(&&GSFT_InputVar_Var&GSFT_j..-&&GSFT_InputVar_Var&GSFT_j.._Mean)**2;
else &&GSFT_InputVar_Var&GSFT_j.._SqrDev=0;
%end;
run;

/* ���������������뷽�� */
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
/* �����ģ����������ͳ������GMEAN������ƽ��ֵ����GSUM�����˻��� */
%else %if &GSFT_StatGroup4 NE 0 %then %do;
%if %UPCASE(%SUBSTR(&InputVarType,1,1)) EQ P %then %do; /* ����InputVarType������ĸ�����жϣ�P�ɴ���Price/PNL */
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

/* �ڶ�������Ҫ�������� */
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

/* ɾ������Ҫ�ı�� */
proc datasets lib=work nolist;
delete GSFT_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=NavOfFund;*/
/*%let TargetTable=NavOfFund_GMean;*/
/*%let ByFactors=Fund_Code; /* ������Ϊ������ÿո�ָ� */*/
/*%let InputVar=Adj_NAV Unit_NAV;*/
/*%let InputVarType=; /* ��Statistic=GMEANʱ�������ã�=P��ʾ�۸������=R��ʾ�����ʱ��� */*/
/*%let OutputVarType=Suffix; /* ������������ͣ�=Origin��ʾ��������=Suffix��ʾ��������ò�ͬ��ͳ������Ϊ��׺ */*/
/*%let Weight=; /* ��Ϊһ������ */*/
/*%let Statistic=All; /* ��Ϊһ��ͳ���� */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*/* ���㼸��ƽ�������ʵ����ӣ���InputVar����Ϊ�۸���� */*/
/*%let SourceTable=ReturnOfFund_Dy;*/
/*%let TargetTable=ReturnOfFund_GMean;*/
/*%let ByFactors=Fund_Code; /* ������Ϊ������ÿո�ָ� */*/
/*%let InputVar=Adj_NAV;*/
/*%let InputVarType=P; /* ��Statistic=GMEANʱ�������ã�=P��ʾ�۸������=R��ʾ�����ʱ��� */*/
/*%let OutputVarType=; /* ������������ͣ�=Origin��ʾ��������=Suffix��ʾ��������ò�ͬ��ͳ������Ϊ��׺ */*/
/*%let Weight=; /* ��Ϊһ������ */*/
/*%let Statistic=GMEAN; /* ��Ϊһ��ͳ���� */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*/* ���㼸�����˻������ӣ���InputVar����Ϊ�����ʱ��� */*/
/*%let SourceTable=GARFP_AbnRetOfPort;*/
/*%let TargetTable=GARFP_AbnRetOfPort_GSUM;*/
/*%let ByFactors=Port_Code End_Yr End_Mt; /* ������Ϊ������ÿո�ָ� */*/
/*%let InputVar=Ret_Dy Ret_Bm AbnRet_Dy AbnRetRatio_Dy;*/
/*%let InputVarType=R; /* ��Statistic=GMEANʱ�������ã�=P��ʾ�۸������=R��ʾ�����ʱ��� */*/
/*%let OutputVarType=; /* ������������ͣ�=Origin��ʾ��������=Suffix��ʾ��������ò�ͬ��ͳ������Ϊ��׺ */*/
/*%let Weight=; /* ��Ϊһ������ */*/
/*%let Statistic=GSUM; /* ��Ϊһ��ͳ���� */*/
/*%GetStatsForTable(&SourceTable,&TargetTable,&ByFactors,&InputVar,&InputVarType,&OutputVarType,&Weight,&Statistic);*/
/**/
/*%mend;*/

/*���:5*/
%macro GetCountForSeq(SourceTable,TargetTable,ByFactors,InputVar,OutputVar);

/**********************************************************************/
/* �˺�������Ǽ���ĳ���ݱ���ָ���������ظ�����������������ͬһֵ�Ĵ� */
/* �������У�SourceTable��ԭʼ���TargetTable�ǽ�����ByFactors  */
/* �Ƿ��������InputVar��Ŀ�������������Ϊ������ÿո�ָ���Output_  */
/* Var�ǽ����������ֵΪ�ù۲�ֵ���������ظ��Ĵ���������ָ������Ϊԭ  */
/* Ŀ�������Ӻ�׺_Cnt��ע�⣬�����б���֮ǰ��Ҫ��ԭʼ�����к��ʵ� */
/* ����                                                             */
/*                                                                    */
/* ���յõ�����ԭ���ݱ���ָ���������ظ������Ľ�����               */
/*                                                                    */
/*                                      Created on 2012.12.21         */
/*                                      Modified on 2013.3.20         */
/**********************************************************************/

/* ���TargetTable�Ĵ����ԣ�������������Ϊ&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* ���ByFactors�Ĵ����� */
%if &ByFactors NE %STR() %then %do;
        %ChkVar(SourceTable=&SourceTable,InputVar=&ByFactors,FlagVarExists=GCFS_FlagVarExists1);

        %if %SYSFUNC(FIND(&GCFS_FlagVarExists1,0)) NE 0 %then %do;
                %put ERROR: The ByFactors "%SCAN(&ByFactors,%SYSFUNC(FIND(&GCFS_FlagVarExists1,0)))" does not exist in SourceTable, please check it again.;
                %goto exit;
        %end;
%end;

/* ���InputVar�Ĵ����� */
%ChkVar(SourceTable=&SourceTable,InputVar=&InputVar,FlagVarExists=GCFS_FlagVarExists2);

%if %SYSFUNC(FIND(&GCFS_FlagVarExists2,0)) NE 0 %then %do;
        %put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&GCFS_FlagVarExists2,0)))" does not exist in SourceTable, please check it again.;
        %goto exit;
%end;

/* ���InputVar */
%SeparateString(InputString=&InputVar,OutputString=GCFS_InputVar);

/* ���OutputVar�ĺϷ��� */
%if &OutputVar NE %STR() AND %SYSFUNC(COUNT(&InputVar,%STR( ))) NE %SYSFUNC(COUNT(&OutputVar,%STR( ))) %then %do;
        %put ERROR: The number of InputVar and OutputVar should be equal, please check it again.;
        %goto exit;
%end;

/* ��OutputVarΪ�գ�������ΪInputVar���_Cnt��׺ */
%if &OutputVar EQ %STR() %then %do;
        %let OutputVar=%SYSFUNC(TRANWRD(&InputVar,%STR( ),_Cnt%STR( )))_Cnt;
%end;

/* ���OutputVar */
%SeparateString(InputString=&OutputVar,OutputString=GCFS_OutputVar);

/* ��ʼ���м��� */
/* ��һ���������µķ������ */
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

/* �ڶ������õ��������� */
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

/* ɾ����ʱ���ɵ�OrderVar */
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
/*%let InputVar=PE_Rank;                /* ��Ҫ�����Ŀ�������������Ϊ������ÿո�ָ� */*/
/*%let OutputVar=;*/
/*%GetCountForSeq(&SourceTable,&TargetTable,&ByFactors,&InputVar,&OutputVar);*/
/**/
/*%mend;*/

/*��ţ�6*/
%macro ChkDummyVar(SourceTable,InputVar,FlagIsDummyVar);

/**********************************************************************/
/* �˺�������Ǽ��ĳ���ݱ��е�ָ�������Ƿ�Ϊ�����������ȡֵֻ��Ϊ0  */
/* ��1�����У�SourceTable��ԭʼ���InputVar��ָ���ı�������Ϊ����� */
/* �������ÿո�ָ���FlagIsDummyVar�Ǳ�Ǻ�������ƣ�=1��ʾ����Ϊ���� */
/* ����������=0�����ж��InputVar��������ͬλ���ϵ�1��0������Ӧ�ı� */
/* ���Ƿ������������ע�⣬��ĳ����������0��1֮�⣬������ȱʧֵ������ */
/* Ȼ��Ϊ��Ϊ���������                                               */
/*                                                                    */
/* ���յõ����Ǻ����&FlagIsDummyVar���������ݱ���ָ������Ϊ���������*/
/* ��&FlagIsDummyVar=1������=0����Ϊ�����������ͬλ���ϵ�1��0����  */
/* ��Ӧ�ı����Ƿ�Ϊ���������                                         */
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

/* ���SourceTable�Ĵ����� */
%ChkDataSet(DataSet=&CDV_LibName..&CDV_MemName,FlagDataSetExists=CDV_FlagDataSetExists);

%if &CDV_FlagDataSetExists EQ 0 %then %do;
        %put ERROR: The DataSet &SourceTable does not exist, please check it again.;
        %goto exit;
%end;

/* ���InputVar�Ĵ����� */
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

/* ���InputVar */
%SeparateString(InputString=&InputVar,OutputString=CDV_InputVar);

/* ��ʼ���м��� */
%global &FlagIsDummyVar;

%let &FlagIsDummyVar=;

/* ���InputVar�ĸ�ʽ����Ϊ�ַ��ͣ���һ������������� */
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

/* ��Ҫ��ʾ&FlagIsDummyVar��ֵ����ȡ�������ע�� */
/*%put &FlagIsDummyVar=&&&FlagIsDummyVar;*/

%exit��
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

/*��ţ�7*/
%macro DropEmptyTables(LibName,Filter);

/**********************************************************************/
/* �˺�����ɾ��ָ���߼����еĿձ�Ҳ���۲�ֵΪ��ı������LibName  */
/* ��ָ���߼������ƣ�Filter���ļ��������ã�=Nullʱɾ��ȫ���ձ�����  */
/* _��%��SQL��like�Ӿ��ͨ���ʱɾ��ָ��ǰ��׺�Ŀձ��������κ�ͨ��  */
/* ��ʱɾ��ָ���ձ���ָ����Ϊ����ɾ����                         */
/*                                                                    */
/* ����ָ���߼��������з��������Ŀձ�ȫ����ɾ����                     */
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
/*%let Filter="a%";                /* =Nullʱɾ��ȫ���ձ�����_��%��SQL��like�Ӿ��ͨ���ʱɾ��ָ��ǰ��׺�Ŀձ�ע���ʱҪ��˫���ţ��������κ�ͨ���ʱɾ��ָ���ձ� */*/
/*%DropEmptyTables(&LibName,&Filter);*/
/**/
/*%mend;*/

/*���:8*/
%macro DeleteMissObs(SourceTable,TargetTable,MissingVar);
/**********************************************************************/
/* �˺�ɾ��ԭ����ָ������Ϊȱʧֵ�Ĺ۲⡣����SourceTable��ԭʼ���  */
/* TargetTable�ǽ�����MissingVar�ǿ��ܺ���ȱʧֵ�ı�����=_Numeric_*/
/* ��ʾѡ��ȫ����ֵ�ͱ�����=_Character_��ʾѡ��ȫ���ַ��ͱ�����=_All_ */
/* ��ʾѡ��ȫ��������Ҳ����ѡ�����������ÿո�ָ���                 */
/*                                                                    */
/* ���ս�������ָ������Ϊȱʧֵ�Ĺ۲ⱻɾ����                       */
/*                                                                    */
/*                                      Created on 2013.1.10          */
/*                                      Modified on 2013.2.5          */
/**********************************************************************/

/* ���TargetTable�Ĵ����ԣ�������������Ϊ&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* ���MissingVar�Ĵ����� */
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

/* �����ŵ�MissingVar_Quote����SQL���� */
%let MissingVar_Quote=%PrxChange(InputString=&MissingVar,PrxString=s/(\w+)/'$1'/);

/* ��ʼ���м��� */
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
                        where name in (&MissingVar_Quote.) and type EQ 1;                /* ��ֵ�� */
                select name into :DMO_VarList_Char separated by ' '
                        from DMO_VarList
                        where name in (&MissingVar_Quote.) and type EQ 2;                /* �ַ��� */
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

/* ɾ������Ҫ�ı�� */
proc datasets lib=work nolist;
        delete DMO_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=DailyPriceOfIndex;*/
/*%let TargetTable=DailyPriceOfIndex1;*/
/*%let MissingVar=_ALL_;                /* =_Numeric_��ʾѡ��ȫ����ֵ�ͱ�����=_Character��ʾѡ��ȫ���ַ��ͱ�����=_All_��ʾѡ��ȫ��������Ҳ����ѡ�����������ÿո�ָ� */*/
/*%DeleteMissObs(&SourceTable,&TargetTable,&MissingVar);*/
/**/
/*%mend;*/

/*��ţ�9*/
%macro GetVarListForTable(SourceTable,TargetTable,OutputVar,VarType,UseLabel);

/**********************************************************************/
/* �˺�������ǵõ�ָ�����ı����б����У�SourceTable��ԭʼ���  */
/* TargetTable�ǽ�����VarType�Ǳ������ͣ�=_Numeric_��ʾ��ֵ�ͣ�   */
/* =_Character_��ʾ�ַ��ͣ�=_ALL_��ʾȡ��ȫ�������б�=xx:��ʾ��xx�� */
/* ͷ�����б�����=xx%��ʾ����xx�����б�����UseLabel�Ǳ�Ǳ�����=Yes�� */
/* ʾ�ñ�ǩ���������������=No��                                      */
/*                                                                    */
/* ���յõ�ָ�����ı����б�                                       */
/*                                                                    */
/*                                      Created on 2013.2.6           */
/*                                      Modified on 2013.2.17          */
/**********************************************************************/

/* ���SourceTable�ĺϷ��� */
%if %SYSFUNC(FIND(&SourceTable,.)) NE 0 %then %do;
        %let GVLFT_SourceLibName=%SCAN(&SourceTable,1,.);
        %let GVLFT_SourceDatasetName=%SCAN(&SourceTable,2,.);
%end;
%else %do;
        %let GVLFT_SourceLibName=WORK;
        %let GVLFT_SourceDatasetName=&SourceTable;
%end;

/* ���TargetTable�Ĵ����� */
%if &TargetTable EQ %STR() AND &OutputVar EQ %STR() %then %do;
        %put ERROR: The TargetTable and OutputVar should not be blank simultaneously, please check it again.;
        %goto exit;
%end;

%if &TargetTable EQ %STR() %then %let TargetTable=GVLFT_Res;

/* ���VarType�ķǿ��� */
%if &VarType EQ %STR() %then %let VarType=_All_;

/* ���VarType */
%SeparateString(InputString=&VarType,OutputString=GVLFT_VarType);

/* ���UseLabel�ĺϷ��� */
%if &UseLabel EQ %STR() %then %let UseLabel=No;

%if %UPCASE(&UseLabel) NE YES AND %UPCASE(&UseLabel) NE NO %then %do;
        %put ERROR: The UseLabel should be Yes or No, case insensitive and without quotes.;
        %goto exit;
%end;

/* ��ʼ���� */
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

/* �ϲ�������� */
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

/* ɾ������Ҫ�ı�� */
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
/*%let VarType=_All_;                /* =_Numerical_��ʾ��ֵ�ͣ�=_Character_��ʾ�ַ��ͣ�=_ALL_��ʾȡ��ȫ�������б�=xx:��ʾ��xx��ͷ�����б�����=xx%��ʾ����xx�����б��� */*/
/*%let UseLabel=Yes;                /* ��Ǳ�����=Yes��ʾ�ñ�ǩ���������������=No */*/
/*%GetVarListForTable(&SourceTable,&TargetTable,&OutputVar,&VarType,&UseLabel);*/
/**/
/*%put &VarString;*/
/**/
/*%mend;*/

/*��ţ�10*/
%macro GetDataSetInfoInLib(LibName,Filter,TargetTable,OutFilePath,Detail);

/**********************************************************************/
/* �˺����ڻ��Ŀ���߼������������ݼ�����Ϣ����������Ϣ������SAS��� */
/* �򵼳���txt�ļ��С����У�LibName��ָ�����߼��⣻Filter�����ݼ����� */
/* ���ã�֧��_��%ͨ���������Ҫ�����������ݼ��б���������Ϊ�գ� */
/* TargetTable�Ǳ������ݼ���Ϣ��SAS���������Ҫ���ɣ�������Ϊ�գ� */
/* OutFilePath�ǵ���txt�ļ���·����������Ҫ������������Ϊ�գ�Detail�� */
/* ��Ǳ�����=Yes��ʾ�������ݼ��б����飬����=No�� */
/* */
/* ���յõ����Ǻ���Ŀ���߼������������ݼ���Ϣ��SAS���ʹ���ָ��·�� */
/* ��txt�ļ��� */
/* */
/* Created on 2013.2.23 */
/* Modified on 2013.4.3 */
/**********************************************************************/

/* ���TargetTable��OutFilePath�ķ�ͬʱΪ���� */
%if &TargetTable EQ %STR() AND &OutFilePath EQ %STR() %then %do;
%put ERROR: The TargetTable and OutFilePath should not be blank simultaneously, please check it again.;
%goto exit;
%end;

%if &TargetTable EQ %STR() %then %let TargetTable=GDSIIL_Temp;

/* ���OutFilePath�ĺϷ��ԣ�����׺�����ڻ��TXT�����ΪTXT */
%if &OutFilePath NE %STR() %then %do;
%if %SYSFUNC(FIND(&OutFilePath,%STR(.))) EQ 0 %then %do;
%let OutFilePath=%SYSFUNC(CATS(&OutFilePath,%STR(.TXT)));
%end;
%else %if %SYSFUNC(FIND(&OutFilePath,%STR(.))) NE 0 AND %UPCASE(%SCAN(&OutFilePath,-1,%STR(.))) NE TXT %then %do;
%let OutFilePath=%SYSFUNC(CATS(%SUBSTR(&OutFilePath,1,%LENGTH(&OutFilePath)-%LENGTH(%SCAN(&OutFilePath,-1,%STR(.)))),TXT));
%end;
%end;

/* �������·�����Ƿ����ͬ���ļ�����������ɾ�� */
%if &OutFilePath NE %STR() %then %do;
%ChkFile(&OutFilePath);
%end;

/* ���Detail�ĺϷ��� */
%if &Detail EQ %STR() %then %let Detail=No;

%if %UPCASE(&Detail) NE YES AND %UPCASE(&Detail) NE NO %then %do;
%put ERROR: The Detail should be Yes or No, case insensitive and without quotes.;
%goto exit;
%end;

/* ��ʼ���м��� */
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

/* ����Ҫ��SAS��Output�����д�ӡ�ļ��б���ȡ������ע�� */
/*proc print data=&TargetTable;*/
/*title1 "Files identified through saved file";*/
/*run;*/

/* ɾ������Ҫ�ı�� */
proc datasets lib=work nolist;
delete GDSIIL_:;
quit;

%exit:
%mend;

/*%macro Demo();*/
/**/
/*%let LibName=Zheng;*/
/*%let Filter=r%; /* �ļ��������ã�����Ҫ���������ļ��б�������Ϊ�ռ��ɣ���Filter=; */*/
/*%let TargetTable=FileList; /* ������Ҫ���ɰ����ļ��б��SAS�������Ϊ�գ���Сд������ */*/
/*%let OutFilePath=d:\Temp\abc.txt; /* ������Ҫ�����ļ��б�txt�ļ�������Ϊ�գ���Сд������ */*/
/*%let Detail=Yes; /* =Yes��ʾ�ڵ����ļ��б�txt�ļ��а���InDirPath�����飬����=No����Сд������ */*/
/*%GetDataSetInfoInLib(&LibName,&Filter,&TargetTable,&OutFilePath,&Detail);*/
/**/
/*%mend;*/

/*��ţ�11*/
%macro FillMissWithNonMiss(SourceTable,TargetTable,ByFactors,MissingVar,OrderVar,Type);
/**********************************************************************/
/* �˺��ԭ���к���ȱʧֵ�ı�����������䷽���ǽ�ȱʧֵ����һ������ */
/* һ����ȱʧֵ���������SourceTable��ԭʼ���TargetTable�ǽ���� */
/* ��ByFactors�Ƿ��������MissingVar�ǿ��ܺ���ȱʧֵ�ı�����        */
/* =_Numeric_��ʾѡ��ȫ����ֵ�ͱ�����=_Character_��ʾѡ��ȫ���ַ��ͱ� */
/* ����=_All_��ʾѡ��ȫ��������Ҳ����ѡ�����������ÿո�ָ���Order_ */
/* Var�����б�����������Ϊ������ÿո�ָ���Ĭ�ϰ��������У���Ҫ����  */
/* ���У�������Ӧ�ı������DESCENDING��Type��ȱʧֵ��ѡȡ��ʽ��       */
/* =Previous��ʾȱʧֵѡȡǰһ����ȱʧֵ��=Next��ʾȱʧֵѡȡ��һ���� */
/* ȱʧֵ��=Mix��ʾ�����Բ�ֵ�ķ����ȱʧֵ���÷���ֻ��������ֵ�ͱ� */
/* �������ַ��ͱ�������ΪMix�����Զ���Previous�ķ�����ֵ����          */
/*                                                                    */
/* ���ս�������ָ���ĺ���ȱʧֵ�ı�����ȱʧֵ�����               */
/*                                                                    */
/*                                      Created on 2011.9.28          */
/*                                      Modified on 2013.3.22         */
/**********************************************************************/

/* ���TargetTable�Ĵ����ԣ�������������Ϊ&SourceTable */
%if &TargetTable EQ %STR() %then %let TargetTable=&SourceTable;

/* ��SourceTable��TargetTable��ͬ������FMWNM_resΪ&SourceTable */
%if %UPCASE(&SourceTable) EQ %UPCASE(&TargetTable) %then %let FMWNM_res=&SourceTable;
%else %let FMWNM_res=FMWNM_res;

data &FMWNM_res;
        set &SourceTable;
run;

/* ���ByFactors�Ĵ����� */
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

/* ���ŷָ���ByFactors_Comma����SQL��� */
%local ByFactors_Comma;

%if %SYSFUNC(FIND(&ByFactors,%STR( ))) NE 0 %then %do;
        %let ByFactors_Comma=%SYSFUNC(TRANWRD(%SYSFUNC(COMPBL(&ByFactors)),%STR( ),%STR(,)));
%end;
%else %let ByFactors_Comma=&ByFactors;

/* ���MissingVar�Ĵ����� */
%if (%UPCASE(&MissingVar) NE _NUMERIC_) AND (%UPCASE(&MissingVar) NE _CHARACTER_) AND (%UPCASE(&MissingVar) NE _ALL_) %then %do;
        %ChkVar(SourceTable=&FMWNM_res,InputVar=&MissingVar,FlagVarExists=FMWNM_FlagVarExists2);

        %if %SYSFUNC(FIND(&FMWNM_FlagVarExists2,0)) NE 0 %then %do;
                %put ERROR: The MissingVar %SCAN(&ByFactors,%SYSFUNC(FIND(&FMWNM_FlagVarExists2,0))) does not exist in SourceTable, please check it again.;
                %goto exit;
        %end;
%end;

/* ���OrderVar�Ĵ����� */
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

/* ���ŷָ���OrderVar_Comma����SQL��� */
%local OrderVar_Comma;

%if &OrderVar NE %STR() %then %do;
        %if %SYSFUNC(FIND(&OrderVar,%STR( ))) NE 0 %then %do;
                %let OrderVar=%SYSFUNC(COMPBL(&OrderVar));                /* ѹ������ո� */
                %let OrderVar_Comma=%PrxChange(InputString=&OrderVar,PrxString=s/ DESCENDING/DESCENDING/);                /* ���DESCENDING�ĸ�ʽ���� */
                %let OrderVar_Comma=%SYSFUNC(TRANWRD(&OrderVar_Comma,%STR( ),ANCBS_Space));
                %let OrderVar_Comma=%PrxChange(InputString=&OrderVar_Comma,PrxString=s/DESCENDING/ DESCENDING/);
                %let OrderVar_Comma=%SYSFUNC(TRANWRD(&OrderVar_Comma,ANCBS_Space,%STR(,)));
        %end;
        %else %let OrderVar_Comma=&OrderVar;
%end;
%else %let OrderVar_Comma=;

/* ���Type�Ĵ����ԺͺϷ��� */
%if &Type EQ %STR() %then %let Type=PREVIOUS;

%if (%UPCASE(&Type) NE PREVIOUS) AND (%UPCASE(&Type) NE NEXT) AND (%UPCASE(&Type) NE MIX) %then %do;
        %put ERROR: The Type should be PREVIOUS, NEXT or MIX, case insensitive and without quotes.;
        %goto exit;
%end;

/* ��ʼ���м��� */
/* ���ȣ�����Type���ö�ԭʼ���������� */
%if %UPCASE(&Type) EQ PREVIOUS %then %do;
        proc sort data=&FMWNM_res;
                by &OrderVar;
        run;
%end;
%else %if (%UPCASE(&Type) EQ NEXT) OR (%UPCASE(&Type) EQ MIX) %then %do;                /* ��ԭ��&ByFactors�������� */
        proc sort data=&FMWNM_res;
                by DESCENDING %SYSFUNC(TRANWRD(&OrderVar,%STR( ),%STR( )DESCENDING%STR( )));
        run;
%end;

/* ��Σ��Ժ���ȱʧֵ�ı������в��� */
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
                                        &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;                /* �õ�����ȱʧֵ֮��Ĳ� */
                                        &FMWNM_MissVarName._No=0;                /* �õ�ȱʧֵ����� */
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
                                        &FMWNM_MissVarName=var_temp+(&FMWNM_MissVarName._Diff-var_temp)/(&FMWNM_MissVarName._No+1);                /* ��������ȱʧֵ֮��Ĳ��ȱʧֵ����ŵõ���Ҫ�����ֵ */
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
        %else %do;                /* ��MissingVarΪָ���������ƣ����ȡָ��������ȱʧֵ�������� */
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
                                                &FMWNM_MissVarName._Diff=&FMWNM_MissVarName;                /* �õ�����ȱʧֵ֮��Ĳ� */
                                                &FMWNM_MissVarName._No=0;                /* �õ�ȱʧֵ����� */
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
                                                &FMWNM_MissVarName=var_temp+(&FMWNM_MissVarName._Diff-var_temp)/(&FMWNM_MissVarName._No+1);                /* ��������ȱʧֵ֮��Ĳ��ȱʧֵ����ŵõ���Ҫ�����ֵ */
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

/* ɾ����ʱ���ɵ�ByFactors��OrderVar */
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

/* ɾ������Ҫ�ı�� */
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
/*%let MissingVar=_All_;                /* =_Numeric_��ʾѡ��ȫ����ֵ�ͱ�����=_Character��ʾѡ��ȫ���ַ��ͱ�����=_All_��ʾѡ��ȫ��������Ҳ����ѡ�����������ÿո�ָ� */*/
/*%let OrderVar=;*/
/*%let Type=MIX;                /* ��ȱʧֵ���д���ķ�����=Previous��Next��MIX */*/
/*%FillMissWithNonMiss(&SourceTable,&TargetTable,&ByFactors,&MissingVar,&OrderVar,&Type);*/
/**/
/*%mend;*/

/*��ţ�12*/
%macro GetMissNum(SourceTable,TargetTable,InputVar);
/**********************************************************************/
/* �˺��������ͳ��ԭ���в�ͬ������ȱʧֵ����������SourceTable��ԭʼ */
/* ���SourceTable�ǽ�����TargetTable�ǽ�����InputVar��ԭʼ */
/* ����еı������������������ÿո�ָ���Ҳ���������ã�=_Numeric_�� */
/* ʾͳ��ȫ����ֵ�ͱ�����=_Character_��ʾͳ��ȫ���ַ��ͱ�����=_All_�� */
/* ʾͳ��ȫ�������� */
/* */
/* ���ս������а�������ָ�����������ơ����ͺ���Ӧ��ȱʧֵ������ */
/* */
/* Created on 2013.5.8 */
/* Modified on 2013.5.8 */
/**********************************************************************/

/* ���TargetTable�Ĵ����� */
%if &TargetTable EQ %STR() %then %do;
%put ERROR: The TargetTable should not be blank, please check it again.;
%goto exit;
%end;

/* ���InputVar�ĺϷ��� */
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

/* �����ֵ�ͱ����Ƿ���� */
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

/* ����ԭʼ��� */
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

/* ����ַ��ͱ����Ƿ���� */
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

/* ����ԭʼ��� */
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

/* ɸѡָ���ı��� */
%if %UPCASE(&InputVar) NE _ALL_ %then %do;
%let InputVar_Comma=%PrxChange(InputString=&InputVar,PrxString=s/(\w+)/'$1'/); /* ��InputVar�еĴ�������� */
%let InputVar_Comma=%SYSFUNC(TRANSLATE(&InputVar_Comma,%STR(,),%STR( ))); /* �滻InputVar�еĿո�Ϊ���� */

proc sql noprint;
create table GMN_VarList as
select * from GMN_VarList
where Name in (&InputVar_Comma)
order by Name;
quit;
%end;

/* �����ֵ�ͱ����Ƿ���� */
%ChkValue(SourceTable=GMN_VarList,
InputVar=type,
Value=1,
FlagValueExists=GMN_FlagNumVarExists);

/* ����ַ��ͱ����Ƿ���� */
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

/* ����ԭʼ��� */
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

/* ����ԭʼ��� */
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

/* ɾ������Ҫ�ı�� */
proc datasets lib=work nolist;
delete GMN_:;
quit;

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Cars;*/
/*%let TargetTable=MissNum;*/
/*%let InputVar=Cylinders; /* =_Numeric_��ʾͳ��ȫ����ֵ�ͱ�����=_Character_��ʾͳ��ȫ���ַ��ͱ�����=_All_��ʾͳ��ȫ����������Сд������ */*/
/*%GetMissNum(&SourceTable,&TargetTable,&InputVar);*/
/**/
/*%mend;*/

/*��ţ�13*/
%macro ChkValue(SourceTable,InputVar,Value,FlagValueExists);

/**********************************************************************/
/* �˺�������Ǽ��ĳ���ݱ����Ƿ���ָ������Ϊĳ�ض�ֵ�Ĺ۲⡣���У� */
/* SourceTable��ԭʼ���InputVar��ָ���ı�������ֻ��ָ��һ�������� */
/* Value��ָ����ֵ���ַ�������Ҫ�����ţ�������Ϊ���ֵ���ÿո�ָ��� */
/* FlagValueExists�Ǳ�Ǻ�������ƣ�=1��ʾԭ���ݱ��к���ָ������Ϊĳ */
/* �ض�ֵ�Ĺ۲⣬����=0�� */
/* */
/* ���յõ����Ǻ����&FlagValueExists����ͬλ���ϵ���ֵ��ʾ��Ӧ��ֵ�� */
/* ����ԭ���е�ָ�������д��ڣ�=1��ʾԭ���ݱ��к���ָ������Ϊĳ�ض�ֵ */
/* �Ĺ۲⣬����=0�� */
/* */
/* Created on 2012.11.6 */
/* Modified on 2012.11.12 */
/**********************************************************************/

/* ���SourceTable�Ĵ����� */
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

/* ���InputVar��Ψһ�� */
%if %SYSFUNC(FIND(&InputVar,%STR( ))) NE 0 %then %do;
%put ERROR: The InputVar should be only a single variable, please check it again.;
%goto exit;
%end;

/* ���InputVar�Ĵ����� */
%ChkVar(SourceTable=&CVL_LibName..&CVL_MemName,InputVar=&InputVar,FlagVarExists=CVL_FlagInputVarExists);

%if %SYSFUNC(FIND(&CVL_FlagInputVarExists,0)) NE 0 %then %do;
%put ERROR: The InputVar "%SCAN(&InputVar,%SYSFUNC(FIND(&CV_FlagInputVarExists,0)))" does not exist in SourceTable, please check it again.;
%goto exit;
%end;

/* ��ʼ���м��� */
/* ���Value */
%SeparateString(InputString=&Value,OutputString=CVL_Value);

/* Ϊ&FlagValueExists���ó�ʼֵ */
%do CVL_i=1 %to &CVL_Value_Num;
%let CVL_FlagValueExists_&CVL_i.=0;
%end;

/* ���InputVar�ĸ�ʽ */
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

/* ����������������������&FlagValueExists */
%global &FlagValueExists;

%let &FlagValueExists=&CVL_FlagValueExists_1;

%do CVL_l=2 %to &CVL_Value_Num;
%let &FlagValueExists=&&&FlagValueExists.&&CVL_FlagValueExists_&CVL_l;
%end;

/* ��Ҫ��ʾ&FlagValueExists��ֵ����ȡ�������ע�� */
/*%put &FlagValueExists=&&&FlagValueExists;*/

%exit:
%mend;


/*%macro Demo();*/
/**/
/*%let SourceTable=Allretoffund_holding_temp1;*/
/*%let InputVar=End_Yr;*/
/*%let Value=2004; /* �ַ�������Ҫ������ */*/
/*%let FlagValueExists=FlagValueExists1;*/
/*%ChkValue(&SourceTable,&InputVar,&Value,&FlagValueExists);*/
/**/
/*%mend;*/

/*��ţ�14*/
%macro ChkVarFormat(SourceTable,InputVar,FlagVarFormat);

/**********************************************************************/
/* �˺�������Ǽ��ĳ���ݱ���ָ�������ĸ�ʽ�������ڸ�ʽYYMMDD10.���� */
/* ������ʽ$40.�����У�SourceTable��ԭʼ���InputVar��ָ���ı����� */
/* ��Ϊ������������ÿո�ָ���FlagVarFormat�Ǳ�Ǻ�������ƣ����ж� */
/* ��InputVar����������С����ָ��� */
/* */
/* ���յõ����Ǻ����&FlagVarFormat�� */
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

/* ��Ҫ��ʾ&FlagVarFormat��ֵ����ȡ�������ע�� */
/*%put &FlagVarFormat=&&&FlagVarFormat;*/

/* ɾ������Ҫ�ı�� */
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

/*��ţ�15*/
%macro ChkVarType(SourceTable,InputVar,FlagVarType);

/**********************************************************************/
/* �˺�������Ǽ��ĳ���ݱ���ָ�����������ͣ�����ֵ�ͻ��ַ��͡����У� */
/* SourceTable��ԭʼ���InputVar��ָ���ı�������Ϊ������������ÿ� */
/* ��ָ���FlagVarType�Ǳ�Ǻ�������ƣ�=N��ʾΪ��ֵ�ͣ�=C��ʾΪ�ַ� */
/* �ͣ����ж��InputVar��������ͬλ���ϵ�N��C������Ӧ���������͡� */
/* */
/* ���յõ����Ǻ����&FlagVarType��=N��ʾָ������Ϊ��ֵ�ͣ�=C��ʾΪ�� */
/* ���ͣ���Ϊ�����������ͬλ���ϵ�N��C������Ӧ���������͡� */
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

%let &FlagVarType=%SYSFUNC(TRANSLATE(&&&FlagVarType,NC,12)); /* ת���������͵���ʾ��ʽ��N��ʾ��ֵ�ͣ�C��ʾ�ַ��� */
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

/* ��Ҫ��ʾ&FlagVarType��ֵ����ȡ�������ע�� */
/*%put &FlagVarType=&&&FlagVarType;*/

/* ɾ������Ҫ�ı�� */
proc delete data=CVT_temp;
run;

%exit:
%mend;

/*����15�İ���*/
/*%macro Demo();*/
/**/
/*%let SourceTable=Allretoffund_holding_temp1;*/
/*%let InputVar=End_Yr End_Mt End_Dy Stk_Name;*/
/*%let FlagVarType=FlagVarType1;*/
/*%ChkVarType(&SourceTable,&InputVar,&FlagVarType);*/
/**/
/*%mend;*/

/*��ţ�16*/
%macro ChkVar(SourceTable,InputVar,FlagVarExists);

/**********************************************************************/
/* �˺�������Ǽ��ĳ���ݱ����Ƿ����ָ���ı��������У�SourceTable�� */
/* ԭʼ���InputVar��ָ���ı�������Ϊ������������ÿո�ָ���Flag_ */
/* VarExists�Ǳ�Ǻ�������ƣ�=1��ʾ�������ڣ�����=0�����ж��InputVar*/
/* ��������ͬλ���ϵ�1��0������Ӧ�ı����Ƿ���ڡ� */
/* */
/* ���յõ����Ǻ����&FlagVarExists���������ݱ����ָ���������� */
/* &FlagVarExists=1������=0����Ϊ�����������ͬλ���ϵ�1��0������Ӧ */
/* �ı����Ƿ���ڡ� */
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

/* ��Ҫ��ʾ&FlagVarExists��ֵ����ȡ�������ע�� */
/*%put &FlagVarExists=&&&FlagVarExists;*/

/* ɾ������Ҫ�ı�� */
proc delete data=CV_temp;
run;

%exit:
%mend;

/*����16����*/
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

/*��ţ�17*/
%macro ChkDataSet(DataSet,FlagDataSetExists);

/**********************************************************************/
/* �˺����ڼ��ָ�������ݼ��Ƿ���ڡ����У�DataSet��ָ�������ݼ����� */
/* ��Ҫָ��������߼��⣬������߼���.���ݿ�ĸ�ʽ�����������ݼ��� */
/* �ÿո�ָ���FlagDataSetExists�Ǳ�Ǻ�������ƣ�=1��ʾ���ݼ����ڣ� */
/* ����=No����ָ���˶�����ݼ�����ͬλ���ϵ�1��0������Ӧ�����ݼ��� */
/* ����ڡ�������Ҫע�⣬��һ������ָ��һ�����ݼ�ʱ������ָ���߼����� */
/* �ƣ���ָֻ�����ݼ����ƣ���ʱ����SAS������ֻ����һ��ָ�������ݼ��� */
/* ���Ǻ����FlagDataSetExists=1�����������ͬ�������ݼ�����ᱨ��*/
/* �ڶ�����ָ��������ݼ�ʱ������ָ���߼������ƣ���Ĭ��ΪWORK�߼��⡣ */
/* */
/* ���յõ����Ǻ����&FlagDataSetExists����ָ�����ݼ����ڣ����� */
/* &FlagDataSetExists=1������=0����Ϊ������ݼ�����ͬλ���ϵ�1��0�� */
/* ����Ӧ�����ݼ��Ƿ���ڡ� */
/* */
/* Created on 2012.11.16 */
/* Modified on 2012.11.16 */
/**********************************************************************/

/* ���DataSet�Ĵ����� */
%if &DataSet EQ %STR( ) %then %do;
%put ERROR: The DataSet should not be blank, please check it again.;
%goto exit;
%end;

/* ��ʼ���м��� */
%global &FlagDataSetExists;

/* ����һ�����趨һ�����ݼ�����ʱ��ʡ���߼����������������߼����в���ͬ�������ݼ������Ա��� */
%if %SYSFUNC(FIND(&DataSet,%STR( ))) EQ 0 %then %do;
/* ���DataSet�ĺϷ��� */
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
/* ���ζ����趨������ݼ�����ʱ��ʡ���߼���������Ĭ��ΪWORK�߼��� */
%else %do;
%SeparateString(InputString=&DataSet,OutputString=CDS_DateSet);

%do CDS_i=1 %to &CDS_DateSet_Num;
/* ���DataSet�ĺϷ��� */
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

/* �����Ҫ����������ȡ�������ע�� */
/*%put &&&FlagDataSetExists;*/

/* ɾ������Ҫ�ı�� */
proc datasets lib=work nolist;
delete CDS_temp;
quit;


%exit:
%mend;

/*����17����*/
/*%macro Demo();*/
/**/
/*%let DataSet=Gfl_fundcodelist_mgrname Gfl_managersoffund; /* ���ݼ����ƣ�����Ϊ������ÿո�ָ� */*/
/*%let FlagDataSetExists=FlagDataSetExists1; /* ����������ƣ�ע�ⲻ�������������ͬ*/*/
/*%ChkDataSet(&DataSet,&FlagDataSetExists);*/
/**/
/*%put &FlagDataSetExists1;*/
/**/
/*%mend;*/

/*��ţ�18*/
%macro SeparateString(InputString,OutputString);
/**********************************************************************/
/* �˺����ڽ�����һ�鵥�ʵ��ַ������Ϊһ�����ĵ��ʣ�������Щ�������� */
/* �����һϵ�к����֮�С�ע�⣬�ַ����е��ʵĶ���Ϊ����ĸ�����ֺ��� */
/* �»�����ɵ�һ�����壬���ָ�������Ϊ����ĸ�����֡��»����Լ�����֮ */
/* ������������ַ�������InputString����ѡ���ַ�����OutputString���� */
/* �����ַ���ǰ׺������Ҫ�������»��ߡ� */
/* */
/* ���յõ�����һ�鵥�ʵĺ����&OutputString._Var1,&OutputString.Var2 */
/* ���Լ��ַ����������������ĺ����&OutputString._Num�� */
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

/* ȥ��&OutputString._Numǰ��Ŀո� */
%let &OutputString._Num=%SYSFUNC(TRIM(&&&OutputString._Num));

/* ɾ������Ҫ�ı�� */
proc delete data=SS_temp;
run;

%mend;

/*����18����*/
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

/*��ţ�19*/
%macro ChkFile(OutFilePath);
/**********************************************************************/
/* �˺�������Ǽ��ָ��·�����ļ��л��ļ��Ƿ���ڡ���ָ��·�������ļ� */
/* ���������д˺��·���а������ļ��д��ڵ��ļ������ڣ������Ժ������ */
/* ��ָ��·���������ļ����������д˺��·���а������ļ��д��ڡ����У� */
/* OutFilePath��ָ�����ļ��л��ļ�·����ע�����·���а����ļ�������  */
/* һ��Ҫдȫ�ļ���������չ����                                       */
/*                                                                    */
/*                                      Created on 2011.9.29          */
/*                                      Modified on 2011.9.29         */
/**********************************************************************/

/* ����1�����������OutFilePath�����ļ���ʱ��ע���ļ����������׺ */
%if %SYSFUNC(FIND(&OutFilePath,%Str(.))) NE 0 %then %do; 
        /* �õ�OutFilePath�а������ļ���File���ļ���·��Dir */
        %let File=%SYSFUNC(SCAN(&OutFilePath,-1,\));
        %let Dir=%SYSFUNC(SUBSTR(&OutFilePath,1,%EVAL(%SYSFUNC(LENGTH(&OutFilePath))-%SYSFUNC(LENGTH(&File)))));

        options noxwait;

        %local rc1 fileref1;
        %local rc2 fileref2;
        %let rc1=%SYSFUNC(FILENAME(fileref1,&Dir));
        %let rc2=%SYSFUNC(FILENAME(fileref2,&OutFilePath));

        %if %SYSFUNC(FEXIST(&fileref1)) %then %do;
                %put NOTE: The directory "&Dir" exists.;
                %if %SYSFUNC(FEXIST(&fileref2)) %then %do;                /* �ļ��д������ļ�Ҳ���ڵ����� */
                        %SYSEXEC del &OutFilePath;
                        %put NOTE: The file "&File" also exists, and has been deleted.;
                        %end;
                %else %put NOTE: But the file "&File" does not exist.;                /* �ļ��д������ļ������ڵ����� */
                %end;
        %else %do;                /* �ļ��в����ڵ����� */
                %SYSEXEC md &Dir;
                %put %SYSFUNC(SYSMSG()) The directory has been created.;
                %end; 

        %let rc1=%SYSFUNC(FILENAME(fileref1));
        %let rc2=%SYSFUNC(FILENAME(fileref2));
%end;

/* ����2�����������OutFilePath�������ļ���ʱ */
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

/*���19����*/
/*%macro Demo();*/
/**/
/*%ChkFile(d:\temp\data.xls);*/
/**/
/*%mend;*/


/*��ţ�20*/
/*dopen()��ָ��·��;dnum()����һ��·���µĳ�Ա����;filename(x,y)����ַy��ֵ��������x;
dread()�����ض�·����ĳ��Ա����;*/
%MACRO GETFILES_IN_FOLDER(DIRNAME,TYP,DIRFILES)     ;/*������������·�����ļ����ͺ�׺,�������ݼ�*/
/*   %PUT %STR(----------->DIRNAME=&DIRNAME)        ;*/
/*   %PUT %STR(----------->TYP=&TYP)                ;*/
   /*str()������quote()���ƣ�ʹ��������������Խ���*/
/*   %let rs=%sysfunc(exist(WORK.&DIRFILES.));*/
/*   %if rs ^= 0 %then %do;*/
   DATA WORK.&DIRFILES.                             ;     
   	RC = %sysfunc(FILENAME(DIR,&DIRNAME.))             ;/*��&DIRNAMEֵ�����ļ����÷�"DIR"*/    
   	OPENFILE = %sysfunc(DOPEN(&DIR.));/*�õ�·����ʾ��OPENFILE��DOPEN�Ǵ�directory��sas���ú���*/
   %IF &OPENFILE. > 0 %THEN %DO                     ;/*���OPENFILE>0��ʾ��ȷ��·��*/        
     NUMMEM = %sysfunc(DNUM(OPENFILE))                  ;/*�õ�·����ʾ��OPENFILE��member�ĸ���nummem*/        
     %DO II=1 %TO NUMMEM                      ;           
        NAME = %sysfunc(DREAD(OPENFILE,II))             ;/*��DREAD���ζ�ȡÿ���ļ������ֵ�NAME*/           
        OUTPUT                              ;/*�������*/        
     %END;                                         
   %END;                                       
/*   %end;	 */
   KEEP NAME                                 ;/*ֻ����NAME��*/
RUN;                                            
PROC SORT                                      ;/*����NAME����*/     
    BY DESCENDING NAME                        ;
    %IF &TYP ^= ALL %THEN %DO                        ;/*�Ƿ�����ض����ļ�����&TYP*/     
      WHERE INDEX(UPCASE(NAME),UPCASE("&TYP.")); /*Y,��ͨ������NAME�Ƿ����&TYP�ķ�ʽ�����ļ�����*/
    %END                                           ;
RUN;                                            
%MEND;


/*��ţ�*/
/*���ɻ�Ͼ��� DSin �������ݣ�ProbVar ����ΥԼ���ʱ�����DVVar ʵ��ΥԼ״̬������Cutoff �ٽ�ֵ��DSCM ��Ͼ������ݼ�*/
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

/*��ţ�*/
/*�������ڻ�������ͼ�����ݼ���Ĭ�ϵȷֹ�ģΪ10 DSin �������ݣ�ProbVar ����ΥԼ���ʱ�����DVVar ʵ��ΥԼ״̬������DSLift ����ͼ������ݼ�*/
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

	label TilePer ='��������';
	label TileP='��������';

	if &DVVar=1 then SumP=SumP+&DVVar;
	else SumN=SumN+1;

	PPer=SumP/&P;			/* Positive  % */
	NPer=SumN/&N;           /* Negative % */

	label PPer='"��"�ͻ��ı���';
	label NPer='"��"�ͻ��ı���';

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
/*��������ͼ*/

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


/*��ţ�*/
/*ʹ�����������ߵ����ݼ������ͳ���� DSin �������ݣ�ProbVar ����ΥԼ���ʱ�����DVVar ʵ��ΥԼ״̬������DSLorenz �����������������ݵ����ݼ���M_Gini ����ͳ����ֵ�ķ���ֵ*/
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
label TotRespPer='���á��ͻ�����';
label Tile ='��������';

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


/*��ţ�*/
/*ʹ�û���ͳ������������������ DSLorenz �����������������ݵ����ݼ�*/
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

/*��ţ�*/
/*ʹ��K-Sͳ��������K-S���� DSin �������ݣ�ProbVar ����ΥԼ���ʱ�����DVVar ʵ��ΥԼ״̬������ DSKS ����K-S�������ݵ����ݼ��� M_Gini K-Sͳ�����ķ���ֵ*/
/*K-Sֵ�����壺K-SֵԽ�󣬱�ʾ����ģ���ܹ������á����������ͻ����ֿ����ĳ̶�Խ��*/
/*K-S ���ߣ������������ߵ�����������С�������У��ֱ����ÿһ������֮�¡��á����������ʻ��ۼ���ռ�İٷֱȣ��ٽ��������ۼưٷֱ�����������ͬһ��ͼ���ϣ��õ�K-S���ߡ�*/
/*K-Sֵ���������¶�Ӧ���ۼơ������ʻ��ٷֱ����ۼơ��á��ʻ��ٷֱ�֮������ֵ��*/
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

/*��ţ�*/
/*ʹ��K-Sͳ��������K-S���� DSKS ����K-S�������ݵ����ݼ�*/
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


