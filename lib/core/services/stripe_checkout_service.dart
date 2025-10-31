import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class StripeCheckoutResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? sessionId;
  final String? errorMessage;

  StripeCheckoutResult({
    required this.isSuccess,
    required this.isCancelled,
    this.sessionId,
    this.errorMessage,
  });

  factory StripeCheckoutResult.success({required String sessionId}) {
    return StripeCheckoutResult(
      isSuccess: true,
      isCancelled: false,
      sessionId: sessionId,
    );
  }

  factory StripeCheckoutResult.cancelled() {
    return StripeCheckoutResult(
      isSuccess: false,
      isCancelled: true,
      errorMessage: 'Payment cancelled by user',
    );
  }

  factory StripeCheckoutResult.error(String message) {
    return StripeCheckoutResult(
      isSuccess: false,
      isCancelled: false,
      errorMessage: message,
    );
  }
}

class StripeCheckoutService {
  // URL de votre backend Laravel sur Hostinger
  static const String _baseUrl = 'https://darkturquoise-stork-328739.hostingersite.com';
  
  // Endpoints API
  static const String _checkoutEndpoint = '/api/stripe/create-checkout';
  static const String _verifyEndpoint = '/api/stripe/verify-session';
  static const String _subscriptionStatusEndpoint = '/api/stripe/subscription-status';
  static const String _cancelSubscriptionEndpoint = '/api/stripe/cancel-subscription';
  
  // Deep links pour le retour après paiement
  static const String _successUrl = 'hydroaichat://payment/success';
  static const String _cancelUrl = 'hydroaichat://payment/cancel';

  /// Créer et rediriger vers Stripe Checkout
  Future<StripeCheckoutResult> redirectToCheckout({
    required double amount,
    required String currency,
    required String planId,
    required String planName,
    required bool isYearly,
    required String pocketbaseToken,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      //debugPrint('=== STRIPE CHECKOUT START ===');
      //debugPrint('Backend URL: $_baseUrl$_checkoutEndpoint');
      //debugPrint('Amount: \$${amount.toStringAsFixed(2)} $currency');
      //debugPrint('Plan: $planName ($planId)');
      //debugPrint('Period: ${isYearly ? "Yearly" : "Monthly"}');
      
      // Décoder le token pour debug (optionnel)
      _debugToken(pocketbaseToken);

      // Validation
      if (pocketbaseToken.isEmpty) {
        throw Exception('PocketBase token is required');
      }

      if (amount <= 0) {
        throw Exception('Invalid amount');
      }

      // Préparer la requête
      final requestBody = {
        'amount': amount,
        'currency': currency.toLowerCase(),
        'plan_id': planId,
        'plan_name': planName,
        'is_yearly': isYearly,
        'success_url': _successUrl,
        'cancel_url': _cancelUrl,
        'metadata': metadata ?? {},
      };

      //debugPrint('Request body: ${json.encode(requestBody)}');

      // Appel API
      final response = await http.post(
        Uri.parse('$_baseUrl$_checkoutEndpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $pocketbaseToken',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Server not responding');
        },
      );

      //debugPrint('Response status: ${response.statusCode}');
      //debugPrint('Response body: ${response.body}');

      // Traiter la réponse
      return await _handleCheckoutResponse(response);

    } on http.ClientException catch (e) {
      //debugPrint('❌ Network error: $e');
      return StripeCheckoutResult.error(
        'Network error. Please check your internet connection.',
      );
    } catch (e) {
      //debugPrint('❌ Checkout error: $e');
      return StripeCheckoutResult.error(_formatErrorMessage(e.toString()));
    }
  }

  /// Gérer la réponse du checkout
  Future<StripeCheckoutResult> _handleCheckoutResponse(http.Response response) async {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final checkoutUrl = data['url'] as String?;
      final sessionId = data['sessionId'] as String?;

      if (checkoutUrl == null || sessionId == null) {
        throw Exception('Invalid response: missing checkout URL or session ID');
      }

      //debugPrint('✅ Checkout session created');
      //debugPrint('Session ID: $sessionId');
      //debugPrint('Checkout URL: $checkoutUrl');

      // Ouvrir le navigateur
      final launched = await _launchCheckoutUrl(checkoutUrl);
      
      if (launched) {
        //debugPrint('✅ Browser opened successfully');
        return StripeCheckoutResult.success(sessionId: sessionId);
      } else {
        throw Exception('Failed to launch browser');
      }

    } else if (response.statusCode == 401) {
      //debugPrint('❌ Authentication failed');
      final error = _parseError(response.body);
      throw Exception('Authentication error: $error');
      
    } else if (response.statusCode == 422) {
      //debugPrint('❌ Validation error');
      final error = _parseError(response.body);
      throw Exception('Validation error: $error');
      
    } else if (response.statusCode >= 500) {
      //debugPrint('❌ Server error');
      throw Exception('Server error. Please try again later.');
      
    } else {
      //debugPrint('❌ Unexpected error');
      final error = _parseError(response.body);
      throw Exception(error);
    }
  }

  /// Lancer l'URL Stripe dans le navigateur
  Future<bool> _launchCheckoutUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        //debugPrint('Cannot launch URL: $url');
        return false;
      }
    } catch (e) {
      //debugPrint('Error launching URL: $e');
      return false;
    }
  }

  /// Vérifier le statut d'une session après paiement
  Future<Map<String, dynamic>?> verifySession({
    required String sessionId,
    required String pocketbaseToken,
  }) async {
    try {
      //debugPrint('Verifying session: $sessionId');

      final response = await http.get(
        Uri.parse('$_baseUrl$_verifyEndpoint/$sessionId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $pocketbaseToken',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        //debugPrint('✅ Session verified successfully');
        return json.decode(response.body);
      } else {
        //debugPrint('❌ Failed to verify session: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //debugPrint('❌ Error verifying session: $e');
      return null;
    }
  }

  /// Vérifier le statut d'abonnement de l'utilisateur
  Future<Map<String, dynamic>?> getSubscriptionStatus({
    required String pocketbaseToken,
  }) async {
    try {
      //debugPrint('Getting subscription status...');

      final response = await http.get(
        Uri.parse('$_baseUrl$_subscriptionStatusEndpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $pocketbaseToken',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        //debugPrint('✅ Subscription status retrieved');
        return json.decode(response.body);
      } else {
        //debugPrint('❌ Failed to get subscription status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      //debugPrint('❌ Error getting subscription status: $e');
      return null;
    }
  }

  /// Annuler l'abonnement
  Future<bool> cancelSubscription({
    required String pocketbaseToken,
  }) async {
    try {
      //debugPrint('Cancelling subscription...');

      final response = await http.post(
        Uri.parse('$_baseUrl$_cancelSubscriptionEndpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $pocketbaseToken',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        //debugPrint('✅ Subscription cancelled successfully');
        return true;
      } else {
        //debugPrint('❌ Failed to cancel subscription: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      //debugPrint('❌ Error cancelling subscription: $e');
      return false;
    }
  }

  /// Tester la connexion au backend
  Future<bool> testConnection() async {
    try {
      //debugPrint('Testing backend connection...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/api/ping'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        //debugPrint('✅ Backend is reachable');
        return true;
      } else {
        //debugPrint('❌ Backend returned: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      //debugPrint('❌ Backend unreachable: $e');
      return false;
    }
  }

  // ========================================
  // MÉTHODES UTILITAIRES PRIVÉES
  // ========================================

  /// Parser les erreurs de l'API
  String _parseError(String responseBody) {
    try {
      final data = json.decode(responseBody);
      return data['error'] ?? data['message'] ?? 'Unknown error';
    } catch (e) {
      return responseBody.isNotEmpty ? responseBody : 'Unknown error';
    }
  }

  /// Formater les messages d'erreur pour l'utilisateur
  String _formatErrorMessage(String error) {
    String message = error.replaceFirst('Exception: ', '');
    
    if (message.contains('SocketException') || 
        message.contains('Failed host lookup')) {
      return 'Cannot reach payment server. Check your internet connection.';
    } else if (message.contains('TimeoutException') ||
               message.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (message.contains('HandshakeException')) {
      return 'Secure connection failed. Please try again.';
    } else if (message.contains('FormatException')) {
      return 'Invalid server response. Please contact support.';
    } else if (message.contains('Authentication error')) {
      return 'Session expired. Please log in again.';
    }
    
    return message;
  }

  /// Debug le token JWT (en développement uniquement)
  void _debugToken(String token) {
    if (!kDebugMode) return;

    try {
      final parts = token.split('.');
      if (parts.length == 3) {
        // Décoder le payload
        String payload = parts[1];
        
        // Ajouter le padding si nécessaire
        while (payload.length % 4 != 0) {
          payload += '=';
        }
        
        final decoded = utf8.decode(base64Url.decode(payload));
        final data = json.decode(decoded);
        
        //debugPrint('Token info:');
        //debugPrint('  - User ID: ${data['id'] ?? 'N/A'}');
        //debugPrint('  - Email: ${data['email'] ?? 'N/A'}');
        //debugPrint('  - Issued at: ${data['iat'] ?? 'N/A'}');
        //debugPrint('  - Expires at: ${data['exp'] ?? 'N/A'}');
        
        // Vérifier si le token est expiré
        if (data['exp'] != null) {
          final expiryDate = DateTime.fromMillisecondsSinceEpoch(
            (data['exp'] as int) * 1000
          );
          final isExpired = expiryDate.isBefore(DateTime.now());
          //debugPrint('  - Expired: $isExpired');
          if (isExpired) {
            //debugPrint('  ⚠️ WARNING: Token is expired!');
          }
        }
      }
    } catch (e) {
      //debugPrint('Cannot decode token for debug: $e');
    }
  }

  /// Obtenir les headers HTTP standards
  Map<String, String> _getHeaders(String token) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Valider les paramètres de checkout
  void _validateCheckoutParams({
    required double amount,
    required String currency,
    required String planId,
    required String planName,
    required String pocketbaseToken,
  }) {
    if (amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }
    
    if (currency.length != 3) {
      throw ArgumentError('Currency must be 3 characters (e.g., USD, EUR)');
    }
    
    if (planId.isEmpty) {
      throw ArgumentError('Plan ID cannot be empty');
    }
    
    if (planName.isEmpty) {
      throw ArgumentError('Plan name cannot be empty');
    }
    
    if (pocketbaseToken.isEmpty) {
      throw ArgumentError('PocketBase token cannot be empty');
    }
  }
}