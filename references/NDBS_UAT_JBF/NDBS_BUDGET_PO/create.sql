CREATE PROCEDURE NDBS_BUDGET_PO
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
	
	
	-- Loop Close PO
	Declare cursor looppolineclose for
		Select T0."DocStatus",T1."DocEntry",T1."LineNum",T1."LineStatus",T1."Project",T4."Code",T1."U_NDBS_BudgetYear",T1."OcrCode"
		from OPOR T0 Inner Join POR1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join OACT T2 ON T1."AcctCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		Where T1."DocEntry" = :datakey AND T1."LineStatus" = 'C';
		
	Declare cursor looppodocclose for
		Select T0."DocStatus",T1."DocEntry",T1."LineNum",T1."LineStatus",T1."Project",T4."Code",T1."U_NDBS_BudgetYear",T1."OcrCode"
		from OPOR T0 Inner Join POR1 T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join OACT T2 ON T1."AcctCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		Where T0."DocEntry" = :datakey AND T0."DocStatus" = 'C';
		
	Declare cursor looppo for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."LineTotal" ELSE T0."LineTotal"-ROUND((T0."LineTotal"/S."LineTotal")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T4."U_Center" = 'Y' THEN T4."U_Department" 
				When T4."U_UseGroupCode" = 'N' THEN T5."PrcCode"
				ELSE T5."U_NDBS_BudgetDept" END "OcrCode"
		FROM POR1 T0 Inner Join OPOR T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		LEFT Join OPRC T5 ON T5."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."LineTotal") AS "LineTotal" from POR1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		Where T0."LineTotal" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey;
		
	

	Declare cursor looppoclose for
		SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" AS "DocDept", T0."Project"
		, CASE WHEN T1."DiscSum" = 0 THEN T0."OpenSum" ELSE T0."OpenSum"-ROUND((T0."OpenSum"/S."OpenSum")*T1."DiscSum",2) END AS "LineTotal"
		,T1."DocEntry",T0."LineNum",
				T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
				Case When T4."U_Center" = 'Y' THEN T4."U_Department" 
				When T4."U_UseGroupCode" = 'N' THEN T5."PrcCode"
				ELSE T5."U_NDBS_BudgetDept" END "OcrCode"
		FROM POR1 T0 Inner Join OPOR T1 ON T0."DocEntry" = T1."DocEntry"
		INNER Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
		INNER Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
		LEFT Join OPRC T5 ON T5."PrcCode" = T0."OcrCode"
		--- 24 Oct 2025 ---
		LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
		left join 
		( select T0."DocEntry",SUM(T0."OpenSum") AS "OpenSum" from POR1 T0 group by  T0."DocEntry")S ON T0."DocEntry" =S."DocEntry"
		Where T0."OpenSum" <> 0 AND IFNULL(I1."InvntItem",'N') <> 'Y' AND T0."DocEntry" = :datakey and T0."LineStatus" ='O';
		

		if(:transaction_type IN ('A','U','C')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			for currloop as looppo do
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
					if(:transaction_type in ('U','C')) then
						Select Count(*) Into BCOunt
						FROM "NDBS_BGC_OBDE" T0
						left join POR1 T1 ON T0."PrimaryObjectID"= T1."DocEntry" and T0."PrimaryObjectLine" = T1."LineNum"
						Where "ObjectType" = '22' AND T0."ObjectID" = :DocKey  AND T0."ObjectLine" = :DocLine 
						AND T0."PrimaryObjectType" = '22' AND T0."PrimaryObjectID" = :DocKey AND T0."PrimaryObjectLine" = :DocLine;
						
						IF  BCount <> 0 then
							SELECT TOP 1  IFNULL(-T0."Amount",0),T0."Department",T0."BudgetGroup",T0."BudgetYear" into BAvailable,OldDept,OldGroup,OldYear
							FROM "NDBS_BGC_OBDE" T0
							left join POR1 T1 ON T0."PrimaryObjectID"= T1."DocEntry" and T0."PrimaryObjectLine" = T1."LineNum"
							--- 24 Oct 2025 ---
							LEFT Join OITM I1 ON T1."ItemCode"=I1."ItemCode"
							Where "ObjectType" = '22' AND T0."ObjectID" = :DocKey  AND T0."ObjectLine" = :DocLine 
							AND T0."PrimaryObjectType" = '22' AND T0."PrimaryObjectID" = :DocKey AND T0."PrimaryObjectLine" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y'
							
							Order By T0."DocEntry" desc;
		
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBDE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
									"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
							VALUES
								(:AutoKey,:OldGroup,:OldYear,:OldDept,'22',:DocKey,:DocLine,
										'',0,0,:BAvailable,'R',:BValDate,'I','22',:DocKey,:DocLine);
										
							--Call NDBS_UpdateBudgetAmount(:OldGroup,:OldYear,'D',:OldDept);
						end if;
					end if;
					
					if(:transaction_type in ('U','A')) then
						Select COUNT(*) into BCOunt
						FROM "@NDBS_BGC_BDPL" T0
						WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Department" = :BDept;
						IF BCount <> 0 Then
							Select TOP 1 IFNULL(T0."U_BudgetRem",0) into BAvailable
							FROM "@NDBS_BGC_BDPL" T0
							WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Department" = :BDept;
						
							Select TOP 1 (T0."LineTotal"-ifnull(T1."LineTotal",0)), ifnull(T1."LineTotal",0),T0."LineTotal" into BDiffAmount, BaseAmount,LineAmount
							FROM POR1 T0 left JOin PRQ1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
							--- 24 Oct 2025 ---
							LEFT Join OITM I1 ON T0."ItemCode"=I1."ItemCode"
							WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine AND IFNULL(I1."InvntItem",'N') <> 'Y';
							
							IF ((:BAvailable+:BaseAmount) >= :LineAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
								AutoKey = :AutoKey+1;
								INSERT INTO "NDBS_BGC_OBDE"
								("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
								"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
									"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
								VALUES
									(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
										:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);
								
								--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);	
		
							else
								error = -32;
								error_message = CONCAT(CONCAT('Department ',:BDept),'Over budget');
							end if;
							
						
						end if;
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
					if (:BProject <> '') then
						if(:transaction_type in ('U','C')) then
							Select Count(*) Into BCOunt
							FROM "NDBS_BGC_OBPE"
							Where "ObjectType" = '22' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
							AND "PrimaryObjectType" = '22' AND "PrimaryObjectID" = :DocKey AND "PrimaryObjectLine" = :DocLine;
							
							IF  BCount <> 0 then
								SELECT TOP 1  IFNULL(-"Amount",0),"Project","BudgetGroup","BudgetYear" into BAvailable,OldProject,OldGroup,OldYear
								FROM "NDBS_BGC_OBPE"
								Where "ObjectType" = '22' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
								AND "PrimaryObjectType" = '22' AND "PrimaryObjectID" = :DocKey AND "PrimaryObjectLine" = :DocLine
								Order By "DocEntry" desc;
			
								AutoKey = :AutoKey+1;
								INSERT INTO "NDBS_BGC_OBPE"
								("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
								"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
									"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
								VALUES
									(:AutoKey,:OldGroup,:OldYear,:OldProject,'22',:DocKey,:DocLine,
											'',0,0,:BAvailable,'R',:BValDate,'I','22',:DocKey,:DocLine);
			
								--Call NDBS_UpdateBudgetAmount(:OldGroup,:OldYear,'P',:OldProject);
							end if;
						end if;
						if(:transaction_type in ('U','A')) then
						
							Select TOP 1 T0."U_BudgetRem" into BAvailable
							FROM "@NDBS_BGC_BPJL" T0
							WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Project" = :BProject ;
							
							Select TOP 1 (T0."LineTotal"-ifnull(T1."LineTotal",0)), ifnull(T1."LineTotal",0),T0."LineTotal" into BDiffAmount, BaseAmount,LineAmount
							FROM POR1 T0 left JOin PRQ1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
							WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
							
							IF :BaseType IN ('-1','1470000113') then
								IF (:BAvailable >= :LineAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
									if(:transaction_type IN ('A','U')) then
										AutoKey = :AutoKey+1;
										INSERT INTO "NDBS_BGC_OBPE"
										("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
										"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
										"PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
										VALUES
											(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,
												:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I',
												'22',:DocKey,:DocLine);
												
										--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
									end if;
								else
									error = -32;
									error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget') ;
								end if;	
							
							end if;
						end if;
					end if;
				end if;	
			end for;
		elseif (:transaction_type IN ('L')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
				
				for currloop as looppoclose do
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
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);
								
						--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
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
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);
								
						--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);	
					end if;
				end for;
			
			
		end if;
			
	for currloop as looppodocclose do
		BYear = currloop."U_NDBS_BudgetYear";
		BDept = currloop."OcrCode";
		BProject = currloop."Project";
		BCode = currloop."Code";
		if (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			--AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"Amount","BudgetType","ValueDate","BudgetStatus")
			select (ROW_NUMBER() OVER (ORDER BY "BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate"))+AutoKey,
				"BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
				-SUM("Amount"),"BudgetType","ValueDate",'A'
			From NDBS_BGC_OBPE
			Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A') AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum"
			Group By "BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate";
					
			--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		else 
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			--AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				"Amount","BudgetType","ValueDate","BudgetStatus")
			select (ROW_NUMBER() OVER (ORDER BY "BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate"))+AutoKey,
				"BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				-SUM("Amount"),"BudgetType","ValueDate",'A'
			From NDBS_BGC_OBDE
			Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A') AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum"
			Group By "BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate";
					
			--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		end if;
	end for;
	
	for currloop as looppolineclose do
		BYear = currloop."U_NDBS_BudgetYear";
		BDept = currloop."OcrCode";
		BProject = currloop."Project";
		BCode = currloop."Code";
		if (currloop."Project" <> '') then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			--AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBPE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
			"Amount","BudgetType","ValueDate","BudgetStatus")
			select (ROW_NUMBER() OVER (ORDER BY "BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate"))+AutoKey,
				"BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
				-SUM("Amount"),"BudgetType","ValueDate",'A'
			From NDBS_BGC_OBPE
			Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A') AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum"
			Group By "BudgetGroup","BudgetYear","Project","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate";
					
			--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
		else 
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			--AutoKey = :AutoKey+1;
			INSERT INTO "NDBS_BGC_OBDE"
			("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				"Amount","BudgetType","ValueDate","BudgetStatus")
			select (ROW_NUMBER() OVER (ORDER BY "BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate"))+AutoKey,
				"BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				-SUM("Amount"),"BudgetType","ValueDate",'A'
			From NDBS_BGC_OBDE
			Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A') AND "ObjectID" = currloop."DocEntry" AND "ObjectLine" = currloop."LineNum"
			Group By "BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine","BudgetType","ValueDate";
					
			--Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
		end if;
	end for;


end;