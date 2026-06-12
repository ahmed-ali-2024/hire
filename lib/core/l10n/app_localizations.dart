import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Hire'**
  String get appName;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @newRecruitment.
  ///
  /// In en, this message translates to:
  /// **'New Recruitment'**
  String get newRecruitment;

  /// No description provided for @jobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job Title'**
  String get jobTitle;

  /// No description provided for @jobDescription.
  ///
  /// In en, this message translates to:
  /// **'Job Description'**
  String get jobDescription;

  /// No description provided for @uploadCVs.
  ///
  /// In en, this message translates to:
  /// **'Upload CVs'**
  String get uploadCVs;

  /// No description provided for @startAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis'**
  String get startAnalysis;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @screeningAgent.
  ///
  /// In en, this message translates to:
  /// **'Screening Agent'**
  String get screeningAgent;

  /// No description provided for @reviewerAgent.
  ///
  /// In en, this message translates to:
  /// **'Reviewer Agent'**
  String get reviewerAgent;

  /// No description provided for @interviewAgent.
  ///
  /// In en, this message translates to:
  /// **'Interview Agent'**
  String get interviewAgent;

  /// No description provided for @culturalAgent.
  ///
  /// In en, this message translates to:
  /// **'Cultural Agent'**
  String get culturalAgent;

  /// No description provided for @coordinatorAgent.
  ///
  /// In en, this message translates to:
  /// **'Coordinator Agent'**
  String get coordinatorAgent;

  /// No description provided for @bandActivity.
  ///
  /// In en, this message translates to:
  /// **'Band Activity'**
  String get bandActivity;

  /// No description provided for @contextHandoff.
  ///
  /// In en, this message translates to:
  /// **'Context Handoff'**
  String get contextHandoff;

  /// No description provided for @reviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Review Request'**
  String get reviewRequest;

  /// No description provided for @reviewResult.
  ///
  /// In en, this message translates to:
  /// **'Review Result'**
  String get reviewResult;

  /// No description provided for @finalEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Final Evaluation'**
  String get finalEvaluation;

  /// No description provided for @coordinatorSync.
  ///
  /// In en, this message translates to:
  /// **'Coordinator Sync'**
  String get coordinatorSync;

  /// No description provided for @conflictDetected.
  ///
  /// In en, this message translates to:
  /// **'Conflict Detected'**
  String get conflictDetected;

  /// No description provided for @conflictNote.
  ///
  /// In en, this message translates to:
  /// **'Conflict in evaluation — human review recommended'**
  String get conflictNote;

  /// No description provided for @overallScore.
  ///
  /// In en, this message translates to:
  /// **'Overall Score'**
  String get overallScore;

  /// No description provided for @technicalScore.
  ///
  /// In en, this message translates to:
  /// **'Technical Score'**
  String get technicalScore;

  /// No description provided for @culturalScore.
  ///
  /// In en, this message translates to:
  /// **'Cultural Score'**
  String get culturalScore;

  /// No description provided for @screeningScore.
  ///
  /// In en, this message translates to:
  /// **'Screening Score'**
  String get screeningScore;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @requestReview.
  ///
  /// In en, this message translates to:
  /// **'Request Review'**
  String get requestReview;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @messagePayload.
  ///
  /// In en, this message translates to:
  /// **'Message Payload'**
  String get messagePayload;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @apiKeys.
  ///
  /// In en, this message translates to:
  /// **'API Keys'**
  String get apiKeys;

  /// No description provided for @saveKeys.
  ///
  /// In en, this message translates to:
  /// **'Save Keys'**
  String get saveKeys;

  /// No description provided for @keysSaved.
  ///
  /// In en, this message translates to:
  /// **'Keys saved successfully'**
  String get keysSaved;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneral;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNetwork;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @agentFailed.
  ///
  /// In en, this message translates to:
  /// **'{agentName} failed — tap to retry'**
  String agentFailed(String agentName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
