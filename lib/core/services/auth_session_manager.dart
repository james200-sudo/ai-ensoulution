// lib/core/services/auth_session_manager.dart
import 'dart:async';
import 'dart:convert'; // Pour base64, utf8, json
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_auth_service.dart';
import 'pocketbase_instance.dart';
import '../../features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class AuthSessionManager {
  static final AuthSessionManager _instance = AuthSessionManager._internal();
  factory AuthSessionManager() => _instance;
  AuthSessionManager._internal();

  Timer? _tokenCheckTimer;
  final PocketBaseAuthService _authService = PocketBaseAuthService();
  final PocketBase _pb = PocketBaseInstance.instance;
  
  // Stockage des dernières infos de connexion pour pré-remplissage
  String? _lastEmail;
  String? _lastUserType; // 'individual' ou 'company'
  
  /// Démarre la vérification périodique du token
  void startTokenMonitoring() {
    stopTokenMonitoring();
    
    // Vérifier toutes les 30 secondes
    _tokenCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkTokenValidity(),
    );
    
    // Vérification immédiate
    _checkTokenValidity();
  }
  
  /// Arrête la vérification périodique
  void stopTokenMonitoring() {
    _tokenCheckTimer?.cancel();
    _tokenCheckTimer = null;
  }
  
  /// Vérifie la validité du token et déclenche le logout si expiré
  Future<void> _checkTokenValidity() async {
    try {
      // Vérifier si le token est valide
      if (!_pb.authStore.isValid) {
        debugPrint('🔴 Token invalide ou expiré - Déconnexion automatique');
        await _handleTokenExpiration();
        return;
      }
      
      // Essayer de rafraîchir le token s'il est proche de l'expiration
      final token = _pb.authStore.token;
      if (token != null && _isTokenNearExpiration(token)) {
        debugPrint('🟡 Token proche de l\'expiration - Tentative de rafraîchissement');
        
        try {
          await _pb.collection('users').authRefresh();
          debugPrint('✅ Token rafraîchi avec succès');
        } catch (e) {
          debugPrint('❌ Échec du rafraîchissement du token');
          await _handleTokenExpiration();
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du token: $e');
      await _handleTokenExpiration();
    }
  }
  
  /// Vérifie si le token est proche de l'expiration (moins de 5 minutes)
  bool _isTokenNearExpiration(String token) {
    try {
      // Décoder le JWT pour obtenir l'expiration
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      // Décoder le payload (partie du milieu)
      final payload = parts[1];
      // Ajouter le padding nécessaire pour base64
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);
      
      final exp = data['exp'] as int?;
      if (exp == null) return true;
      
      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final difference = expDate.difference(now);
      
      // Si moins de 5 minutes avant expiration
      return difference.inMinutes < 5;
    } catch (e) {
      debugPrint('Erreur décodage JWT: $e');
      return true; // En cas d'erreur, considérer comme proche de l'expiration
    }
  }
  
  /// Gère l'expiration du token
  Future<void> _handleTokenExpiration() async {
    // Sauvegarder l'email pour pré-remplissage
    await _saveLastCredentials();
    
    // Nettoyer toutes les données locales
    await _clearAllLocalData();
    
    // Déconnecter
    await _authService.logout();
    
    // Naviguer vers la page de login
    _navigateToLogin();
  }
  
  /// Sauvegarde les dernières infos de connexion
  Future<void> _saveLastCredentials() async {
    try {
      final record = _pb.authStore.record;
      if (record != null) {
        final prefs = await SharedPreferences.getInstance();
        
        // Accéder aux données correctement selon le type RecordModel
        final email = record.getStringValue('email');
        final planId = record.getStringValue('plan');
        
        _lastEmail = email;
        _lastUserType = _determineUserType(planId);
        
        // Sauvegarder pour le pré-remplissage
        if (_lastEmail != null && _lastEmail!.isNotEmpty) {
          await prefs.setString('last_email', _lastEmail!);
        }
        if (_lastUserType != null && _lastUserType!.isNotEmpty) {
          await prefs.setString('last_user_type', _lastUserType!);
        }
      }
    } catch (e) {
      debugPrint('Erreur sauvegarde credentials: $e');
    }
  }
  
  /// Détermine le type d'utilisateur basé sur le plan
  String _determineUserType(String? planId) {
    // Company plans
    const companyPlans = ['hnahry5t5ardea3', '7iw3959pf0rbo7m'];
    
    if (planId != null && companyPlans.contains(planId)) {
      return 'company';
    }
    return 'individual';
  }
  
  /// Nettoie toutes les données locales
  Future<void> _clearAllLocalData() async {
    try {
      debugPrint('🧹 Nettoyage de toutes les données locales...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Sauvegarder temporairement les infos de pré-remplissage
      final savedEmail = prefs.getString('last_email');
      final savedUserType = prefs.getString('last_user_type');
      
      // Nettoyer tout
      await prefs.clear();
      
      // Restaurer les infos de pré-remplissage
      if (savedEmail != null) {
        await prefs.setString('last_email', savedEmail);
      }
      if (savedUserType != null) {
        await prefs.setString('last_user_type', savedUserType);
      }
      
      debugPrint('✅ Données locales nettoyées');
    } catch (e) {
      debugPrint('❌ Erreur nettoyage données: $e');
    }
  }
  
  /// Navigate vers la page de login
  void _navigateToLogin() {
    try {
      // Obtenir le contexte global de navigation
      final context = navigatorKey.currentContext;
      if (context != null) {
        // Nettoyer le provider de chat si disponible
        try {
          final chatProvider = context.read<ChatProvider>();
          chatProvider.clearAllLocalData(); 
        } catch (e) {
          debugPrint('Provider non disponible: $e');
        }
        
        // Naviguer vers login en supprimant toute la pile
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
        
        // Afficher un message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Votre session a expiré. Veuillez vous reconnecter.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur navigation: $e');
    }
  }
  
  /// Vérifie le token avant chaque action importante
  Future<bool> validateTokenBeforeAction() async {
    try {
      // Vérifier si connecté
      if (!_pb.authStore.isValid) {
        debugPrint('❌ Utilisateur non connecté');
        await _handleTokenExpiration();
        return false;
      }
      
      // Vérifier si le token est expiré
      final token = _pb.authStore.token;
      if (token == null || _isTokenExpired(token)) {
        debugPrint('❌ Token expiré');
        await _handleTokenExpiration();
        return false;
      }
      
      // Essayer de rafraîchir si proche de l'expiration
      if (_isTokenNearExpiration(token)) {
        try {
          await _pb.collection('users').authRefresh();
          debugPrint('✅ Token rafraîchi avant action');
        } catch (e) {
          debugPrint('❌ Impossible de rafraîchir le token');
          await _handleTokenExpiration();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ Erreur validation token: $e');
      await _handleTokenExpiration();
      return false;
    }
  }
  
  /// Vérifie si le token est complètement expiré
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = json.decode(decoded);
      
      final exp = data['exp'] as int?;
      if (exp == null) return true;
      
      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      return now.isAfter(expDate);
    } catch (e) {
      return true;
    }
  }
  
  /// Récupère les infos de pré-remplissage
  Future<Map<String, String>> getLastCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('last_email') ?? '',
      'userType': prefs.getString('last_user_type') ?? 'individual',
    };
  }
  
  /// Nettoie les infos de pré-remplissage
  Future<void> clearLastCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_email');
    await prefs.remove('last_user_type');
  }
  
  void dispose() {
    stopTokenMonitoring();
  }
}

// Clé globale pour la navigation - À METTRE DANS MAIN.DART
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();