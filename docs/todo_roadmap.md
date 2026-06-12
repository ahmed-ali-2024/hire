# خريطة الطريق وقائمة المهام (Todo Roadmap) لمشروع Hire
حتى تاريخ 2026-6-12 
تم إعداد هذه الوثيقة لتكون مرجعاً تتابعياً لأي جلسة تطوير جديدة. توضح هذه الخريطة ما تم إنجازه بالكامل، وما هو قيد التنفيذ، والمهام المتبقية بناءً على وثيقة الشروط والمواصفات [hire_sdd.md](file:///media/ahmed/projects/projects/a3a_app/hire/docs/hire_sdd.md)، بالإضافة إلى المهام المطلوبة من المستخدم.

> [!IMPORTANT]
> **استراتيجية النسخة التجريبية (Demo Mode):** هذا الإصدار مخصص للجنة التحكيم. مفاتيح API تُخزن في الـ Backend (Supabase Edge Functions Secrets) وتخدم جميع المستخدمين بدون حاجة لإدخال أي مفتاح. صفحة تسجيل الدخول تعرض بيانات حساب تجريبي جاهز.

---

## 🛠️ حالة المراحل البرمجية (Core & Feature Checklist)

### [x] **المرحلة 0: البنية التحتية والخدمات المشتركة (Core)**
- [x] إعداد ملفات البيئة والمحاكاة لـ `.env` و `.env.example`.
- [x] إنشاء كلاس `EnvironmentConfig` الآمن لقراءة وإدارة المتغيرات والمفاتيح.
- [x] كتابة الخدمات المشتركة الأساسية:
  - `ConnectivityService` (فحص الاتصال متخطياً قيود CORS على الويب).
  - `PlatformService` (منع استخدام `dart:io` على الويب وتأمين البناء).
  - `ResponsiveService` (تأمين استجابة النوافذ).
  - `AppLogger` (نظام تسجيل وتتبع الأخطاء الموحد).
- [x] كتابة خدمة تفسير السير الذاتية `CVParserService` (استخلاص النصوص والأسماء محلياً من ملفات PDF).
- [x] تهيئة الترجمة الثنائية (العربية والإنجليزية) والـ RTL وحفظ خيار المستخدم مستمراً في `LocaleCubit`.
- [x] تهيئة الثيم التجميلي الحديث Outfit للوضعين الداكن والفاتح في `ThemeCubit`.
- [x] إعداد حقن الاعتماديات بالكامل في [injection_container.dart](file:///media/ahmed/projects/projects/a3a_app/hire/lib/core/di/injection_container.dart).

---

### [x] **المرحلة 1: نظام المصادقة (Auth - F01)**
- [x] إنشاء هياكل وموديلات مستخدم سوبابيس (`UserEntity`, `UserModel`).
- [x] بناء `AuthRepositoryImpl` و `AuthRemoteDataSource` المربوط بـ `Supabase Auth`.
- [x] كتابة الـ Use Cases الأربعة (تسجيل الدخول، التسجيل، التحقق، الخروج).
- [x] إدارة الحالة عبر `AuthCubit`.
- [x] تصميم واجهات المصادقة التجميلية المستجيبة (`LoginPage`, `RegisterPage`, `AuthFormWidget`).
- [x] بناء نظام التوجيه وحماية المسارات (Route Guards) عبر `GoRouter` لضمان عدم دخول غير المسجلين.
- [x] **[تمت إضافته]** بطاقة بيانات الحساب التجريبي (Demo Account) في صفحة تسجيل الدخول تعرض البريد وكلمة المرور للجنة التحكيم مع إبقاء خيار التسجيل الجديد متاحاً.

---

### [x] **المرحلة 2: إعدادات مفاتيح الـ API ~~الخاصة بالمستخدم~~ → المركزية في الباك اند (Settings - F02)**

> [!WARNING]
> **تغيير جوهري في الاستراتيجية:** تم إلغاء نهج "كل مستخدم يدخل مفاتيحه" واستبداله بنهج "المفاتيح مخزنة مركزياً في الباك اند" عبر Supabase Edge Functions Secrets. هذا يعني:
> - ❌ ~~صفحة الإعدادات لإدخال مفاتيح API~~ (لم تعد مطلوبة)
> - ❌ ~~SettingsCubit لحفظ وجلب المفاتيح من جدول user_secrets~~ (لم يعد مطلوباً)
> - ✅ المفاتيح تُخزن كـ Secrets في مشروع Supabase وتُستخدم داخل Edge Functions فقط
> - ✅ أي مستخدم يفتح التطبيق يمكنه استخدامه مباشرة بدون إعدادات

- [x] إنشاء الهياكل والموديلات (`ApiKeysEntity`, `ApiKeysModel`). *(أصبحت مرجعية فقط)*
- [x] إعداد جدول قاعدة البيانات `user_secrets` لتخزين مفاتيح المستخدم بأمان مع سياسة RLS. *(لم يعد يُستخدم لإدخال المفاتيح)*
- [x] تسجيل الـ Use Cases والـ Repository والـ DataSource الخاص بالإعدادات في GetIt. *(أصبح مرجعياً)*
- [x] ~~بناء الـ `SettingsCubit`~~ → **ملغاة** - المفاتيح ستكون في Edge Functions.
- [x] ~~تصميم صفحة الإعدادات~~ → **ملغاة** - لا حاجة لإدخال مفاتيح يدوياً.
- [ ] **[متبقي - جديد]** تخزين مفاتيح API كـ Secrets في مشروع Supabase:
  ```
  supabase secrets set AIMLAPI_KEY=xxx FEATHERLESS_KEY=xxx BAND_API_KEY=xxx BAND_API_URL=xxx
  ```
- [ ] **[متبقي - جديد]** إنشاء Supabase Edge Functions تعمل كوسيط (Proxy) بين التطبيق وخدمات الذكاء الاصطناعي:
  - `analyze-cv` → يستقبل نص السيرة الذاتية + الوصف الوظيفي ويستدعي Screening Agent عبر AIMLAPI.
  - `review-cv` → يستدعي Adversarial Reviewer عبر Featherless.
  - `simulate-interview` → يستدعي Interview Agent ومحاكي المتقدم.
  - `cultural-fit` → يستدعي Cultural Fit Agent.
  - `coordinate` → يستدعي Coordinator Agent لكتابة التقرير النهائي.
  - `band-relay` → يسجل ويوجه رسائل Band API بين الوكلاء.
- [ ] **[متبقي - جديد]** تعديل طبقة الـ DataSource في التطبيق لاستدعاء Edge Functions بدلاً من الـ APIs مباشرة (الاستدعاء عبر `Supabase.instance.client.functions.invoke()`).

---

### [x] **المرحلة 3: إدارة الجلسات ورفع الملفات (Recruitment & Upload - F03, F04)**
- [x] إنشاء هياكل الجلسات والمرشحين (`RecruitmentSessionEntity`, `CandidateEntity`).
- [x] بناء مستودعات البيانات والاتصال بسوبابيس لجلب وإنشاء الجلسات وإضافة المرشحين.
- [x] إنشاء `FileUploadCubit` لإدارة رفع وتفسير ملفات PDF.
- [x] تصميم صفحة إنشاء جلسة جديدة [new_recruitment_page.dart](file:///media/ahmed/projects/projects/a3a_app/hire/lib/features/recruitment/presentation/pages/new_recruitment_page.dart) وربطها بنجاح لتقوم بإنشاء الجلسة ورفع وتفسير السير الذاتية وتخزينها في قاعدة البيانات.
- [x] **[تم إصلاحه]** حل مشكلة الشاشة البيضاء بعد تحليل السيرة الذاتية (Navigator Lock مع GoRouter) باستبدال `showDialog/pop` بمتغير حالة `_isLoading`.
- [x] **[تم إنجازه]** تعديل شاشة لوحة التحكم `DashboardPage` لتعرض قائمة بجلسات التوظيف السابقة للمسؤول بدلاً من الواجهة الاستاتيكية الحالية.
- [x] **[تم إنجازه]** بناء شاشة تفاصيل الجلسة (`SessionDetailPage`) التي تُعرض عند النقر على إحدى الجلسات، لتعرض قائمة المرشحين المرفوعة سيرهم الذاتية، وحالاتهم، مع توفير زر "بدء تحليل الوكلاء".
- [x] **[تم إنجازه]** إعداد المسارات والتوجيه والـ Cubit الخاصة بتفاصيل الجلسة (`SessionDetailCubit` و `/app/recruitment/:id`) وتأكيد خلو الكود من أي أخطاء أو تحذيرات بناء.

---

### [ ] **المرحلة 4: نظام التنسيق وتشغيل الوكلاء الخمسة (Orchestration & Agents - F05-F08)**

> [!NOTE]
> جميع استدعاءات الوكلاء ستتم عبر **Supabase Edge Functions** بدلاً من الاتصال المباشر بـ APIs. التطبيق يرسل البيانات إلى Edge Function → Edge Function تستخدم المفاتيح المخزنة كـ Secrets → تُعيد النتيجة للتطبيق.

- [ ] بناء الهياكل والموديلات لنتائج تقييم الوكلاء وتقارير التعارض والتقرير النهائي.
- [ ] إنشاء `OrchestrationRepository` و `OrchestrationRemoteDataSource` يستدعي Edge Functions بدلاً من APIs مباشرة.
- [ ] كتابة Use Cases تشغيل الوكلاء الخمسة تتابعياً:
  1. **Screening Agent** (Edge Function: `analyze-cv`) - فحص السيرة الذاتية الأولي.
  2. **Adversarial Reviewer** (Edge Function: `review-cv`) - مراجعة مستقلة لكشف التحيز.
  3. **Conflict Resolution** - حل التعارض ودمج الدرجات (يمكن أن يكون محلياً أو Edge Function).
  4. **Interview Agent & Candidate Simulator** (Edge Function: `simulate-interview`) - توليد ومحاكاة المقابلة التقنية.
  5. **Cultural Fit Agent** (Edge Function: `cultural-fit`) - تقييم السلوك والتوافق الثقافي.
  6. **Coordinator Agent** (Edge Function: `coordinate`) - كتابة التقرير النهائي المدمج والتوصية النهائية.
- [ ] ربط الاتصال بـ **Band API** عبر Edge Function (`band-relay`) لإرسال واستلام رسائل تسليم السياق (Context Handoff) وتسجيلها في جدول `band_messages_log` في كل خطوة.
- [ ] بناء `OrchestrationCubit` لإدارة تشغيل وتتبع مراحل الوكلاء خطوة بخطوة.
- [ ] تصميم صفحة التحليل (`AnalysisPage`) التي تعرض مؤشرات تقدم عمل الوكلاء بشكل تفاعلي أثناء التشغيل.

---

### [ ] **المرحلة 5: لوحة نشاط Band والتقارير النهائية (F09, F10)**
- [ ] بناء `BandActivityCubit` للاستماع الفوري (Realtime) لرسائل الوكلاء المسجلة في جدول `band_messages_log` وعرضها في شريط جانبي متحرك (Band Activity Panel) أثناء التحليل.
- [ ] بناء شاشة التقارير الكاملة للجلسة (`ReportsPage`) لعرض المرشحين ودرجاتهم الإجمالية والفرعية وتوصية الوكلاء.
- [ ] تصميم شاشة تقرير المرشح المفصل (`CandidateReportPage`) لعرض التقرير النهائي، ونقاط القوة والضعف، وسجل إجابات المقابلة المحاكاتية، مع أزرار للموافقة أو الرفض البشري النهائي.

---

### [ ] **المرحلة 6: الفحص والاختبار والتكامل النهائي**
- [ ] اختبار توافق التصفح الكامل على Flutter Web (Chrome).
- [ ] التأكد من خلو المشروع تماماً من أي تعارضات أو أخطاء برمجية في التحليل والتجميع.

---

## 👤 المهام المطلوبة من المستخدم (User Actions Required)

لكي يعمل النظام بشكل متكامل، يُطلب من المستخدم **إجراء واحد فقط**:

### 🔑 إعداد مفاتيح API في Supabase (مرة واحدة فقط)
يجب تخزين المفاتيح كـ Secrets في مشروع Supabase لتعمل Edge Functions:
```bash
# من مجلد المشروع (بعد تسجيل الدخول لـ Supabase CLI)
supabase secrets set AIMLAPI_KEY=your_aimlapi_key_here
supabase secrets set FEATHERLESS_KEY=your_featherless_key_here
supabase secrets set BAND_API_KEY=your_band_api_key_here
supabase secrets set BAND_API_URL=your_band_api_url_here
```

> [!CAUTION]
> **لا تضع المفاتيح في ملف `.env` ولا في الكود المصدري ولا في قاعدة البيانات.** استخدم حصراً `supabase secrets set` لتخزينها على مستوى الـ Backend.

> [!TIP]
> بعد تخزين المفاتيح، أي مستخدم (سواء لجنة التحكيم أو غيرهم) يمكنه استخدام التطبيق مباشرة بدون أي إعدادات إضافية. البيانات التجريبية (Demo Account) معروضة في صفحة تسجيل الدخول.

---

## 📊 ملخص التقدم

| المرحلة | الحالة | النسبة |
|---------|--------|--------|
| 0 - البنية التحتية | ✅ مكتمل | 100% |
| 1 - المصادقة | ✅ مكتمل | 100% |
| 2 - مفاتيح API (باك اند) | 🔄 جزئي | 40% (الهياكل جاهزة، Edge Functions متبقية) |
| 3 - الجلسات والرفع | ✅ مكتمل | 100% |
| 4 - الوكلاء والتنسيق | ⏳ لم يبدأ | 0% |
| 5 - التقارير و Band | ⏳ لم يبدأ | 0% |
| 6 - الاختبار النهائي | ⏳ لم يبدأ | 0% |
