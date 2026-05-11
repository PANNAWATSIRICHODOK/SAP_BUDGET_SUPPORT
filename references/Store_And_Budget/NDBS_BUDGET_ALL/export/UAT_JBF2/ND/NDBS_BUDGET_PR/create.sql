CREATE PROCEDURE NDBS_BUDGET_PR
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),
	in datakey nvarchar(255),
	out error  int,
	out error_message nvarchar (200)
)
LANGUAGE SQLSCRIPT
AS
	AutoKey int;
	BAvailable DECIMAL(19, 2);
	OldProject Nvarchar(50);
	OldDept Nvarchar(50);
	OldGroup Nvarchar(50);
	OldYear Nvarchar(50);
	CountRec INT;
begin
	
	Declare cursor looppr  for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
				T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",
				Case When T4."U_Center" = 'Y' THEN T4."U_Department" 
				When T4."U_UseGroupCode" = 'Y' THEN T5."U_NDBS_BudgetDept" 
				ELSE T5."PrcCode" END "OcrCode"
		FROM PRQ1 T0 Inner Join OPRQ T1 ON T0."DocEntry" = T1."DocEntry"
		Inner Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
		Inner Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		Inner Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		Inner Join OPRC T5 ON T5."PrcCode" = T0."OcrCode"
		Where T0."LineTotal" <> 0 AND T0."DocEntry" = :datakey;
			
	Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
	
	for currloop as looppr do
		if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
			Select COunt(*) INto CountRec
			FROM "@NDBS_BGC_BDPL" T0
			WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Department" = currloop."OcrCode";
			IF :CountRec = 0 then
				error = 36;
				error_message = 'No Budget Setup for Department ';-- + TO_NVARCHAR(currloop."OcrCode"); + CONCAT(' And Group ',TO_NVARCHAR(currloop."Code"));
			else
				if(:transaction_type in ('U','C','L')) then
					SELECT TOP 1  IFNULL(-"Amount",0),"Department","BudgetGroup","BudgetYear" 
					into BAvailable,OldDept,OldGroup,OldYear
					FROM "NDBS_BGC_OBDE"
					Where "ObjectType" = '1470000113' AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum" 
					Order By "DocEntry" desc;
	
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
					VALUES
						(:AutoKey,:OldGroup,:OldYear,:OldDept,'1470000113',currloop."DocEntry",currloop."LineNum",
								'',0,0,:BAvailable,'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum");
										
					Call NDBS_UpdateBudgetAmount (:OldGroup,:OldYear,'D',:OldDept);
	
				end if;
				if(:transaction_type in ('U','A')) then
				    Select COUNT(T0."U_BudgetRem") into BAvailable
					FROM "@NDBS_BGC_BDPL" T0
					WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Department" = currloop."OcrCode";
				    if :BAvailable <> 0 then
						Select TOP 1 IFNULL(T0."U_BudgetRem",0) into BAvailable
						FROM "@NDBS_BGC_BDPL" T0
						WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Department" = currloop."OcrCode";
					end if;
	
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
					VALUES
						(:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."OcrCode",'1470000113',currloop."DocEntry",currloop."LineNum",
							'',0,0,currloop."LineTotal",'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum");
	
					Call NDBS_UpdateBudgetAmount(currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),'D',currloop."OcrCode");	
				end if;
			end if;
		elseif (currloop."Project" <> '') then
			Select COunt(*) INto CountRec
			FROM "@NDBS_BGC_BPJL" T0
						WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Project" = currloop."Project";
			IF :CountRec = 0 then
				error = 36;
				error_message = 'No Budget Setup for Project ';-- + currloop."Project" + ' And Group ' + currloop."Code";
			else
				Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
				if(:transaction_type in ('U','C','L')) then
					SELECT TOP 1  IFNULL(-"Amount",0),"Project","BudgetGroup","BudgetYear" 
					into BAvailable,OldDept,OldGroup,OldYear
					FROM "NDBS_BGC_OBPE"
					Where "ObjectType" = '1470000113' AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum" 
					Order By "DocEntry" desc;
	
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
						"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
					VALUES
						(:AutoKey,:OldGroup,:OldYear,:OldDept,'1470000113',currloop."DocEntry",currloop."LineNum",
								'',0,0,:BAvailable,'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum");
										
					Call NDBS_UpdateBudgetAmount (:OldGroup,:OldYear,'P',:OldDept);
	
				end if;
				if(:transaction_type in ('U','A')) then
				    Select COUNT(T0."U_BudgetRem") into BAvailable
					FROM "@NDBS_BGC_BPJL" T0
					WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Project" = currloop."Project";
				    if :BAvailable <> 0 then
						Select TOP 1 IFNULL(T0."U_BudgetRem",0) into BAvailable
						FROM "@NDBS_BGC_BPJL" T0
						WHERE T0."Code" = TO_NVARCHAR(currloop."U_NDBS_BudgetYear") AND T0."U_GroupCode" = currloop."Code" AND T0."U_Project" = currloop."Project";
					end if;
	
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
					"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
					VALUES
						(:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."Project",'1470000113',currloop."DocEntry",currloop."LineNum",
							'',0,0,currloop."LineTotal",'R',currloop."DocDate",'I','1470000113',currloop."DocEntry",currloop."LineNum");
	
					Call NDBS_UpdateBudgetAmount(currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),'P',currloop."Project");	
				end if;
			end if;
		end if;
	end for;
end;
