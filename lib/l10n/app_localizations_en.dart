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
  String get appleLoginSuccess => 'Apple login successful';

  @override
  String get appleLoginError => 'Apple error';

  @override
  String appleError(String error) {
    return 'Apple error: $error';
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
  String currentPlan(Object plan) {
    return 'Current Plan: $plan';
  }

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
  String get pleaseEnterValidEmail => 'Please enter a valid email';

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

  @override
  String get helpAndSupportDesc => 'Get help or contact support';

  @override
  String get aboutDesc => 'App version and information';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeMedium => 'Medium';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeExtraLarge => 'Extra Large';

  @override
  String get privacySettingsContent =>
      'Privacy settings would be configured here, including data collection preferences and privacy controls.';

  @override
  String get fontSizeSample => 'Sample text with current size';

  @override
  String get done => 'Done';

  @override
  String get aboutTgmAi => 'About TGM AI';

  @override
  String get clearHistoryDialogContent =>
      'This will permanently delete all your conversation history. This action cannot be undone.\\n\\nAre you sure you want to continue?';

  @override
  String get clear => 'Clear';

  @override
  String get resetSettingsDialogContent =>
      'This will reset all settings to their default values. Are you sure you want to continue?';

  @override
  String get reset => 'Reset';

  @override
  String get historyClearedSuccess => 'Chat history cleared successfully';

  @override
  String get historyClearedError => 'Failed to clear chat history';

  @override
  String get settingsResetSuccess => 'Settings reset to defaults';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get newToPlatform => 'New to our platform?';

  @override
  String get createFreeAccount => 'Create a free account';

  @override
  String get companyLoginSuccess => 'Company login successful';

  @override
  String get jwtNotFound => 'JWT not found in response';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginError => 'Login error';

  @override
  String get googleLoginSuccess => 'Google login successful';

  @override
  String get googleLoginError => 'Google error';

  @override
  String googleError(String error) {
    return 'Google error: $error';
  }

  @override
  String biometricAuthFailed(String error) {
    return 'Biometric authentication failed: $error';
  }

  @override
  String get createAccount => 'Create account';

  @override
  String get joinOurCommunity => 'Join our community';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get nameMinLength => 'Name must be at least 2 characters';

  @override
  String get passwordMinLength8 => 'Password must be at least 8 characters';

  @override
  String get passwordComplexity =>
      'Password must contain an uppercase letter, a lowercase letter, and a number';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get acceptTerms => 'I accept the terms of use and the privacy policy';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get alreadyHaveAnAccount => 'Already have an account? ';

  @override
  String get mustAcceptTerms => 'You must accept the terms of use';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get accountCreatedEmailError =>
      'Account created but there was a problem sending the email';

  @override
  String get registrationError => 'Registration error';

  @override
  String errorWithMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get accountCreatedSuccess => 'Account created successfully';

  @override
  String get googleAuthError => 'Error during Google authentication';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get resetYourPassword => 'Reset your password';

  @override
  String get resetPasswordInstructions =>
      'Enter your email address and we will send you a link to reset your password.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get emailSent => 'Email sent!';

  @override
  String get weSentAnEmailTo => 'We sent an email to:';

  @override
  String get howToResetPassword => 'How to reset your password';

  @override
  String get howToResetPasswordInstructions =>
      '1. Open your mailbox\n2. Click on the link in the email\n3. You will be redirected to a web page\n4. Enter your new password\n5. Return to the app to log in';

  @override
  String get checkSpam => '📬 Check your spam if you don\'t see the email';

  @override
  String get resendEmail => 'Resend email';

  @override
  String get sendingInProgress => 'Sending...';

  @override
  String get emailSentMessage => 'Email sent';

  @override
  String get emailNotFound => 'Email address not found';

  @override
  String get sendingError => 'Error while sending';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get newPassword => 'New password';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get passwordResetError => 'Error resetting password';

  @override
  String get returnToLogin => 'Return to login';

  @override
  String get verifyEmail => 'Verify email';

  @override
  String get verificationEmailSent => 'Verification email sent!';

  @override
  String get instructions => 'Instructions';

  @override
  String get openMailbox => 'Open your mailbox';

  @override
  String get findVerificationEmail => 'Find the verification email';

  @override
  String get clickVerifyButton => 'Click the \"Verify\" button';

  @override
  String get accountActivated =>
      'Your account will be activated automatically!';

  @override
  String get emailResent => 'Email resent';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String expires(Object date) {
    return 'Expires: $date';
  }

  @override
  String failedToPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get plansAndProfileRefreshed =>
      'Plans and profile refreshed successfully';

  @override
  String failedToRefresh(Object error) {
    return 'Failed to refresh: $error';
  }

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get loadingPlans => 'Loading plans...';

  @override
  String get failedToLoadPlans => 'Failed to load plans';

  @override
  String get retry => 'Retry';

  @override
  String get noPlansAvailable => 'No plans available';

  @override
  String get securePaymentWithStripe => 'Secure Payment with Stripe';

  @override
  String get redirectToStripe =>
      'You will be redirected to Stripe\'s secure payment page to complete your purchase.';

  @override
  String get sslEncryption => '256-bit SSL encryption';

  @override
  String get allCreditCardsAccepted => 'All major credit cards accepted';

  @override
  String get pciDssCompliant => 'PCI DSS Compliant';

  @override
  String get dataNeverStored => 'Your data is never stored';

  @override
  String continueToPayment(Object price) {
    return 'Continue to Payment - $price';
  }

  @override
  String get secureAndEncryptedPayment => 'Secure and Encrypted Payment';

  @override
  String get paymentInfoProtected =>
      'Payment information is protected by bank-level encryption. We never store your card details.';

  @override
  String get poweredByStripe => 'Powered by Stripe';

  @override
  String get sessionExpired => 'Session expired. Please log in again.';

  @override
  String get mustBeLoggedIn => 'You must be logged in to make a payment.';

  @override
  String get invalidAmount => 'Invalid amount';

  @override
  String get redirectingToPayment => 'Redirecting to secure payment page...';

  @override
  String get paymentCancelled => 'Payment cancelled';

  @override
  String get paymentInitializationFailed => 'Failed to initialize payment';

  @override
  String get connectionProblem => 'Connection problem. Check your internet.';

  @override
  String get serverNotResponding =>
      'The server is not responding. Please try again later.';

  @override
  String get verifyingPayment => 'Verifying your payment...';

  @override
  String get pleaseWait => 'Please wait a moment';

  @override
  String get paymentSuccessful => 'Payment successful!';

  @override
  String get subscriptionActivated =>
      'Your subscription has been successfully activated. You now have access to all premium features!';

  @override
  String get plan => 'Plan';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get session => 'Session';

  @override
  String get startChatting => 'Start chatting';

  @override
  String get viewProfile => 'View profile';

  @override
  String get verificationProblem => 'Verification problem';

  @override
  String get verificationFailed =>
      'Could not verify your payment. Please contact support if the problem persists.';

  @override
  String get retryVerification => 'Retry verification';

  @override
  String get continueInApp => 'Continue in app';

  @override
  String get paymentCancelledTitle => 'Payment Cancelled';

  @override
  String get paymentCancelledMessage =>
      'Your payment has been cancelled. No charge has been made to your account.';

  @override
  String get noPaymentProcessed => 'No payment has been processed';

  @override
  String get accountUnchanged => 'Your account remains unchanged';

  @override
  String get youCanRetry => 'You can try again at any time';

  @override
  String get retryPayment => 'Retry Payment';

  @override
  String get returnToApp => 'Return to App';

  @override
  String get needHelpContactSupport => 'Need help? Contact support';

  @override
  String get viewFullHistory => 'View Full History';

  @override
  String get whatCanIHelpYouWith => 'What can I help you with today?';

  @override
  String get gallery => 'Gallery';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get recording => 'Recording';

  @override
  String get failedToSaveRecording => 'Failed to save voice recording';

  @override
  String recordingError(Object error) {
    return 'Recording error: $error';
  }

  @override
  String get permissionDenied => 'Recording Permission Required';

  @override
  String get permissionDeniedMessage =>
      'Voice recording requires microphone permission. Please enable it in your device settings to record voice messages.';

  @override
  String get startChattingToSeeHistory =>
      'Start chatting to see your conversation history here';

  @override
  String messagesCount(Object count) {
    return '$count messages';
  }

  @override
  String get current => 'Current';

  @override
  String get switchToConversation => 'Switch to this conversation';

  @override
  String get deleteConversation => 'Delete conversation';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String get deleteConversationConfirmation =>
      'Are you sure you want to delete this conversation?';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String planInterest(Object planName) {
    return 'I am interested in the $planName plan. Please contact me with more information about pricing and features.';
  }

  @override
  String failedToSend(Object error) {
    return 'Failed to send message: $error';
  }

  @override
  String get welcomeTo => 'Welcome to TGM HydroAI';

  @override
  String get chooseAccountType => 'Choose your account type to get started';

  @override
  String get individual => 'Individual';

  @override
  String get personalUse => 'Personal use with social login';

  @override
  String get company => 'Company';

  @override
  String get businessAccount => 'Business account with company code';

  @override
  String get companyCodeRequired => 'Company code is required';

  @override
  String get companyCodeLength => 'Company code must be exactly 6 characters';

  @override
  String get invalidCompanyCode => 'Only uppercase letters and numbers allowed';

  @override
  String get companyCodeHint => 'Enter 6-digit company code';

  @override
  String get companyCodeDescription =>
      '6 uppercase alphanumeric characters (A-Z, 0-9)';

  @override
  String get continueButton => 'Continue';

  @override
  String get logoFallback => 'TGM\nAI';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get companyCode => 'Company Code';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String failedToDeleteAccount(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get delete => 'Delete';
}
