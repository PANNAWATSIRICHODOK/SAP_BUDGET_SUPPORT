CREATE PROCEDURE NDBS_UpdateBudgetAmount
(
	in budgetgroup nvarchar(50),
	in budgetyear nvarchar(50),
	in budgettype nvarchar(50),
	in budgettypecode nvarchar(50)
)
LANGUAGE SQLSCRIPT
AS
begin

	Declare NetReserve DECIMAL(19, 2);
	Declare NetActual DECIMAL(19, 2);

	If :budgettype = 'D' Then
		Select
			IFNULL(SUM(CASE WHEN "BudgetType" = 'R' THEN IFNULL("Amount",0) ELSE 0 END),0),
			IFNULL(SUM(CASE WHEN "BudgetType" = 'A' THEN IFNULL("Amount",0) ELSE 0 END),0)
		INTO NetReserve, NetActual
		From "NDBS_BGC_OBDE"
		WHERE "Department" = :budgettypecode
		  AND "BudgetGroup" = :budgetgroup
		  AND "BudgetYear" = :budgetyear
		  AND "BudgetStatus" <> 'C';

		Update "@NDBS_BGC_BDPL" Set
			"U_BudgetRes" = IFNULL(:NetReserve,0),
			"U_BudgetAct" = IFNULL(:NetActual,0),
			"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
			"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = :budgetyear
		  AND "U_GroupCode" = :budgetgroup
		  AND "U_Department" = :budgettypecode;
	else
		Select
			IFNULL(SUM(CASE WHEN "BudgetType" = 'R' THEN IFNULL("Amount",0) ELSE 0 END),0),
			IFNULL(SUM(CASE WHEN "BudgetType" = 'A' THEN IFNULL("Amount",0) ELSE 0 END),0)
		INTO NetReserve, NetActual
		From "NDBS_BGC_OBPE"
		WHERE "Project" = :budgettypecode
		  AND "BudgetGroup" = :budgetgroup
		  AND "BudgetYear" = :budgetyear
		  AND "BudgetStatus" <> 'C';

		Update "@NDBS_BGC_BPJL" Set
			"U_BudgetRes" = IFNULL(:NetReserve,0),
			"U_BudgetAct" = IFNULL(:NetActual,0),
			"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
			"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = :budgetyear
		  AND "U_GroupCode" = :budgetgroup
		  AND "U_Project" = :budgettypecode;
	end if;

	-- Repair budget rows with null remaining amount in bulk instead of row-by-row cursor loops.
	UPDATE "@NDBS_BGC_BDPL" T SET
		T."U_BudgetRes" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetType" = 'R' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBDE" D
			WHERE D."Department" = T."U_Department"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
			  AND D."BudgetStatus" <> 'C'
		),0),
		T."U_BudgetAct" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetType" = 'A' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBDE" D
			WHERE D."Department" = T."U_Department"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
			  AND D."BudgetStatus" <> 'C'
		),0),
		T."U_BudgetBal" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBDE" D
			WHERE D."Department" = T."U_Department"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
		),0),
		T."U_BudgetRem" = IFNULL(T."U_BudgetAmt",0) - IFNULL((
			SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBDE" D
			WHERE D."Department" = T."U_Department"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
		),0)
	WHERE T."U_BudgetRem" IS NULL;

	UPDATE "@NDBS_BGC_BPJL" T SET
		T."U_BudgetRes" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetType" = 'R' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBPE" D
			WHERE D."Project" = T."U_Project"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
			  AND D."BudgetStatus" <> 'C'
		),0),
		T."U_BudgetAct" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetType" = 'A' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBPE" D
			WHERE D."Project" = T."U_Project"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
			  AND D."BudgetStatus" <> 'C'
		),0),
		T."U_BudgetBal" = IFNULL((
			SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBPE" D
			WHERE D."Project" = T."U_Project"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
		),0),
		T."U_BudgetRem" = IFNULL(T."U_BudgetAmt",0) - IFNULL((
			SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C' THEN IFNULL(D."Amount",0) ELSE 0 END)
			FROM "NDBS_BGC_OBPE" D
			WHERE D."Project" = T."U_Project"
			  AND D."BudgetGroup" = T."U_GroupCode"
			  AND D."BudgetYear" = T."Code"
		),0)
	WHERE T."U_BudgetRem" IS NULL;
end;
