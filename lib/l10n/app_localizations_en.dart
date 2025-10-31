// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TGM HydroAI Chat';

  @override
  String get appTagline => 'Intelligent Chat Assistant';

  @override
  String get loading => 'Loading...';

  @override
  String get signIn => 'Sign In';

  @override
  String get emailOrUsername => 'Email or username';

  @override
  String get password => 'Password';

  @override
  String continueWith(String provider) {
    return 'Continue with $provider';
  }

  @override
  String get or => 'or';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get typeYourMessage => 'Type your message...';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get messages => 'Messages';

  @override
  String get daysActive => 'Days Active';

  @override
  String get rating => 'Rating';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get preferences => 'Preferences';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDesc => 'Receive notifications for new messages';

  @override
  String get messageSounds => 'Message Sounds';

  @override
  String get messageSoundsDesc => 'Play sound when messages arrive';

  @override
  String get chatPreferences => 'Chat Preferences';

  @override
  String get autoSaveConversations => 'Auto-save Conversations';

  @override
  String get autoSaveConversationsDesc => 'Automatically save chat history';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Use dark theme for the app';

  @override
  String get security => 'Security';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get biometricAuthDesc => 'Use fingerprint or face ID to unlock';

  @override
  String get account => 'Account';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get privacySettingsDesc => 'Manage your privacy preferences';

  @override
  String get language => 'Language';

  @override
  String get fontSize => 'Font Size';

  @override
  String get dataAndStorage => 'Data & Storage';

  @override
  String get clearChatHistory => 'Clear Chat History';

  @override
  String get clearChatHistoryDesc => 'Delete all conversation history';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsDesc => 'Reset all settings to default';

  @override
  String get logOut => 'Log Out';

  @override
  String get tapToChangePhoto => 'Tap to change photo';

  @override
  String get photoLibrary => 'Photo Library';

  @override
  String get camera => 'Camera';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get emailCannotBeEmpty => 'Email cannot be empty';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get pleaseEnterYourEmail => 'Please enter your email or username';

  @override
  String get pleaseEnterYourPassword => 'Please enter your password';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Password must be at least 6 characters';

  @override
  String get welcomeMessage =>
      'Hello! I\'m your AI assistant. How can I help you today?';

  @override
  String get aiResponseError =>
      'I\'m sorry, I encountered an error. Please try again.';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get useBiometricLogin => 'Use Biometric Login';

  @override
  String get authenticating => 'Authenticating...';

  @override
  String get completePurchase => 'Complete Purchase';

  @override
  String get selectedPlan => 'Selected Plan';

  @override
  String get featuresIncluded => 'Features included:';

  @override
  String get paymentInformation => 'Payment Information';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get processing => 'Processing...';

  @override
  String get secureAndEncrypted =>
      'Your payment information is secure and encrypted. We never store your card details.';

  @override
  String get pleaseFillAllFields => 'Please fill in all credit card fields';

  @override
  String successfullyUpgraded(String planName) {
    return 'Successfully upgraded to $planName plan!';
  }

  @override
  String paymentFailed(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get pleaseInputValidCvv => 'Please input a valid CVV';

  @override
  String get pleaseInputValidDate => 'Please input a valid date';

  @override
  String get pleaseInputValidNumber => 'Please input a valid number';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get choosePlan => 'Choose Plan';

  @override
  String planExpires(String date) {
    return 'Expires: $date';
  }

  @override
  String get changePlan => 'Change Plan';

  @override
  String get noProfileData => 'No profile data available';

  @override
  String get helpAndSupportTitle => 'Help & Support';

  @override
  String get helpAndSupportContent =>
      'For support, please contact us at:\nsupport@ensolutions.ca\n\nOr visit our help center online.';

  @override
  String get aboutTitle => 'About TGM HydroAI';

  @override
  String get aboutContent =>
      'TGM HydroAI Chat App v1.0.0\n\nAn intelligent chat application powered by advanced AI technology.\n\n© 2024 TGM AI. All rights reserved.';

  @override
  String get ok => 'OK';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String planName(String plan) {
    return '$plan Plan';
  }

  @override
  String get contactUs => 'Contact Us';

  @override
  String get enterpriseContact => 'Enterprise Contact';

  @override
  String get enterpriseSolutions => 'Enterprise Solutions';

  @override
  String get enterpriseDescription =>
      'Get customized solutions for your business needs. Our team will contact you within 24 hours to discuss your requirements.';

  @override
  String get contactInformation => 'Contact Information';

  @override
  String get companyName => 'Company Name';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get message => 'Message';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get sending => 'Sending...';

  @override
  String get alternativeContactMethods => 'Alternative Contact Methods';

  @override
  String get businessHours => 'Business Hours';

  @override
  String get businessHoursValue => 'Mon - Fri: 9:00 AM - 6:00 PM EST';

  @override
  String get enterpriseEmail => 'hello@ensolutions.ca';

  @override
  String get enterprisePhone => '+1 (514) 501-9202';

  @override
  String get messageMinLength =>
      'Please provide more details (minimum 20 characters)';

  @override
  String get enterCompanyName => 'Enter your company name';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get enterEmailAddress => 'Enter your email address';

  @override
  String get enterPhoneNumber => 'Enter your phone number';

  @override
  String get enterMessage =>
      'Tell us about your business needs and requirements...';

  @override
  String get pleaseEnterCompanyName => 'Please enter your company name';

  @override
  String get pleaseEnterFullName => 'Please enter your full name';

  @override
  String get pleaseEnterEmailAddress => 'Please enter your email address';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter your phone number';

  @override
  String get pleaseEnterMessage => 'Please enter your message';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String get messageSentSuccessfully =>
      'Thank you! Your message has been sent successfully. Our enterprise team will contact you within 24 hours.';

  @override
  String messageSendError(String error) {
    return 'Error sending message: $error';
  }

  @override
  String get close => 'Close';

  @override
  String get currentPlanTitle => 'Current Plan';

  @override
  String get choosePreferredSignInMethod =>
      'Choose your preferred sign-in method';

  @override
  String get enterYourUsername => 'Enter your username';

  @override
  String get pleaseEnterYourUsername => 'Please enter your username';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String successfullyLoggedInWith(String provider) {
    return 'Successfully logged in with $provider';
  }

  @override
  String biometricAuthenticationFailed(String error) {
    return 'Biometric authentication failed: $error';
  }

  @override
  String get pleaseAuthenticateToLogin =>
      'Please authenticate to login to TGM HydroAI Chat';

  @override
  String get businessHoursText => 'Mon - Fri: 9:00 AM - 6:00 PM PST';

  @override
  String get pleaseProvideMoreDetails =>
      'Please provide more details (minimum 20 characters)';

  @override
  String get chooseYourPlan => 'Choose Your Plan';

  @override
  String get unlockThePowerOfAI => 'Unlock the Power of AI';

  @override
  String get choosePerfectPlan =>
      'Choose the perfect plan to enhance your productivity\nwith our advanced AI assistant';

  @override
  String get freePlan => 'Free';

  @override
  String get proPlan => 'Pro';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get enterprisePlan => 'Enterprise';

  @override
  String get contactUsForPricing => 'Contact us';

  @override
  String get messagesPerDay => '10 messages per day';

  @override
  String get basicAIResponses => 'Basic AI responses';

  @override
  String get standardSupport => 'Standard support';

  @override
  String get unlimitedMessages => 'Unlimited messages';

  @override
  String get advancedAIFeatures => 'Advanced AI features';

  @override
  String get priorityResponses => 'Priority responses';

  @override
  String get fileAttachments => 'File attachments';

  @override
  String get messageHistory => 'Message history';

  @override
  String get everythingInPro => 'Everything in Pro';

  @override
  String get premiumAIModel => 'Premium AI model';

  @override
  String get voiceMessages => 'Voice messages';

  @override
  String get prioritySupport => 'Priority support';

  @override
  String get customThemes => 'Custom themes';

  @override
  String get exportConversations => 'Export conversations';

  @override
  String get everythingInPremium => 'Everything in Premium';

  @override
  String get customAITraining => 'Custom AI training';

  @override
  String get teamCollaboration => 'Team collaboration';

  @override
  String get adminDashboard => 'Admin dashboard';

  @override
  String get customBranding => 'Custom branding';

  @override
  String get dedicatedSupport => 'Dedicated support';

  @override
  String get secureAndReliable => 'Secure & Reliable';

  @override
  String get enterpriseGradeSecurity =>
      'All plans come with enterprise-grade security,\n24/7 uptime, and money-back guarantee.';

  @override
  String get secure => 'Secure';

  @override
  String get fast => 'Fast';

  @override
  String get support247 => '24/7 Support';

  @override
  String get conversationHistory => 'Conversation History';

  @override
  String get noConversationsInHistory => 'No conversations in history';

  @override
  String get newConversation => 'New Conversation';
}
