// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get companyCode => 'Code entreprise';

  @override
  String get delete => 'Supprimer';

  @override
  String get appTitle => 'TGM HydroAI Chat';

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
  String get rating => 'Évaluation';

  @override
  String get chatHistory => 'Historique de discussion';

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
  String get messageSounds => 'Sons de messages';

  @override
  String get messageSoundsDesc => 'Jouer un son à l\'arrivée des messages';

  @override
  String get chatPreferences => 'Préférences de discussion';

  @override
  String get autoSaveConversations =>
      'Sauvegarde automatique des conversations';

  @override
  String get autoSaveConversationsDesc =>
      'Sauvegarder automatiquement l\'historique des discussions';

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
  String get clearChatHistory => 'Effacer l\'historique des discussions';

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
      'Je suis désolé, j\'ai rencontré une erreur. Veuillez réessayer.';

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
      'Veuillez remplir tous les champs de carte de crédit';

  @override
  String successfullyUpgraded(String planName) {
    return 'Mise à niveau réussie au plan $planName !';
  }

  @override
  String paymentFailed(String error) {
    return 'Échec du paiement : $error';
  }

  @override
  String get pleaseInputValidCvv => 'Veuillez entrer un CVV valide';

  @override
  String get pleaseInputValidDate => 'Veuillez entrer une date valide';

  @override
  String get pleaseInputValidNumber => 'Veuillez entrer un numéro valide';

  @override
  String get currentPlan => 'Plan actuel';

  @override
  String get choosePlan => 'Choisir un plan';

  @override
  String planExpires(String date) {
    return 'Expire le : $date';
  }

  @override
  String get changePlan => 'Changer de plan';

  @override
  String get noProfileData => 'Aucune donnée de profil disponible';

  @override
  String get helpAndSupportTitle => 'Aide et support';

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
  String get contactUs => 'Nous contacter';

  @override
  String get enterpriseContact => 'Contact entreprise';

  @override
  String get enterpriseSolutions => 'Solutions entreprise';

  @override
  String get enterpriseDescription =>
      'Obtenez des solutions personnalisées pour vos besoins d\'entreprise. Notre équipe vous contactera dans les 24 heures pour discuter de vos besoins.';

  @override
  String get contactInformation => 'Informations de contact';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get fullName => 'Nom complet';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get message => 'Message';

  @override
  String get sendMessage => 'Envoyer le message';

  @override
  String get sending => 'Envoi...';

  @override
  String get alternativeContactMethods => 'Méthodes de contact alternatives';

  @override
  String get businessHours => 'Heures d\'ouverture';

  @override
  String get businessHoursValue => 'Lun - Ven : 9h00 - 18h00 HNE';

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
      'Parlez-nous de vos besoins et exigences d\'entreprise...';

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
  String get currentPlanTitle => 'Plan actuel';

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
    return 'Échec de connexion : $error';
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
  String get businessHoursText => 'Lun - Ven : 9h00 - 18h00 HNP';

  @override
  String get pleaseProvideMoreDetails =>
      'Veuillez fournir plus de détails (minimum 20 caractères)';

  @override
  String get chooseYourPlan => 'Choisissez votre plan';

  @override
  String get unlockThePowerOfAI => 'Débloquez la puissance de l\'IA';

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
  String get basicAIResponses => 'Réponses IA de base';

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
  String get everythingInPro => 'Tout dans Pro';

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
  String get everythingInPremium => 'Tout dans Premium';

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
      'Tous les plans incluent une sécurité de niveau entreprise,\nune disponibilité 24/7 et une garantie de remboursement.';

  @override
  String get secure => 'Sécurisé';

  @override
  String get fast => 'Rapide';

  @override
  String get support247 => 'Support 24/7';

  @override
  String get conversationHistory => 'Historique des conversations';

  @override
  String get noConversationsInHistory =>
      'Aucune conversation dans l\'historique';

  @override
  String get newConversation => 'Nouvelle conversation';

  @override
  String get helpAndSupportDesc => 'Obtenir de l\'aide ou contacter le support';

  @override
  String get aboutDesc => 'Version et informations de l\'application';

  @override
  String get fontSizeSmall => 'Petite';

  @override
  String get fontSizeMedium => 'Moyenne';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get fontSizeExtraLarge => 'Très grande';

  @override
  String get privacySettingsContent =>
      'Les paramètres de confidentialité seraient configurés ici, y compris les préférences de collecte de données et les contrôles de confidentialité.';

  @override
  String get fontSizeSample => 'Exemple de texte avec la taille actuelle';

  @override
  String get done => 'Terminé';

  @override
  String get aboutTgmAi => 'À propos de TGM AI';

  @override
  String get clearHistoryDialogContent =>
      'Ceci supprimera définitivement tout votre historique de conversation. Cette action ne peut pas être annulée.\\n\\nÊtes-vous sûr de vouloir continuer ?';

  @override
  String get clear => 'Effacer';

  @override
  String get resetSettingsDialogContent =>
      'Ceci réinitialisera tous les paramètres à leurs valeurs par défaut. Êtes-vous sûr de vouloir continuer ?';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get historyClearedSuccess =>
      'Historique de discussion effacé avec succès';

  @override
  String get historyClearedError =>
      'Échec de l\'effacement de l\'historique de discussion';

  @override
  String get settingsResetSuccess =>
      'Paramètres réinitialisés aux valeurs par défaut';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get newToPlatform => 'Nouveau sur notre plateforme ?';

  @override
  String get createFreeAccount => 'Créer un compte gratuit';

  @override
  String get companyLoginSuccess => 'Connexion entreprise réussie';

  @override
  String get jwtNotFound => 'JWT non trouvé dans la réponse';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get googleLoginSuccess => 'Connexion Google réussie';

  @override
  String get googleLoginError => 'Erreur Google';

  @override
  String googleError(String error) {
    return 'Erreur Google : $error';
  }

  @override
  String biometricAuthFailed(String error) {
    return 'Échec de l\'authentification biométrique : $error';
  }

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinOurCommunity => 'Rejoignez notre communauté';

  @override
  String get pleaseEnterYourName => 'Veuillez entrer votre nom';

  @override
  String get nameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get passwordMinLength8 =>
      'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get passwordComplexity =>
      'Le mot de passe doit contenir une majuscule, une minuscule et un chiffre';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get acceptTerms =>
      'J\'accepte les conditions d\'utilisation et la politique de confidentialité';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ? ';

  @override
  String get mustAcceptTerms =>
      'Vous devez accepter les conditions d\'utilisation';

  @override
  String get registrationSuccess => 'Inscription réussie';

  @override
  String get accountCreatedEmailError =>
      'Compte créé mais il y a eu un problème lors de l\'envoi de l\'email';

  @override
  String get registrationError => 'Erreur d\'inscription';

  @override
  String errorWithMessage(String error) {
    return 'Erreur : $error';
  }

  @override
  String get accountCreatedSuccess => 'Compte créé avec succès';

  @override
  String get googleAuthError => 'Erreur lors de l\'authentification Google';

  @override
  String unexpectedError(String error) {
    return 'Erreur inattendue : $error';
  }

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get resetYourPassword => 'Réinitialiser votre mot de passe';

  @override
  String get resetPasswordInstructions =>
      'Entrez votre adresse email et nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get emailSent => 'Email envoyé !';

  @override
  String get weSentAnEmailTo => 'Nous avons envoyé un email à :';

  @override
  String get howToResetPassword => 'Comment réinitialiser votre mot de passe';

  @override
  String get howToResetPasswordInstructions =>
      '1. Ouvrez votre boîte mail\n2. Cliquez sur le lien dans l\'email\n3. Vous serez redirigé vers une page web\n4. Entrez votre nouveau mot de passe\n5. Revenez à l\'application pour vous connecter';

  @override
  String get checkSpam => '📬 Vérifiez vos spams si vous ne voyez pas l\'email';

  @override
  String get resendEmail => 'Renvoyer l\'email';

  @override
  String get sendingInProgress => 'Envoi...';

  @override
  String get emailSentMessage => 'Email envoyé';

  @override
  String get emailNotFound => 'Adresse email non trouvée';

  @override
  String get sendingError => 'Erreur lors de l\'envoi';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès';

  @override
  String get passwordResetError =>
      'Erreur lors de la réinitialisation du mot de passe';

  @override
  String get returnToLogin => 'Retour à la connexion';

  @override
  String get verifyEmail => 'Vérifier l\'email';

  @override
  String get verificationEmailSent => 'Email de vérification envoyé !';

  @override
  String get instructions => 'Instructions';

  @override
  String get openMailbox => 'Ouvrez votre boîte mail';

  @override
  String get findVerificationEmail => 'Trouvez l\'email de vérification';

  @override
  String get clickVerifyButton => 'Cliquez sur le bouton \"Vérifier\"';

  @override
  String get accountActivated => 'Votre compte sera activé automatiquement !';

  @override
  String get emailResent => 'Email renvoyé';

  @override
  String get emailCannotBeChanged => 'L\'email ne peut pas être modifié';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Échec de la mise à jour du profil : $error';
  }

  @override
  String expires(Object date) {
    return 'Expire le : $date';
  }

  @override
  String failedToPickImage(Object error) {
    return 'Échec de la sélection de l\'image : $error';
  }

  @override
  String get plansAndProfileRefreshed =>
      'Plans et profil actualisés avec succès';

  @override
  String failedToRefresh(Object error) {
    return 'Échec de l\'actualisation : $error';
  }

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get loadingPlans => 'Chargement des plans...';

  @override
  String get failedToLoadPlans => 'Échec du chargement des plans';

  @override
  String get retry => 'Réessayer';

  @override
  String get noPlansAvailable => 'Aucun plan disponible';

  @override
  String get securePaymentWithStripe => 'Paiement sécurisé avec Stripe';

  @override
  String get redirectToStripe =>
      'Vous serez redirigé vers la page de paiement sécurisée de Stripe pour finaliser votre achat.';

  @override
  String get sslEncryption => 'Cryptage SSL 256 bits';

  @override
  String get allCreditCardsAccepted =>
      'Toutes les cartes de crédit principales acceptées';

  @override
  String get pciDssCompliant => 'Conforme PCI DSS';

  @override
  String get dataNeverStored => 'Vos données ne sont jamais stockées';

  @override
  String continueToPayment(Object price) {
    return 'Continuer vers le paiement - $price';
  }

  @override
  String get secureAndEncryptedPayment => 'Paiement sécurisé et crypté';

  @override
  String get paymentInfoProtected =>
      'Les informations de paiement sont protégées par un cryptage bancaire. Nous ne stockons jamais les détails de votre carte.';

  @override
  String get poweredByStripe => 'Propulsé par Stripe';

  @override
  String get sessionExpired => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get mustBeLoggedIn =>
      'Vous devez être connecté pour effectuer un paiement.';

  @override
  String get invalidAmount => 'Montant invalide';

  @override
  String get redirectingToPayment =>
      'Redirection vers la page de paiement sécurisée...';

  @override
  String get paymentCancelled => 'Paiement annulé';

  @override
  String get paymentInitializationFailed =>
      'Échec de l\'initialisation du paiement';

  @override
  String get connectionProblem =>
      'Problème de connexion. Vérifiez votre internet.';

  @override
  String get serverNotResponding =>
      'Le serveur ne répond pas. Veuillez réessayer plus tard.';

  @override
  String get verifyingPayment => 'Vérification de votre paiement...';

  @override
  String get pleaseWait => 'Veuillez patienter un moment';

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String get subscriptionActivated =>
      'Votre abonnement a été activé avec succès. Vous avez maintenant accès à toutes les fonctionnalités premium !';

  @override
  String get plan => 'Plan';

  @override
  String get status => 'Statut';

  @override
  String get active => 'Actif';

  @override
  String get session => 'Session';

  @override
  String get startChatting => 'Commencer à discuter';

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get verificationProblem => 'Problème de vérification';

  @override
  String get verificationFailed =>
      'Impossible de vérifier votre paiement. Veuillez contacter le support si le problème persiste.';

  @override
  String get retryVerification => 'Réessayer la vérification';

  @override
  String get continueInApp => 'Continuer dans l\'application';

  @override
  String get paymentCancelledTitle => 'Paiement annulé';

  @override
  String get paymentCancelledMessage =>
      'Votre paiement a été annulé. Aucun débit n\'a été effectué sur votre compte.';

  @override
  String get noPaymentProcessed => 'Aucun paiement n\'a été traité';

  @override
  String get accountUnchanged => 'Votre compte reste inchangé';

  @override
  String get youCanRetry => 'Vous pouvez réessayer à tout moment';

  @override
  String get retryPayment => 'Réessayer le paiement';

  @override
  String get returnToApp => 'Retour à l\'application';

  @override
  String get needHelpContactSupport => 'Besoin d\'aide ? Contactez le support';

  @override
  String get viewFullHistory => 'Voir l\'historique complet';

  @override
  String get whatCanIHelpYouWith => 'Comment puis-je vous aider aujourd\'hui ?';

  @override
  String get gallery => 'Galerie';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(Object days) {
    return 'Il y a $days jours';
  }

  @override
  String get recording => 'Enregistrement';

  @override
  String get failedToSaveRecording => 'Échec de l\'enregistrement vocal';

  @override
  String recordingError(Object error) {
    return 'Erreur d\'enregistrement : $error';
  }

  @override
  String get permissionDenied => 'Permission d\'enregistrement requise';

  @override
  String get permissionDeniedMessage =>
      'L\'enregistrement vocal nécessite l\'autorisation du microphone. Veuillez l\'activer dans les paramètres de votre appareil pour enregistrer des messages vocaux.';

  @override
  String get startChattingToSeeHistory =>
      'Commencez à discuter pour voir votre historique de conversation ici';

  @override
  String messagesCount(Object count) {
    return '$count messages';
  }

  @override
  String get current => 'Actuelle';

  @override
  String get switchToConversation => 'Basculer vers cette conversation';

  @override
  String get deleteConversation => 'Supprimer la conversation';

  @override
  String get justNow => 'À l\'instant';

  @override
  String minutesAgo(Object minutes) {
    return 'Il y a ${minutes}m';
  }

  @override
  String hoursAgo(Object hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String get deleteConversationConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette conversation ?';

  @override
  String get thisActionCannotBeUndone =>
      'Cette action ne peut pas être annulée.';

  @override
  String get conversationDeleted => 'Conversation supprimée';

  @override
  String planInterest(Object planName) {
    return 'Je suis intéressé par le plan $planName. Veuillez me contacter avec plus d\'informations sur les prix et les fonctionnalités.';
  }

  @override
  String failedToSend(Object error) {
    return 'Échec de l\'envoi du message : $error';
  }

  @override
  String get welcomeTo => 'Bienvenue chez TGM HydroAI';

  @override
  String get chooseAccountType =>
      'Choisissez votre type de compte pour commencer';

  @override
  String get individual => 'Individuel';

  @override
  String get personalUse => 'Usage personnel avec connexion sociale';

  @override
  String get company => 'Entreprise';

  @override
  String get businessAccount => 'Compte d\'entreprise avec code entreprise';

  @override
  String get companyCodeRequired => 'Le code entreprise est requis';

  @override
  String get companyCodeLength =>
      'Le code entreprise doit contenir exactement 6 caractères';

  @override
  String get invalidCompanyCode =>
      'Seules les lettres majuscules et les chiffres sont autorisés';

  @override
  String get companyCodeHint => 'Entrez le code à 6 chiffres';

  @override
  String get companyCodeDescription =>
      '6 caractères alphanumériques en majuscules (A-Z, 0-9)';

  @override
  String get continueButton => 'Continuer';

  @override
  String get logoFallback => 'TGM\nAI';

  @override
  String get changeLanguage => 'Changer de langue';
}
