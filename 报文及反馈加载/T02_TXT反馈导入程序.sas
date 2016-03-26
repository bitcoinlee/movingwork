/*1.���˻�����Ϣ���ĵ���*/
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
 sstartyear ='��ְ����'
 iposition ='ְ��'
 ititle ='ְ��'
 iannualincome ='������'
 ssectionid_D ='�α�D'
 saddress  ='��ס��ַ'
 szip  ='��ס��ַ��������'
 Scondition ='��ס״��';
call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_P='P';RUN;
proc append base=ER_PQ data=&out force;run;
proc delete data=&out; 
run;
%mend;

/*2.��������*/
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
label ssectionid_S ='�α�S'
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
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_S='S';RUN;
proc append base=ER_SQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*3.����ҵ����Ϣ���ĵ���*/
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
label ssectionid_A ='�α�A'
 sorgcode ='���ݷ�������'
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
 Spaystat24month ='24���»���״̬'
 iinfoindicator ='�˻�ӵ������Ϣ��ʾ'
 sname ='����'
 scerttype ='֤������'
 scertno ='֤������'
 skeepcolumn ='Ԥ���ֶ�';
 call scan("&inpath",5,position1,length1,"\");
call scan("&inpath",6,position2,length2,"\");
call scan("&inpath",8,position3,length3,"\");
IF LENGTH("&inpath")>82;
/*call scan()����position length,����substrn*/
uploaddate=substrn("&inpath",position1,length1);
filename=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_A='A';RUN;
proc append base=ER_AQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*��ͬ��Ϣ��*/
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
label ssectionid_H ='�α�H'
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
IF ssectionid_H='H';RUN;
proc append base=ER_HQ data=&out force;run;
proc delete data=&out ; run;
%mend;
/*������Ϣ*/
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
label ssectionid_E ='�α�E'
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
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_E='E';RUN;
proc append base=ER_EQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*Ͷ������Ϣ*/
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
label ssectionid_T ='�α�T'
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
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_T='T';RUN;
proc append base=ER_TQ data=&out force;run;
proc delete data=&out ; run;
%mend;

/*���⽻��*/
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
file_name=substrn("&inpath",position3,length3);
drop position1 length1 position2 length2 position3 length3;
IF ssectionid_G='G';RUN;
proc append base=ER_GQ data=&out force;run;
proc delete data=&out ; run;
%mend;

