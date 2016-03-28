/*1.个人基本信息报文导入*/
%macro Er_PQ_input(out,inpath);
DATA &out;
INFILE "&inpath" DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_P $ 60-60
sorgcode $ 61-74
sname $ 75-104
scerttype $ 105-105
scertno $ 106-123
ssectionid_B $ 124-124
isex $ 125-125
dbirthday $ 126-133
imarriage $ 134-135
iedulevel $ 136-137
iedudegree $ 138-138
smatename $ 139-163
smatecerttype $ 164-179
smatecertno $ 180-204
smatecompany $ 205-234
smatetel $ 235-294
shometel $ 295-300
smobiletel $ 301-360
sofficetel $ 361-390
Semail $ 391-391
saddress $ 392-409
szip $ 410-469
sfirstcontactname $ 470-494
sfirstcontactrelation $ 495-524
sfirstcontacttel $ 525-525
ssecondcontactname $ 526-550
ssecondcontactrelation $ 551-580
ssecondcontacttel $ 581-581
sresidence $ 582-606
ssectionid_C $ 607-607
soccupation $ 608-608
Scompany $ 609-668
sindustry $ 669-669
scompanyaddress $ 670-729
scompanyzip $ 730-735
sstartyear $ 736-739
iposition $ 740-740
ititle $ 741-741
iannualincome $ 742-751
ssectionid_D $ 752-752
saddress  $ 753-812
szip  $ 813-818
Scondition $ 819-819
;
label 
ssectionid_P ='段标P'
 sorgcode ='数据发生机构'
 sname ='姓名'
 scerttype ='证件类型'
 scertno ='证件号码'
 ssectionid_B ='段标B'
 isex ='性别'
 dbirthday ='出生日期'
 imarriage ='婚姻状况'
 iedulevel ='最高学历'
 iedudegree ='最高学位'
 smatename ='配偶姓名'
 smatecerttype ='配偶证件类型'
 smatecertno ='配偶证件号码'
 smatecompany ='配偶工作单位'
 smatetel ='配偶联系电话'
 shometel ='住宅电话'
 smobiletel ='手机号码'
 sofficetel ='单位电话'
 Semail ='电子邮箱'
 saddress ='通讯地址'
 szip ='通讯地址邮政编码'
 sfirstcontactname ='第一联系人姓名'
 sfirstcontactrelation ='第一联系人关系'
 sfirstcontacttel ='第一联系人联系电话'
 ssecondcontactname ='第二联系人姓名'
 ssecondcontactrelation ='第二联系人关系'
 ssecondcontacttel ='第二联系人联系电话'
 sresidence ='户籍地址'
 ssectionid_C ='段标C'
 soccupation ='职业'
 Scompany ='单位名称'
 sindustry ='单位所属行业'
 scompanyaddress ='单位地址'
 scompanyzip ='单位邮政编码'
 sstartyear ='在职年限'
 iposition ='职务'
 ititle ='职称'
 iannualincome ='年收入'
 ssectionid_D ='段标D'
 saddress  ='居住地址'
 szip  ='居住地址邮政编码'
 Scondition ='居住状况';
call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_P='P';RUN;
proc append base=ER_PQ data=&out force;run;
proc delete data=&out; 
run;
%mend;

/*2.贷款申请*/
%macro Er_SQ_input(out,inpath);
DATA &out;
INFILE "&inpath"
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_S $ 60-60
sorgcode $ 61-74
sapplycode $ 75-114
sname $ 115-144
scerttype $ 145-145
scertno $ 146-163
stype $ 164-165
Imoney $ 166-175
imonthcount $ 176-181
ddate $ 182-189
sstate $ 190-190
;
label ssectionid_S ='段标S'
 sorgcode ='业务发生机构'
 sapplycode ='贷款申请号'
 sname ='姓名'
 scerttype ='证件类型'
 scertno ='证件号码'
 stype ='贷款申请类型'
 Imoney ='贷款申请金额'
 imonthcount ='贷款申请月数'
 ddate ='贷款申请时间'
 sstate ='贷款申请状态';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_S='S';RUN;
proc append base=ER_SQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*3.贷款业务信息报文导入*/
%macro Er_AQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_A $ 60-60
sorgcode $ 61-74
sloantype $ 75-76
sloancompactcode $ 77-136
saccount $ 137-176
sareacode $ 177-182
ddateopened $ 183-190
ddateclosed $ 191-198
scurrency $ 199-201
icreditlimit $ 202-211
ishareaccount $ 212-221
imaxdebt $ 222-231
iguaranteeway $ 232-232
stermsfreq $ 233-234
imonthduration $ 235-237
imonthunpaid $ 238-240
streatypaydue $ 241-243
streatypayamount $ 244-253
dbillingdate $ 254-261
drecentpaydate $ 262-269
ischeduledamount $ 270-279
iactualpayamount $ 280-289
ibalance $ 290-299
icurtermspastdue $ 300-301
iamountpastdue $ 302-311
Iamountpastdue30 $ 312-321
Iamountpastdue60 $ 322-331
Iamountpastdue90 $ 332-341
Iamountpastdue180 $ 342-351
itermspastdue $ 352-354
imaxtermspastdue $ 355-356
iclass5stat $ 357-357
iaccountstat $ 358-358
Spaystat24month $ 359-382
iinfoindicator $ 383-383
sname $ 384-413
scerttype $ 414-414
scertno $ 415-432
skeepcolumn $ 433-462
;
label ssectionid_A ='段标A'
 sorgcode ='数据发生机构'
 sloantype ='贷款类别'
 sloancompactcode ='贷款合同号码'
 saccount ='业务号'
 sareacode ='发生地点'
 ddateopened ='开户日期'
 ddateclosed ='到期日期'
 scurrency ='币种'
 icreditlimit ='授信额度'
 ishareaccount ='共享授信额度'
 imaxdebt ='最大负债额'
 iguaranteeway ='担保方式'
 stermsfreq ='还款频率'
 imonthduration ='还款月数'
 imonthunpaid ='剩余还款月数'
 streatypaydue ='协定还款期数'
 streatypayamount ='协定期还款额'
 dbillingdate ='结算/应还款日期'
 drecentpaydate ='最近一次实际还款日期'
 ischeduledamount ='本月应还款金额'
 iactualpayamount ='本月实际还款金额'
 ibalance ='余额'
 icurtermspastdue ='当前逾期期数'
 iamountpastdue ='当前逾期总额'
 Iamountpastdue30 ='逾期31-60天未归还贷款本金'
 Iamountpastdue60 ='逾期61-90天未归还贷款本金'
 Iamountpastdue90 ='逾期91-180天未归还贷款本金'
 Iamountpastdue180 ='逾期180天以上未归还贷款本金'
 itermspastdue ='累计逾期期数'
 imaxtermspastdue ='最高逾期期数'
 iclass5stat ='五级分类状态'
 iaccountstat ='账户状态'
 Spaystat24month ='24个月还款状态'
 iinfoindicator ='账户拥有者信息提示'
 sname ='姓名'
 scerttype ='证件类型'
 scertno ='证件号码'
 skeepcolumn ='预留字段';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_A='A';RUN;
proc append base=ER_AQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*合同信息段*/
%macro Er_HQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_H $ 60-60
sloancompactcode $ 61-120
dloancompactopened $ 121-128
dloancompactclosed $ 129-136
scurrency $ 137-139
iloancompactamount $ 140-149
icompactstat $ 150-150
;
label ssectionid_H ='段标H'
 sloancompactcode ='贷款合同号码'
 dloancompactopened ='贷款合同生效日期'
 dloancompactclosed ='贷款合同终止日期'
 scurrency ='币种'
 iloancompactamount ='贷款合同金额'
 icompactstat ='合同状态';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_H='H';RUN;
proc append base=ER_HQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*担保信息*/
%macro Er_EQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_E $ 60-60
sguaranteepersonname $ 61-90
sguaranteepersoncerttype $ 91-91
sguaranteepersoncertno $ 92-109
iguaranteesum $ 110-119
iguaranteestat $ 120-120
;
label ssectionid_E ='段标E'
 sguaranteepersonname ='担保人姓名'
 sguaranteepersoncerttype ='担保人证件类型'
 sguaranteepersoncertno ='担保人证件号'
 iguaranteesum ='担保金额'
 iguaranteestat ='担保状态';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_E='E';RUN;
proc append base=ER_EQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*投资人信息*/
%macro Er_TQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_T $ 60-60
sinvestorpersonname $ 61-90
sinvestorpersoncerttype $ 91-91
sinvestorpersoncertno $ 92-109
iinvestorsum $ 110-119
;
label ssectionid_T ='段标T'
 sinvestorpersonname ='投资人姓名'
 sinvestorpersoncerttype ='投资人证件类型'
 sinvestorpersoncertno ='投资人证件号'
 iinvestorsum ='投资金额';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_T='T';RUN;
proc append base=ER_TQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*特殊交易*/
%macro Er_GQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
SMSGFILENAME $ 1-24
SERROR1CODE $ 25-28
SERROR1INDEX $ 29-31
SERROR2CODE $ 32-35
SERROR2INDEX $ 36-38
SERROR3CODE $ 39-42
SERROR3INDEX $ 43-45
SERROR4CODE $ 46-48
SERROR4INDEX $ 50-52
SERROR5CODE $ 53-56
SERROR5INDEX $ 57-59
ssectionid_G $ 60-60
sorgcode $ 61-74
sname $ 75-104
scerttype $ 105-105
scertno $ 106-123
saccount $ 124-163
speculiartradetype $ 164-164
doccurdate $ 165-172
ichangemonth $ 173-176
ioccursum $ 177-186
sdetailinfo $ 187-386
;
label 
ssectionid_G ='段标G'
sorgcode ='P2P机构代码'
sname ='姓名'
scerttype ='证件类型'
scertno ='证件号码'
saccount ='业务号'
speculiartradetype ='特殊交易类型'
doccurdate ='发生日期'
ichangemonth ='变更月数'
ioccursum ='发生金额'
sdetailinfo ='明细信息';
call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()生成position length,用于substrn*/
uploaddate=substrn("&inpath",position1,length1);
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_G='G';RUN;
proc append base=ER_GQ data=&out force;run;
proc delete data=&out ; run;
%mend;

