/*XLS的字段导入宏*//*母宏包含所有子宏参数*/
/*子宏1*/

%MACRO CTON(TNAME,VNAME);
	DATA &TNAME.;
		FORMAT A&VNAME. BEST12.;
		SET &TNAME.;
		IF VTYPE(&VNAME.)='C' THEN DO;
			A&VNAME.=INPUT(&VNAME.,BEST12.);
			END;
		ELSE A&VNAME.=&VNAME.;
		DROP &VNAME.;
		RENAME A&VNAME.=&VNAME.;
	RUN;
%MEND;

%MACRO NTOC(TNAME,VNAME);
	DATA &TNAME.;
		FORMAT A&VNAME. $10.;
		SET &TNAME.;
		IF VTYPE(&VNAME.)='N' THEN DO;
			A&VNAME.=PUT(COMPRESS(&VNAME.),$10.);
			END;
		ELSE A&VNAME.=&VNAME.;
		DROP &VNAME.;
		RENAME A&VNAME.=&VNAME.;
	RUN;
%MEND;




%macro im_xls(path,worktable,out);
PROC import datafile="&path" DBMS=excel out=&out replace;
sheet="&worktable";run;

DATA &out;
set &out;
/*length filename $118.;*/
x="&path";
call scan(x,5,position1,length1,"\");
uploaddate=substrn(x,position1,length1);
call scan(x,8,position2,length2,"\");
filename=substrn(x,position2,length2);
wordtype=substr(filename,length(filename)-2,3);
drop position1 length1 position2 length2 x;run;

%mend;



/*子宏2
DATA &out;set &out;
if _col0=' ' then delete;
run;
proc delete data=&out &out.f;run;
*/

%MACRO IFA_PB(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_PB(&out);
proc append base=T_PB data=&out._f force;
run;
data t_pb;
	set t_pb(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;
run;
%mend;
%MACRO IFA_PC(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_PC(&out);
proc append base=T_PC data=&out._f force;run;
data t_pc;
	set t_pc(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_PD(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_PD(&out);
proc append base=T_PD data=&out._f force;
run;
data t_pd;
	set t_pd(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_S(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_S(&out);
proc append base=T_S data=&out._f force;run;
data t_s;
	set t_s(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_A(path,worktable,out);
%im_xls(&path,&worktable,&out);
%CTON(&out,_COL8);
%CTON(&out,_COL9);
%CTON(&out,_COL10);
%CTON(&out,_COL16);
%CTON(&out,_COL19);
%CTON(&out,_COL20);
%CTON(&out,_COL21);
%CTON(&out,_COL23);
%CTON(&out,_COL24);
%CTON(&out,_COL25);
%CTON(&out,_COL26);
%CTON(&out,_COL27);
/*%CTON(&out,icreditlimit);*/
/*%CTON(&out,ishareaccount);*/
/*%CTON(&out,imaxdebt);*/
/*%CTON(&out,streatypayamount);*/
/*%CTON(&out,ischeduledamount);*/
/*%CTON(&out,iactualpayamount);*/
/*%CTON(&out,ibalance);*/
/*%CTON(&out,iamountpastdue);*/
/*%CTON(&out,Iamountpastdue30);*/
/*%CTON(&out,Iamountpastdue60);*/
/*%CTON(&out,Iamountpastdue90);*/
/*%CTON(&out,Iamountpastdue180);*/
%format_A(&out);
proc append base=T_A data=&out._f force;run;
data t_a;
	set t_a(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_H(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_H(&out);
proc append base=T_H data=&out._f force;run;
data t_h;
	set t_h(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_E(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_E(&out);
proc append base=T_E data=&out._f force;run;
data t_e;
	set t_e(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_T(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_T(&out);
proc append base=T_T data=&out._f force;run;
data t_t;
	set t_t(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;
%MACRO IFA_G(path,worktable,out);
%im_xls(&path,&worktable,&out);
%format_G(&out);
proc append base=T_G data=&out._f force;run;
data t_g;
	set t_g(where=(sorgcode^=''));
run;
proc delete data=&out &out._f;run;
%mend;


%MACRO im_xls_pack(pathfile);
%IFA_PB	(&pathfile,身份信息,PB&i);
%IFA_PC	(&pathfile,职业信息,PC&i);
%IFA_PD	(&pathfile,居住信息,PD&i);
%IFA_S	(&pathfile,贷款申请信息,S&i);
%IFA_A	(&pathfile,贷款业务信息,A&i);
%IFA_H	(&pathfile,贷款合同信息,H&i);
%IFA_E	(&pathfile,担保信息,E&i);
%IFA_T	(&pathfile,投资人信息,T&i);
%IFA_G	(&pathfile,特殊交易信息,G&i);
%mend;




/*check前5列主键，若为空格则删除观测*/
/*补一个rename过程
D:\Rock_bamboo\2.CIS\A1.1NFCS\D.0NFCS_original_datafile\data20140504\2014-04-24\Q10152900HA900\Q10152900HA9002014040041\Q10152900HA9002014040041.xls*/



















