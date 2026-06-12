# Spec: Hire
> **الإصدار:** 1.0  
> **المعمارية:** 3AAI Flutter Clean Architecture v2.0  
> **أسلوب التطوير:** Spec-Driven Development  
> **ملاحظة للـ Agent:** اقرأ هذا الـ Spec كاملاً قبل كتابة سطر واحد. نفّذ الخطوات بالترتيب المحدد. لا تتخطَّ خطوة. لا تتخذ قرارات غير محددة هنا.

---

## القواعد الذهبية — 3AAI (الـ Agent المُنفِّذ يلتزم بها صارماً)

```
1. Domain Layer لا يستورد شيئاً خارجه: لا flutter، لا data layer. مسموح فقط: fpdart, equatable
2. كل Repository يُرجع Either<Failure, T> من fpdart (لا dartz)
3. لا try/catch في Cubits — فقط result.fold()
4. App-Level Cubits = registerLazySingleton | Feature Cubits = registerFactory (الخلط = bug حرج)
5. لا print() — فقط AppLogger.instance.i/d/w/e()
6. لا assert() في الإنتاج — فقط throw StateError()
7. فحص الاتصال بالشبكة أول شيء في كل دالة Repository تستدعي API
8. كل عنصر تفاعلي: 48×48 بكسل حداً أدنى
9. لا dartz — فقط fpdart
10. لا dart:io في Domain أو Presentation — فقط PlatformService
```

---

## 1. نظرة عامة على المشروع

### 1.1 وصف التطبيق

**Hire** هو نظام توظيف ذكي متعدد الوكلاء مبني على Flutter Web. يستقبل وصفاً وظيفياً وسيراً ذاتية، ثم يُشغّل خمسة وكلاء ذكاء اصطناعي يتواصلون عبر منصة **Band** لتحليل المرشحين واختيار الأنسب تلقائياً. الميزة المحورية هي **Adversarial Pairing**: وكيل الفرز الرئيسي (AIMLAPI/GPT-4o) يتنافس مع وكيل مراجعة مستقل (Featherless/Mistral) لضمان تقييم موضوعي خالٍ من التحيز.

### 1.2 أدوار المستخدمين

| الدور | الوصف | الصلاحيات الرئيسية |
|-------|-------|-------------------|
| `hr_manager` | مسؤول التوظيف، المستخدم الوحيد في هذه النسخة | إنشاء جلسات توظيف، رفع ملفات، مشاهدة نتائج الوكلاء، الموافقة/الرفض على المرشحين |

### 1.3 المنصات المستهدفة

- **Flutter Web** (Chrome أولاً — Chrome-only للهاكثون)

### 1.4 الـ Backend

- **Supabase** — Database + Auth + Storage + Realtime
- **AIMLAPI** — `https://api.aimlapi.com/v1` (OpenAI-compatible)
- **Featherless.ai** — `https://api.featherless.ai/v1` (OpenAI-compatible)
- **Band API** — `${BAND_API_URL}` (REST — يتحدد من متغير البيئة)

### 1.5 اللغات المدعومة

- **الافتراضية:** الإنجليزية (`en`)
- **المدعومة:** الإنجليزية + العربية (`ar`)
- المستخدم يُبدّل اللغة من أي شاشة — القرار محفوظ في `LocaleCubit` (HydratedCubit)
- دعم RTL كامل عند تفعيل العربية

---

## 2. قائمة الميزات

### Core Features

| # | الميزة | الوصف | الأولوية |
|---|--------|-------|---------|
| F01 | Authentication | تسجيل دخول/خروج + حماية المسارات | عالية |
| F02 | API Keys Settings | حفظ مفاتيح AIMLAPI, Featherless, Band في Supabase | عالية |
| F03 | Recruitment Session Management | إنشاء وعرض وتتبع جلسات التوظيف | عالية |
| F04 | File Upload & CV Parsing | رفع JD + سير ذاتية PDF/DOCX وتحويلها لنص | عالية |
| F05 | Screening + Adversarial Review | وكيل الفرز (AIMLAPI) + وكيل المراجعة (Featherless) + حل التعارض | عالية |
| F06 | Technical Interview Agent | توليد أسئلة تقنية + CandidateSimulator (Featherless) | عالية |
| F07 | Cultural Assessment Agent | أسئلة سلوكية + تقييم التوافق الثقافي (AIMLAPI) | عالية |
| F08 | Orchestration & Coordination | تنسيق تسلسل الوكلاء + التقرير النهائي + زر الموافقة | عالية |
| F09 | Band Activity Panel | عرض رسائل Band بين الوكلاء في real-time | عالية |
| F10 | Reports & Results Dashboard | عرض نتائج الفرز والتقارير النهائية للمرشحين | عالية |

### Enhanced Features (Post-Hackathon)

| # | الميزة | الوصف |
|---|--------|-------|
| F20 | Interactive Interview UI | واجهة محادثة مباشرة مع المرشح البشري |
| F21 | Email Notifications | إرسال بريد للمرشح المقبول |
| F22 | Onboarding Bundle | توليد حزمة الترحيب للموظف الجديد |

### Future Features

| # | الميزة | الوصف |
|---|--------|-------|
| F30 | Analytics Dashboard | رسوم بيانية عن معدلات القبول |
| F31 | PDF Export | تصدير التقرير النهائي كـ PDF |
| F32 | Voice Interview | تسجيل إجابات المرشح عبر الميكروفون |

> ⚠️ تنبيه للـ Agent: نفّذ Core Features (F01–F10) فقط. لا تُنشئ ملفات للـ Enhanced أو Future.

---

## 3. نموذج البيانات (Entities)

> ⚠️ تنبيه للـ Agent: كل Entity تُنشأ في مسارها المحدد. كل Entity تمتد من `BaseEntity` وتستخدم `Equatable`.

---

### Entity: UserEntity
**المسار:** `lib/features/auth/domain/entities/user_entity.dart`  
**الاستخدام:** F01 — Auth

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف Supabase |
| email | String | ✅ | البريد الإلكتروني |
| createdAt | DateTime | ✅ | تاريخ الإنشاء |

---

### Entity: ApiKeysEntity
**المسار:** `lib/features/settings/domain/entities/api_keys_entity.dart`  
**الاستخدام:** F02 — Settings

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف السجل |
| userId | String | ✅ | معرف المستخدم |
| aimlApiKey | String | ✅ | مفتاح AIMLAPI |
| featherlessKey | String | ✅ | مفتاح Featherless |
| bandApiKey | String | ✅ | مفتاح Band API |
| bandApiUrl | String | ✅ | رابط Band API |
| updatedAt | DateTime | ✅ | آخر تحديث |

---

### Entity: RecruitmentSessionEntity
**المسار:** `lib/features/recruitment/domain/entities/recruitment_session_entity.dart`  
**الاستخدام:** F03, F08, F10

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف الجلسة |
| userId | String | ✅ | معرف المستخدم |
| jobTitle | String | ✅ | عنوان الوظيفة |
| jobDescription | String | ✅ | نص متطلبات الوظيفة |
| status | SessionStatus | ✅ | pending / analyzing / completed |
| bandRoomId | String? | ❌ | معرف غرفة Band (يُعيَّن عند بدء التحليل) |
| candidatesCount | int | ✅ | عدد المرشحين |
| createdAt | DateTime | ✅ | تاريخ الإنشاء |
| updatedAt | DateTime | ✅ | آخر تحديث |

**enum SessionStatus:** `pending, analyzing, completed, failed`

---

### Entity: CandidateEntity
**المسار:** `lib/features/recruitment/domain/entities/candidate_entity.dart`  
**الاستخدام:** F04, F05, F06, F07, F08, F10

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف المرشح |
| sessionId | String | ✅ | معرف الجلسة |
| name | String | ✅ | اسم المرشح (مُستخرَج من الملف) |
| cvText | String | ✅ | نص السيرة الذاتية المُستخرَج |
| fileName | String | ✅ | اسم الملف الأصلي |
| overallScore | double? | ❌ | الدرجة الإجمالية (تُحسب بعد التحليل) |
| status | CandidateStatus | ✅ | pending / analyzing / analyzed / accepted / rejected / review_requested |
| createdAt | DateTime | ✅ | تاريخ الإضافة |

**enum CandidateStatus:** `pending, analyzing, analyzed, accepted, rejected, reviewRequested`

---

### Entity: AgentResultEntity
**المسار:** `lib/features/orchestration/domain/entities/agent_result_entity.dart`  
**الاستخدام:** F05, F06, F07, F08, F10

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف النتيجة |
| sessionId | String | ✅ | معرف الجلسة |
| candidateId | String | ✅ | معرف المرشح |
| agentType | AgentType | ✅ | نوع الوكيل |
| score | double | ✅ | الدرجة (0–100) |
| summary | String | ✅ | ملخص نصي |
| recommendation | AgentRecommendation | ✅ | accept / reject / maybe |
| rawData | Map<String, dynamic> | ✅ | البيانات الكاملة من الوكيل (JSON) |
| createdAt | DateTime | ✅ | تاريخ الإنشاء |

**enum AgentType:** `screening, adversarialReview, technicalInterview, culturalAssessment, coordination`  
**enum AgentRecommendation:** `accept, reject, maybe`

---

### Entity: ConflictResolutionEntity
**المسار:** `lib/features/orchestration/domain/entities/conflict_resolution_entity.dart`  
**الاستخدام:** F05 — Adversarial Pairing

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| candidateId | String | ✅ | معرف المرشح |
| screeningScore | double | ✅ | درجة وكيل الفرز |
| reviewScore | double | ✅ | درجة وكيل المراجعة |
| finalScore | double | ✅ | الدرجة المدمجة النهائية |
| hasConflict | bool | ✅ | true إذا كان الفرق > 20 نقطة |
| conflictNote | String? | ❌ | نص تحذير التعارض (يظهر في UI) |
| finalRecommendation | AgentRecommendation | ✅ | التوصية النهائية المدمجة |

---

### Entity: BandMessageEntity
**المسار:** `lib/features/orchestration/domain/entities/band_message_entity.dart`  
**الاستخدام:** F09 — Band Activity Panel

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف الرسالة |
| roomId | String | ✅ | معرف غرفة Band |
| sessionId | String | ✅ | معرف الجلسة |
| candidateId | String | ✅ | معرف المرشح |
| messageType | BandMessageType | ✅ | نوع الرسالة |
| senderAgent | AgentType | ✅ | الوكيل المُرسِل |
| receiverAgent | AgentType | ✅ | الوكيل المستقبِل |
| payload | Map<String, dynamic> | ✅ | محتوى الرسالة (JSON) |
| createdAt | DateTime | ✅ | timestamp |

**enum BandMessageType:** `contextHandoff, reviewRequest, reviewResult, finalEvaluation, coordinatorSync`

---

### Entity: FinalReportEntity
**المسار:** `lib/features/orchestration/domain/entities/final_report_entity.dart`  
**الاستخدام:** F08, F10

| الحقل | النوع | إلزامي؟ | الوصف |
|-------|-------|---------|-------|
| id | String | ✅ | معرف التقرير |
| sessionId | String | ✅ | معرف الجلسة |
| candidateId | String | ✅ | معرف المرشح |
| screeningScore | double | ✅ | درجة الفرز المدمجة |
| technicalScore | double | ✅ | درجة المقابلة التقنية |
| culturalScore | double | ✅ | درجة التقييم الثقافي |
| overallScore | double | ✅ | الدرجة الإجمالية (40%+40%+20%) |
| hasConflict | bool | ✅ | هل وقع تعارض في الفرز؟ |
| conflictNote | String? | ❌ | نص التعارض إن وُجد |
| finalRecommendation | AgentRecommendation | ✅ | التوصية النهائية |
| summaryNotes | String | ✅ | ملخص نصي من وكيل التنسيق |
| createdAt | DateTime | ✅ | تاريخ الإنشاء |

**العلاقات:**
- `RecruitmentSessionEntity` ← يحتوي على قائمة من `CandidateEntity`
- `CandidateEntity` ← مرتبط بقائمة من `AgentResultEntity` عبر `candidateId`
- `CandidateEntity` ← مرتبط بـ `FinalReportEntity` واحد عبر `candidateId`
- `BandMessageEntity` ← مرتبط بـ `CandidateEntity` عبر `candidateId`

---

## 4. هيكلية المجلدات الكاملة

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── config/
│   │   └── environment_config.dart
│   ├── di/
│   │   └── injection_container.dart
│   ├── error/
│   │   ├── exceptions.dart
│   │   ├── failures.dart
│   │   └── error_handler.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_guard.dart
│   ├── services/
│   │   ├── band/
│   │   │   └── band_service.dart
│   │   ├── ai/
│   │   │   ├── aiml_service.dart
│   │   │   └── featherless_service.dart
│   │   ├── parser/
│   │   │   └── cv_parser_service.dart
│   │   ├── connectivity_service.dart
│   │   ├── cache_service.dart
│   │   ├── persistent_cache_service.dart
│   │   ├── responsive_service.dart
│   │   └── platform_service.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_ar.arb
│   ├── logger/
│   │   └── app_logger.dart
│   ├── usecases/
│   │   └── usecase.dart
│   └── widgets/
│       ├── multi_bloc_provider_widget.dart
│       └── accessibility_wrapper.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── user_model.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/
│   │   │       ├── sign_in_usecase.dart
│   │   │       ├── sign_up_usecase.dart
│   │   │       ├── sign_out_usecase.dart
│   │   │       └── check_auth_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── auth_cubit.dart
│   │       │   └── auth_state.dart
│   │       └── pages/
│   │           ├── login_page.dart
│   │           ├── register_page.dart
│   │           └── widgets/
│   │               └── auth_form_widget.dart
│   │
│   ├── settings/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── settings_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── api_keys_model.dart
│   │   │   └── repositories/
│   │   │       └── settings_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── api_keys_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── settings_repository.dart
│   │   │   └── usecases/
│   │   │       ├── save_api_keys_usecase.dart
│   │   │       └── get_api_keys_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── settings_cubit.dart
│   │       │   └── settings_state.dart
│   │       └── pages/
│   │           ├── settings_page.dart
│   │           └── widgets/
│   │               └── api_key_field_widget.dart
│   │
│   ├── recruitment/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── recruitment_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   ├── recruitment_session_model.dart
│   │   │   │   └── candidate_model.dart
│   │   │   └── repositories/
│   │   │       └── recruitment_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── recruitment_session_entity.dart
│   │   │   │   └── candidate_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── recruitment_repository.dart
│   │   │   └── usecases/
│   │   │       ├── create_session_usecase.dart
│   │   │       ├── get_sessions_usecase.dart
│   │   │       ├── get_session_by_id_usecase.dart
│   │   │       ├── upload_cvs_usecase.dart
│   │   │       └── get_candidates_usecase.dart
│   │   └── presentation/
│   │       ├── cubit/
│   │       │   ├── recruitment_cubit.dart
│   │       │   ├── recruitment_state.dart
│   │       │   ├── file_upload_cubit.dart
│   │       │   └── file_upload_state.dart
│   │       └── pages/
│   │           ├── dashboard_page.dart
│   │           ├── new_recruitment_page.dart
│   │           ├── session_detail_page.dart
│   │           └── widgets/
│   │               ├── session_card_widget.dart
│   │               ├── cv_upload_widget.dart
│   │               └── candidate_list_widget.dart
│   │
│   └── orchestration/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── orchestration_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── agent_result_model.dart
│       │   │   ├── band_message_model.dart
│       │   │   ├── conflict_resolution_model.dart
│       │   │   └── final_report_model.dart
│       │   └── repositories/
│       │       └── orchestration_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── agent_result_entity.dart
│       │   │   ├── band_message_entity.dart
│       │   │   ├── conflict_resolution_entity.dart
│       │   │   └── final_report_entity.dart
│       │   ├── repositories/
│       │   │   └── orchestration_repository.dart
│       │   └── usecases/
│       │       ├── run_full_analysis_usecase.dart
│       │       ├── run_screening_usecase.dart
│       │       ├── run_adversarial_review_usecase.dart
│       │       ├── resolve_conflict_usecase.dart
│       │       ├── run_interview_usecase.dart
│       │       ├── run_cultural_assessment_usecase.dart
│       │       ├── run_coordination_usecase.dart
│       │       ├── approve_candidate_usecase.dart
│       │       ├── reject_candidate_usecase.dart
│       │       ├── get_band_messages_usecase.dart
│       │       └── get_final_reports_usecase.dart
│       └── presentation/
│           ├── cubit/
│           │   ├── orchestration_cubit.dart
│           │   ├── orchestration_state.dart
│           │   ├── band_activity_cubit.dart
│           │   ├── band_activity_state.dart
│           │   ├── reports_cubit.dart
│           │   └── reports_state.dart
│           └── pages/
│               ├── analysis_page.dart
│               ├── reports_page.dart
│               ├── candidate_report_page.dart
│               └── widgets/
│                   ├── band_activity_panel.dart
│                   ├── agent_progress_widget.dart
│                   ├── adversarial_result_widget.dart
│                   ├── final_report_card_widget.dart
│                   └── conflict_badge_widget.dart
│
└── shared/
    ├── data/
    │   └── models/
    │       └── base_model.dart
    └── domain/
        └── entities/
            ├── base_entity.dart
            └── value_objects.dart

test/
├── features/
│   ├── auth/
│   │   ├── domain/usecases/
│   │   └── presentation/cubit/
│   ├── recruitment/
│   │   ├── domain/usecases/
│   │   └── presentation/cubit/
│   └── orchestration/
│       ├── domain/usecases/
│       └── presentation/cubit/
└── shared/
```

---

## 5. خريطة التنقل (Navigation)

**المسار:** `lib/core/router/app_router.dart`

```
/ (root)                         → redirect حسب AuthState
├── /splash                      → SplashPage              [عامة]
├── /login                       → LoginPage               [requireUnauthenticated]
├── /register                    → RegisterPage            [requireUnauthenticated]
└── /app (ShellRoute)            → AppShellLayout
    ├── /app/dashboard           → DashboardPage           [requireAuthenticated]
    ├── /app/recruitment/new     → NewRecruitmentPage      [requireAuthenticated]
    ├── /app/recruitment/:id     → SessionDetailPage       [requireAuthenticated]
    ├── /app/recruitment/:id/analysis
    │                            → AnalysisPage            [requireAuthenticated]
    │                              (يحتوي Band Activity Panel جانبياً)
    ├── /app/recruitment/:id/reports
    │                            → ReportsPage             [requireAuthenticated]
    ├── /app/recruitment/:id/candidates/:candidateId
    │                            → CandidateReportPage     [requireAuthenticated]
    └── /app/settings            → SettingsPage            [requireAuthenticated]
```

**Route Guards:**

| Guard | السلوك |
|-------|--------|
| `requireAuthenticated` | يُعيد توجيه لـ `/login` إذا لم يكن مُسجّل دخوله |
| `requireUnauthenticated` | يُعيد توجيه لـ `/app/dashboard` إذا كان مُسجّل دخوله |

> ⚠️ تنبيه للـ Agent: استخدم `AuthStateListenable` مع `refreshListenable` في GoRouter — لا `GoRouterRefreshStream` (مُهجَر). يجب أن يكون `errorBuilder` موجوداً يعرض `ErrorPage` عند أي مسار غير موجود.

---

## 6. إدارة الحالة (State Management Plan)

### App-Level Cubits
> هذه تُسجَّل في `injection_container.dart` كـ `registerLazySingleton` وتُضاف في `main.dart`

| Cubit | States | الغرض |
|-------|--------|-------|
| `AuthCubit` | `AuthInitial, AuthLoading, AuthAuthenticated(UserEntity user), AuthUnauthenticated, AuthError(String message)` | حالة المصادقة عبر التطبيق |
| `ThemeCubit` | `ThemeState(ThemeMode themeMode)` | الثيم (light/dark) — HydratedCubit |
| `LocaleCubit` | `LocaleState(Locale locale)` | اللغة (en/ar) — HydratedCubit — الافتراضي: `en` |
| `ApiKeysCubit` | `ApiKeysInitial, ApiKeysLoading, ApiKeysLoaded(ApiKeysEntity keys), ApiKeysError(String message)` | مفاتيح API المحفوظة — يُحمَّل عند Login |

### Feature-Level Cubits
> هذه تُسجَّل كـ `registerFactory`

| Feature | Cubit | States |
|---------|-------|--------|
| F03 | `RecruitmentCubit` | `RecruitmentInitial, RecruitmentLoading, RecruitmentLoaded(List<RecruitmentSessionEntity> sessions), RecruitmentError(String message)` |
| F03+F04 | `SessionDetailCubit` | `SessionDetailInitial, SessionDetailLoading, SessionDetailLoaded(RecruitmentSessionEntity session, List<CandidateEntity> candidates), SessionDetailError(String message)` |
| F04 | `FileUploadCubit` | `FileUploadInitial, FileUploadPicking, FileUploadParsing(int current, int total), FileUploadSuccess(List<CandidateEntity> candidates), FileUploadError(String message)` |
| F05-F08 | `OrchestrationCubit` | `OrchestrationIdle, OrchestrationRunning(String currentAgentLabel, int completedSteps, int totalSteps), OrchestrationCompleted(List<FinalReportEntity> reports), OrchestrationError(String message, String failedAgent)` |
| F09 | `BandActivityCubit` | `BandActivityInitial, BandActivityUpdated(List<BandMessageEntity> messages)` |
| F10 | `ReportsCubit` | `ReportsInitial, ReportsLoading, ReportsLoaded(List<FinalReportEntity> reports), ReportsError(String message)` |
| F02 | `SettingsCubit` | `SettingsInitial, SettingsLoading, SettingsSaved, SettingsLoaded(ApiKeysEntity keys), SettingsError(String message)` |

> ⚠️ تنبيه للـ Agent: `AuthCubit`, `ThemeCubit`, `LocaleCubit`, `ApiKeysCubit` = `registerLazySingleton`. كل Cubit آخر = `registerFactory`. الخلط يُسبب bug حرج في GoRouter Guards.

---

## 7. Use Cases الكاملة

### Feature: Auth (F01)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `SignInUseCase` | `SignInParams(email: String, password: String)` | `Either<Failure, UserEntity>` | تسجيل الدخول بالبريد وكلمة السر |
| `SignUpUseCase` | `SignUpParams(email: String, password: String)` | `Either<Failure, UserEntity>` | إنشاء حساب جديد |
| `SignOutUseCase` | `NoParams` | `Either<Failure, Unit>` | تسجيل الخروج وإلغاء الجلسة |
| `CheckAuthUseCase` | `NoParams` | `Either<Failure, UserEntity?>` | فحص الجلسة الحالية عند فتح التطبيق |

### Feature: Settings (F02)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `SaveApiKeysUseCase` | `SaveApiKeysParams(userId, aimlKey, featherlessKey, bandKey, bandUrl)` | `Either<Failure, Unit>` | حفظ/تحديث مفاتيح API في Supabase |
| `GetApiKeysUseCase` | `GetApiKeysParams(userId: String)` | `Either<Failure, ApiKeysEntity>` | جلب مفاتيح API للمستخدم |

### Feature: Recruitment & Upload (F03, F04)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `CreateSessionUseCase` | `CreateSessionParams(userId, jobTitle, jobDescription)` | `Either<Failure, RecruitmentSessionEntity>` | إنشاء جلسة توظيف جديدة |
| `GetSessionsUseCase` | `GetSessionsParams(userId: String)` | `Either<Failure, List<RecruitmentSessionEntity>>` | جلب جميع جلسات المستخدم |
| `GetSessionByIdUseCase` | `GetSessionByIdParams(id: String)` | `Either<Failure, RecruitmentSessionEntity>` | جلب جلسة بمعرفها |
| `UploadCVsUseCase` | `UploadCVsParams(sessionId: String, files: List<PlatformFile>)` | `Either<Failure, List<CandidateEntity>>` | رفع ملفات + استخراج النص + حفظ في Supabase |
| `GetCandidatesUseCase` | `GetCandidatesParams(sessionId: String)` | `Either<Failure, List<CandidateEntity>>` | جلب مرشحي جلسة |

### Feature: Orchestration — Agents (F05–F08)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `RunFullAnalysisUseCase` | `RunFullAnalysisParams(sessionId, candidates: List<CandidateEntity>, apiKeys: ApiKeysEntity)` | `Either<Failure, List<FinalReportEntity>>` | ينسق تسلسل كل الوكلاء لكل المرشحين |
| `RunScreeningUseCase` | `RunScreeningParams(candidate: CandidateEntity, jobDescription: String, apiKeys)` | `Either<Failure, AgentResultEntity>` | تشغيل وكيل الفرز (AIMLAPI/GPT-4o) |
| `RunAdversarialReviewUseCase` | `RunAdversarialParams(candidate, screeningResult: AgentResultEntity, apiKeys)` | `Either<Failure, AgentResultEntity>` | تشغيل وكيل المراجعة (Featherless/Mistral) |
| `ResolveConflictUseCase` | `ResolveConflictParams(candidateId, screeningResult, reviewResult)` | `Either<Failure, ConflictResolutionEntity>` | حساب الدرجة المدمجة وتحديد التعارض |
| `RunInterviewUseCase` | `RunInterviewParams(candidate, skills: List<String>, experienceLevel: String, apiKeys)` | `Either<Failure, AgentResultEntity>` | توليد أسئلة + تشغيل CandidateSimulator + تقييم |
| `RunCulturalAssessmentUseCase` | `RunCulturalParams(candidate: CandidateEntity, apiKeys)` | `Either<Failure, AgentResultEntity>` | تقييم التوافق الثقافي |
| `RunCoordinationUseCase` | `RunCoordinationParams(candidateId, interviewResult, culturalResult, conflictResolution, apiKeys)` | `Either<Failure, FinalReportEntity>` | دمج النتائج وإنشاء التقرير النهائي |
| `ApproveCandidateUseCase` | `ApproveCandidateParams(candidateId: String)` | `Either<Failure, Unit>` | تغيير حالة المرشح لـ accepted |
| `RejectCandidateUseCase` | `RejectCandidateParams(candidateId: String)` | `Either<Failure, Unit>` | تغيير حالة المرشح لـ rejected |

### Feature: Band Activity Panel (F09)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `GetBandMessagesUseCase` | `GetBandMessagesParams(sessionId: String, candidateId: String)` | `Either<Failure, List<BandMessageEntity>>` | جلب رسائل Band لمرشح محدد |

### Feature: Reports (F10)

| UseCase | المدخل (Params) | المخرج | الوصف |
|---------|----------------|--------|-------|
| `GetFinalReportsUseCase` | `GetFinalReportsParams(sessionId: String)` | `Either<Failure, List<FinalReportEntity>>` | جلب تقارير جميع مرشحي جلسة |
| `GetCandidateReportUseCase` | `GetCandidateReportParams(candidateId: String)` | `Either<Failure, FinalReportEntity>` | جلب تقرير مرشح محدد |

---

## 8. Repository Interfaces

### `AuthRepository`
**المسار:** `lib/features/auth/domain/repositories/auth_repository.dart`
```
signIn(email: String, password: String) → Future<Either<Failure, UserEntity>>
signUp(email: String, password: String) → Future<Either<Failure, UserEntity>>
signOut() → Future<Either<Failure, Unit>>
getCurrentUser() → Future<Either<Failure, UserEntity?>>
```

### `SettingsRepository`
**المسار:** `lib/features/settings/domain/repositories/settings_repository.dart`
```
saveApiKeys(SaveApiKeysParams) → Future<Either<Failure, Unit>>
getApiKeys(userId: String) → Future<Either<Failure, ApiKeysEntity>>
```

### `RecruitmentRepository`
**المسار:** `lib/features/recruitment/domain/repositories/recruitment_repository.dart`
```
createSession(CreateSessionParams) → Future<Either<Failure, RecruitmentSessionEntity>>
getSessions(userId: String) → Future<Either<Failure, List<RecruitmentSessionEntity>>>
getSessionById(id: String) → Future<Either<Failure, RecruitmentSessionEntity>>
updateSessionStatus(id: String, status: SessionStatus) → Future<Either<Failure, Unit>>
updateSessionBandRoom(id: String, bandRoomId: String) → Future<Either<Failure, Unit>>
uploadCVs(sessionId: String, files: List<PlatformFile>) → Future<Either<Failure, List<CandidateEntity>>>
getCandidates(sessionId: String) → Future<Either<Failure, List<CandidateEntity>>>
updateCandidateStatus(candidateId: String, status: CandidateStatus) → Future<Either<Failure, Unit>>
updateCandidateScore(candidateId: String, score: double) → Future<Either<Failure, Unit>>
```

### `OrchestrationRepository`
**المسار:** `lib/features/orchestration/domain/repositories/orchestration_repository.dart`
```
runScreeningAgent(RunScreeningParams) → Future<Either<Failure, AgentResultEntity>>
runAdversarialReview(RunAdversarialParams) → Future<Either<Failure, AgentResultEntity>>
resolveConflict(ResolveConflictParams) → Future<Either<Failure, ConflictResolutionEntity>>
runInterviewAgent(RunInterviewParams) → Future<Either<Failure, AgentResultEntity>>
runCulturalAssessment(RunCulturalParams) → Future<Either<Failure, AgentResultEntity>>
runCoordinationAgent(RunCoordinationParams) → Future<Either<Failure, FinalReportEntity>>
saveAgentResult(AgentResultEntity) → Future<Either<Failure, Unit>>
saveFinalReport(FinalReportEntity) → Future<Either<Failure, Unit>>
updateCandidateDecision(candidateId: String, status: CandidateStatus) → Future<Either<Failure, Unit>>
getBandMessages(sessionId: String, candidateId: String) → Future<Either<Failure, List<BandMessageEntity>>>
getFinalReports(sessionId: String) → Future<Either<Failure, List<FinalReportEntity>>>
getCandidateReport(candidateId: String) → Future<Either<Failure, FinalReportEntity>>
```

---

## 9. API Contracts (Data Layer)

### 9.1 Supabase — جداول وعمليات

| العملية | الجدول | Method | الحقول المُرسَلة | الحقول المُستقبَلة |
|---------|--------|--------|-----------------|------------------|
| تسجيل الدخول | `auth.signInWithPassword` | — | `email, password` | `session, user` |
| إنشاء حساب | `auth.signUp` | — | `email, password` | `session, user` |
| تسجيل خروج | `auth.signOut` | — | — | — |
| حفظ مفاتيح API | `user_secrets` | upsert | `user_id, aiml_api_key, featherless_key, band_api_key, band_api_url` | `id, updated_at` |
| جلب مفاتيح API | `user_secrets` | select | filter: `user_id` | `id, aiml_api_key, featherless_key, band_api_key, band_api_url, updated_at` |
| إنشاء جلسة | `recruitment_sessions` | insert | `user_id, job_title, job_description, status` | `id, created_at` |
| جلب الجلسات | `recruitment_sessions` | select | filter: `user_id` | `id, job_title, status, candidates_count, created_at` |
| تحديث حالة الجلسة | `recruitment_sessions` | update | `status, band_room_id` | — |
| إضافة مرشح | `candidates` | insert | `session_id, name, cv_text, file_name, status` | `id, created_at` |
| جلب المرشحين | `candidates` | select | filter: `session_id` | جميع الحقول |
| تحديث حالة مرشح | `candidates` | update | `status, overall_score` | — |
| حفظ نتيجة وكيل | `agent_results` | insert | `session_id, candidate_id, agent_type, score, summary, recommendation, raw_data` | `id, created_at` |
| تسجيل رسالة Band | `band_messages_log` | insert | `room_id, session_id, candidate_id, message_type, sender_agent, receiver_agent, payload` | `id, created_at` |
| جلب رسائل Band | `band_messages_log` | select + realtime | filter: `session_id, candidate_id` | جميع الحقول |
| حفظ التقرير النهائي | `final_reports` | insert | جميع حقول FinalReportEntity | `id, created_at` |
| جلب تقارير الجلسة | `final_reports` | select | filter: `session_id` | جميع الحقول |

### 9.2 AIMLAPI (Screening, Interview, Cultural)

**Base URL:** `${AIMLAPI_BASE_URL}` (من .env)  
**Endpoint:** `POST /chat/completions`  
**Headers:** `Authorization: Bearer ${AIMLAPI_KEY}`, `Content-Type: application/json`

```
Request Body:
{
  "model": "gpt-4o",
  "max_tokens": 1000,
  "messages": [
    {"role": "system", "content": "[system_prompt]"},
    {"role": "user", "content": "[user_prompt]"}
  ]
}

Response:
{
  "choices": [{"message": {"content": "[JSON string]"}}]
}
```

> ⚠️ تنبيه للـ Agent: الرد دائماً JSON string داخل `choices[0].message.content`. استخدم `jsonDecode` بعد استخراجه. أضف retry logic: 3 محاولات مع exponential backoff (1s, 2s, 4s).

### 9.3 Featherless (Adversarial Review, Candidate Simulator)

**Base URL:** `${FEATHERLESS_BASE_URL}` (من .env)  
**Endpoint:** `POST /chat/completions`  
**Headers:** `Authorization: Bearer ${FEATHERLESS_KEY}`, `Content-Type: application/json`  
**Default Model:** `mistralai/Mistral-7B-Instruct-v0.3`

نفس هيكل Request/Response كـ AIMLAPI تماماً (OpenAI-compatible).

### 9.4 Band API

**Base URL:** `${BAND_API_URL}` (من .env)  
**Headers:** `Authorization: Bearer ${BAND_API_KEY}`, `Content-Type: application/json`

| العملية | Endpoint | Method | Body | Response |
|---------|----------|--------|------|---------|
| إنشاء غرفة | `/rooms` | POST | `{"name": "session_{sessionId}_candidate_{candidateId}"}` | `{"room_id": "..."}` |
| إرسال رسالة | `/rooms/{roomId}/messages` | POST | `{"type": "[BandMessageType]", "sender": "[agentType]", "receiver": "[agentType]", "payload": {...}}` | `{"message_id": "..."}` |
| جلب الرسائل | `/rooms/{roomId}/messages` | GET | — | `[{"id", "type", "sender", "receiver", "payload", "timestamp"}]` |

> ⚠️ تنبيه للـ Agent: بعد كل `sendMessage` عبر Band، سجّل الرسالة أيضاً في جدول Supabase `band_messages_log` — هذا ما يجعل Band Activity Panel يعمل عبر Realtime.

### 9.5 System Prompts للوكلاء

**Screening Agent (AIMLAPI):**
```
System: "You are an expert recruiter. Analyze the CV against the job requirements. Output ONLY valid JSON:
{
  \"match_score\": 0-100,
  \"matched_skills\": [\"skill1\"],
  \"missing_skills\": [\"skill2\"],
  \"experience_years\": 0,
  \"summary\": \"one paragraph\",
  \"recommendation\": \"accept|reject|maybe\"
}"
User: "Job Requirements:\n{jobDescription}\n\nCV:\n{cvText}"
```

**Adversarial Reviewer (Featherless/Mistral):**
```
System: "You are an independent HR auditor. Review the screening result for bias or errors. Output ONLY valid JSON:
{
  \"agrees\": true|false,
  \"confidence\": 0-100,
  \"revised_score\": null|0-100,
  \"critique\": \"explanation\",
  \"final_recommendation\": \"accept|reject|maybe\"
}"
User: "Screening Result:\n{screeningResultJson}\n\nOriginal CV:\n{cvText}"
```

**Interview Agent (AIMLAPI):**
```
System: "Generate 3 technical interview questions of increasing difficulty based on the candidate's skills. Then evaluate their answers. Output ONLY valid JSON:
{
  \"questions\": [{\"q\": \"\", \"ideal_answer\": \"\", \"candidate_answer\": \"\", \"score\": 0-10}],
  \"overall_technical_score\": 0-100,
  \"summary\": \"\"
}"
User: "Skills: {skills}\nExperience Level: {level}\nCandidate Answers: {answers}"
```

**Candidate Simulator (Featherless):**
```
System: "You are a real job candidate answering technical questions. Respond naturally and imperfectly — some correct, some incomplete, some wrong. Be realistic."
User: "Questions:\n{questionsJson}"
```

**Cultural Assessment Agent (AIMLAPI):**
```
System: "Evaluate the candidate's cultural fit based on values: Collaboration, Innovation, Responsibility. Output ONLY valid JSON:
{
  \"cultural_fit_score\": 0-100,
  \"traits_observed\": [\"\"],
  \"concerns\": [\"\"],
  \"summary\": \"\"
}"
User: "Candidate CV:\n{cvText}\nSimulated behavioral answers:\n{behavioralAnswers}"
```

**Coordination Agent (AIMLAPI):**
```
System: "You are a hiring coordinator. Merge all evaluation results into a final hiring recommendation. Output ONLY valid JSON:
{
  \"final_recommendation\": \"accept|reject|maybe\",
  \"summary_notes\": \"2-3 sentences\",
  \"strengths\": [\"\"],
  \"concerns\": [\"\"]
}"
User: "Screening (merged): {conflictResolutionJson}\nTechnical: {interviewResultJson}\nCultural: {culturalResultJson}"
```

---

## 10. Dependency Injection Plan

**المسار:** `lib/core/di/injection_container.dart`

```
تسلسل التسجيل (الترتيب إلزامي):

0. Core Services (LazySingleton)
   - ConnectivityService
   - AppLogger
   - PersistentCacheService
   - CacheService
   - BandService               ← يُحقن بـ BAND_API_URL, BAND_API_KEY من EnvironmentConfig
   - AimlService               ← يُحقن بـ AIMLAPI_BASE_URL من EnvironmentConfig
   - FeatherlessService        ← يُحقن بـ FEATHERLESS_BASE_URL من EnvironmentConfig
   - CVParserService

1. Feature: Auth
   - AuthRemoteDataSource (LazySingleton)
   - AuthRepository → AuthRepositoryImpl (LazySingleton)
   - SignInUseCase (LazySingleton)
   - SignUpUseCase (LazySingleton)
   - SignOutUseCase (LazySingleton)
   - CheckAuthUseCase (LazySingleton)
   - AuthCubit (LazySingleton) ← App-Level

2. Feature: Settings
   - SettingsRemoteDataSource (LazySingleton)
   - SettingsRepository → SettingsRepositoryImpl (LazySingleton)
   - SaveApiKeysUseCase (LazySingleton)
   - GetApiKeysUseCase (LazySingleton)
   - ApiKeysCubit (LazySingleton) ← App-Level
   - SettingsCubit (Factory)

3. Feature: Recruitment
   - RecruitmentRemoteDataSource (LazySingleton)
   - RecruitmentRepository → RecruitmentRepositoryImpl (LazySingleton)
   - CreateSessionUseCase (LazySingleton)
   - GetSessionsUseCase (LazySingleton)
   - GetSessionByIdUseCase (LazySingleton)
   - UploadCVsUseCase (LazySingleton)
   - GetCandidatesUseCase (LazySingleton)
   - RecruitmentCubit (Factory)
   - SessionDetailCubit (Factory)
   - FileUploadCubit (Factory)

4. Feature: Orchestration
   - OrchestrationRemoteDataSource (LazySingleton)
     ← يُحقن بـ AimlService, FeatherlessService, BandService
   - OrchestrationRepository → OrchestrationRepositoryImpl (LazySingleton)
   - [جميع Agent UseCases] (LazySingleton)
   - RunFullAnalysisUseCase (LazySingleton)
   - ApproveCandidateUseCase (LazySingleton)
   - RejectCandidateUseCase (LazySingleton)
   - GetBandMessagesUseCase (LazySingleton)
   - GetFinalReportsUseCase (LazySingleton)
   - GetCandidateReportUseCase (LazySingleton)
   - OrchestrationCubit (Factory)
   - BandActivityCubit (Factory)
   - ReportsCubit (Factory)
```

---

## 11. Core Services — تفاصيل التنفيذ

### BandService
**المسار:** `lib/core/services/band/band_service.dart`
```
createRoom(sessionId: String, candidateId: String) → Future<String>  ← يُرجع roomId
sendMessage(roomId: String, type: BandMessageType, senderAgent: AgentType,
            receiverAgent: AgentType, payload: Map) → Future<void>
getMessages(roomId: String) → Future<List<Map<String, dynamic>>>
```
> ⚠️ بعد كل `sendMessage` ناجح: استدعِ Supabase insert على `band_messages_log` بالبيانات الكاملة. هذا ضروري لـ Band Activity Panel.

### AimlService
**المسار:** `lib/core/services/ai/aiml_service.dart`
```
complete(systemPrompt: String, userPrompt: String, {model: String = 'gpt-4o'}) → Future<String>
```
Retry logic: 3 محاولات. Timeout: 30 ثانية. يُرمي `ServerException` عند الفشل.

### FeatherlessService
**المسار:** `lib/core/services/ai/featherless_service.dart`
```
complete(systemPrompt: String, userPrompt: String,
         {model: String = 'mistralai/Mistral-7B-Instruct-v0.3'}) → Future<String>
```
نفس منطق AimlService. يُستخدم حصرياً للـ Reviewer Agent و Candidate Simulator.

### CVParserService
**المسار:** `lib/core/services/parser/cv_parser_service.dart`
```
parseFile(file: PlatformFile) → Future<String>   ← يُرجع النص المُستخرَج
extractCandidateName(text: String) → String       ← يستخرج اسم المرشح من أول سطرين
```
يدعم PDF (حزمة `pdf`) و DOCX (حزمة `docx_to_text`). عند فشل الاستخراج: يُرجع `""` (لا يُرمي exception).

---

## 12. تسلسل التنفيذ الكامل

> ⚠️ تنبيه للـ Agent: نفّذ هذا التسلسل بالترتيب الحرفي. لا تنتقل للخطوة التالية قبل إكمال السابقة بالكامل.

### المرحلة 0: البنية التحتية (Core)
```
0.01  إنشاء هيكلية المجلدات كاملة كما في القسم 4
0.02  كتابة exceptions.dart (AppException, ServerException, AuthException,
      NetworkException, CacheException, ValidationException, NoConnectionException)
0.03  كتابة failures.dart (Failure base + 6 subclasses مقابل الـ Exceptions)
0.04  كتابة base_entity.dart + base_model.dart + usecase.dart + value_objects.dart
0.05  كتابة ConnectivityService, CacheService, PersistentCacheService
0.06  كتابة PlatformService, ResponsiveService, AppLogger
0.07  كتابة AppTheme (light + dark + RTL support)
0.08  كتابة ملفات l10n: app_en.arb + app_ar.arb (جميع المفاتيح من القسم 13)
0.09  كتابة BandService, AimlService, FeatherlessService, CVParserService
0.10  كتابة EnvironmentConfig (يقرأ من .env)
0.11  كتابة injection_container.dart (هيكل فارغ جاهز للتسجيل)
0.12  كتابة app_router.dart (جميع المسارات + Guards + errorBuilder)
0.13  كتابة main.dart بالتسلسل: WidgetsFlutterBinding → EnvironmentConfig →
      PersistentCacheService → HydratedBloc.storage → initDependencies →
      FlutterError.onError → runApp
```

### المرحلة 1: Feature — Auth (F01)
```
1.01  domain/entities/user_entity.dart
1.02  domain/repositories/auth_repository.dart (interface)
1.03  domain/usecases/sign_in_usecase.dart
1.04  domain/usecases/sign_up_usecase.dart
1.05  domain/usecases/sign_out_usecase.dart
1.06  domain/usecases/check_auth_usecase.dart
1.07  → Unit Tests (test/features/auth/domain/usecases/)
1.08  data/models/user_model.dart
1.09  data/datasources/auth_remote_datasource.dart
1.10  data/repositories/auth_repository_impl.dart
1.11  presentation/cubit/auth_state.dart
1.12  presentation/cubit/auth_cubit.dart
1.13  → Unit Tests للـ Cubit
1.14  تسجيل في injection_container.dart
1.15  presentation/pages/login_page.dart
1.16  presentation/pages/register_page.dart
1.17  presentation/pages/widgets/auth_form_widget.dart
```

### المرحلة 2: Feature — Settings (F02)
```
2.01  domain/entities/api_keys_entity.dart
2.02  domain/repositories/settings_repository.dart
2.03  domain/usecases/save_api_keys_usecase.dart
2.04  domain/usecases/get_api_keys_usecase.dart
2.05  data/models/api_keys_model.dart
2.06  data/datasources/settings_remote_datasource.dart
2.07  data/repositories/settings_repository_impl.dart
2.08  presentation/cubit/settings_state.dart + settings_cubit.dart
2.09  تسجيل في injection_container.dart (ApiKeysCubit = LazySingleton)
2.10  presentation/pages/settings_page.dart
2.11  presentation/pages/widgets/api_key_field_widget.dart
```

### المرحلة 3: Feature — Recruitment & Upload (F03, F04)
```
3.01  domain/entities/recruitment_session_entity.dart
3.02  domain/entities/candidate_entity.dart
3.03  domain/repositories/recruitment_repository.dart
3.04  domain/usecases/ (جميع الـ 5 UseCases)
3.05  → Unit Tests
3.06  data/models/recruitment_session_model.dart + candidate_model.dart
3.07  data/datasources/recruitment_remote_datasource.dart
3.08  data/repositories/recruitment_repository_impl.dart
3.09  presentation/cubit/ (RecruitmentCubit, SessionDetailCubit, FileUploadCubit + states)
3.10  → Unit Tests للـ Cubits
3.11  تسجيل في injection_container.dart
3.12  presentation/pages/dashboard_page.dart
3.13  presentation/pages/new_recruitment_page.dart
3.14  presentation/pages/session_detail_page.dart
3.15  presentation/pages/widgets/ (session_card, cv_upload, candidate_list)
```

### المرحلة 4: Feature — Orchestration (F05–F09)
```
4.01  domain/entities/ (agent_result, band_message, conflict_resolution, final_report)
4.02  domain/repositories/orchestration_repository.dart
4.03  domain/usecases/ (جميع الـ 11 UseCase)
4.04  → Unit Tests للـ UseCases الحرجة:
        RunScreeningUseCase, RunAdversarialReviewUseCase, ResolveConflictUseCase
4.05  data/models/ (4 models)
4.06  data/datasources/orchestration_remote_datasource.dart
        ← ينفذ جميع Agent calls عبر AimlService, FeatherlessService, BandService
4.07  data/repositories/orchestration_repository_impl.dart
4.08  presentation/cubit/orchestration_state.dart + orchestration_cubit.dart
4.09  presentation/cubit/band_activity_state.dart + band_activity_cubit.dart
4.10  presentation/cubit/reports_state.dart + reports_cubit.dart
4.11  → Unit Tests للـ Cubits
4.12  تسجيل في injection_container.dart
4.13  presentation/pages/analysis_page.dart
4.14  presentation/pages/widgets/band_activity_panel.dart  ← Supabase Realtime
4.15  presentation/pages/widgets/agent_progress_widget.dart
4.16  presentation/pages/widgets/adversarial_result_widget.dart  ← يعرض ⚡ عند التعارض
4.17  presentation/pages/widgets/conflict_badge_widget.dart
4.18  presentation/pages/reports_page.dart
4.19  presentation/pages/candidate_report_page.dart
4.20  presentation/pages/widgets/final_report_card_widget.dart
```

### المرحلة 5: التكامل النهائي
```
5.01  مراجعة app_router.dart — تأكد من ربط كل المسارات بصفحاتها
5.02  مراجعة injection_container.dart — تأكد من تسجيل كل شيء بالنوع الصحيح
5.03  مراجعة main.dart — تأكد من تسلسل التهيئة
5.04  اختبار flow كامل: login → create session → upload CVs → start analysis
       → band panel يعرض رسائل → reports تظهر → approve يعمل
5.05  تشغيل flutter analyze — إصلاح كل تحذير
5.06  flutter build web --release — تأكد من البناء بدون أخطاء
```

---

## 13. Accessibility & Localization

### مفاتيح الترجمة الكاملة (app_en.arb / app_ar.arb)

| المفتاح | English | العربي |
|---------|---------|--------|
| `appName` | Hire | Hire |
| `dashboard` | Dashboard | لوحة التحكم |
| `newRecruitment` | New Recruitment | توظيف جديد |
| `jobTitle` | Job Title | عنوان الوظيفة |
| `jobDescription` | Job Description | متطلبات الوظيفة |
| `uploadCVs` | Upload CVs | رفع السير الذاتية |
| `startAnalysis` | Start Analysis | بدء التحليل |
| `analyzing` | Analyzing... | جاري التحليل... |
| `screeningAgent` | Screening Agent | وكيل الفرز |
| `reviewerAgent` | Reviewer Agent | وكيل المراجعة |
| `interviewAgent` | Interview Agent | وكيل المقابلة |
| `culturalAgent` | Cultural Agent | وكيل التقييم الثقافي |
| `coordinatorAgent` | Coordinator Agent | وكيل التنسيق |
| `bandActivity` | Band Activity | نشاط Band |
| `contextHandoff` | Context Handoff | تسليم السياق |
| `reviewRequest` | Review Request | طلب مراجعة |
| `reviewResult` | Review Result | نتيجة المراجعة |
| `finalEvaluation` | Final Evaluation | التقييم النهائي |
| `coordinatorSync` | Coordinator Sync | مزامنة التنسيق |
| `conflictDetected` | Conflict Detected | تم اكتشاف تعارض |
| `conflictNote` | Conflict in evaluation — human review recommended | تعارض في التقييم — يُنصح بمراجعة بشرية |
| `overallScore` | Overall Score | الدرجة الإجمالية |
| `technicalScore` | Technical Score | الدرجة التقنية |
| `culturalScore` | Cultural Score | درجة التوافق الثقافي |
| `screeningScore` | Screening Score | درجة الفرز |
| `approve` | Approve | موافقة |
| `reject` | Reject | رفض |
| `requestReview` | Request Review | طلب مراجعة |
| `accepted` | Accepted | مقبول |
| `rejected` | Rejected | مرفوض |
| `pending` | Pending | قيد الانتظار |
| `viewDetails` | View Details | عرض التفاصيل |
| `messagePayload` | Message Payload | محتوى الرسالة |
| `settings` | Settings | الإعدادات |
| `apiKeys` | API Keys | مفاتيح API |
| `saveKeys` | Save Keys | حفظ المفاتيح |
| `keysSaved` | Keys saved successfully | تم حفظ المفاتيح بنجاح |
| `signIn` | Sign In | تسجيل الدخول |
| `signUp` | Sign Up | إنشاء حساب |
| `signOut` | Sign Out | تسجيل الخروج |
| `email` | Email | البريد الإلكتروني |
| `password` | Password | كلمة السر |
| `language` | Language | اللغة |
| `theme` | Theme | المظهر |
| `light` | Light | فاتح |
| `dark` | Dark | داكن |
| `errorGeneral` | Something went wrong | حدث خطأ |
| `errorNetwork` | No internet connection | لا يوجد اتصال بالإنترنت |
| `retry` | Retry | إعادة المحاولة |
| `agentFailed` | {agentName} failed — tap to retry | فشل {agentName} — اضغط للإعادة |

### عناصر تحتاج Semantics Label

| العنصر | الـ Label |
|--------|----------|
| زر بدء التحليل | `semanticsLabel: l10n.startAnalysis` |
| زر الموافقة | `semanticsLabel: l10n.approve` |
| زر الرفض | `semanticsLabel: l10n.reject` |
| بطاقة رسالة Band | `semanticsLabel: '${l10n.messagePayload}: ${message.messageType.name}'` |
| مؤشر درجة المرشح | `semanticsLabel: '${candidate.name}: ${score}%'` |
| زر رفع الملفات | `semanticsLabel: l10n.uploadCVs` |

---

## 14. Environment Variables

**ملف:** `.env`  
**ملف المثال:** `.env.example` (يُرفع على Git بدون قيم حقيقية)

| المتغير | القيمة في Development | مطلوب في Production؟ |
|---------|----------------------|---------------------|
| `ENVIRONMENT` | `development` | ✅ |
| `SUPABASE_URL` | `https://[project].supabase.co` | ✅ |
| `SUPABASE_ANON_KEY` | `eyJ...` | ✅ |
| `AIMLAPI_BASE_URL` | `https://api.aimlapi.com/v1` | ✅ |
| `AIMLAPI_KEY` | `[user-provided at runtime]` | ✅ |
| `FEATHERLESS_BASE_URL` | `https://api.featherless.ai/v1` | ✅ |
| `FEATHERLESS_KEY` | `[user-provided at runtime]` | ✅ |
| `BAND_API_URL` | `[band-api-url]` | ✅ |
| `BAND_API_KEY` | `[user-provided at runtime]` | ✅ |

> ⚠️ تنبيه للـ Agent: مفاتيح AIMLAPI, Featherless, Band لا تُخزَّن في `.env` للإنتاج — يُدخلها المستخدم في صفحة Settings وتُحفظ في Supabase `user_secrets`. ملف `.env` يحتوي فقط على SUPABASE_URL و SUPABASE_ANON_KEY كبيانات بنية تحتية ثابتة. `ApiKeysCubit` يحمّل المفاتيح من Supabase عند كل تسجيل دخول ويمررها للـ Agent UseCases.

---

## 15. ملاحظات خاصة بهذا المشروع

- **Adversarial Pairing:** الفرق > 20 نقطة بين ScreeningAgent و ReviewerAgent يُنشئ `hasConflict: true`. يُعرض في الـ UI بأيقونة ⚡ وشارة صفراء. هذا سلوك مقصود وليس خطأ.

- **Band Activity Panel:** يعتمد على `supabase.from('band_messages_log').stream(primaryKey: ['id']).eq('session_id', sessionId).eq('candidate_id', candidateId)`. يجب أن يكون Realtime مُفعَّلاً على هذا الجدول في Supabase Dashboard.

- **CandidateSimulator:** وكيل Featherless يُشغَّل داخل `RunInterviewUseCase` تلقائياً قبل التقييم. لا يوجد تدخل بشري في MVP.

- **تسلسل الوكلاء لكل مرشح:** Screening → AdversarialReview → ConflictResolution → (Interview + Cultural بالتوازي) → Coordination. انتبه: Interview و Cultural يُشغَّلان بـ `Future.wait([...])` لتوفير الوقت.

- **اللغة الافتراضية:** الإنجليزية. زر تبديل اللغة في الـ AppBar موجود في جميع الصفحات. `LocaleCubit` يحفظ القرار.

- **RTL:** عند تفعيل العربية، يجب أن يكون `Directionality(textDirection: TextDirection.rtl)` مُطبَّقاً على مستوى `MaterialApp` عبر `locale` من `LocaleCubit`.

- **لا Supabase Auth في صفحة Settings:** صفحة Settings تستخدم `userId` من `AuthCubit` المُحقَّن — لا تستدعي Supabase Auth مباشرةً.

- **Chrome Only للهاكثون:** لا تضف `flutter_web_plugins` overrides لمتصفحات أخرى. اختبر على Chrome فقط.
