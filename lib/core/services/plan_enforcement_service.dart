import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/plan_limits_config.dart';
import 'pocketbase_auth_service.dart';

class PlanEnforcementService {
  final PocketBaseAuthService _authService = PocketBaseAuthService();
  
  PocketBase get _pb => _authService.pocketBase;
  
  static const String _messageCountKey = 'current_month_messages';
  static const String _quotaResetDateKey = 'quota_reset_date';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _planModeCacheKey = 'plan_mode_cache';
  static const String _planModeCacheTimeKey = 'plan_mode_cache_time';
  
  UserPlanInfo? _cachedPlanInfo;
  DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // 🆕 Cache pour planMode
  String? _cachedPlanMode;
  DateTime? _planModeCacheTime;
  static const Duration _planModeCacheDuration = Duration(minutes: 10);
  
  /// 🆕 Récupère le planMode depuis app_config
  Future<String> _getPlanMode() async {
    try {
      // Vérifier le cache
      if (_cachedPlanMode != null && 
          _planModeCacheTime != null && 
          DateTime.now().difference(_planModeCacheTime!) < _planModeCacheDuration) {
        return _cachedPlanMode!;
      }
      
      // Récupérer depuis SharedPreferences si disponible
      final prefs = await SharedPreferences.getInstance();
      final cachedMode = prefs.getString(_planModeCacheKey);
      final cachedTimeStr = prefs.getString(_planModeCacheTimeKey);
      
      if (cachedMode != null && cachedTimeStr != null) {
        final cachedTime = DateTime.parse(cachedTimeStr);
        if (DateTime.now().difference(cachedTime) < _planModeCacheDuration) {
          _cachedPlanMode = cachedMode;
          _planModeCacheTime = cachedTime;
          return cachedMode;
        }
      }
      
      // Récupérer depuis PocketBase
      final result = await _pb.collection('app_config').getList(
        perPage: 1,
        sort: '-created',
      );
      
      if (result.items.isEmpty) {
        debugPrint('⚠️ Aucune config trouvée - Mode payant par défaut');
        return 'payant';
      }
      
      final planMode = result.items.first.data['planMode'] as String? ?? 'payant';
      
      // Mettre en cache
      _cachedPlanMode = planMode;
      _planModeCacheTime = DateTime.now();
      await prefs.setString(_planModeCacheKey, planMode);
      await prefs.setString(_planModeCacheTimeKey, DateTime.now().toIso8601String());
      
      debugPrint('✅ PlanMode récupéré: $planMode');
      return planMode;
      
    } catch (e) {
      debugPrint('❌ Erreur récupération planMode: $e');
      return 'payant'; // Par défaut en cas d'erreur
    }
  }
  
  /// Vérifie si l'utilisateur peut envoyer un message
  Future<PlanCheckResult> canSendMessage(String userId) async {
    try {
      // 🔹 Utilisateurs non connectés = Company User
      if (!_authService.isLoggedIn) {
        debugPrint('✅ Utilisateur Company - accès autorisé');
        return PlanCheckResult.allowed();
      }
      
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint('✅ Pas de données utilisateur - accès autorisé (Company)');
        return PlanCheckResult.allowed();
      }
      
      // 🔹 Récupérer le plan de l'utilisateur
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      if (planId == null) {
        debugPrint('✅ Utilisateur sans plan (Entreprise) - accès illimité');
        return PlanCheckResult.allowed();
      }
      
      // 🔹 Plans Company/Hydropower = toujours illimités
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        debugPrint('✅ Plan Company/Hydropower - accès illimité');
        return PlanCheckResult.allowed();
      }
      
      // 🆕 CORRECTION PRINCIPALE : Vérifier le planMode pour le plan Free
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final planMode = await _getPlanMode();
        
        if (planMode == 'free') {
          debugPrint('✅ Mode Free actif - Plan Free illimité');
          return PlanCheckResult.allowed();
        }
        
        debugPrint('ℹ️ Mode payant actif - Limitations du plan Free appliquées');
      }
      
      // À partir d'ici : utilisateurs individuels avec limitations
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) {
        debugPrint('⚠️ Configuration de plan invalide pour $planId');
        return PlanCheckResult.denied('Configuration de plan invalide');
      }
      
      // Vérifier le statut d'abonnement (sauf plan Gratuit)
      final subscriptionStatus = user.data['subscriptionStatus'] as String?;
      if (subscriptionStatus != 'active' && planId != PlanLimitsConfig.PLAN_FREE) {
        return PlanCheckResult.denied(
          'Votre abonnement n\'est pas actif. Veuillez le renouveler.',
          requiresUpgrade: true,
        );
      }
      
      // Vérifier la période d'essai pour le plan Gratuit
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final created = DateTime.parse(user.data['created'] as String);
        final trialEnd = created.add(Duration(days: limits.trialDurationDays));
        
        if (DateTime.now().isAfter(trialEnd)) {
          return PlanCheckResult.denied(
            'Votre essai gratuit a expiré. Passez à un plan supérieur.',
            requiresUpgrade: true,
          );
        }
      }
      
      // Si plan illimité (Individual)
      if (limits.isUnlimited) {
        debugPrint('✅ Plan Individual illimité - accès autorisé');
        return PlanCheckResult.allowed();
      }
      
      // Vérifier le quota de messages pour le plan Free
      final messageCount = await _getCurrentMonthMessageCount(userId);
      
      if (messageCount >= limits.messageQuotaPerMonth) {
        return PlanCheckResult.denied(
          'Limite mensuelle atteinte (${limits.messageQuotaPerMonth} messages). Passez au plan Individuel.',
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
      return PlanCheckResult.allowed(); // Fail-safe
    }
  }
  
  /// Vérifie si l'utilisateur peut uploader une image
  Future<PlanCheckResult> canUploadImage(String userId, int fileSizeBytes) async {
    try {
      if (!_authService.isLoggedIn) {
        return PlanCheckResult.allowed();
      }
      
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      if (planId == null) {
        return PlanCheckResult.allowed();
      }
      
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        return PlanCheckResult.allowed();
      }
      
      // 🆕 Si mode free, autoriser pour plan Free
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final planMode = await _getPlanMode();
        if (planMode == 'free') {
          debugPrint('✅ Mode Free - Upload images autorisé');
          return PlanCheckResult.allowed();
        }
      }
      
      final limits = PlanLimitsConfig.getLimits(planId);
      if (limits == null) {
        return PlanCheckResult.denied('Plan invalide');
      }
      
      if (!limits.canUploadImages) {
        return PlanCheckResult.denied(
          'Téléchargement d\'images non disponible. Passez à un plan supérieur.',
          requiresUpgrade: true,
        );
      }
      
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      if (fileSizeMB > limits.maxFileSize) {
        return PlanCheckResult.denied(
          'Fichier trop volumineux (${fileSizeMB.toStringAsFixed(2)}MB). Limite: ${limits.maxFileSize}MB.',
        );
      }
      
      return PlanCheckResult.allowed();
      
    } catch (e) {
      debugPrint('❌ Erreur vérification image: $e');
      return PlanCheckResult.allowed();
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
      
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        return PlanCheckResult.allowed();
      }
      
      // 🆕 Si mode free, autoriser toutes les features pour plan Free
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final planMode = await _getPlanMode();
        if (planMode == 'free') {
          debugPrint('✅ Mode Free - Feature $featureName autorisée');
          return PlanCheckResult.allowed();
        }
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
      debugPrint('❌ Erreur vérification feature: $e');
      return PlanCheckResult.allowed();
    }
  }
  
  Future<int> _getCurrentMonthMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final resetDateStr = prefs.getString('${_quotaResetDateKey}_$userId');
      
      if (resetDateStr != null) {
        final resetDate = DateTime.parse(resetDateStr);
        if (DateTime.now().isAfter(resetDate)) {
          await _resetMonthlyQuota(userId);
          return 0;
        }
      } else {
        await _setNextResetDate(userId);
      }
      
      final lastSyncStr = prefs.getString('${_lastSyncKey}_$userId');
      final now = DateTime.now();
      
      if (lastSyncStr != null) {
        final lastSync = DateTime.parse(lastSyncStr);
        final timeSinceSync = now.difference(lastSync);
        
        if (timeSinceSync.inMinutes < 5) {
          final localCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
          return localCount;
        }
      }
      
      return await _syncMessageCountFromPocketBase(userId);
      
    } catch (e) {
      debugPrint('❌ Erreur compteur messages: $e');
      return 0;
    }
  }
  
  Future<int> _syncMessageCountFromPocketBase(String userId) async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      
      final discussions = await _pb.collection('discussions').getList(
        filter: 'user = "$userId"',
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
    
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_messageCountKey}_$userId', totalUserMessages);
      await prefs.setString('${_lastSyncKey}_$userId', DateTime.now().toIso8601String());
      
      debugPrint('✅ Compteur synchronisé: $totalUserMessages messages');
      return totalUserMessages;
      
    } catch (e) {
      debugPrint('❌ Erreur synchronisation compteur: $e');
      
      try {
        final prefs = await SharedPreferences.getInstance();
        final localCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
        return localCount;
      } catch (e2) {
        return 0;
      }
    }
  }
  
  Future<void> incrementMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('${_messageCountKey}_$userId') ?? 0;
      await prefs.setInt('${_messageCountKey}_$userId', currentCount + 1);
      debugPrint('📊 Messages ce mois: ${currentCount + 1}');
    } catch (e) {
      debugPrint('❌ Erreur incrémentation: $e');
    }
  }
  
  Future<void> _resetMonthlyQuota(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${_messageCountKey}_$userId', 0);
      await _setNextResetDate(userId);
      await prefs.remove('${_lastSyncKey}_$userId');
      debugPrint('🔄 Quota réinitialisé');
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
      debugPrint('❌ Erreur date reset: $e');
    }
  }
  
  Future<UserPlanInfo?> getUserPlanInfo(String userId) async {
    try {
      if (_cachedPlanInfo != null && 
          _cacheTimestamp != null && 
          DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
        return _cachedPlanInfo;
      }
      
      if (!_authService.isLoggedIn) {
        return null;
      }
      
      final user = await _pb.collection('users').getOne(userId);
      final planId = user.data['plan'] as String?;
      
      if (planId == null) {
        return null;
      }
      
      if (planId == PlanLimitsConfig.PLAN_COMPANY || 
          planId == PlanLimitsConfig.PLAN_HYDROPOWER) {
        final limits = PlanLimitsConfig.getLimits(planId);
        if (limits == null) return null;
        
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
      
      // 🆕 Si plan Free en mode free, afficher comme illimité
      if (planId == PlanLimitsConfig.PLAN_FREE) {
        final planMode = await _getPlanMode();
        if (planMode == 'free') {
          _cachedPlanInfo = UserPlanInfo(
            planId: planId,
            planName: 'Free Illimité', // Affichage clair
            messageCount: 0,
            messageQuota: -1,
            subscriptionStatus: 'active',
            limits: limits,
          );
          _cacheTimestamp = DateTime.now();
          return _cachedPlanInfo;
        }
      }
      
      final messageCount = await _getCurrentMonthMessageCount(userId);
      final subscriptionStatus = user.data['subscriptionStatus'] as String?;
      
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
      debugPrint('❌ Erreur info plan: $e');
      
      if (e.toString().contains('429') && _cachedPlanInfo != null) {
        return _cachedPlanInfo;
      }
      
      return null;
    }
  }
  
  void clearCache() {
    _cachedPlanInfo = null;
    _cacheTimestamp = null;
    _cachedPlanMode = null;
    _planModeCacheTime = null;
  }
  
  Future<void> forceSyncMessageCount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_lastSyncKey}_$userId');
      await _syncMessageCountFromPocketBase(userId);
      debugPrint('✅ Resynchronisation forcée OK');
    } catch (e) {
      debugPrint('❌ Erreur resync: $e');
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