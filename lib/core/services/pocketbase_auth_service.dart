import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pocketbase_instance.dart';

class PocketBaseAuthService {
  static const String _baseUrl = 'https://hydro-ai-chat.ensolutions.ca';
  static const String _usersCollection = 'users';
  static const String _freePlanId = 'xkdv2sqngtpnqjp';
  
  late final PocketBase _pb;
  static final PocketBaseAuthService _instance = PocketBaseAuthService._internal();
  factory PocketBaseAuthService() => _instance;
  
  PocketBaseAuthService._internal() {
     _pb = PocketBaseInstance.instance;
    _initializeAuthStore();
  }
  
  Future<void> _initializeAuthStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pb_token');
      final userJson = prefs.getString('pb_user');
      
      if (token != null && userJson != null) {
        final userData = json.decode(userJson);
        _pb.authStore.save(token, userData);
      }
    } catch (e) {}
  }

  Future<void> _ensureInitialized() async {
    if (_pb.authStore.isValid) return;
    await _initializeAuthStore();
  }
  
  // EMAIL/PASSWORD LOGIN
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _ensureInitialized();
      
      final authData = await _pb.collection(_usersCollection).authWithPassword(email, password);
      
      final isVerified = authData.record?.data['verified'] ?? false;
      if (!isVerified) {
        _pb.authStore.clear();
        return {
          'success': false,
          'error': 'Votre email n\'est pas encore vérifié',
          'needsVerification': true,
          'email': email,
        };
      }
      
      await _saveAuthData(authData.token, authData.record?.toJson());
      
      return {
        'success': true,
        'token': authData.token,
        'user': authData.record?.toJson(),
        'message': 'Authentification réussie',
      };
      
    } catch (e) {
      String errorMessage = 'Erreur de connexion';
      if (e.toString().contains('400') || e.toString().contains('invalid_credentials')) {
        errorMessage = 'Email ou mot de passe incorrect';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Utilisateur non trouvé';
      }
      
      return {'success': false, 'error': errorMessage, 'details': e.toString()};
    }
  }
  
  // GOOGLE OAUTH - Simplifié
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      print('🔵 Google OAuth...');
      
      final authData = await _pb.collection(_usersCollection).authWithOAuth2(
        'google',
        (url) async {
          print('📍 URL: $url');
          
          // ATTENDRE 500ms pour que PocketBase soit prêt
          await Future.delayed(Duration(milliseconds: 500));
          
          if (await canLaunchUrl(url)) {
            await launchUrl(
              url,
              mode: kIsWeb ? LaunchMode.externalApplication : LaunchMode.externalApplication,
              webOnlyWindowName: kIsWeb ? '_blank' : null,
            );
          }
        },
        scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'],
        createData: {
          'emailVisibility': true,
          'subscriptionStatus': 'active',
          'subscriptionStartDate': DateTime.now().toIso8601String(),
          'subscriptionEndDate': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        },
      );
      
      print('✅ OAuth réussi');
      
      final userData = authData.record?.toJson();
      await _saveAuthData(authData.token, userData);
      
      return {
        'success': true,
        'token': authData.token,
        'user': userData,
        'message': 'Authentification Google réussie',
      };
      
    } catch (e) {
      print('❌ Erreur: $e');
      
      if (e.toString().contains('429')) {
        return {'success': false, 'error': 'Trop de tentatives. Attendez 1 minute.', 'rateLimited': true};
      }
      
      return {'success': false, 'error': 'Erreur OAuth Google. Utilisez email/password.', 'details': e.toString()};
    }
  }
  
  // REGISTER
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
  }) async {
    try {
      await _ensureInitialized();
      
      final existingUser = await _checkUserExists(email);
      if (existingUser) {
        return {'success': false, 'error': 'Un compte existe déjà avec cette adresse email'};
      }
      
      final now = DateTime.now();
      
      final record = await _pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'name': name,
        'emailVisibility': true,
        'verified': false,
        'plan': _freePlanId,
        'subscriptionStatus': 'active',
        'subscriptionStartDate': now.toIso8601String(),
        'subscriptionEndDate': now.add(Duration(days: 7)).toIso8601String(),
      });

      try {
        await _pb.collection('users').requestVerification(email);
        
        return {
          'success': true,
          'message': 'Compte créé avec succès. Un email de vérification vous a été envoyé.',
          'userId': record.id,
          'needsVerification': true,
          'emailSent': true,
        };
      } catch (emailError) {
        return {
          'success': true,
          'message': 'Compte créé mais l\'email de vérification n\'a pas pu être envoyé.',
          'userId': record.id,
          'needsVerification': true,
          'emailSent': false,
        };
      }
      
    } catch (e) {
      String errorMessage = 'Erreur lors de l\'inscription';
      if (e.toString().contains('email')) {
        errorMessage = 'Cette adresse email est déjà utilisée';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Le mot de passe ne respecte pas les critères requis';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }
  
 Future<void> logout() async {
  try {
    // 1. Sauvegarder l'email pour pré-remplissage
    final email = _pb.authStore.record?.data['email'];
    
    // 2. Effacer l'auth store de PocketBase
    _pb.authStore.clear();
    
    // 3. Nettoyer SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    // Sauvegarder l'email pour le pré-remplissage
    if (email != null) {
      await prefs.setString('last_email', email);
    }
    
    // Supprimer les tokens et données utilisateur
    await prefs.remove('pb_token');
    await prefs.remove('pb_user');
    await prefs.remove('jwt');
    await prefs.remove('user');
    
    // Supprimer les données de chat
    await prefs.remove('chat_messages');
    await prefs.remove('saved_conversations');
    await prefs.remove('current_conversation_id');
    await prefs.remove('messageCount');
    
    //debugPrint('✅ Déconnexion réussie');
  } catch (e) {
    //debugPrint('❌ Erreur lors de la déconnexion: $e');
  }
}
 
  
  bool get isLoggedIn => _pb.authStore.isValid;
  String? get currentToken => _pb.authStore.token;
  Map<String, dynamic>? get currentUser => _pb.authStore.record?.toJson();
  PocketBase get pocketBase => _pb;
  
  Future<void> _saveAuthData(String token, Map<String, dynamic>? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('pb_token', token);
      if (user != null) {
        await prefs.setString('pb_user', json.encode(user));
      }
      
      await prefs.setString('jwt', token);
      if (user != null) {
        await prefs.setString('user', json.encode(user));
      }
      
      if (prefs.getString('firstLoginDate') == null) {
        await prefs.setString('firstLoginDate', DateTime.now().toIso8601String());
      }
    } catch (e) {}
  }
  
  Future<bool> refreshAuthIfNeeded() async {
    try {
      if (!_pb.authStore.isValid) return false;
      await _pb.collection(_usersCollection).authRefresh();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> testConnection() async {
    try {
      await _pb.health.check();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> requestEmailVerification(String email) async {
    try {
      await _ensureInitialized();
      
      final user = await getUserByEmail(email);
      if (user == null) {
        return {'success': false, 'error': 'Adresse email non trouvée'};
      }
      
      if (user['verified'] == true) {
        return {'success': false, 'error': 'Ce compte est déjà vérifié'};
      }
      
      await _pb.collection('users').requestVerification(email);
      
      return {'success': true, 'message': 'Email de vérification envoyé avec succès'};
      
    } catch (e) {
      return {'success': false, 'error': 'Impossible d\'envoyer l\'email de vérification'};
    }
  }

  Future<Map<String, dynamic>> confirmEmailVerification(String token) async {
    try {
      await _ensureInitialized();
      
      if (token.trim().isEmpty) {
        return {'success': false, 'error': 'Le code de vérification ne peut pas être vide'};
      }
      
      await _pb.collection('users').confirmVerification(token.trim());
      
      return {'success': true, 'message': 'Email vérifié avec succès !'};
      
    } catch (e) {
      String errorMessage = 'Code de vérification invalide ou expiré';
      if (e.toString().contains('404')) {
        errorMessage = 'Code de vérification introuvable';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Code de vérification invalide';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      await _ensureInitialized();
      
      if (email.trim().isEmpty) {
        return {'success': false, 'error': 'L\'adresse email ne peut pas être vide'};
      }
      
      final user = await getUserByEmail(email.trim());
      if (user == null) {
        return {'success': false, 'error': 'Aucun compte trouvé avec cette adresse email', 'userExists': false};
      }
      
      await _pb.collection('users').requestPasswordReset(email.trim());
      
      return {'success': true, 'message': 'Un email de réinitialisation vous a été envoyé.', 'userExists': true, 'emailSent': true};
      
    } catch (e) {
      return {'success': false, 'error': 'Impossible de traiter votre demande'};
    }
  }

  Future<Map<String, dynamic>> confirmPasswordReset({
    required String token,
    required String newPassword,
    required String passwordConfirm,
  }) async {
    try {
      await _ensureInitialized();
      
      if (token.trim().isEmpty) {
        return {'success': false, 'error': 'Le code de vérification ne peut pas être vide'};
      }
      
      if (newPassword != passwordConfirm) {
        return {'success': false, 'error': 'Les mots de passe ne correspondent pas'};
      }
      
      if (newPassword.length < 8) {
        return {'success': false, 'error': 'Le mot de passe doit contenir au moins 8 caractères'};
      }
      
      await _pb.collection('users').confirmPasswordReset(token.trim(), newPassword, passwordConfirm);
      
      return {'success': true, 'message': 'Mot de passe réinitialisé avec succès !'};
      
    } catch (e) {
      String errorMessage = 'Code de vérification invalide ou expiré';
      if (e.toString().contains('404')) {
        errorMessage = 'Code de vérification introuvable';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Code de vérification invalide';
      }
      
      return {'success': false, 'error': errorMessage};
    }
  }

  Future<bool> _checkUserExists(String email) async {
    try {
      await _ensureInitialized();
      final cleanEmail = email.trim().toLowerCase();
      final records = await _pb.collection('users').getList(page: 1, perPage: 1, filter: 'email="$cleanEmail"');
      return records.items.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      await _ensureInitialized();
      final cleanEmail = email.trim().toLowerCase();
      final records = await _pb.collection('users').getList(page: 1, perPage: 1, filter: 'email="$cleanEmail"');
      
      if (records.items.isEmpty) return null;
      
      final record = records.items.first;
      
      return {
        'id': record.id,
        'email': record.data['email'],
        'name': record.data['name'],
        'verified': record.data['verified'] ?? false,
        'created': record.data['created'],
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> checkServerStatus() async {
    try {
      await _pb.health.check();
      return {'success': true, 'message': 'Serveur PocketBase disponible', 'baseUrl': _baseUrl};
    } catch (e) {
      return {'success': false, 'error': 'Serveur PocketBase indisponible', 'details': e.toString()};
    }
  }
}