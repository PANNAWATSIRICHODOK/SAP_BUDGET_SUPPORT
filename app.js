const slides = [...document.querySelectorAll(".slide")];
const slidesContainer = document.querySelector("#slides");
const slideDots = [...document.querySelectorAll(".slide-dot")];
const currentSlideLabel = document.querySelector("#current-slide-label");
const frame = document.querySelector(".frame");
const overviewTabs = [...document.querySelectorAll(".overview-tab")];
const overviewTabPanels = [...document.querySelectorAll(".overview-tab-panel")];

const flowChips = [...document.querySelectorAll(".flow-chip")];
const flowConnectors = [...document.querySelectorAll(".flow-connector")];
const flowDetail = document.querySelector("#flow-detail");
const flowStagePosition = document.querySelector("#flow-stage-position");
const flowStageCaption = document.querySelector("#flow-stage-caption");
const flowPrevButton = document.querySelector("#flow-prev");
const flowNextButton = document.querySelector("#flow-next");
const flowDetailKicker = document.querySelector("#flow-detail-kicker");
const flowDetailTitle = document.querySelector("#flow-detail-title");
const flowDetailSummary = document.querySelector("#flow-detail-summary");
const flowDetailTags = document.querySelector("#flow-detail-tags");
const flowDetailFrom = document.querySelector("#flow-detail-from");
const flowDetailTo = document.querySelector("#flow-detail-to");
const flowDetailImpact = document.querySelector("#flow-detail-impact");
const flowRuleCaption = document.querySelector("#flow-rule-caption");
const flowDetailRules = document.querySelector("#flow-detail-rules");
const flowDetailPass = document.querySelector("#flow-detail-pass");
const flowDetailNote = document.querySelector("#flow-detail-note");
const flowDetailCodes = document.querySelector("#flow-detail-codes");

const workflowOrder = ["draft", "pr", "po", "ap", "je", "final"];
let activeWorkflowStage = workflowOrder[0];
let lastScrollTop = 0;

const workflowData = {
  draft: {
    status: "Draft Gate",
    kicker: "Stage 1",
    title: "Draft",
    summary: "เริ่มจากเอกสารร่างก่อน ถ้าร่างยังไม่ครบ ระบบจะไม่ปล่อยให้ใช้เป็นฐานของเอกสารจริง",
    from: "ผู้ใช้เริ่มกรอกเอกสารใน Draft",
    to: "PR / PO / AP / APCN ที่พร้อมไปขั้นถัดไป",
    impact: "หยุดตั้งแต่ร่าง ผู้ใช้ต้องกลับไปเติมข้อมูล budget ให้ครบก่อน",
    pass: "เมื่อผ่านแล้ว Draft จะพร้อมให้ผู้ใช้นำไปเปิดต่อหรือแปลงเป็นเอกสารจริงตาม flow ธุรกิจ",
    note: "store นี้ทำหน้าที่ตรวจและ block เท่านั้น ไม่ได้สร้างเอกสารถัดไปให้อัตโนมัติ",
    caption: "4 จุดที่ store ใช้ block draft ก่อนเกิดเอกสารจริง",
    tags: ["Add / Update", "Draft Pre-check", "ก่อนเอกสารจริง"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "Draft ของ PR/PO ที่ item เป็น non-inventory และ item group เปิด budget control แต่ OcrCode ว่าง",
        action: "store ตั้ง error = 100 และส่งข้อความ ISS รบกวนใส่ฝ่าย",
        impact: "draft นี้ยังไม่พร้อมใช้เป็นฐานของ PR หรือ PO",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 100",
        when: "Draft ของ PR/PO/AP/APCN ที่ U_NDBS_BudgetYear ว่าง",
        action: "store ตั้งใจ block ด้วยข้อความ ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "ผู้ใช้ยังเก็บ draft ที่พร้อมใช้ต่อไม่ได้",
      },
      {
        title: "ไม่มี budget ตามฝ่าย",
        badge: "Error 105",
        when: "Draft ของ PR/PO ที่ไม่มี Project และหา budget ตามปีงบ + group account + department ไม่เจอ",
        action: "store ตั้ง error = 105 และแจ้ง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "ร่างยังไม่ผ่านประตู budget ตั้งแต่ต้นทาง",
      },
      {
        title: "ไม่มี budget ตาม Project",
        badge: "Error 209",
        when: "Draft ที่มี Project แต่ไม่พบ project budget หรือ budget amount เป็น 0",
        action: "store ตั้ง error = 209 และแจ้ง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "draft ที่อิง project จะไม่ไปต่อจนกว่าจะผูกงบ project ถูกต้อง",
      },
    ],
    codes: ["Budget.sql:155-200", "Budget.sql:203-247", "Budget.sql:339-378"],
  },
  pr: {
    status: "PR Gate",
    kicker: "Stage 2",
    title: "PR",
    summary: "PR คือต้นทางของการขอใช้เงิน ถ้า PR ถูก block จะหยุดตั้งแต่คำขอ ยังไม่พร้อมไปสู่การอนุมัติและ PO",
    from: "Draft หรือการสร้าง PR ตรง",
    to: "Approval / PO",
    impact: "คำขอใช้เงินหยุดที่ต้นทาง และยังใช้สร้าง PO ไม่ได้",
    pass: "เมื่อผ่าน PR จะพร้อมเข้าสู่ approval และใช้เป็นฐานสร้าง PO",
    note: "store ตรวจทั้งความครบของข้อมูลและการมี budget รองรับจริงในชั้น PR",
    caption: "4 จุด block สำคัญที่ทำให้ PR ไปต่อไม่ได้",
    tags: ["Add / Update", "ต้นทางขอใช้เงิน", "ก่อน PO"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "บรรทัด PR ที่เป็น non-inventory ไม่มี OcrCode",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนใส่ฝ่าย",
        impact: "PR ยังไม่พร้อมเข้าสู่ approval",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 101",
        when: "บรรทัด PR ที่เป็น non-inventory ไม่มี U_NDBS_BudgetYear",
        action: "store ตั้ง error = 101 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "คำขอใช้เงินยังไม่อยู่ในกรอบ budget year ที่ระบบยอมรับ",
      },
      {
        title: "ไม่มีงบตามฝ่าย",
        badge: "Error 501",
        when: "PR ไม่มี Project แต่หา budget ตามปีงบ + account group + department ไม่เจอ",
        action: "store ตั้ง error = 501 และแสดง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "PR ยังไม่สามารถใช้เป็นฐานของ PO ได้",
      },
      {
        title: "ไม่มีงบตาม Project",
        badge: "Error 203",
        when: "PR มี Project แต่หา project budget ไม่เจอหรือ budget amount เป็น 0",
        action: "store ตั้ง error = 203 และแสดง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "PR สาย project จะหยุดที่ชั้นนี้จนกว่าจะมี budget setup รองรับ",
      },
    ],
    codes: ["Budget.sql:4-21", "Budget.sql:23-40", "Budget.sql:295-335", "Budget.sql:424-462"],
  },
  po: {
    status: "PO Gate",
    kicker: "Stage 3",
    title: "PO",
    summary: "PO คือจุดที่เริ่มผูก supplier และยอดสั่งซื้อจริง จึงถูกตรวจซ้ำอย่างเข้มขึ้นก่อนปล่อยไปขั้นรับของหรือเจ้าหนี้",
    from: "PR",
    to: "GRPO / AP / APCN ใน flow ธุรกิจ",
    impact: "การสั่งซื้อหยุด และเอกสาร downstream ที่อ้างอิง PO ยังเดินต่อไม่ได้",
    pass: "เมื่อผ่าน PO จะพร้อมถูกอ้างอิงไปขั้นรับของหรือตั้งเจ้าหนี้ตามกระบวนการจริง",
    note: "ไฟล์นี้ไม่ได้สร้าง GRPO หรือ AP/APCN ให้เอง แต่ PO ที่ไม่ผ่านจะตัดการไหลของเอกสารถัดไปทันที",
    caption: "5 จุด block ที่ PO โดนคุมหนักที่สุดใน flow นี้",
    tags: ["Add / Update", "ผูกพันยอดซื้อ", "ก่อนเจ้าหนี้"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "บรรทัด PO ที่เป็น non-inventory ไม่มี OcrCode",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนใส่ฝ่าย",
        impact: "PO ไม่ผ่านตั้งแต่ข้อมูลความรับผิดชอบของงบ",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 102",
        when: "บรรทัด PO ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "store ตั้ง error = 102 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "PO ยังไม่พร้อมใช้เป็นเอกสารอ้างอิงต่อ",
      },
      {
        title: "ไม่มีงบตามฝ่าย",
        badge: "Error 100",
        when: "PO ไม่มี Project แต่หา budget ตามปีงบ + account group + department ไม่เจอ",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "PO ยังไม่ผ่านประตู budget ฝั่ง department",
      },
      {
        title: "ไม่มีงบตาม Project",
        badge: "Error 202",
        when: "PO มี Project แต่หา project budget ไม่เจอหรือ budget amount เป็น 0",
        action: "store ตั้ง error = 202 และแสดง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "PO ที่ใช้ project จะหยุดตรงนี้ทันที",
      },
      {
        title: "ปีงบไม่ตรงรูปแบบ",
        badge: "Error 301",
        when: "ค่า U_NDBS_BudgetYear ของ PO ไม่ขึ้นต้นตามรูปแบบที่ script ยอมรับ",
        action: "store ตั้ง error = 301 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "แม้จะมี budget อยู่แล้ว แต่รูปแบบปีงบผิดก็ยังบันทึก PO ไม่ได้",
      },
    ],
    codes: ["Budget.sql:43-61", "Budget.sql:64-83", "Budget.sql:252-292", "Budget.sql:383-421", "Budget.sql:464-498"],
  },
  ap: {
    status: "AP / APCN Gate",
    kicker: "Stage 4",
    title: "AP / APCN",
    summary: "ชั้นนี้คุมตอนเริ่มรับรู้เจ้าหนี้หรือการกลับรายการกับ supplier แม้เอกสารก่อนหน้าจะผ่านมาแล้ว",
    from: "PO หรือการตั้งเจ้าหนี้ / เครดิตเมโมโดยตรง",
    to: "ผลบัญชีและ JE ปลายทาง",
    impact: "ยังไม่รับรู้เจ้าหนี้หรือ reverse รายการในเอกสารนั้น",
    pass: "เมื่อผ่าน เอกสารเจ้าหนี้จะถูกบันทึกและพร้อมส่งผลต่อบัญชีปลายทาง",
    note: "A/P Invoice กับ A/P Credit Memo ใช้กฎไม่เหมือนกันในไฟล์นี้ โดย APCN ไม่มี check รูปแบบปีงบ",
    caption: "3 จุด block ในชั้นเจ้าหนี้ที่ store ตรวจชัดเจน",
    tags: ["Add / Update", "รับรู้เจ้าหนี้", "ขั้นบัญชี"],
    rules: [
      {
        title: "A/P Invoice ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด A/P Invoice ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "ยังไม่รับรู้เจ้าหนี้จากเอกสารนั้น",
      },
      {
        title: "A/P Invoice ปีงบไม่ตรงรูปแบบ",
        badge: "Error 302",
        when: "U_NDBS_BudgetYear ของ A/P Invoice มีค่าน้อยกว่ากรอบปีที่ script ยอมรับ",
        action: "store ตั้ง error = 302 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "แม้เอกสารต้นทางผ่านมาแล้ว A/P Invoice ก็ยังถูก block ได้",
      },
      {
        title: "A/P Credit Memo ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด A/P Credit Memo ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "การกลับรายการฝั่งเจ้าหนี้ยังไม่สามารถบันทึกได้",
      },
    ],
    codes: ["Budget.sql:86-107", "Budget.sql:110-130", "Budget.sql:501-520"],
  },
  je: {
    status: "JE Gate",
    kicker: "Stage 5",
    title: "JE",
    summary: "แม้จะไม่ผ่าน flow จัดซื้อครบชุด JE ก็ยังถูกคุม budget year ก่อน post เข้า ledger",
    from: "AP / APCN หรือการลง JE ตรง",
    to: "Final Control และ ledger จริง",
    impact: "รายการบัญชียังไม่ถูก post เข้า ledger",
    pass: "เมื่อผ่าน JE จะพร้อมไปยัง final control แล้วจึงบันทึก transaction",
    note: "ชั้นนี้คุมปีงบของบรรทัดบัญชีโดยตรง ไม่ได้ตรวจ budget ตามฝ่ายหรือ project ในไฟล์นี้",
    caption: "2 จุด block ที่ตัด JE ก่อนลงบัญชีจริง",
    tags: ["Add / Update", "ลงบัญชีตรง", "ปลายทาง Ledger"],
    rules: [
      {
        title: "ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด JE ไม่มี U_NDBS_BudgetYear",
        action: "store ตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "JE ยังไม่ถูก post เข้า ledger",
      },
      {
        title: "ปีงบไม่ตรงรูปแบบ",
        badge: "Error 303",
        when: "U_NDBS_BudgetYear ของ JE ต่ำกว่ากรอบปีที่ script ยอมรับ",
        action: "store ตั้ง error = 303 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "JE ถูกหยุดแม้จะเป็นการลงบัญชีตรงโดยไม่ผ่าน PR หรือ PO",
      },
    ],
    codes: ["Budget.sql:134-152", "Budget.sql:523-541"],
  },
  final: {
    status: "Final Control",
    kicker: "Stage 6",
    title: "Final Control",
    summary: "ทุกเอกสารที่ยังไม่มี error จากขั้นก่อนจะถูกส่งต่อไปตรวจ final control อีกชั้นก่อน commit transaction",
    from: "Draft / PR / PO / AP / APCN / JE ที่ผ่าน pre-check",
    to: "บันทึก transaction จริง",
    impact: "ถึงเอกสารก่อนหน้าจะผ่าน ถ้า final control ไม่ผ่านก็ยังถูก block ได้อีก",
    pass: "เอกสารจะถูกบันทึกได้จริงต่อเมื่อ NDBS_BUDGET_CONTROL ไม่ส่ง error กลับมา",
    note: "นี่คือประตูสุดท้ายของ store ในไฟล์นี้ก่อน transaction commit",
    caption: "1 ขั้นสุดท้ายที่ทุกเอกสารต้องผ่านก่อน commit",
    tags: ["หลัง Pre-check", "Procedure Call", "จบ Transaction"],
    rules: [
      {
        title: "เรียก final procedure",
        badge: "Procedure Call",
        when: "ถ้า error = 0 จากทุกเงื่อนไขก่อนหน้า",
        action: "store เรียก NDBS_BUDGET_CONTROL พร้อม object type, transaction type และ document key",
        impact: "final procedure ยังมีสิทธิ์ block เพิ่มก่อนบันทึกจริง",
      },
    ],
    codes: ["Budget.sql:543-545"],
  },
};

const workflowCodeLibrary = {
  draft: [
    {
      label: "ไม่มีฝ่าย | Error 100",
      ref: "Budget.sql:155-176",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt
  from ODRF t0
  left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
  left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
  LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
  where IFNULL(t1."OcrCode",'')=''
    and T0."ObjType" IN ('1470000049','22')
    and IFNULL(I1."InvntItem",'N')='N'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 100",
      ref: "Budget.sql:180-200",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt1
  from ODRF t0
  left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
  where T0."ObjType" IN ('1470000049','22','18','19')
    and IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 105",
      ref: "Budget.sql:205-247",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A') Then
  ...
  where T0."ObjType" IN ('1470000113','22')
    and IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and T0."WddStatus" <> '-'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 105;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 209",
      ref: "Budget.sql:339-378",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and IFNULL(I1."InvntItem",'N')='N'
    and T0."WddStatus" <> '-'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 209;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
  End If;
End If;`,
    },
  ],
  pr: [
    {
      label: "ไม่มีฝ่าย | Error 100",
      ref: "Budget.sql:4-21",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPRQ t0
  left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
  left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
  where IFNULL(t1."OcrCode",'')=''
    and IFNULL(I1."InvntItem",'N')='N'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 101",
      ref: "Budget.sql:23-40",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPRQ t0
  left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and IFNULL(I1."InvntItem",'N')='N'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 101;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 501",
      ref: "Budget.sql:295-335",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A') Then
  ...
  where IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(I1."InvntItem",'N')='N'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 501;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 203",
      ref: "Budget.sql:424-462",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and IFNULL(I1."InvntItem",'N')='N'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 203;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
  End If;
End If;`,
    },
  ],
  po: [
    {
      label: "ไม่มีฝ่าย | Error 100",
      ref: "Budget.sql:43-61",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."OcrCode",'')=''
    and IFNULL(I1."InvntItem",'N')='N'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 102",
      ref: "Budget.sql:64-83",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and IFNULL(I1."InvntItem",'N')='N'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 102;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 100",
      ref: "Budget.sql:252-292",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A') Then
  ...
  where IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(I1."InvntItem",'N')='N'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 202",
      ref: "Budget.sql:383-421",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and IFNULL(I1."InvntItem",'N')='N'
    and T4."U_BGwithinbg" = 'Y'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 202;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
  End If;
End If;`,
    },
    {
      label: "Budget Year ไม่ตรงรูปแบบ | Error 301",
      ref: "Budget.sql:464-498",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  where LEFT(T1."U_NDBS_BudgetYear",3) <> '202'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 301;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
  ],
  ap: [
    {
      label: "A/P Invoice ไม่มีปีงบ | Error 100",
      ref: "Budget.sql:86-107",
      snippet: `IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPCH t0
  left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
  LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and IFNULL(I1."InvntItem",'N')='N'
    and T0."CANCELED"='N'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "A/P Credit Memo ไม่มีปีงบ | Error 100",
      ref: "Budget.sql:110-130",
      snippet: `IF :object_type ='19' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from ORPC t0
  left join RPC1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and IFNULL(I1."InvntItem",'N')='N'
    and T0."CANCELED"='N'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "A/P Invoice ปีงบไม่ตรงรูปแบบ | Error 302",
      ref: "Budget.sql:501-520",
      snippet: `IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPCH t0
  left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
  where LEFT(T1."U_NDBS_BudgetYear",4) < '2024'
    AND T0."CANCELED"='N'
    and t0."DocEntry" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 302;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
  ],
  je: [
    {
      label: "ไม่มีปีงบ | Error 100",
      ref: "Budget.sql:134-152",
      snippet: `IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."TransId") Into cnt
  from OJDT t0
  left join JDT1 t1 on t0."TransId" = t1."TransId"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and T0."TransType" IN ('30')
    and T0."StornoToTr"=0
    and t0."TransId" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "Budget Year ไม่ตรงรูปแบบ | Error 303",
      ref: "Budget.sql:523-541",
      snippet: `IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."TransId") Into cnt
  from OJDT t0
  left join JDT1 t1 on t0."TransId" = t1."TransId"
  where LEFT(T1."U_NDBS_BudgetYear",4) < '2024'
    and T0."TransType" IN ('30')
    and t0."TransId" = :list_of_cols_val_tab_del;

  If :cnt > 0 Then
    error := 303;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
  ],
  final: [
    {
      label: "Final Procedure Call",
      ref: "Budget.sql:543-545",
      snippet: `if :error = 0 then
  call NDBS_BUDGET_CONTROL (
    :object_type,
    :transaction_type,
    :list_of_cols_val_tab_del,
    :error,
    :error_message
  );
end if;`,
    },
  ],
};

function renderWorkflowStage(stageKey) {
  const stage = workflowData[stageKey];
  const stageIndex = workflowOrder.indexOf(stageKey);

  if (!stage || !flowDetail || stageIndex === -1) {
    return;
  }

  activeWorkflowStage = stageKey;

  flowChips.forEach((chip, index) => {
    const isActive = chip.dataset.stage === stageKey;
    chip.classList.toggle("is-active", isActive);
    chip.classList.toggle("is-complete", index < stageIndex);
    chip.setAttribute("aria-pressed", String(isActive));
  });

  flowConnectors.forEach((connector, index) => {
    connector.classList.toggle("is-active", index < stageIndex);
  });

  if (flowStagePosition) {
    flowStagePosition.textContent = `${stageIndex + 1} / ${workflowOrder.length}`;
  }

  if (flowStageCaption) {
    flowStageCaption.textContent = stage.status;
  }

  if (flowDetailKicker) {
    flowDetailKicker.textContent = stage.kicker;
  }

  if (flowDetailTitle) {
    flowDetailTitle.textContent = stage.title;
  }

  if (flowDetailSummary) {
    flowDetailSummary.textContent = stage.summary;
  }

  if (flowDetailTags) {
    flowDetailTags.innerHTML = "";
    stage.tags.forEach((tag) => {
      const tagElement = document.createElement("span");
      tagElement.className = "flow-tag";
      tagElement.textContent = tag;
      flowDetailTags.appendChild(tagElement);
    });
  }

  if (flowDetailFrom) {
    flowDetailFrom.textContent = stage.from;
  }

  if (flowDetailTo) {
    flowDetailTo.textContent = stage.to;
  }

  if (flowDetailImpact) {
    flowDetailImpact.textContent = stage.impact;
  }

  if (flowRuleCaption) {
    flowRuleCaption.textContent = stage.caption;
  }

  if (flowDetailRules) {
    flowDetailRules.innerHTML = "";

    stage.rules.forEach((rule) => {
      const card = document.createElement("article");
      card.className = "flow-rule-card";

      const head = document.createElement("div");
      head.className = "flow-rule-head";

      const title = document.createElement("strong");
      title.className = "flow-rule-title";
      title.textContent = rule.title;

      const badge = document.createElement("span");
      badge.className = "flow-rule-badge";
      badge.textContent = rule.badge;

      head.append(title, badge);

      const copy = document.createElement("div");
      copy.className = "flow-rule-copy";

      const when = document.createElement("p");
      when.innerHTML = `<strong>เมื่อ:</strong> ${rule.when}`;

      const action = document.createElement("p");
      action.innerHTML = `<strong>Store ทำ:</strong> ${rule.action}`;

      const impact = document.createElement("p");
      impact.innerHTML = `<strong>ผลต่อ flow:</strong> ${rule.impact}`;

      copy.append(when, action, impact);
      card.append(head, copy);
      flowDetailRules.appendChild(card);
    });
  }

  if (flowDetailPass) {
    flowDetailPass.textContent = stage.pass;
  }

  if (flowDetailNote) {
    flowDetailNote.textContent = stage.note;
  }

  if (flowDetailCodes) {
    flowDetailCodes.innerHTML = "";

    const codeRefs =
      workflowCodeLibrary[stageKey] ||
      (stage.codes || []).map((item) => ({
        label: item,
        ref: item,
        snippet: item,
      }));

    codeRefs.forEach((entry) => {
      const details = document.createElement("details");
      details.className = "code-dropdown";

      const summary = document.createElement("summary");

      const head = document.createElement("div");
      head.className = "code-dropdown-head";

      const label = document.createElement("span");
      label.className = "code-dropdown-label";
      label.textContent = entry.label;

      const ref = document.createElement("span");
      ref.className = "code-dropdown-ref";
      ref.textContent = entry.ref;

      head.append(label, ref);
      summary.appendChild(head);

      const snippetWrap = document.createElement("div");
      snippetWrap.className = "code-snippet-wrap";

      const snippet = document.createElement("pre");
      snippet.className = "code-snippet";
      snippet.textContent = entry.snippet;

      snippetWrap.appendChild(snippet);
      details.append(summary, snippetWrap);
      flowDetailCodes.appendChild(details);
    });
  }

  if (flowPrevButton) {
    flowPrevButton.disabled = stageIndex === 0;
  }

  if (flowNextButton) {
    flowNextButton.disabled = stageIndex === workflowOrder.length - 1;
  }

  flowDetail.classList.remove("is-refreshing");
  requestAnimationFrame(() => {
    flowDetail.classList.add("is-refreshing");
  });
}

function stepWorkflow(direction) {
  const currentIndex = workflowOrder.indexOf(activeWorkflowStage);
  if (currentIndex === -1) {
    return;
  }

  const nextIndex = Math.min(Math.max(currentIndex + direction, 0), workflowOrder.length - 1);
  renderWorkflowStage(workflowOrder[nextIndex]);
}

function setActiveSlide(id) {
  slides.forEach((slide) => {
    const active = slide.id === id;
    slideDots
      .filter((dot) => dot.dataset.target === slide.id)
      .forEach((dot) => dot.classList.toggle("is-active", active));
  });

  const activeSlide = slides.find((slide) => slide.id === id);
  if (activeSlide && currentSlideLabel) {
    currentSlideLabel.textContent = activeSlide.dataset.label || activeSlide.id;
  }
}

function setOverviewPanel(panelKey) {
  overviewTabs.forEach((tab) => {
    const active = tab.dataset.panel === panelKey;
    tab.classList.toggle("is-active", active);
    tab.setAttribute("aria-selected", String(active));
  });

  overviewTabPanels.forEach((panel) => {
    const active = panel.id === `overview-panel-${panelKey}`;
    panel.classList.toggle("is-active", active);
    panel.hidden = !active;
  });
}

function getActiveSlideId() {
  return slideDots.find((dot) => dot.classList.contains("is-active"))?.dataset.target || slides[0]?.id;
}

const observer = new IntersectionObserver(
  (entries) => {
    const visibleEntry = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];

    if (visibleEntry) {
      setActiveSlide(visibleEntry.target.id);
    }
  },
  {
    root: slidesContainer,
    threshold: 0.6,
  },
);

slides.forEach((slide) => observer.observe(slide));

slideDots.forEach((dot) => {
  dot.addEventListener("click", (event) => {
    event.preventDefault();
    const targetId = dot.dataset.target;
    const targetSlide = document.querySelector(`#${targetId}`);
    targetSlide?.scrollIntoView({ behavior: "smooth", block: "start" });
  });
});

slidesContainer?.addEventListener(
  "scroll",
  () => {
    const currentScrollTop = slidesContainer.scrollTop;

    if (!frame) {
      lastScrollTop = currentScrollTop;
      return;
    }

    if (currentScrollTop <= 24) {
      frame.classList.remove("is-hidden");
      lastScrollTop = currentScrollTop;
      return;
    }

    const delta = currentScrollTop - lastScrollTop;

    if (delta > 10) {
      frame.classList.add("is-hidden");
    } else if (delta < -8) {
      frame.classList.remove("is-hidden");
    }

    lastScrollTop = currentScrollTop;
  },
  { passive: true },
);

window.addEventListener("keydown", (event) => {
  const activeIndex = slides.findIndex((slide) =>
    slideDots.some((dot) => dot.dataset.target === slide.id && dot.classList.contains("is-active")),
  );

  if (event.key === "ArrowDown" || event.key === "PageDown" || event.key === " ") {
    event.preventDefault();
    const nextSlide = slides[Math.min(activeIndex + 1, slides.length - 1)];
    nextSlide?.scrollIntoView({ behavior: "smooth", block: "start" });
    return;
  }

  if (event.key === "ArrowUp" || event.key === "PageUp") {
    event.preventDefault();
    const prevSlide = slides[Math.max(activeIndex - 1, 0)];
    prevSlide?.scrollIntoView({ behavior: "smooth", block: "start" });
    return;
  }

  if (getActiveSlideId() === "workflow" && (event.key === "ArrowLeft" || event.key === "[")) {
    event.preventDefault();
    stepWorkflow(-1);
    return;
  }

  if (getActiveSlideId() === "workflow" && (event.key === "ArrowRight" || event.key === "]")) {
    event.preventDefault();
    stepWorkflow(1);
  }
});

if (slides[0]) {
  setActiveSlide(slides[0].id);
}

overviewTabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    setOverviewPanel(tab.dataset.panel);
  });
});

flowChips.forEach((chip) => {
  chip.addEventListener("click", () => {
    const stageKey = chip.dataset.stage;
    renderWorkflowStage(stageKey);
  });
});

flowPrevButton?.addEventListener("click", () => stepWorkflow(-1));
flowNextButton?.addEventListener("click", () => stepWorkflow(1));

setOverviewPanel("business");
renderWorkflowStage("draft");
