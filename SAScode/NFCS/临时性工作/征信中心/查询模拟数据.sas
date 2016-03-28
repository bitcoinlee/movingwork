options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;

/*δ��Ȩ��ѯ*/
data req_weishouquan;
	set nfcs.sino_person_certification(where = (sorgcode = "Q10152900H4400") keep = sorgcode sname scerttype scertno);
	if _n_ <= 1000;
	sorgcode = "T1210010010001";
	sreason = "�������";
	label
	sorgcode = ��������
	sname = ����
	scerttype = ֤������
	scertno = ֤������
	sreason = ��ѯԭ��
	;
run;

/*�������ѯ*/
data req_kuadiqu;
	set nfcs.sino_person_certification(where = (substr(scertno,1,2) = "31") keep = sorgcode sname scerttype scertno);
	if _n_ <= 1000;
	sorgcode = "T1210010010003";
	sreason = "��������";
	label
	sorgcode = ��������
	sname = ����
	scerttype = ֤������
	scertno = ֤������
	sreason = ��ѯԭ��
	;
run;

/*��ѯ���춯*/
data req_yidong;
	set nfcs.sino_person_certification(keep = sorgcode sname scerttype scertno);
		if _n_ <= 5000;
	sorgcode = "T1210010010004";
	sreason = "��������";
	label
	sorgcode = ��������
	sname = ����
	scerttype = ֤������
	scertno = ֤������
	sreason = ��ѯԭ��
	;
run;

libname xls excel "E:\�½��ļ���\201507\��������\���Ա���\ģ���ѯ������.xlsx";
	data xls.δ��Ȩ��ѯ(dblabel=yes);
		set req_weishouquan;
	data xls.�������ѯ(dblabel=yes);
		set req_kuadiqu;
	data xls.��ѯ���춯(dblabel=yes);
		set req_yidong;
run;
libname xls clear;
