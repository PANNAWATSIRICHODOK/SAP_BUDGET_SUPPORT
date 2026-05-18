CREATE VIEW "UAT_JBF2"."BIC_POReceived" ( "DocNum", "DocEntry", "ObjType", "ItemCode", "ItemName", "CardCode", "CardName", "ItmsGrpNam", "PCLimit", "QuantityPO", "SumQuantityGRPOLimit", "OpenQty", "SumQuantityGRPO" ) AS SELECT 
  Z."DocNum",Z."DocEntry",Z."ObjType", Z."ItemCode", Z."ItemName", Z."CardCode", Z."CardName"
  , Z."ItmsGrpNam"
  ,(CASE WHEN  Z."InvntItem" = 'Y'  THEN 10 ELSE 0 END) AS "PCLimit" --- แก้ไขตรงนี้ เป็น 10 ถ้าใช้จริง
  , SUM(Z."QuantityPO") AS "QuantityPO"
  ,(CASE  WHEN  Z."InvntItem" != 'Y'
          THEN  SUM(Z."QuantityPO") 
          ELSE  ((SUM(Z."QuantityPO")*(CASE WHEN  Z."InvntItem" = 'Y'  THEN 10 ELSE 0 END))/100) + SUM(Z."QuantityPO") 
          END) AS "SumQuantityGRPOLimit"
  , SUM(Z."OpenQty") AS "OpenQty"
  , SUM(Z."SumQuantityGRPO") AS "SumQuantityGRPO"
FROM
(SELECT 
T0."DocNum"
,T0."DocEntry"
,T0."ObjType"
,T1."LineNum"
,T1."ItemCode" 
,I1."ItemName" 
,T0."CardCode" 
,T0."CardName" 
,I2."ItmsGrpNam"
,T1."Quantity" AS "QuantityPO"
,T1."OpenQty"
,I1."InvntItem"
,(CASE WHEN C1."SumQuantityGRPO" IS NULL THEN 0 ELSE C1."SumQuantityGRPO" END ) AS "SumQuantityGRPO"
FROM OPOR T0 
INNER JOIN POR1 T1 ON T1."DocEntry" = T0."DocEntry" 
LEFT JOIN OITM I1 ON I1."ItemCode"  = T1."ItemCode" 
LEFT JOIN OITB I2 ON I2."ItmsGrpCod" = I1."ItmsGrpCod"
LEFT JOIN (
			SELECT  A1."BaseEntry", A1."BaseLine" 
					, SUM(A1."Quantity") AS "SumQuantityGRPO" 
			FROM
			PDN1 A1 
			JOIN OPDN A2 ON A1."DocEntry" = A2."DocEntry" 
			WHERE (A1."BaseType" = '22' ) AND A2.CANCELED = 'N'
			GROUP BY A1."BaseEntry", A1."BaseLine" 
) C1 ON C1."BaseEntry" = T1."DocEntry" AND C1."BaseLine" = T1."LineNum"WHERE 1=1
AND T0.CANCELED = 'N'
--AND T0."DocStatus" != 'C'
) Z
WHERE 0=0
GROUP BY Z."DocNum",Z."DocEntry", Z."ObjType",Z."ItemCode", Z."ItemName", Z."CardCode", Z."CardName", Z."ItmsGrpNam",Z."InvntItem" ORDER BY Z."DocNum" , Z."ItemCode" WITH READ ONLY