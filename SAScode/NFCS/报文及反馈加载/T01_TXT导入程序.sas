/*1.个人基本信息报文导入*/
%macro PQ_input(out,inpath);
DATA &out;
INFILE "&inpath" DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_P $ 1
sorgcode $ 2-15
sname $ 16-45
scerttype $ 46
scertno $ 47-64
ssectionid_B $ 65
isex $ 66
dbirthday $ 67-74
imarriage $ 75-76
iedulevel $ 77-78
iedudegree $ 79
shometel $ 80-104
smobiletel $ 105-120
sofficetel $ 121-145
Semail $ 146-175
saddress $ 176-235
szip $ 236-241
sresidence $ 242-301
smatename $ 302-331
smatecerttype $ 332
smatecertno $ 333-350
smatecompany $ 351-410
smatetel $ 411-435
sfirstcontactname $ 436-465
sfirstcontactrelation $ 466
sfirstcontacttel $ 467-491
ssecondcontactname $ 492-521
ssecondcontactrelation $ 522
ssecondcontacttel $ 523-547
ssectionid_C $ 548
soccupation $ 549
Scompany $ 550-609
sindustry $ 610
scompanyaddress $ 611-670
scompanyzip $ 671-676
sstartyear $ 677-680
iposition $ 681
ititle $ 682
iannualincome $ 683-692
ssectionid_D $ 693
Daddress $ 694-753
Dzip $ 754-759
Dcondition $ 760;

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
 sstartyear ='本单位工作起始年份'
 iposition ='职务'
 ititle ='职称'
 iannualincome ='年收入'
 ssectionid_D ='段标D'
 daddress  ='居住地址'
 dzip  ='居住地址邮政编码'
 dcondition ='居住状况';
/*call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()生成position length,用于substrn*/
/*uploaddate=substrn("&inpath",position1,length1);*/
/*filename=substrn("&inpath",position3,length3);*/
/*drop position1 length1 position2 length2 position3 length3;*/
IF ssectionid_P='P';
RUN;
proc append base=PQ data=&out force;
run;
proc delete data=&out; 
run;
%mend;

/*2.贷款申请*/
%macro SQ_input(out,inpath);
DATA &out;
INFILE "&inpath"
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT
ssectionid_S $ 1
sorgcode $ 2-15
sapplycode $ 16-55
sname $ 56-85
scerttype $ 86
scertno $ 87-104
stype $ 105-106
Imoney $ 107-116
imonthcount $ 117-122
ddate $ 123-130
sstate $ 131;
label 
ssectionid_S ='段标S'
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
/* call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()生成position length,用于substrn*/
/*uploaddate=substrn("&inpath",position1,length1);*/
/*filename=substrn("&inpath",position3,length3);*/
/*drop position1 length1 position2 length2 position3 length3;*/
IF ssectionid_S='S';RUN;
proc append base=SQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*3.贷款业务信息报文导入*/
%macro AQ_input(out,inpath);
DATA &out;
INFILE "&inpath" DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_A $ 1
sorgcode $ 2-15
sloantype $ 16-17
sloancompactcode $ 18-77
saccount $ 78-117
sareacode $ 118-123
ddateopened $ 124-131
ddateclosed $ 132-139
scurrency $ 140-142
icreditlimit $ 143-152
ishareaccount $ 153-162
imaxdebt $ 163-172
iguaranteeway $ 173
stermsfreq $ 174-175
imonthduration $ 176-178
imonthunpaid $ 179-181
streatypaydue $ 182-184
streatypayamount $ 185-194
dbillingdate $ 195-202
drecentpaydate $ 203-210
ischeduledamount $ 211-220
iactualpayamount $ 221-230 
ibalance $ 231-240
icurtermspastdue $ 241-242
iamountpastdue $ 243-252
Iamountpastdue30 $ 253-262
Iamountpastdue60 $ 263-272
Iamountpastdue90 $ 273-282
Iamountpastdue180 $ 283-292
itermspastdue $ 293-295
imaxtermspastdue $ 296-297
iclass5stat $ 298
iaccountstat $ 299
Spaystat24month $ 300-323
iinfoindicator $ 324
sname $ 325-354
scerttype $ 355
scertno $ 356-373
skeepcolumn $ 374-403;
label 
ssectionid_A ='段标A'
 sorgcode ='机构名称'
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
 Spaystat24month ='24月（贷款）还款状态'
 iinfoindicator ='账户拥有者信息提示'
 sname ='姓名'
 scerttype ='证件类型'
 scertno ='证件号码'
 skeepcolumn ='预留字段';
/*call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()生成position length,用于substrn*/
/*uploaddate=substrn("&inpath",position1,length1);*/
/*filename=substrn("&inpath",position3,length3);*/
/*drop position1 length1 position2 length2 position3 length3;*/
IF ssectionid_A='A';
RUN;
proc append base=AQ data=&out force;
run;
proc delete data=&out ; 
run;
%mend;
/*合同信息段*/
%macro HQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_H $ 404-404
sorgcode $ 2-15
sloancompactcode $ 405-464
dloancompactopened $ 465-472
dloancompactclosed $ 473-480
scurrency $ 481-483
iloancompactamount $ 484-493
icompactstat $ 494-494 ;
label 
ssectionid_H ='段标H'
sorgcode='机构名称'
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
IF ssectionid_H='H';
RUN;
proc append base=HQ data=&out force;
run;
proc delete data=&out; 
run;
%mend;
/*担保信息*/
%macro EQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_E $ 495-495
sorgcode $ 2-15
sguaranteepersonname $ 496-525
sguaranteepersoncerttype $ 526-526
sguaranteepersoncertno $ 527-544
iguaranteesum $ 545-554
iguaranteestat $ 555-555;
label 
ssectionid_E ='段标E'
sorgcode='机构名称'
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
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_E='E';RUN;
proc append base=EQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*投资人信息*/
%macro TQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_T $ 556-556
sorgcode $ 2-15
sinvestorpersonname $ 557-586
sinvestorpersoncerttype $ 587-587
sinvestorpersoncertno $ 588-605
iinvestorsum $ 606-615;
label ssectionid_T ='段标T'
sorgcode='机构名称'
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
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_T='T';
RUN;
proc append base=TQ data=&out force;
run;
proc delete data=&out ; 
run;
%mend;

/*特殊交易*/
%macro GQ_input(out,inpath);
DATA &out;
INFILE "&inpath" 
DSD MISSOVER FIRSTOBS=1 LRECL=32767;
INPUT 
ssectionid_G $ 1-1
sorgcode $ 2-15
sname $ 16-45
scerttype $ 46-46
scertno $ 47-64
saccount $ 65-104
speculiartradetype $ 105-105
doccurdate $ 106-113
ichangemonth $ 114-117
ioccursum $ 118-127
sdetailinfo $ 128-327;
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
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_G='G';
RUN;
proc append base=GQ data=&out force;
run;
proc delete data=&out; 
run;
%mend;

