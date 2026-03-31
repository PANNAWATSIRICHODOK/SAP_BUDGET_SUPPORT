CREATE PROCEDURE NDBS_UpdateAllBudgetAmount
LANGUAGE SQLSCRIPT
AS
begin
	
	Declare NetReserve DECIMAL(19, 2);
	Declare NetActual DECIMAL(19, 2);
	Declare cursor loopbudgetdept for Select * From "@NDBS_BGC_BDPL";
	Declare cursor loopbudgetproj  for Select * From "@NDBS_BGC_BPJL";
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