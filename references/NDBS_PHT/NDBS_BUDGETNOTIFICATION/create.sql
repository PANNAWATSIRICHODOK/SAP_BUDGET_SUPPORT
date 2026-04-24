CREATE PROCEDURE NDBS_BudgetNotification
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
	--out RET_ERR table (ERROR_OUT INT,ERROR_OUT_MSG nvarchar(200))
)
LANGUAGE SQLSCRIPT
AS
begin
-- Budget Control
declare error  int;				-- Result (0 for no error)
declare error_message nvarchar (200); 		-- Error string to be displayed
declare LineNum INTEGER DEFAULT 0;
Declare AutoKey Integer = 0;
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

Declare cursor looppr  for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",
			Case When T4."U_Center" = 'Y' THEN T4."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM PRQ1 T0 Inner Join OPRQ T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
Declare cursor looppo for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T4."Code",T4."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T4."U_Center" = 'Y' THEN T4."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM POR1 T0 Inner Join OPOR T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join OACT T2 ON T0."AcctCode" = T2."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T3 ON T3."U_AccountCode" = T2."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
Declare cursor loopgrn for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T5."U_Center" = 'Y' THEN T5."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM PDN1 T0 Inner Join OPDN T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join POR1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
	Inner Join OACT T3 ON T2."AcctCode" = T3."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
		
Declare cursor loopinv1 for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
	--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
	Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
	Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

Declare cursor loopinv2 for
	SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
Declare cursor loopreturn for
SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T5."U_Center" = 'Y' THEN T5."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM RPD1 T0 Inner Join ORPD T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join OACT T3 ON T0."AcctCode" = T3."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
Declare cursor loopcn1 for
SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
	Inner Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

Declare cursor loopcn2 for
SELECT T1."DocDate",T0."U_NDBS_BudgetYear",T0."OcrCode" "DocDept", T0."Project", T0."LineTotal",T1."DocEntry",T0."LineNum",
			T6."Code",T6."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."BaseType",T0."BaseEntry",T0."BaseLine",
			Case When T6."U_Center" = 'Y' THEN T6."U_Department" ELSE T0."OcrCode" END "OcrCode"
	FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
	Inner Join OACT T4 ON T0."AcctCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
	Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;
	
Declare cursor loopje for
	SELECT T0."RefDate",T0."U_NDBS_BudgetYear",T0."ProfitCode" "DocDept", T0."Project", (T0."Debit"-T0."Credit") "Amt",T0."TransId",T0."Line_ID",
			T5."Code",T5."U_Locked",T0."U_NDBS_NotCheckBudget",T0."U_NDBS_BudgetReason",T0."TransType" "BaseType",0 "BaseEntry",0 "BaseLine",
			Case When T5."U_Center" = 'Y' THEN T5."U_Department" ELSE T0."ProfitCode" END "ProfitCode"
	FROM JDT1 T0 
	Inner Join OACT T3 ON T0."Account" = T3."AcctCode"
	Inner Join "@NDBS_BGC_BGPL" T4 ON T4."U_AccountCode" = T3."AcctCode"
	Inner Join "@NDBS_BGC_OBGP" T5 ON T4."Code" = T5."Code"
	Where (T0."Debit"-T0."Credit") <> 0 AND T0."TransType" = '30' AND T0."DocEntry" = :list_of_cols_val_tab_del;	
						
-- Budget Contrrol
IF ( :object_type in ('1470000113','22','20','21','19','18') AND   (:transaction_type IN ('A') OR :transaction_type IN ('U')))
THEN
	IF ( :object_type = '1470000113') then
	    SELECT IFNULL(COUNT(LineNum),0) Into LineNum
	    FROM  OPRQ a inner join PRQ1 b on a."DocEntry" = b."DocEntry"
	                        WHERE (B."OcrCode" = '' or B."OcrCode" is null)
							and A."DocEntry" = :list_of_cols_val_tab_del; 
	 
	    IF :LineNum > 0 Then
			error = -2;
	        error_message = 'Please define CostCenter '+ :LineNum +'. ';
		end if;
	
		SELECT IFNULL(COUNT(LineNum),0) into LineNum
	    FROM  OPRQ a inner join PRQ1 b on a."DocEntry" = b."DocEntry"
	                        WHERE ((B."U_NDBS_BudgetYear" = 0) OR (B."U_NDBS_BudgetYear" IS NULL))
							and A."DocEntry" = :list_of_cols_val_tab_del;
	 
	    IF (:LineNum > 0) then
			error = -2;
	        error_message = 'Please define Budget Year '+ :LineNum +'. ';
		end if;
	end if;
	IF ( :object_type = '22') then
		SELECT IFNULL(COUNT(LineNum),0) Into LineNum
	    FROM  OPOR a inner join POR1 b on a."DocEntry" = b."DocEntry"
	                        WHERE (B."OcrCode" = '' or B."OcrCode" is null)
							and A."DocEntry" = :list_of_cols_val_tab_del; 
	 
	    IF :LineNum > 0 Then
			error = -2;
	        error_message = 'Please define CostCenter and Project '+ :LineNum +'. ';
		end if;
	
		SELECT IFNULL(COUNT(LineNum),0) into LineNum
	    FROM  OPOR a inner join POR1 b on a."DocEntry" = b."DocEntry"
	                        WHERE ((B."U_NDBS_BudgetYear" = 0) OR (B."U_NDBS_BudgetYear" IS NULL))
							and A."DocEntry" = :list_of_cols_val_tab_del;
	 
	    IF (:LineNum > 0) then
			error = -2;
	        error_message = 'Please define Budget Year '+ :LineNum +'. ';
		end if;
	end if;
END IF;
if :error = 0 then
IF ( :object_type in ('1470000113','30','22','21','20','18','19') AND :transaction_type IN ('A','U','C','L')) then
	-- Department
	if ( :object_type = '1470000113') then
		if(:transaction_type in ('A','U','C')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			for currloop as looppr do
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
				DocDept = currloop."DocDept";
				if ((BProject IS NULL)OR(BProject = '')) then
					if(:transaction_type in ('U','C')) then
						SELECT TOP 1  IFNULL(-"Amount",0),"Department","BudgetGroup","BudgetYear" into BAvailable,OldDept,OldGroup,OldYear
						FROM "NDBS_BGC_OBDE"
						Where "ObjectType" = '1470000113' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
						Order By "DocEntry" desc;
	
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
						VALUES
							(:AutoKey,:OldGroup,:OldYear,:OldDept,'1470000113',:DocKey,:DocLine,
									'',0,0,:BAvailable,'R',:BValDate,'I');
	
						Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = "U_BudgetRes" + :BAvailable, "U_BudgetBal" = "U_BudgetBal" + :BAvailable,
									"U_BudgetRem" = "U_BudgetRem" - :BAvailable
							WHERE "Code" = :OldYear AND "U_GroupCode" = :OldGroup AND "U_Department" = :OldDept;
	
					end if;
					if(:transaction_type <> 'C') then
					    Select COUNT(T0."U_BudgetRem") into BAvailable
						FROM "@NDBS_BGC_BDPL" T0
						WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Department" = :BDept;
					    if :BAvailable <> 0 then
							Select TOP 1 IFNULL(T0."U_BudgetRem",0) into BAvailable
							FROM "@NDBS_BGC_BDPL" T0
							WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Department" = :BDept;
						end if;
						IF (:BAvailable >= :BAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBDE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'1470000113',:DocKey,:DocLine,
									'',0,0,:BAmount,'R',:BValDate,'I');
							Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = "U_BudgetRes" + :BAmount, "U_BudgetBal" = "U_BudgetBal" + :BAmount,
									"U_BudgetRem" = "U_BudgetRem" - :BAmount
							WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
						else
							error = -22;
							--error_message = 'Department '+ :BDept+' Line No. '+CAST(:DocLine AS VARCHAR) +' Budget Available '+
							--	CAST(:BAvailable AS VARCHAR)+ ' less than Item Amount ' +CAST(:BAmount AS VARCHAR);
							error_message = 'Not have budget ';
						end if;
					end if;	
				end if;
			end for;
		end if;
	elseif ( :object_type = '22') then
		if(:transaction_type IN ('A','U','C')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			for currloop as looppo do
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
					SELECT TOP 1  IFNULL(-"Amount",0),"Department","BudgetGroup","BudgetYear" into BAvailable,OldDept,OldGroup,OldYear
					FROM "NDBS_BGC_OBDE"
					Where "ObjectType" = '22' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
					Order By "DocEntry" desc;

					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:OldGroup,:OldYear,:OldDept,'22',:DocKey,:DocLine,
								'',0,0,:BAvailable,'R',:BValDate,'I');

					Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = "U_BudgetRes" + :BAvailable, "U_BudgetBal" = "U_BudgetBal" + :BAvailable,
								"U_BudgetRem" = "U_BudgetRem" - :BAvailable
						WHERE "Code" = :OldYear AND "U_GroupCode" = :OldGroup AND "U_Department" = :OldDept;

				end if;
				if(:transaction_type <> 'C') then
					--Select TOP 1 T0."U_BudgetRem" into BAvailable
					--FROM "@NDBS_BGC_BDPL" T0
					--WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Department" = :BDept;
	
					Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
					FROM POR1 T0 Inner JOin PRQ1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
					WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
	
					--IF (:BAvailable >= :BDiffAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
						if(:transaction_type = 'A') then
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBDE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,:BaseType,:BaseKey,:BaseLine,
									'22',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A');
						end if;
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBDE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
						VALUES
							(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
								:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I');
								
						Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = "U_BudgetRes" + :BDiffAmount, "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
								"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
						WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
					--else
					--	error = -22;
					--	error_message = 'Department '+ :BDept+' Line No. '+TO_NVARCHAR(:DocLine) +' Budget Available '+
					--		TO_NVARCHAR(:BAvailable)+ ' less than Item Amount ' +TO_NVARCHAR(:BAmount);
					--end if;
				end if;	
			end for;
		end if;
	elseif ( :object_type = '20') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			for currloop as loopgrn do
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
				
				Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
				FROM PDN1 T0 Inner JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
				WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
				AutoKey = :AutoKey+1;
				
				INSERT INTO "NDBS_BGC_OBDE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,:BaseType,:BaseKey,:BaseLine,
						'20',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A');
				AutoKey = :AutoKey+1;
				INSERT INTO "NDBS_BGC_OBDE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'20',:DocKey,:DocLine,
						:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I');
						
				Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = "U_BudgetRes" - :BAmount, "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
						"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
			end for;
		end if;
	elseif ( :object_type = '18') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
			--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
			Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

			IF :Bcount > 0 then
				for currloop as loopinv1 do
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
					
					Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
					FROM PCH1 T0 Inner JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
					WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
					AutoKey = :AutoKey+1;
				
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,:BaseType,:BaseKey,:BaseLine,
							'18',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A');
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
							"U_BudgetAct" = "U_BudgetAct"+:BDiffAmount,"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
				end for;
			else
				for currloop as loopinv2 do
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
					AutoKey = :AutoKey+1;
					
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'18',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" + :BAmount,
							"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
				end for;
			end if;
		end if;
	elseif ( :object_type = '21') then
		if(:transaction_type IN ('A')) then
			for currloop as loopreturn do
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
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'21',:DocKey,:DocLine,
						:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
						
				Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" - :BAmount,
						"U_BudgetAct" = "U_BudgetAct"-:BAmount,"U_BudgetRem" = "U_BudgetRem" + :BAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
				
			end for;
		end if;
	elseif ( :object_type = '19') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
			Inner Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

			IF :Bcount > 0 then
				for currloop as loopcn1 do
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
					
					Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
					FROM RPC1 T0 Inner JOin RPD1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
					WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
					AutoKey = :AutoKey+1;
				
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,:BaseType,:BaseKey,:BaseLine,
							'19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A');
							
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBDE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" - :BDiffAmount,
							"U_BudgetAct" = "U_BudgetAct"-:BDiffAmount,"U_BudgetRem" = "U_BudgetRem" + :BDiffAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;

				end for;
			else
				for currloop as loopcn2 do
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
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" - :BAmount,
							"U_BudgetAct" = "U_BudgetAct"-:BAmount,"U_BudgetRem" = "U_BudgetRem" + :BAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;
				end for;
			end if;
		end if;
	elseif ( :object_type = '30') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBDE";
			for currloop as loopje do
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
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,
						'',0,0,:BAmount,'A',:BValDate,'I');
						
				Update "@NDBS_BGC_BDPL" Set "U_BudgetBal" = "U_BudgetBal" + :BAmount,
						"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Department" = :BDept;

			end for;
		end if;
	end if;
	
	
	-- Project
	if ( :object_type = '1470000113') then
		if(:transaction_type in ('A','U','C')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			for currloop as looppr do
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
				if (:BProject IS NOT NULL) AND (:BProject <> '') then
					if(:transaction_type in ('U','C')) then
						SELECT TOP 1  IFNULL(-"Amount",0),"Project","BudgetGroup","BudgetYear" into BAvailable,OldDept,OldGroup,OldYear
						FROM "NDBS_BGC_OBPE"
						Where "ObjectType" = '1470000113' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
						Order By "DocEntry" desc;
	
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
						VALUES
							(:AutoKey,:OldGroup,:OldYear,:OldDept,'1470000113',:DocKey,:DocLine,
									'',0,0,:BAvailable,'R',:BValDate,'I');
	
						Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = "U_BudgetRes" + :BAvailable, "U_BudgetBal" = "U_BudgetBal" + :BAvailable,
									"U_BudgetRem" = "U_BudgetRem" - :BAvailable
							WHERE "Code" = :OldYear AND "U_GroupCode" = :OldGroup AND "U_Project" = :OldDept;
	
					end if;
					if(:transaction_type <> 'C') then
					    Select COUNT(T0."U_BudgetRem") into BAvailable
						FROM "@NDBS_BGC_BPJL" T0
						WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Project" = :BProject;
						if (:BAvailable > 0) then
							Select TOP 1 IFNULL(T0."U_BudgetRem",0) into BAvailable
							FROM "@NDBS_BGC_BPJL" T0
							WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Project" = :BProject;
						end if;
						IF (:BAvailable >= :BAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBPE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'1470000113',:DocKey,:DocLine,
									'',0,0,:BAmount,'R',:BValDate,'I');
							Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = "U_BudgetRes" + :BAmount, "U_BudgetBal" = "U_BudgetBal" + :BAmount,
									"U_BudgetRem" = "U_BudgetRem" - :BAmount
							WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
						else
							error = -22;
							--error_message = 'Project '+ :BProject+' Line No. '+TO_NVARCHAR(:DocLine) +' Budget Available '+
							--	TO_NVARCHAR(:BAvailable)+ ' less than Item Amount ' +TO_NVARCHAR(:BAmount);
							--error_message = 'Department '+ :BDept+' Line No. '+CAST(:DocLine AS VARCHAR) +' Budget Available '+
							--	CAST(:BAvailable AS VARCHAR)+ ' less than Item Amount ' +CAST(:BAmount AS VARCHAR);

							error_message = 'Not have budget';
						end if;	
					end if;
				end if;
			end for;
		end if;
	elseif ( :object_type = '22') then
		if(:transaction_type IN ('A','U','C')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			for currloop as looppo do
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
				if (:BProject IS NOT NULL) AND (:BProject <> '') then
					if(:transaction_type in ('U','C')) then
						SELECT TOP 1  IFNULL(-"Amount",0),"Project","BudgetGroup","BudgetYear" into BAvailable,OldDept,OldGroup,OldYear
						FROM "NDBS_BGC_OBPE"
						Where "ObjectType" = '22' AND "ObjectID" = :DocKey AND "ObjectLine" = :DocLine 
						Order By "DocEntry" desc;
	
						AutoKey = :AutoKey+1;
						INSERT INTO "NDBS_BGC_OBPE"
						("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
						"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
						VALUES
							(:AutoKey,:OldGroup,:OldYear,:OldDept,'22',:DocKey,:DocLine,
									'',0,0,:BAvailable,'R',:BValDate,'I');
	
						Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = "U_BudgetRes" + :BAvailable, "U_BudgetBal" = "U_BudgetBal" + :BAvailable,
									"U_BudgetRem" = "U_BudgetRem" - :BAvailable
							WHERE "Code" = :OldYear AND "U_GroupCode" = :OldGroup AND "U_Project" = :OldDept;
	
					end if;
					if(:transaction_type <> 'C') then
						Select TOP 1 T0."U_BudgetRem" into BAvailable
						FROM "@NDBS_BGC_BPJL" T0
						WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Project" = :BProject;
		
						Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
						FROM POR1 T0 Inner JOin PRQ1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
						WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
		
						--IF (:BAvailable >= :BDiffAmount) OR (:BLocked = 'N') OR  (:BNotChecked = 'Y') then
							if(:transaction_type = 'A') then
								AutoKey = :AutoKey+1;
								INSERT INTO "NDBS_BGC_OBPE"
								("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
								"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
								VALUES
									(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
										'22',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A');
							end if;
							AutoKey = :AutoKey+1;
							INSERT INTO "NDBS_BGC_OBPE"
							("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
							"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
							VALUES
								(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,
									:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I');
									
							Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = "U_BudgetRes" + :BDiffAmount, "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
									"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
							WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
						--else
						--	error = -22;
						--	error_message = 'Project '+ :BProject+' Line No. '+TO_NVARCHAR(:DocLine) +' Budget Available '+
						--		TO_NVARCHAR(:BAvailable)+ ' less than Item Amount ' +TO_NVARCHAR(:BAmount);
						--end if;	
					end if;
				end if;
			end for;
		end if;
	elseif ( :object_type = '20') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			for currloop as loopgrn do
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
				
				Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
				FROM PDN1 T0 Inner JOin POR1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
				WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
				AutoKey = :AutoKey+1;
				
				INSERT INTO "NDBS_BGC_OBPE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
						'20',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A');
				AutoKey = :AutoKey+1;
				INSERT INTO "NDBS_BGC_OBPE"
				("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'20',:DocKey,:DocLine,
						:BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I');
						
				Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = "U_BudgetRes" - :BAmount, "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
						"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
			end for;
		end if;
	elseif ( :object_type = '18') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM PCH1 T0 Inner Join OPCH T1 ON T0."DocEntry" = T1."DocEntry"
			--Inner Join PDN1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join POR1 T3 ON T3."DocEntry" = T0."BaseEntry" AND T3."LineNum" = T0."BaseLine" AND T0."BaseType" = '22'
			--Inner Join POR1 T3 ON T3."DocEntry" = T2."BaseEntry" AND T3."LineNum" = T2."BaseLine"
			Inner Join OACT T4 ON T3."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

			IF :Bcount > 0 then
				for currloop as loopinv1 do
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
					
					Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
					FROM PCH1 T0 Inner JOin PDN1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
					WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
					AutoKey = :AutoKey+1;
				
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
							'18',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A');
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" + :BDiffAmount,
							"U_BudgetAct" = "U_BudgetAct"+:BDiffAmount,"U_BudgetRem" = "U_BudgetRem" - :BDiffAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
				end for;
			else
				for currloop as loopinv2 do
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
					IF (BaseType='18') then
						BAmount = -:BAmount;
					end if;
					AutoKey = :AutoKey+1;
					
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" + :BAmount,
							"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
				end for;
			end if;
		end if;
	elseif ( :object_type = '21') then
		if(:transaction_type IN ('A')) then
			for currloop as loopreturn do
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
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'21',:DocKey,:DocLine,
						:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
						
				Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" - :BAmount,
						"U_BudgetAct" = "U_BudgetAct"-:BAmount,"U_BudgetRem" = "U_BudgetRem" + :BAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
				
			end for;
		end if;
	elseif ( :object_type = '19') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			
			SELECT IFNULL(Count(T0."LineNum"),0) into Bcount
			FROM RPC1 T0 Inner Join ORPC T1 ON T0."DocEntry" = T1."DocEntry"
			Inner Join RPD1 T2 ON T2."DocEntry" = T0."BaseEntry" AND T2."LineNum" = T0."BaseLine"
			Inner Join OACT T4 ON T2."AcctCode" = T4."AcctCode"
			Inner Join "@NDBS_BGC_BGPL" T5 ON T5."U_AccountCode" = T4."FormatCode"
			Inner Join "@NDBS_BGC_OBGP" T6 ON T5."Code" = T6."Code"
			Where T0."LineTotal" <> 0 AND T0."DocEntry" = :list_of_cols_val_tab_del;

			IF :Bcount > 0 then
				for currloop as loopcn1 do
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
					
					Select TOP 1 (T0."LineTotal"-T1."LineTotal"), T1."LineTotal" into BDiffAmount, BaseAmount
					FROM RPC1 T0 Inner JOin RPD1 T1 ON T0."BaseEntry" = T1."DocEntry" AND T0."BaseLine" = T1."LineNum"
					WHERE T0."DocEntry" = :DocKey AND T0."LineNum" = :DocLine;
				
					AutoKey = :AutoKey+1;
				
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,:BaseType,:BaseKey,:BaseLine,
							'19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A');
							
					AutoKey = :AutoKey+1;
					INSERT INTO "NDBS_BGC_OBPE"
					("DocEntry","BudgetGroup" ,"BudgetYear","Project","ObjectType","ObjectID","ObjectLine",
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" - :BDiffAmount,
							"U_BudgetAct" = "U_BudgetAct"-:BDiffAmount,"U_BudgetRem" = "U_BudgetRem" + :BDiffAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;

				end for;
			else
				for currloop as loopcn2 do
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
					"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
					VALUES
						(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
							:BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I');
							
					Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" - :BAmount,
							"U_BudgetAct" = "U_BudgetAct"-:BAmount,"U_BudgetRem" = "U_BudgetRem" + :BAmount
					WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;
				end for;
			end if;
		end if;
	elseif ( :object_type = '30') then
		if(:transaction_type IN ('A')) then
			Select IFNULL(MAX("DocEntry"),0) into AutoKey From "NDBS_BGC_OBPE";
			for currloop as loopje do
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
				"BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus")
				VALUES
					(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'30',:DocKey,:DocLine,
						'',0,0,:BAmount,'A',:BValDate,'I');
						
				Update "@NDBS_BGC_BPJL" Set "U_BudgetBal" = "U_BudgetBal" + :BAmount,
						"U_BudgetAct" = "U_BudgetAct"+:BAmount,"U_BudgetRem" = "U_BudgetRem" - :BAmount
				WHERE "Code" = TO_NVARCHAR(:BYear) AND "U_GroupCode" = :BCode AND "U_Project" = :BProject;

			end for;
		end if;
	end if;
end if;

end if;
--create local temporary table #RESULT_DATA(ERROR_OUT INTEGER,ERROR_OUT_MSG nvarchar(200));
--insert into #RESULT_DATA values(:error, :error_message);
--RET_ERR = select ERROR_OUT, ERROR_OUT_MSG FROM #RESULT_DATA;
--DROp table #RESULT_DATA;
-- Budget Contrrol
select :error, :error_message FROM dummy;
end;