// lib/core/widgets/version_check_wrapper.dart
import 'package:flutter/material.dart';
import '../services/app_version_service.dart';
import '../router/app_router.dart'; // ✅ Importer AppRouter
import 'force_update_dialog.dart';

class VersionCheckWrapper extends StatefulWidget {
  final Widget child;
  final bool checkOnInit;
  
  const VersionCheckWrapper({
    super.key,
    required this.child,
    this.checkOnInit = true,
  });
  
  @override
  State<VersionCheckWrapper> createState() => _VersionCheckWrapperState();
}

class _VersionCheckWrapperState extends State<VersionCheckWrapper> 
    with WidgetsBindingObserver {
  final AppVersionService _versionService = AppVersionService();
  bool _hasCheckedOnInit = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.checkOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkVersion();
      });
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _hasCheckedOnInit) {
      _checkVersion();
    }
  }
  
  Future<void> _checkVersion() async {
    try {
      final updateInfo = await _versionService.checkForUpdate();
      _hasCheckedOnInit = true;
      
      print('📱 Version Check: $updateInfo');
      
      if (updateInfo.isUpdateRequired || updateInfo.isUpdateAvailable) {
        // ✅ Attendre que le Navigator soit prêt
        await _waitForNavigator();
        
        if (mounted) {
          _showUpdateDialog(updateInfo);
        }
      }
    } catch (e) {
      print('❌ Error checking version: $e');
    }
  }
  
  /// ✅ Attendre que le Navigator soit disponible
  Future<void> _waitForNavigator() async {
    int attempts = 0;
    const maxAttempts = 10;
    
    while (attempts < maxAttempts) {
      // Utiliser le navigatorKey de go_router
      if (AppRouter.rootNavigatorKey.currentState != null) {
        print('✅ Navigator ready after ${attempts * 100}ms');
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    
    print('⚠️ Navigator not ready after ${maxAttempts * 100}ms');
  }
  
  void _showUpdateDialog(UpdateInfo updateInfo) {
    // ✅ Utiliser directement le navigatorKey de go_router
    final navigatorState = AppRouter.rootNavigatorKey.currentState;
    
    if (navigatorState == null) {
      print('❌ Navigator still not available');
      return;
    }
    
    print('✅ Showing update dialog');
    
    showDialog(
      context: navigatorState.overlay!.context,
      barrierDismissible: !updateInfo.isUpdateRequired,
      builder: (context) => ForceUpdateDialog(updateInfo: updateInfo),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}