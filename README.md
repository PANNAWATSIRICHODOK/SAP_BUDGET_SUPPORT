# SAP_BUDGET_SUPPORT

เว็บนำเสนอและอธิบาย logic ของ `Budget.sql` สำหรับ SAP Business One on SAP HANA โดยเน้นให้ทั้งผู้บริหารและทีมพัฒนาเข้าใจ flow การตรวจงบ, จุดที่เอกสารถูก block, และความเสี่ยงที่ควรรีบแก้ในโค้ด

## สิ่งที่มีในโปรเจกต์

- `index.html` หน้า presentation แบบ 2 ส่วน: `Overview` และ `Workflow`
- `styles.css` theme และ interaction ของหน้าเว็บ
- `app.js` logic สำหรับ tab, workflow interaction, code dropdown, และ auto-hiding header
- `Budget.sql` ไฟล์ SQL ต้นฉบับที่ใช้วิเคราะห์

## จุดเด่นของเว็บ

- สรุปภาพรวมระบบ budget validation แบบสั้นและใช้ present ได้
- แสดง flow `Draft -> PR -> PO -> AP / APCN -> JE -> Final`
- คลิกดูแต่ละเอกสารเพื่อเห็น:
  - เชื่อมจากขั้นไหน
  - ไปต่อขั้นไหน
  - ถูก block ด้วยอะไร
  - ถ้าผ่านจะส่งผลอย่างไร
- มี `Business / Developer` tab ในส่วน Overview
- มี dropdown สำหรับดู SQL snippet ตาม `Code refs`
- header ซ่อนเองตอนเลื่อนลงและกลับมาเมื่อเลื่อนขึ้น

## วิธีเปิดใช้งาน

เปิดไฟล์ `index.html` ตรง ๆ ใน browser ได้เลย หรือ serve แบบ local:

```bash
cd /Users/bic-pannawat/Documents/SideProject
python3 -m http.server
```

จากนั้นเปิด `http://localhost:8000`

## โครงสร้างการใช้งาน

### Overview

- `Business`
  - สรุประบบเช็กอะไร
  - เอกสารที่อยู่ใน scope
- `Developer`
  - จุดผิดใน `Budget.sql` ที่ควรรีบแก้

### Workflow

- คลิกที่ stage เพื่อดูรายละเอียดของเอกสารนั้น
- ใช้ `ก่อนหน้า / ถัดไป` เพื่อ present ทีละขั้น
- ใช้คีย์:
  - `ArrowUp / ArrowDown / PageUp / PageDown / Space` สำหรับเปลี่ยนสไลด์
  - `ArrowLeft / ArrowRight` หรือ `[` `]` สำหรับเปลี่ยน stage ใน workflow

## จุดที่ทีมพัฒนาควรดูต่อ

- ตรวจแก้ logic ของ draft ที่ใช้ `cnt1` แต่ไปเช็ก `cnt`
- ตรวจ `ObjType` ของ draft ว่าตรงกับเอกสารที่ตั้งใจคุมจริงหรือไม่
- ทำกติกา `Budget Year` ให้สอดคล้องกันทุกเอกสาร
- แยก `error code` ให้ไม่ซ้ำหลายความหมาย
- ถ้ามีไฟล์ `NDBS_BUDGET_CONTROL` ให้เอามารวมวิเคราะห์ต่อ เพื่อให้ flow ของ budget control ครบทั้งระบบ

## ไฟล์ถัดไปที่ควรเพิ่ม

ถ้าต้องการให้เว็บนี้อธิบายระบบ budget control ได้ครบจริง ควรเพิ่มไฟล์:

- `NDBS_BUDGET_CONTROL`
- procedure อื่นที่ถูก `CALL` ต่อจากมัน ถ้ามี

## Git Workflow ที่แนะนำ

- `main` เก็บเวอร์ชันที่พร้อมใช้งาน
- branch ถัดไปสำหรับขยาย analysis: `feature/ndbs-budget-control`

