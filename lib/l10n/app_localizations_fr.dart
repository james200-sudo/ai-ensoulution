// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TGM IA Chat';

  @override
  String get appTagline => 'Assistant de Chat Intelligent';

  @override
  String get loading => 'Chargement...';

  @override
  String get signIn => 'Se connecter';

  @override
  String get emailOrUsername => 'Email ou nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String continueWith(String provider) {
    return 'Continuer avec $provider';
  }

  @override
  String get or => 'ou';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get typeYourMessage => 'Tapez votre message...';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get name => 'Nom';

  @override
  String get email => 'Email';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get messages => 'Messages';

  @override
  String get daysActive => 'Jours actifs';

  @override
  String get rating => 'Note';

  @override
  String get chatHistory => 'Historique des conversations';

  @override
  String get preferences => 'Préférences';

  @override
  String get helpAndSupport => 'Aide et support';

  @override
  String get about => 'À propos';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications push';

  @override
  String get pushNotificationsDesc =>
      'Recevoir des notifications pour les nouveaux messages';

  @override
  String get messageSounds => 'Sons des messages';

  @override
  String get messageSoundsDesc => 'Jouer un son à l\'arrivée des messages';

  @override
  String get chatPreferences => 'Préférences de chat';

  @override
  String get autoSaveConversations =>
      'Sauvegarde automatique des conversations';

  @override
  String get autoSaveConversationsDesc =>
      'Sauvegarder automatiquement l\'historique des conversations';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get darkModeDesc => 'Utiliser le thème sombre pour l\'application';

  @override
  String get security => 'Sécurité';

  @override
  String get biometricAuth => 'Authentification biométrique';

  @override
  String get biometricAuthDesc =>
      'Utiliser l\'empreinte digitale ou Face ID pour déverrouiller';

  @override
  String get account => 'Compte';

  @override
  String get privacySettings => 'Paramètres de confidentialité';

  @override
  String get privacySettingsDesc => 'Gérer vos préférences de confidentialité';

  @override
  String get language => 'Langue';

  @override
  String get fontSize => 'Taille de police';

  @override
  String get dataAndStorage => 'Données et stockage';

  @override
  String get clearChatHistory => 'Effacer l\'historique des conversations';

  @override
  String get clearChatHistoryDesc =>
      'Supprimer tout l\'historique des conversations';

  @override
  String get resetSettings => 'Réinitialiser les paramètres';

  @override
  String get resetSettingsDesc =>
      'Réinitialiser tous les paramètres par défaut';

  @override
  String get logOut => 'Se déconnecter';

  @override
  String get tapToChangePhoto => 'Appuyez pour changer la photo';

  @override
  String get photoLibrary => 'Bibliothèque de photos';

  @override
  String get camera => 'Appareil photo';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get nameCannotBeEmpty => 'Le nom ne peut pas être vide';

  @override
  String get emailCannotBeEmpty => 'L\'email ne peut pas être vide';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get pleaseEnterYourEmail =>
      'Veuillez entrer votre email ou nom d\'utilisateur';

  @override
  String get pleaseEnterYourPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordMustBeAtLeast6Characters =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get welcomeMessage =>
      'Bonjour ! Je suis votre assistant IA. Comment puis-je vous aider aujourd\'hui ?';

  @override
  String get aiResponseError =>
      'Désolé, j\'ai rencontré une erreur. Veuillez réessayer.';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageSpanish => 'Español';

  @override
  String get useBiometricLogin => 'Utiliser la connexion biométrique';

  @override
  String get authenticating => 'Authentification...';

  @override
  String get completePurchase => 'Finaliser l\'achat';

  @override
  String get selectedPlan => 'Plan sélectionné';

  @override
  String get featuresIncluded => 'Fonctionnalités incluses :';

  @override
  String get paymentInformation => 'Informations de paiement';

  @override
  String payAmount(String amount) {
    return 'Payer $amount';
  }

  @override
  String get processing => 'Traitement...';

  @override
  String get secureAndEncrypted =>
      'Vos informations de paiement sont sécurisées et cryptées. Nous ne stockons jamais les détails de votre carte.';

  @override
  String get pleaseFillAllFields =>
      'Veuillez remplir tous les champs de la carte de crédit';

  @override
  String successfullyUpgraded(String planName) {
    return 'Mise à niveau réussie vers le plan $planName !';
  }

  @override
  String paymentFailed(String error) {
    return 'Échec du paiement : $error';
  }

  @override
  String get pleaseInputValidCvv => 'Veuillez saisir un CVV valide';

  @override
  String get pleaseInputValidDate => 'Veuillez saisir une date valide';

  @override
  String get pleaseInputValidNumber => 'Veuillez saisir un numéro valide';

  @override
  String get currentPlan => 'Plan Actuel';

  @override
  String get choosePlan => 'Choisir le Plan';

  @override
  String planExpires(String date) {
    return 'Expire le : $date';
  }

  @override
  String get changePlan => 'Changer de Plan';

  @override
  String get noProfileData => 'Aucune donnée de profil disponible';

  @override
  String get helpAndSupportTitle => 'Aide et Support';

  @override
  String get helpAndSupportContent =>
      'Pour obtenir de l\'aide, veuillez nous contacter à :\nsupport@ensolutions.ca\n\nOu visitez notre centre d\'aide en ligne.';

  @override
  String get aboutTitle => 'À propos de TGM HydroAI';

  @override
  String get aboutContent =>
      'TGM HydroAI Chat App v1.0.0\n\nUne application de chat intelligente alimentée par une technologie IA avancée.\n\n© 2024 TGM AI. Tous droits réservés.';

  @override
  String get ok => 'OK';

  @override
  String get logoutConfirmation =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String planName(String plan) {
    return 'Plan $plan';
  }

  @override
  String get contactUs => 'Nous Contacter';

  @override
  String get enterpriseContact => 'Contact Entreprise';

  @override
  String get enterpriseSolutions => 'Solutions Entreprise';

  @override
  String get enterpriseDescription =>
      'Obtenez des solutions personnalisées pour les besoins de votre entreprise. Notre équipe vous contactera dans les 24 heures pour discuter de vos exigences.';

  @override
  String get contactInformation => 'Informations de Contact';

  @override
  String get companyName => 'Nom de l\'Entreprise';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get emailAddress => 'Adresse Email';

  @override
  String get phoneNumber => 'Numéro de Téléphone';

  @override
  String get message => 'Message';

  @override
  String get sendMessage => 'Envoyer le Message';

  @override
  String get sending => 'Envoi...';

  @override
  String get alternativeContactMethods => 'Méthodes de Contact Alternatives';

  @override
  String get businessHours => 'Heures d\'ouverture';

  @override
  String get businessHoursValue => 'Lun - Ven: 9:00 AM - 6:00 PM EST';

  @override
  String get enterpriseEmail => 'hello@ensolutions.ca';

  @override
  String get enterprisePhone => '+1 (514) 501-9202';

  @override
  String get messageMinLength =>
      'Veuillez fournir plus de détails (minimum 20 caractères)';

  @override
  String get enterCompanyName => 'Entrez le nom de votre entreprise';

  @override
  String get enterFullName => 'Entrez votre nom complet';

  @override
  String get enterEmailAddress => 'Entrez votre adresse email';

  @override
  String get enterPhoneNumber => 'Entrez votre numéro de téléphone';

  @override
  String get enterMessage =>
      'Parlez-nous des besoins et exigences de votre entreprise...';

  @override
  String get pleaseEnterCompanyName =>
      'Veuillez entrer le nom de votre entreprise';

  @override
  String get pleaseEnterFullName => 'Veuillez entrer votre nom complet';

  @override
  String get pleaseEnterEmailAddress => 'Veuillez entrer votre adresse email';

  @override
  String get pleaseEnterPhoneNumber =>
      'Veuillez entrer votre numéro de téléphone';

  @override
  String get pleaseEnterMessage => 'Veuillez entrer votre message';

  @override
  String get pleaseEnterValidEmail =>
      'Veuillez entrer une adresse email valide';

  @override
  String get messageSentSuccessfully =>
      'Merci ! Votre message a été envoyé avec succès. Notre équipe entreprise vous contactera dans les 24 heures.';

  @override
  String messageSendError(String error) {
    return 'Erreur lors de l\'envoi du message : $error';
  }

  @override
  String get close => 'Fermer';

  @override
  String get currentPlanTitle => 'Plan Actuel';

  @override
  String get choosePreferredSignInMethod =>
      'Choisissez votre méthode de connexion préférée';

  @override
  String get enterYourUsername => 'Entrez votre nom d\'utilisateur';

  @override
  String get pleaseEnterYourUsername =>
      'Veuillez entrer votre nom d\'utilisateur';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithFacebook => 'Continuer avec Facebook';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String loginFailed(String error) {
    return 'Échec de la connexion : $error';
  }

  @override
  String successfullyLoggedInWith(String provider) {
    return 'Connexion réussie avec $provider';
  }

  @override
  String biometricAuthenticationFailed(String error) {
    return 'Échec de l\'authentification biométrique : $error';
  }

  @override
  String get pleaseAuthenticateToLogin =>
      'Veuillez vous authentifier pour vous connecter à TGM HydroAI Chat';

  @override
  String get businessHoursText => 'Lun - Ven: 9h00 - 18h00 PST';

  @override
  String get pleaseProvideMoreDetails =>
      'Veuillez fournir plus de détails (minimum 20 caractères)';

  @override
  String get chooseYourPlan => 'Choisissez votre plan';

  @override
  String get unlockThePowerOfAI => 'Libérez la puissance de l\'IA';

  @override
  String get choosePerfectPlan =>
      'Choisissez le plan parfait pour améliorer votre productivité\navec notre assistant IA avancé';

  @override
  String get freePlan => 'Gratuit';

  @override
  String get proPlan => 'Pro';

  @override
  String get premiumPlan => 'Premium';

  @override
  String get enterprisePlan => 'Entreprise';

  @override
  String get contactUsForPricing => 'Nous contacter';

  @override
  String get messagesPerDay => '10 messages par jour';

  @override
  String get basicAIResponses => 'Réponses IA basiques';

  @override
  String get standardSupport => 'Support standard';

  @override
  String get unlimitedMessages => 'Messages illimités';

  @override
  String get advancedAIFeatures => 'Fonctionnalités IA avancées';

  @override
  String get priorityResponses => 'Réponses prioritaires';

  @override
  String get fileAttachments => 'Pièces jointes';

  @override
  String get messageHistory => 'Historique des messages';

  @override
  String get everythingInPro => 'Tout de Pro';

  @override
  String get premiumAIModel => 'Modèle IA premium';

  @override
  String get voiceMessages => 'Messages vocaux';

  @override
  String get prioritySupport => 'Support prioritaire';

  @override
  String get customThemes => 'Thèmes personnalisés';

  @override
  String get exportConversations => 'Exporter les conversations';

  @override
  String get everythingInPremium => 'Tout de Premium';

  @override
  String get customAITraining => 'Formation IA personnalisée';

  @override
  String get teamCollaboration => 'Collaboration d\'équipe';

  @override
  String get adminDashboard => 'Tableau de bord admin';

  @override
  String get customBranding => 'Marque personnalisée';

  @override
  String get dedicatedSupport => 'Support dédié';

  @override
  String get secureAndReliable => 'Sécurisé et fiable';

  @override
  String get enterpriseGradeSecurity =>
      'Tous les plans incluent une sécurité de niveau entreprise,\nune disponibilité 24h/24 et 7j/7, et une garantie de remboursement.';

  @override
  String get secure => 'Sécurisé';

  @override
  String get fast => 'Rapide';

  @override
  String get support247 => 'Support 24h/24 et 7j/7';

  @override
  String get conversationHistory => 'Historique des conversations';

  @override
  String get noConversationsInHistory =>
      'Aucune conversation dans l\'historique';

  @override
  String get newConversation => 'Nouvelle conversation';
}
