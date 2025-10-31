import 'package:tgm_ai_chat/core/services/message_counter_service.dart';
import 'package:tgm_ai_chat/core/services/subscription_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_stats.dart';
import '../../../core/utils/strapi_client.dart';
import '../../../core/utils/constants.dart';
import '../../../core/services/pocketbase_auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;
  bool _isCompanyUser = false;
  
  late final PocketBaseAuthService _authService;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isCompanyUser => _isCompanyUser;

  static const String _profileKey = 'user_profile';

  ProfileProvider() {
    _authService = PocketBaseAuthService();
    _loadUserProfile();
  }

  Future<void> refreshUserProfile() async {
    await _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    _setLoading(true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionService = SubscriptionService();
      
      final userType = prefs.getString('user_type') ?? 'individual';
      _isCompanyUser = userType == 'company';
      
      final userJson = prefs.getString('user');
      final messageCount = await MessageCounterService().getMessageCount();
      final firstLoginDateStr = prefs.getString('firstLoginDate');
      int daysActive = 0;
      if (firstLoginDateStr != null) {
        final firstLoginDate = DateTime.parse(firstLoginDateStr);
        daysActive = DateTime.now().difference(firstLoginDate).inDays;
      }

      String currentPlan = 'Free';
      DateTime? planExpiryDate = subscriptionService.planExpiryDate;
      
      if (!_isCompanyUser) {
        final syncedPlan = await _syncPlanFromPocketBase();
        if (syncedPlan != null) {
          currentPlan = syncedPlan;
          //print('Plan synchronisé depuis PocketBase: $currentPlan');
        } else {
          currentPlan = subscriptionService.currentPlan;
        }
      } else {
        currentPlan = subscriptionService.currentPlan;
      }

      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        
        String userName = 'Unknown User';
        String userEmail = 'unknown@email.com';
        String? avatarUrl;
        
        if (userData.containsKey('firstName') && userData.containsKey('lastName')) {
          userName = '${userData['firstName']} ${userData['lastName']}';
        } else if (userData.containsKey('username')) {
          userName = userData['username'];
        } else if (userData.containsKey('name')) {
          userName = userData['name'];
        }
        
        if (userData.containsKey('email')) {
          userEmail = userData['email'];
        }
        
        // Gestion avatar pour PocketBase
        if (userData.containsKey('avatar') && userData['avatar'] != null) {
          if (userData['avatar'] is String && userData['avatar'].isNotEmpty) {
            avatarUrl = userData['avatar'];
            
            // Construire l'URL complète si nécessaire
            if (avatarUrl != null && !avatarUrl.startsWith('http')) {
              if (_isCompanyUser) {
                // Pour Strapi (company users)
                avatarUrl = '${AppConstants.strapiApiUrl.replaceAll('/api', '')}$avatarUrl';
              } else {
                // Pour PocketBase (individual users)
                final userId = userData['id'];
                avatarUrl = 'https://hydro-ai-chat.ensolutions.ca/api/files/_pb_users_auth_/$userId/$avatarUrl';
              }
            }
          } else if (userData['avatar'] is Map && userData['avatar']['url'] != null) {
            // Ce cas est pour Strapi uniquement
            avatarUrl = userData['avatar']['url'];
            if (avatarUrl != null && !avatarUrl.startsWith('http')) {
              avatarUrl = '${AppConstants.strapiApiUrl.replaceAll('/api', '')}$avatarUrl';
            }
          }
        }
        
        _userProfile = UserProfile(
          id: userData['id']?.toString() ?? '1',
          name: userName,
          email: userEmail,
          avatarUrl: avatarUrl,
          stats: UserStats(
            messageCount: messageCount,
            daysActive: daysActive,
            rating: 4.8,
            joinDate: DateTime.now().subtract(Duration(days: daysActive)),
            conversationsCount: messageCount ~/ 10,
          ),
          lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
          currentPlan: currentPlan,
          planExpiryDate: planExpiryDate,
        );
        
        await _saveUserProfile();
      } else {
        final profileJson = prefs.getString(_profileKey);
        if (profileJson != null) {
          final profileMap = json.decode(profileJson) as Map<String, dynamic>;
          _userProfile = UserProfile.fromJson(profileMap);
          _userProfile = _userProfile!.copyWith(
            stats: _userProfile!.stats.copyWith(
              messageCount: messageCount,
              daysActive: daysActive,
            ),
            currentPlan: currentPlan,
            planExpiryDate: planExpiryDate,
          );
        } else {
          _userProfile = UserProfile(
            id: '1',
            name: 'User',
            email: 'user@example.com',
            stats: UserStats(
              messageCount: messageCount,
              daysActive: daysActive,
              rating: 4.8,
              joinDate: DateTime.now().subtract(const Duration(days: 1)),
              conversationsCount: 0,
            ),
            lastActive: DateTime.now(),
            currentPlan: currentPlan,
            planExpiryDate: planExpiryDate,
          );
          await _saveUserProfile();
        }
      }
    } catch (e) {
      //debugPrint('Error loading user profile: $e');
      final subscriptionService = SubscriptionService();
      _userProfile = UserProfile(
        id: '1',
        name: 'User',
        email: 'user@example.com',
        stats: UserStats(
          messageCount: 0,
          daysActive: 1,
          rating: 4.8,
          joinDate: DateTime.now().subtract(const Duration(days: 1)),
          conversationsCount: 0,
        ),
        lastActive: DateTime.now(),
        currentPlan: subscriptionService.currentPlan,
        planExpiryDate: subscriptionService.planExpiryDate,
      );
    }

    _setLoading(false);
  }

  Future<String?> _syncPlanFromPocketBase() async {
    try {
      //print('=== DEBUT SYNC PLAN DEPUIS POCKETBASE ===');
      final pb = _authService.pocketBase;
      
      //print('AuthStore valide: ${pb.authStore.isValid}');
      //print('Model présent: ${pb.authStore.model != null}');
      
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        //print('❌ ProfileProvider: Utilisateur non connecté à PocketBase');
        return null;
      }

      final userId = pb.authStore.model!.id;
      //print('🔍 ProfileProvider: Récupération du plan pour utilisateur $userId');
      
      final userRecord = await pb.collection('users').getOne(userId);
      
      final planId = userRecord.data['plan'];
      
      if (planId == null || planId.toString().isEmpty) {
        //print('⚠️ Aucun plan assigné à l\'utilisateur - utilisation du plan par défaut');
        return 'Free';
      }
      
      //print('✅ ID du plan trouvé: "$planId"');
      
      try {
        final planRecord = await pb.collection('plans').getOne(planId.toString());
        
        final planName = planRecord.data['Name']?.toString();
        
        if (planName != null && planName.isNotEmpty) {
          //print('✅ Plan récupéré avec succès: "$planName"');
          //print('=== FIN SYNC PLAN - SUCCÈS ===');
          return planName;
        } else {
          //print('⚠️ Nom du plan vide ou null dans l\'enregistrement');
          return 'Free';
        }
      } catch (planError) {
        //print('❌ Erreur lors de la récupération du plan "$planId": $planError');
        return 'Free';
      }
      
    } catch (e) {
      //print('❌ Erreur générale lors de la sync du plan: $e');
      return null;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> _saveUserProfile() async {
    if (_userProfile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_userProfile!.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      //debugPrint('Error saving user profile: $e');
    }
  }

  // ========================================
  // UPLOAD AVATAR - POCKETBASE
  // ========================================
    Future<String?> _uploadAvatarToPocketBase(XFile imageFile) async {
    try {
      //print('=== DEBUT UPLOAD AVATAR POCKETBASE ===');
      final pb = _authService.pocketBase;
      
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        //print('❌ Utilisateur non connecté à PocketBase');
        return null;
      }

      final userId = pb.authStore.model!.id;
      //print('📤 Upload avatar pour utilisateur: $userId');

      // Lire les bytes du fichier
      final bytes = await imageFile.readAsBytes();
      
      // PocketBase attend un MultipartFile mais de son propre package
      // Il faut utiliser http.MultipartFile mais le passer correctement
      final updatedRecord = await pb.collection('users').update(
        userId,
        body: {}, // Body vide pour les autres champs
        files: [
          http.MultipartFile.fromBytes(
            'avatar', // nom du champ
            bytes,
            filename: imageFile.name,
          ),
        ],
      );

      //print('✅ Avatar uploadé avec succès');
      
      // Construire l'URL complète de l'avatar
      final avatarFilename = updatedRecord.data['avatar'];
      if (avatarFilename != null && avatarFilename.isNotEmpty) {
        final avatarUrl = 'https://hydro-ai-chat.ensolutions.ca/api/files/_pb_users_auth_/$userId/$avatarFilename';
        //print('📸 URL avatar: $avatarUrl');
        return avatarUrl;
      }

      return null;
    } catch (e) {
      //print('❌ ERREUR upload avatar PocketBase: $e');
      //print('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // ========================================
  // UPLOAD AVATAR - STRAPI (Company users)
  // ========================================
  Future<String?> _uploadAvatarToStrapi(XFile imageFile) async {
    try {
      //print('=== DEBUT UPLOAD AVATAR STRAPI ===');
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt');
      final userId = _userProfile!.id;

      if (jwt == null) {
        //print('ERREUR: JWT manquant');
        return null;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.strapiApiUrl}/upload'),
      );

      request.headers['Authorization'] = 'Bearer $jwt';

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'files',
          bytes,
          filename: imageFile.name,
        );
        request.files.add(multipartFile);
      } else {
        var multipartFile = await http.MultipartFile.fromPath(
          'files',
          imageFile.path,
        );
        request.files.add(multipartFile);
      }

      request.fields['field'] = 'avatar';
      request.fields['ref'] = 'plugin::users-permissions.user';
      request.fields['refId'] = userId;
      request.fields['source'] = 'plugin::users-permissions';

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final uploadResult = json.decode(responseData.body);
        
        if (uploadResult is List && uploadResult.isNotEmpty) {
          final avatarData = uploadResult[0];
          String avatarUrl = avatarData['url'];
          
          if (!avatarUrl.startsWith('http')) {
            avatarUrl = '${AppConstants.strapiApiUrl.replaceAll('/api', '')}$avatarUrl';
          }
          
          //print('✅ URL avatar Strapi: $avatarUrl');
          return avatarUrl;
        }
      }
      
      return null;
    } catch (e) {
      //print('❌ EXCEPTION upload avatar Strapi: $e');
      return null;
    }
  }

  // ========================================
  // UPDATE PROFILE - UNIFIÉ
  // ========================================
  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    XFile? avatarFile,
  }) async {
    if (_userProfile == null) return;

    _setLoading(true);

    try {
      //print('=== DEBUT UPDATE PROFIL ===');
      //print('Type utilisateur: ${_isCompanyUser ? "Company" : "Individual"}');

      String? uploadedAvatarUrl;

      // Upload avatar selon le type d'utilisateur
      if (avatarFile != null) {
        //print('📤 Upload de nouvel avatar...');
        if (_isCompanyUser) {
          uploadedAvatarUrl = await _uploadAvatarToStrapi(avatarFile);
        } else {
          uploadedAvatarUrl = await _uploadAvatarToPocketBase(avatarFile);
        }
        
        if (uploadedAvatarUrl != null) {
          //print('✅ Avatar uploadé: $uploadedAvatarUrl');
          avatarUrl = uploadedAvatarUrl;
        }
      }

      // Mise à jour selon le type d'utilisateur
      if (_isCompanyUser) {
        await _updateProfileStrapi(name: name, email: email, avatarUrl: avatarUrl);
      } else {
        await _updateProfilePocketBase(name: name, avatarUrl: avatarUrl);
      }

      //print('=== UPDATE PROFIL RÉUSSI ===');

    } catch (e) {
      //print('❌ ERREUR UPDATE PROFIL: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ========================================
  // UPDATE PROFILE - POCKETBASE
  // ========================================
  Future<void> _updateProfilePocketBase({
    String? name,
    String? avatarUrl,
  }) async {
    try {
      //print('🔄 Mise à jour profil PocketBase...');
      final pb = _authService.pocketBase;
      
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        throw Exception('Utilisateur non connecté à PocketBase');
      }

      final userId = pb.authStore.model!.id;
      final updateData = <String, dynamic>{};

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }

      // Note: On ne met PAS à jour l'email dans PocketBase directement
      // Il faut utiliser requestEmailChange() pour cela

      if (updateData.isNotEmpty) {
        //print('📦 Données à mettre à jour: $updateData');
        
        final updatedRecord = await pb.collection('users').update(
          userId,
          body: updateData,
        );

        //print('✅ Profil PocketBase mis à jour');

        // Récupérer l'URL de l'avatar si elle existe
        String? finalAvatarUrl = avatarUrl;
        if (updatedRecord.data['avatar'] != null && updatedRecord.data['avatar'].isNotEmpty) {
          final avatarFilename = updatedRecord.data['avatar'];
          finalAvatarUrl = 'https://hydro-ai-chat.ensolutions.ca/api/files/_pb_users_auth_/$userId/$avatarFilename';
        }

        // Mettre à jour le profil local
        _userProfile = _userProfile!.copyWith(
          name: name ?? _userProfile!.name,
          avatarUrl: finalAvatarUrl ?? _userProfile!.avatarUrl,
        );

        await _saveUserProfile();

        // Mettre à jour SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final currentUserJson = prefs.getString('user');
        if (currentUserJson != null) {
          final currentUserData = json.decode(currentUserJson) as Map<String, dynamic>;
          
          if (name != null) {
            currentUserData['name'] = name.trim();
          }
          
          if (finalAvatarUrl != null) {
            currentUserData['avatar'] = updatedRecord.data['avatar']; // Stocker le nom du fichier
          }
          
          await prefs.setString('user', json.encode(currentUserData));
        }

        notifyListeners();
      }
    } catch (e) {
      //print('❌ Erreur mise à jour PocketBase: $e');
      throw e;
    }
  }

  // ========================================
  // UPDATE PROFILE - STRAPI (Company)
  // ========================================
  Future<void> _updateProfileStrapi({
    String? name,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      //print('🔄 Mise à jour profil Strapi...');
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString('jwt');
      final userId = _userProfile!.id;

      if (jwt == null || userId.isEmpty) {
        throw Exception('Utilisateur non authentifié');
      }

      final updateData = <String, dynamic>{};
      
      if (name != null) {
        final nameParts = name.trim().split(' ');
        updateData['firstName'] = nameParts.first;
        if (nameParts.length > 1) {
          updateData['lastName'] = nameParts.skip(1).join(' ');
        }
      }
      
      if (email != null) {
        updateData['email'] = email.trim();
      }

      final response = await http.put(
        Uri.parse('${AppConstants.strapiApiUrl}/users/$userId?populate=*'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);

        String? finalAvatarUrl = avatarUrl;
        
        if (responseData.containsKey('avatar') && responseData['avatar'] != null) {
          if (responseData['avatar'] is Map && responseData['avatar']['url'] != null) {
            finalAvatarUrl = responseData['avatar']['url'];
          } else if (responseData['avatar'] is String) {
            finalAvatarUrl = responseData['avatar'];
          }
          
          if (finalAvatarUrl != null && !finalAvatarUrl.startsWith('http')) {
            finalAvatarUrl = '${AppConstants.strapiApiUrl.replaceAll('/api', '')}$finalAvatarUrl';
          }
        }

        _userProfile = _userProfile!.copyWith(
          name: name ?? _userProfile!.name,
          email: email ?? _userProfile!.email,
          avatarUrl: finalAvatarUrl ?? _userProfile!.avatarUrl,
        );

        await _saveUserProfile();
        
        final currentUserJson = prefs.getString('user');
        if (currentUserJson != null) {
          final currentUserData = json.decode(currentUserJson) as Map<String, dynamic>;
          
          if (name != null) {
            final nameParts = name.trim().split(' ');
            currentUserData['firstName'] = nameParts.first;
            if (nameParts.length > 1) {
              currentUserData['lastName'] = nameParts.skip(1).join(' ');
            }
          }
          
          if (email != null) {
            currentUserData['email'] = email.trim();
          }
          
          if (responseData.containsKey('avatar')) {
            currentUserData['avatar'] = responseData['avatar'];
          }
          
          await prefs.setString('user', json.encode(currentUserData));
        }
        
        notifyListeners();
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      //print('❌ Erreur mise à jour Strapi: $e');
      throw e;
    }
  }

  Future<void> updatePlan(String planName) async {
    if (_userProfile == null) return;

    //print('ProfileProvider: Mise à jour du plan vers $planName');

    try {
      if (!_isCompanyUser) {
        await _updatePlanInPocketBase(planName);
      }

      final subscriptionService = SubscriptionService();
      
      _userProfile = _userProfile!.copyWith(
        currentPlan: planName,
        planExpiryDate: subscriptionService.planExpiryDate,
      );

      await _saveUserProfile();
      
      //print('ProfileProvider: Plan mis à jour vers $planName');
      notifyListeners();
      
    } catch (e) {
      //print('ProfileProvider: Erreur mise à jour plan: $e');
      rethrow;
    }
  }

  Future<void> _updatePlanInPocketBase(String planName) async {
    try {
      //print('=== DEBUT MISE À JOUR PLAN DANS POCKETBASE ===');
      //print('Plan demandé: "$planName"');
      
      final pb = _authService.pocketBase;
      if (!pb.authStore.isValid || pb.authStore.model == null) {
        //print('❌ ProfileProvider: Utilisateur non connecté pour mise à jour');
        return;
      }

      final userId = pb.authStore.model!.id;
      //print('🔄 ProfileProvider: Mise à jour du plan vers "$planName" pour utilisateur $userId');
      
      String? planId;
      try {
        final planRecord = await pb.collection('plans').getFirstListItem(
          'Name = "$planName"'
        );
        planId = planRecord.id;
        //print('✅ ID du plan "$planName" trouvé: $planId');
      } catch (e) {
        //print('❌ Plan "$planName" non trouvé dans la base: $e');
        throw Exception('Plan "$planName" non trouvé dans la base de données');
      }

      final updateData = {
        'plan': planId,
        'updated': DateTime.now().toIso8601String(),
      };
      
      await pb.collection('users').update(userId, body: updateData);

      //print('✅ ProfileProvider: Plan mis à jour avec succès dans PocketBase');
      
      final updatedUser = await pb.collection('users').getOne(userId);
      //print('📦 Champ "plan" après mise à jour: ${updatedUser.data['plan']}');
      //print('=== FIN MISE À JOUR PLAN - SUCCÈS ===');
      
    } catch (e) {
      //print('❌ ProfileProvider: Erreur mise à jour PocketBase: $e');
      throw e;
    }
  }

  Future<void> syncPlanFromPocketBase() async {
    if (_userProfile == null || _isCompanyUser) return;

    try {
      final syncedPlan = await _syncPlanFromPocketBase();
      if (syncedPlan != null && syncedPlan != _userProfile!.currentPlan) {
        //print('ProfileProvider: Plan synchronisé: ${_userProfile!.currentPlan} → $syncedPlan');
        
        _userProfile = _userProfile!.copyWith(currentPlan: syncedPlan);
        await _saveUserProfile();
        notifyListeners();
      }
    } catch (e) {
      //print('ProfileProvider: Erreur sync forcée: $e');
    }
  }

  Future<void> refreshStats() async {
    if (_userProfile == null) return;

    _setLoading(true);

    await Future.delayed(const Duration(milliseconds: 800));

    final currentStats = _userProfile!.stats;
    _userProfile = _userProfile!.copyWith(
      stats: currentStats.copyWith(
        messageCount:
            currentStats.messageCount + (DateTime.now().millisecond % 10),
        daysActive: currentStats.daysActive + (DateTime.now().second % 2),
      ),
      lastActive: DateTime.now(),
    );

    _setLoading(false);
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt');
      await prefs.remove('user');
      await prefs.remove(_profileKey);
      await prefs.remove('pb_token');
      await prefs.remove('pb_user');
      
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      //debugPrint('Failed to logout: $e');
      _userProfile = null;
      notifyListeners();
    }
  }
}