# การจัดการหน่วยความจำ {#chapter-memory}

<!-- ## เกี่ยวกับความปลอดภัยของหน่วยความจำของ Rust -->

<!--
<mark>TODO</mark>: อธิบายการจัดสรร/คืนหน่วยความจำอย่างปลอดภัย ความเป็นเจ้าของ/การยืม
และระบุโครงสร้างภาษาที่อาจทำลายความปลอดภัยของหน่วยความจำ (ตัวอย่างเช่น
พฤติกรรมที่ไม่ถูกต้องตามหลักความปลอดภัยในคอมไพเลอร์เวอร์ชันเก่า)
-->

ในกรณีส่วนใหญ่ ใน Rust ที่ไม่ใช้ `unsafe` (กล่าวคือ โค้ดที่ไม่ใช้ `unsafe`) คอมไพเลอร์จะกำหนด **โดยอัตโนมัติ** ว่าเมื่อใดจึงจะคืนหน่วยความจำที่ค่าหนึ่งในโปรแกรมครอบครองอยู่
แต่ดังที่[กล่าวไว้ก่อนหน้านี้](../guarantees.md#การรับประกันของ-rust) สิ่งนี้ไม่ใช่
การรับประกัน: โค้ดที่ไม่มี `unsafe` ก็ยังสามารถนำไปสู่การรั่วของหน่วยความจำ (memory leak) ได้ ดังนั้น กฎบางข้อที่นำเสนอ
ในบทนี้จึงไม่เกี่ยวข้องโดยตรงกับคีย์เวิร์ด `unsafe` อย่างไรก็ตาม

<div class="important">

แม้ว่าฟังก์ชันต่อไปนี้จะไม่ใช่ `unsafe`
แต่ก็ควรใช้ในบริบท Rust แบบ *unsafe* เท่านั้น

</div>

ตามกฎทั่วไป ต้องหลีกเลี่ยงการรั่วของหน่วยความจำ

<div class="reco" id="MEM-NO-LEAK" type="กฎ" title="ไม่มีการรั่วของหน่วยความจำ">

ในการพัฒนา Rust อย่างปลอดภัย ต้องไม่อนุญาตให้เกิดการรั่วของหน่วยความจำ

</div>

## [`mem::forget`] และการรั่วของหน่วยความจำ {#forget-and-memory-leaks}

โดยทั่วไปแล้ว วิธีปกติที่หน่วยความจำจะถูกเรียกคืนคือเมื่อตัวแปรหลุดออกนอก
ขอบเขต (scope) แต่ Rust มีฟังก์ชันพิเศษสำหรับเรียกคืนหน่วยความจำด้วยมือ: [`mem::forget`] และ
[`mem::drop`] ของโมดูล `std::mem` (หรือ `core::mem`) ขณะที่ [`mem::drop`] เพียงกระตุ้น
การเรียกคืนหน่วยความจำก่อนกำหนด ซึ่งจะเรียกตัวทำลาย (destructor) ที่เกี่ยวข้องเมื่อจำเป็น
[`mem::forget`] กลับข้ามการเรียกตัวทำลายทั้งหมด

```rust align
{{#include ../../../examples/src/memory.rs:drop_example}}
```

ฟังก์ชันทั้งสอง **ปลอดภัยด้านหน่วยความจำ** ใน Rust อย่างไรก็ตาม [`mem::forget`] จะทำให้
ทรัพยากรใดๆ ที่ค่าดังกล่าวจัดการอยู่ไม่สามารถเข้าถึงได้และไม่ถูกเรียกคืน

```rust align bad
{{#include ../../../examples/src/memory.rs:forget_example}}
```

โดยเฉพาะอย่างยิ่ง การใช้ [`mem::forget`] อาจส่งผลให้ทรัพยากรที่สำคัญไม่ถูกปลดปล่อย
นำไปสู่การติดตาย (deadlock) หรือข้อมูลที่ละเอียดอ่อนไม่ถูกลบออกจากหน่วยความจำ นี่คือเหตุผลที่
[`mem::forget`] **ไม่ปลอดภัย**

<div class="reco" id="MEM-FORGET" type="กฎ" title="ต้องไม่ใช้ `mem::forget`">

ในการพัฒนา Rust อย่างปลอดภัย ต้องไม่ใช้ฟังก์ชัน [`mem::forget`] ของ `std::mem`
(`core::mem`)

</div>

<!-- -->

<div class="reco" id="MEM-FORGET-LINT" type="ข้อเสนอแนะ" title="ใช้ลินต์ของ Clippy เพื่อตรวจจับการใช้ `mem::forget`">

ควรใช้ลินต์ `mem_forget` ของ Clippy เพื่อตรวจจับการใช้
[`mem::forget`] โดยอัตโนมัติ เพื่อบังคับไม่ให้มีการใช้ [`mem::forget`] ในเครต ให้เพิ่มบรรทัด
ต่อไปนี้ที่ด้านบนของไฟล์ราก (โดยปกติคือ `src/lib.rs` หรือ `src/main.rs`):

```rust,noplaypen,ignore
#![deny(clippy::mem_forget)]
```

</div>

ไลบรารีมาตรฐานยังมีวิธีอื่นในการ *ลืม* การดรอปค่า:

- [`Box::leak`] เพื่อรั่วทรัพยากร
- [`Box::into_raw`] เพื่อใช้ประโยชน์จาก `Box` ในฐานะ **พอยน์เตอร์** ในโค้ด unsafe บางกรณี โดยเฉพาะใน FFI
- [`ManuallyDrop`] (ใน `std::mem` หรือ `core::mem`) เพื่อบังคับการคืนค่าบางอย่างด้วยมือ

ทางเลือกเหล่านี้อาจนำไปสู่ปัญหาความปลอดภัยเดียวกัน แต่มี
ประโยชน์เพิ่มเติมที่ทำให้เห็นเจตนาได้อย่างชัดเจน

<div class="reco" id="MEM-LEAK" type="กฎ" title="ต้องไม่ใช้ฟังก์ชัน `leak`">

ในการพัฒนา Rust อย่างปลอดภัย โค้ดต้องไม่รั่วหน่วยความจำหรือทรัพยากร
โดยเฉพาะผ่าน [`Box::leak`]

</div>

[`ManuallyDrop`] และ [`Box::into_raw`] ได้ย้ายความรับผิดชอบในการคืนจาก
คอมไพเลอร์ไปยังผู้พัฒนา

<div class="reco" id="MEM-MANUALLYDROP" type="กฎ" title="ต้องคืนค่าที่ห่อด้วย `ManuallyDrop`">

ในการพัฒนา Rust อย่างปลอดภัย ค่าใดๆ ที่ถูกห่อด้วย [`ManuallyDrop`] ต้องถูก
แกะออกเพื่อให้สามารถคืนได้โดยอัตโนมัติ ([`ManuallyDrop::into_inner`])
หรือถูกคืนด้วยมือ (ด้วย unsafe [`ManuallyDrop::drop`])

</div>

<!-- -->

[`mem::forget`]: https://doc.rust-lang.org/std/mem/fn.forget.html
[`mem::drop`]: https://doc.rust-lang.org/std/mem/fn.drop.html
[`Drop`]: https://doc.rust-lang.org/std/ops/trait.Drop.html
[`Box::leak`]: https://doc.rust-lang.org/std/boxed/struct.Box.html#method.leak
[`Box::into_raw`]: https://doc.rust-lang.org/std/boxed/struct.Box.html#method.into_raw
[`ManuallyDrop`]: https://doc.rust-lang.org/beta/std/mem/struct.ManuallyDrop.html
[`ManuallyDrop::into_inner`]: https://doc.rust-lang.org/beta/std/mem/struct.ManuallyDrop.html#method.into_inner
[`ManuallyDrop::drop`]: https://doc.rust-lang.org/beta/std/mem/struct.ManuallyDrop.html#method.drop

## ตัวชี้ดิบ

ตัวชี้เหล่านี้ส่วนใหญ่ใช้สำหรับพอยน์เตอร์ของ C ตัวชี้เหล่านี้ไม่มีการป้องกัน
เช่นเดียวกับ *สมาร์ตพอยน์เตอร์ (smart pointer)* และมักต้องใช้ในบริบท `unsafe` ตัวอย่างเช่น การคืน 
ตัวชี้ดิบต้องทำด้วยมือโดยไม่มีการรับประกันจาก Rust

<div class="reco" id="MEM-NORAWPOINTER" type="กฎ" title="อย่าแปลงสมาร์ตพอยน์เตอร์เป็นตัวชี้ดิบใน Rust ที่ไม่ใช้ `unsafe`">

ในการพัฒนา Rust อย่างปลอดภัยที่ไม่ใช้ `unsafe` ควรไม่แปลงเรฟเฟอเรนซ์และ *สมาร์ตพอยน์เตอร์*
ให้เป็น *ตัวชี้ดิบ* ตัวอย่างเช่น ควรไม่ใช้ฟังก์ชัน `into_raw` หรือ `into_non_null`
ของสมาร์ตพอยน์เตอร์ [`Box`], [`Rc`], [`Arc`], [`rc::Weak`] หรือ [`sync::Weak`]

มิฉะนั้น การใช้ *ตัวชี้ดิบ* โดยไม่มีโค้ด `unsafe` ต้องมีเอกสารกำกับและมีเหตุผลรองรับ

</div>

<div class="reco" id="MEM-INTOFROMRAWALWAYS" type="กฎ" title="เรียก `from_raw` บนค่าที่ผ่าน `into_raw` เสมอ">

ในการพัฒนา Rust อย่างปลอดภัย พอยน์เตอร์ใดๆ ที่ถูกสร้างขึ้นด้วยการเรียก `into_raw`
(หรือ `into_non_null`) จากชนิดข้อมูลใดชนิดข้อมูลหนึ่งต่อไปนี้:

- [`std::boxed::Box`] (หรือ [`alloc::boxed::Box`]),
- [`std::rc::Rc`] (หรือ [`alloc::rc::Rc`]),
- [`std::rc::Weak`] (หรือ [`alloc::rc::Weak`]),
- [`std::sync::Arc`] (หรือ [`alloc::sync::Arc`]),
- [`std::sync::Weak`] (หรือ [`alloc::sync::Weak`]),
- [`std::ffi::CString`],
- [`std::ffi::OsString`].

ต้องถูกแปลงกลับเป็นค่าด้วยการเรียก `from_raw` ที่สอดคล้องกันในที่สุด เพื่อให้สามารถเรียกคืนได้

```rust align
{{#include ../../../examples/src/memory.rs:raw_pointer}}
```

</div>

การกลับกันก็เป็นจริงเช่นกัน! กล่าวคือ ควรเรียก `from_raw` **เพียง** กับค่าที่ผ่าน `into_raw` เท่านั้น ตัวอย่างเช่น
สมาร์ตพอยน์เตอร์ [`Rc`] [ระบุเงื่อนไขนี้อย่างชัดเจน](https://doc.rust-lang.org/std/rc/struct.Rc.html#method.from_raw)
และสำหรับสมาร์ตพอยน์เตอร์ [`Box`] การแปลงพอยน์เตอร์ของ C เป็น [`Box`] นั้น [ไม่สนับสนุน](https://doc.rust-lang.org/std/boxed/index.html#memory-layout)

<div class="reco" id="MEM-INTOFROMRAWONLY" type="กฎ" title="เรียก `from_raw` กับค่าที่ผ่าน `into_raw` *เท่านั้น*">

ในการพัฒนา Rust อย่างปลอดภัย ต้องเรียก `from_raw` กับค่าที่ผ่าน `into_raw` เท่านั้น

</div>

<!-- -->

<div class="note">

ในกรณีของ [`Box::into_raw`] การทำความสะอาดด้วยมือสามารถทำได้ แต่ซับซ้อนกว่า
การนำตัวชี้ดิบกลับมาห่อเป็น `Box` ใหม่มาก และควรหลีกเลี่ยง:

```rust align bad
{{#include ../../../examples/src/memory.rs:into_raw}}
```

เนื่องจากชนิดข้อมูลอื่นๆ ([`Rc`] และ [`Arc`]) เป็นแบบทึบและซับซ้อนกว่า
การทำความสะอาดด้วยมือจึงไม่สามารถทำได้

</div>

[`Box`]: https://doc.rust-lang.org/std/boxed/struct.Box.html
[`std::boxed::Box`]: https://doc.rust-lang.org/std/boxed/struct.Box.html
[`alloc::boxed::Box`]: https://doc.rust-lang.org/alloc/boxed/struct.Box.html
[`Rc`]: https://doc.rust-lang.org/std/rc/struct.Rc.html
[`std::rc::Rc`]: https://doc.rust-lang.org/std/rc/struct.Rc.html
[`alloc::rc::Rc`]: https://doc.rust-lang.org/alloc/rc/struct.Rc.html
[`rc::Weak`]: https://doc.rust-lang.org/std/rc/struct.Weak.html
[`std::rc::Weak`]: https://doc.rust-lang.org/std/rc/struct.Weak.html
[`alloc::rc::Weak`]: https://doc.rust-lang.org/alloc/rc/struct.Weak.html
[`Arc`]: https://doc.rust-lang.org/std/sync/struct.Arc.html
[`std::sync::Arc`]: https://doc.rust-lang.org/std/sync/struct.Arc.html
[`alloc::sync::Arc`]: https://doc.rust-lang.org/alloc/sync/struct.Arc.html
[`sync::Weak`]: https://doc.rust-lang.org/std/sync/struct.Weak.html
[`std::sync::Weak`]: https://doc.rust-lang.org/std/sync/struct.Weak.html
[`alloc::sync::Weak`]: https://doc.rust-lang.org/alloc/sync/struct.Weak.html
[`std::ffi::CString`]: https://doc.rust-lang.org/std/ffi/struct.CString.html
[`std::ffi::OsString`]: https://doc.rust-lang.org/std/ffi/struct.OsString.html

## หน่วยความจำที่ยังไม่ถูกกำหนดค่าเริ่มต้น

โดยค่าเริ่มต้น Rust บังคับให้ค่าทั้งหมดถูกกำหนดค่าเริ่มต้น ซึ่งป้องกันการใช้
หน่วยความจำที่ยังไม่ถูกกำหนดค่าเริ่มต้น (ยกเว้นเมื่อใช้ [`std::mem::uninitialized`] หรือ
[`std::mem::MaybeUninit`])

<div class="reco" id="MEM-UNINIT" type="กฎ" title="ต้องไม่ใช้หน่วยความจำที่ยังไม่ถูกกำหนดค่าเริ่มต้น">

ต้องไม่ใช้ฟังก์ชัน [`std::mem::uninitialized`] (เลิกใช้แล้วในเวอร์ชัน 1.38)
การใช้ชนิดข้อมูล [`std::mem::MaybeUninit`] (เสถียรแล้วในเวอร์ชัน 1.36) ทุกครั้งต้องมีเหตุผล
รองรับอย่างชัดเจนเมื่อจำเป็น

</div>

การใช้หน่วยความจำที่ยังไม่ถูกกำหนดค่าเริ่มต้นอาจส่งผลให้เกิดปัญหาด้านความปลอดภัยสองประการที่แตกต่างกัน:

- การดรอปหน่วยความจำที่ยังไม่ถูกกำหนดค่าเริ่มต้น (ซึ่งเป็นปัญหาความปลอดภัยของหน่วยความจำด้วย)
- การไม่ดรอปหน่วยความจำที่ถูกกำหนดค่าเริ่มต้นแล้ว

<div class="note">

[`std::mem::MaybeUninit`] เป็นการปรับปรุงที่ดีกว่า [`std::mem::uninitialized`]
กล่าวคือ มันทำให้การดรอปค่าที่ไม่ถูกกำหนดค่าเริ่มต้นยากขึ้นมาก
อย่างไรก็ตาม มันไม่ได้เปลี่ยนแปลงปัญหาประการที่สอง: การไม่ดรอปหน่วยความจำ
ที่ถูกกำหนดค่าเริ่มต้นแล้วยังคงอยู่ ปัญหานี้เป็นเรื่องน่ากังวล โดยเฉพาะเมื่อพิจารณา
การใช้ [`Drop`] เพื่อลบข้อมูลที่ละเอียดอ่อนออกจากหน่วยความจำ

</div>

[`std::mem::uninitialized`]: https://doc.rust-lang.org/std/mem/fn.uninitialized.html
[`std::mem::MaybeUninit`]: https://doc.rust-lang.org/beta/std/mem/union.MaybeUninit.html
