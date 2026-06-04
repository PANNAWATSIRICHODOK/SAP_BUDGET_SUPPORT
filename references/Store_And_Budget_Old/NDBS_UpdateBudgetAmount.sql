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

end;
