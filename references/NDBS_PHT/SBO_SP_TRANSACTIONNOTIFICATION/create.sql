CREATE PROCEDURE "SBO_PHT".SBO_SP_TransactionNotification
(
	in object_type nvarchar(30), 				-- SBO Object Type
	in transaction_type nchar(1),			-- [A]dd, [U]pdate, [D]elete, [C]ancel, C[L]ose
	in num_of_cols_in_key int,
	in list_of_key_cols_tab_del nvarchar(255),
	in list_of_cols_val_tab_del nvarchar(255)
)
LANGUAGE SQLSCRIPT
AS
-- Return values
error  int;				-- Result (0 for no error)
error_message nvarchar (200); 		-- Error string to be displayed
cnt int;
cnt1 int;
cnt2 int;

begin

Declare mesg NVARCHAR (100);
Declare CntReciept INTEGER DEFAULT 0; 
Declare CntIssue INTEGER DEFAULT 0; 

error := 0;
error_message := N'Ok';

--------------------------------------------------------------------------------------------------------------------------------

--	ADD	YOUR	CODE	HERE

--++================================================================++
 -- ::Block postdate more than CurrentDate :: -- Create On: 12 Feb'18
 --++================================================================++

select count(*) into CntReciept from OIGN 
			Where "DocEntry" = ( Select Distinct "DocEntry" From IGN1 Where TO_NVARCHAR("DocEntry") = :list_of_cols_val_tab_del And "BaseType" = '202' )
					And  DAYS_BETWEEN(TO_DATE(CURRENT_DATE),TO_DATE("DocDate")) > 0;
						
select count(*) into CntIssue from  OIGE Where "DocEntry" = ( Select Distinct "DocEntry" From IGE1 Where TO_NVARCHAR("DocEntry") = :list_of_cols_val_tab_del And "BaseType" = '202' )
						And  DAYS_BETWEEN(TO_DATE(CURRENT_DATE),TO_DATE("DocDate")) > 0;					

 -- ::>> Reciept from production
IF :object_type = '59' And (:transaction_type = 'A' OR :transaction_type = 'U') And :CntReciept > 0
then
	error := 100;
	error_message := N'ISS Posting Date เกินวันปัจจุบัน';
End If;

-- ::>> Issue from production
IF :object_type = '60' And (:transaction_type = 'A' OR :transaction_type = 'U') And :CntIssue > 0
Then
	error := 100;
	error_message := N'ISS Posting Date เกินวันปัจจุบัน';
End If;

-- ห้ามยกเลิกเอกสาร Produciton order เมื่อมีการรับสินค้าแล้ว

IF :object_type = '202' And (:transaction_type = 'C')
Then

	select count (t0."DocEntry") into cnt
	from OWOR t0
	where 1 = 1
	and t0."Status" = 'C'
	and (CAST(T0."DocNum" AS NVARCHAR(20)) IN (SELECT CAST("BaseRef" AS NVARCHAR(20)) FROM IGN1 WHERE CAST(T0."DocNum" AS NVARCHAR(20)) = CAST("BaseRef" AS NVARCHAR(20))) --and T0."IsByPrdct" ='Y'
	OR CAST(T0."DocNum" AS NVARCHAR(20)) IN (SELECT CAST("BaseRef" AS NVARCHAR(20)) FROM IGE1 WHERE CAST(T0."DocNum" AS NVARCHAR(20)) = CAST("BaseRef" AS NVARCHAR(20)) ))
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	IF :cnt > 0 Then
	
		error := 100;
		error_message := N'ISS ห้ามยกเลิกเอกสารที่มีการรับสินค้าแล้ว';
	
	End If;

End If;

-- -397 Receipt from Production เอกสาร Receipt for Production : ห้าม ADD หาก Item ใน Line ไม่มี Standard Cost (เช็คจาก Item Master แถบ Inventory ช่อง Item Cost)
IF :object_type = '59' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	select count(t0."DocEntry") into cnt
	from OIGN t0
	left join IGN1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM t2 on t1."ItemCode" = t2."ItemCode"
	left join OWOR t3 on t1."BaseEntry" = t3."DocEntry" 
	where 1 = 1
	and t1."BaseRef" is not null
	and (t2."AvgPrice" < 0.0001 or t2."AvgPrice" is null)
	--and t1."IsByPrdct" != 'Y'
	and t1."ItemCode" in (t3."ItemCode")
	and T2."InvntItem"='Y' -- GUN
	and T2."EvalSystem" ='S'-- GUN
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกนตรวจสอบ Standard Cost';
	
	End If;
	
End If;
--------------------------------------------------------------------------------------------------------------------------------

-- BIC001 : Production Order : Required Production Order Request DocNum
IF :object_type = '202' And (:transaction_type = 'U') Then -- If Update
	SELECT COUNT(T0."DocEntry") INTO cnt
    FROM OWOR T0
    WHERE T0."Status" = 'L' AND T0."DocEntry" = :list_of_cols_val_tab_del; -- If Status is Closed

	If :cnt > 0 Then 
		SELECT COUNT(T0."DocEntry") INTO cnt1
		FROM OWOR T0
		WHERE T0."U_ProdReqNum" IS NULL AND T0."DocEntry" = :list_of_cols_val_tab_del; -- If ProdReqNum is Null Then Alert
		If :cnt1 > 0 Then
			error := 100;
			error_message := 'BIC โปรดระบุ/ตรวจสอบ เลขที่ใบสั่งผลิต (Production Order Request)';
		Else
			SELECT COUNT(T0."DocEntry") INTO cnt1
			FROM OWOR T0
			INNER JOIN "@BIC_OWORREQ" T1 ON T1."DocNum" = T0."U_ProdReqNum" 
			WHERE T0."DocEntry" = :list_of_cols_val_tab_del;  -- If ProdReqNum is not Null Then Check have data 
			If :cnt1 = 0 Then 
				error := 100;
				error_message := 'BIC โปรดระบุ/ตรวจสอบ เลขที่ใบสั่งผลิต (Production Order Request)';
			End If;
		End If;
	End If;

End If;
-- BIC001 : END

-- BIC015 : Production Order : เช็คไม่ให้ลบ item ที่เซ็ตมาจาก BOM
IF :object_type = '202' And (:transaction_type = 'A' OR :transaction_type = 'U' ) Then
	SELECT count (FN."Code") into cnt1
	FROM
	(SELECT T1.*,T2."DocNum"
	FROM
	(SELECT 
		T0."Code" ,T3."ItemName" 
		,T1."Code" AS "ItemCode"
		,T1."Type"  AS "ItemType" 
	FROM OITT T0
	JOIN ITT1 T1 ON T1."Father"  = T0."Code" 
	LEFT JOIN OITM T3 ON T3."ItemCode"  = T0."Code" 
	WHERE T1."Type" != -18
	AND T1."Code" IS NOT NULL
	AND T0."Code" = (SELECT t0."ItemCode" FROM OWOR T0 WHERE T0."DocEntry" = :list_of_cols_val_tab_del))T1
	LEFT JOIN (
			SELECT 
			T0."DocNum"
			,T0."ItemCode" AS "Code" 
			,T3."ItemName" 
			,T1."ItemCode" 
			,T1."ItemType" 
			FROM OWOR T0
			JOIN WOR1 T1 ON T1."DocEntry" = T0."DocEntry" 
			LEFT JOIN OITM T3 ON T3."ItemCode"  = T0."ItemCode" 
			WHERE  T1."ItemType" != -18			
        	AND T1."ItemCode" IS NOT NULL
			AND T0."DocEntry" = :list_of_cols_val_tab_del
	) T2 ON  T1."Code"=T2."Code" AND   T2."ItemCode" = T1."ItemCode" AND T2."ItemType" = T1."ItemType") FN
	WHERE FN."DocNum" IS NULL ;

    -- เช็ค Type Production Order ต้องเป็น standard เท่านั้น
	SELECT count(o."DocEntry") into cnt2
	FROM OWOR o 
	WHERE o."DocEntry" = :list_of_cols_val_tab_del
	AND o."Type" = 'S';

	IF (:cnt2 > 0 and :cnt1 > 0 ) Then	
		error := 100;
		error_message := N'BIC คำสั่งผลิต (Production Order) ไม่อนุญาตให้ลบรายการ Item ที่กำหนดใน BOM';	
	End If;
	
End If;
-- BIC015 : Production Order : เช็คไม่ให้ลบ item ที่เซ็ตมาจาก BOM

-- BIC002 : A/R Invoice : Check request new payment terms
IF :object_type = '13' And (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	SELECT COUNT(A0."DocNum") INTO cnt1 
	FROM OINV A0 
	WHERE (A0."U_SOReqPayTerm" = '' OR A0."U_SOReqPayTerm" IS NULL) AND A0."DocEntry" =:list_of_cols_val_tab_del;

	IF :cnt1 = 0  THEN 
		SELECT COUNT(T0."GroupNum" )  INTO cnt 
		FROM OINV T0
		INNER JOIN OCTG T1 ON T1."GroupNum" = T0."GroupNum" AND T1."PymntGroup" = T0."U_SOReqPayTerm"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
		
		If :cnt = 0 Then 
	        error := 100;
	        error_message := 'BIC เอกสารต้นทาง (Sales Order) มีการขอเปลี่ยน Payment Terms โปรดตรวจสอบแก้ไข A/R Invoice';
	    End If;
   
   END IF; -- END CHECK INPUT 
   
 END IF;
-- BIC002 : END

-- BIC003 : BP Master 
IF :object_type = '2' And (:transaction_type = 'A' OR :transaction_type = 'U') THEN

	-- บังคับกรอก Federal Tax ID
	SELECT COUNT(A0."CardCode") INTO cnt
	FROM OCRD A0 
	WHERE (A0."LicTradNum" = '' OR A0."LicTradNum" IS NULL) AND A0."CardCode" =:list_of_cols_val_tab_del;

   	If :cnt > 0 Then 
	    error := 100;
	    error_message := 'BIC กรุณาระบุ Federal Tax ID ';
	End If;
	-- END

	-- CardName Required
	SELECT COUNT(A0."CardCode") INTO cnt
	FROM OCRD A0 
	WHERE (A0."CardName" = '' OR A0."CardName" IS NULL) AND A0."CardCode" =:list_of_cols_val_tab_del;

   	If :cnt > 0 Then 
	    error := 100;
	    error_message := 'BIC กรุณาระบุ Name ';
	End If;
	-- END

	-- Address > Bill To Required
	SELECT COUNT(A0."CardCode") INTO cnt
	FROM OCRD A0 
	INNER JOIN CRD1 A1 ON A0."CardCode" = A1."CardCode"
	WHERE A1."AdresType" = 'B' AND A0."CardCode" =:list_of_cols_val_tab_del;

   	If :cnt = 0 Then 
	    error := 100;
	    error_message := 'BIC กรุณาเพิ่มข้อมูลที่อยู่ Bill To/Pay To';
	End If;
	-- END
   
 END IF;

-- BIC003 : BP Master END

-- BIC004 : GRPO : Required PO Document
IF :object_type = '20' And :transaction_type = 'A' THEN
	SELECT COUNT(T0."DocEntry") INTO cnt
	FROM OPDN T0
	INNER JOIN PDN1 T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE T1."BaseType" != -1 AND T0."DocEntry" =:list_of_cols_val_tab_del;

   	If :cnt = 0 Then 
	    error := 100;
	    error_message := 'BIC การทำเอกสาร GRPO ต้องมีเอกสารก่อนหน้าอ้างอิง (A/P Invoice , PO , GRPO)';
	End If;
	
	--- สำหรับเช็คยอดรับเกิน PO 10%
    SELECT COUNT(Z."CheckLimit") INTO cnt1
	FROM 
	(SELECT V1.*,V2."Quantity",(V1."SumQuantityGRPOLimit"-V1."SumQuantityGRPO") AS "CheckLimit"
	FROM "BIC_POReceived" V1
	JOIN (
		SELECT  T1."BaseType" ,T1."BaseEntry" ,T1."ItemCode",I2."ItmsGrpNam"  ,SUM(T1."Quantity") AS "Quantity"
		FROM PDN1 T1 
		LEFT JOIN OPDN T2 ON T2."DocEntry"  = T1."DocEntry" 
		LEFT JOIN OITM I1 ON I1."ItemCode"  = T1."ItemCode" 
		LEFT JOIN OITB I2 ON I2."ItmsGrpCod" = I1."ItmsGrpCod"
		WHERE T2.CANCELED = 'N'
			AND TO_NVARCHAR(T2."DocEntry") = :list_of_cols_val_tab_del
		GROUP BY T1."BaseType" ,T1."BaseEntry" ,T1."ItemCode" ,I2."ItmsGrpNam"
		ORDER BY T1."BaseType" ,T1."BaseEntry"
	) V2 ON V2."BaseType" = V1."ObjType" AND V2."BaseEntry" = V1."DocEntry" AND V2."ItemCode" = V1."ItemCode" 
	) Z
	WHERE Z."CheckLimit" < 0 ;
	
	If :cnt1 > 0 Then 
	    error := 100;
	    error_message := 'BIC เอกสาร GRPO ไม่สามรถรับสินค้าเกินจาก เอกสาร PO ตามเปอร์เซ็นที่กำหนดไว้ได้';
	End If;
   
 END IF;
-- BIC004 : GRPO : Required PO Document END

-- BIC005 : Delivery 
IF :object_type = '15' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    --: Required BaseRef and Date Validation  
    -- ตรวจสอบการอ้างอิง Base Document
    SELECT COUNT(T0."DocEntry") INTO cnt
    FROM ODLN T0
    INNER JOIN DLN1 T1 ON T0."DocEntry" = T1."DocEntry"
    WHERE T1."BaseType" != -1 AND T0."DocEntry" = :list_of_cols_val_tab_del;

    IF :cnt = 0 THEN 
        error := 100;
        error_message := 'BIC การทำเอกสาร Delivery ต้องมีเอกสารก่อนหน้าอ้างอิง (A/R Invoice, Delivery, Return, Sales Order)';
    END IF;

    -- ตรวจสอบ Delivery Date ต้องไม่น้อยกว่า Posting Date (เฉพาะตอน Update เอกสารที่สถานะ Open)
    IF :transaction_type = 'U' THEN
        SELECT COUNT("DocEntry") INTO cnt
        FROM ODLN
        WHERE "DocEntry" = :list_of_cols_val_tab_del
          AND "DocStatus" = 'O'
          AND "DocDueDate" < "DocDate";

        IF :cnt > 0 THEN
            error := 101;
            error_message := 'BIC วันที่ Delivery Date ต้องไม่น้อยกว่าวันที่ Posting Date';
        END IF;
    END IF;
    
    
    -- : DO เช็คไม่ให้เปิด Delevery เกินยอด Sales Order
    SELECT COUNT(*)
    INTO cnt
    FROM
    (
        SELECT
            X."SODocEntry",
            X."SOLine",
            X."ItemCode",
            --SUM(X."Qty") AS "DOQty",
            --MAX(R."Quantity") AS "SOQty"
            SUM(CASE 
			        WHEN X."Qty" < 0 THEN X."Qty" * -1 
			        ELSE X."Qty" 
			    END) AS "DOQty",
            CASE WHEN MAX(R."Quantity") <0 THEN (MAX(R."Quantity")*-1) ELSE MAX(R."Quantity") END AS "SOQty"
        FROM
        (
            SELECT
                CASE
                    WHEN D."BaseType" = 17 THEN D."BaseEntry"
                    WHEN D."BaseType" = 13 AND I0."isIns" = 'Y' AND I1."BaseType" = 17 THEN I1."BaseEntry"
                END AS "SODocEntry",
                CASE
                    WHEN D."BaseType" = 17 THEN D."BaseLine"
                    WHEN D."BaseType" = 13 AND I0."isIns" = 'Y' AND I1."BaseType" = 17 THEN I1."BaseLine"
                END AS "SOLine",
                D."ItemCode",
                D."Quantity" AS "Qty"
            FROM DLN1 D
            JOIN ODLN H
              ON H."DocEntry" = D."DocEntry"
             AND H."CANCELED" = 'N'
            LEFT JOIN OINV I0
              ON D."BaseType" = 13
             AND I0."DocEntry" = D."BaseEntry"
             AND I0."CANCELED" = 'N'
            LEFT JOIN INV1 I1
              ON D."BaseType" = 13
             AND I1."DocEntry" = D."BaseEntry"
             AND I1."LineNum"  = D."BaseLine"
            WHERE
                D."BaseType" = 17
                OR (D."BaseType" = 13 AND I0."isIns" = 'Y' AND I1."BaseType" = 17)
        ) X
        JOIN RDR1 R
          ON R."DocEntry" = X."SODocEntry"
         AND R."LineNum"  = X."SOLine"
         AND R."ItemCode" = X."ItemCode"
        WHERE EXISTS
        (
            SELECT 1
            FROM DLN1 C
            LEFT JOIN OINV CI0
              ON C."BaseType" = 13
             AND CI0."DocEntry" = C."BaseEntry"
             AND CI0."CANCELED" = 'N'
            LEFT JOIN INV1 CI1
              ON C."BaseType" = 13
             AND CI1."DocEntry" = C."BaseEntry"
             AND CI1."LineNum"  = C."BaseLine"
            WHERE C."DocEntry" = :list_of_cols_val_tab_del
              AND (
                    (C."BaseType" = 17
                     AND C."BaseEntry" = X."SODocEntry"
                     AND C."BaseLine"  = X."SOLine"
                     AND C."ItemCode"  = X."ItemCode")
                 OR (C."BaseType" = 13
                     AND CI0."isIns" = 'Y'
                     AND CI1."BaseType" = 17
                     AND CI1."BaseEntry" = X."SODocEntry"
                     AND CI1."BaseLine"  = X."SOLine"
                     AND C."ItemCode"    = X."ItemCode")
              )
        )
        GROUP BY
            X."SODocEntry",
            X."SOLine",
            X."ItemCode"
        --HAVING SUM(X."Qty") > MAX(R."Quantity")
    ) A
   WHERE
   A."DOQty"> A."SOQty" ;
        
     If :cnt > 0 Then	
		error := 100;
		error_message := 'ไม่สามารถเปิด Delivery ได้: จำนวนส่งออกเกิน Sales Order';
    END IF;
    
    
END IF;
-- BIC005 : Delivery END

-- BIC008 : Inventory Transfer : Required Base > Inventory Transfer Request
IF :object_type = '67' And (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	-- เช็คว่า ต้องมีเอกสารก่อนหน้าอ้างอิง (Inventory Transfer Request)
	SELECT COUNT(T0."DocEntry") INTO cnt
	FROM OWTR T0
	INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
	WHERE T1."BaseType" = -1 AND T0."DocEntry" =:list_of_cols_val_tab_del;

   	If :cnt > 0 Then 
	    error := 100;
	    error_message := 'BIC การทำเอกสาร Inventory Transfer ต้องมีเอกสารก่อนหน้าอ้างอิง (Inventory Transfer Request)';
	Else 
	-- เช็คว่ายอดสินค้า/วัตถุดิบ เกินจาก Inventory Transfer Request หรือไม่
		SELECT COUNT(T0."DocEntry") INTO cnt1
			FROM OWTR T0
			INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
			LEFT JOIN (
				SELECT X0."BaseEntry",X0."BaseLine",X0."ItemCode" ,SUM(X0."Quantity") AS "SUM_Qty"
				FROM WTR1 X0 
				WHERE X0."BaseType" = 1250000001
				GROUP BY X0."BaseEntry",X0."BaseLine",X0."ItemCode" 
				) T2 ON T1."BaseEntry" = T2."BaseEntry" AND T1."ItemCode" = T2."ItemCode" AND T1."BaseLine" = T2."BaseLine"
			LEFT JOIN WTQ1 T3 ON T1."BaseEntry" = T3."DocEntry" AND T1."BaseLine" = T3."LineNum" AND T1."BaseType" = T3."ObjType" 
			WHERE T2."SUM_Qty" > T3."Quantity" AND T0."DocEntry" =:list_of_cols_val_tab_del;
		
		If :cnt1 > 0 Then
			error := 100;
			error_message := 'BIC โปรดตรวจสอบยอดสินค้า/วัตถุดิบ เนื่องจาก ห้ามระบุยอดเกินจาก Inventory Transfer Request';
		End If;
	End If;
	-- End If;    
    
    SELECT COUNT(T1."DocEntry") INTO cnt1
    FROM OWTR T0
    INNER JOIN WTR1 T1 ON T0."DocEntry" = T1."DocEntry"
    WHERE T1."BaseType" = -1 -- ไม่มีเอกสารฐาน
      AND T0."DocEntry" = :list_of_cols_val_tab_del;

    -- ถ้าพบว่ามีการเพิ่มบรรทัดใหม่ จะไม่อนุญาตให้บันทึก
    IF :cnt1 > 0 THEN
        error := 100;
        error_message := 'BIC ไม่อนุญาตให้เพิ่มบรรทัดใหม่ในเอกสาร Inventory Transfer (ต้องใช้ข้อมูลจากเอกสารอ้างอิงเท่านั้น)';
    END IF;
   
 END IF;
-- BIC008 : Inventory Transfer : Required Base > Inventory Transfer Request END

-- BIC012 : Production Order Request 
IF :object_type = 'BIC_OWORREQ' Then

	-- เมื่อสร้างเอกสาร ห้ามเลือกวันที่เอกสารย้อนเดือนปัจจุบัน
	IF :transaction_type = 'A' Then
		SELECT count(T0."DocEntry") INTO cnt
		FROM "@BIC_OWORREQ" T0
		WHERE (YEAR(T0."U_DocDate") = YEAR(CURRENT_DATE) AND MONTH(T0."U_DocDate") = MONTH(CURRENT_DATE))
		AND T0."DocEntry" =:list_of_cols_val_tab_del;
		
		If :cnt = 0 Then
			error := 100;
			error_message := 'BIC ห้ามเลือกวันที่เอกสารย้อนเดือนปัจจุบัน';
		End If;
	END IF;
	-- เมื่อสร้างเอกสาร ห้ามเลือกวันที่เอกสารย้อนเดือนปัจจุบัน END

	-- ห้ามแก้ไข เมื่อสถานะเป็น Close
	IF :transaction_type = 'U' Then
		SELECT count(T0."DocEntry") INTO cnt
		FROM "@BIC_OWORREQ" T0
		LEFT JOIN (SELECT X0."DocEntry" ,X0."U_Status"
					FROM "@ABIC_OWORREQ" X0 
					WHERE X0."DocEntry" = :list_of_cols_val_tab_del
					ORDER BY X0."LogInst" DESC
					LIMIT 1 OFFSET 1) T1 ON T1."DocEntry" = T0."DocEntry"
		WHERE T1."U_Status" = 'Close' AND T0."DocEntry" =:list_of_cols_val_tab_del;
	
		if :cnt > 0 THEN
			error := 100;
			error_message := 'BIC ห้ามแก้ไขเอกสารที่สถานะเป็น Close';
		End If;
	END IF;
	-- ห้ามแก้ไข เมื่อสถานะเป็น Close END

	-- ไม่ให้ปิดเอกสาร ถ้ายังมีรายการสถานะ Open อยู่
	IF :transaction_type = 'U' Then
		SELECT count(T0."DocEntry") INTO cnt1
		FROM "@BIC_OWORREQ" T0
		WHERE T0."U_Status" = 'Close' AND T0."DocEntry" =:list_of_cols_val_tab_del;
	
		if :cnt1 > 0 THEN
			SELECT count(T0."DocEntry") INTO cnt2
			FROM "@BIC_OWORREQLINE" T0 
			WHERE T0."U_Status" = 'Open' AND T0."DocEntry" =:list_of_cols_val_tab_del;
			
			if :cnt2 > 0 THEN
				error := 100;
				error_message := 'BIC ไม่สามารถ Close ได้ เนื่องจากยังมีรายการที่สถานะ Open';
			End If;
		End If;
	END IF;
	-- ไม่ให้ปิดเอกสาร ถ้ายังมีรายการสถานะ Open อยู่ END

End If;
-- BIC012 : Production Order Request  END

-- ::>> BIC013 Reciept from production ให้เลือกเฉพาะคลังที่เซ็ตเอาไว้ ใช้ทั้ง 3 บริษัท
IF :object_type = '59' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
   
    ---- กลุ่ม FG* บังคับเลือกคลังตามที่ระบุไว้เท่านั้น เช่น QC,QA
    SELECT  COUNT(Z."DocNum") into cnt
	FROM
	(
	SELECT a1."DocNum", b."ItmsGrpNam" ,a2."WhsCode" ,w."U_WhsCode" 
	,(CASE WHEN (SELECT "Code" FROM "@BIC_RFPWHLINE" p1 WHERE "Code" = b."ItmsGrpNam" AND  p1."U_WhsCode" IN (a2."WhsCode")) IS NULL
	       THEN 'NO'
	       ELSE 'YES'
	       END ) AS "CC"
	FROM OIGN a1 
	JOIN IGN1 a2 ON a1."DocEntry"  = a2."DocEntry" 
	LEFT JOIN OITM a ON a."ItemCode"  = a2."ItemCode" 
	LEFT JOIN OITB b ON b."ItmsGrpCod"  = a."ItmsGrpCod" 
	LEFT JOIN OWOR p ON p."DocNum"  = a2."BaseRef" 
	INNER JOIN "@BIC_RFPWHLINE" w ON w."Code"  = b."ItmsGrpNam" 
	WHERE 0=0
	--AND b."ItmsGrpNam" LIKE 'FG%'
	AND a2."BaseType" = '202' 
	AND p."Type" ='S'
	AND a1."DocEntry" = :list_of_cols_val_tab_del
	AND p."ItemCode" = a2."ItemCode"
	)Z
	WHERE Z."CC" = 'NO';

    If :cnt > 0 Then    
        error := 100;
        error_message := 'BIC รับจากการผลิต ไม่สามรถรับเข้าคลังที่ท่านระบุได้';

    End If;

End If;

-- BIC013 : Reciept from production ให้เลือกเฉพาะคลังที่เซ็ตเอาไว้ ใช้ทั้ง 3 บริษัท END

-- ::>> BIC014  Purchase Request  บังคับเลือก Department (ใช้ทั้ง 4 บริษัท) Start
IF :object_type = '1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- เช็คว่าเลือก Department หรือไม่
    SELECT COUNT(T1."DocEntry") into cnt
    FROM OPRQ T1 
    WHERE T1."DocEntry" = :list_of_cols_val_tab_del
    AND T1."Department" > 0 
    AND T1."Department" IS NOT NULL   ;

    -- เช็คว่าเลือก department ที่ยกเลิกไปแล้วหรือไม่ (C)
    SELECT COUNT(T1."DocEntry") into cnt1
    FROM OPRQ T1 
    LEFT JOIN OUDP T2 ON T2."Code" = T1."Department"
    WHERE T1."DocEntry" = :list_of_cols_val_tab_del
    AND T1."Department" > 0 
    AND T1."Department" IS NOT NULL  
    AND T2."Name" LIKE'%(C)%' ;

    If :cnt = 0 Then 
        error := 100;
        error_message := 'BIC กรุณาเลือก Department';
    End If;

    If :cnt1 > 0 Then 
        error := 100;
        error_message := 'BIC Department นี้ไม่ได้เปิดใช้งานแล้ว';
    End If;

END IF;
-- BIC014 Purchase Request  บังคับเลือก Department (ใช้ทั้ง 4 บริษัท) END

-- BIC015  transfer tequest 
IF :object_type = '1250000001' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN
   
    --เรื่อง QA เปิด transfer tequest เกี่ยวกับยาเท่านั่น ที่ปล่อยจาก QC ต้องเป็น "เกศแก้ว คุณวโรตม์" เท่านั้น
	/*IF :transaction_type = 'A' THEN
	    SELECT 
		 COUNT(Q0."DocEntry") INTO cnt1
		FROM 
		    OWTQ Q0
		INNER JOIN 
		    WTQ1 Q1 ON Q1."DocEntry" = Q0."DocEntry"
		LEFT JOIN 
		    OITM T0 ON T0."ItemCode" = Q1."ItemCode"
		LEFT JOIN OUGP T1 ON
			T0."UgpEntry" = T1."UgpEntry"
		LEFT JOIN OITB T2 ON
			T0."ItmsGrpCod" = T2."ItmsGrpCod"
		LEFT JOIN "BIC_ItemPropCat" bipc ON bipc."ItemCode" = T0."ItemCode" 
		LEFT JOIN "BIC_ItemPropCat2" bipc2 ON bipc2."ItemCode" = T0."ItemCode" 
		LEFT JOIN "BIC_ItemPropCat3" bipc3 ON bipc3."ItemCode" = T0."ItemCode" 
		LEFT JOIN "BIC_ItemPropCat4" bipc4 ON bipc4."ItemCode" = T0."ItemCode" 
		LEFT JOIN OUSR U1 ON U1.USERID = Q0."UserSign"
		WHERE T0."InvntItem" ='Y'
		AND  T2."ItmsGrpNam" IN('FG','FG2') 
		AND (bipc."ItmsGrpNam" LIKE '%ยา%' OR bipc2."ItmsGrpNam" LIKE '%ยา%')
		AND ( U1.USER_CODE  != 'LOG025'  AND U1.U_NAME != 'เกศแก้ว คุณวโรตม์') --- --LOG025 / เปลี่ยนเป็น 'เกศแก้ว คุณวโรตม์'
		AND Q0."Filler" = 'QC'
		AND Q1."FromWhsCod" = 'QC'
		AND Q0."DocEntry" =:list_of_cols_val_tab_del;  
		
	
	    IF :cnt1 > 0 THEN
	      error := 100;
	      error_message := 'คุณไม่ได้รับสิทธิ์ในการส่งออกสินค้่าประเภทยา';
	    END IF;
	END IF;
	*/
	-- Inventory Transfer Request Over Planed Production Order (IA Sing)
	IF (:transaction_type = 'A' OR :transaction_type = 'U') THEN
	    
	    SELECT 
			count(*) into cnt
		FROM  
		(
		SELECt
			B."RefDocNum" , B."RefDocEntr" , B."ItemCode" ,B."Dscription"  , SUM( B."Quantity") AS  "Quantity" , SUM("Quantity_TRF") AS "Quantity_TRF"
		FROM
		(
			SELECT T1."RefDocNum" , T1."RefDocEntr" , T3."ItemCode" ,T3."Dscription"  ,T3."Quantity" AS  "Quantity" , 0 AS "Quantity_TRF"
			FROM  
			WTQ21 T1 
			LEFT JOIN OWTQ T2 ON T2."DocEntry" = T1."DocEntry" 
			LEFT  JOIN WTQ1 T3 ON T3."DocEntry" = T2."DocEntry" 
			WHERE T1."DocEntry"  =  :list_of_cols_val_tab_del
			AND T2."U_TrfOver" ='NO' -- เช็คเงื่อนไข ถ้าเป็น YES จะไม่เข้าเงื่อนไขการเช็ค โอนย้านเกิน Planed
			AND T1."RefObjType" = 202
			AND T3."WhsCode" = 'PRD'              -- [FIX#1] นับเฉพาะ To PRD (Transfer Request Line)
			UNION ALL 
			SELECT T1."RefDocNum" , T1."RefDocEntr" , T3."ItemCode" ,T3."Dscription"  , 0 AS "Quantity" , T4."Quantity" AS "Quantity_TRF"  
			FROM  
			WTQ21 T1 
			LEFT JOIN OWTQ T2 ON T2."DocEntry" = T1."DocEntry" 
			LEFT JOIN WTQ1 T3 ON T3."DocEntry" = T2."DocEntry"
			LEFT JOIN WTR1 T4 ON T4."BaseEntry" = T3."DocEntry"  AND  T4."BaseType"  = T3."ObjType"  AND T4."BaseLine" = T3."LineNum" 
			LEFT JOIN OWTR T5 ON T5."DocEntry" = T4."DocEntry"
			LEFT JOIN OWOR T6 ON T1."RefDocEntr" = T6."DocEntry"
			WHERE 0=0
			AND T1."RefDocEntr" = (SELECT "RefDocEntr"  FROM   WTQ21 WHERE  "DocEntry" =  :list_of_cols_val_tab_del AND "RefObjType" = 202) -- ค้นหาจาก Docentry production order
			AND T4."BaseLine" IS NOT NULL
			AND T5.CANCELED <> 'Y'
			AND T1."RefObjType" = 202
			AND T4."WhsCode" = 'PRD'              -- [FIX#1] นับเฉพาะ To PRD (Inventory Transfer Line)
            AND T3."WhsCode" = 'PRD'              -- [FIX#1] กันเคส request ไม่เข้า PRD หลุดไปเลย
			)B
			GROUP BY B."RefDocNum" , B."RefDocEntr" , B."ItemCode" ,B."Dscription"
		) Z1
		LEFT JOIN 
		(
			SELECT a."DocEntry" ,a."ItemCode"  , SUM(a."PlannedQty") AS "PlannedQty"
			FROM WOR1 a WHERE a."DocEntry" =  (SELECT "RefDocEntr"  FROM   WTQ21 WHERE  "DocEntry" =  :list_of_cols_val_tab_del AND "RefObjType" = 202) -- ค้นหาจาก Docentry production order
			AND a."ItemType" = 4 AND a."IssueType" = 'M'
			GROUP BY a."DocEntry" ,a."ItemCode" ) L2 ON Z1."RefDocEntr" = L2."DocEntry"  AND Z1."ItemCode" = L2."ItemCode" 
		WHERE 0=0
		AND L2."PlannedQty"  <  (Z1."Quantity" + Z1."Quantity_TRF" )
		AND Z1."Quantity" > 0 ;
	
	    
	    IF :cnt > 0 THEN
	        error := 100;
	        error_message := 'BIC ไม่สามารถ Transfer เกินยอดที่ Planned ในเอกสาร Production Order ได้';
	
	    END IF;
    END IF;

END IF;

-- BIC015 transfer tequest END

-- ::>>BIC016 BIC  Purchase Order  เช็ค Budget Year PR vs PO (เฉพาะรายการที่อ้างอิง PR) Start
IF :object_type = '22' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- นับบรรทัด PO ที่อ้างอิง PR แล้ว BudgetYear ไม่ตรงกัน
    SELECT COUNT(P0."DocEntry") INTO cnt
    FROM OPOR P0
    JOIN POR1 P1 ON P1."DocEntry" = P0."DocEntry"
    LEFT JOIN PRQ1 R1 
        ON  R1."ObjType"  = P1."BaseType"
        AND R1."DocEntry" = P1."BaseEntry"
        AND R1."LineNum"  = P1."BaseLine"
    JOIN OITM I0 ON I0."ItemCode" = P1."ItemCode"
    JOIN OITB G0 ON G0."ItmsGrpCod" = I0."ItmsGrpCod"
    WHERE P0."DocEntry" = :list_of_cols_val_tab_del
      AND P1."BaseType" = 1470000113              -- PR
      AND I0."InvntItem" = 'N'
      AND (G0."ItmsGrpNam" LIKE 'ASS%' OR G0."ItmsGrpNam" LIKE 'EXP%')
      AND IFNULL(R1."U_NDBS_BudgetYear",NULL) <> IFNULL(P1."U_NDBS_BudgetYear",NULL);

    IF :cnt > 0 THEN
        error := 100;
        error_message := 'BIC ปีงบประมาณ PR และ PO ไม่ตรงกัน';
    END IF;

END IF;
-- ::>>BIC016 End

-- ::>>BIC017 BIC  AP Invoice  เช็ค Budget Year PO vs AP Invoice (เฉพาะรายการที่อ้างอิง PO) Start
IF :object_type = '18' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- นับบรรทัด AP Invoice ที่อ้างอิง PO แล้ว BudgetYear ไม่ตรงกัน
    SELECT COUNT(PV0."DocEntry") INTO cnt
    FROM OPCH PV0
    JOIN PCH1 PV1 ON PV1."DocEntry" = PV0."DocEntry"
    LEFT JOIN POR1 P1 
        ON  P1."ObjType"  = PV1."BaseType"
        AND P1."DocEntry" = PV1."BaseEntry"
        AND P1."LineNum"  = PV1."BaseLine"
    JOIN OITM I0 ON I0."ItemCode" = PV1."ItemCode"
    JOIN OITB G0 ON G0."ItmsGrpCod" = I0."ItmsGrpCod"
    WHERE PV0."DocEntry" = :list_of_cols_val_tab_del
      AND PV1."BaseType" = 22                      -- PO
      AND I0."InvntItem" = 'N'
      AND (G0."ItmsGrpNam" LIKE 'ASS%' OR G0."ItmsGrpNam" LIKE 'EXP%')
      AND IFNULL(P1."U_NDBS_BudgetYear",NULL) <> IFNULL(PV1."U_NDBS_BudgetYear",NULL);

    IF :cnt > 0 THEN
        error := 100;
        error_message := 'BIC ปีงบประมาณ PO และ AP Invoice ไม่ตรงกัน';
    END IF;

END IF;
-- ::>>BIC017 End

-- BIC018 : Asset Master Data บังคับกรอก U_Manufac2 และ U_Manufac3 Sart
IF :object_type = '4' AND (:transaction_type = 'A' OR :transaction_type = 'U') THEN

    -- ขาดทั้ง 2 ช่อง
    SELECT COUNT(*) INTO cnt
    FROM OITM T0
    WHERE T0."ItemCode" = :list_of_cols_val_tab_del
      AND T0."ItemType" = 'F'
      AND IFNULL(TRIM(T0."U_Manufac2"), '') = ''
      AND IFNULL(TRIM(T0."U_Manufac3"), '') = '';

    IF :cnt > 0 THEN
        error := 100;
        error_message := N'BIC กรุณาระบุข้อมูล แหล่งที่มา2 และ แหล่งที่มา3';
    ELSE

        -- ขาดเฉพาะ แหล่งที่มา2
        SELECT COUNT(*) INTO cnt
        FROM OITM T0
        WHERE T0."ItemCode" = :list_of_cols_val_tab_del
          AND T0."ItemType" = 'F'
          AND IFNULL(TRIM(T0."U_Manufac2"), '') = '';

        IF :cnt > 0 THEN
            error := 100;
            error_message := N'BIC กรุณาระบุข้อมูล แหล่งที่มา2';
        ELSE

            -- ขาดเฉพาะ แหล่งที่มา3
            SELECT COUNT(*) INTO cnt
            FROM OITM T0
            WHERE T0."ItemCode" = :list_of_cols_val_tab_del
              AND T0."ItemType" = 'F'
              AND IFNULL(TRIM(T0."U_Manufac3"), '') = '';

            IF :cnt > 0 THEN
                error := 100;
                error_message := N'BIC กรุณาระบุข้อมูล แหล่งที่มา3';
            END IF;

        END IF;

    END IF;

END IF;
-- BIC018 : Asset Master Data บังคับกรอก U_Manufac2 และ U_Manufac3 END

-- ::>>BIC019 Check Issue for Production over Planned 
IF :object_type = '60' AND (:transaction_type = 'A') THEN
    -- ปรับแก้ไขโดยเช็คยอดจากเอกสาร production Issued และหักจาก recerpt 
    SELECT COUNT(*) INTO cnt
	FROM OWOR T1 
	JOIN WOR1 T2 ON T2."DocEntry" = T1."DocEntry" 
	JOIN (
	    SELECT 
	        C."BaseEntry",
	        C."BaseLine",
	        C."BaseType",
	        C."ItemCode",
	        (
	            (   -- Issue สะสม
	                SELECT IFNULL(SUM(L2."Quantity"),0)
	                FROM OIGE H2
	                JOIN IGE1 L2 ON L2."DocEntry" = H2."DocEntry"
	                WHERE H2."CANCELED" = 'N'
	                  AND L2."BaseType"  = C."BaseType"
	                  AND L2."BaseEntry" = C."BaseEntry"
	                  AND L2."BaseLine"  = C."BaseLine"
	                  AND L2."ItemCode"  = C."ItemCode"
	            )
	            -
	            (   -- Receipt from Production สะสม (อ้าง PO เท่านั้น)
	                SELECT IFNULL(SUM(R2."Quantity"),0)
	                FROM OIGN RH2
	                JOIN IGN1 R2 ON R2."DocEntry" = RH2."DocEntry"
	                WHERE RH2."CANCELED" = 'N'
	                  AND R2."BaseType"  = C."BaseType"
	                  AND R2."BaseEntry" = C."BaseEntry"
	                  AND R2."BaseLine"  = C."BaseLine"
	                  AND R2."ItemCode"  = C."ItemCode"
	            )
	        ) AS "S_Quantity"
	    FROM (
	        SELECT DISTINCT
	            L."BaseEntry",
	            L."BaseLine",
	            L."BaseType",
	            L."ItemCode"
	        FROM OIGE H
	        JOIN IGE1 L ON L."DocEntry" = H."DocEntry"
	        WHERE 0=0
	          AND H."DocEntry" = :list_of_cols_val_tab_del
	          AND L."BaseType" = 202
	    ) C
	) IS1 
	  ON IS1."BaseEntry" = T1."DocEntry"
	 AND IS1."BaseLine"  = T2."LineNum"
	 AND IS1."ItemCode"  = T2."ItemCode"
	WHERE T2."ItemType" IN (290,4)
	  AND IS1."S_Quantity" > T2."PlannedQty";
     
    --- เช็คเรื่อง เลือกคลัง PRD เท่านั้น 
    SELECT COUNT(*) INTO cnt1
	FROM OIGE H
	JOIN IGE1 L ON L."DocEntry" = H."DocEntry"
	WHERE H."DocEntry" = :list_of_cols_val_tab_del
	  AND L."BaseType" = '202'
	  AND L."WhsCode" <> 'PRD';
	  
	IF :cnt1 > 0 THEN
	    error := 100;
	    error_message := 'BIC Issue for Production ต้องเบิกจากคลัง PRD เท่านั้น';
	END IF;

    IF :cnt > 0 THEN
        error := 100;
        error_message := 'BIC Issue for Production เกิน Planned';
    END IF;

END IF;

-- BIC019 : BIC019 Check Issue for Production over Planned  END

-- BICXXX : Block SO / AR Reserve / Draft by BP in View ใช้ชั่่วคราว พี่หนูนา
IF (:object_type = '17' OR :object_type = '13' OR :object_type = '112') AND :transaction_type = 'A' THEN

	----------------------------------------------------------------
	-- SO : Add
	----------------------------------------------------------------
	IF :object_type = '17' THEN
	
		SELECT COUNT(T0."DocNum") INTO cnt
		FROM ORDR T0
		INNER JOIN "SBO_BIC"."BIC_LIST_BP_BLOCK_SO_AR_Res" T1 ON T1."CardCode" = T0."CardCode"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del;
		
		IF :cnt > 0 THEN
	        error := 100;
	        error_message := 'BIC BP นี้ใช้ร่วมกับสำนักงานใหญ่ กรุณาเปิดเอกสารด้วยรหัสสำนักงานใหญ่แทน';
	    END IF;
	    
	END IF;


	----------------------------------------------------------------
	-- A/R Reserve : Add
	----------------------------------------------------------------
	IF :object_type = '13' AND :error = 0 THEN
	
		SELECT COUNT(T0."DocNum") INTO cnt
		FROM OINV T0
		INNER JOIN "SBO_BIC"."BIC_LIST_BP_BLOCK_SO_AR_Res" T1 ON T1."CardCode" = T0."CardCode"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del
		  AND IFNULL(T0."isIns",'N') = 'Y';
		
		IF :cnt > 0 THEN
	        error := 100;
	        error_message := 'BIC BP นี้ใช้ร่วมกับสำนักงานใหญ่ กรุณาเปิดเอกสารด้วยรหัสสำนักงานใหญ่แทน';
	    END IF;
	    
	END IF;


	----------------------------------------------------------------
	-- Draft SO / Draft A/R Reserve : Add
	----------------------------------------------------------------
	IF :object_type = '112' AND :error = 0 THEN
	
		SELECT COUNT(T0."DocNum") INTO cnt
		FROM ODRF T0
		INNER JOIN "SBO_BIC"."BIC_LIST_BP_BLOCK_SO_AR_Res" T1 ON T1."CardCode" = T0."CardCode"
		WHERE T0."DocEntry" = :list_of_cols_val_tab_del
		  AND (
		       T0."ObjType" = '17'
		       OR (T0."ObjType" = '13' AND IFNULL(T0."isIns",'N') = 'Y')
		  );
		
		IF :cnt > 0 THEN
	        error := 100;
	        error_message := 'BIC BP นี้ใช้ร่วมกับสำนักงานใหญ่ กรุณาเปิดเอกสารด้วยรหัสสำนักงานใหญ่แทน';
	    END IF;
		
	END IF;

END IF;
-- BICXXX : END

---BUDGET---

-- 100863 PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

	SELECT count(t0."DocEntry") Into cnt
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1
	and IFNULL(t1."OcrCode",'')=''
	and IFNULL(I1."InvntItem",'N')='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';
	
	End If;
End If;

IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt1
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;

-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

	SELECT count(t0."DocEntry") Into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	where 1 = 1 
	and IFNULL(t1."OcrCode",'')=''
	and IFNULL(I1."InvntItem",'N')='N'
	
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';
	
	End If;	
End If;

-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;

-- 100863 AP Budgetyear =''
IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPCH t0
	left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;

-- 100863 APCN Budgetyear =''
IF :object_type ='19' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from ORPC t0
	left join RPC1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;


-- 100863 JE Budgetyear =''
IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."TransId") Into cnt
	from OJDT t0
	left join JDT1 t1 on t0."TransId" = t1."TransId"

	where 1 = 1
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and T0."TransType" IN ('30')
	and T0."StornoToTr"=0
	and t0."TransId" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	
	
	select count(t0."DocEntry") into cnt
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	
	where 1 = 1
	and IFNULL(t1."OcrCode",'')=''
	and T0."ObjType" IN ('1470000049','22')
	and IFNULL(I1."InvntItem",'N')='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนใส่ฝ่าย';
	
	End If;
End If;	

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
		
	select count(t0."DocEntry") into cnt1
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and T0."ObjType" IN ('1470000049','22','18','19')
	and IFNULL(t1."U_NDBS_BudgetYear",0)=0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."CANCELED" ='N'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
	
	End If;
	
End If;

-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBDP"  T0 
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"  
	where 1 = 1
	and T0."ObjType" IN ('1470000113','22')
	and IFNULL(T1."Project",'') = ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."WddStatus" <> '-'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
	
	End If;
	
End If;



-- 100863 PO Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBDP"  T0 
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"  
	where 1 = 1
	and IFNULL(T1."Project",'') = ''
	and IFNULL(T1."OcrCode",'') <> ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 100;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
	
	End If;
	
End If;

-- 100863 PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	--select T3."Code" ,CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END AS "U_Department"
	--,ifnull(B."U_BudgetAmt",0)
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Department"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBDP"  T0 
	left join "@NDBS_BGC_BDPL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and CASE WHEN T4."U_Center" ='Y' THEN T4."U_Department" ELSE T2."U_NDBS_BudgetDept" END = B."U_Department"  
	where 1 = 1
	and IFNULL(T1."Project",'') = ''
	and IFNULL(T1."OcrCode",'') <> ''
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 501;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
	
	End If;
	
End If;


-- 100863 Draft Budgetyear =''
IF :object_type ='112' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from ODRF t0
	left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBPJ"  T0 
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"  
	where 1 = 1
	--and T0."ObjType" IN ('1470000113','22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and T0."WddStatus" <> '-'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 209;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
	
	End If;
	
End If;



-- 100863 Draft Budgetyear =''
IF :object_type ='22' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBPJ"  T0 
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"  
	where 1 = 1
	--and T0."ObjType" IN ('22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 202;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
	
	End If;
	
End If;

-- 100863 Draft PR Budgetyear =''
IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
	select count(t0."DocEntry") into cnt
	from OPRQ t0
	left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBPJ"  T0 
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"  
	where 1 = 1
	--and T0."ObjType" IN ('1470000113','22')
	and ifnull(B."U_BudgetAmt",0) =0
	and IFNULL(T1."Project",'')<>''
	and IFNULL(I1."InvntItem",'N')='N'
	and  T4."U_BGwithinbg"  ='Y'
	and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 203;
		error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
	
	End If;
	
End If;

-- PO Check Budget Year
IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	select count(t0."DocEntry") into cnt
	from OPOR t0
	left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
	left join oprc T2 ON T1."OcrCode" =T2."PrcCode"
	left join "@NDBS_BGC_BGPL" T3 on T1."AcctCode"= T3."U_AccountCode"
	left join "@NDBS_BGC_OBGP" T4 ON T3."Code" = T4."Code"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	left join 
	(
	SELECT T0."Code", T1."U_GroupCode"
	,T1."U_Project"
	--,CASE WHEN T2."U_Center" ='Y' THEN T2."U_Department" ELSE  T1."U_Department" END AS "U_Department"
	,T1."U_BudgetAmt" , T2."U_Locked", T2."U_Center", T3."U_AccountCode" 
	FROM "@NDBS_BGC_OBPJ"  T0 
	left join "@NDBS_BGC_BPJL"  T1 on T0."Code"= T1."Code" 
	LEFT JOIN  "@NDBS_BGC_OBGP" T2 ON T1."U_GroupCode" = T2."Code"
	left join "@NDBS_BGC_BGPL"  T3 on T2."Code"= T3."Code"
	 
	)B ON t1."U_NDBS_BudgetYear"= B."Code" and T3."Code" = B."U_GroupCode"
	and  T1."Project" = B."U_Project"  
	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",3) <> '202'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 301;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;


-- AP Check Budget Year
IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."DocEntry") Into cnt
	from OPCH t0
	left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
	left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
	LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
	AND T0."CANCELED"='N'
	and t0."DocEntry" = :list_of_cols_val_tab_del;
	
	If :cnt > 0 Then
	
		error := 302;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;


-- JE  Check Budget Year
IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
	SELECT count(t0."TransId") Into cnt
	from OJDT t0
	left join JDT1 t1 on t0."TransId" = t1."TransId"

	where 1 = 1
	and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
	and T0."TransType" IN ('30')
	and t0."TransId" = :list_of_cols_val_tab_del;

	If :cnt > 0 Then
	
		error := 303;
		error_message := 'ISS รบกวนตรวจสอบ Budget Year';
	
	End If;
	
End If;

/*
if :error = 0 then
	call NDBS_BUDGET_CONTROL (:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
end if;
*/

---BUDGET---
-- Select the return values
select :error, :error_message FROM dummy;

end;
