SELECT T0."U_AccountCode"
FROM "@NDBS_BGC_BGPL" T0


SELECT T1."AcctCode" 
FROM OACT T1



  SELECT COUNT(*) AS match_acctcode
  FROM "@NDBS_BGC_BGPL" T5
  JOIN OACT T4 ON T5."U_AccountCode" = T4."AcctCode";

  SELECT COUNT(*) AS match_formatcode
  FROM "@NDBS_BGC_BGPL" T5
  JOIN OACT T4 ON T5."U_AccountCode" = T4."FormatCode";

  SELECT TOP 100
      T5."U_AccountCode",
      A1."AcctCode"   AS acctcode_match,
      A1."FormatCode" AS acctcode_format,
      A2."FormatCode" AS formatcode_match
  FROM "@NDBS_BGC_BGPL" T5
  LEFT JOIN OACT A1 ON T5."U_AccountCode" = A1."AcctCode"
  LEFT JOIN OACT A2 ON T5."U_AccountCode" = A2."FormatCode"
  WHERE A1."AcctCode" IS NOT NULL;