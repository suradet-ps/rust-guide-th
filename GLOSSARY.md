# พจนานุกรมศัพท์ (Glossary) — แนวทางความปลอดภัย Rust ฉบับภาษาไทย

ตารางนี้รวบรวมคำศัพท์เชิงเทคนิคและแนวทางการแปลที่ใช้อย่างสม่ำเสมอตลอดทั้งเล่ม เพื่อให้การแปลทุกบทมีความถูกต้อง ลื่นไหล และเป็นธรรมชาติสำหรับนักพัฒนา Rust ชาวไทย

| ศัพท์ต้นฉบับ | คำแปลไทย | หมายเหตุ |
|---|---|---|
| secure application | แอปพลิเคชันที่ปลอดภัย | |
| security | ความปลอดภัย | |
| safety / soundness | ความปลอดภัย / ความถูกต้องตามหลักความปลอดภัย (soundness) | soundness หมายถึงการไม่เปิดช่องให้เกิด undefined behavior |
| memory safety | ความปลอดภัยของหน่วยความจำ (memory safety) | |
| undefined behavior (UB) | พฤติกรรมไม่นิยาม (undefined behavior / UB) | |
| ownership | ความเป็นเจ้าของ (ownership) | |
| borrow / borrowing | การยืม (borrow / borrowing) | |
| lifetime | ไลฟ์ไทม์ (lifetime) | |
| aliasing | การตั้งชื่อแทนข้อมูลหลายทาง (aliasing) | |
| data race | การแข่งกันของข้อมูล (data race) | |
| trait | เทรต (trait) | คง `Send`, `Sync`, `Drop`, `Ord` ฯลฯ ในโค้ด |
| crate | เครต (crate) | |
| edition | เอดิชัน (edition) | |
| toolchain | ชุดเครื่องมือ (toolchain) | |
| release channel | ช่องทางเผยแพร่ (release channel) | stable / beta / nightly คงชื่อเดิม |
| target | เป้าหมายการคอมไพล์ (target) | |
| tier | ระดับชั้น (tier) | |
| overflow | ล้น (overflow) | |
| wrap-around | การวนกลับค่า (wrap-around) | |
| panic | การแพนิก (panic) | |
| lint | ลินต์ (lint) | |
| linter | ตัวตรวจโค้ด (linter) | |
| checksum | เช็กซัม (checksum) | |
| dependency | ดีเพนเดนซี (dependency) | |
| transitive dependency | ดีเพนเดนซีทางอ้อม (transitive dependency) | |
| third-party | จากบุคคลที่สาม / ภายนอก | |
| FFI | อินเทอร์เฟซกับภาษาต่างประเทศ (FFI) | |
| ABI | เอบีไอ (ABI) | Application Binary Interface |
| binding | การผูก (binding) | |
| raw pointer | ตัวชี้ดิบ (raw pointer) | |
| smart pointer | สมาร์ตพอยน์เตอร์ (smart pointer) | |
| memory leak | การรั่วของหน่วยความจำ (memory leak) | |
| dangling pointer | ตัวชี้ที่ dangling | ตัวชี้ที่ชี้ไปยังหน่วยความจำซึ่งถูกคืนแล้ว |
| use-after-free | การใช้หน่วยความจำหลังการคืน (use-after-free) | |
| double free | การคืนหน่วยความจำซ้ำ (double free) | |
| out-of-bounds | นอกขอบเขต (out-of-bounds) | |
| opaque type | ชนิดข้อมูลทึบ (opaque type) | |
| invariant | อินแวเรียนต์ (invariant) | เงื่อนไขที่ต้องคงความเป็นจริงเสมอ |
| panic safety | ความปลอดภัยเมื่อเกิดแพนิก (panic safety) | |
| fuzzing | การฟัซ (fuzzing) | |
| robust / non-robust types | ชนิดข้อมูลที่ทนทาน / ไม่ทนทาน (robust / non-robust) | |
| reference counting | การนับการอ้างอิง (reference counting) | |
| cyclic reference | การอ้างอิงเป็นวงจร (cyclic reference) | |
| untrusted input | อินพุตที่ไม่น่าเชื่อถือ | |
| threat | ภัยคุกคาม (threat) | |
| vulnerability | ช่องโหว่ (vulnerability) | |
| mitigation | มาตรการบรรเทา (mitigation) | |
| Rule | กฎ | ใช้เป็นค่า `type="..."` ใน `<div class="reco">` |
| Recommendation | ข้อเสนอแนะ | ใช้เป็นค่า `type="..."` ใน `<div class="reco">` |
| warning / note / example / definition / important | คำเตือน / หมายเหตุ / ตัวอย่าง / คำนิยาม / สิ่งสำคัญ | ชื่อคลาส CSS คงเดิม (`warning`, `note`, ...) |
| checklist | รายการตรวจสอบ | |

## หลักการทั่วไป

- **ชื่อทางเทคนิค**: ชื่อเครื่องมือ คำสั่ง CLI ตัวเลือก (flag) ชื่อเครต/เทรต/ฟังก์ชัน/ชนิดข้อมูล ชนิดข้อมูลในโค้ด และ URL **ไม่แปล** เช่น `cargo`, `rustup`, `clippy`, `rustfmt`, `Cargo.lock`, `unsafe`, `Send`, `Sync`
- **โค้ดทุกบล็อก (` ```...``` `)**: ต้องคงไว้ตามต้นฉบับภาษาอังกฤษทุกตัวอักษร (byte-identical) รวมถึงคอมเมนต์ การเว้นวรรค และบรรทัด `{{#include ...}}` ทั้งหมด
- **Frontmatter (บล็อก `---` ต้นไฟล์)**: คงไว้ตามต้นฉบับทั้งหมด เพราะเป็นรายการอ้างอิงบรรณานุกรม (title/url/author ของเอกสารจริง)
- **ลิงก์ (Links)**: ทั้ง inline links, reference links และ autolinks ต้องชี้ไปยัง target เดิมเสมอ รวมถึง anchor แบบ `{#...}` ในหัวข้อ
- **บล็อก HTML**: คงค่า `id` ของ `<div class="reco" ...>` ตามต้นฉบับเสมอ (ใช้เป็น anchor) แต่แปลค่า `type` เป็น `กฎ` หรือ `ข้อเสนอแนะ` และแปลค่า `title`
- **การอ้างอิง**: คงรูปแบบ `[@citation-id]` ตามต้นฉบับ เพื่อให้ตัวประมวลผล `cite-proc` สร้างส่วน "แหล่งอ้างอิง" ให้อัตโนมัติ
- **เชิงอรรถ**: คงเครื่องหมาย `[^n]` และหมายเลขเดิม แปลเฉพาะข้อความ
- **หัวข้อ (Headings)**: แปลเป็นไทยอย่างเป็นธรรมชาติ ระดับหัวข้อ (จำนวน `#`) ต้องตรงกับต้นฉบับ และคง `{#anchor-id}` ต่อท้ายไว้เสมอ
- **Anchor ของลิงก์ภายในเล่ม**: ตรวจสอบกับ HTML ที่ mdbook สร้างแล้วเสมอด้วย `scripts/check-links.ps1`
- **การแปลครั้งแรก**: ศัพท์เทคนิคที่แปลเป็นไทย ให้วงเล็บภาษาอังกฤษไว้ครั้งแรกที่ปรากฏ เช่น "พฤติกรรมไม่นิยาม (undefined behavior)" จากนั้นใช้คำไทยเดี่ยวได้
