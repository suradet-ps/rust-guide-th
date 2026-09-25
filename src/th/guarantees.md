---
references:
  - type: web
    title: The Rust Reference
    url: https://doc.rust-lang.org/stable/reference/
    id: rust-reference
  - type: web
    title: The Rustonomicon
    url: https://doc.rust-lang.org/stable/nomicon/
    id: nomicon
---

# การรับประกันของภาษา

## พฤติกรรมไม่นิยาม (Undefined Behaviors / *UB*)

<div class="definition">

พฤติกรรมของโปรแกรมถือเป็น[*ไม่นิยาม*](https://doc.rust-lang.org/reference/behavior-considered-undefined.html) เมื่อความหมายเชิงการทำงาน (semantics) ของมันไม่ได้ถูกอธิบายไว้ในภาษา Rust

</div>

การมีอยู่ของ UB ถือเป็น[ข้อผิดพลาดในการเขียนโปรแกรม](https://doc.rust-lang.org/reference/behavior-considered-undefined.html#r-undefined.general) และต้องหลีกเลี่ยง

<div class="example">

การดีเรฟเฟอเรนซ์พอยน์เตอร์ null (null pointer) เป็น *UB* ในทางกลับกัน การ `unwrap` ออบเจ็กต์ `None` ถือว่านิยามไว้ดีแล้ว (well defined) เพราะเป็นภาษาที่จัดการข้อผิดพลาดนี้เอง (โดยการเรียกแพนิก)

</div>

รายการข้อผิดพลาดในการเขียนโปรแกรมที่นำไปสู่ UB มี[ระบุไว้](https://doc.rust-lang.org/reference/behavior-considered-undefined.html)
ใน [Rust reference @rust-reference] ในบรรดาข้อผิดพลาดเหล่านั้น ข้อผิดพลาดต่อไปนี้น่าสนใจเป็นพิเศษ:

* ต้องไม่ดีเรฟเฟอเรนซ์พอยน์เตอร์ที่ชี้ไปยังที่อยู่หน่วยความจำที่ยังไม่ได้จัดสรรหรือไม่ตรงแนว (ตัวชี้ที่ dangling) ซึ่งหมายความรวมถึง
  * ต้องไม่เกิดบัฟเฟอร์ล้น (buffer overflow)
  * ต้องไม่เข้าถึงหน่วยความจำที่ถูกคืนแล้ว
  * ต้องไม่เข้าถึงแบบไม่ตรงแนว
* ค่าที่พอยน์เตอร์ชี้ไปต้อง[สอดคล้อง](https://doc.rust-lang.org/reference/behavior-considered-undefined.html#r-undefined.invalid)กับชนิดข้อมูลของพอยน์เตอร์ ตัวอย่างเช่น ค่าที่พอยน์เตอร์ชนิดบูลีนชี้ไปจะต้องเป็นไบต์ที่มีค่า 1 หรือ 0
* การปฏิบัติตาม[กฎการตั้งชื่อแทนข้อมูลหลายทาง (aliasing rules)](https://doc.rust-lang.org/reference/behavior-considered-undefined.html#r-undefined.alias) (ดู[ตัวอย่าง](https://doc.rust-lang.org/nomicon/aliasing.html)เพิ่มเติมได้ใน [Rustonomicon @nomicon]): การอ้างอิงแบบเปลี่ยนค่าได้ (mutable reference) ต้องไม่ถูกแชร์
* ต้องไม่[เข้าถึงที่อยู่หน่วยความจำเดียวกันพร้อมกัน](https://doc.rust-lang.org/reference/behavior-considered-undefined.html#r-undefined.race) (การอ่าน/เขียนเป็นไปไม่ได้ในขณะที่กำลังเขียนอยู่พร้อมกัน) (ดู[ตัวอย่าง](https://doc.rust-lang.org/nomicon/races.html)เพิ่มเติมได้ใน [Rustonomicon @nomicon])

## การรับประกันของ Rust

<div class="important">

กระบวนทัศน์ของภาษาคือการรับประกันว่าไม่มี UB ในโปรแกรมที่ใช้เฉพาะส่วนที่ไม่ใช่ *unsafe* ของ Rust

</div>

<div class="note">

แม้จะมีการรับประกันความปลอดภัยของหน่วยความจำ (memory safety) เหล่านี้ ภาษาก็ไม่ได้ป้องกัน

* การรั่วของทรัพยากร (หน่วยความจำ, I/O, ...) (ดู[ส่วนการจัดการหน่วยความจำ](unsafe/memory.md#chapter-memory))
* การล้นของตัวเลข (ดู[ส่วนการดำเนินการกับจำนวนเต็ม](integer.md#chapter-integer))

</div>
