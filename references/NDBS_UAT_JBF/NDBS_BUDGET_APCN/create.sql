CREATE PROCEDURE NDBS_BUDGET_APCN
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

		
	Declare cursor loopcncancel for		
		SELECT T0."BaseType",T0."BaseEntry",T0."BaseLine",T0."Project"
		FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT JOIN OITM I1 ON T0."ItemCode"=I1."ItemCode"
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
		
	Declare cursor loopcn1 for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T2."Project" "OldProject"
	, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
	,T1."DocEntry",T0."LineNum",
				T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
				When T6."U_UseGroupCode" = 'N' THEN T7."PrcCode"
				ELSE T7."U_NDBS_BudgetDept" END "OcrCode",
				Case When T6."U_Center" = 'Y' THEN T6."U_Department" 
				When T6."U_UseGroupCode" = 'N' THEN T8."PrcCode"
				ELSE T8."U_NDBS_BudgetDept" END "OldOcrCode"
		FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
		LEFT Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
		LEFT Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
		left Join OPRC T7 ON T7."PrcCode" = T0."OcrCode"
		left Join OPRC T8 ON T8."PrcCode" = T2."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from RPD1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
	
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
		
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
		
	
	if(:transaction_type IN ('A','C')) then
		Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
		Select "CANCELED" into IsCancelled From ORPC Where "DocEntry" = :datakey;
		IF IsCancelled = 'C' then
			for currloop as loopcncancel do
				IF (currloop."Project" IS NULL) OR (currloop."Project" = '') then
					BaseType = currloop."BaseType";
					BaseKey = currloop."BaseEntry";
					BaseLine = currloop."BaseLine";
					
					Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C'
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
					
					--add 30/06/2025
					Select Count(*)  into BCount
					From "NDBS_BGC_OBDE" 
					Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
					IF BCount >= 0 then
					--IF :BaseKey NOT IN  ('2319') THEN 
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
					
					--add 30/06/2025
					Select Count(*)  into BCount
					From "NDBS_BGC_OBPE" 
						Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
					IF BCount >= 0 then
						--IF :BaseKey NOT IN  ('2319') THEN 
						Select TOP 1 "BudgetYear","BudgetGroup","Project"  into OldYear,OldGroup,OldProject
						From "NDBS_BGC_OBPE" 
						Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine
						Order By "DocEntry" Desc;

					end if;	
				end if;					
			end for;
		else
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
			Inner Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_FormatCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			--- 24 Oct 2025 ---
			LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :datakey AND IFNULL(I1."InvntItem",'N') <> 'Y';

			IF :Bcount > 0 then
				for currloop as loopcn1 do
					if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
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
						FROM RPC1 T0 Inner JOin RPD1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
						--- 24 Oct 2025 ---
						LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
						WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
					
						AutoKey = :AutoKey+1;
					
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBDept,:BaseType,:BaseKey,:BaseLine,
								'19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','19',:DocKey,:DocLine);
	
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);	
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
						FROM RPC1 T0 Inner JOin RPD1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
						--- 24 Oct 2025 ---
						LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
						WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y' ;
					
						AutoKey = :AutoKey+1;
					
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
								'19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','19',:DocKey,:DocLine);	
						
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);
					end if;
				end for;
			else
				for currloop as loopcn2 do
					if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
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
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);
								
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
					
						AutoKey = :AutoKey+1;
						
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
								"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);
					end if;
				end for;
			end if;
		end if;
	end if;

end;