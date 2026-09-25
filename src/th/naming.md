---
references:
  - type: article
    title: General naming conventions
    url: https://rust-lang.github.io/rfcs/0430-finalizing-naming-conventions.html
    id: RFC-430
  - type: article
    title: Rust API Guidelines
    url: https://rust-lang.github.io/api-guidelines/
    id: rust-guidelines
---

# การตั้งชื่อ

ไลบรารีมาตรฐาน (standard library) ทำหน้าที่เป็นมาตรฐานโดยพฤตินัยสำหรับแนวทางการตั้งชื่อใน Rust
ได้มีความพยายามทำให้แนวทางเหล่านี้เป็นทางการผ่าน [RFC 43 @RFC-430] และต่อมาใน [Rust API Guidelines @rust-guidelines]

กฎพื้นฐาน [`(C-CASE)`] ประกอบด้วยการใช้:

- `UpperCamelCase` สำหรับชนิดข้อมูล เทรต ตัวแปรของอีนัม (enum variant) และพารามิเตอร์ชนิดข้อมูลทั่วไป
- `snake_case` สำหรับฟังก์ชัน เมธอด มาโคร ตัวแปร และมอดูล
- `SCREAMING_SNAKE_CASE` สำหรับสแตติก (static) ค่าคงที่ (constant) และพารามิเตอร์ค่าคงที่ทั่วไป
- `'lowercase` สำหรับไลฟ์ไทม์ (lifetime)

[Rust API Guidelines @rust-guidelines] ยังกำหนดแนวทางการตั้งชื่อที่แม่นยำยิ่งขึ้นสำหรับ
โครงสร้างบางประเภท:

- [`(C-CONV)`] สำหรับเมธอดแปลงชนิด (conversion method) (`as_`, `to_`, `into_`)
- [`(C-GETTER)`] สำหรับเก็ตเตอร์ (getter)
- [`(C-ITER)`] สำหรับเมธอดที่สร้างอีเทอเรเตอร์ (iterator-producing method)
- [`(C-ITER-TY)`] สำหรับชนิดข้อมูลอีเทอเรเตอร์ (iterator type)
- [`(C-FEATURE)`] สำหรับการตั้งชื่อฟีเจอร์ (feature) (ฟังก์ชันการทำงานที่เปิดใช้ตามเงื่อนไข)
- [`(C-WORD-ORDER)`] สำหรับความสม่ำเสมอของลำดับคำ (word order)

<div class="note">

กฎพื้นฐาน [`(C-CASE)`] ถูกตรวจสอบโดยคอมไพเลอร์ (ด้วยชุดลินต์ `nonstandard_style`)

นอกจากคอมไพเลอร์แล้ว เครื่องมือ [`clippy`](devenv.md#clippy) ยังช่วยในการนำแนวทางการตั้งชื่อมาใช้ได้ด้วยหมวดลินต์ `style`
ตัวอย่างเช่น ลินต์ [`wrong_self_convention`](https://rust-lang.github.io/rust-clippy/master/index.html#wrong_self_convention) ตรวจสอบความสอดคล้องระหว่างชื่อเมธอดแปลงชนิดกับชนิดข้อมูลตัวรับ (receiver type) (`self`, `&self`, `&mut self`) ตาม [`(C-CONV)`]

<!--
clippy::enum_variant_names
clippy::self_named_constructors
-->

</div>

<div class="reco" id="LANG-NAMING" type="กฎ" title="ปฏิบัติตามแนวทางการตั้งชื่อ">

การพัฒนาแอปพลิเคชันที่ปลอดภัยต้องปฏิบัติตามแนวทางการตั้งชื่อ
ที่ระบุไว้ใน [Rust API Guidelines @rust-guidelines]

</div>

[`(C-CASE)`]: https://rust-lang.github.io/api-guidelines/naming.html#casing-conforms-to-rfc-430-c-case
[`(C-CONV)`]: https://rust-lang.github.io/api-guidelines/naming.html#ad-hoc-conversions-follow-as_-to_-into_-conventions-c-conv
[`(C-GETTER)`]: https://rust-lang.github.io/api-guidelines/naming.html#getter-names-follow-rust-convention-c-getter
[`(C-ITER)`]: https://rust-lang.github.io/api-guidelines/naming.html#methods-on-collections-that-produce-iterators-follow-iter-iter_mut-into_iter-c-iter
[`(C-ITER-TY)`]: https://rust-lang.github.io/api-guidelines/naming.html#iterator-type-names-match-the-methods-that-produce-them-c-iter-ty
[`(C-FEATURE)`]: https://rust-lang.github.io/api-guidelines/naming.html#feature-names-are-free-of-placeholder-words-c-feature
[`(C-WORD-ORDER)`]: https://rust-lang.github.io/api-guidelines/naming.html#names-use-a-consistent-word-order-c-word-order
