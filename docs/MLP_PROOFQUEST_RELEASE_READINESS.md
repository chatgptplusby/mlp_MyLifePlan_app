# MLP ProofQuest — competition tekshiruvi

2026-11-02. **Oraliq hisobot; demo release hali tasdiqlanmagan.**

Git bazasi: 8cca0d7 (University Edition). Boshlanishda goal_detail, quests_tab va university_edition_test dirty edi; ularga tegilmadi. Android settings/app Gradle fayllarini Copilot tuzatyapti, bu tekshiruv ularni tahrirlamaydi.

| Tekshiruv | Holat | Dalil / cheklov |
|---|---|---|
| Ilova ochilishi | NOT TESTED | Native ochilish hali tekshirilmadi; widget natija sahifasi ochildi |
| Goal / Mission saqlanishi | NOT TESTED | Mavjud store va seed tekshirildi, yakuniy regression kutilmoqda |
| Focus timer | NOT TESTED | Mission tugmasi fokusga o‘tadi, lekin mission bog‘lanishini tekshirish kerak |
| Evidence validatsiyasi | NOT TESTED | Store min 10 belgi va URL tekshiradi; UI xatoni yutishi tuzatildi; regression davom etmoqda |
| Lokal Blind Challenge | FAIL | Avval 2 javob 3 deb saqlangan. Kod tuzatildi; UI orqali ball va timeout regressiyasi kerak |
| False Proof Level | FAIL | Avval testsiz L3, +300 XP/+50 kredit chiqardi. Ikki UI dagi asossiz mukofot olib tashlandi; yakuniy tekshiruv davom etmoqda |
| Skill Passport | NOT TESTED | Endi saqlangan local test natijasini ko‘rsatadi; mustaqil tasdiq da’vosi yo‘q |
| Restart persistence | NOT TESTED | Test bajarilmoqda; avvalgi osilib qolgan fixture runAsync bilan tuzatildi. Oldingi progress xabaridagi restart PASS da’vosi hali tasdiqlanmagan |
| Offline | NOT TESTED | Store lokal, ammo real qurilmada tarmoqsiz to‘liq oqim hali bajarilmadi |
| Android build | NOT TESTED | Copilot tuzatishi bilan parallel build/edit qilinmaydi |
| Duplicate submission | NOT TESTED | Saqlash tugmasiga guard qo‘shildi; task XP regressiyasi bajarilmoqda |
| Data loss | FAIL | Core CRUD memory-first; disk yozuvi yiqilsa ko‘rinayotgan holat diskdan farq qilishi mumkin. Rollback/retry regressiyasi kerak |
| Null state / navigation | NOT TESTED | Repository yo‘q bo‘lsa endi muvaffaqiyat ko‘rsatilmaydi; boshlang‘ich indeks clamp qilindi |
| UI overflow | NOT TESTED | Kichik ekran / katta shrift matritsasi kutilmoqda |
| Firebase secrets | NOT TESTED | Maxfiy qiymatlarni logga chiqarmasdan alohida tekshirish kerak |

## Tuzatilgan kod

- `mlp_university_edition.dart`: haqiqiy score; soxta prefilling yo‘q; saqlash xatolari ko‘rinadi; qayta bosish guard; vaqt tugagandan so‘ng javob bloklanadi; sahifadan chiqishda timer bekor qilinadi; natija va pasport sodda, halol nusxaga o‘tdi.
- `mlp_progress_pages.dart`: hisobga ulanmagan XP/kredit mukofoti olib tashlandi.
- `mlp_proofquest_safety_test.dart`: yangi alohida regression fayli; boshqa AI testlari saqlangan.

## Dalillar

`evidence/proofquest-2026-11-02/analyze.log`: birinchi analyze — 6 lint/unused topilma, compile error yo‘q. Topilmalar tuzatildi; qayta analyze hali bajarilmadi.
`evidence/proofquest-2026-11-02/safety-test.log`: joriy test logi. Faqat terminal All tests passed natijasidan keyin PASS deb hisoblanadi.

Asossiz ball/L3 avval real kritik xato bo‘lgan. Tuzatish kodga kiritilishi testdan o‘tganini yoki native demo tayyorligini anglatmaydi.

## Yangilangan tasdiqlangan natija

Maqsadli regression: **3/3 PASS**, exit 0 (4 soniya):
- Bo‘sh natija va pasportda L3/soxta kredit berilmaydi.
- Saqlangan 2/3 natija yangi repository ochilganda aynan 2/3 ko‘rinadi.
- Yaroqsiz izoh missionni bajarmaydi; bir xil dalilni qayta yuborish XPni oshirmaydi; saqlangan dalil yangi storeda tiklanadi.

Bu widget/repository sinovlari. Yuqoridagi native/offline/build va to‘liq UI oqimi NOT TESTED holatlari saqlanadi. Asosiy challenge ekranidagi real javob bosish, timeout va xato yozuv holatlari hali alohida tekshiriladi.
