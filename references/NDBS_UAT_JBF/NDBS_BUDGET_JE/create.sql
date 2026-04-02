CREATE PROCEDURE NDBS_BUDGET_JE
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

		
		
	Declare cursor loopje for
		SELECT T0."RefDate"
		,CASE WHEN T0."TransType" = 30 THEN T0."U_NDBS_BudgetYear" ELSE YEAR(T0."RefDate") END AS "U_NDBS_BudgetYear"
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
		Where (T0."Debit"-T0."Credit") <> 0 AND T0."TransType" IN( '30','46','24','59','60') AND T0."TransId" = :datakey AND IFNULL(T1."U_NDBS_UseBudget",'N') = 'Y';	
	

	
	if(:transaction_type IN ('A','U')) then
	
		Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
		for currloop as loopje do
			if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			
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
				
				if (:transaction_type IN ('U')) THEN
					Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C' Where "ObjectType" = '30' AND "ObjectID"= :DocKey AND "ObjectLine" = :DocLine AND "BudgetStatus" in ('I','O'); 
				end if;	
				INSERT INTO "NDBS_BGC_OBDE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
							"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,
						'',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);
						

			else
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
				if (:transaction_type IN ('U')) THEN
				Update "NDBS_BGC_OBPE" Set "BudgetStatus" = 'C' Where "ObjectType" = '30' AND "ObjectID"= :DocKey AND "ObjectLine" = :DocLine AND "BudgetStatus" in ('I','O'); 
				end if;	
				INSERT INTO "NDBS_BGC_OBPE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
							"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'30',:DocKey,:DocLine,
						'',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);	
			end if;
		end for;
	end if;
	

end;