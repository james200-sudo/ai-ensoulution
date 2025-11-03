// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get companyCode => 'Company Code';

  @override
  String get delete => 'Delete';

  @override
  String get appTitle => 'TGM IA Chat';

  @override
  String get appTagline => 'Asistente de Chat Inteligente';

  @override
  String get loading => 'Cargando...';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get emailOrUsername => 'Email o nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String continueWith(String provider) {
    return 'Continuar con $provider';
  }

  @override
  String get or => 'o';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get typeYourMessage => 'Escribe tu mensaje...';

  @override
  String get profile => 'Perfil';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get name => 'Nombre';

  @override
  String get email => 'Email';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get messages => 'Mensajes';

  @override
  String get daysActive => 'Días activos';

  @override
  String get rating => 'Calificación';

  @override
  String get chatHistory => 'Historial de chat';

  @override
  String get preferences => 'Preferencias';

  @override
  String get helpAndSupport => 'Ayuda y soporte';

  @override
  String get about => 'Acerca de';

  @override
  String get settings => 'Configuración';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones push';

  @override
  String get pushNotificationsDesc =>
      'Recibir notificaciones para nuevos mensajes';

  @override
  String get messageSounds => 'Sonidos de mensajes';

  @override
  String get messageSoundsDesc => 'Reproducir sonido cuando lleguen mensajes';

  @override
  String get chatPreferences => 'Preferencias de chat';

  @override
  String get autoSaveConversations => 'Guardar conversaciones automáticamente';

  @override
  String get autoSaveConversationsDesc =>
      'Guardar automáticamente el historial de chat';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get darkModeDesc => 'Usar tema oscuro para la aplicación';

  @override
  String get security => 'Seguridad';

  @override
  String get biometricAuth => 'Autenticación biométrica';

  @override
  String get biometricAuthDesc =>
      'Usar huella dactilar o Face ID para desbloquear';

  @override
  String get account => 'Cuenta';

  @override
  String get privacySettings => 'Configuración de privacidad';

  @override
  String get privacySettingsDesc => 'Gestionar tus preferencias de privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get fontSize => 'Tamaño de fuente';

  @override
  String get dataAndStorage => 'Datos y almacenamiento';

  @override
  String get clearChatHistory => 'Borrar historial de chat';

  @override
  String get clearChatHistoryDesc =>
      'Eliminar todo el historial de conversaciones';

  @override
  String get resetSettings => 'Restablecer configuración';

  @override
  String get resetSettingsDesc =>
      'Restablecer todas las configuraciones por defecto';

  @override
  String get logOut => 'Cerrar sesión';

  @override
  String get tapToChangePhoto => 'Toca para cambiar la foto';

  @override
  String get photoLibrary => 'Biblioteca de fotos';

  @override
  String get camera => 'Cámara';

  @override
  String get removePhoto => 'Quitar foto';

  @override
  String get nameCannotBeEmpty => 'El nombre no puede estar vacío';

  @override
  String get emailCannotBeEmpty => 'El email no puede estar vacío';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado exitosamente';

  @override
  String get pleaseEnterYourEmail =>
      'Por favor ingresa tu email o nombre de usuario';

  @override
  String get pleaseEnterYourPassword => 'Por favor ingresa tu contraseña';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get welcomeMessage =>
      '¡Hola! Soy tu asistente IA. ¿Cómo puedo ayudarte hoy?';

  @override
  String get aiResponseError =>
      'Lo siento, encontré un error. Por favor inténtalo de nuevo.';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get useBiometricLogin => 'Usar inicio de sesión biométrico';

  @override
  String get authenticating => 'Autenticando...';

  @override
  String get completePurchase => 'Completar Compra';

  @override
  String get selectedPlan => 'Plan Seleccionado';

  @override
  String get featuresIncluded => 'Funciones incluidas:';

  @override
  String get paymentInformation => 'Información de Pago';

  @override
  String payAmount(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get processing => 'Procesando...';

  @override
  String get secureAndEncrypted =>
      'Su información de pago es segura y está encriptada. Nunca almacenamos los detalles de su tarjeta.';

  @override
  String get pleaseFillAllFields =>
      'Por favor complete todos los campos de la tarjeta de crédito';

  @override
  String successfullyUpgraded(String planName) {
    return '¡Actualización exitosa al plan $planName!';
  }

  @override
  String paymentFailed(String error) {
    return 'Pago fallido: $error';
  }

  @override
  String get pleaseInputValidCvv => 'Por favor ingrese un CVV válido';

  @override
  String get pleaseInputValidDate => 'Por favor ingrese una fecha válida';

  @override
  String get pleaseInputValidNumber => 'Por favor ingrese un número válido';

  @override
  String get currentPlan => 'Plan Actual';

  @override
  String get choosePlan => 'Elegir Plan';

  @override
  String planExpires(String date) {
    return 'Expira: $date';
  }

  @override
  String get changePlan => 'Cambiar Plan';

  @override
  String get noProfileData => 'No hay datos de perfil disponibles';

  @override
  String get helpAndSupportTitle => 'Ayuda y Soporte';

  @override
  String get helpAndSupportContent =>
      'Para soporte, por favor contáctanos en:\nsupport@ensolutions.ca\n\nO visita nuestro centro de ayuda en línea.';

  @override
  String get aboutTitle => 'Acerca de TGM HydroAI';

  @override
  String get aboutContent =>
      'TGM HydroAI Chat App v1.0.0\n\nUna aplicación de chat inteligente impulsada por tecnología IA avanzada.\n\n© 2024 TGM AI. Todos los derechos reservados.';

  @override
  String get ok => 'OK';

  @override
  String get logoutConfirmation =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String planName(String plan) {
    return 'Plan $plan';
  }

  @override
  String get contactUs => 'Contáctanos';

  @override
  String get enterpriseContact => 'Contacto Empresarial';

  @override
  String get enterpriseSolutions => 'Soluciones Empresariales';

  @override
  String get enterpriseDescription =>
      'Obtén soluciones personalizadas para las necesidades de tu empresa. Nuestro equipo te contactará dentro de 24 horas para discutir tus requerimientos.';

  @override
  String get contactInformation => 'Información de Contacto';

  @override
  String get companyName => 'Nombre de la Empresa';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get emailAddress => 'Dirección de Email';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get message => 'Mensaje';

  @override
  String get sendMessage => 'Enviar Mensaje';

  @override
  String get sending => 'Enviando...';

  @override
  String get alternativeContactMethods => 'Métodos de Contacto Alternativos';

  @override
  String get businessHours => 'Horario de atención';

  @override
  String get businessHoursValue => 'Lun - Vie: 9:00 AM - 6:00 PM EST';

  @override
  String get enterpriseEmail => 'hello@ensolutions.ca';

  @override
  String get enterprisePhone => '+1 (514) 501-9202';

  @override
  String get messageMinLength =>
      'Por favor proporciona más detalles (mínimo 20 caracteres)';

  @override
  String get enterCompanyName => 'Ingresa el nombre de tu empresa';

  @override
  String get enterFullName => 'Ingresa tu nombre completo';

  @override
  String get enterEmailAddress => 'Ingresa tu dirección de email';

  @override
  String get enterPhoneNumber => 'Ingresa tu número de teléfono';

  @override
  String get enterMessage =>
      'Cuéntanos sobre las necesidades y requerimientos de tu empresa...';

  @override
  String get pleaseEnterCompanyName =>
      'Por favor ingresa el nombre de tu empresa';

  @override
  String get pleaseEnterFullName => 'Por favor ingresa tu nombre completo';

  @override
  String get pleaseEnterEmailAddress =>
      'Por favor ingresa tu dirección de email';

  @override
  String get pleaseEnterPhoneNumber =>
      'Por favor ingresa tu número de teléfono';

  @override
  String get pleaseEnterMessage => 'Por favor ingresa tu mensaje';

  @override
  String get pleaseEnterValidEmail =>
      'Por favor ingresa una dirección de email válida';

  @override
  String get messageSentSuccessfully =>
      '¡Gracias! Tu mensaje ha sido enviado exitosamente. Nuestro equipo empresarial te contactará dentro de 24 horas.';

  @override
  String messageSendError(String error) {
    return 'Error enviando mensaje: $error';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get currentPlanTitle => 'Plan Actual';

  @override
  String get choosePreferredSignInMethod =>
      'Elige tu método de inicio de sesión preferido';

  @override
  String get enterYourUsername => 'Ingresa tu nombre de usuario';

  @override
  String get pleaseEnterYourUsername =>
      'Por favor ingresa tu nombre de usuario';

  @override
  String get enterYourPassword => 'Ingresa tu contraseña';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithFacebook => 'Continuar con Facebook';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String loginFailed(String error) {
    return 'Error en el inicio de sesión: $error';
  }

  @override
  String successfullyLoggedInWith(String provider) {
    return 'Inicio de sesión exitoso con $provider';
  }

  @override
  String biometricAuthenticationFailed(String error) {
    return 'Falló la autenticación biométrica: $error';
  }

  @override
  String get pleaseAuthenticateToLogin =>
      'Por favor autentícate para iniciar sesión en TGM HydroAI Chat';

  @override
  String get businessHoursText => 'Lun - Vie: 9:00 AM - 6:00 PM PST';

  @override
  String get pleaseProvideMoreDetails =>
      'Por favor proporciona más detalles (mínimo 20 caracteres)';

  @override
  String get chooseYourPlan => 'Elige tu plan';

  @override
  String get unlockThePowerOfAI => 'Desbloquea el poder de la IA';

  @override
  String get choosePerfectPlan =>
      'Elige el plan perfecto para mejorar tu productividad\ncon nuestro asistente de IA avanzado';

  @override
  String get freePlan => 'Gratis';

  @override
  String get proPlan => 'Pro';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get enterprisePlan => 'Empresarial';

  @override
  String get contactUsForPricing => 'Contáctanos';

  @override
  String get messagesPerDay => '10 mensajes por día';

  @override
  String get basicAIResponses => 'Respuestas de IA básicas';

  @override
  String get standardSupport => 'Soporte estándar';

  @override
  String get unlimitedMessages => 'Mensajes ilimitados';

  @override
  String get advancedAIFeatures => 'Funciones de IA avanzadas';

  @override
  String get priorityResponses => 'Respuestas prioritarias';

  @override
  String get fileAttachments => 'Archivos adjuntos';

  @override
  String get messageHistory => 'Historial de mensajes';

  @override
  String get everythingInPro => 'Todo de Pro';

  @override
  String get premiumAIModel => 'Modelo de IA premium';

  @override
  String get voiceMessages => 'Mensajes de voz';

  @override
  String get prioritySupport => 'Soporte prioritario';

  @override
  String get customThemes => 'Temas personalizados';

  @override
  String get exportConversations => 'Exportar conversaciones';

  @override
  String get everythingInPremium => 'Todo de Premium';

  @override
  String get customAITraining => 'Entrenamiento de IA personalizado';

  @override
  String get teamCollaboration => 'Colaboración en equipo';

  @override
  String get adminDashboard => 'Panel de administración';

  @override
  String get customBranding => 'Marca personalizada';

  @override
  String get dedicatedSupport => 'Soporte dedicado';

  @override
  String get secureAndReliable => 'Seguro y confiable';

  @override
  String get enterpriseGradeSecurity =>
      'Todos los planes incluyen seguridad de nivel empresarial,\ndisponibilidad 24/7 y garantía de devolución de dinero.';

  @override
  String get secure => 'Seguro';

  @override
  String get fast => 'Rápido';

  @override
  String get support247 => 'Soporte 24/7';

  @override
  String get conversationHistory => 'Historial de conversaciones';

  @override
  String get noConversationsInHistory =>
      'No hay conversaciones en el historial';

  @override
  String get newConversation => 'Nueva conversación';

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
    return '$days days ago';
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
}
