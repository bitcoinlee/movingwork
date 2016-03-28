options compress=yes mprint mlogic noxwait;
libname nfcs oracle user=datauser password=zlxdh7jf path=p2p;

/*未授权查询*/
data req_weishouquan;
	set nfcs.sino_person_certification(where = (sorgcode = "Q10152900H4400") keep = sorgcode sname scerttype scertno);
	if _n_ <= 1000;
	sorgcode = "T1210010010001";
	sreason = "贷后管理";
	label
	sorgcode = 机构代码
	sname = 姓名
	scerttype = 证件类型
	scertno = 证件号码
	sreason = 查询原因
	;
run;

/*跨地区查询*/
data req_kuadiqu;
	set nfcs.sino_person_certification(where = (substr(scertno,1,2) = "31") keep = sorgcode sname scerttype scertno);
	if _n_ <= 1000;
	sorgcode = "T1210010010003";
	sreason = "贷款审批";
	label
	sorgcode = 机构代码
	sname = 姓名
	scerttype = 证件类型
	scertno = 证件号码
	sreason = 查询原因
	;
run;

/*查询量异动*/
data req_yidong;
	set nfcs.sino_person_certification(keep = sorgcode sname scerttype scertno);
		if _n_ <= 5000;
	sorgcode = "T1210010010004";
	sreason = "贷款审批";
	label
	sorgcode = 机构代码
	sname = 姓名
	scerttype = 证件类型
	scertno = 证件号码
	sreason = 查询原因
	;
run;

libname xls excel "E:\新建文件夹\201507\征信中心\测试报文\模拟查询用数据.xlsx";
	data xls.未授权查询(dblabel=yes);
		set req_weishouquan;
	data xls.跨地区查询(dblabel=yes);
		set req_kuadiqu;
	data xls.查询量异动(dblabel=yes);
		set req_yidong;
run;
libname xls clear;
