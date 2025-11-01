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

  /// No description provided for @companyCode.
  ///
  /// In en, this message translates to:
  /// **'Company Code'**
  String get companyCode;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

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
  /// **'Current Plan: {plan}'**
  String currentPlan(Object plan);

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

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
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

  /// No description provided for @helpAndSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Get help or contact support'**
  String get helpAndSupportDesc;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get aboutDesc;

  /// No description provided for @fontSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fontSizeMedium;

  /// No description provided for @fontSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get fontSizeExtraLarge;

  /// No description provided for @privacySettingsContent.
  ///
  /// In en, this message translates to:
  /// **'Privacy settings would be configured here, including data collection preferences and privacy controls.'**
  String get privacySettingsContent;

  /// No description provided for @fontSizeSample.
  ///
  /// In en, this message translates to:
  /// **'Sample text with current size'**
  String get fontSizeSample;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @aboutTgmAi.
  ///
  /// In en, this message translates to:
  /// **'About TGM AI'**
  String get aboutTgmAi;

  /// No description provided for @clearHistoryDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your conversation history. This action cannot be undone.\\n\\nAre you sure you want to continue?'**
  String get clearHistoryDialogContent;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @resetSettingsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will reset all settings to their default values. Are you sure you want to continue?'**
  String get resetSettingsDialogContent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @historyClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Chat history cleared successfully'**
  String get historyClearedSuccess;

  /// No description provided for @historyClearedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear chat history'**
  String get historyClearedError;

  /// No description provided for @settingsResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetSuccess;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @newToPlatform.
  ///
  /// In en, this message translates to:
  /// **'New to our platform?'**
  String get newToPlatform;

  /// No description provided for @createFreeAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a free account'**
  String get createFreeAccount;

  /// No description provided for @companyLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Company login successful'**
  String get companyLoginSuccess;

  /// No description provided for @jwtNotFound.
  ///
  /// In en, this message translates to:
  /// **'JWT not found in response'**
  String get jwtNotFound;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login error'**
  String get loginError;

  /// No description provided for @googleLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Google login successful'**
  String get googleLoginSuccess;

  /// No description provided for @googleLoginError.
  ///
  /// In en, this message translates to:
  /// **'Google error'**
  String get googleLoginError;

  /// No description provided for @googleError.
  ///
  /// In en, this message translates to:
  /// **'Google error: {error}'**
  String googleError(String error);

  /// No description provided for @biometricAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed: {error}'**
  String biometricAuthFailed(String error);

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @joinOurCommunity.
  ///
  /// In en, this message translates to:
  /// **'Join our community'**
  String get joinOurCommunity;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @passwordMinLength8.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength8;

  /// No description provided for @passwordComplexity.
  ///
  /// In en, this message translates to:
  /// **'Password must contain an uppercase letter, a lowercase letter, and a number'**
  String get passwordComplexity;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms of use and the privacy policy'**
  String get acceptTerms;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAnAccount;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms of use'**
  String get mustAcceptTerms;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccess;

  /// No description provided for @accountCreatedEmailError.
  ///
  /// In en, this message translates to:
  /// **'Account created but there was a problem sending the email'**
  String get accountCreatedEmailError;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration error'**
  String get registrationError;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(String error);

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccess;

  /// No description provided for @googleAuthError.
  ///
  /// In en, this message translates to:
  /// **'Error during Google authentication'**
  String get googleAuthError;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @emailSent.
  ///
  /// In en, this message translates to:
  /// **'Email sent!'**
  String get emailSent;

  /// No description provided for @weSentAnEmailTo.
  ///
  /// In en, this message translates to:
  /// **'We sent an email to:'**
  String get weSentAnEmailTo;

  /// No description provided for @howToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'How to reset your password'**
  String get howToResetPassword;

  /// No description provided for @howToResetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'1. Open your mailbox\n2. Click on the link in the email\n3. You will be redirected to a web page\n4. Enter your new password\n5. Return to the app to log in'**
  String get howToResetPasswordInstructions;

  /// No description provided for @checkSpam.
  ///
  /// In en, this message translates to:
  /// **'📬 Check your spam if you don\'t see the email'**
  String get checkSpam;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @sendingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingInProgress;

  /// No description provided for @emailSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Email sent'**
  String get emailSentMessage;

  /// No description provided for @emailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Email address not found'**
  String get emailNotFound;

  /// No description provided for @sendingError.
  ///
  /// In en, this message translates to:
  /// **'Error while sending'**
  String get sendingError;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetError.
  ///
  /// In en, this message translates to:
  /// **'Error resetting password'**
  String get passwordResetError;

  /// No description provided for @returnToLogin.
  ///
  /// In en, this message translates to:
  /// **'Return to login'**
  String get returnToLogin;

  /// No description provided for @verifyEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get verifyEmail;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get verificationEmailSent;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @openMailbox.
  ///
  /// In en, this message translates to:
  /// **'Open your mailbox'**
  String get openMailbox;

  /// No description provided for @findVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Find the verification email'**
  String get findVerificationEmail;

  /// No description provided for @clickVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Click the \"Verify\" button'**
  String get clickVerifyButton;

  /// No description provided for @accountActivated.
  ///
  /// In en, this message translates to:
  /// **'Your account will be activated automatically!'**
  String get accountActivated;

  /// No description provided for @emailResent.
  ///
  /// In en, this message translates to:
  /// **'Email resent'**
  String get emailResent;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChanged;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expires(Object date);

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(Object error);

  /// No description provided for @plansAndProfileRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Plans and profile refreshed successfully'**
  String get plansAndProfileRefreshed;

  /// No description provided for @failedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh: {error}'**
  String failedToRefresh(Object error);

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @loadingPlans.
  ///
  /// In en, this message translates to:
  /// **'Loading plans...'**
  String get loadingPlans;

  /// No description provided for @failedToLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plans'**
  String get failedToLoadPlans;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noPlansAvailable.
  ///
  /// In en, this message translates to:
  /// **'No plans available'**
  String get noPlansAvailable;

  /// No description provided for @securePaymentWithStripe.
  ///
  /// In en, this message translates to:
  /// **'Secure Payment with Stripe'**
  String get securePaymentWithStripe;

  /// No description provided for @redirectToStripe.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to Stripe\'s secure payment page to complete your purchase.'**
  String get redirectToStripe;

  /// No description provided for @sslEncryption.
  ///
  /// In en, this message translates to:
  /// **'256-bit SSL encryption'**
  String get sslEncryption;

  /// No description provided for @allCreditCardsAccepted.
  ///
  /// In en, this message translates to:
  /// **'All major credit cards accepted'**
  String get allCreditCardsAccepted;

  /// No description provided for @pciDssCompliant.
  ///
  /// In en, this message translates to:
  /// **'PCI DSS Compliant'**
  String get pciDssCompliant;

  /// No description provided for @dataNeverStored.
  ///
  /// In en, this message translates to:
  /// **'Your data is never stored'**
  String get dataNeverStored;

  /// No description provided for @continueToPayment.
  ///
  /// In en, this message translates to:
  /// **'Continue to Payment - {price}'**
  String continueToPayment(Object price);

  /// No description provided for @secureAndEncryptedPayment.
  ///
  /// In en, this message translates to:
  /// **'Secure and Encrypted Payment'**
  String get secureAndEncryptedPayment;

  /// No description provided for @paymentInfoProtected.
  ///
  /// In en, this message translates to:
  /// **'Payment information is protected by bank-level encryption. We never store your card details.'**
  String get paymentInfoProtected;

  /// No description provided for @poweredByStripe.
  ///
  /// In en, this message translates to:
  /// **'Powered by Stripe'**
  String get poweredByStripe;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @mustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to make a payment.'**
  String get mustBeLoggedIn;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get invalidAmount;

  /// No description provided for @redirectingToPayment.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to secure payment page...'**
  String get redirectingToPayment;

  /// No description provided for @paymentCancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled'**
  String get paymentCancelled;

  /// No description provided for @paymentInitializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize payment'**
  String get paymentInitializationFailed;

  /// No description provided for @connectionProblem.
  ///
  /// In en, this message translates to:
  /// **'Connection problem. Check your internet.'**
  String get connectionProblem;

  /// No description provided for @serverNotResponding.
  ///
  /// In en, this message translates to:
  /// **'The server is not responding. Please try again later.'**
  String get serverNotResponding;

  /// No description provided for @verifyingPayment.
  ///
  /// In en, this message translates to:
  /// **'Verifying your payment...'**
  String get verifyingPayment;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get pleaseWait;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful!'**
  String get paymentSuccessful;

  /// No description provided for @subscriptionActivated.
  ///
  /// In en, this message translates to:
  /// **'Your subscription has been successfully activated. You now have access to all premium features!'**
  String get subscriptionActivated;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @startChatting.
  ///
  /// In en, this message translates to:
  /// **'Start chatting'**
  String get startChatting;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get viewProfile;

  /// No description provided for @verificationProblem.
  ///
  /// In en, this message translates to:
  /// **'Verification problem'**
  String get verificationProblem;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not verify your payment. Please contact support if the problem persists.'**
  String get verificationFailed;

  /// No description provided for @retryVerification.
  ///
  /// In en, this message translates to:
  /// **'Retry verification'**
  String get retryVerification;

  /// No description provided for @continueInApp.
  ///
  /// In en, this message translates to:
  /// **'Continue in app'**
  String get continueInApp;

  /// No description provided for @paymentCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Cancelled'**
  String get paymentCancelledTitle;

  /// No description provided for @paymentCancelledMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been cancelled. No charge has been made to your account.'**
  String get paymentCancelledMessage;

  /// No description provided for @noPaymentProcessed.
  ///
  /// In en, this message translates to:
  /// **'No payment has been processed'**
  String get noPaymentProcessed;

  /// No description provided for @accountUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Your account remains unchanged'**
  String get accountUnchanged;

  /// No description provided for @youCanRetry.
  ///
  /// In en, this message translates to:
  /// **'You can try again at any time'**
  String get youCanRetry;

  /// No description provided for @retryPayment.
  ///
  /// In en, this message translates to:
  /// **'Retry Payment'**
  String get retryPayment;

  /// No description provided for @returnToApp.
  ///
  /// In en, this message translates to:
  /// **'Return to App'**
  String get returnToApp;

  /// No description provided for @needHelpContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact support'**
  String get needHelpContactSupport;

  /// No description provided for @viewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View Full History'**
  String get viewFullHistory;

  /// No description provided for @whatCanIHelpYouWith.
  ///
  /// In en, this message translates to:
  /// **'What can I help you with today?'**
  String get whatCanIHelpYouWith;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String daysAgo(Object days);

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @failedToSaveRecording.
  ///
  /// In en, this message translates to:
  /// **'Failed to save voice recording'**
  String get failedToSaveRecording;

  /// No description provided for @recordingError.
  ///
  /// In en, this message translates to:
  /// **'Recording error: {error}'**
  String recordingError(Object error);

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Recording Permission Required'**
  String get permissionDenied;

  /// No description provided for @permissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice recording requires microphone permission. Please enable it in your device settings to record voice messages.'**
  String get permissionDeniedMessage;

  /// No description provided for @startChattingToSeeHistory.
  ///
  /// In en, this message translates to:
  /// **'Start chatting to see your conversation history here'**
  String get startChattingToSeeHistory;

  /// No description provided for @messagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String messagesCount(Object count);

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @switchToConversation.
  ///
  /// In en, this message translates to:
  /// **'Switch to this conversation'**
  String get switchToConversation;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String minutesAgo(Object minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String hoursAgo(Object hours);

  /// No description provided for @deleteConversationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this conversation?'**
  String get deleteConversationConfirmation;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @conversationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// No description provided for @planInterest.
  ///
  /// In en, this message translates to:
  /// **'I am interested in the {planName} plan. Please contact me with more information about pricing and features.'**
  String planInterest(Object planName);

  /// No description provided for @failedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message: {error}'**
  String failedToSend(Object error);

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TGM HydroAI'**
  String get welcomeTo;

  /// No description provided for @chooseAccountType.
  ///
  /// In en, this message translates to:
  /// **'Choose your account type to get started'**
  String get chooseAccountType;

  /// No description provided for @individual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get individual;

  /// No description provided for @personalUse.
  ///
  /// In en, this message translates to:
  /// **'Personal use with social login'**
  String get personalUse;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @businessAccount.
  ///
  /// In en, this message translates to:
  /// **'Business account with company code'**
  String get businessAccount;

  /// No description provided for @companyCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Company code is required'**
  String get companyCodeRequired;

  /// No description provided for @companyCodeLength.
  ///
  /// In en, this message translates to:
  /// **'Company code must be exactly 6 characters'**
  String get companyCodeLength;

  /// No description provided for @invalidCompanyCode.
  ///
  /// In en, this message translates to:
  /// **'Only uppercase letters and numbers allowed'**
  String get invalidCompanyCode;

  /// No description provided for @companyCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit company code'**
  String get companyCodeHint;

  /// No description provided for @companyCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'6 uppercase alphanumeric characters (A-Z, 0-9)'**
  String get companyCodeDescription;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @logoFallback.
  ///
  /// In en, this message translates to:
  /// **'TGM\nAI'**
  String get logoFallback;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;
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
