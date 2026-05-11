CREATE PROCEDURE NDBS_BUDGET_BEGINING_BK11122025
(
	
)
LANGUAGE SQLSCRIPT
AS
begin
	-- Budget Control
	declare LineNum INTEGER DEFAULT 0;
	Declare AutoKey Integer = 0;
	Declare IsCancelled Nvarchar(1);
	Declare OldProject Nvarchar(50);
	Declare OldDept Nvarchar(50);
	Declare OldGroup Nvarchar(50);
	Declare OldYear Nvarchar(50);
	Declare BProject Nvarchar(50);
	Declare BDept Nvarchar(50);
	Declare DocDept Nvarchar(50);
	Declare BCode Nvarchar(50);
	Declare BLocked Nvarchar(1);
	Declare BNotChecked Nvarchar(1);
	Declare BReason Nvarchar(100);
	Declare BItem Nvarchar(50);
	Declare BValDate Date;
	Declare BYear Integer;
	Declare BaseAmount DECIMAL(19, 2);
	Declare LineAmount DECIMAL(19, 2);
	Declare BAmount DECIMAL(19, 2);
	Declare BAvailable DECIMAL(19, 2);
	Declare BDiffAmount DECIMAL(19, 2);
	Declare DraftAppStatus nvarchar(50);
	Declare DraftType nvarchar(50);
	Declare DraftKey Integer = 0;
	Declare DocKey Integer = 0;
	Declare DocLine Integer = 0;
	Declare BaseType nvarchar(50);
	Declare BaseKey Integer = 0;
	Declare BaseLine Integer = 0;
	Declare BCOunt Integer = 0;
	Declare IsDraft nvarchar(50);
	Declare DraftObject nvarchar(50);
	Declare NetReserve DECIMAL(19, 2);
	Declare NetActual DECIMAL(19, 2);
	Declare BaseQty DECIMAL(19, 2);
	Declare ActQty DECIMAL(19, 2);
	
	/*
	Declare cursor looppr  for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."OpenSum" "LineTotal",T1."DocEntry",T0."LineNum",
				T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",
				Case When T4."U_Center" = 'Y' THEN T4."U_Department" 
				When T4."U_UseGroupCode" = 'Y' THEN T5."U_NDBS_BudgetDept" 
				ELSE T5."PrcCode" END "OcrCode"
		FROM PRQ1 T0 Inner Join OPRQ T1 ON T0."DocEntry" = T1."DocEntry"
		Inner Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
		Inner Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		Inner Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		Inner Join OPRC T5 ON T5."PrcCode" = T0."OcrCode"
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 AND T1."CANCELED" = 'N';
	*/
	Declare cursor looppo for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."OpenSum" 
		ELSE ROUND((T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2))*T0."OpenQty"/T0."Quantity",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T4."U_Center" = 'Y' THEN T4."U_Department" 
				When T4."U_UseGroupCode" = 'N' THEN T5."PrcCode"
				ELSE T5."U_NDBS_BudgetDept" END "OcrCode"
		FROM POR1 T0 Inner Join OPOR T1 ON T0."DocEntry" = T1."DocEntry" AND T0."LineStatus"='O'
		INNER Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		LEFT Join OPRC T5 ON T5."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from POR1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL 
		AND T0."U_NDBS_BudgetYear" >= 2024 AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
		
	Declare cursor loopgrn for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T5."U_Center" = 'Y' THEN T5."U_Department" 
				When T5."U_UseGroupCode" = 'N' THEN T6."PrcCode"
				ELSE T6."U_NDBS_BudgetDept" END "OcrCode"
		FROM PDN1 T0 Inner Join OPDN T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join POR1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
		INNER Join OACT T3 ON T2."AcctCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
		LEFT Join OPRC T6 ON T6."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		LEFT join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PDN1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 
		AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	--PR>PO>AP		
	Declare cursor loopinv1 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department"
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode" 
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode",
				Case When T9."U_Center" = 'Y' THEN T9."U_Department"
				When T9."U_UseGroupCode" = 'N' THEN T10."PrcCode" 
				ELSE T10."U_NDBS_BudgetDept" END "OldOcrCode"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
		INNER Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
		INNER Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		INNER Join "@NDBS_BGC_BGPL" T8 ON T8."U_AccountCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T9 ON T8."Code" = T9."Code"		
		LEFT Join OPRC T10 ON T10."PrcCode" = T3."OcrCode"		
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 
		AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	--AP		
	Declare cursor loopinv2 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department"
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode" 
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry" AND T0."BaseType"='-1'
		INNER Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		LEFT join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 
		AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	--PR>PO>GRP>AP		
	Declare cursor loopinv3 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
			When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode"
			ELSE T7."U_NDBS_BudgetDept" END "OcrCode"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
		INNER Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
		INNER Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 
		AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	Declare cursor loopreturn for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
	, CASE WHEN T1."DiscSum" = 0 THEN T0."OpenSum" 
	ELSE ROUND((T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2))*T0."OpenQty"/T0."Quantity",2) END AS "LineTotal"
	,T1."DocEntry",T0."LineNum",
				T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T5."U_Center" = 'Y' THEN T5."U_Department" 
				When T5."U_UseGroupCode" = 'N' THEN T6."PrcCode"
				ELSE T6."U_NDBS_BudgetDept" END "OcrCode"
		FROM RPD1 T0 Inner Join ORPD T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT Join OACT T3 ON T0."AcctCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
		left Join OPRC T6 ON T6."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from RPD1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0  AND T0."U_NDBS_BudgetYear" IS NOT NULL 
		AND T0."U_NDBS_BudgetYear" >= 2024 AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
		
	Declare cursor loopcn1 for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
	, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
	,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode"
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode"
		FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
		LEFT Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		left Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from RPD1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024 
		AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	Declare cursor loopcn2 for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
	, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
	,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode"
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode"
		FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		LEFT join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from RPD1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND T0."U_NDBS_BudgetYear" IS NOT NULL 
		AND T0."U_NDBS_BudgetYear" >= 2024 AND T1."CANCELED" = 'N' AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
	Declare cursor loopje for
		SELECT T0."RefDate",CASE WHEN  T0."TransType" = 30 THEN T0."U_NDBS_BudgetYear" ELSE YEAR(T0."RefDate") END AS "U_NDBS_BudgetYear"
		,T0."ProfitCode" "DocDept", T0."Project", (T0."Debit"-T0."Credit") "Amt",T0."TransId",T0."Line_ID",
				T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."TransType" "BaseType",0 "BaseEntry",0 "BaseLine",
				Case When T5."U_Center" = 'Y' THEN T5."U_Department" 
				When T5."U_UseGroupCode" = 'N' THEN T6."PrcCode"
				ELSE T6."U_NDBS_BudgetDept" END "ProfitCode"
		FROM JDT1 T0 Inner Join OJDT T1 ON T0."TransId" = T1."TransId"
		LEFT Join OACT T3 ON T0."Account" = T3."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
		LEFT Join OPRC T6 ON T6."PrcCode" = T0."ProfitCode"
		Where (T0."Debit"-T0."Credit") <> 0 AND T0."TransType" IN( '30','46','24','59','60') AND IFNULL(T1."U_NDBS_UseBudget",'N') = 'Y'
		 AND T0."U_NDBS_BudgetYear" IS NOT NULL AND T0."U_NDBS_BudgetYear" >= 2024;		
		 
    /*
	for currloop as looppr do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
			"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."OcrCode",'1470000113',currloop."DocEntry",currloop."LineNum",
					'',0,0,currloop."LineTotal",'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum",'Y','looppr');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
			"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."Project",'1470000113',currloop."DocEntry",currloop."LineNum",
					'',0,0,currloop."LineTotal",'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum",'Y','looppr');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;
	end for;
	*/
	
	for currloop as looppo do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
				"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine,'Y','looppo');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";

			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
			"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I',
					'22',:DocKey,:DocLine,'Y','looppo');		
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);		
		end if;	
	end for;
	
	for currloop as loopgrn do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";

			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'20',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','20',:DocKey,:DocLine,'Y','loopgrn');	
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'20',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','20',:DocKey,:DocLine,'Y','loopgrn');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopinv1 do
		IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			OldDept	= currloop."OldOcrCode";
		
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv1');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
							
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv1');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopinv2 do
		IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
		
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv2');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
							
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv2');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopinv3 do
		IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
		
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv3');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
							
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine,'Y','loopinv3');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopreturn do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
				
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'21',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','21',:DocKey,:DocLine,'Y','loopreturn');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
						
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'21',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','21',:DocKey,:DocLine,'Y','loopreturn');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopcn1 do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine,'Y','loopcn1');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine,'Y','loopcn1');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopcn2 do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine,'Y','loopcn2');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."DocDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."OcrCode";
			BProject = currloop."Project";
			BAmount = currloop."LineTotal";
			DocKey = currloop."DocEntry";
			DocLine = currloop."LineNum";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine,'Y','loopcn2');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		end if;	
	end for;
	for currloop as loopje do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			BValDate = currloop."RefDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."ProfitCode";
			BProject = currloop."Project";
			BAmount = currloop."Amt";
			DocKey = currloop."TransId";
			DocLine = currloop."Line_ID";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
			
			AutoKey = :AutoKey+1;
				
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,
					'',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine,'Y','loopje');
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		elseif (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			BValDate = currloop."RefDate";
			BYear = currloop."U_NDBS_BudgetYear";
			BDept = currloop."ProfitCode";
			BProject = currloop."Project";
			BAmount = currloop."Amt";
			DocKey = currloop."TransId";
			DocLine = currloop."Line_ID";
			BCode = currloop."Code";
			BLocked = currloop."U_Locked";
			BNotChecked = currloop."U_NDBS_NotCheckBudget";
			BReason = currloop."U_NDBS_BudgetReason";
			BaseType = currloop."BaseType";
			BaseKey = currloop."BaseEntry";
			BaseLine = currloop."BaseLine";
		
			AutoKey = :AutoKey+1;
			
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine","BF","TYPE")
			VALUES
				(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'30',:DocKey,:DocLine,
					:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine,'Y','loopje');
					
			Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);	
		end if;	
	end for;
end;
