const frame = document.querySelector(".frame");
const overviewTabs = [...document.querySelectorAll(".overview-tab")];
const overviewTabPanels = [...document.querySelectorAll(".overview-tab-panel")];
const backendRoleCodeTargets = [...document.querySelectorAll("[data-backend-code]")];
const developerCodeTargets = [...document.querySelectorAll("[data-developer-code]")];
const documentWorkflowSection = document.querySelector("#document-workflow");
const ndbsWorkflowSection = document.querySelector("#ndbs-workflow");
const systemWorkflowSection = document.querySelector("#system-workflow");
const systemFlowMap = document.querySelector("#system-flow-map");
const flowMap = document.querySelector("#flow-map");
const ndbsFlowMap = document.querySelector("#ndbs-flow-map");

const systemFlowChips = systemFlowMap ? [...systemFlowMap.querySelectorAll(".flow-chip")] : [];
const systemFlowConnectors = systemFlowMap ? [...systemFlowMap.querySelectorAll(".flow-connector")] : [];
const systemFlowDetail = document.querySelector("#system-flow-detail");
const systemFlowStagePosition = document.querySelector("#system-flow-stage-position");
const systemFlowStageCaption = document.querySelector("#system-flow-stage-caption");
const systemFlowPrevButton = document.querySelector("#system-flow-prev");
const systemFlowNextButton = document.querySelector("#system-flow-next");
const systemFlowDetailKicker = document.querySelector("#system-flow-detail-kicker");
const systemFlowDetailTitle = document.querySelector("#system-flow-detail-title");
const systemFlowDetailSummary = document.querySelector("#system-flow-detail-summary");
const systemFlowDetailTags = document.querySelector("#system-flow-detail-tags");
const systemFlowDetailFrom = document.querySelector("#system-flow-detail-from");
const systemFlowDetailTo = document.querySelector("#system-flow-detail-to");
const systemFlowDetailImpact = document.querySelector("#system-flow-detail-impact");
const systemFlowRuleCaption = document.querySelector("#system-flow-rule-caption");
const systemFlowDetailRules = document.querySelector("#system-flow-detail-rules");
const systemFlowDetailPass = document.querySelector("#system-flow-detail-pass");
const systemFlowDetailNote = document.querySelector("#system-flow-detail-note");
const systemFlowDetailCodes = document.querySelector("#system-flow-detail-codes");

const flowChips = flowMap ? [...flowMap.querySelectorAll(".flow-chip")] : [];
const flowConnectors = flowMap ? [...flowMap.querySelectorAll(".flow-connector")] : [];
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

const ndbsFlowChips = ndbsFlowMap ? [...ndbsFlowMap.querySelectorAll(".flow-chip")] : [];
const ndbsFlowConnectors = ndbsFlowMap ? [...ndbsFlowMap.querySelectorAll(".flow-connector")] : [];
const ndbsFlowDetail = document.querySelector("#ndbs-flow-detail");
const ndbsFlowStagePosition = document.querySelector("#ndbs-flow-stage-position");
const ndbsFlowStageCaption = document.querySelector("#ndbs-flow-stage-caption");
const ndbsFlowPrevButton = document.querySelector("#ndbs-flow-prev");
const ndbsFlowNextButton = document.querySelector("#ndbs-flow-next");
const ndbsFlowDetailKicker = document.querySelector("#ndbs-flow-detail-kicker");
const ndbsFlowDetailTitle = document.querySelector("#ndbs-flow-detail-title");
const ndbsFlowDetailSummary = document.querySelector("#ndbs-flow-detail-summary");
const ndbsFlowDetailTags = document.querySelector("#ndbs-flow-detail-tags");
const ndbsFlowDetailFrom = document.querySelector("#ndbs-flow-detail-from");
const ndbsFlowDetailTo = document.querySelector("#ndbs-flow-detail-to");
const ndbsFlowDetailImpact = document.querySelector("#ndbs-flow-detail-impact");
const ndbsFlowRuleCaption = document.querySelector("#ndbs-flow-rule-caption");
const ndbsFlowDetailRules = document.querySelector("#ndbs-flow-detail-rules");
const ndbsFlowDetailPass = document.querySelector("#ndbs-flow-detail-pass");
const ndbsFlowDetailNote = document.querySelector("#ndbs-flow-detail-note");
const ndbsFlowDetailCodes = document.querySelector("#ndbs-flow-detail-codes");

const workflowOrder = ["draft", "pr", "po", "ap", "je", "final"];
const ndbsWorkflowOrder = ["entry", "route", "reserve", "actual", "reverse", "finalize"];
const systemWorkflowOrder = ["engine", "update", "recalc", "writeback", "commit"];
let activeSystemWorkflowStage = systemWorkflowOrder[0];
let activeWorkflowStage = workflowOrder[0];
let activeNdbsWorkflowStage = ndbsWorkflowOrder[0];
let lastScrollTop = 0;

const systemWorkflowData = {
  engine: {
    status: "Continue from Budget Engine",
    kicker: "Stage 1",
    title: "Finalize จาก Budget Engine",
    summary:
      "ส่วนนี้เริ่มต่อจาก Budget Engine โดยตรง หลัง route ของเอกสารจบแล้ว ระบบจะ cleanup movement ที่ต้องปิด และเตรียมส่งต่อไปยังตัวคำนวณยอดคงเหลือ",
    from: "Budget Engine",
    to: "NDBS_UpdateBudgetAmount",
    impact: "ถ้าจุดนี้ไม่วิ่งต่อ movement อาจถูกเขียนแล้ว แต่ยอดคงเหลือของงบจะยังไม่ sync ตามเอกสารล่าสุด",
    pass: "ทุกเส้นทางหลักจะพา budgetgroup, year และ department หรือ project ไปให้ NDBS_UpdateBudgetAmount คำนวณต่อ",
    note: "นี่คือจุดต่อจาก section Budget Engine โดยตรง ไม่ได้ย้อนกลับไปเริ่มที่ SAP Event เหมือนโครงเดิม",
    caption: "3 เรื่องที่เกิดขึ้นทันทีหลัง Budget Engine จบ route ของเอกสาร",
    tags: ["ต่อจาก Budget Engine", "Finalize", "ส่งต่อยอดคงเหลือ"],
    rules: [
      {
        title: "เรียกตัวคำนวณหลัง movement เปลี่ยน",
        badge: "Call helper",
        when: "หลัง reserve, actual, reverse, cancel หรือ close ของเอกสารถูกเขียนลง ledger แล้ว",
        action: "engine จะเรียก NDBS_UpdateBudgetAmount พร้อม budget group, ปีงบ และรหัสฝ่ายหรือโครงการ",
        impact: "ยอดคงเหลือจะไม่ค้างอยู่ที่ movement อย่างเดียว แต่ถูกส่งไปคำนวณต่อทันที",
      },
      {
        title: "cleanup movement ที่ไม่ควรค้าง",
        badge: "Cleanup",
        when: "ปิด route ของเอกสารหรือปิด PO แล้วมี movement ที่หักกลับจนเหลือ 0",
        action: "engine ลบแถวที่ Amount = 0 ออกจาก ledger ก่อนปล่อยงานต่อ",
        impact: "ledger จะไม่ค้างแถวศูนย์ที่รบกวนการอ่านและคำนวณยอดรอบถัดไป",
      },
      {
        title: "runtime และ rebuild ลงมาจุดเดียวกัน",
        badge: "Shared path",
        when: "ไม่ว่าจะมาจาก flow ปกติหรือ flow สร้างย้อนหลัง",
        action: "สุดท้ายทุกเส้นจะกลับมาพึ่งตัวคำนวณยอดคงเหลือตัวเดียวกัน",
        impact: "จุดนี้เป็นคอขวดสำคัญของความถูกต้องของงบทั้งระบบ",
      },
    ],
  },
  update: {
    status: "Update Helper",
    kicker: "Stage 2",
    title: "เข้า NDBS_UpdateBudgetAmount",
    summary:
      "ชั้นนี้รับค่าที่ Budget Engine ส่งมา แล้วแยกว่าจะคำนวณฝั่ง department หรือ project ตาม budgettype ที่ถูกส่งเข้า procedure",
    from: "Budget Engine หรือ NDBS_BUDGET_PR",
    to: "ชั้นคำนวณยอด reserve และ actual",
    impact: "ถ้าค่า budgetgroup, year หรือ typecode ผิด จะทำให้ไปอัปเดตงบผิดก้อนหรือไม่โดนก้อนที่ควรโดน",
    pass: "procedure รู้ทันทีว่าควรอ่าน ledger ฝั่ง OBDE หรือ OBPE เพื่อรวมยอดใหม่",
    note: "4 input หลักของ procedure นี้คือ budgetgroup, budgetyear, budgettype และ budgettypecode",
    caption: "3 หน้าที่หลักของ helper ตัวนี้ก่อนเริ่มรวมยอดจริง",
    tags: ["Helper", "Department / Project", "shared service"],
    rules: [
      {
        title: "รับ key ของงบที่ต้องคำนวณ",
        badge: "4 inputs",
        when: "Budget Engine ส่งค่าหลัง movement ของเอกสารเปลี่ยน",
        action: "procedure รับ budget group, budget year, ประเภทงบ และรหัสฝ่ายหรือโครงการที่ต้องอัปเดต",
        impact: "ระบบคำนวณเฉพาะก้อนงบที่ได้รับผลจาก transaction นั้น ไม่ต้องไล่ทั้งระบบทุกครั้ง",
      },
      {
        title: "เลือกทาง department หรือ project",
        badge: "D / P",
        when: "budgettype ถูกส่งมาเป็น D หรือ P",
        action: "ถ้าเป็น D จะอ่าน OBDE กับ BDPL ถ้าเป็น P จะอ่าน OBPE กับ BPJL",
        impact: "งบของฝ่ายและงบของโครงการจึงถูกคำนวณแยกกันชัดเจน",
      },
      {
        title: "เป็น helper กลางของหลาย procedure",
        badge: "Shared entry",
        when: "ถูกเรียกจาก Budget Engine, PR route หรือ rebuild",
        action: "ใช้ procedure เดียวกันเพื่อจบงานเรื่องยอดคงเหลือ",
        impact: "ถ้าจุดนี้มี bug ผลจะกระทบทั้ง runtime และ rebuild พร้อมกัน",
      },
    ],
  },
  recalc: {
    status: "Recalculate Totals",
    kicker: "Stage 3",
    title: "รวมยอด Reserve และ Actual จาก Ledger",
    summary:
      "เมื่อเข้า helper แล้ว ระบบจะรวมยอดที่กันไว้และยอดที่ใช้จริงจาก ledger โดยตัด movement ที่ถูกยกเลิกออกจากการคำนวณ",
    from: "NDBS_UpdateBudgetAmount",
    to: "ชั้นเขียนกลับ budget master",
    impact: "ถ้ายอดรวมสองก้อนนี้ผิด ยอดคงเหลือที่ผู้ใช้เห็นจะเพี้ยนทันที แม้ movement แต่ละแถวจะถูกต้อง",
    pass: "ได้ยอด reserve และ actual ล่าสุดของก้อนงบนั้น เพื่อใช้เขียนกลับไปยัง master detail",
    note: "ระบบอ่านจาก OBDE เมื่อเป็นฝ่าย และจาก OBPE เมื่อเป็นโครงการ โดยใช้ BudgetStatus <> 'C' เป็นตัวกรอง",
    caption: "3 เรื่องที่ helper ใช้ตัดสินยอดล่าสุดของงบ",
    tags: ["Reserve", "Actual", "Ledger sums"],
    rules: [
      {
        title: "รวมยอดที่กันไว้",
        badge: "BudgetType R",
        when: "ต้องการรู้ว่าก้อนงบนั้นมีวงเงินถูกกันอยู่เท่าไร",
        action: "SUM Amount ของ movement ที่เป็น reserve และยังไม่ถูกยกเลิก",
        impact: "ระบบเห็นว่ายอดใดถูกจองไว้ก่อนใช้จริงแล้ว",
      },
      {
        title: "รวมยอดที่ใช้จริง",
        badge: "BudgetType A",
        when: "ต้องการรู้ว่าก้อนงบนั้นถูกใช้จริงไปแล้วเท่าไร",
        action: "SUM Amount ของ movement ที่เป็น actual และยังไม่ถูกยกเลิก",
        impact: "ระบบเห็นการใช้จริงของงบหลัง PO, GRPO, AP, APCN หรือ JE",
      },
      {
        title: "กันค่า null ไม่ให้เพี้ยน",
        badge: "Null safe",
        when: "ไม่พบ movement บางประเภทในก้อนงบนั้น",
        action: "ตั้ง NetReserve หรือ NetActual เป็น 0 ก่อนคำนวณต่อ",
        impact: "งบที่ยังไม่มี movement บางด้านจะไม่กลายเป็นค่า null และทำให้ยอดคงเหลือเพี้ยน",
      },
    ],
  },
  writeback: {
    status: "Write Back to Budget Master",
    kicker: "Stage 4",
    title: "เขียนยอดกลับ Budget Master",
    summary:
      "หลังรวมยอดเสร็จ ระบบจะเขียนยอดกันงบ ยอดใช้จริง ยอดรวม และยอดคงเหลือกลับไปที่ budget master detail ของฝ่ายหรือโครงการนั้นทันที",
    from: "ยอด reserve และ actual ล่าสุด",
    to: "BDPL / BPJL และแถวที่ยังไม่เคยมี U_BudgetRem",
    impact: "นี่คือจุดที่ผู้ใช้ปลายทางจะเห็นยอดคงเหลือบนหน้าจอ ถ้าเขียนผิด ความเข้าใจงบของทั้งองค์กรจะผิดตาม",
    pass: "master detail ถูกอัปเดตแล้ว และ helper จะ sync แถวที่ U_BudgetRem ยังเป็น null เพิ่มเติมก่อนคืนผล",
    note: "ในไฟล์ปัจจุบันมี loop ปิดท้ายสำหรับไล่ซ่อมแถวที่ U_BudgetRem ยังเป็น null ทั้งฝั่ง department และ project",
    caption: "3 งานที่ชั้นนี้ทำก่อนคืนผลออกจาก helper",
    tags: ["Write back", "Budget Master", "Remaining"],
    rules: [
      {
        title: "อัปเดตงบของฝ่าย",
        badge: "BDPL",
        when: "budgettype เป็น D",
        action: "เขียน U_BudgetRes, U_BudgetAct, U_BudgetBal และ U_BudgetRem กลับไปยังตาราง BDPL ของฝ่ายนั้น",
        impact: "ผู้ใช้ฝั่ง department เห็นยอดงบที่ sync กับ movement ล่าสุด",
      },
      {
        title: "อัปเดตงบของโครงการ",
        badge: "BPJL",
        when: "budgettype เป็น P",
        action: "เขียน 4 ค่าหลักกลับไปยังตาราง BPJL ของโครงการนั้น",
        impact: "งบโครงการแสดงยอดคงเหลือตามการจอง ใช้จริง หรือคืนงบล่าสุด",
      },
      {
        title: "ไล่ sync แถวที่ยังไม่มี U_BudgetRem",
        badge: "Repair loop",
        when: "ยังมี master detail บางแถวที่ U_BudgetRem เป็น null",
        action: "helper จะวนซ้ำคำนวณและอัปเดตแถวนั้นให้ครบทั้งฝั่ง department และ project",
        impact: "ช่วยให้ข้อมูลเก่าที่ไม่สมบูรณ์ถูกดึงกลับมาอยู่ในรูปแบบเดียวกับแถวปกติ",
      },
    ],
  },
  commit: {
    status: "Return to SAP",
    kicker: "Stage 5",
    title: "ส่งผลกลับ SAP แล้วจบ Transaction",
    summary:
      "เมื่อคำนวณและเขียนกลับเสร็จแล้ว ระบบจะคืนค่า error และข้อความกลับไปให้ SAP จากนั้น SAP จะตัดสินใจเองว่าจะบันทึกเอกสารหรือ block ผู้ใช้ไว้",
    from: "Budget master ที่อัปเดตแล้ว",
    to: "Document saved หรือ blocked in SAP",
    impact: "นี่คือจุดสุดท้ายที่ผู้ใช้เห็นผลลัพธ์จริง ว่าเอกสารผ่าน budget control หรือถูกหยุดไว้ให้แก้ไข",
    pass: "ถ้า error ยังเป็น 0 เอกสารถูกบันทึกพร้อมงบที่อัปเดตแล้ว ถ้ามี error SAP จะหยุด transaction ทันที",
    note: "ในไฟล์ SQL ไม่มีคำสั่ง COMMIT ตรง ๆ เพราะ SAP B1 ใช้ค่าที่ procedure คืนกลับไปตัดสินใจเรื่องการบันทึก transaction",
    caption: "2 ผลลัพธ์สุดท้ายหลัง helper คืนค่ากลับระบบ",
    tags: ["Return", "Commit", "Block"],
    rules: [
      {
        title: "คืนผลลัพธ์กลับจาก stored procedure",
        badge: "error / message",
        when: "Budget Engine และตัวคำนวณยอดทำงานครบแล้ว",
        action: "Transaction Notification ส่งค่า error และ error_message กลับออกไปที่ SAP",
        impact: "SAP ใช้ค่านี้เป็นคำตอบสุดท้ายว่าจะยอมให้เอกสารผ่านหรือไม่",
      },
      {
        title: "SAP ตัดสินใจบันทึกหรือ block",
        badge: "Save / Stop",
        when: "ค่าที่คืนกลับมาเป็น 0 หรือไม่เป็น 0",
        action: "ถ้าไม่มี error เอกสารถูกบันทึก ถ้ามี error ผู้ใช้จะเห็นข้อความและต้องกลับไปแก้ข้อมูล",
        impact: "นี่คือปลายทางของ flow ทั้งระบบตั้งแต่เอกสารถูกตรวจจนงบถูกอัปเดต",
      },
    ],
  },
};

const workflowData = {
  draft: {
    status: "Draft Pre-check",
    kicker: "Stage 1",
    title: "Draft",
    summary:
      "Draft ถูกคุมเฉพาะในด่านตรวจข้อมูลต้นทาง เพื่อกันเอกสารที่ข้อมูลยังไม่พร้อม ไม่ให้ถูกใช้เป็นฐานของเอกสารจริงตั้งแต่ต้นทาง",
    from: "ผู้ใช้เริ่มกรอก Draft ของ PR / PO / AP / APCN",
    to: "PR / PO / AP / APCN ฉบับจริง",
    impact: "ถ้า Draft ไม่ผ่าน จะยังไม่เกิดเอกสารจริงและยังไม่เข้าด่านคุมงบขั้นสุดท้าย",
    pass: "เมื่อผ่านแล้ว Draft พร้อมให้เปิดต่อเป็นเอกสารจริงตาม flow ธุรกิจ แต่ยังไม่มีการจองงบหรือตัดงบใด ๆ เกิดขึ้น",
    note: "Draft อยู่ในด่านตรวจข้อมูลต้นทางล้วน ๆ และยังไม่มีการเขียน movement ลง ledger ให้ Draft โดยตรง",
    caption: "4 จุดที่ Draft ถูก block ตั้งแต่ก่อนเกิดเอกสารจริง",
    tags: ["ด่านตรวจข้อมูลต้นทาง", "Draft only", "ยังไม่ถึงด่านคุมงบ"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "Draft ของ PR/PO ที่ item เป็น non-inventory และ item group เปิด budget control แต่ OcrCode ว่าง",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และส่งข้อความ ISS รบกวนใส่ฝ่าย",
        impact: "Draft นี้ยังไม่พร้อมใช้เป็นฐานของ PR หรือ PO",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 100",
        when: "Draft ของ PR/PO/AP/APCN ที่ U_NDBS_BudgetYear ว่าง",
        action: "ด่านตรวจข้อมูลต้นทาง block ด้วยข้อความ ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "ผู้ใช้ยังเก็บ Draft ที่พร้อมใช้ต่อไม่ได้",
      },
      {
        title: "ไม่มี budget ตามฝ่าย",
        badge: "Error 105",
        when: "Draft ของ PR/PO ที่ไม่มี Project และหา budget ตามปีงบ + group account + department ไม่เจอ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 105 และแจ้ง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "ร่างยังไม่ผ่านประตู budget ตั้งแต่ต้นทาง",
      },
      {
        title: "ไม่มี budget ตาม Project",
        badge: "Error 209",
        when: "Draft ที่มี Project แต่ไม่พบ project budget หรือ budget amount เป็น 0",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 209 และแจ้ง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "Draft สาย project จะไม่ไปต่อจนกว่าจะผูกงบ project ถูกต้อง",
      },
    ],
  },
  pr: {
    status: "PR Gate",
    kicker: "Stage 2",
    title: "PR",
    summary:
      "PR คือคำขอใช้เงินต้นทาง ด่านหน้าใน Transaction Notification จะเช็กความครบของข้อมูลก่อน และมี procedure แยกชื่อ NDBS_BUDGET_PR สำหรับลง movement ของ PR โดยเฉพาะ",
    from: "Draft หรือการเปิด PR ตรง",
    to: "Approval / PO",
    impact: "ถ้า PR ไม่ผ่าน จะหยุดที่คำขอและยังไม่มีฐานให้ PO อ้างอิงต่อ",
    pass: "เมื่อผ่านด่านต้นทางแล้ว PR พร้อมเข้าสู่ approval และเป็นฐานให้ PO ส่วนถ้า route เข้าถึง NDBS_BUDGET_PR ได้ ระบบจะเริ่มลง movement ของ PR และคำนวณยอดคงเหลือต่อ",
    note: "จากไฟล์ปัจจุบัน NDBS_BUDGET_PR มี logic พร้อมใช้งาน แต่ทางเข้าจาก NDBS_BUDGET_CONTROL ยังควรรีบยืนยัน เพราะ outer IF ไม่รวม object_type ของ PR",
    caption: "4 จุด block ของ PR และ 1 จุดเสี่ยงของเส้นทาง PR ในชั้นคุมงบ",
    tags: ["Transaction Notification", "NDBS_BUDGET_PR", "ก่อน PO"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "บรรทัด PR ที่เป็น non-inventory ไม่มี OcrCode",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนใส่ฝ่าย",
        impact: "PR ยังไม่พร้อมเข้าสู่ approval",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 101",
        when: "บรรทัด PR ที่เป็น non-inventory ไม่มี U_NDBS_BudgetYear",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 101 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "คำขอใช้เงินยังไม่อยู่ในกรอบ budget year ที่ระบบยอมรับ",
      },
      {
        title: "ไม่มีงบตามฝ่าย",
        badge: "Error 501",
        when: "PR ไม่มี Project แต่หา budget ตามปีงบ + account group + department ไม่เจอ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 501 และแสดง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "PR ยังไม่สามารถใช้เป็นฐานของ PO ได้",
      },
      {
        title: "ไม่มีงบตาม Project",
        badge: "Error 203",
        when: "PR มี Project แต่หา project budget ไม่เจอหรือ budget amount เป็น 0",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 203 และแสดง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "PR สาย project จะหยุดที่ชั้นนี้จนกว่าจะมี budget setup รองรับ",
      },
      {
        title: "Final layer ของ PR ดูเหมือนยังไม่ถูกเรียก",
        badge: "Urgent finding",
        when: "NDBS_BUDGET_CONTROL เปิด outer IF แค่ 30, 22, 21, 20, 18, 19 แต่ด้านในยังมี if object_type = 1470000113",
        action: "Call NDBS_BUDGET_PR อาจไม่ถูกเข้าถึงจริง",
        impact: "PR อาจผ่านแค่ด่านต้นทาง แต่ไม่ถูกคุมด้วย logic ขั้นสุดท้ายตามที่ตั้งใจ",
      },
    ],
  },
  po: {
    status: "PO Gate",
    kicker: "Stage 3",
    title: "PO",
    summary:
      "PO เป็นจุดที่เริ่มจองงบจริง หลังผ่านด่านตรวจข้อมูลต้นทางแล้ว ด่านคุมงบขั้นสุดท้ายจะเขียน reserve movement ลง ledger และอัปเดตงบคงเหลือ",
    from: "PR",
    to: "GRPO / AP / APCN",
    impact: "ถ้า PO ถูก block จะยังไม่มีฐานให้ GRPO หรือ AP อ้างอิง และถ้าโดน block ในชั้นคุมงบ reserve ก็จะไม่ถูกบันทึก",
    pass: "เมื่อผ่าน PO จะเริ่มสร้าง reserve movement ด้วย BudgetType = 'R' ใน OBDE หรือ OBPE แล้วพร้อมไหลไปขั้นถัดไป",
    note: "PO close และ line close มี logic คืนงบด้วย amount ติดลบ ส่วนฝั่ง project มี over-budget block ชัดเจน แต่ฝั่ง department มีบรรทัด block ถูก comment ไว้",
    caption: "5 จุดตรวจต้นทาง และ 1 จุด block ในด่านคุมงบขั้นสุดท้ายของ PO",
    tags: ["ด่านต้นทาง + ด่านคุมงบ", "Reserve budget", "ก่อน GRPO/AP"],
    rules: [
      {
        title: "ไม่มีฝ่าย",
        badge: "Error 100",
        when: "บรรทัด PO ที่เป็น non-inventory ไม่มี OcrCode",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนใส่ฝ่าย",
        impact: "PO ไม่ผ่านตั้งแต่ข้อมูลความรับผิดชอบของงบ",
      },
      {
        title: "ไม่มีปีงบ",
        badge: "Error 102",
        when: "บรรทัด PO ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 102 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "PO ยังไม่พร้อมใช้เป็นเอกสารอ้างอิงต่อ",
      },
      {
        title: "ไม่มีงบตามฝ่าย",
        badge: "Error 100",
        when: "PO ไม่มี Project แต่หา budget ตามปีงบ + account group + department ไม่เจอ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบงบประมาณ",
        impact: "PO ยังไม่ผ่านประตู budget ฝั่ง department",
      },
      {
        title: "ไม่มีงบตาม Project",
        badge: "Error 202",
        when: "PO มี Project แต่หา project budget ไม่เจอหรือ budget amount เป็น 0",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 202 และแสดง ISS รบกวนตรวจสอบงบประมาณProject",
        impact: "PO ที่ใช้ project จะหยุดตรงนี้ทันที",
      },
      {
        title: "ปีงบไม่ตรงรูปแบบ",
        badge: "Error 301",
        when: "ค่า U_NDBS_BudgetYear ของ PO ไม่ขึ้นต้นตามรูปแบบที่ script ยอมรับ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 301 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "แม้จะมี budget setup อยู่แล้ว แต่รูปแบบปีงบผิดก็ยังบันทึก PO ไม่ได้",
      },
      {
        title: "Project over budget ในด่านคุมงบขั้นสุดท้าย",
        badge: "Error -32",
        when: "PO ผ่านด่านต้นทางแล้ว แต่ path ฝั่ง project มี budget available น้อยกว่ายอดที่จะ reserve",
        action: "ด่านคุมงบขั้นสุดท้ายตั้ง error = -32 และส่งข้อความ Project ... Over budget",
        impact: "PO ถูกหยุดในชั้น reserve แม้ผ่านด่านต้นทางมาแล้ว",
      },
    ],
  },
  ap: {
    status: "AP / APCN Gate",
    kicker: "Stage 4",
    title: "AP / APCN",
    summary:
      "A/P Invoice และ A/P Credit Memo เป็นชั้นรับรู้เจ้าหนี้และกลับรายการ หลังผ่านด่านตรวจข้อมูลต้นทางแล้ว ด่านคุมงบขั้นสุดท้ายจะเปลี่ยน reserve เป็น actual หรือ reverse movement เดิม",
    from: "PO / GRPO / supplier document",
    to: "Budget ledger และบัญชีปลายทาง",
    impact: "ถ้า AP/APCN ไม่ผ่าน จะยังไม่รับรู้เจ้าหนี้หรือกลับรายการ และ movement งบจะไม่ถูกอัปเดตตามเอกสารนั้น",
    pass: "เมื่อผ่านด่านคุมงบขั้นสุดท้าย ระบบจะ mark movement เดิมเป็น A หรือ C แล้วเขียน movement ใหม่เพื่อสะท้อน actual usage หรือ reversal",
    note: "A/P Invoice กับ APCN ไม่ถูกคุมเหมือนกันทั้งหมด: APCN ไม่มี rule format ปีงบในด่านต้นทาง และ project path ของ APCN มีเงื่อนไข Project ที่ควรรีบแก้",
    caption: "3 จุด block ในด่านต้นทาง และ 1 จุดเสี่ยงในด่านคุมงบขั้นสุดท้ายของ AP / APCN",
    tags: ["ด่านต้นทาง + ด่านคุมงบ", "Actual / Reverse", "ขั้นเจ้าหนี้"],
    rules: [
      {
        title: "A/P Invoice ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด A/P Invoice ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "ยังไม่รับรู้เจ้าหนี้จากเอกสารนั้น",
      },
      {
        title: "A/P Invoice ปีงบไม่ตรงรูปแบบ",
        badge: "Error 302",
        when: "U_NDBS_BudgetYear ของ A/P Invoice มีค่าน้อยกว่ากรอบปีที่ script ยอมรับ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 302 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "แม้เอกสารต้นทางผ่านมาแล้ว A/P Invoice ก็ยังถูก block ได้",
      },
      {
        title: "A/P Credit Memo ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด A/P Credit Memo ไม่มี U_NDBS_BudgetYear และ item group เปิด budget control",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "การกลับรายการฝั่งเจ้าหนี้ยังไม่สามารถบันทึกได้",
      },
      {
        title: "Project condition ของ APCN เสี่ยงเข้าทางผิด",
        badge: "High risk",
        when: "project path ของ APCN ใช้เงื่อนไข IF (Project IS NOT NULL) OR (Project != '')",
        action: "ด่านคุมงบขั้นสุดท้ายอาจเข้า logic ฝั่ง project แม้ค่า project ไม่สมบูรณ์",
        impact: "เสี่ยง update หรือ reverse movement ผิดเส้นทางของเอกสาร",
      },
    ],
  },
  je: {
    status: "JE Gate",
    kicker: "Stage 5",
    title: "JE",
    summary:
      "JE อาจเข้ามาโดยไม่ผ่าน flow จัดซื้อ แต่ยังถูกคุมปีงบในด่านตรวจข้อมูลต้นทาง และเมื่อผ่านแล้วด่านคุมงบขั้นสุดท้ายจะลง actual movement ตรงเข้าสมุดงบ",
    from: "AP / APCN หรือ manual JE",
    to: "General ledger และ budget ledger",
    impact: "ถ้า JE ไม่ผ่าน จะยังไม่ถูก post เข้า ledger และงบจะยังไม่ถูกตัดจริง",
    pass: "เมื่อผ่านด่านคุมงบขั้นสุดท้าย ระบบจะ insert actual movement ด้วย BudgetType = 'A' ลง OBDE หรือ OBPE และ recalc งบคงเหลือทันที",
    note: "ด่านตรวจข้อมูลต้นทางไม่ได้เช็ก budget ตามฝ่ายหรือ project สำหรับ JE เหมือน PR/PO แต่ด่านคุมงบขั้นสุดท้ายจะเป็นชั้นที่ขยับงบจริง",
    caption: "2 จุด block ของ JE ก่อน post และ 1 การขยับงบหลังผ่าน",
    tags: ["ด่านต้นทาง + ด่านคุมงบ", "Actual posting", "ปลายทางบัญชี"],
    rules: [
      {
        title: "ไม่มีปีงบ",
        badge: "Error 100",
        when: "บรรทัด JE ไม่มี U_NDBS_BudgetYear",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 100 และแสดง ISS รบกวนตรวจสอบปีงบประมาณ",
        impact: "JE ยังไม่ถูก post เข้า ledger",
      },
      {
        title: "ปีงบไม่ตรงรูปแบบ",
        badge: "Error 303",
        when: "U_NDBS_BudgetYear ของ JE ต่ำกว่ากรอบปีที่ script ยอมรับ",
        action: "ด่านตรวจข้อมูลต้นทางตั้ง error = 303 และแสดง ISS รบกวนตรวจสอบ Budget Year",
        impact: "JE ถูกหยุดแม้จะเป็นการลงบัญชีตรงโดยไม่ผ่าน PR หรือ PO",
      },
      {
        title: "ผ่านแล้วลง actual ทันที",
        badge: "Final movement",
        when: "JE ผ่านด่านต้นทางและไม่มี error จากขั้นก่อนหน้า",
        action: "ด่านคุมงบขั้นสุดท้าย insert movement ใหม่ลง OBDE/OBPE และเรียก NDBS_UpdateBudgetAmount",
        impact: "งบคงเหลือถูกปรับตาม JE ทันทีหลังบันทึก",
      },
    ],
  },
  final: {
    status: "Final Control",
    kicker: "Stage 6",
    title: "Final Control",
    summary:
      "ด่านคุมงบขั้นสุดท้ายไม่ใช่แค่ตัวเช็ก แต่เป็น procedure ที่เขียน movement งบ ยกเลิก movement เดิม อัปเดตยอดคงเหลือ และ block บางกรณีก่อน commit transaction",
    from: "เอกสารที่ผ่านด่านตรวจข้อมูลต้นทาง และเอกสาร downstream เช่น GRPO / Goods Return",
    to: "NDBS_BGC_OBDE / NDBS_BGC_OBPE / transaction commit",
    impact: "ถึงด่านต้นทางจะผ่าน ถ้าด่านคุมงบขั้นสุดท้ายเจอ error หรือ logic ผิด เอกสารก็ยังไม่ commit",
    pass: "เมื่อไม่มี error ด่านคุมงบขั้นสุดท้ายจะเขียน movement ตามสถานะเอกสาร อัปเดตยอดคงเหลือผ่าน NDBS_UpdateBudgetAmount และลบแถว Amount = 0 ก่อนจบ",
    note: "ตอนนี้ flow หลักชัดเจนแล้วว่า Transaction Notification เรียก NDBS_BUDGET_CONTROL แล้วค่อยให้ NDBS_UpdateBudgetAmount ปรับยอดคงเหลือ ส่วน PR ยังควรรีบตรวจเรื่อง route เข้าถึง",
    caption: "5 เรื่องที่ด่านคุมงบขั้นสุดท้ายทำจริงกับงบ และ 1 จุด block สำคัญที่ยัง active อยู่",
    tags: ["ด่านคุมงบขั้นสุดท้าย", "Reserve / Actual / Reverse", "ก่อน commit"],
    rules: [
      {
        title: "เขียน log ก่อนเข้ากระบวนการ",
        badge: "Store log",
        when: "error จากชั้นแรกยังเป็น 0",
        action: "procedure insert ข้อมูลเข้า NDBS_STORE_TABLE ก่อนเริ่ม branch ตาม object type",
        impact: "มี trace ว่า transaction ไหนถูกส่งเข้าด่านคุมงบขั้นสุดท้าย",
      },
      {
        title: "เขียน movement ลง 2 ledger",
        badge: "OBDE / OBPE",
        when: "เอกสารผ่าน branch ที่เกี่ยวข้องกับ department หรือ project",
        action: "insert / update movement ลง NDBS_BGC_OBDE หรือ NDBS_BGC_OBPE พร้อม BudgetStatus เช่น I, A, C",
        impact: "งบถูกแปลงเป็น reserve, actual หรือ cancellation ตามสถานะเอกสารจริง",
      },
      {
        title: "อัปเดตงบคงเหลือทุกครั้ง",
        badge: "Recalculate",
        when: "หลังมี movement ใหม่หรือมีการกลับสถานะ movement เดิม",
        action: "เรียก NDBS_UpdateBudgetAmount ซ้ำตาม budget group, year และ department/project ที่เกี่ยวข้อง",
        impact: "งบคงเหลือใน master ถูกปรับตามธุรกรรมล่าสุด",
      },
      {
        title: "Project over budget ยัง block อยู่จริง",
        badge: "Error -32",
        when: "project path ของ PO reserve แล้ว budget available ไม่พอ",
        action: "procedure ส่ง error = -32 และข้อความ Project ... Over budget กลับออกมา",
        impact: "เอกสารถูกหยุดที่ด่านสุดท้าย แม้ผ่านด่านต้นทางมาแล้ว",
      },
      {
        title: "ปิดเอกสารแล้วคืนงบและล้างแถวศูนย์",
        badge: "Close / Cleanup",
        when: "PO close, line close, cancel หรือ reversal จบแล้ว",
        action: "insert amount ติดลบเพื่อคืนงบ และลบแถวใน OBDE / OBPE ที่ Amount = 0",
        impact: "ledger ของงบไม่ค้างยอดที่ไม่ควรมีหลังเอกสารถูกปิดหรือย้อนกลับ",
      },
    ],
  },
};

const systemWorkflowCodeLibrary = {
  engine: [
    {
      label: "Budget Engine ส่งต่อเข้า helper คำนวณยอด",
      ref: "NDBS_BUDGET_CONTROL.sql:538, 601, 1499-1510, 2238-2308",
      snippet: `Call NDBS_UpdateBudgetAmount(:OldGroup,:OldYear,'D',:OldDept);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);

INSERT INTO "NDBS_BGC_OBPE" (...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBPE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');`,
    },
    {
      label: "ล้าง movement ที่ Amount = 0 ก่อนจบ",
      ref: "NDBS_BUDGET_CONTROL.sql:2313-2314",
      snippet: `DELETE FROM NDBS_BGC_OBPE WHERE "Amount"=0;
DELETE FROM NDBS_BGC_OBDE WHERE "Amount"=0;`,
    },
  ],
  update: [
    {
      label: "โครง procedure ของ NDBS_UpdateBudgetAmount",
      ref: "NDBS_UpdateBudgetAmount.sql:1-16",
      snippet: `CREATE PROCEDURE NDBS_UpdateBudgetAmount
(
  in budgetgroup nvarchar(50),
  in budgetyear nvarchar(50),
  in budgettype nvarchar(50),
  in budgettypecode nvarchar(50)
)
...
If :budgettype = 'D' Then`,
    },
    {
      label: "เลือกทาง Department หรือ Project",
      ref: "NDBS_UpdateBudgetAmount.sql:16-17, 36-37",
      snippet: `If :budgettype = 'D' Then
  ...
else
  ...
end if;`,
    },
  ],
  recalc: [
    {
      label: "รวมยอด Reserve และ Actual ฝั่ง Department",
      ref: "NDBS_UpdateBudgetAmount.sql:16-31",
      snippet: `Select SUM(IFNULL("Amount",0)) INTO NetReserve
From "NDBS_BGC_OBDE"
WHERE "Department" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear
AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';

Select SUM(IFNULL("Amount",0)) INTO NetActual
From "NDBS_BGC_OBDE"
WHERE "Department" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear
AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';`,
    },
    {
      label: "รวมยอด Reserve และ Actual ฝั่ง Project",
      ref: "NDBS_UpdateBudgetAmount.sql:37-50",
      snippet: `Select SUM(IFNULL("Amount",0)) INTO NetReserve
From "NDBS_BGC_OBPE"
WHERE "Project" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear
AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';

Select SUM(IFNULL("Amount",0)) INTO NetActual
From "NDBS_BGC_OBPE"
WHERE "Project" = :budgettypecode AND "BudgetGroup" = :budgetgroup AND "BudgetYear" = :budgetyear
AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';`,
    },
  ],
  writeback: [
    {
      label: "เขียนยอดกลับ budget master",
      ref: "NDBS_UpdateBudgetAmount.sql:32-35, 52-55",
      snippet: `Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
    "U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
    "U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
WHERE "Code" = :budgetyear AND "U_GroupCode" = :budgetgroup AND "U_Department" = :budgettypecode;

Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), "U_BudgetAct" = IFNULL(:NetActual,0),
    "U_BudgetBal" = IFNULL(:NetReserve,0)+IFNULL(:NetActual,0),
    "U_BudgetRem" = IFNULL("U_BudgetAmt",0) - (IFNULL(:NetReserve,0)+IFNULL(:NetActual,0))
WHERE "Code" = :budgetyear AND "U_GroupCode" = :budgetgroup AND "U_Project" = :budgettypecode;`,
    },
    {
      label: "loop sync แถวที่ U_BudgetRem ยังเป็น null",
      ref: "NDBS_UpdateBudgetAmount.sql:58-104",
      snippet: `for currloop as loopbudgetdept do
  ...
  Update "@NDBS_BGC_BDPL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), ...
  WHERE "Code" = currloop."Code" AND "U_GroupCode" = currloop."U_GroupCode" AND "U_Department" = currloop."U_Department";
end for;

for currloop as loopbudgetproj do
  ...
  Update "@NDBS_BGC_BPJL" Set "U_BudgetRes" = IFNULL(:NetReserve,0), ...
  WHERE "Code" = currloop."Code" AND "U_GroupCode" = currloop."U_GroupCode" AND "U_Project" = currloop."U_Project";
end for;`,
    },
  ],
  commit: [
    {
      label: "คืนผลกลับจาก Transaction Notification ไปยัง SAP",
      ref: "SBO_SP_TransactionNotification.sql:1105-1112",
      snippet: `if :error = 0 then
  call NDBS_BUDGET_CONTROL (:object_type,:transaction_type,:list_of_cols_val_tab_del,:error,:error_message);
end if;

select :error, :error_message FROM dummy;`,
    },
  ],
};

const workflowCodeLibrary = {
  draft: [
    {
      label: "ไม่มีฝ่าย | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:717-736",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt
  from ODRF t0
  left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
  left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
  LEFT JOIN OITB I2 ON I1."ItmsGrpCod"=I2."ItmsGrpCod"
  where IFNULL(t1."OcrCode",'')=''
    and T0."ObjType" IN ('1470000049','22')
    and IFNULL(I1."InvntItem",'N')='N'
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:742-760",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt1
  from ODRF t0
  left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
  where T0."ObjType" IN ('1470000049','22','18','19')
    and IFNULL(t1."U_NDBS_BudgetYear",0)=0;

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 105",
      ref: "SBO_SP_TransactionNotification.sql:767-805",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A') Then
  ...
  where T0."ObjType" IN ('1470000113','22')
    and IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and T4."U_BGwithinbg" = 'Y';

  If :cnt > 0 Then
    error := 105;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 209",
      ref: "SBO_SP_TransactionNotification.sql:901-936",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and T4."U_BGwithinbg" = 'Y';

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
      ref: "SBO_SP_TransactionNotification.sql:565-583",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPRQ t0
  left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
  left join OITM I1 ON T1."ItemCode" = I1."ItemCode"
  where IFNULL(t1."OcrCode",'')=''
    and IFNULL(I1."InvntItem",'N')='N';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 101",
      ref: "SBO_SP_TransactionNotification.sql:585-602",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPRQ t0
  left join PRQ1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0;

  If :cnt > 0 Then
    error := 101;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 501",
      ref: "SBO_SP_TransactionNotification.sql:857-893",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A') Then
  ...
  where IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and T4."U_BGwithinbg" = 'Y';

  If :cnt > 0 Then
    error := 501;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 203",
      ref: "SBO_SP_TransactionNotification.sql:986-1020",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and T4."U_BGwithinbg" = 'Y';

  If :cnt > 0 Then
    error := 203;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
  End If;
End If;`,
    },
    {
      label: "PR final call ดูเหมือนเข้าไม่ถึง",
      ref: "NDBS_BUDGET_CONTROL.sql:483-491",
      snippet: `Insert Into NDBS_STORE_TABLE
Values
(:object_type,:transaction_type,:error,'',:datakey);

if :error = 0 then
  IF ( :object_type in ('30','22','21','20','18','19')) then
    if ( :object_type = '1470000113') then
      Call NDBS_BUDGET_PR (:object_type,:transaction_type,:datakey,:error,:error_message);
    end if;
  end if;
end if;`,
    },
  ],
  po: [
    {
      label: "ไม่มีฝ่าย | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:605-623",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."OcrCode",'')=''
    and IFNULL(I1."InvntItem",'N')='N';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนใส่ฝ่าย';
  End If;
End If;`,
    },
    {
      label: "ไม่มีปีงบ | Error 102",
      ref: "SBO_SP_TransactionNotification.sql:626-645",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and IFNULL(I2."U_NTT_CtrlBG",'N')='Y';

  If :cnt > 0 Then
    error := 102;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตามฝ่าย | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:814-850",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A') Then
  ...
  where IFNULL(T1."Project",'') = ''
    and IFNULL(T1."OcrCode",'') <> ''
    and ifnull(B."U_BudgetAmt",0) = 0
    and T4."U_BGwithinbg" = 'Y';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "ไม่มีงบตาม Project | Error 202",
      ref: "SBO_SP_TransactionNotification.sql:945-979",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A') Then
  ...
  where ifnull(B."U_BudgetAmt",0) = 0
    and IFNULL(T1."Project",'') <> ''
    and T4."U_BGwithinbg" = 'Y';

  If :cnt > 0 Then
    error := 202;
    error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
  End If;
End If;`,
    },
    {
      label: "Budget Year ไม่ตรงรูปแบบ | Error 301",
      ref: "SBO_SP_TransactionNotification.sql:1027-1056",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  select count(t0."DocEntry") into cnt
  from OPOR t0
  left join POR1 t1 on t0."DocEntry" = t1."DocEntry"
  where LEFT(T1."U_NDBS_BudgetYear",3) <> '202';

  If :cnt > 0 Then
    error := 301;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
    {
      label: "ผ่านแล้วจองงบฝั่ง Department | OBDE",
      ref: "NDBS_BUDGET_CONTROL.sql:530-601",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
("DocEntry","BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
 "BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
 "PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);

Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);`,
    },
    {
      label: "Department over budget ถูก comment ไว้",
      ref: "NDBS_BUDGET_CONTROL.sql:603-614",
      snippet: `else
  --GUN 20260321 -- error= -32;
  --error_message = 'Department '+ :BDept+' ...';
  --GUN 20260321 -- error_message = CONCAT(CONCAT('Department ',:BDept),'Over budget');
end if;`,
    },
    {
      label: "Project over budget | Error -32",
      ref: "NDBS_BUDGET_CONTROL.sql:1379-1416",
      snippet: `else
  error = -32;
  error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget');
end if;`,
    },
    {
      label: "PO close คืนงบและอัปเดต remaining",
      ref: "NDBS_BUDGET_CONTROL.sql:2244-2308",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBPE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');

Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);

INSERT INTO "NDBS_BGC_OBDE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBDE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');`,
    },
  ],
  ap: [
    {
      label: "A/P Invoice ไม่มีปีงบ | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:648-669",
      snippet: `IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPCH t0
  left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and T0."CANCELED"='N';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "A/P Credit Memo ไม่มีปีงบ | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:672-692",
      snippet: `IF :object_type ='19' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from ORPC t0
  left join RPC1 t1 on t0."DocEntry" = t1."DocEntry"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and T0."CANCELED"='N';

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "A/P Invoice ปีงบไม่ตรงรูปแบบ | Error 302",
      ref: "SBO_SP_TransactionNotification.sql:1064-1082",
      snippet: `IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."DocEntry") Into cnt
  from OPCH t0
  left join PCH1 t1 on t0."DocEntry" = t1."DocEntry"
  where LEFT(T1."U_NDBS_BudgetYear",4) < '2024'
    AND T0."CANCELED"='N';

  If :cnt > 0 Then
    error := 302;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
    {
      label: "ผ่านแล้วแปลง Reserve เป็น Actual",
      ref: "NDBS_BUDGET_CONTROL.sql:1588-1640",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:OldGroup,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
 '18',:DocKey,:DocLine,-:OldAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,'18',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);`,
    },
    {
      label: "APCN project condition ใช้ OR",
      ref: "NDBS_BUDGET_CONTROL.sql:2014-2050",
      snippet: `IF IsCancelled = 'C' then
  for currloop as loopcncancel do
    IF (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
      ...
    end if;
  end for;
else
  ...
  if (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
    ...
  end if;
end if;`,
    },
  ],
  je: [
    {
      label: "ไม่มีปีงบ | Error 100",
      ref: "SBO_SP_TransactionNotification.sql:696-714",
      snippet: `IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."TransId") Into cnt
  from OJDT t0
  left join JDT1 t1 on t0."TransId" = t1."TransId"
  where IFNULL(t1."U_NDBS_BudgetYear",0)=0
    and T0."TransType" IN ('30');

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
    {
      label: "Budget Year ไม่ตรงรูปแบบ | Error 303",
      ref: "SBO_SP_TransactionNotification.sql:1086-1103",
      snippet: `IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  SELECT count(t0."TransId") Into cnt
  from OJDT t0
  left join JDT1 t1 on t0."TransId" = t1."TransId"
  where LEFT(T1."U_NDBS_BudgetYear",4) < '2024';

  If :cnt > 0 Then
    error := 303;
    error_message := 'ISS รบกวนตรวจสอบ Budget Year';
  End If;
End If;`,
    },
    {
      label: "ผ่านแล้วลง Actual ใน ledger",
      ref: "NDBS_BUDGET_CONTROL.sql:1248-1260",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
("DocEntry","BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
 "BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
 "PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,
 '',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);

Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);`,
    },
  ],
  final: [
    {
      label: "ด่านต้นทางเรียก procedure ขั้นสุดท้าย",
      ref: "SBO_SP_TransactionNotification.sql:1105-1106",
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
    {
      label: "เข้าด่านคุมงบขั้นสุดท้ายแล้ว log ก่อน",
      ref: "NDBS_BUDGET_CONTROL.sql:483-489",
      snippet: `Insert Into NDBS_STORE_TABLE
Values
(:object_type,:transaction_type,:error,'',:datakey);

if :error = 0 then
  IF ( :object_type in ('30','22','21','20','18','19')) then
    ...
  end if;
end if;`,
    },
    {
      label: "เขียน movement ลง Department ledger",
      ref: "NDBS_BUDGET_CONTROL.sql:530-601",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);

Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);`,
    },
    {
      label: "Project over budget | Error -32",
      ref: "NDBS_BUDGET_CONTROL.sql:1379-1416",
      snippet: `else
  error = -32;
  error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget');
end if;`,
    },
    {
      label: "ปิดเอกสารแล้วคืนงบ",
      ref: "NDBS_BUDGET_CONTROL.sql:2244-2308",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBPE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');

INSERT INTO "NDBS_BGC_OBDE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBDE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');`,
    },
    {
      label: "ล้างแถว Amount = 0 ก่อนจบ",
      ref: "NDBS_BUDGET_CONTROL.sql:2313-2314",
      snippet: `DELETE FROM NDBS_BGC_OBPE WHERE "Amount"=0;
DELETE FROM NDBS_BGC_OBDE WHERE "Amount"=0;`,
    },
  ],
};

const ndbsWorkflowData = {
  entry: {
    status: "Entry Log",
    kicker: "Stage 1",
    title: "Receive Transaction",
    summary:
      "หลังด่านตรวจข้อมูลต้นทางปล่อยผ่านมาแล้ว procedure นี้จะรับ object_type, transaction_type และ datakey เข้ามาเพื่อเริ่มด่านคุมงบขั้นสุดท้าย",
    from: "ด่านตรวจข้อมูลต้นทาง",
    to: "route ตาม object type",
    impact: "ถ้าด่านต้นทางไม่ผ่าน ขั้นนี้จะไม่ถูกเรียกเลย",
    pass: "transaction ถูก log และเข้าสู่ branch ของเอกสารที่รองรับ",
    note: "นี่คือจุดเริ่มต้นของด่านคุมงบขั้นสุดท้าย ก่อนมี reserve, actual หรือ reverse movement เกิดขึ้นจริง",
    caption: "2 เรื่องแรกที่ procedure ทำทันทีหลังถูกเรียก",
    tags: ["เริ่มด่านคุมงบ", "NDBS_STORE_TABLE", "ก่อน route"],
    rules: [
      {
        title: "รับ transaction จากด่านต้นทาง",
        badge: "Procedure call",
        when: "ด่านตรวจข้อมูลต้นทางเช็กแล้ว error ยังเป็น 0",
        action: "ด่านต้นทางเรียก procedure ขั้นสุดท้ายพร้อม object_type, transaction_type และ datakey",
        impact: "เฉพาะเอกสารที่ผ่านชั้นแรกเท่านั้นจึงเข้าสู่ชั้นนี้",
      },
      {
        title: "เขียน log ก่อนทำงานต่อ",
        badge: "Store log",
        when: "procedure เริ่มทำงาน",
        action: "insert ข้อมูลเข้า NDBS_STORE_TABLE เพื่อ trace transaction ที่เข้ามา",
        impact: "ทีม support สามารถตามดูได้ว่า transaction ไหนถูกส่งเข้าด่านคุมงบขั้นสุดท้าย",
      },
    ],
  },
  route: {
    status: "Branch Routing",
    kicker: "Stage 2",
    title: "Route by Object Type",
    summary:
      "procedure จะเลือก branch ตาม object_type และแยก path ระหว่าง department กับ project เพื่อพาเอกสารเข้า logic ที่เกี่ยวข้อง",
    from: "Entry log",
    to: "Reserve / Actual / Reverse paths",
    impact: "ถ้า route ผิดหรือ branch เข้าไม่ถึง movement งบจะไม่ถูกสร้างหรือถูกสร้างผิดเส้นทาง",
    pass: "แต่ละบรรทัดของเอกสารจะถูกส่งเข้าฝั่ง department หรือ project ตามข้อมูลจริง",
    note: "จากโค้ดปัจจุบัน outer IF รองรับ 30, 22, 21, 20, 18, 19 ชัดเจน ส่วน PR ยังมีความเสี่ยงว่าถูกเรียกไม่ถึง",
    caption: "3 เรื่องที่ตัดสินว่า transaction จะไปทางไหนต่อ",
    tags: ["Routing", "Department / Project", "Cursor based"],
    rules: [
      {
        title: "เลือก branch ตาม object type",
        badge: "22 / 18 / 19 / 20 / 21 / 30",
        when: "object_type อยู่ในกลุ่มที่ outer IF รองรับ",
        action: "procedure เปิด cursor และเข้า logic ของเอกสารแต่ละประเภท",
        impact: "เอกสารแต่ละชนิดถูกคุมด้วย movement logic ไม่เหมือนกัน",
      },
      {
        title: "แยก path ระหว่าง department กับ project",
        badge: "OBDE / OBPE",
        when: "บรรทัดเอกสารมี Project หรือไม่มี Project",
        action: "ไม่มี Project จะเข้า OBDE ส่วนมี Project จะเข้า OBPE",
        impact: "งบถูกขยับคนละ ledger ตามโครงสร้างงบที่ใช้จริง",
      },
      {
        title: "APCN project path มีเงื่อนไขเสี่ยง",
        badge: "High risk",
        when: "branch ของ APCN ฝั่ง project ใช้ IF (Project IS NOT NULL) OR (Project != '')",
        action: "อาจเข้า path ฝั่ง project แม้ค่า project ไม่สมบูรณ์",
        impact: "เสี่ยง reverse หรือ update งบผิด branch",
      },
    ],
  },
  reserve: {
    status: "Reserve Budget",
    kicker: "Stage 3",
    title: "Create Reserve Movement",
    summary:
      "PO และบาง path ที่เกี่ยวข้องจะสร้าง reserve movement ด้วย BudgetType = 'R' ลง OBDE หรือ OBPE แล้ว recalculation งบคงเหลือทันที",
    from: "Route by object type",
    to: "Actual usage / Close / Cancel",
    impact: "ถ้า reserve ไม่ผ่าน transaction จะไม่สามารถจองงบไว้ให้เอกสารนั้นได้",
    pass: "เมื่อผ่าน reserve ยอดคงเหลือจะถูกอัปเดตและเอกสารพร้อมไปสู่ขั้น downstream",
    note: "project side ยัง block over budget อยู่จริง แต่ department side มีบรรทัด block ถูก comment ออก",
    caption: "3 เรื่องหลักของช่วงที่เริ่มจองงบจริง",
    tags: ["BudgetType = R", "PO reserve", "ก่อน actual"],
    rules: [
      {
        title: "จองงบฝั่ง Department",
        badge: "OBDE",
        when: "บรรทัด PO ไม่มี Project",
        action: "insert movement ใหม่ลง NDBS_BGC_OBDE พร้อม BudgetType = 'R' และ BudgetStatus = 'I'",
        impact: "ยอดงบของฝ่ายนั้นถูกกันไว้สำหรับเอกสาร PO",
      },
      {
        title: "จองงบฝั่ง Project",
        badge: "OBPE",
        when: "บรรทัด PO มี Project",
        action: "insert reserve movement ลง NDBS_BGC_OBPE แล้วเรียก NDBS_UpdateBudgetAmount",
        impact: "ยอดงบของ project ถูกกันไว้เพื่อรอ actual usage",
      },
      {
        title: "Project over budget ยัง block",
        badge: "Error -32",
        when: "budget available ฝั่ง project น้อยกว่ายอดที่จะ reserve",
        action: "ด่านคุมงบขั้นสุดท้ายส่ง error = -32 และข้อความ Project ... Over budget",
        impact: "PO ถูกหยุดในด่านคุมงบขั้นสุดท้ายทันที",
      },
    ],
  },
  actual: {
    status: "Actual Usage",
    kicker: "Stage 4",
    title: "Create Actual Movement",
    summary:
      "A/P Invoice และ JE จะเปลี่ยน reserve เดิมให้เป็น actual หรือ insert actual movement ใหม่โดยตรง เพื่อสะท้อนการใช้เงินจริง",
    from: "Reserve path หรือ route โดยตรง",
    to: "Reverse / Finalize",
    impact: "ถ้า actual movement เขียนผิด งบใช้จริงจะคลาดเคลื่อนทันที",
    pass: "เมื่อผ่าน actual งบ used/remaining จะถูกปรับตามเอกสารที่ลงจริง",
    note: "A/P Invoice บาง path แปลง reserve เดิมเป็น actual ส่วน JE จะลง actual ตรงลง ledger",
    caption: "3 รูปแบบที่ procedure ใช้ทำ actual movement",
    tags: ["BudgetType = A", "AP Invoice", "JE"],
    rules: [
      {
        title: "A/P Invoice แปลง reserve เดิมเป็น actual",
        badge: "Reserve -> Actual",
        when: "AP อ้างอิงมาจาก PO หรือ GRPO",
        action: "procedure เขียน movement ติดลบเพื่อปิด reserve เดิม แล้ว insert movement ใหม่ด้วย BudgetType = 'A'",
        impact: "งบเปลี่ยนจากสถานะกันไว้เป็นการใช้จริง",
      },
      {
        title: "JE ลง actual ตรง",
        badge: "Direct actual",
        when: "JE ผ่านด่านต้นทางแล้วเข้าด่านคุมงบขั้นสุดท้าย",
        action: "insert movement ใหม่ลง OBDE หรือ OBPE ด้วย BudgetType = 'A'",
        impact: "manual JE กระทบงบจริงทันทีโดยไม่ต้องมี PO มาก่อน",
      },
      {
        title: "อัปเดตงบคงเหลือหลัง actual",
        badge: "Recalculate",
        when: "หลัง insert actual movement หรือเปลี่ยนสถานะ movement เดิม",
        action: "เรียก NDBS_UpdateBudgetAmount ตาม budget group, year และ owner งบ",
        impact: "budget remaining ถูก sync กับการใช้จริงล่าสุด",
      },
    ],
  },
  reverse: {
    status: "Reverse / Cancel",
    kicker: "Stage 5",
    title: "Reverse and Return Budget",
    summary:
      "เมื่อเกิด APCN, cancel, close หรือ line close procedure จะ mark movement เดิมและเขียน amount ติดลบเพื่อคืนงบหรือกลับรายการ",
    from: "Reserve หรือ Actual",
    to: "Finalize",
    impact: "ถ้า reverse ผิด งบคงเหลือจะสูงหรือต่ำกว่าความจริงและตามเอกสารย้อนหลังยาก",
    pass: "เมื่อ reverse สำเร็จ งบที่กันไว้หรือใช้ไปจะถูกคืนหรือปรับกลับตามเอกสารนั้น",
    note: "PO close และ line close ใช้การรวมยอด movement เดิมแล้ว insert กลับด้วย amount ติดลบ ส่วน APCN ยังมีความเสี่ยงจากเงื่อนไข project",
    caption: "3 กรณีหลักที่ procedure ใช้คืนงบหรือกลับรายการ",
    tags: ["Cancel", "Close", "Negative amount"],
    rules: [
      {
        title: "A/P Credit Memo และ cancel path",
        badge: "Status C / A",
        when: "เอกสารถูกยกเลิกหรือเป็นการกลับรายการ",
        action: "update BudgetStatus ของ movement เดิม และ recalculation งบของ line นั้น",
        impact: "ยอดคงเหลือถูกคืนกลับตามรายการที่ถูกยกเลิก",
      },
      {
        title: "PO close คืน reserve ด้วย amount ติดลบ",
        badge: "Negative movement",
        when: "PO หรือ line ของ PO ถูกปิด",
        action: "insert movement ใหม่โดยใช้ -SUM(Amount) จากรายการ reserve/actual เดิม",
        impact: "งบที่กันไว้แต่ไม่ได้ใช้ถูกคืนกลับไปที่ budget remaining",
      },
      {
        title: "APCN project branch ยังเสี่ยง",
        badge: "High risk",
        when: "Project condition ใช้ OR แทน AND",
        action: "procedure อาจ reverse movement ในฝั่ง project แม้ข้อมูล project ไม่ครบ",
        impact: "งบ project อาจถูกคืนหรือปรับผิดบรรทัด",
      },
    ],
  },
  finalize: {
    status: "Finalize and Cleanup",
    kicker: "Stage 6",
    title: "Finalize Procedure",
    summary:
      "เมื่อแต่ละ branch ทำ movement เสร็จ procedure จะ cleanup ข้อมูลที่เป็นศูนย์และจบด้วยสถานะ commit หรือ error กลับไปยัง transaction",
    from: "Actual / Reverse / Recalculate",
    to: "Commit หรือ Block",
    impact: "ถ้ายังมี error transaction จะไม่ commit แม้ movement บางส่วนจะเริ่มประมวลผลแล้ว",
    pass: "เมื่อไม่มี error transaction จะ commit พร้อม ledger ที่ถูก cleanup แล้ว",
    note: "จากโค้ดปัจจุบัน explicit error ที่เห็นชัดที่สุดยังเป็น project over-budget ส่วนตอนจบมีการลบแถว Amount = 0 ทั้งสอง ledger",
    caption: "3 เรื่องสุดท้ายก่อน procedure จบการทำงาน",
    tags: ["Cleanup", "Amount = 0", "Commit / Error"],
    rules: [
      {
        title: "Recalculate ถูกเรียกซ้ำหลายจุด",
        badge: "UpdateBudgetAmount",
        when: "ทุกครั้งที่มี insert หรือ update movement สำคัญ",
        action: "procedure เรียก NDBS_UpdateBudgetAmount เพื่อ sync ยอดคงเหลือใน master",
        impact: "budget remaining ถูกปรับให้ตาม state ล่าสุดของเอกสาร",
      },
      {
        title: "ลบแถวที่ amount เป็นศูนย์",
        badge: "Cleanup",
        when: "จบทุก branch แล้ว",
        action: "DELETE FROM NDBS_BGC_OBPE WHERE Amount = 0 และ DELETE FROM NDBS_BGC_OBDE WHERE Amount = 0",
        impact: "ledger ไม่ค้างรายการที่ไม่มีผลต่อยอด",
      },
      {
        title: "ส่งผลลัพธ์กลับ transaction",
        badge: "Commit / Block",
        when: "procedure ทำงานครบทุกช่วงแล้ว",
        action: "ถ้ามี error จะ block transaction ถ้าไม่มี error transaction จึง commit ได้",
        impact: "ด่านคุมงบขั้นสุดท้ายเป็นประตูสุดท้ายก่อนเอกสารถูกบันทึกจริงใน SAP B1",
      },
    ],
  },
};

const ndbsWorkflowCodeLibrary = {
  entry: [
    {
      label: "ด่านต้นทางเรียก procedure ขั้นสุดท้าย",
      ref: "SBO_SP_TransactionNotification.sql:1105-1106",
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
    {
      label: "เข้า procedure แล้วเขียน log",
      ref: "NDBS_BUDGET_CONTROL.sql:483-489",
      snippet: `Insert Into NDBS_STORE_TABLE
Values
(:object_type,:transaction_type,:error,'',:datakey);

if :error = 0 then
  ...
end if;`,
    },
  ],
  route: [
    {
      label: "Outer IF และ PR branch ที่น่าสงสัย",
      ref: "NDBS_BUDGET_CONTROL.sql:486-491",
      snippet: `if :error = 0 then
  IF ( :object_type in ('30','22','21','20','18','19')) then
    if ( :object_type = '1470000113') then
      Call NDBS_BUDGET_PR (:object_type,:transaction_type,:datakey,:error,:error_message);
    elseif ( :object_type = '22') then
      ...
    end if;
  end if;
end if;`,
    },
    {
      label: "APCN project condition ใช้ OR",
      ref: "NDBS_BUDGET_CONTROL.sql:2014-2050",
      snippet: `IF (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
  ...
end if;`,
    },
  ],
  reserve: [
    {
      label: "PO reserve ฝั่ง Department",
      ref: "NDBS_BUDGET_CONTROL.sql:530-601",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
("DocEntry","BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
 "BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
 "PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);

Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);`,
    },
    {
      label: "Department over budget ถูก comment",
      ref: "NDBS_BUDGET_CONTROL.sql:603-614",
      snippet: `else
  -- error = -32;
  -- error_message = CONCAT(CONCAT('Department ',:BDept),'Over budget');
end if;`,
    },
    {
      label: "Project over budget ยัง block",
      ref: "NDBS_BUDGET_CONTROL.sql:1379-1416",
      snippet: `else
  error = -32;
  error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget');
end if;`,
    },
  ],
  actual: [
    {
      label: "A/P Invoice แปลง reserve เป็น actual",
      ref: "NDBS_BUDGET_CONTROL.sql:1588-1640",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:OldGroup,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
 '18',:DocKey,:DocLine,-:OldAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,'18',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);`,
    },
    {
      label: "JE ลง actual ตรง",
      ref: "NDBS_BUDGET_CONTROL.sql:1248-1260",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
("DocEntry","BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
 "BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
 "PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,
 '',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);`,
    },
  ],
  reverse: [
    {
      label: "APCN cancel และ project path",
      ref: "NDBS_BUDGET_CONTROL.sql:2010-2055",
      snippet: `IF IsCancelled = 'C' then
  for currloop as loopcncancel do
    IF (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
      Update "NDBS_BGC_OBPE" Set "BudgetStatus" = 'C'
      Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey;
      ...
    end if;
  end for;
end if;`,
    },
    {
      label: "PO close คืนงบด้วยยอดติดลบ",
      ref: "NDBS_BUDGET_CONTROL.sql:2244-2308",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBPE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');

INSERT INTO "NDBS_BGC_OBDE"
(...)
select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
From NDBS_BGC_OBDE
Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');`,
    },
  ],
  finalize: [
    {
      label: "เรียก UpdateBudgetAmount ซ้ำหลายจุด",
      ref: "NDBS_BUDGET_CONTROL.sql:538, 601, 649, 1411, 1635, 2268, 2308",
      snippet: `Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);`,
    },
    {
      label: "ล้างแถว Amount = 0 ก่อนจบ",
      ref: "NDBS_BUDGET_CONTROL.sql:2313-2314",
      snippet: `DELETE FROM NDBS_BGC_OBPE WHERE "Amount"=0;
DELETE FROM NDBS_BGC_OBDE WHERE "Amount"=0;`,
    },
  ],
};

const backendRoleCodeLibrary = {
  draft: [
    {
      label: "เช็กฝ่ายและปีงบของ Draft",
      ref: "SBO_SP_TransactionNotification.sql:717-760",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."OcrCode",'')=''
  and T0."ObjType" IN ('1470000049','22')
  ...
  error := 100;
  error_message := 'ISS รบกวนใส่ฝ่าย';
End If;

IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and T0."ObjType" IN ('1470000049','22','18','19')
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 100;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;`,
    },
    {
      label: "เช็ก budget setup ของ Draft",
      ref: "SBO_SP_TransactionNotification.sql:767-809, 901-940",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' ) Then
  ...
  and T0."ObjType" IN ('1470000113','22')
  and IFNULL(T1."Project",'') = ''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 105;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
End If;

IF :object_type ='112' And (:transaction_type = 'A' ) Then
  ...
  and IFNULL(T1."Project",'')<>''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 209;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
End If;`,
    },
  ],
  pr: [
    {
      label: "เช็กข้อมูลต้นทางของ PR",
      ref: "SBO_SP_TransactionNotification.sql:565-602",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."OcrCode",'')=''
  ...
  error := 100;
  error_message := 'ISS รบกวนใส่ฝ่าย';
End If;

IF :object_type ='1470000113' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 101;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;`,
    },
    {
      label: "เช็ก budget setup ของ PR",
      ref: "SBO_SP_TransactionNotification.sql:857-897, 986-1024",
      snippet: `IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
  ...
  and IFNULL(T1."Project",'') = ''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 501;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
End If;

IF :object_type ='1470000113' And (:transaction_type = 'A' ) Then
  ...
  and IFNULL(T1."Project",'')<>''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 203;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
End If;`,
    },
    {
      label: "จุดที่ runtime ตั้งใจส่ง PR เข้า procedure แยก",
      ref: "NDBS_BUDGET_CONTROL.sql:487-491",
      snippet: `IF ( :object_type in ('30','22','21','20','18','19'/*,'1470000049'*/)) then
  if ( :object_type = '1470000113') then
    Call NDBS_BUDGET_PR (:object_type,:transaction_type,:datakey,:error,:error_message);
  elseif ( :object_type = '22') then
    ...
  end if;
end if;`,
    },
    {
      label: "movement ของ PR ใน NDBS_BUDGET_PR",
      ref: "NDBS_BUDGET_PR.sql:35-132",
      snippet: `for currloop as looppr do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    ...
    INSERT INTO "NDBS_BGC_OBDE" (...)
    VALUES
    (:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."OcrCode",
     '1470000113',currloop."DocEntry",currloop."LineNum",...,currloop."LineTotal",'R',currloop."DocDate",'I',...);
    Call NDBS_UpdateBudgetAmount(currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),'D',currloop."OcrCode");
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...)
    VALUES
    (:AutoKey,currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),currloop."Project",
     '1470000113',currloop."DocEntry",currloop."LineNum",...,currloop."LineTotal",'R',currloop."DocDate",'I',...);
    Call NDBS_UpdateBudgetAmount(currloop."Code",TO_NVARCHAR(currloop."U_NDBS_BudgetYear"),'P',currloop."Project");
  end if;
end for;`,
    },
  ],
  po: [
    {
      label: "เช็กฝ่ายและปีงบของ PO",
      ref: "SBO_SP_TransactionNotification.sql:604-645",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."OcrCode",'')=''
  ...
  error := 100;
  error_message := 'ISS รบกวนใส่ฝ่าย';
End If;

IF :object_type ='22' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 102;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;`,
    },
    {
      label: "เช็ก budget setup และรูปแบบปีงบของ PO",
      ref: "SBO_SP_TransactionNotification.sql:813-854, 944-983, 1026-1060",
      snippet: `IF :object_type ='22' And (:transaction_type = 'A' ) Then
  ...
  and IFNULL(T1."Project",'') = ''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 100;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณ';
End If;

IF :object_type ='22' And (:transaction_type = 'A' ) Then
  ...
  and IFNULL(T1."Project",'')<>''
  and ifnull(B."U_BudgetAmt",0) =0
  ...
  error := 202;
  error_message := 'ISS รบกวนตรวจสอบงบประมาณProject';
End If;

and LEFT(T1."U_NDBS_BudgetYear",3) <> '202'
...
error := 301;`,
    },
    {
      label: "PO กันงบฝั่งฝ่าย",
      ref: "NDBS_BUDGET_CONTROL.sql:542-601",
      snippet: `if(:transaction_type in ('U','A')) then
  ...
  IF ((:BAvailable+:BaseAmount) >= :LineAmount) OR (:BLocked = 'N') OR (:BNotChecked = 'Y') then
    INSERT INTO "NDBS_BGC_OBDE"
    ("DocEntry","BudgetGroup","BudgetYear","Department","ObjectType","ObjectID","ObjectLine",
     "BaseType","BaseID","BaseLine","Amount","BudgetType","ValueDate","BudgetStatus",
     "PrimaryObjectType","PrimaryObjectID","PrimaryObjectLine")
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,
     :BaseType,:BaseKey,:BaseLine,:BAmount,'R',:BValDate,'I','22',:DocKey,:DocLine);

    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
  end if;
end if;`,
    },
    {
      label: "PO กันงบฝั่งโครงการและ block ถ้างบไม่พอ",
      ref: "NDBS_BUDGET_CONTROL.sql:1353-1383",
      snippet: `if(:transaction_type in ('U','A')) then
  Select TOP 1 T0."U_BudgetRem" into BAvailable
  FROM "@NDBS_BGC_BPJL" T0
  WHERE T0."Code" = TO_NVARCHAR(:BYear) AND T0."U_GroupCode" = :BCode AND T0."U_Project" = :BProject;

  IF (:BAvailable >= :LineAmount) OR (:BLocked = 'N') OR (:BNotChecked = 'Y') then
    INSERT INTO "NDBS_BGC_OBPE" (...)
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,...,:BAmount,'R',:BValDate,'I',...);
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
  else
    error = -32;
    error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget');
  end if;
end if;`,
    },
    {
      label: "PO คืนงบตอนปิดเอกสารหรือปิดบรรทัด",
      ref: "NDBS_BUDGET_CONTROL.sql:2238-2308",
      snippet: `if ( :object_type = '22') then
  ...
  INSERT INTO "NDBS_BGC_OBPE" (...)
  select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
  From NDBS_BGC_OBPE
  Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');
  Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);

  INSERT INTO "NDBS_BGC_OBDE" (...)
  select ..., -SUM("Amount"), "BudgetType", "ValueDate", 'A'
  From NDBS_BGC_OBDE
  Where "ObjectType" = '22' AND "BudgetStatus" IN ('I','A');
  Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
end if;`,
    },
    {
      label: "PO ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:312-367",
      snippet: `for currloop as looppo do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...)
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'22',:DocKey,:DocLine,...,:BAmount,'R',:BValDate,'I',...,'Y','looppo');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...)
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'22',:DocKey,:DocLine,...,:BAmount,'R',:BValDate,'I',...,'Y','looppo');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
  end if;
end for;`,
    },
  ],
  grpo: [
    {
      label: "GRPO เปลี่ยนจากกันงบเป็นใช้จริงฝั่งฝ่าย",
      ref: "NDBS_BUDGET_CONTROL.sql:690-732",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
(...,"Amount","BudgetType","ValueDate","BudgetStatus",...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBDept,:BaseType,:BaseKey,:BaseLine,
 '20',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A','20',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:OldBDept);

INSERT INTO "NDBS_BGC_OBDE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'20',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','20',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);`,
    },
    {
      label: "GRPO เปลี่ยนจากกันงบเป็นใช้จริงฝั่งโครงการ",
      ref: "NDBS_BUDGET_CONTROL.sql:1493-1537",
      snippet: `INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
 '20',:DocKey,:DocLine,-:BaseAmount,'R',:BValDate,'A','20',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:OldBProject);

INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'20',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','20',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);`,
    },
    {
      label: "GRPO ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:371-424",
      snippet: `for currloop as loopgrn do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...)
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'20',:DocKey,:DocLine,...,:BAmount,'A',:BValDate,'I',...,'Y','loopgrn');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...)
    VALUES
    (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'20',:DocKey,:DocLine,...,:BAmount,'A',:BValDate,'I',...,'Y','loopgrn');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
  end if;
end for;`,
    },
  ],
  apinvoice: [
    {
      label: "เช็กปีงบของ A/P Invoice ก่อนเข้าด่านคุมงบ",
      ref: "SBO_SP_TransactionNotification.sql:647-669, 1063-1082",
      snippet: `IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 100;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;

IF :object_type ='18' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
  ...
  error := 302;
  error_message := 'ISS รบกวนตรวจสอบ Budget Year';
End If;`,
    },
    {
      label: "A/P Invoice ยกเลิก movement เดิมเมื่อ cancel",
      ref: "NDBS_BUDGET_CONTROL.sql:742-765, 1547-1570",
      snippet: `IF IsCancelled = 'C' then
  ...
  Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C'
  Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
  Call NDBS_UpdateBudgetAmount (:OldGroup,:OldYear,'D',:OldDept);

  Update "NDBS_BGC_OBPE" Set "BudgetStatus" = 'C'
  Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;
  Call NDBS_UpdateBudgetAmount (:OldGroup,:OldYear,'P',:OldDept);
end if;`,
    },
    {
      label: "A/P Invoice รับรู้ใช้จริงใน runtime",
      ref: "NDBS_BUDGET_CONTROL.sql:830-847, 1044-1063, 1618-1635, 1848-1855",
      snippet: `INSERT INTO "NDBS_BGC_OBDE" (...)
VALUES
(:AutoKey,:OldGroup,TO_NVARCHAR(:BYear),:OldDept,:BaseType,:BaseKey,:BaseLine,
 '18',:DocKey,:DocLine,-:OldAmount,'R',:BValDate,'A','18',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBDE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldDept,'18',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBPE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'18',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','18',:DocKey,:DocLine);`,
    },
    {
      label: "A/P Invoice ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:428-599",
      snippet: `for currloop as loopinv1 do
  INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'18',...,'A',...,'loopinv1');
  Call NDBS_UpdateBudgetAmount(...);
end for;

for currloop as loopinv2 do
  INSERT INTO "NDBS_BGC_OBDE" / "NDBS_BGC_OBPE" (...) VALUES (...,'18',...,'A',...,'loopinv2');
  Call NDBS_UpdateBudgetAmount(...);
end for;

for currloop as loopinv3 do
  INSERT INTO "NDBS_BGC_OBDE" / "NDBS_BGC_OBPE" (...) VALUES (...,'18',...,'A',...,'loopinv3');
  Call NDBS_UpdateBudgetAmount(...);
end for;`,
    },
  ],
  goodsreturn: [
    {
      label: "Goods Return ปรับยอดใช้จริงใน runtime",
      ref: "NDBS_BUDGET_CONTROL.sql:1071-1103, 1863-1892",
      snippet: `INSERT INTO "NDBS_BGC_OBDE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'21',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','21',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);

INSERT INTO "NDBS_BGC_OBPE"
(...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'21',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,:BAmount,'A',:BValDate,'I','21',:DocKey,:DocLine);
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);`,
    },
    {
      label: "Goods Return ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:603-658",
      snippet: `for currloop as loopreturn do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'21',...,'A',...,'Y','loopreturn');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...) VALUES (...,'21',...,'A',...,'Y','loopreturn');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
  end if;
end for;`,
    },
  ],
  apcreditmemo: [
    {
      label: "เช็กปีงบของ A/P Credit Memo ก่อนเข้าด่านคุมงบ",
      ref: "SBO_SP_TransactionNotification.sql:671-692",
      snippet: `IF :object_type ='19' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 100;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;`,
    },
    {
      label: "A/P Credit Memo คืนงบฝั่งฝ่าย",
      ref: "NDBS_BUDGET_CONTROL.sql:1115-1219",
      snippet: `Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C'
Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;

INSERT INTO "NDBS_BGC_OBDE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBDept,:BaseType,:BaseKey,:BaseLine,
 '19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','19',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBDE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'19',:DocKey,:DocLine,
 :BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);`,
    },
    {
      label: "A/P Credit Memo คืนงบฝั่งโครงการ",
      ref: "NDBS_BUDGET_CONTROL.sql:2014-2125",
      snippet: `IF (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
  Update "NDBS_BGC_OBPE" Set "BudgetStatus" = 'C'
  Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;

  INSERT INTO "NDBS_BGC_OBPE" (...)
  VALUES
  (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:OldBProject,:BaseType,:BaseKey,:BaseLine,
   '19',:DocKey,:DocLine,-:BaseAmount,'A',:BValDate,'A','19',:DocKey,:DocLine);

  INSERT INTO "NDBS_BGC_OBPE" (...)
  VALUES
  (:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'19',:DocKey,:DocLine,
   :BaseType,:BaseKey,:BaseLine,-:BAmount,'A',:BValDate,'I','19',:DocKey,:DocLine);
end if;`,
    },
    {
      label: "A/P Credit Memo ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:661-768",
      snippet: `for currloop as loopcn1 do
  INSERT INTO "NDBS_BGC_OBDE" / "NDBS_BGC_OBPE" (...) VALUES (...,'19',...,-:BAmount,'A',...,'Y','loopcn1');
  Call NDBS_UpdateBudgetAmount(...);
end for;

for currloop as loopcn2 do
  INSERT INTO "NDBS_BGC_OBDE" / "NDBS_BGC_OBPE" (...) VALUES (...,'19',...,-:BAmount,'A',...,'Y','loopcn2');
  Call NDBS_UpdateBudgetAmount(...);
end for;`,
    },
  ],
  je: [
    {
      label: "เช็กปีงบของ JE ก่อนเข้าด่านคุมงบ",
      ref: "SBO_SP_TransactionNotification.sql:695-714, 1085-1103",
      snippet: `IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...
  error := 100;
  error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
End If;

IF :object_type ='30' And (:transaction_type = 'A' OR :transaction_type = 'U') Then
  ...
  and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'
  ...
  error := 303;
  error_message := 'ISS รบกวนตรวจสอบ Budget Year';
End If;`,
    },
    {
      label: "JE ลง actual ใน runtime",
      ref: "NDBS_BUDGET_CONTROL.sql:1249-1260, 2175-2186",
      snippet: `if (:transaction_type IN ('U')) THEN
  Update "NDBS_BGC_OBDE" Set "BudgetStatus" = 'C'
  Where "ObjectType" = '30' AND "ObjectID"= :DocKey AND "ObjectLine" = :DocLine;
end if;

INSERT INTO "NDBS_BGC_OBDE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BDept,'30',:DocKey,:DocLine,'',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);

INSERT INTO "NDBS_BGC_OBPE" (...)
VALUES
(:AutoKey,:BCode,TO_NVARCHAR(:BYear),:BProject,'30',:DocKey,:DocLine,'',0,0,:BAmount,'A',:BValDate,'I','30',:DocKey,:DocLine);`,
    },
    {
      label: "JE ใน flow rebuild ย้อนหลัง",
      ref: "NDBS_BUDGET_BEGINING.sql:771-826",
      snippet: `for currloop as loopje do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'30',...,:BAmount,'A',...,'Y','loopje');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...) VALUES (...,'30',...,:BAmount,'A',...,'Y','loopje');
    Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);
  end if;
end for;`,
    },
  ],
  rebuild: [
    {
      label: "cursor ที่ใช้ไล่เอกสารใน rebuild",
      ref: "NDBS_BUDGET_BEGINING.sql:61-244",
      snippet: `Declare cursor looppo for ...
Declare cursor loopgrn for ...
Declare cursor loopinv1 for ...
Declare cursor loopinv2 for ...
Declare cursor loopinv3 for ...
Declare cursor loopreturn for ...
Declare cursor loopcn1 for ...
Declare cursor loopcn2 for ...
Declare cursor loopje for ...`,
    },
    {
      label: "rebuild เขียน movement กลับเข้า ledger และคำนวณยอดใหม่",
      ref: "NDBS_BUDGET_BEGINING.sql:312-339, 389-397, 791-826",
      snippet: `INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'22',...,'R',...,'Y','looppo');
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);

INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'20',...,'A',...,'Y','loopgrn');
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'D',:BDept);

INSERT INTO "NDBS_BGC_OBPE" (...) VALUES (...,'30',...,'A',...,'Y','loopje');
Call NDBS_UpdateBudgetAmount(:BCode,TO_NVARCHAR(:BYear),'P',:BProject);`,
    },
    {
      label: "PR rebuild ยังถูกปิดไว้",
      ref: "NDBS_BUDGET_BEGINING.sql:282-309",
      snippet: `/*
for currloop as looppr do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...) VALUES (...,'1470000113',...,'R',...,'Y','looppr');
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...) VALUES (...,'1470000113',...,'R',...,'Y','looppr');
  end if;
end for;
*/`,
    },
  ],
};

const developerCodeLibrary = {
  draft_year_var: [
    {
      label: "นับลง cnt1 แต่ไปเช็ก cnt",
      ref: "SBO_SP_TransactionNotification.sql:742-760",
      snippet: `IF :object_type ='112' And (:transaction_type = 'A' OR :transaction_type = 'U') Then

  select count(t0."DocEntry") into cnt1
  from ODRF t0
  left join DRF1 t1 on t0."DocEntry" = t1."DocEntry"
  ...
  and T0."ObjType" IN ('1470000049','22','18','19')
  and IFNULL(t1."U_NDBS_BudgetYear",0)=0
  ...

  If :cnt > 0 Then
    error := 100;
    error_message := 'ISS รบกวนตรวจสอบปีงบประมาณ';
  End If;
End If;`,
    },
  ],
  draft_pr_objtype: [
    {
      label: "Draft PR ยังอ้าง object type เดิม",
      ref: "SBO_SP_TransactionNotification.sql:717-750",
      snippet: `and T0."ObjType" IN ('1470000049','22')
...
and T0."ObjType" IN ('1470000049','22','18','19')`,
    },
  ],
  pr_route_unreachable: [
    {
      label: "Outer IF ไม่รวม PR แต่ inner call ยังมี",
      ref: "NDBS_BUDGET_CONTROL.sql:487-491",
      snippet: `IF ( :object_type in ('30','22','21','20','18','19'/*,'1470000049'*/)) then

  if ( :object_type = '1470000113') then
    Call NDBS_BUDGET_PR (:object_type,:transaction_type,:datakey,:error,:error_message);
  elseif ( :object_type = '22') then
    ...
  end if;
end if;`,
    },
  ],
  project_year_wrong: [
    {
      label: "loop project ใช้ U_Project ไปเทียบ BudgetYear",
      ref: "NDBS_UpdateBudgetAmount.sql:82-103",
      snippet: `for currloop as loopbudgetproj do
  Select SUM(IFNULL("Amount",0)) INTO NetReserve
  From "NDBS_BGC_OBPE"
  WHERE "Project" = currloop."U_Project" AND "BudgetGroup" = currloop."U_GroupCode"
  AND "BudgetYear" = currloop."U_Project"
  AND "BudgetType" = 'R' AND "BudgetStatus" <> 'C';

  Select SUM(IFNULL("Amount",0)) INTO NetActual
  From "NDBS_BGC_OBPE"
  WHERE "Project" = currloop."U_Project" AND "BudgetGroup" = currloop."U_GroupCode"
  AND "BudgetYear" = currloop."U_Project"
  AND "BudgetType" = 'A' AND "BudgetStatus" <> 'C';
end for;`,
    },
  ],
  apcn_project_or: [
    {
      label: "Project condition ใช้ OR แทน AND",
      ref: "NDBS_BUDGET_CONTROL.sql:2014-2050",
      snippet: `IF IsCancelled = 'C' then
  for currloop as loopcncancel do
    IF (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
      ...
    end if;
  end for;
else
  ...
  for currloop as loopcn1 do
    if (currloop."Project" IS NOT NULL) OR (currloop."Project" != '') then
      ...
    end if;
  end for;
end if;`,
    },
  ],
  bcount_ge_zero: [
    {
      label: "BCount >= 0 ผ่านเสมอหลัง COUNT(*)",
      ref: "NDBS_BUDGET_CONTROL.sql:1118-1129, 2022-2033",
      snippet: `Select Count(*) into BCount
From "NDBS_BGC_OBDE"
Where "PrimaryObjectType" = :BaseType AND "PrimaryObjectID" = :BaseKey AND "PrimaryObjectLine" = :BaseLine;

IF BCount >= 0 then
  Select TOP 1 "BudgetYear","BudgetGroup","Department" into OldYear,OldGroup,OldDept
  From "NDBS_BGC_OBDE"
  ...
end if;

Select Count(*) into BCount
From "NDBS_BGC_OBPE"
...
IF BCount >= 0 then
  Select TOP 1 "BudgetYear","BudgetGroup","Project" into OldYear,OldGroup,OldProject
  ...
end if;`,
    },
  ],
  rebuild_no_cleanup: [
    {
      label: "เริ่ม rebuild แล้วเข้า loop insert เลย",
      ref: "NDBS_BUDGET_BEGINING.sql:1-7, 312-339",
      snippet: `CREATE PROCEDURE NDBS_BUDGET_BEGINING
(

)
LANGUAGE SQLSCRIPT
AS
begin
  -- Budget Control
  ...

  for currloop as looppo do
    ...
    INSERT INTO "NDBS_BGC_OBDE" (...)
    VALUES (...,'22',...,'R',...);
  end for;`,
    },
    {
      label: "ไม่พบ DELETE หรือ TRUNCATE ก่อนสร้างใหม่",
      ref: "NDBS_BUDGET_BEGINING.sql:1-831",
      snippet: `-- ตรวจทั้งไฟล์แล้วไม่พบคำสั่งล้าง ledger ก่อนเข้า loop เหล่านี้
for currloop as looppo do ... end for;
for currloop as loopgrn do ... end for;
for currloop as loopinv1 do ... end for;
for currloop as loopcn1 do ... end for;
for currloop as loopje do ... end for;`,
    },
  ],
  rebuild_pr_commented: [
    {
      label: "block ของ PR ใน rebuild ถูก comment ทิ้งทั้งชุด",
      ref: "NDBS_BUDGET_BEGINING.sql:282-309",
      snippet: `/*
for currloop as looppr do
  if (currloop."Project" IS NULL) OR (currloop."Project" = '') then
    INSERT INTO "NDBS_BGC_OBDE" (...)
    VALUES (...,'1470000113',...,'R',...,'Y','looppr');
  elseif (currloop."Project" <> '') then
    INSERT INTO "NDBS_BGC_OBPE" (...)
    VALUES (...,'1470000113',...,'R',...,'Y','looppr');
  end if;
end for;
*/`,
    },
  ],
  overbudget_mismatch: [
    {
      label: "ฝั่ง Department ไม่ block แล้ว",
      ref: "NDBS_BUDGET_CONTROL.sql:603-614",
      snippet: `else
  --GUN 20260321 -- error= -32;
  --error_message = 'Department '+ :BDept+' Line No. '+TO_NVARCHAR(:DocLine) +' Budget Available '+
  --  TO_NVARCHAR(:BAvailable)+ ' less than Item Amount ' +TO_NVARCHAR(:BAmount);
  --GUN 20260321 -- error_message = CONCAT(CONCAT('Department ',:BDept),'Over budget');
end if;`,
    },
    {
      label: "ฝั่ง Project ยัง block อยู่จริง",
      ref: "NDBS_BUDGET_CONTROL.sql:1379-1383",
      snippet: `else
  error = -32;
  error_message = CONCAT(CONCAT('Project ',:BProject),'Over budget') ;
end if;`,
    },
  ],
  budget_year_mismatch: [
    {
      label: "PO ใช้คนละเงื่อนไขกับ AP และ JE",
      ref: "SBO_SP_TransactionNotification.sql:1050, 1071, 1092",
      snippet: `-- PO
and LEFT(T1."U_NDBS_BudgetYear",3) <> '202'

-- AP
and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'

-- JE
and LEFT(T1."U_NDBS_BudgetYear",4) <'2024'`,
    },
  ],
};

const systemWorkflowElements = {
  chips: systemFlowChips,
  connectors: systemFlowConnectors,
  detail: systemFlowDetail,
  stagePosition: systemFlowStagePosition,
  stageCaption: systemFlowStageCaption,
  prevButton: systemFlowPrevButton,
  nextButton: systemFlowNextButton,
  detailKicker: systemFlowDetailKicker,
  detailTitle: systemFlowDetailTitle,
  detailSummary: systemFlowDetailSummary,
  detailTags: systemFlowDetailTags,
  detailFrom: systemFlowDetailFrom,
  detailTo: systemFlowDetailTo,
  detailImpact: systemFlowDetailImpact,
  ruleCaption: systemFlowRuleCaption,
  detailRules: systemFlowDetailRules,
  detailPass: systemFlowDetailPass,
  detailNote: systemFlowDetailNote,
  detailCodes: systemFlowDetailCodes,
};

const workflowElements = {
  chips: flowChips,
  connectors: flowConnectors,
  detail: flowDetail,
  stagePosition: flowStagePosition,
  stageCaption: flowStageCaption,
  prevButton: flowPrevButton,
  nextButton: flowNextButton,
  detailKicker: flowDetailKicker,
  detailTitle: flowDetailTitle,
  detailSummary: flowDetailSummary,
  detailTags: flowDetailTags,
  detailFrom: flowDetailFrom,
  detailTo: flowDetailTo,
  detailImpact: flowDetailImpact,
  ruleCaption: flowRuleCaption,
  detailRules: flowDetailRules,
  detailPass: flowDetailPass,
  detailNote: flowDetailNote,
  detailCodes: flowDetailCodes,
};

const ndbsWorkflowElements = {
  chips: ndbsFlowChips,
  connectors: ndbsFlowConnectors,
  detail: ndbsFlowDetail,
  stagePosition: ndbsFlowStagePosition,
  stageCaption: ndbsFlowStageCaption,
  prevButton: ndbsFlowPrevButton,
  nextButton: ndbsFlowNextButton,
  detailKicker: ndbsFlowDetailKicker,
  detailTitle: ndbsFlowDetailTitle,
  detailSummary: ndbsFlowDetailSummary,
  detailTags: ndbsFlowDetailTags,
  detailFrom: ndbsFlowDetailFrom,
  detailTo: ndbsFlowDetailTo,
  detailImpact: ndbsFlowDetailImpact,
  ruleCaption: ndbsFlowRuleCaption,
  detailRules: ndbsFlowDetailRules,
  detailPass: ndbsFlowDetailPass,
  detailNote: ndbsFlowDetailNote,
  detailCodes: ndbsFlowDetailCodes,
};

function renderCodeDropdownList(container, entries) {
  if (!container) {
    return;
  }

  container.innerHTML = "";

  entries.forEach((entry) => {
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
    container.appendChild(details);
  });
}

function renderFlowStage(stageKey, order, data, codeLibrary, elements, setActiveStage) {
  const stage = data[stageKey];
  const stageIndex = order.indexOf(stageKey);

  if (!stage || !elements.detail || stageIndex === -1) {
    return;
  }

  setActiveStage(stageKey);

  elements.chips.forEach((chip, index) => {
    const isActive = chip.dataset.stage === stageKey;
    chip.classList.toggle("is-active", isActive);
    chip.classList.toggle("is-complete", index < stageIndex);
    chip.setAttribute("aria-pressed", String(isActive));
  });

  elements.connectors.forEach((connector, index) => {
    connector.classList.toggle("is-active", index < stageIndex);
  });

  if (elements.stagePosition) {
    elements.stagePosition.textContent = `${stageIndex + 1} / ${order.length}`;
  }

  if (elements.stageCaption) {
    elements.stageCaption.textContent = stage.status;
  }

  if (elements.detailKicker) {
    elements.detailKicker.textContent = stage.kicker;
  }

  if (elements.detailTitle) {
    elements.detailTitle.textContent = stage.title;
  }

  if (elements.detailSummary) {
    elements.detailSummary.textContent = stage.summary;
  }

  if (elements.detailTags) {
    elements.detailTags.innerHTML = "";
    stage.tags.forEach((tag) => {
      const tagElement = document.createElement("span");
      tagElement.className = "flow-tag";
      tagElement.textContent = tag;
      elements.detailTags.appendChild(tagElement);
    });
  }

  if (elements.detailFrom) {
    elements.detailFrom.textContent = stage.from;
  }

  if (elements.detailTo) {
    elements.detailTo.textContent = stage.to;
  }

  if (elements.detailImpact) {
    elements.detailImpact.textContent = stage.impact;
  }

  if (elements.ruleCaption) {
    elements.ruleCaption.textContent = stage.caption;
  }

  if (elements.detailRules) {
    elements.detailRules.innerHTML = "";

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
      elements.detailRules.appendChild(card);
    });
  }

  if (elements.detailPass) {
    elements.detailPass.textContent = stage.pass;
  }

  if (elements.detailNote) {
    elements.detailNote.textContent = stage.note;
  }

  if (elements.detailCodes) {
    const codeRefs =
      codeLibrary[stageKey] ||
      (stage.codes || []).map((item) => ({
        label: item,
        ref: item,
        snippet: item,
      }));

    renderCodeDropdownList(elements.detailCodes, codeRefs);
  }

  if (elements.prevButton) {
    elements.prevButton.disabled = stageIndex === 0;
  }

  if (elements.nextButton) {
    elements.nextButton.disabled = stageIndex === order.length - 1;
  }

  elements.detail.classList.remove("is-refreshing");
  requestAnimationFrame(() => {
    elements.detail.classList.add("is-refreshing");
  });
}

function stepFlow(direction, order, activeStage, renderStage) {
  const currentIndex = order.indexOf(activeStage);
  if (currentIndex === -1) {
    return;
  }

  const nextIndex = Math.min(Math.max(currentIndex + direction, 0), order.length - 1);
  renderStage(order[nextIndex]);
}

function renderSystemWorkflowStage(stageKey) {
  renderFlowStage(
    stageKey,
    systemWorkflowOrder,
    systemWorkflowData,
    systemWorkflowCodeLibrary,
    systemWorkflowElements,
    (value) => {
      activeSystemWorkflowStage = value;
    },
  );
}

function stepSystemWorkflow(direction) {
  stepFlow(direction, systemWorkflowOrder, activeSystemWorkflowStage, renderSystemWorkflowStage);
}

function renderWorkflowStage(stageKey) {
  renderFlowStage(stageKey, workflowOrder, workflowData, workflowCodeLibrary, workflowElements, (value) => {
    activeWorkflowStage = value;
  });
}

function stepWorkflow(direction) {
  stepFlow(direction, workflowOrder, activeWorkflowStage, renderWorkflowStage);
}

function renderNdbsWorkflowStage(stageKey) {
  renderFlowStage(
    stageKey,
    ndbsWorkflowOrder,
    ndbsWorkflowData,
    ndbsWorkflowCodeLibrary,
    ndbsWorkflowElements,
    (value) => {
      activeNdbsWorkflowStage = value;
    },
  );
}

function stepNdbsWorkflow(direction) {
  stepFlow(direction, ndbsWorkflowOrder, activeNdbsWorkflowStage, renderNdbsWorkflowStage);
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

function isSectionActive(section) {
  if (!section) {
    return false;
  }

  const rect = section.getBoundingClientRect();
  const viewportHeight = window.innerHeight || document.documentElement.clientHeight;
  const visibleHeight = Math.min(rect.bottom, viewportHeight) - Math.max(rect.top, 0);

  return visibleHeight > Math.min(rect.height, viewportHeight) * 0.35;
}

window.addEventListener(
  "scroll",
  () => {
    const currentScrollTop = window.scrollY || document.documentElement.scrollTop;

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
  if (isSectionActive(systemWorkflowSection) && (event.key === "ArrowLeft" || event.key === "[")) {
    event.preventDefault();
    stepSystemWorkflow(-1);
    return;
  }

  if (isSectionActive(systemWorkflowSection) && (event.key === "ArrowRight" || event.key === "]")) {
    event.preventDefault();
    stepSystemWorkflow(1);
    return;
  }

  if (isSectionActive(ndbsWorkflowSection) && (event.key === "ArrowLeft" || event.key === "[")) {
    event.preventDefault();
    stepNdbsWorkflow(-1);
    return;
  }

  if (isSectionActive(ndbsWorkflowSection) && (event.key === "ArrowRight" || event.key === "]")) {
    event.preventDefault();
    stepNdbsWorkflow(1);
    return;
  }

  if (isSectionActive(documentWorkflowSection) && (event.key === "ArrowLeft" || event.key === "[")) {
    event.preventDefault();
    stepWorkflow(-1);
    return;
  }

  if (isSectionActive(documentWorkflowSection) && (event.key === "ArrowRight" || event.key === "]")) {
    event.preventDefault();
    stepWorkflow(1);
  }
});

overviewTabs.forEach((tab) => {
  tab.addEventListener("click", () => {
    setOverviewPanel(tab.dataset.panel);
  });
});

systemFlowChips.forEach((chip) => {
  chip.addEventListener("click", () => {
    const stageKey = chip.dataset.stage;
    renderSystemWorkflowStage(stageKey);
  });
});

flowChips.forEach((chip) => {
  chip.addEventListener("click", () => {
    const stageKey = chip.dataset.stage;
    renderWorkflowStage(stageKey);
  });
});

ndbsFlowChips.forEach((chip) => {
  chip.addEventListener("click", () => {
    const stageKey = chip.dataset.stage;
    renderNdbsWorkflowStage(stageKey);
  });
});

systemFlowPrevButton?.addEventListener("click", () => stepSystemWorkflow(-1));
systemFlowNextButton?.addEventListener("click", () => stepSystemWorkflow(1));
flowPrevButton?.addEventListener("click", () => stepWorkflow(-1));
flowNextButton?.addEventListener("click", () => stepWorkflow(1));
ndbsFlowPrevButton?.addEventListener("click", () => stepNdbsWorkflow(-1));
ndbsFlowNextButton?.addEventListener("click", () => stepNdbsWorkflow(1));

backendRoleCodeTargets.forEach((target) => {
  renderCodeDropdownList(target, backendRoleCodeLibrary[target.dataset.backendCode] || []);
});

developerCodeTargets.forEach((target) => {
  renderCodeDropdownList(target, developerCodeLibrary[target.dataset.developerCode] || []);
});

setOverviewPanel("business");
renderSystemWorkflowStage("engine");
renderWorkflowStage("draft");
renderNdbsWorkflowStage("entry");
