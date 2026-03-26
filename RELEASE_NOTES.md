# Release Notes

## Current Scope

โปรเจกต์นี้เป็น presentation site สำหรับอธิบาย `Budget.sql` ใน SAP Business One HANA โดยเน้น 2 มุมหลัก:

- ภาพรวมของระบบ budget validation
- flow ของเอกสารที่ถูก block จาก draft ไปจนถึง final control

## Delivered

- รวม `Overview` และ `Checks` เป็นหน้าเดียว
- ทำ `Workflow` ให้ interactive
- เพิ่ม `Business / Developer` tab
- เพิ่ม `Code refs / SQL` แบบ dropdown
- เพิ่ม auto-hiding header
- เพิ่ม `Developer` summary สำหรับจุดที่ควรรีบแก้ใน `Budget.sql`

## Key Findings Highlighted

- Draft check ใช้ตัวแปรผิด `cnt1` / `cnt`
- Draft `ObjType` น่าจะไม่ตรงกับเจตนา
- กติกา `Budget Year` ไม่สอดคล้องกันระหว่างเอกสาร
- `Error 100` ถูกใช้ซ้ำหลายความหมาย

## Suggested Next Release

- เพิ่ม analysis ของ `NDBS_BUDGET_CONTROL`
- เชื่อม flow ระหว่าง `Budget.sql` และ final procedure
- ทำ budget impact map ว่า PR / PO / AP / JE มีผลต่อยอดงบอย่างไร
- เพิ่ม developer diagnostics ให้ลึกระดับ logic และ performance
