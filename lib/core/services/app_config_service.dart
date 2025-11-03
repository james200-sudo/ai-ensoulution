import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_instance.dart';

class AppConfigService {
  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  final PocketBase _pb = PocketBaseInstance.instance;
  
  // Cache du planMode (valide pendant 5 minutes)
  String? _cachedPlanMode;
  DateTime? _cacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  /// Récupère le planMode depuis app_config
  Future<String> getPlanMode() async {
    try {
      // Utiliser le cache si valide
      if (_cachedPlanMode != null && 
          _cacheTime != null && 
          DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedPlanMode!;
      }

      // Récupérer depuis PocketBase
      final records = await _pb.collection('app_config').getFullList(
        sort: '-created',
      );

      if (records.isEmpty) {
        _cachedPlanMode = 'payant'; // Par défaut si pas de config
        _cacheTime = DateTime.now();
        return 'payant';
      }

      final config = records.first;
      final planMode = config.data['planMode']?.toString() ?? 'payant';
      
      // Mettre en cache
      _cachedPlanMode = planMode;
      _cacheTime = DateTime.now();
      
      return planMode;
    } catch (e) {
      print('❌ Erreur récupération planMode: $e');
      return 'payant'; // Valeur par défaut en cas d'erreur
    }
  }

  /// Vérifie si l'application est en mode gratuit
  Future<bool> isFreeMode() async {
    final planMode = await getPlanMode();
    return planMode.toLowerCase() == 'free';
  }

  /// Force le rechargement du planMode (invalide le cache)
  void clearCache() {
    _cachedPlanMode = null;
    _cacheTime = null;
  }
}