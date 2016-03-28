/*1.���˻�����Ϣ���ĵ���*/
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
ssectionid_P ='�α�P'
 sorgcode ='���ݷ�������'
 sname ='����'
 scerttype ='֤������'
 scertno ='֤������'
 ssectionid_B ='�α�B'
 isex ='�Ա�'
 dbirthday ='��������'
 imarriage ='����״��'
 iedulevel ='���ѧ��'
 iedudegree ='���ѧλ'
 smatename ='��ż����'
 smatecerttype ='��ż֤������'
 smatecertno ='��ż֤������'
 smatecompany ='��ż������λ'
 smatetel ='��ż��ϵ�绰'
 shometel ='סլ�绰'
 smobiletel ='�ֻ�����'
 sofficetel ='��λ�绰'
 Semail ='��������'
 saddress ='ͨѶ��ַ'
 szip ='ͨѶ��ַ��������'
 sfirstcontactname ='��һ��ϵ������'
 sfirstcontactrelation ='��һ��ϵ�˹�ϵ'
 sfirstcontacttel ='��һ��ϵ����ϵ�绰'
 ssecondcontactname ='�ڶ���ϵ������'
 ssecondcontactrelation ='�ڶ���ϵ�˹�ϵ'
 ssecondcontacttel ='�ڶ���ϵ����ϵ�绰'
 sresidence ='������ַ'
 ssectionid_C ='�α�C'
 soccupation ='ְҵ'
 Scompany ='��λ����'
 sindustry ='��λ������ҵ'
 scompanyaddress ='��λ��ַ'
 scompanyzip ='��λ��������'
 sstartyear ='����λ������ʼ���'
 iposition ='ְ��'
 ititle ='ְ��'
 iannualincome ='������'
 ssectionid_D ='�α�D'
 daddress  ='��ס��ַ'
 dzip  ='��ס��ַ��������'
 dcondition ='��ס״��';
/*call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()����position length,����substrn*/
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

/*2.��������*/
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
ssectionid_S ='�α�S'
 sorgcode ='ҵ��������'
 sapplycode ='���������'
 sname ='����'
 scerttype ='֤������'
 scertno ='֤������'
 stype ='������������'
 Imoney ='����������'
 imonthcount ='������������'
 ddate ='��������ʱ��'
 sstate ='��������״̬';
/* call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()����position length,����substrn*/
/*uploaddate=substrn("&inpath",position1,length1);*/
/*filename=substrn("&inpath",position3,length3);*/
/*drop position1 length1 position2 length2 position3 length3;*/
IF ssectionid_S='S';RUN;
proc append base=SQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*3.����ҵ����Ϣ���ĵ���*/
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
ssectionid_A ='�α�A'
 sorgcode ='��������'
 sloantype ='�������'
 sloancompactcode ='�����ͬ����'
 saccount ='ҵ���'
 sareacode ='�����ص�'
 ddateopened ='��������'
 ddateclosed ='��������'
 scurrency ='����'
 icreditlimit ='���Ŷ��'
 ishareaccount ='�������Ŷ��'
 imaxdebt ='���ծ��'
 iguaranteeway ='������ʽ'
 stermsfreq ='����Ƶ��'
 imonthduration ='��������'
 imonthunpaid ='ʣ�໹������'
 streatypaydue ='Э����������'
 streatypayamount ='Э���ڻ����'
 dbillingdate ='����/Ӧ��������'
 drecentpaydate ='���һ��ʵ�ʻ�������'
 ischeduledamount ='����Ӧ������'
 iactualpayamount ='����ʵ�ʻ�����'
 ibalance ='���'
 icurtermspastdue ='��ǰ��������'
 iamountpastdue ='��ǰ�����ܶ�'
 Iamountpastdue30 ='����31-60��δ�黹�����'
 Iamountpastdue60 ='����61-90��δ�黹�����'
 Iamountpastdue90 ='����91-180��δ�黹�����'
 Iamountpastdue180 ='����180������δ�黹�����'
 itermspastdue ='�ۼ���������'
 imaxtermspastdue ='�����������'
 iclass5stat ='�弶����״̬'
 iaccountstat ='�˻�״̬'
 Spaystat24month ='24�£��������״̬'
 iinfoindicator ='�˻�ӵ������Ϣ��ʾ'
 sname ='����'
 scerttype ='֤������'
 scertno ='֤������'
 skeepcolumn ='Ԥ���ֶ�';
/*call scan("&inpath",5,position1,length1,"\");*/
/*call scan("&inpath",6,position2,length2,"\");*/
/*call scan("&inpath",8,position3,length3,"\");*/
/*IF LENGTH("&inpath")>82;*/
/*call scan()����position length,����substrn*/
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
/*��ͬ��Ϣ��*/
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
ssectionid_H ='�α�H'
sorgcode='��������'
 sloancompactcode ='�����ͬ����'
 dloancompactopened ='�����ͬ��Ч����'
 dloancompactclosed ='�����ͬ��ֹ����'
 scurrency ='����'
 iloancompactamount ='�����ͬ���'
 icompactstat ='��ͬ״̬';
  call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
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
/*������Ϣ*/
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
ssectionid_E ='�α�E'
sorgcode='��������'
 sguaranteepersonname ='����������'
 sguaranteepersoncerttype ='������֤������'
 sguaranteepersoncertno ='������֤����'
 iguaranteesum ='�������'
 iguaranteestat ='����״̬';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_E='E';RUN;
proc append base=EQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*Ͷ������Ϣ*/
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
label ssectionid_T ='�α�T'
sorgcode='��������'
 sinvestorpersonname ='Ͷ��������'
 sinvestorpersoncerttype ='Ͷ����֤������'
 sinvestorpersoncertno ='Ͷ����֤����'
 iinvestorsum ='Ͷ�ʽ��';
  call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
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

/*���⽻��*/
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
ssectionid_G ='�α�G'
sorgcode ='P2P��������'
sname ='����'
scerttype ='֤������'
scertno ='֤������'
saccount ='ҵ���'
speculiartradetype ='���⽻������'
doccurdate ='��������'
ichangemonth ='�������'
ioccursum ='�������'
sdetailinfo ='��ϸ��Ϣ';
call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
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

