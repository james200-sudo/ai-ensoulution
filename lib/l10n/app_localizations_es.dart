// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
}
