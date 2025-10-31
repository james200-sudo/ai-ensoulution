import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/plan_limits_config.dart';
import 'pocketbase_auth_service.dart';

class PlanEnforcementService {
  final PocketBaseAuthService _authService = PocketBaseAuthService();
  
  // Accesseur (Getter) pour l'instance PocketBase
  PocketBase get _pb => _authService.pocketBase;
  
  static const String _messageCountKey = 'current_month_messages';
  static const String _quotaResetDateKey = 'quota_reset_date';
  static const String _lastSyncKey = 'last_sync_timestamp';
  UserPlanInfo? _cachedPlanInfo;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);
  /// Vérifie si l'utilisateur peut envoyer un message
  /// IMPORTANT: Ne s'applique QU'AUX utilisateurs individuels (PocketBase)
  Future<PlanCheckResult> canSendMessage(String userId) async {
    try {
      // 🔹 VÉRIFICATION CRITIQUE #1: Utilisateur non connecté à PocketBase = Company User
      if (!_authService.isLoggedIn) {
        debugPrint('✅ Utilisateur non connecté à PocketBase - accès autorisé (Company user via Strapi)');
        return PlanCheckResult.allowed();
      }
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint('✅ Pas de données utilisateur PocketBase - accès autorisé (Company user)');
        return PlanCheckResult.allowed();
      }
      
      // 🔹 VÉRIFICATION CRITIQUE #2: Récupérer le plan de l'utilisateur
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      // Si pas de plan = utilisateur d'entreprise
      if (planId == null) {
        debugPrint('✅ Utilisateur sans plan (Entreprise) - accès illimité');
        return PlanCheckResult.allowed();
      }
      
      // 🎯 CORRECTION CRITIQUE #3: Vérifier si c'est un plan Company ou Hydropower
      // Ces plans doivent TOUJOURS avoir un accès illimité
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        debugPrint('✅ Plan Company/Hydropower détecté - accès illimité garanti');
        return PlanCheckResult.allowed();
      }
      
      // À partir d'ici, c'est un utilisateur individuel avec un plan Free ou Individual
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) {
        debugPrint('⚠️ Configuration de plan invalide pour $planId');
        return PlanCheckResult.denied('Configuration de plan invalide');
      }
      
      // Vérifier le statut d'abonnement (sauf plan Gratuit)
      final subscriptionStatus = user.data['subscriptionStatus'] as String?;
      if (subscriptionStatus != 'active' && planId != PlanLimitsConfig.PLAN_FREE) {
        return PlanCheckResult.denied(
          'Votre abonnement n\'est pas actif. Veuillez le renouveler pour continuer.',
          requiresUpgrade: true,
        );
      }
      
      // Vérifier la période d'essai pour le plan Gratuit
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final created = DateTime.parse(user.data['created'] as String);
        final trialEnd = created.add(Duration(days: limits.trialDurationDays));
        
        if (DateTime.now().isAfter(trialEnd)) {
          return PlanCheckResult.denied(
            'Votre essai gratuit a expiré. Veuillez passer à un plan supérieur pour continuer à utiliser TGM HydroAI.',
            requiresUpgrade: true,
          );
        }
      }
      
      // Si plan illimité (Individual), autoriser
      if (limits.isUnlimited) {
        debugPrint('✅ Plan illimité (Individual) - accès autorisé');
        return PlanCheckResult.allowed();
      }
      
      // Vérifier le quota de messages pour le plan Free
      final messageCount = await _getCurrentMonthMessageCount(userId);
      
      if (messageCount >= limits.messageQuotaPerMonth) {
        return PlanCheckResult.denied(
          'Vous avez atteint votre limite mensuelle de messages (${limits.messageQuotaPerMonth} messages). '
          'Passez au plan Individuel pour des messages illimités.',
          requiresUpgrade: true,
          remainingQuota: 0,
        );
      }
      
      debugPrint('✅ Messages restants: ${limits.messageQuotaPerMonth - messageCount}');
      return PlanCheckResult.allowed(
        remainingQuota: limits.messageQuotaPerMonth - messageCount,
      );
      
    } catch (e) {
      debugPrint('❌ Erreur vérification permissions: $e');
      // En cas d'erreur, autoriser l'accès (fail-safe pour Company users)
      return PlanCheckResult.allowed();
    }
  }
  
  /// Vérifie si l'utilisateur peut uploader une image
  Future<PlanCheckResult> canUploadImage(String userId, int fileSizeBytes) async {
    try {
      // 🔹 Vérifier si c'est un utilisateur PocketBase
      if (!_authService.isLoggedIn) {
        return PlanCheckResult.allowed();
      }
      
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      // Utilisateurs sans plan (Entreprise) = accès illimité
      if (planId == null) {
        return PlanCheckResult.allowed();
      }
      
      // 🎯 CORRECTION: Plans Company/Hydropower = accès illimité
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        debugPrint('✅ Plan Company/Hydropower - upload images autorisé');
        return PlanCheckResult.allowed();
      }
      
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) {
        return PlanCheckResult.denied('Plan invalide');
      }
      
      if (!limits.canUploadImages) {
        return PlanCheckResult.denied(
          'Le téléchargement d\'images n\'est pas disponible dans votre plan. Passez à un plan supérieur pour accéder à cette fonctionnalité.',
          requiresUpgrade: true,
        );
      }
      
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      if (fileSizeMB > limits.maxFileSize) {
        return PlanCheckResult.denied(
          'La taille du fichier (${fileSizeMB.toStringAsFixed(2)}MB) dépasse la limite de votre plan (${limits.maxFileSize}MB).',
        );
      }
      
      return PlanCheckResult.allowed();
      
    } catch (e) {
      debugPrint('❌ Erreur vérification image: $e');
      return PlanCheckResult.allowed(); // Fail-safe
    }
  }
  
  /// Vérifie si l'utilisateur peut utiliser les messages vocaux
  Future<PlanCheckResult> canUseVoiceMessages(String userId) async {
    return _checkFeature(userId, 'voice_messages');
  }
  
  Future<PlanCheckResult> _checkFeature(String userId, String featureName) async {
    try {
      if (!_authService.isLoggedIn) {
        return PlanCheckResult.allowed();
      }
      
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      if (planId == null) {
        return PlanCheckResult.allowed();
      }
      
      // 🎯 CORRECTION: Plans Company/Hydropower = toutes les features
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        debugPrint('✅ Plan Company/Hydropower - feature $featureName autorisée');
        return PlanCheckResult.allowed();
      }
      
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) {
        return PlanCheckResult.denied('Plan invalide');
      }
      
      if (limits.hasFeature(featureName)) {
        return PlanCheckResult.allowed();
      } else {
        return PlanCheckResult.denied(
          limits.getLimitationMessage(featureName),
          requiresUpgrade: true,
        );
      }
      
    } catch (e) {
      debugPrint('❌ Erreur vérification feature $featureName: $e');
      return PlanCheckResult.allowed();
    }
  }
  
  /// ✅ CORRECTION CRITIQUE: Compte correctement les messages depuis PocketBase
  Future<int> _getCurrentMonthMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier la date de reset AVANT de lire le compteur
      final resetDateStr = prefs.getString('${_quotaResetDateKey}_$userId');
      
      if (resetDateStr != null) {
        final resetDate = DateTime.parse(resetDateStr);
        if (DateTime.now().isAfter(resetDate)) {
          await _resetMonthlyQuota(userId);
          return 0;
        }
      } else {
        // Première utilisation : définir la date de reset
        await _setNextResetDate(userId);
      }
      
      // ✅ Vérifier si une synchronisation est nécessaire (toutes les 5 minutes)
      final lastSyncStr = prefs.getString('${_lastSyncKey}_$userId');
      final shouldSync = lastSyncStr == null || 
          DateTime.now().difference(DateTime.parse(lastSyncStr)).inMinutes > 5;
      
      if (shouldSync) {
        // Synchroniser avec PocketBase
        return await _syncMessageCountFromPocketBase(userId);
      }
      
      // Utiliser le compteur local mis en cache
      final localCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
      return localCount;
      
    } catch (e) {
      debugPrint('❌ Erreur lecture compteur: $e');
      return 0;
    }
  }
  
  /// ✅ NOUVEAU: Synchronise le compteur depuis PocketBase
  Future<int> _syncMessageCountFromPocketBase(String userId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      
      // ✅ CORRECTION CRITIQUE: Requête correcte
      // On compte les messages dans TOUTES les conversations de l'utilisateur
      
      // OPTION 1: Si les messages ont une relation directe avec l'utilisateur
      // final messages = await _pb.collection('messages').getList(
      //   filter: 'user.id = "$userId" && created >= "${firstDayOfMonth.toIso8601String()}" && isUser = true',
      //   perPage: 1,
      // );
      
      // OPTION 2 (RECOMMANDÉE): Compter via les conversations
      // Récupérer toutes les conversations de l'utilisateur ce mois
      final discussions = await _pb.collection('discussions').getList(
          filter: 'user = "$userId" && created >= "${firstDayOfMonth.toIso8601String()}"',
          perPage: 500,
        );

        int totalUserMessages = 0;

        for (final discussion in discussions.items) {
          final messagesResult = await _pb.collection('messages').getList(
            filter: 'discussion = "${discussion.id}" && is_user = true && created >= "${firstDayOfMonth.toIso8601String()}"',
            perPage: 500,
          );
          totalUserMessages += messagesResult.totalItems;
        }
      
      // ✅ Sauvegarder dans le cache local
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_messageCountKey}_$userId', totalUserMessages);
      await prefs.setString('${_lastSyncKey}_$userId', DateTime.now().toIso8601String());
      
      debugPrint('✅ Compteur synchronisé depuis PocketBase: $totalUserMessages messages utilisateur ce mois');
      return totalUserMessages;
      
    } catch (e) {
      debugPrint('❌ Erreur synchronisation compteur PocketBase: $e');
      
      // Fallback: utiliser le compteur local s'il existe
      try {
        final prefs = await SharedPreferences.getInstance();
        final localCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
        debugPrint('⚠️ Utilisation compteur local (fallback): $localCount');
        return localCount;
      } catch (e2) {
        return 0;
      }
    }
  }
  
  /// ✅ CORRECTION: Incrémente seulement après confirmation de sauvegarde
  Future<void> incrementMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
      await prefs.setInt('${_messageCountKey}_$userId', currentCount + 1);
      debugPrint('📊 Messages envoyés ce mois: ${currentCount + 1}');
    } catch (e) {
      debugPrint('❌ Erreur incrémentation compteur: $e');
    }
  }
  
  Future<void> _resetMonthlyQuota(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_messageCountKey}_$userId', 0);
      await _setNextResetDate(userId);
      await prefs.remove('${_lastSyncKey}_$userId'); // Forcer une resync
      debugPrint('🔄 Quota mensuel réinitialisé');
    } catch (e) {
      debugPrint('❌ Erreur reset quota: $e');
    }
  }
  
  Future<void> _setNextResetDate(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final nextMonth = DateTime(now.year, now.month + 1, 1);
      await prefs.setString('${_quotaResetDateKey}_$userId', nextMonth.toIso8601String());
    } catch (e) {
      debugPrint('❌ Erreur définition date reset: $e');
    }
  }
  
  /// Récupère les informations du plan utilisateur
   Future<UserPlanInfo?> getUserPlanInfo(String userId) async {
    try {
      // 🆕 AJOUTER : Vérifier le cache
      if (_cachedPlanInfo != null && 
          _cacheTimestamp != null && 
          DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
        debugPrint('✅ Utilisation cache plan info');
        return _cachedPlanInfo;
      }
      
      if (!_authService.isLoggedIn) {
        debugPrint('ℹ️ Utilisateur Company - pas de quota à afficher');
        return null;
      }
      
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      if (planId == null) {
        debugPrint('ℹ️ Utilisateur sans plan - pas de quota à afficher');
        return null;
      }
      
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        final limits = PlanLimitsConfig.getLimits(planId);
        if (limits == null) return null;
        
        debugPrint('✅ Utilisateur Company/Hydropower - quota illimité');
        
        // 🆕 AJOUTER : Mettre en cache
        _cachedPlanInfo = UserPlanInfo(
          planId: planId,
          planName: limits.name,
          messageCount: 0,
          messageQuota: -1,
          subscriptionStatus: 'active',
          limits: limits,
        );
        _cacheTimestamp = DateTime.now();
        
        return _cachedPlanInfo;
      }
      
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) return null;
      
      final messageCount = await _getCurrentMonthMessageCount(userId);
      final subscriptionStatus = user.data['subscriptionStatus'] as String?;
      
      // 🆕 AJOUTER : Mettre en cache
      _cachedPlanInfo = UserPlanInfo(
        planId: planId,
        planName: limits.name,
        messageCount: messageCount,
        messageQuota: limits.messageQuotaPerMonth,
        subscriptionStatus: subscriptionStatus ?? 'unknown',
        limits: limits,
      );
      _cacheTimestamp = DateTime.now();
      
      return _cachedPlanInfo;
      
    } catch (e) {
      debugPrint('❌ Erreur récupération info plan: $e');
      
      // 🆕 AJOUTER : Retourner le cache même expiré en cas d'erreur 429
      if (e.toString().contains('429') && _cachedPlanInfo != null) {
        debugPrint('⚠️ Erreur 429 - Utilisation cache expiré');
        return _cachedPlanInfo;
      }
      
      return null;
    }
  }
  void clearCache() {
    _cachedPlanInfo = null;
    _cacheTimestamp = null;
  }
  /// ✅ NOUVEAU: Force une resynchronisation immédiate
  Future<void> forceSyncMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_lastSyncKey}_$userId');
      await _syncMessageCountFromPocketBase(userId);
      debugPrint('✅ Resynchronisation forcée terminée');
    } catch (e) {
      debugPrint('❌ Erreur resynchronisation forcée: $e');
    }
  }
}

class PlanCheckResult {
  final bool isAllowed;
  final String? errorMessage;
  final bool requiresUpgrade;
  final int? remainingQuota;
  
  PlanCheckResult._({
    required this.isAllowed,
    this.errorMessage,
    this.requiresUpgrade = false,
    this.remainingQuota,
  });
  
  factory PlanCheckResult.allowed({int? remainingQuota}) {
    return PlanCheckResult._(
      isAllowed: true,
      remainingQuota: remainingQuota,
    );
  }
  
  factory PlanCheckResult.denied(String message, {bool requiresUpgrade = false, int? remainingQuota}) {
    return PlanCheckResult._(
      isAllowed: false,
      errorMessage: message,
      requiresUpgrade: requiresUpgrade,
      remainingQuota: remainingQuota,
    );
  }
}

class UserPlanInfo {
  final String planId;
  final String planName;
  final int messageCount;
  final int messageQuota;
  final String subscriptionStatus;
  final PlanLimits limits;
  
  UserPlanInfo({
    required this.planId,
    required this.planName,
    required this.messageCount,
    required this.messageQuota,
    required this.subscriptionStatus,
    required this.limits,
  });
  
  bool get isUnlimited => messageQuota == -1;
  bool get hasReachedLimit => !isUnlimited && messageCount >= messageQuota;
  int get remainingMessages => isUnlimited ? -1 : (messageQuota - messageCount).clamp(0, messageQuota);
  double get usagePercentage => isUnlimited ? 0 : (messageCount / messageQuota * 100).clamp(0, 100);
}