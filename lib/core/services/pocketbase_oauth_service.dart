import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'pocketbase_instance.dart';

class PocketBaseOAuthService {
  static const String _baseUrl = 'https://hydro-ai-chat.ensolutions.ca';
  static const String _usersCollection = 'users';
  
  // ID du plan FREE
  static const String _freePlanId = 'xkdv2sqngtpnqjp';
  
  late final PocketBase _pb;
  
  // Singleton
  static final PocketBaseOAuthService _instance = PocketBaseOAuthService._internal();
  factory PocketBaseOAuthService() => _instance;
  
  PocketBaseOAuthService._internal() {
     _pb = PocketBaseInstance.instance;
    _initializeAuthStore();
  }
  
  PocketBase get pocketBase => _pb;
  bool get isLoggedIn => _pb.authStore.isValid;
  String? get currentToken => _pb.authStore.token;
  Map<String, dynamic>? get currentUser {
    final record = _pb.authStore.record;
    if (record == null) return null;
    
    // Construire manuellement l'objet utilisateur
    return _buildUserData(record);
  }

  /// Initialise l'auth store avec les données sauvegardées
  Future<void> _initializeAuthStore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('pb_token');
      final userJson = prefs.getString('pb_user');
      
      if (token != null && userJson != null) {
        final userData = json.decode(userJson);
        _pb.authStore.save(token, userData);
        //print('Session PocketBase restaurée');
      }
    } catch (e) {
      //print('Erreur restauration session: $e');
    }
  }

  /// ========================================
  /// MÉTHODE UTILITAIRE : Construction manuelle des données utilisateur
  /// ========================================
  Map<String, dynamic> _buildUserData(RecordModel record) {
    final userData = <String, dynamic>{
      // Champs systèmes (accessibles directement)
      'id': record.id,
      'collectionId': record.collectionId,
      'collectionName': record.collectionName,
      'created': record.created,
      'updated': record.updated,
    };
    
    // Ajouter les données du record.data
    try {
      // Convertir record.data (qui peut être IdentityMap) en Map standard
      final data = record.data;
      
      if (data is Map) {
        // Parcourir chaque clé et convertir les valeurs
        data.forEach((key, value) {
          // Convertir les valeurs complexes en types sérialisables
          if (value is Map) {
            userData[key] = Map<String, dynamic>.from(value);
          } else if (value is List) {
            userData[key] = List<dynamic>.from(value);
          } else {
            userData[key] = value;
          }
        });
      }
    } catch (e) {
      //print('⚠️ Erreur conversion record.data: $e');
    }
    
    return userData;
  }

  /// ========================================
  /// AUTHENTIFICATION GOOGLE OAUTH COMPLETE
  /// ========================================
  
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      //print('=== DÉBUT AUTHENTIFICATION GOOGLE OAUTH ===');
      
      Map<String, dynamic>? userData;
      Map<String, dynamic>? metaData;
      String? token;
      
      // Utiliser la méthode authWithOAuth2 avec callback
      final authData = await _pb.collection(_usersCollection).authWithOAuth2(
        'google',
        (url) async {
          //print('URL OAuth reçue: $url');
          
          if (await canLaunchUrl(url)) {
            // ✅ Sur Web ET Mobile : utiliser externalApplication pour ouvrir en popup
            final launched = await launchUrl(
              url,
              mode: LaunchMode.externalApplication,
              webOnlyWindowName: '_blank',  // Ouvre dans une nouvelle fenêtre/popup
            );
            
            if (!launched) {
              throw Exception('Échec du lancement de l\'URL');
            }
            
            //print('Navigateur ouvert pour authentification Google');
          } else {
            throw Exception('Impossible d\'ouvrir l\'URL OAuth');
          }
        },
        scopes: ['email', 'profile'],
        createData: {
          'emailVisibility': true,
        },
      );
      
      //print('Authentification OAuth réussie');
      token = authData.token;
      //print('Token: $token');
      
      // Extraire les données utilisateur
      try {
        final record = authData.record;
        if (record != null) {
          userData = {
            'id': record.id,
            'collectionId': record.collectionId,
            'collectionName': record.collectionName,
            'created': record.created,
            'updated': record.updated,
          };
          
          if (record.data.isNotEmpty) {
            userData.addAll(Map<String, dynamic>.from(record.data));
          }
          
          //print('User ID: ${userData['id']}');
          //print('User email: ${userData['email']}');
          //print('User verified: ${userData['verified']}');
        }
      } catch (e) {
        //print('Erreur extraction record: $e');
      }
      
      // Extraire meta
      try {
        if (authData.meta != null) {
          metaData = Map<String, dynamic>.from(authData.meta as Map);
        }
      } catch (e) {
        //print('Erreur extraction meta: $e');
      }
      
      // Sauvegarder
      if (token != null && userData != null) {
        await _saveAuthData(token, userData);
      }
      
      return {
        'success': true,
        'token': token,
        'user': userData,
        'meta': metaData,
        'message': 'Authentification Google réussie',
      };
      
    } catch (e, stackTrace) {
      //print('Erreur authentification Google: $e');
      //print('Stack trace: $stackTrace');
      
      String errorMessage = 'Erreur lors de l\'authentification Google';
      
      if (e.toString().contains('OAuth2')) {
        errorMessage = 'OAuth2 n\'est pas configuré correctement dans PocketBase';
      } else if (e.toString().contains('cancelled')) {
        errorMessage = 'Authentification annulée';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Problème de connexion réseau';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'La connexion a expiré. Réessayez.';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'details': e.toString(),
      };
    }
  }

  /// ========================================
  /// AUTHENTIFICATION EMAIL/PASSWORD
  /// ========================================
  
  Future<Map<String, dynamic>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      //print('Tentative de connexion email/password...');
      
      final authData = await _pb.collection(_usersCollection).authWithPassword(
        email,
        password,
      );
      
      //print('Authentification réussie');
      
      // Vérifier si l'email est vérifié
      final record = authData.record;
      if (record == null) {
        throw Exception('Données utilisateur manquantes');
      }
      
      final isVerified = record.data['verified'] ?? false;
      if (!isVerified) {
        _pb.authStore.clear();
        return {
          'success': false,
          'error': 'Votre email n\'est pas encore vérifié',
          'needsVerification': true,
          'email': email,
        };
      }
      
      // Construire les données utilisateur
      final userData = _buildUserData(record);
      await _saveAuthData(authData.token, userData);
      
      return {
        'success': true,
        'token': authData.token,
        'user': userData,
        'message': 'Authentification réussie',
      };
      
    } catch (e) {
      //print('Erreur authentification: $e');
      
      String errorMessage = 'Erreur de connexion';
      if (e.toString().contains('400') || e.toString().contains('invalid_credentials')) {
        errorMessage = 'Email ou mot de passe incorrect';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Utilisateur non trouvé';
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'details': e.toString(),
      };
    }
  }

  /// ========================================
  /// INSCRIPTION
  /// ========================================
  
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String passwordConfirm,
    required String name,
  }) async {
    try {
      //print('Inscription utilisateur...');
      
      // Calculer les dates pour le plan Free (7 jours gratuits)
      final now = DateTime.now();
      final startDate = now.toIso8601String();
      final endDate = now.add(Duration(days: 7)).toIso8601String();
      
      final record = await _pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
        'name': name,
        'emailVisibility': true,
        'verified': false,
        
        // Attribution automatique du plan Free
        'plan': _freePlanId,
        'subscriptionStatus': 'active',
        'subscriptionStartDate': startDate,
        'subscriptionEndDate': endDate,
      });

      //print('✅ Utilisateur créé: ${record.id}');
      //print('✅ Plan Free attribué automatiquement');
      
      // Envoyer l'email de vérification
      await _pb.collection('users').requestVerification(email);
      
      return {
        'success': true,
        'message': 'Compte créé avec succès. Un email de vérification vous a été envoyé.',
        'userId': record.id,
        'needsVerification': true,
        'emailSent': true,
      };
      
    } catch (e) {
      //print('Erreur inscription: $e');
      
      String errorMessage = 'Erreur lors de l\'inscription';
      if (e.toString().contains('email')) {
        errorMessage = 'Cette adresse email est déjà utilisée';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Le mot de passe ne respecte pas les critères requis';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  /// ========================================
  /// UTILITAIRES
  /// ========================================
  
  Future<void> _saveAuthData(String token, Map<String, dynamic>? user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('pb_token', token);
      if (user != null) {
        await prefs.setString('pb_user', json.encode(user));
      }
      
      // Compatibilité ancien format
      await prefs.setString('jwt', token);
      if (user != null) {
        await prefs.setString('user', json.encode(user));
      }
      
      if (prefs.getString('firstLoginDate') == null) {
        await prefs.setString('firstLoginDate', DateTime.now().toIso8601String());
      }
      
      //print('Données d\'authentification sauvegardées');
      
    } catch (e) {
      //print('Erreur sauvegarde auth: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      //print('Déconnexion...');
      
      _pb.authStore.clear();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pb_token');
      await prefs.remove('pb_user');
      await prefs.remove('jwt');
      await prefs.remove('user');
      
      //print('Déconnexion effectuée');
      
    } catch (e) {
      //print('Erreur déconnexion: $e');
    }
  }
  
  Future<bool> testConnection() async {
    try {
      await _pb.health.check();
      //print('Connexion PocketBase OK');
      return true;
    } catch (e) {
      //print('Connexion PocketBase échouée: $e');
      return false;
    }
  }
}