CREATE PROCEDURE NDBS_BUDGET_AP
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),
	in datakey nvarchar(255),
	out error  int,
	out error_message nvarchar (200)
)
LANGUAGE SQLSCRIPT
AS
begin

	-- Budget Control
	Declare LineNum INTEGER DEFAULT 0;
	Declare AutoKey Integer = 0;
	Declare IsCancelled Nvarchar(1);
	Declare OldProject Nvarchar(50);
	Declare OldDept Nvarchar(50);
	Declare OldGroup Nvarchar(50);
	Declare OldYear Nvarchar(50);
	Declare OldAmount DECIMAL(19, 2);
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

	Declare OldBProject Nvarchar(50);
	Declare OldBDept Nvarchar(50);
	
	Declare cursor loopinvcancel for		
		SELECT T0."BaseType",T0."BaseEntry",T0."BaseLine",T0."Project"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT JOIN OITM I1 ON T0."ItemCode"=I1."ItemCode"
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;

	--PR>PO>AP		
	Declare cursor loopinv1 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T3."Project" "OldProject"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		, CASE WHEN T11."DiscSum" = 0 THEN T3."LineTotal" ELSE T3."LineTotal"-ROUND((T3."LineTotal"/P."LineTotal")*T11."DiscSum",2) END AS "OldLineTotal"
		,T1."DocEntry",T0."LineNum",
		T6."Code",T6."U_Locked",T9."Code" "OldCode",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
		Case When T6."U_Center" = 'Y' THEN T6."U_Department"
		When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode" 
		ELSE T7."U_NDBS_BudgetDept" END "OcrCode",
		Case When T9."U_Center" = 'Y' THEN T9."U_Department"
		When T9."U_UseGroupCode" = 'N' THEN T10."PrcCode" 
		ELSE T10."U_NDBS_BudgetDept" END "OldOcrCode"
		FROM PCH1 T0 
		Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
		INNER Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
		INNER Join OPOR T11 ON T3."DocEntry" = T11."DocEntry"
		INNER Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
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
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from POR1 T0 group by  T0."DocEntry")P ON T11."DocEntry" = P."DocEntry"
		Where T0."LineTotal" <> 0  AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
	
	--AP		
	Declare cursor loopinv2 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department"
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode" 
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		LEFT join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
	
	--PR>PO>GRP>AP		
	Declare cursor loopinv3 for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."Project" "OldProject"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
			When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode"
			ELSE T7."U_NDBS_BudgetDept" END "OcrCode",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department"
				When T6."U_UseGroupCode" = 'N' THEN T8."PrcCode" 
				ELSE T8."U_NDBS_BudgetDept" END "OldOcrCode"
		FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
		INNER Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
		INNER Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		LEFT Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		LEFT Join OPRC T8 ON T8."PrcCode" = T2."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
		
	
	

	if(:transaction_type IN ('A','C')) then
		
		Select "CANCELED" into IsCancelled From OPCH Where "DocEntry" = :datakey;
		IF IsCancelled = 'C' then
			for currloop as loopinvcancel do
				IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then
					BaseType = currloop."BaseType";
					BaseKey = currloop."BaseEntry";
					BaseLine = currloop."BaseLine";
					
					Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C'
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
					
					Select Count(*) into BCOunt
					From "NDBS_BGC_OBDE" 
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
				
					if BCOunt > 0 
					then
					
						Select TOP 1 "BudgetYear","BudgetGroup","Department"  into OldYear,OldGroup,OldDept
						From "NDBS_BGC_OBDE" 
						Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine
						Order By "DocEntry" Desc;
					end if;	
				else
					BaseType = currloop."BaseType";
					BaseKey = currloop."BaseEntry";
					BaseLine = currloop."BaseLine";
					
					Update "NDBS_BGC_OBPE" Set "BudgetStatus" = 'C'
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
					
					Select Count(*) into BCOunt
					From "NDBS_BGC_OBPE" 
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
				
					if BCOunt > 0 
					then
					--IF :BaseKey NOT IN  ('173687','173836','174798','176967') THEN 
						Select TOP 1 IFNULL("BudgetYear",0), IFNULL("BudgetGroup",''), IFNULL("Project",'')  into OldYear,OldGroup,OldDept
						From "NDBS_BGC_OBPE" 
						Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine
						Order By "DocEntry" Desc;
					
					end if;
				end if;					
			end for;
		else
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
			--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
			Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_FormatCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			--- 24 Oct 2025 ---
			LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :datakey AND IFNULL(I1."InvntItem",'N') <> 'Y';
		
			IF :Bcount > 0 then
				for currloop as loopinv1 do
					IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
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
						OldAmount = currloop."OldLineTotal";
						OldGroup = currloop."OldCode";
						
					
						Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal",T0."Quantity",T1."Quantity" into BDiffAmount, BaseAmount,ActQty,BaseQty
						FROM PCH1 T0 Inner JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
						--- 24 Oct 2025 ---
						LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
						WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
						Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
						AutoKey = :AutoKey+1;
						IF ActQty <> BaseQty then
							BaseAmount = ROUND(BaseAmount*ActQty/BaseQty,0.01);
						end if;
						
						AutoKey = :AutoKey+1;
						
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:OldGroup,TO_NVARCHAR(:BYear),:OldDept,:BaseType,:BaseKey,:BaseLine,
								'18',:DocKey,:DocLine,-:OldAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);
		
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldDept,'18',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
								
					else
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
						OldBProject = currloop."OldProject";
						OldAmount = currloop."OldLineTotal";
						OldGroup = currloop."OldCode";
						
						Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal",T0."Quantity",T1."Quantity" into BDiffAmount, BaseAmount,ActQty,BaseQty
						FROM PCH1 T0 Inner JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
						--- 24 Oct 2025 ---
						LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
						WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
						Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
						AutoKey = :AutoKey+1;
						IF ActQty <> BaseQty then
							BaseAmount = ROUND(BaseAmount*ActQty/BaseQty,0.01);
						end if;
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:OldGroup,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
								'18',:DocKey,:DocLine,-:OldAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);
						AutoKey = :AutoKey+1;
							
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,'18',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);	
					end if;
				end for;
			else
				SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
				FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
				Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
				Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
				Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
				Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
				Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
				--- 24 Oct 2025 ---
				LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
				Where T0."LineTotal" <> 0 AND T0."DocEntry" = :datakey AND IFNULL(I1."InvntItem",'N') <> 'Y';
				IF :Bcount > 0 then
					for currloop as loopinv3 do
						IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
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
							OldBDept = currloop."OldOcrCode";
							
							Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
							FROM PCH1 T0 Inner JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
							--- 24 Oct 2025 ---
							LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
							WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
							Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
							AutoKey = :AutoKey+1;
						
							INSERT INTO "NDBS_BGC_OBDE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBDept,:BaseType,:BaseKey,:BaseLine,
									'18',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','18',:DocKey,:DocLine);
										
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBDE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBDept,'18',:DocKey,:DocLine,
									:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
									
						else
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
							OldBProject = currloop."OldProject";
							
							Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
							FROM PCH1 T0 Inner JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
							--- 24 Oct 2025 ---
							LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
							WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
							Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
							AutoKey = :AutoKey+1;
						
							INSERT INTO "NDBS_BGC_OBPE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
									'18',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','18',:DocKey,:DocLine);
										
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBPE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,'18',:DocKey,:DocLine,
									:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);								
						end if;
					end for;
				else
					for currloop as loopinv2 do
						IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then 
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
							IF (:BaseType = '18') then
								BaseAmount = -:BaseAmount;
							End if;
							Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
							AutoKey = :AutoKey+1;
							IF (BaseType='18') then
								SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
								FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
								--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
								Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
								Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
								Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
								Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
								--- 24 Oct 2025 ---
								LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
								Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND IFNULL(I1."InvntItem",'N') <> 'Y';
					
								IF :Bcount > 0 then
									SELECT T1."DocDate",T0."U_NDBS_BudgetYear", T0."Project"
									, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
									,T1."DocEntry",T0."LineNum",
											T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
											Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode",
											Case When T8."U_Center" = 'Y' THEN T8."U_Department" ELSE T3."OcrCode" END "OcrCode"
									Into BValDate,BYear,BProject,BAmount,DocKey,DocLine,BCode,BLocked,BNotChecked,BReason,BaseType,BaseKey,BaseLine,BDept,OldDept
									FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
									Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
									Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
									Inner Join "@NDBS_BGC_BGPL" T7 ON T7."U_AccountCode" = T3."AcctCode"
									Inner Join "@NDBS_BGC_OBGP" T8 ON T7."Code" = T8."Code"
									--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									left join 
									( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
	
									Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND T0."LineNum" = :BaseLine ;
									
									Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
									FROM PCH1 T0 Inner JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
									--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
									BAmount = -:BAmount;
									AutoKey = :AutoKey+1;
									
									INSERT INTO "NDBS_BGC_OBDE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
									VALUES
										(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldDept,:BaseType,:BaseKey,:BaseLine,
											'18',:DocKey,:DocLine,:BaseAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);
											
									AutoKey = :AutoKey+1;
									INSERT INTO "NDBS_BGC_OBDE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
									VALUES
										(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldDept,'18',:DocKey,:DocLine,
											:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
									
								else
									SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
									FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
									Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
									Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
									Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
										--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND IFNULL(I1."InvntItem",'N') <> 'Y';
									IF :Bcount > 0 then
										SELECT T1."DocDate",T0."U_NDBS_BudgetYear", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
											T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
											Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
										Into BValDate,BYear,BProject,BAmount,DocKey,DocLine,BCode,BLocked,BNotChecked,BReason,BaseType,BaseKey,BaseLine,BDept
										FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
										Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
										Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
										Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
										Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
										Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
										--- 24 Oct 2025 ---
										LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
										Where T0."LineTotal" <> 0  AND T0."DocEntry" = :BaseKey AND T0."LineNum" = :BaseLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
										
										Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
										FROM PCH1 T0 Inner JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
										--- 24 Oct 2025 ---
										LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
										WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
										BAmount = -:BAmount;
										AutoKey = :AutoKey+1;
									
										INSERT INTO "NDBS_BGC_OBDE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,:BaseType,:BaseKey,:BaseLine,
												'18',:DocKey,:DocLine,:BaseAmount,'A',:BValDate,'A','18',:DocKey,:DocLine);
												
										AutoKey = :AutoKey+1;
										INSERT INTO "NDBS_BGC_OBDE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
												:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
											
												
									else 
										BAmount = -:BAmount;
										INSERT INTO "NDBS_BGC_OBDE"
											("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
											"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
												:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
												
											
									end if;
								end if;
							else
								INSERT INTO "NDBS_BGC_OBDE"
									("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
									"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
								VALUES
									(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
										:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
								
							end if;
						else
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
							IF (:BaseType = '18') then
								BaseAmount = -:BaseAmount;
							End if;
							Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
							AutoKey = :AutoKey+1;
							IF (BaseType='18') then
								SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
								FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
								--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
								Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
								Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
								Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_FormatCode" = T4."FormatCode"
								Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
								--- 24 Oct 2025 ---
								LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
								Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND IFNULL(I1."InvntItem",'N') <> 'Y';
					
								IF :Bcount > 0 then
									SELECT T1."DocDate",T0."U_NDBS_BudgetYear", T3."Project"

									, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
									,T1."DocEntry",T0."LineNum",
											T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
											Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T3."OcrCode" END "OcrCode"
									Into BValDate,BYear,BProject,BAmount,DocKey,DocLine,BCode,BLocked,BNotChecked,BReason,BaseType,BaseKey,BaseLine,BDept
									FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
									Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
									Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_FormatCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
									--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									left join 
									( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
	
									Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND T0."LineNum" = :BaseLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
									
									Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
									FROM PCH1 T0 left JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
									--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
									BAmount = -:BAmount;
									AutoKey = :AutoKey+1;
								
									INSERT INTO "NDBS_BGC_OBPE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
									VALUES
										(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
											'18',:DocKey,:DocLine,:BaseAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);
											
									AutoKey = :AutoKey+1;
									INSERT INTO "NDBS_BGC_OBPE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
									VALUES
										(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
											:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
									
								else
									SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
									FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
									Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
									Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
									Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
									Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
									--- 24 Oct 2025 ---
									LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
									Where T0."LineTotal" <> 0 AND T0."DocEntry" = :BaseKey AND IFNULL(I1."InvntItem",'N') <> 'Y';
									IF :Bcount > 0 then
										SELECT T1."DocDate",T0."U_NDBS_BudgetYear", T0."Project"
										, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
									
										,T1."DocEntry",T0."LineNum",
											T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
											Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
										Into BValDate,BYear,BProject,BAmount,DocKey,DocLine,BCode,BLocked,BNotChecked,BReason,BaseType,BaseKey,BaseLine,BDept
										FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
										Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine" AND T0."BaseType" = '20'
										Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine" AND T2."BaseType" = '22'
										Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
										Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
										Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
										--- 24 Oct 2025 ---
										LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
										left join 
										( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from PCH1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
	
										Where T0."LineTotal" <> 0  AND T0."DocEntry" = :BaseKey AND T0."LineNum" = :BaseLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
										
										Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
										FROM PCH1 T0 left JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
										--- 24 Oct 2025 ---
										LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
										WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
	
										BAmount = -:BAmount;
										AutoKey = :AutoKey+1;
									
										INSERT INTO "NDBS_BGC_OBPE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
												'18',:DocKey,:DocLine,:BaseAmount,'A',:BValDate,'A','18',:DocKey,:DocLine);
												
										AutoKey = :AutoKey+1;
										INSERT INTO "NDBS_BGC_OBPE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
												:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
										
												
									else 
										BAmount = -:BAmount;
										INSERT INTO "NDBS_BGC_OBPE"
											("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
											"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
												:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
												
											
									end if;
								end if;
							else
								INSERT INTO "NDBS_BGC_OBPE"
									("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
									"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
								VALUES
									(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
										:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);
								
							end if;
						end if;
					end for;
				end if;
			end if;
		end if;
	end if;

end;