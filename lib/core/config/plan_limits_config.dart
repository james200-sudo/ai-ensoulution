import 'package:flutter/foundation.dart';

/// Configuration centralisée des limitations par plan
class PlanLimitsConfig {
  // IDs des plans (EXACTEMENT comme dans PocketBase)
  static const String PLAN_FREE = 'xkdv2sqngtpnqjp';
  static const String PLAN_INDIVIDUAL = 'iox7db52ee17vnf';
  static const String PLAN_COMPANY = 'hnahry5t5ardea3';
  static const String PLAN_HYDROPOWER = '7iw3959pf0rbo7m';
  
  // Limitations par plan
  static final Map<String, PlanLimits> limits = {
    PLAN_FREE: PlanLimits(
      name: 'Free',
      messageQuotaPerMonth: 100,
      maxConversations: 10,
      canUploadImages: true,
      canUseVoice: true,
      hasAdvancedAnalytics: false,
      hasMultiUser: false,
      hasPrioritySupport: false,
      canExportData: false,
      maxFileSize: 5,
      trialDurationDays: 7,
    ),
    
    PLAN_INDIVIDUAL: PlanLimits(
      name: 'Individual',
      messageQuotaPerMonth: -1,
      maxConversations: -1,
      canUploadImages: true,
      canUseVoice: true,
      hasAdvancedAnalytics: false,
      hasMultiUser: false,
      hasPrioritySupport: false,
      canExportData: true,
      maxFileSize: 10,
      trialDurationDays: 0,
    ),
    
    PLAN_COMPANY: PlanLimits(
      name: 'Company',
      messageQuotaPerMonth: -1,
      maxConversations: -1,
      canUploadImages: true,
      canUseVoice: true,
      hasAdvancedAnalytics: true,
      hasMultiUser: true,
      hasPrioritySupport: true,
      canExportData: true,
      maxFileSize: 25,
      trialDurationDays: 0,
      hasSharedKnowledgeBase: true,
    ),
    
    PLAN_HYDROPOWER: PlanLimits(
      name: 'Hydropower Utilities',
      messageQuotaPerMonth: -1,
      maxConversations: -1,
      canUploadImages: true,
      canUseVoice: true,
      hasAdvancedAnalytics: true,
      hasMultiUser: true,
      hasPrioritySupport: true,
      canExportData: true,
      maxFileSize: 50,
      trialDurationDays: 0,
      hasSharedKnowledgeBase: true,
      hasERPIntegration: true,
      hasAssetManagement: true,
    ),
  };
  
  static PlanLimits? getLimits(String planId) {
    return limits[planId];
  }
  
  static bool hasExceededQuota(String planId, int currentMessageCount) {
    final planLimits = getLimits(planId);
    if (planLimits == null) return true;
    
    if (planLimits.messageQuotaPerMonth == -1) return false;
    
    return currentMessageCount >= planLimits.messageQuotaPerMonth;
  }
}

class PlanLimits {
  final String name;
  final int messageQuotaPerMonth;
  final int maxConversations;
  final bool canUploadImages;
  final bool canUseVoice;
  final bool hasAdvancedAnalytics;
  final bool hasMultiUser;
  final bool hasPrioritySupport;
  final bool canExportData;
  final int maxFileSize;
  final int trialDurationDays;
  final bool hasSharedKnowledgeBase;
  final bool hasERPIntegration;
  final bool hasAssetManagement;
  
  const PlanLimits({
    required this.name,
    required this.messageQuotaPerMonth,
    required this.maxConversations,
    required this.canUploadImages,
    required this.canUseVoice,
    required this.hasAdvancedAnalytics,
    required this.hasMultiUser,
    required this.hasPrioritySupport,
    required this.canExportData,
    required this.maxFileSize,
    required this.trialDurationDays,
    this.hasSharedKnowledgeBase = false,
    this.hasERPIntegration = false,
    this.hasAssetManagement = false,
  });
  
  bool hasFeature(String featureName) {
    switch (featureName) {
      case 'upload_images':
        return canUploadImages;
      case 'voice_messages':
        return canUseVoice;
      case 'advanced_analytics':
        return hasAdvancedAnalytics;
      case 'multi_user':
        return hasMultiUser;
      case 'priority_support':
        return hasPrioritySupport;
      case 'export_data':
        return canExportData;
      case 'shared_knowledge':
        return hasSharedKnowledgeBase;
      case 'erp_integration':
        return hasERPIntegration;
      case 'asset_management':
        return hasAssetManagement;
      default:
        return false;
    }
  }
  
  String getLimitationMessage(String featureName) {
    return 'This feature is not available in your $name plan. Please upgrade to access it.';
  }
}

extension PlanLimitsHelper on PlanLimits {
  bool get isUnlimited => messageQuotaPerMonth == -1;
  bool get isTrialPlan => trialDurationDays > 0;
}