import 'package:flutter/foundation.dart';
import 'package:tgm_ai_chat/features/plans/models/plan_model.dart';
import 'package:tgm_ai_chat/core/services/plans_service.dart';

enum PlansLoadingState {
  initial,
  loading,
  loaded,
  error,
  refreshing
}

class PlansProvider extends ChangeNotifier {
  final PlansService _plansService = PlansService();

  // État des données
  List<Plan> _plans = [];
  PlansLoadingState _loadingState = PlansLoadingState.initial;
  String? _errorMessage;
  bool _isYearlyBilling = false;

  // Getters
  List<Plan> get plans => _plans;
  PlansLoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _loadingState == PlansLoadingState.loading;
  bool get isRefreshing => _loadingState == PlansLoadingState.refreshing;
  bool get hasError => _loadingState == PlansLoadingState.error;
  bool get hasPlans => _plans.isNotEmpty;
  bool get isYearlyBilling => _isYearlyBilling;

  // Getters pour des plans spécifiques
  Plan? get freePlan => _plans.where((plan) => plan.isFree).firstOrNull;
  List<Plan> get paidPlans => _plans.where((plan) => !plan.isFree).toList();
  Plan? get enterprisePlan => _plans.where((plan) => plan.isEnterprise).firstOrNull;
  List<Plan> get regularPlans => _plans.where((plan) => !plan.isFree && !plan.isEnterprise).toList();

  /// Charge tous les plans depuis PocketBase
  Future<void> loadPlans({bool forceRefresh = false}) async {
    try {
      if (forceRefresh && _loadingState == PlansLoadingState.loaded) {
        _loadingState = PlansLoadingState.refreshing;
      } else {
        _loadingState = PlansLoadingState.loading;
      }
      _errorMessage = null;
      notifyListeners();

      final plans = await _plansService.getAllPlans(forceRefresh: forceRefresh);
      
      _plans = plans;
      _loadingState = PlansLoadingState.loaded;
      _errorMessage = null;
    } catch (e) {
      _loadingState = PlansLoadingState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }

  /// Rafraîchit les plans
  Future<void> refreshPlans() async {
    await loadPlans(forceRefresh: true);
  }

  /// Trouve un plan par son ID
  Plan? getPlanById(String planId) {
    try {
      return _plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  /// Trouve un plan par son nom
  Plan? getPlanByName(String planName) {
    try {
      return _plans.firstWhere(
        (plan) => plan.name.toLowerCase() == planName.toLowerCase()
      );
    } catch (e) {
      return null;
    }
  }

  /// Toggle entre facturation mensuelle et annuelle
  void toggleBillingPeriod() {
    _isYearlyBilling = !_isYearlyBilling;
    notifyListeners();
  }

  /// Définit le type de facturation
  void setBillingPeriod({required bool isYearly}) {
    if (_isYearlyBilling != isYearly) {
      _isYearlyBilling = isYearly;
      notifyListeners();
    }
  }

  /// Obtient le prix formatté d'un plan selon la période de facturation
  String getPlanPrice(Plan plan) {
    return plan.getPriceFormatted(isYearly: _isYearlyBilling);
  }

  /// Obtient la période de facturation pour l'affichage
  String getBillingPeriodText() {
    return _isYearlyBilling ? '/year' : '/month';
  }

  /// Vérifie si un plan est recommandé
  bool isPlanRecommended(Plan plan) {
    return plan.name.toLowerCase().contains('premium') ||
           plan.name.toLowerCase().contains('pro');
  }

  /// Obtient l'économie annuelle d'un plan
  String getYearlyDiscount(Plan plan) {
    if (!_isYearlyBilling || plan.yearlyDiscount <= 0) return '';
    
    final discountPercentage = plan.yearlyDiscountPercentage.round();
    return 'Save $discountPercentage%';
  }

  /// Trie les plans par prix
  List<Plan> getSortedPlans({bool ascending = true}) {
    final sortedPlans = List<Plan>.from(_plans);
    
    sortedPlans.sort((a, b) {
      final priceA = _isYearlyBilling ? a.yearlyPrice : a.monthlyPrice;
      final priceB = _isYearlyBilling ? b.yearlyPrice : b.monthlyPrice;
      
      return ascending ? priceA.compareTo(priceB) : priceB.compareTo(priceA);
    });
    
    return sortedPlans;
  }

  /// Recharge les plans si nécessaire
  Future<void> ensurePlansLoaded() async {
    if (_loadingState == PlansLoadingState.initial || _plans.isEmpty) {
      await loadPlans();
    }
  }

  /// Nettoie les données et remet à l'état initial
  void reset() {
    _plans = [];
    _loadingState = PlansLoadingState.initial;
    _errorMessage = null;
    _isYearlyBilling = false;
    notifyListeners();
  }
}