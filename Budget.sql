---BUDGET---

-- 100863 PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

	SELECT count(t0."DocEntry") Into cnt
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1
	and IFNULL(t1."OcrCode",'')=''
	and IFNULL(I1."InvntItem",'N')='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';

	End If;
End If;

IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 101;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;

-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

	SELECT count(t0."DocEntry") Into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1
	and IFNULL(t1."OcrCode",'')=''
	and IFNULL(I1."InvntItem",'N')='N'

	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';

	End If;
End If;

-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 102;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;

-- 100863 AP Budgetyear =''
IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPCH t0
	left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'

	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;

-- 100863 APCN Budgetyear =''
IF :object_type ='19' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from ORPC t0
	left join RPC1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;


-- 100863 JE Budgetyear =''
IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."TransId") Into cnt
	from OJDT t0
	left join JDT1 t1 on t0."TransId" = t1."TransId"

	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and T0."TransType" IN ('30')
	and T0."StornoToTr"=0
	and t0."TransId" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then


	select count(t0."DocEntry") into cnt
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"

	where 1 = 1
	and IFNULL(t1."OcrCode",'')=''
	and T0."ObjType" IN ('1470000049','22')
	and IFNULL(I1."InvntItem",'N')='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';

	End If;
End If;

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

	select count(t0."DocEntry") into cnt1
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and T0."ObjType" IN ('1470000049','22','18','19')
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';

	End If;

End If;

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBDP"  T0
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"
	where 1 = 1
	and T0."ObjType" IN ('1470000113','22')
	and IFNULL(T1."Project",'') = ''
	and IFNULL(T1."OcrCode",'') <> ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."WddStatus" <> '-'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 105;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';

	End If;

End If;



-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBDP"  T0
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"
	where 1 = 1
	and IFNULL(T1."Project",'') = ''
	and IFNULL(T1."OcrCode",'') <> ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 100;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';

	End If;

End If;

-- 100863 PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBDP"  T0
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"
	where 1 = 1
	and IFNULL(T1."Project",'') = ''
	and IFNULL(T1."OcrCode",'') <> ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 501;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';

	End If;

End If;


-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBPJ"  T0
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"
	where 1 = 1
	--and T0."ObjType" IN ('1470000113','22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."WddStatus" <> '-'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 209;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';

	End If;

End If;



-- 100863 Draft Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBPJ"  T0
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"
	where 1 = 1
	--and T0."ObjType" IN ('22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 202;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';

	End If;

End If;

-- 100863 Draft PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode"
	FROM "@NDBS_BGC_OBPJ"  T0
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code"
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"

	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"
	where 1 = 1
	--and T0."ObjType" IN ('1470000113','22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then

		error := 203;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';

	End If;

End If;

-- PO Check Budget Year
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	select count(t0."DocEntry") into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBPJ"  T0 
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"  
	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",3) <> '202'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 301;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;


-- AP Check Budget Year
IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPCH t0
	left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
	AND T0."CANCELED"='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 302;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;


-- JE  Check Budget Year
IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."TransId") Into cnt
	from OJDT t0
	left join JDT1 t1 on t0."TransId" = t1."TransId"

	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
	and T0."TransType" IN ('30')
	and t0."TransId" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then
	
		error := 303;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;

if :error = 0 then
	call NDBS_BUDGET_CONTROL (:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
end if;


---BUDGET---