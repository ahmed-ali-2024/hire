// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hire';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get newRecruitment => 'New Recruitment';

  @override
  String get jobTitle => 'Job Title';

  @override
  String get jobDescription => 'Job Description';

  @override
  String get uploadCVs => 'Upload CVs';

  @override
  String get startAnalysis => 'Start Analysis';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get screeningAgent => 'Screening Agent';

  @override
  String get reviewerAgent => 'Reviewer Agent';

  @override
  String get interviewAgent => 'Interview Agent';

  @override
  String get culturalAgent => 'Cultural Agent';

  @override
  String get coordinatorAgent => 'Coordinator Agent';

  @override
  String get bandActivity => 'Band Activity';

  @override
  String get contextHandoff => 'Context Handoff';

  @override
  String get reviewRequest => 'Review Request';

  @override
  String get reviewResult => 'Review Result';

  @override
  String get finalEvaluation => 'Final Evaluation';

  @override
  String get coordinatorSync => 'Coordinator Sync';

  @override
  String get conflictDetected => 'Conflict Detected';

  @override
  String get conflictNote =>
      'Conflict in evaluation — human review recommended';

  @override
  String get overallScore => 'Overall Score';

  @override
  String get technicalScore => 'Technical Score';

  @override
  String get culturalScore => 'Cultural Score';

  @override
  String get screeningScore => 'Screening Score';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get requestReview => 'Request Review';

  @override
  String get accepted => 'Accepted';

  @override
  String get rejected => 'Rejected';

  @override
  String get pending => 'Pending';

  @override
  String get viewDetails => 'View Details';

  @override
  String get messagePayload => 'Message Payload';

  @override
  String get settings => 'Settings';

  @override
  String get apiKeys => 'API Keys';

  @override
  String get saveKeys => 'Save Keys';

  @override
  String get keysSaved => 'Keys saved successfully';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get errorGeneral => 'Something went wrong';

  @override
  String get errorNetwork => 'No internet connection';

  @override
  String get retry => 'Retry';

  @override
  String agentFailed(String agentName) {
    return '$agentName failed — tap to retry';
  }
}
