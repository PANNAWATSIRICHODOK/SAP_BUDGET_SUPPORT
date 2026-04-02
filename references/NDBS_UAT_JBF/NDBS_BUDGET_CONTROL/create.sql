CREATE PROCEDURE NDBS_BUDGET_CONTROL
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

	if ( :object_type = '1470000113') then
		Call NDBS_BUDGET_PR (:object_type,:transaction_type,:datakey,:error,:error_message);
	elseif ( :object_type = '22') then
		Call NDBS_BUDGET_PO (:object_type,:transaction_type,:datakey,:error,:error_message);	
	elseif ( :object_type = '20') then
		Call NDBS_BUDGET_GRPO (:object_type,:transaction_type,:datakey,:error,:error_message);
	elseif ( :object_type = '18') then
		Call NDBS_BUDGET_AP (:object_type,:transaction_type,:datakey,:error,:error_message);
	elseif ( :object_type = '21') then
		Call NDBS_BUDGET_RETURN (:object_type,:transaction_type,:datakey,:error,:error_message);
	elseif ( :object_type = '19') then
		Call NDBS_BUDGET_APCN (:object_type,:transaction_type,:datakey,:error,:error_message);
	elseif ( :object_type = '19') then
		Call NDBS_BUDGET_JE (:object_type,:transaction_type,:datakey,:error,:error_message);
	end if;
	

	if (error = 0) then
		DELETE FROM NDBS_BGC_OBPE WHERE "Amount"=0;
		DELETE FROM NDBS_BGC_OBDE WHERE "Amount"=0;
		call NDBS_UpdateAllBudgetAmount;
	end if;
end;