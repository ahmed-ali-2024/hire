# 🏆 Product Backlog – Hackathon Edition
## اسم التطبيق Hire
وكيل التوظيف الذكي | Band of Agents Hackathon
واجهة التطبيق الأساسية الانجليزية و يمكن التبديل للعربية
### Track 1: Internal Enterprise Workflows

---

> **مبدأ التنفيذ:** المشروع يُنفَّذ بوكلاء ذكاء اصطناعي. كل مهمة مكتوبة كـ Spec مباشر قابل للتنفيذ بـ prompt واضح بدون غموض.

> **قاعدة الهاكثون الذهبية:** Demo يعمل بالكامل > features كثيرة ناقصة.

---

## 📐 النطاق – ما يُبنى وما يُحذف

### ✅ في النطاق (MVP الهاكثون)
- رفع JD + سير ذاتية → تحليل → تقرير نهائي
- 5 وكلاء يتواصلون عبر Band Rooms
- Adversarial Pairing: وكيل رئيسي (AIMLAPI) + وكيل مراجع (Featherless)
- Band Activity Panel: عرض مرئي للرسائل في real-time
- Human-in-the-loop: زر موافقة مدير التوظيف
- تقرير نهائي مع التوصية

### ❌ خارج النطاق (Post-Hackathon)
- المقابلة التفاعلية الكاملة (chat interface للمرشح)
- دعم الصوت (Speech-to-Text)
- Analytics Dashboard
- تصدير PDF
- جدولة تنظيف الجلسات
- بيئات متعددة (staging/production)
- Sentry error monitoring

---

## 🏗️ Architecture Overview

```
[HR Manager UI – Flutter Web]
        │
        ▼
[RecruitmentOrchestrator]
        │
        ├──→ Band: createRoom("session_{id}")
        │
        ▼
[ScreeningAgent] ──AIMLAPI/GPT-4o──→ analyzes CV vs JD
        │
        │ Band: contextHandoff → ReviewerAgent
        ▼
[ReviewerAgent] ──Featherless/Mistral──→ challenges screening result
        │
        │ Band: reviewResult → Orchestrator
        ▼
[InterviewAgent + CulturalAgent] ──parallel──→ AIMLAPI
        │
        │ Band: finalEvaluation × 2 → CoordinatorAgent
        ▼
[CoordinatorAgent] → merges → Final Report
        │
        ▼
[HR Manager] → Approval/Rejection → Band: decision_logged
```

---

## 📊 Adversarial Pairing – الميزة التنافسية

```
الوكيل الرئيسي (AIMLAPI / GPT-4o)     الوكيل المراجع (Featherless / Mistral)
─────────────────────────────────     ──────────────────────────────────────
"المرشح مناسب بنسبة 85%"         ──→  "لا، الخبرة 3 سنوات وليس 5 – أقترح 70%"
                                         ↓
                              ConflictResolver
                                         ↓
                          النتيجة المدمجة: 75% + تعليق التعارض
                          [يظهر في الـ UI بأيقونة ⚡ للتعارض]
```

---

## 📋 المهام

### 🔧 المجموعة 1 – البنية التحتية

| # | المهمة | الأولوية | الـ Prompt للوكيل |
|---|--------|----------|-------------------|
| 1 | **إنشاء مشروع Flutter Web** | 🔴 حرجة | "أنشئ مشروع Flutter Web جديد بالهيكل التالي: lib/core/, lib/agents/, lib/screens/, lib/services/band/, lib/services/ai/. أضف go_router للتوجيه. نفّذ `flutter create --platforms web`" |
| 2 | **ربط Supabase** | 🔴 حرجة | "أضف supabase_flutter، أنشئ الجداول: recruitment_sessions (id, job_title, status, created_at)، candidates (id, session_id, name, cv_text, scores jsonb)، agent_results (id, session_id, candidate_id, agent_type, score, summary, recommendation, raw_data jsonb, created_at)، band_messages_log (id, room_id, message_type, sender, payload jsonb, created_at). فعّل RLS بسياسة anon read/write مؤقتاً للهاكثون." |
| 3 | **ربط Band API** | 🔴 حرجة | "أنشئ خدمة BandService في lib/services/band/band_service.dart. تحتوي على: createRoom(sessionId), sendMessage(roomId, type, payload), subscribeToRoom(roomId, onMessage). استخدم http package. المصادقة عبر Bearer token من .env" |
| 4 | **إدارة المتغيرات البيئية** | 🔴 حرجة | "أنشئ .env يحتوي: SUPABASE_URL, SUPABASE_ANON_KEY, AIMLAPI_KEY, FEATHERLESS_KEY, BAND_API_KEY, BAND_API_URL. استخدم flutter_dotenv لتحميلها في main.dart" |
| 5 | **GitHub Actions** | 🟡 عالية | "أنشئ .github/workflows/build.yml يبني flutter build web --release فقط عند push على main." |

---

### 🤖 المجموعة 2 – طبقة الوكلاء والبيانات

| # | المهمة | الأولوية | الـ Prompt للوكيل |
|---|--------|----------|-------------------|
| 6 | **Abstract Agent Base Class** | 🔴 حرجة | "أنشئ abstract class BaseAgent في lib/agents/base_agent.dart بالخصائص: agentId, agentType (enum: screening, reviewer, interview, cultural, coordinator), bandRoomId. والطرق: Future<AgentResult> execute(AgentContext ctx), void onMessageReceived(BandMessage msg). AgentResult يحتوي: score (double), summary (String), recommendation (enum), rawData (Map)" |
| 7 | **طبقة تكامل AIMLAPI** | 🔴 حرجة | "أنشئ AimlApiService في lib/services/ai/aiml_service.dart. دالة: Future<String> complete(String systemPrompt, String userPrompt, {String model = 'gpt-4o'}). استخدم https://api.aimlapi.com/v1/chat/completions متوافقة مع OpenAI API. أضف retry منطق: 3 محاولات مع exponential backoff." |
| 8 | **طبقة تكامل Featherless** | 🔴 حرجة | "أنشئ FeatherlessService في lib/services/ai/featherless_service.dart. نفس الواجهة بالضبط مع AimlApiService لكن يتصل بـ https://api.featherless.ai/v1. افتراضي model: 'mistralai/Mistral-7B-Instruct-v0.3'. سيُستخدم حصرياً للـ Reviewer Agent و Candidate Simulator." |
| 9 | **Band Message Types** | 🔴 حرجة | "أنشئ enum BandMessageType: contextHandoff, reviewRequest, reviewResult, finalEvaluation, coordinatorSync. أنشئ class BandMessage بالحقول: type, senderId, receiverId, candidateId, payload (Map<String, dynamic>), timestamp. أضف toJson/fromJson." |
| 10 | **استخراج نص PDF/DOCX** | 🔴 حرجة | "أضف flutter_file_picker. أنشئ CVParserService: يقبل File، يحول PDF باستخدام pdf package لاستخراج النص، يُرجع String. لو فشل: استخدم Supabase Storage لرفع الملف ثم استدعِ Supabase Edge Function بسيطة تستخدم Node.js pdftotext." |

---

### 🧠 المجموعة 3 – وكيل الفرز + Adversarial Pairing ⭐

> **قلب التمييز عن المنافسين.** Adversarial Pairing هو ما يجعل مشروعك فريداً — AI يحكّم AI.

| # | المهمة | الأولوية | الـ Prompt للوكيل |
|---|--------|----------|-------------------|
| 11 | **Screening Agent (AIMLAPI)** | 🔴 حرجة | "أنشئ ScreeningAgent extends BaseAgent في lib/agents/screening_agent.dart. يستخدم AimlApiService مع GPT-4o. System prompt: 'أنت خبير توظيف. حلل السيرة الذاتية مقارنةً بمتطلبات الوظيفة. أخرج JSON فقط: {match_score: 0-100, matched_skills: [], missing_skills: [], experience_years: int, summary: string, recommendation: accept/reject/maybe}'. بعد التنفيذ: أرسل رسالة Band من نوع contextHandoff تحتوي النتيجة كاملة." |
| 12 | **Reviewer Agent (Featherless) ⭐** | 🔴 حرجة | "أنشئ ReviewerAgent extends BaseAgent في lib/agents/reviewer_agent.dart. يستخدم FeatherlessService مع Mistral. يستقبل رسالة contextHandoff من ScreeningAgent. System prompt: 'أنت محكّم مستقل. راجع تقييم الفرز المقدم وحدد: هل التقييم دقيق؟ هل هناك تحيز؟ اختلف إذا كان الدليل يستدعي ذلك. أخرج JSON: {agrees: bool, confidence: 0-100, revised_score: int_or_null, critique: string, final_recommendation: accept/reject/maybe}'. أرسل reviewResult عبر Band." |
| 13 | **منطق حل التعارض** | 🔴 حرجة | "أنشئ ConflictResolver في lib/agents/conflict_resolver.dart. إذا اتفق الوكيلان: استخدم متوسط الدرجات. إذا اختلفا باختلاف > 20 نقطة: الدرجة النهائية = متوسط مرجح (Screener 60% + Reviewer 40%) مع إضافة تعليق 'تعارض في التقييم – يُنصح بمراجعة بشرية'. سجّل النتيجة في agent_results." |

---

### 🎤 المجموعة 4 – وكلاء المقابلة والتقييم

| # | المهمة | الأولوية | الـ Prompt للوكيل |
|---|--------|----------|-------------------|
| 14 | **Technical Interview Agent** | 🔴 حرجة | "أنشئ InterviewAgent extends BaseAgent. يستقبل contextHandoff من ReviewerAgent (يحتوي: skills, experience_level, candidate_id). System prompt لـ AIMLAPI GPT-4o: 'بناءً على مهارات المرشح {skills} ومستوى خبرته {level}، ولّد 3 أسئلة تقنية متدرجة مع الإجابات المثالية. ثم قيّم إجاباته المقدمة. أخرج JSON: {questions: [{q, ideal_answer, candidate_answer, score_0_10}], overall_technical_score: 0-100, summary: string}'. الإجابات تُولَّد بـ CandidateSimulator في MVP." |
| 15 | **Candidate Simulator** | 🔴 حرجة | "أنشئ CandidateSimulatorAgent يستخدم FeatherlessService. يستقبل الأسئلة التقنية ويولد إجابات 'مرشح حقيقي': بعضها صحيح، بعضها ناقص، بعضها خاطئ. System prompt: 'أنت مرشح يجيب على أسئلة تقنية. أجب بشكل طبيعي وغير مثالي لمحاكاة مرشح حقيقي.' هذا يتيح demo كامل بدون مرشح بشري." |
| 16 | **Cultural Assessment Agent** | 🟡 عالية | "أنشئ CulturalAgent extends BaseAgent. يستقبل بيانات المرشح. يُولد 3 أسئلة سلوكية ويقيّم الإجابات المُحاكاة. System prompt: 'قيّم توافق المرشح مع قيم: التعاون، الابتكار، المسؤولية. أخرج JSON: {cultural_fit_score: 0-100, traits_observed: [], concerns: [], summary: string}'. استخدم AimlApiService." |
| 17 | **Coordination Agent** | 🔴 حرجة | "أنشئ CoordinatorAgent extends BaseAgent. ينتظر رسائل finalEvaluation من InterviewAgent و CulturalAgent عبر Band. بعد استلام كليهما: يدمج النتائج، يحسب الدرجة الإجمالية (Screening 40% + Technical 40% + Cultural 20%)، ينشئ التقرير النهائي JSON، يرسل coordinatorSync لتحديث الـ UI، يحفظ في Supabase." |

---

### 🔄 المجموعة 5 – التنسيق والتكامل

| # | المهمة | الأولوية | التفاصيل |
|---|--------|----------|---------|
| 18 | **RecruitmentOrchestrator** | 🔴 حرجة | دالة مركزية تدير تسلسل الوكلاء: (1) أنشئ Band Room، (2) سجّل الوكلاء، (3) شغّل ScreeningAgent، (4) انتظر reviewResult، (5) شغّل InterviewAgent + CulturalAgent بالتوازي، (6) انتظر كليهما، (7) شغّل CoordinatorAgent. كل خطوة تُحدث progress في Supabase. |
| 19 | **Error Handling شامل** | 🔴 حرجة | كل API call محمية بـ try/catch مع رسائل خطأ واضحة. لو فشل وكيل: أعد المحاولة مرة واحدة، إذا فشل مجدداً: اعرض "فشل {اسم_الوكيل} – حاول مجدداً" مع زر retry. لا تترك الـ UI يتجمد بدون feedback. |

---

### 🖥️ المجموعة 6 – واجهة المستخدم

| # | المهمة | الأولوية | الـ Prompt للوكيل |
|---|--------|----------|-------------------|
| 20 | **لوحة التحكم الرئيسية** | 🔴 حرجة | "أنشئ DashboardScreen: قائمة recruitment_sessions من Supabase مع realtime subscription. كل جلسة تعرض: عنوان الوظيفة، عدد المرشحين، الحالة (analyzing/completed). زر 'إنشاء عملية جديدة' يفتح NewRecruitmentScreen. استخدم Material 3 + directionality RTL." |
| 21 | **نموذج إنشاء طلب التوظيف** | 🔴 حرجة | "أنشئ NewRecruitmentScreen: حقل نص لعنوان الوظيفة، TextField متعدد الأسطر لمتطلبات الوظيفة، FilePicker لرفع سير ذاتية متعددة (PDF/DOCX). زر 'بدء التحليل' يستدعي RecruitmentOrchestrator.start()." |
| 22 | **⭐ Band Activity Panel** | 🔴 حرجة | "أنشئ BandActivityPanel كـ Widget جانبي يظهر أثناء التحليل. يستمع لجدول band_messages_log في Supabase Realtime. لكل رسالة جديدة يعرض: أيقونة الوكيل المُرسِل ← أيقونة المستقبل، نوع الرسالة بالعربي ('تسليم السياق'، 'طلب مراجعة'، 'تقييم نهائي')، timestamp، زر '↗ التفاصيل' يفتح dialog يعرض JSON payload كاملاً." |
| 23 | **شاشة نتائج الفرز** | 🔴 حرجة | "أنشئ ResultsScreen: قائمة المرشحين مع Progress indicator للدرجة الإجمالية. بطاقة لكل مرشح تعرض: الدرجة الإجمالية، درجة الفرز (Screener vs Reviewer مع مؤشر الاتفاق/الاختلاف ⚡)، درجة المقابلة، درجة الثقافة، التوصية (قبول/رفض/مراجعة) مع لون semantically correct." |
| 24 | **شاشة التقرير النهائي** | 🔴 حرجة | "أنشئ FinalReportScreen: عرض التقرير الكامل لكل مرشح. Accordion sections: ملخص الفرز + رأي المراجع، الأسئلة التقنية والإجابات، التقييم الثقافي. في الأسفل: زر 'موافقة وإرسال العرض' (يغير status في Supabase)، زر 'رفض'، زر 'إعادة مراجعة'." |
| 25 | **Loading & Feedback States** | 🟡 عالية | Loading indicators أثناء عمل كل وكيل. Animations بسيطة: pulse على أيقونة الوكيل النشط. ألوان متسقة. Responsive لشاشات مختلفة. |

---

### 🚀 المجموعة 7 – النشر والـ Demo

| # | المهمة | الأولوية | التفاصيل |
|---|--------|----------|---------|
| 26 | **بيانات Demo جاهزة** | 🔴 حرجة | أنشئ: (1) JD لوظيفة "Flutter Developer Senior" بمتطلبات واضحة، (2) 3 سير ذاتية: مرشح قوي، متوسط، ضعيف. احفظها كـ sample_data/ في المشروع. |
| 27 | **نشر إلى الإنترنت** | 🔴 حرجة | `flutter build web --release` ثم نشر على Vercel أو Firebase Hosting. |
| 28 | **وثيقة المشروع (README)** | 🔴 حرجة | README يجيب على: ما المشكلة؟ كيف يحلها Band؟ كيف تعمل الوكلاء معاً؟ Architecture diagram. كيف تشغّل المشروع محلياً. |
| 29 | **سكريبت فيديو الـ Demo** | 🔴 حرجة | **(2 دقيقة):** (00:00) "لديك 40 سيرة ذاتية وتحتاج موظفاً في يومين..." → (00:20) افتح الداشبورد، أنشئ طلب جديد → (00:35) ارفع JD و 3 سير ذاتية، اضغط 'بدء التحليل' → (00:45) أظهر Band Panel وهو يعرض الرسائل live → (01:10) **أبرز لحظة:** وكيل المراجعة يختلف مع وكيل الفرز → (01:30) تقرير نهائي مع 3 مرشحين مصنّفين → (01:50) موافقة على المرشح الأول. |
| 30 | **تقديم المشروع على lablab.ai** | 🔴 حرجة | رفع: رابط المشروع، رابط GitHub، فيديو الـ Demo، وصف يُبرز: (1) Adversarial Pairing cross-model، (2) استخدام كلا AIMLAPI و Featherless، (3) Band Activity Panel. |

---

## ✅ Checklist القبول النهائي

- [ ] رفع JD + 3 سير ذاتية يعمل بدون أخطاء
- [ ] Band Panel يعرض الرسائل في real-time
- [ ] Adversarial Pairing يظهر اتفاق/اختلاف الوكيلين بوضوح
- [ ] 5 وكلاء يُكملون مهامهم بالترتيب الصحيح
- [ ] التقرير النهائي يعرض 3 درجات + توصية
- [ ] زر الموافقة يعمل ويغير الحالة
- [ ] Demo video لا يتجاوز 3 دقائق

---

## 🔴 تحذيرات للوكلاء المنفذين

1. **ابدأ بالـ Agents والـ Band integration** قبل الـ UI
2. **كل Agent يُسجّل رسائله في band_messages_log** – Band Panel يعتمد عليه
3. **الـ Conflict في Adversarial Pairing ليس bug** – هو feature، أبرزه في الـ UI بأيقونة ⚡
4. **CandidateSimulator ضروري** – بدونه لا يعمل الـ demo للـ Interview Agent
5. **اختبر على Chrome فقط** – Flutter Web على Chrome الأفضل للهاكثون
