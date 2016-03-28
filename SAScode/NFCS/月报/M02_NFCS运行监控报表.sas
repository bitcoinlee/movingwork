/*libname nfcs "D:\����\201602";*/
%include "E:\�½��ļ���\SAS\config.sas";

proc sql;
	create table nfcs_op as select
		T2.sorgcode
		,T2.SMSGFILENAME
		,T1.ITOTALCOUNT
		,T1.ISUCCESSCOUNT
		,intck('minute',T2.DCREATETIME,T3.DSTARTTIME) as quere_time label = "����ʱ��"
		,intck('minute',T3.DSTARTTIME,T3.DSTOPTIME) as handle_time label = "����ʱ��"
/*		,(case when intck('minute',T2.DCREATETIME,T3.DSTARTTIME) < 0 then 0 else intck('minute',T2.DCREATETIME,T3.DSTARTTIME) end) as quere_time label = "�Ŷ�ʱ��"*/
/*		,round(T1.ITOTALCOUNT/calculated handle_time,1) as handle_spd label = "�����ٶ�(��λ����/����)"*/
		,T2.DCREATETIME
		,intnx('month',datepart(DHANDLEDATE),0,'b') as DHANDLEDATE label = "�·�" format = yymmn6.
		,T2.STASKTYPE
		,T3.DSTARTTIME
		,T3.DSTOPTIME
		,(case when t3.ISTATE in (2,3) then 1 else 0 end) as ISTATE
/*		,t3.SEXCEPTION*/
	from nfcs.sino_task as T2
	left join  nfcs.sino_msg as T1
	on T1.SMSGFILENAME = T2.SMSGFILENAME
	left join nfcs.sino_taskdetail as T3
	on T3.ITASKID = T2.IID 	
		where T1.ITOTALCOUNT is not null
		order by DCREATETIME;
;
quit;

proc sql;
	create table yuefen as select
	distinct DHANDLEDATE as yuefen
	,intnx('month',yuefen,0,'b') as firstday format = yymmddn8.
	,intnx('month',yuefen,0,'e') as lastday format = yymmddn8.
	,intck('day',calculated firstday,calculated lastday)*60*24 as fulltime label = "����ȫ��ʱ�� ����λ�����ӣ�"
	from nfcs_op
;
quit;

proc UNIVARIATE data =nfcs_op noprint;
var quere_time handle_time ITOTALCOUNT ISTATE;
by DHANDLEDATE;
output out = nfcs_op_1 max= qt_max mean = qt_mean sum = qt_sum ht_sum bw_cnt err_cnt;
label
DHANDLEDATE = �·�
bw_cnt = ���±�������
qt_max = ������Ŷ�ʱ�� ����λ�����ӣ�
/*qt_md = �����Ŷ�ʱ����λ�� ����λ�����ӣ�*/
qt_mean = ����ƽ���Ŷ�ʱ�� ����λ�����ӣ�
/*qt_std = �����Ŷ�ʱ���׼�� ����λ�����ӣ�*/
qt_sum = �����ۼ��Ŷ�ʱ�� ����λ�����ӣ�
ht_sum = �����ۼƴ���ʱ�� ����λ�����ӣ�
err_cnt = �쳣����
;
run;

proc sql;
	create table _nfcs_op as select
		T2.yuefen
		,T1.bw_cnt
		,t1.ht_sum
		,T2.fulltime
		,t1.ht_sum/T2.fulltime as per_use label = "��Դʹ����" format = percent8.2
		,ROUND(T1.qt_mean,1) AS qt_mean LABEL = "����ƽ���Ŷ�ʱ�� ����λ�����ӣ�"
		,t1.qt_max
		,T1.err_cnt
	from nfcs_op_1 as T1
	left join yuefen(drop = firstday lastday) as T2
	on T1.DHANDLEDATE = T2.yuefen
;
quit;

/*��ѯ������Ӧ���*/
/*	proc sql;*/
/*		create table nfcs_op_cx as select*/
/*			sorgcode label = "��������"*/
/*			,(case when IPERSONID = 0 then 0 else 1 end) as label_cd label = "�Ƿ���"*/
/*			,intnx('month',datepart(DCREATETIME),0,'b') as yuefen label = "�·�" format = yymmn6.*/
/*			,intck('second',DREQUESTTIME,DCREATETIME) as time_wait label = "��Ӧʱ��" */
/*		from nfcs.Sino_credit_record(keep = sorgcode IPERSONID DCREATETIME DREQUESTTIME)*/
/*	;*/
/*	quit;*/
/*	*/


proc template;
  define style styles.XLStatistical;
	parent = styles.Statistical;
	style Header from Header / borderwidth=2;
    style RowHeader from RowHeader / borderwidth=2;
    style Data from Data / borderwidth=2;
  end;
run; 
quit;

proc template;
        define style formatSTYLE;
        STYLE SystemTitle /
                FONT_FACE = "Times New Roman"
                FONT_SIZE = 2.5
                FONT_STYLE = roman
                FOREGROUND = black
                BACKGROUND = white;
        STYLE Header /
                BACKGROUND = white
                FOREGROUND = black
                FONT_FACE = "Times New Roman"
                FONT_STYLE = roman
                JUST = center
                VJUST = middle
                FONT_SIZE = 2.5;
        STYLE Cell /
                BACKGROUND = white
                FOREGROUND = black
                FONT_FACE = "Times New Roman"
                FONT_WEIGHT = light
                FONT_STYLE = roman
                JUST = center
                VJUST = middle
                FONT_SIZE = 2.5;
        STYLE Table /
                RightMargin=3.17cm
                LeftMargin=3.17cm
                TopMargin=2.54cm 
                BottomMargin=2.54cm
                CELLSPACING = 0
                CELLPADDING = 2
                FRAME = void
                RULES = none
                OUTPUTWIDTH = 925;
        end;
run;

ods listing off;
 ods tagsets.excelxp file="E:\�½��ļ���\SAS\���ô���\�Զ���\����ļ���\�±����\&curr_month.\NFCSϵͳ�����������_&STAT_OP..xls" style = printer
      options(sheet_name="NFCSϵͳ�����������" embedded_titles='yes' embedded_footnotes='yes' sheet_interval="bygroup" frozen_headers='yes' frozen_rowheaders='1' autofit_height='yes');
proc report data = _nfcs_op NOWINDOWS headline headskip
          style(header)={background=lightgray foreground=black  JUST = center VJUST = center fontweight = bold};
/*		  style yymmnn_yyyy-mm from data / tagattr = 'type:DateTime format:yyyy��mm��';*/
title "NFCSϵͳ�����������";
	columns _all_;
	define yuefen /display format = yymmn6.;
	define ht_sum /display '�����ۼƴ���ʱ��/(��λ�����ӣ�' center;
	define fulltime /display '����ȫ��ʱ��/����λ�����ӣ�' center;
	define per_use/display 'ϵͳ������' center;
	define qt_mean /display '����ƽ���Ŷ�ʱ��/����λ�����ӣ�' center;
	define qt_max /display '������Ŷ�ʱ��/����λ�����ӣ�' center;
	define err_cnt /display '�쳣����' center;
	compute ht_sum;
 	if 0.8 > per_use >= 0.6 then 
 		call define(_c2_,'style','style={background=lightyellow fontweight=bold}');
 	else if 1 > per_use >= 0.8 then 
	 	call define(_c2_,'style','style={background=lightred fontweight=bold}');
	else if per_use >= 1 then
	 	call define(_c2_,'style','style={background=darkred fontweight=bold}');
 	endcomp;
footnote ���쳣������������2-���� 3-������;
run;
ods tagsets.excelxp close;
  ods listing;

/*libname xls excel "C:\Users\linan\Documents\����\SAS\NFCSϵͳ�����������.xlsx";*/
/*data xls.sheet1(dblabel=yes);*/
/*	set _nfcs_op;*/
/*run;*/
/*libname xls clear;*/
