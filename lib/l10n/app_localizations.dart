import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'TGM HydroAI Chat'**
  String get appTitle;

  /// The tagline shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Intelligent Chat Assistant'**
  String get appTagline;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Email or username input placeholder
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get emailOrUsername;

  /// Password input placeholder
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Social login button text
  ///
  /// In en, this message translates to:
  /// **'Continue with {provider}'**
  String continueWith(String provider);

  /// Divider text between login options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// AI assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeYourMessage;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit profile button text
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Messages stat label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Days active stat label
  ///
  /// In en, this message translates to:
  /// **'Days Active'**
  String get daysActive;

  /// Rating stat label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Chat history menu item
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// Preferences menu item
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications setting
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Push notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for new messages'**
  String get pushNotificationsDesc;

  /// Message sounds setting
  ///
  /// In en, this message translates to:
  /// **'Message Sounds'**
  String get messageSounds;

  /// Message sounds description
  ///
  /// In en, this message translates to:
  /// **'Play sound when messages arrive'**
  String get messageSoundsDesc;

  /// Chat preferences section title
  ///
  /// In en, this message translates to:
  /// **'Chat Preferences'**
  String get chatPreferences;

  /// Auto-save conversations setting
  ///
  /// In en, this message translates to:
  /// **'Auto-save Conversations'**
  String get autoSaveConversations;

  /// Auto-save conversations description
  ///
  /// In en, this message translates to:
  /// **'Automatically save chat history'**
  String get autoSaveConversationsDesc;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Dark mode description
  ///
  /// In en, this message translates to:
  /// **'Use dark theme for the app'**
  String get darkModeDesc;

  /// Security section title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// Biometric authentication setting
  ///
  /// In en, this message translates to:
  /// **'Biometric Authentication'**
  String get biometricAuth;

  /// Biometric authentication description
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID to unlock'**
  String get biometricAuthDesc;

  /// Account section title
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Privacy settings menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Settings'**
  String get privacySettings;

  /// Privacy settings description
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy preferences'**
  String get privacySettingsDesc;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Font size setting
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Data and storage section title
  ///
  /// In en, this message translates to:
  /// **'Data & Storage'**
  String get dataAndStorage;

  /// Clear chat history menu item
  ///
  /// In en, this message translates to:
  /// **'Clear Chat History'**
  String get clearChatHistory;

  /// Clear chat history description
  ///
  /// In en, this message translates to:
  /// **'Delete all conversation history'**
  String get clearChatHistoryDesc;

  /// Reset settings menu item
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Reset settings description
  ///
  /// In en, this message translates to:
  /// **'Reset all settings to default'**
  String get resetSettingsDesc;

  /// Log out button text
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Change photo instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to change photo'**
  String get tapToChangePhoto;

  /// Photo library option
  ///
  /// In en, this message translates to:
  /// **'Photo Library'**
  String get photoLibrary;

  /// Camera option
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Remove photo option
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// Name validation error
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get emailCannotBeEmpty;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Email validation error on login
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or username'**
  String get pleaseEnterYourEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterYourPassword;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// Default welcome message from AI
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your AI assistant. How can I help you today?'**
  String get welcomeMessage;

  /// AI error response message
  ///
  /// In en, this message translates to:
  /// **'I\'m sorry, I encountered an error. Please try again.'**
  String get aiResponseError;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English (US)'**
  String get languageEnglish;

  /// French language option
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// Biometric login button text
  ///
  /// In en, this message translates to:
  /// **'Use Biometric Login'**
  String get useBiometricLogin;

  /// Biometric authentication in progress text
  ///
  /// In en, this message translates to:
  /// **'Authenticating...'**
  String get authenticating;

  /// Payment screen title
  ///
  /// In en, this message translates to:
  /// **'Complete Purchase'**
  String get completePurchase;

  /// Selected plan label
  ///
  /// In en, this message translates to:
  /// **'Selected Plan'**
  String get selectedPlan;

  /// Features included label
  ///
  /// In en, this message translates to:
  /// **'Features included:'**
  String get featuresIncluded;

  /// Payment information section title
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get paymentInformation;

  /// Pay button text
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payAmount(String amount);

  /// Payment processing text
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Security information text
  ///
  /// In en, this message translates to:
  /// **'Your payment information is secure and encrypted. We never store your card details.'**
  String get secureAndEncrypted;

  /// Card validation error message
  ///
  /// In en, this message translates to:
  /// **'Please fill in all credit card fields'**
  String get pleaseFillAllFields;

  /// Successful payment message
  ///
  /// In en, this message translates to:
  /// **'Successfully upgraded to {planName} plan!'**
  String successfullyUpgraded(String planName);

  /// Payment failure message
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailed(String error);

  /// CVV validation message
  ///
  /// In en, this message translates to:
  /// **'Please input a valid CVV'**
  String get pleaseInputValidCvv;

  /// Date validation message
  ///
  /// In en, this message translates to:
  /// **'Please input a valid date'**
  String get pleaseInputValidDate;

  /// Card number validation message
  ///
  /// In en, this message translates to:
  /// **'Please input a valid number'**
  String get pleaseInputValidNumber;

  /// Current plan section title
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// Button text for selecting a plan
  ///
  /// In en, this message translates to:
  /// **'Choose Plan'**
  String get choosePlan;

  /// Plan expiry date
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String planExpires(String date);

  /// Change plan menu item
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get changePlan;

  /// No profile data message
  ///
  /// In en, this message translates to:
  /// **'No profile data available'**
  String get noProfileData;

  /// Help and support dialog title
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupportTitle;

  /// Help and support dialog content
  ///
  /// In en, this message translates to:
  /// **'For support, please contact us at:\nsupport@ensolutions.ca\n\nOr visit our help center online.'**
  String get helpAndSupportContent;

  /// About dialog title
  ///
  /// In en, this message translates to:
  /// **'About TGM HydroAI'**
  String get aboutTitle;

  /// About dialog content
  ///
  /// In en, this message translates to:
  /// **'TGM HydroAI Chat App v1.0.0\n\nAn intelligent chat application powered by advanced AI technology.\n\n© 2024 TGM AI. All rights reserved.'**
  String get aboutContent;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// Plan name with suffix
  ///
  /// In en, this message translates to:
  /// **'{plan} Plan'**
  String planName(String plan);

  /// Contact us button text
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Enterprise contact page title
  ///
  /// In en, this message translates to:
  /// **'Enterprise Contact'**
  String get enterpriseContact;

  /// Enterprise solutions title
  ///
  /// In en, this message translates to:
  /// **'Enterprise Solutions'**
  String get enterpriseSolutions;

  /// Enterprise solutions description
  ///
  /// In en, this message translates to:
  /// **'Get customized solutions for your business needs. Our team will contact you within 24 hours to discuss your requirements.'**
  String get enterpriseDescription;

  /// Contact information form title
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// Company name field label
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Email address field label
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Message field label
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// Send message button text
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// Sending message progress text
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// Alternative contact methods section title
  ///
  /// In en, this message translates to:
  /// **'Alternative Contact Methods'**
  String get alternativeContactMethods;

  /// Business hours label
  ///
  /// In en, this message translates to:
  /// **'Business Hours'**
  String get businessHours;

  /// Business hours value
  ///
  /// In en, this message translates to:
  /// **'Mon - Fri: 9:00 AM - 6:00 PM EST'**
  String get businessHoursValue;

  /// Enterprise email address
  ///
  /// In en, this message translates to:
  /// **'hello@ensolutions.ca'**
  String get enterpriseEmail;

  /// Enterprise phone number
  ///
  /// In en, this message translates to:
  /// **'+1 (514) 501-9202'**
  String get enterprisePhone;

  /// Message minimum length validation
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (minimum 20 characters)'**
  String get messageMinLength;

  /// Company name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your company name'**
  String get enterCompanyName;

  /// Full name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// Email address field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailAddress;

  /// Phone number field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get enterPhoneNumber;

  /// Message field hint
  ///
  /// In en, this message translates to:
  /// **'Tell us about your business needs and requirements...'**
  String get enterMessage;

  /// Company name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your company name'**
  String get pleaseEnterCompanyName;

  /// Full name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// Email address validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get pleaseEnterEmailAddress;

  /// Phone number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// Message validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your message'**
  String get pleaseEnterMessage;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get pleaseEnterValidEmail;

  /// Message sent success notification
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your message has been sent successfully. Our enterprise team will contact you within 24 hours.'**
  String get messageSentSuccessfully;

  /// Message send error notification
  ///
  /// In en, this message translates to:
  /// **'Error sending message: {error}'**
  String messageSendError(String error);

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Current plan section title
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlanTitle;

  /// Message shown to individual users for login options
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred sign-in method'**
  String get choosePreferredSignInMethod;

  /// Username field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterYourUsername;

  /// Username validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterYourUsername;

  /// Password field placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// Google login button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Facebook login button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// Apple login button text
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Login error message
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// Social login success message
  ///
  /// In en, this message translates to:
  /// **'Successfully logged in with {provider}'**
  String successfullyLoggedInWith(String provider);

  /// Biometric auth error message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed: {error}'**
  String biometricAuthenticationFailed(String error);

  /// Biometric authentication prompt
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to login to TGM HydroAI Chat'**
  String get pleaseAuthenticateToLogin;

  /// Business hours text
  ///
  /// In en, this message translates to:
  /// **'Mon - Fri: 9:00 AM - 6:00 PM PST'**
  String get businessHoursText;

  /// Message validation error for minimum length
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (minimum 20 characters)'**
  String get pleaseProvideMoreDetails;

  /// Plans screen title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Plan'**
  String get chooseYourPlan;

  /// Plans hero section title
  ///
  /// In en, this message translates to:
  /// **'Unlock the Power of AI'**
  String get unlockThePowerOfAI;

  /// Plans hero section description
  ///
  /// In en, this message translates to:
  /// **'Choose the perfect plan to enhance your productivity\nwith our advanced AI assistant'**
  String get choosePerfectPlan;

  /// Free plan name
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freePlan;

  /// Pro plan name
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proPlan;

  /// Premium plan name
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumPlan;

  /// Enterprise plan name
  ///
  /// In en, this message translates to:
  /// **'Enterprise'**
  String get enterprisePlan;

  /// Enterprise plan pricing text
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUsForPricing;

  /// Free plan feature
  ///
  /// In en, this message translates to:
  /// **'10 messages per day'**
  String get messagesPerDay;

  /// Free plan feature
  ///
  /// In en, this message translates to:
  /// **'Basic AI responses'**
  String get basicAIResponses;

  /// Free plan feature
  ///
  /// In en, this message translates to:
  /// **'Standard support'**
  String get standardSupport;

  /// Pro plan feature
  ///
  /// In en, this message translates to:
  /// **'Unlimited messages'**
  String get unlimitedMessages;

  /// Pro plan feature
  ///
  /// In en, this message translates to:
  /// **'Advanced AI features'**
  String get advancedAIFeatures;

  /// Pro plan feature
  ///
  /// In en, this message translates to:
  /// **'Priority responses'**
  String get priorityResponses;

  /// Pro plan feature
  ///
  /// In en, this message translates to:
  /// **'File attachments'**
  String get fileAttachments;

  /// Pro plan feature
  ///
  /// In en, this message translates to:
  /// **'Message history'**
  String get messageHistory;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Everything in Pro'**
  String get everythingInPro;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Premium AI model'**
  String get premiumAIModel;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Voice messages'**
  String get voiceMessages;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get prioritySupport;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Custom themes'**
  String get customThemes;

  /// Premium plan feature
  ///
  /// In en, this message translates to:
  /// **'Export conversations'**
  String get exportConversations;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Everything in Premium'**
  String get everythingInPremium;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Custom AI training'**
  String get customAITraining;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Team collaboration'**
  String get teamCollaboration;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get adminDashboard;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Custom branding'**
  String get customBranding;

  /// Enterprise plan feature
  ///
  /// In en, this message translates to:
  /// **'Dedicated support'**
  String get dedicatedSupport;

  /// Plans bottom section title
  ///
  /// In en, this message translates to:
  /// **'Secure & Reliable'**
  String get secureAndReliable;

  /// Plans security description
  ///
  /// In en, this message translates to:
  /// **'All plans come with enterprise-grade security,\n24/7 uptime, and money-back guarantee.'**
  String get enterpriseGradeSecurity;

  /// Security feature label
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secure;

  /// Speed feature label
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// Support feature label
  ///
  /// In en, this message translates to:
  /// **'24/7 Support'**
  String get support247;

  /// Chat drawer title
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistory;

  /// Empty conversation history message
  ///
  /// In en, this message translates to:
  /// **'No conversations in history'**
  String get noConversationsInHistory;

  /// New conversation tooltip
  ///
  /// In en, this message translates to:
  /// **'New Conversation'**
  String get newConversation;
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
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
