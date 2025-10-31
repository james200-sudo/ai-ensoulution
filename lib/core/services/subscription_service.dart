import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../features/plans/models/plan_model.dart';

class SubscriptionService extends ChangeNotifier {
  static const String _subscriptionKey = 'user_subscription';
  
  String _currentPlan = 'Free';
  DateTime? _planExpiryDate;
  
  String get currentPlan => _currentPlan;
  DateTime? get planExpiryDate => _planExpiryDate;
  
  bool get isPlanActive {
    if (_planExpiryDate == null) return _currentPlan == 'Free';
    return DateTime.now().isBefore(_planExpiryDate!);
  }
  
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal() {
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString(_subscriptionKey);
      
      if (subscriptionJson != null) {
        final data = json.decode(subscriptionJson) as Map<String, dynamic>;
        _currentPlan = data['currentPlan'] ?? 'Free';
        _planExpiryDate = data['planExpiryDate'] != null
            ? DateTime.parse(data['planExpiryDate'])
            : null;
            
        // Check if plan has expired
        if (!isPlanActive && _currentPlan != 'Free') {
          await _downgradeToPlan('Free');
        }
      }
    } catch (e) {
      //debugPrint('Error loading subscription: $e');
      _currentPlan = 'Free';
      _planExpiryDate = null;
    }
    notifyListeners();
  }

  Future<void> _saveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionData = {
        'currentPlan': _currentPlan,
        'planExpiryDate': _planExpiryDate?.toIso8601String(),
      };
      await prefs.setString(_subscriptionKey, json.encode(subscriptionData));
    } catch (e) {
      //debugPrint('Error saving subscription: $e');
    }
  }

  Future<bool> upgradeToPlan(Plan plan) async {
    try {
      _currentPlan = plan.name;
      
      // Set expiry date based on plan (30 days for paid plans)
      if (plan.name != 'Free') {
        _planExpiryDate = DateTime.now().add(const Duration(days: 30));
      } else {
        _planExpiryDate = null;
      }
      
      await _saveSubscription();
      notifyListeners();
      return true;
    } catch (e) {
      //debugPrint('Error upgrading to plan: $e');
      return false;
    }
  }

  Future<bool> _downgradeToPlan(String planName) async {
    try {
      _currentPlan = planName;
      if (planName == 'Free') {
        _planExpiryDate = null;
      }
      await _saveSubscription();
      notifyListeners();
      return true;
    } catch (e) {
      //debugPrint('Error downgrading plan: $e');
      return false;
    }
  }

  Future<void> cancelSubscription() async {
    await _downgradeToPlan('Free');
  }

  Map<String, dynamic> getSubscriptionData() {
    return {
      'currentPlan': _currentPlan,
      'planExpiryDate': _planExpiryDate?.toIso8601String(),
      'isActive': isPlanActive,
    };
  }

  // Check if user has access to a feature based on their plan
  bool hasFeatureAccess(String feature) {
    switch (feature) {
      case 'unlimited_messages':
        return _currentPlan != 'Free' && isPlanActive;
      case 'priority_support':
        return (_currentPlan == 'Premium' || _currentPlan == 'Enterprise') && isPlanActive;
      case 'custom_branding':
        return _currentPlan == 'Enterprise' && isPlanActive;
      default:
        return true; // Basic features available to all
    }
  }

  // Get message limit based on plan
  int get dailyMessageLimit {
    if (!isPlanActive || _currentPlan == 'Free') return 10;
    return -1; // Unlimited for paid plans
  }
}