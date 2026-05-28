CREATE PROCEDURE NDBS_UpdateTouchedBudgetAmount
(
	in object_type nvarchar(30),
	in datakey nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
begin

	Declare RefreshObjectType nvarchar(30);
	Declare RefreshKey nvarchar(255);

	Declare cursor loopdept for
		SELECT DISTINCT "BudgetGroup","BudgetYear","Department"
		FROM "NDBS_BGC_OBDE"
		WHERE IFNULL("BudgetGroup",'') <> ''
		  AND IFNULL("BudgetYear",'') <> ''
		  AND IFNULL("Department",'') <> ''
		  AND (
			("ObjectType" = :RefreshObjectType AND "ObjectID" = :RefreshKey)
			OR ("PrimaryObjectType" = :RefreshObjectType AND "PrimaryObjectID" = :RefreshKey)
			OR ("BaseType" = :RefreshObjectType AND "BaseID" = :RefreshKey)
		  );

	Declare cursor loopproj for
		SELECT DISTINCT "BudgetGroup","BudgetYear","Project"
		FROM "NDBS_BGC_OBPE"
		WHERE IFNULL("BudgetGroup",'') <> ''
		  AND IFNULL("BudgetYear",'') <> ''
		  AND IFNULL("Project",'') <> ''
		  AND (
			("ObjectType" = :RefreshObjectType AND "ObjectID" = :RefreshKey)
			OR ("PrimaryObjectType" = :RefreshObjectType AND "PrimaryObjectID" = :RefreshKey)
			OR ("BaseType" = :RefreshObjectType AND "BaseID" = :RefreshKey)
		  );

	RefreshObjectType = :object_type;
	RefreshKey = :datakey;

	IF :object_type = '24' THEN
		SELECT IFNULL(MAX(TO_NVARCHAR("TransId")),'') INTO RefreshKey
		FROM ORCT
		WHERE "DocEntry" = :datakey;
		RefreshObjectType = '30';
	ELSEIF :object_type = '46' THEN
		SELECT IFNULL(MAX(TO_NVARCHAR("TransId")),'') INTO RefreshKey
		FROM OVPM
		WHERE "DocEntry" = :datakey;
		RefreshObjectType = '30';
	ELSEIF :object_type = '59' THEN
		SELECT IFNULL(MAX(TO_NVARCHAR("TransId")),'') INTO RefreshKey
		FROM OIGN
		WHERE "DocEntry" = :datakey;
		RefreshObjectType = '30';
	ELSEIF :object_type = '60' THEN
		SELECT IFNULL(MAX(TO_NVARCHAR("TransId")),'') INTO RefreshKey
		FROM OIGE
		WHERE "DocEntry" = :datakey;
		RefreshObjectType = '30';
	END IF;

	IF IFNULL(:RefreshKey,'') <> '' THEN
		DELETE FROM "NDBS_BGC_OBDE"
		WHERE "Amount" = 0
		  AND (
			("ObjectType" = :RefreshObjectType AND "ObjectID" = :RefreshKey)
			OR ("PrimaryObjectType" = :RefreshObjectType AND "PrimaryObjectID" = :RefreshKey)
			OR ("BaseType" = :RefreshObjectType AND "BaseID" = :RefreshKey)
		  );

		DELETE FROM "NDBS_BGC_OBPE"
		WHERE "Amount" = 0
		  AND (
			("ObjectType" = :RefreshObjectType AND "ObjectID" = :RefreshKey)
			OR ("PrimaryObjectType" = :RefreshObjectType AND "PrimaryObjectID" = :RefreshKey)
			OR ("BaseType" = :RefreshObjectType AND "BaseID" = :RefreshKey)
		  );

		for currloop as loopdept do
			call NDBS_UpdateBudgetAmount(currloop."BudgetGroup",currloop."BudgetYear",'D',currloop."Department");
		end for;

		for currloop as loopproj do
			call NDBS_UpdateBudgetAmount(currloop."BudgetGroup",currloop."BudgetYear",'P',currloop."Project");
		end for;
	END IF;
end;
