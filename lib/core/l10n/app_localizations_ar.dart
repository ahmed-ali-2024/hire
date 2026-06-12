// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Hire';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get newRecruitment => 'توظيف جديد';

  @override
  String get jobTitle => 'عنوان الوظيفة';

  @override
  String get jobDescription => 'متطلبات الوظيفة';

  @override
  String get uploadCVs => 'رفع السير الذاتية';

  @override
  String get startAnalysis => 'بدء التحليل';

  @override
  String get analyzing => 'جاري التحليل...';

  @override
  String get screeningAgent => 'وكيل الفرز';

  @override
  String get reviewerAgent => 'وكيل المراجعة';

  @override
  String get interviewAgent => 'وكيل المقابلة';

  @override
  String get culturalAgent => 'وكيل التقييم الثقافي';

  @override
  String get coordinatorAgent => 'وكيل التنسيق';

  @override
  String get bandActivity => 'نشاط Band';

  @override
  String get contextHandoff => 'تسليم السياق';

  @override
  String get reviewRequest => 'طلب مراجعة';

  @override
  String get reviewResult => 'نتيجة المراجعة';

  @override
  String get finalEvaluation => 'التقييم النهائي';

  @override
  String get coordinatorSync => 'مزامنة التنسيق';

  @override
  String get conflictDetected => 'تم اكتشاف تعارض';

  @override
  String get conflictNote => 'تعارض في التقييم — يُنصح بمراجعة بشرية';

  @override
  String get overallScore => 'الدرجة الإجمالية';

  @override
  String get technicalScore => 'الدرجة التقنية';

  @override
  String get culturalScore => 'درجة التوافق الثقافي';

  @override
  String get screeningScore => 'درجة الفرز';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get requestReview => 'طلب مراجعة';

  @override
  String get accepted => 'مقبول';

  @override
  String get rejected => 'مرفوض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get messagePayload => 'محتوى الرسالة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get apiKeys => 'مفاتيح API';

  @override
  String get saveKeys => 'حفظ المفاتيح';

  @override
  String get keysSaved => 'تم حفظ المفاتيح بنجاح';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة السر';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get errorGeneral => 'حدث خطأ ما';

  @override
  String get errorNetwork => 'لا يوجد اتصال بالإنترنت';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String agentFailed(String agentName) {
    return 'فشل $agentName — اضغط للإعادة';
  }
}
