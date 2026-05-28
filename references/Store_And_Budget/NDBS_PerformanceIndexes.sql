-- Run once per company database after deploying the optimized budget procedures.
-- If an index already exists, skip that CREATE INDEX statement.

CREATE INDEX "IDX_OBDE_BUDGET_QUERY"
ON "NDBS_BGC_OBDE" ("BudgetGroup","BudgetYear","Department","BudgetStatus","BudgetType");

CREATE INDEX "IDX_OBPE_BUDGET_QUERY"
ON "NDBS_BGC_OBPE" ("BudgetGroup","BudgetYear","Project","BudgetStatus","BudgetType");

CREATE INDEX "IDX_OBDE_OBJECT_TOUCH"
ON "NDBS_BGC_OBDE" ("ObjectType","ObjectID","BudgetGroup","BudgetYear","Department","Amount");

CREATE INDEX "IDX_OBDE_PRIMARY_TOUCH"
ON "NDBS_BGC_OBDE" ("PrimaryObjectType","PrimaryObjectID","BudgetGroup","BudgetYear","Department","Amount");

CREATE INDEX "IDX_OBDE_BASE_TOUCH"
ON "NDBS_BGC_OBDE" ("BaseType","BaseID","BudgetGroup","BudgetYear","Department","Amount");

CREATE INDEX "IDX_OBPE_OBJECT_TOUCH"
ON "NDBS_BGC_OBPE" ("ObjectType","ObjectID","BudgetGroup","BudgetYear","Project","Amount");

CREATE INDEX "IDX_OBPE_PRIMARY_TOUCH"
ON "NDBS_BGC_OBPE" ("PrimaryObjectType","PrimaryObjectID","BudgetGroup","BudgetYear","Project","Amount");

CREATE INDEX "IDX_OBPE_BASE_TOUCH"
ON "NDBS_BGC_OBPE" ("BaseType","BaseID","BudgetGroup","BudgetYear","Project","Amount");

CREATE INDEX "IDX_BDPL_UPDATE"
ON "@NDBS_BGC_BDPL" ("Code","U_GroupCode","U_Department");

CREATE INDEX "IDX_BPJL_UPDATE"
ON "@NDBS_BGC_BPJL" ("Code","U_GroupCode","U_Project");
