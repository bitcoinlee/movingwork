options compress=yes mprint mlogic noxwait;
libname mylib oracle user=datauser password=zlxdh7jf path=p2p;
DATA zhangwu_sq;
	SET mylib.sino_loan_apply(keep= sorgcode sapplycode Spin Imoney WHERE=(SUBSTR(SORGCODE,1,1)='Q' AND SORGCODE not in ('Q10152900H0000' 'Q10152900H0001')));
RUN;
proc sql noprint;
	select count(sorgcode),count(distinct spin),put(round(sum(IMONEY)/100000000,0.01),best12.) into :sq_count,:sq_person,:sq_MONEY
	from zhangwu_sq
	;
quit;
%put &sq_count.;
%put &sq_person.;
%put &sq_MONEY.;
%let x = %sysfunc(compress(%str(NFCS申请记录数)&sq_count.%str(,人数)&sq_person.%str(,申请金额)&sq_MONEY.%str(亿元)));
%put &x.;
