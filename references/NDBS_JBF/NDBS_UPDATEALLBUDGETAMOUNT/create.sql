CREATE PROCEDURE SBO_JBF.NDBS_UpdateAllBudgetAmount
LANGUAGE SQLSCRIPT
AS
BEGIN
    --[2026-03-27 PERF FIX] Set-based rewrite replaces row-by-row cursor loop
    --Previous: 1003 rows x 3 SQL x full-scan 54225 rows = 60-180s runtime
    --New: 2 bulk UPDATEs using indexed subqueries = sub-second runtime
    --Indexes added: IDX_OBDE_BUDGET_QUERY, IDX_BDPL_UPDATE, IDX_OBPE_BUDGET_QUERY

    UPDATE SBO_JBF."@NDBS_BGC_BDPL" T SET
        T."U_BudgetRes" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetType" = 'R' AND D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBDE" D
            WHERE D."Department" = T."U_Department"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."Code"
        ), 0),
        T."U_BudgetAct" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetType" = 'A' AND D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBDE" D
            WHERE D."Department" = T."U_Department"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."Code"
        ), 0),
        T."U_BudgetBal" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBDE" D
            WHERE D."Department" = T."U_Department"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."Code"
        ), 0),
        T."U_BudgetRem" = IFNULL(T."U_BudgetAmt", 0) - IFNULL((
            SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBDE" D
            WHERE D."Department" = T."U_Department"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."Code"
        ), 0);

    UPDATE SBO_JBF."@NDBS_BGC_BPJL" T SET
        T."U_BudgetRes" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetType" = 'R' AND D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBPE" D
            WHERE D."Project"     = T."U_Project"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."U_Project"
        ), 0),
        T."U_BudgetAct" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetType" = 'A' AND D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBPE" D
            WHERE D."Project"     = T."U_Project"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."U_Project"
        ), 0),
        T."U_BudgetBal" = IFNULL((
            SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBPE" D
            WHERE D."Project"     = T."U_Project"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."U_Project"
        ), 0),
        T."U_BudgetRem" = IFNULL(T."U_BudgetAmt", 0) - IFNULL((
            SELECT SUM(CASE WHEN D."BudgetStatus" <> 'C'
                            THEN IFNULL(D."Amount", 0) ELSE 0 END)
            FROM SBO_JBF."NDBS_BGC_OBPE" D
            WHERE D."Project"     = T."U_Project"
              AND D."BudgetGroup" = T."U_GroupCode"
              AND D."BudgetYear"  = T."U_Project"
        ), 0);
END