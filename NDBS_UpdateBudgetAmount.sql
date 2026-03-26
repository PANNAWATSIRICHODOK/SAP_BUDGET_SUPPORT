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
	Declare cursor loopbudgetdept for Select * From "@NDBS_BGC_BDPL" Where "U_BudgetRem" IS NULL;
	Declare cursor loopbudgetproj  for Select * From "@NDBS_BGC_BPJL" Where "U_BudgetRem" IS NULL;
	If :budgettype = 'D' Then 
		Select SUM(IFNULL("Amount",0)) INTO NetReserve
		From "NDBS_BGC_OBDE"
		WHERE "Department" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear 
		AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';
		
		Select SUM(IFNULL("Amount",0)) INTO NetActual
		From "NDBS_BGC_OBDE"
		WHERE "Department" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear 
		AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';
		IF NetActual IS NULL Then
			NetActual = 0;
		End if;
		IF NetReserve IS NULL Then
			NetReserve = 0;
		End if;
		Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
				"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
				"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = :budgetyear AND "U_GroupCode" = :budgetgroup AND "U_Department" = :budgettypecode;
	else
		Select SUM(IFNULL("Amount",0)) INTO NetReserve
		From "NDBS_BGC_OBPE"
		WHERE "Project" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear 
		AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';
		
		Select SUM(IFNULL("Amount",0)) INTO NetActual
		From "NDBS_BGC_OBPE"
		WHERE "Project" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear 
		AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';
		IF NetActual IS NULL Then
			NetActual = 0;
		End if;
		IF NetReserve IS NULL Then
			NetReserve = 0;
		End if;
		Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
				"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
				"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = :budgetyear AND "U_GroupCode" = :budgetgroup AND "U_Project" = :budgettypecode;
	end if;
	
	for currloop as loopbudgetdept do
		Select SUM(IFNULL("Amount",0)) INTO NetReserve
		From "NDBS_BGC_OBDE"
		WHERE "Department" = currloop."U_Department" AND "BudgetGroup" = currloop."U_GroupCode" 
		AND "BudgetYear" = currloop."Code" 
		AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';
		
		Select SUM(IFNULL("Amount",0)) INTO NetActual
		From "NDBS_BGC_OBDE"
		WHERE "Department" = currloop."U_Department" AND "BudgetGroup" = currloop."U_GroupCode" 
		AND "BudgetYear" = currloop."Code" 
		AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';
		IF NetActual IS NULL Then
			NetActual = 0;
		End if;
		IF NetReserve IS NULL Then
			NetReserve = 0;
		End if;
		
		Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
				"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
				"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = currloop."Code"  AND "U_GroupCode" = currloop."U_GroupCode"  AND "U_Department" = currloop."U_Department";
	end for;
	for currloop as loopbudgetproj do
		Select SUM(IFNULL("Amount",0)) INTO NetReserve
		From "NDBS_BGC_OBPE"
		WHERE "Project" = currloop."U_Project" AND "BudgetGroup" = currloop."U_GroupCode" 
		AND "BudgetYear" = currloop."U_Project" 
		AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';
		
		Select SUM(IFNULL("Amount",0)) INTO NetActual
		From "NDBS_BGC_OBPE"
		WHERE "Project" = currloop."U_Project" AND "BudgetGroup" = currloop."U_GroupCode" 
		AND "BudgetYear" = currloop."U_Project" 
		AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';
		IF NetActual IS NULL Then
			NetActual = 0;
		End if;
		IF NetReserve IS NULL Then
			NetReserve = 0;
		End if;
		Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
				"U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
				"U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
		WHERE "Code" = currloop."Code" AND "U_GroupCode" = currloop."U_GroupCode" AND "U_Project" = currloop."U_Project";	
	end for;
end;