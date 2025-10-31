import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'features/chat/providers/chat_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/plans/providers/plans_provider.dart'; 
import 'l10n/app_localizations.dart';
import 'core/widgets/version_check_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style for Android - optimized for performance
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Enable edge-to-edge mode for Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Optimize keyboard performance
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // Initialize notification service (uniquement sur mobile)
  if (!kIsWeb) {
    try {
      await NotificationService().initialize();
    } catch (e) {
      //print('❌ Erreur initialisation notifications: $e');
    }
  }

  runApp(const TGMAIApp());
}

class TGMAIApp extends StatelessWidget {
  const TGMAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      useInheritedMediaQuery: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ChatProvider()),
            ChangeNotifierProvider(create: (_) => ProfileProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider(create: (_) => PlansProvider()), 
          ],
          child: Consumer<SettingsProvider>(
            builder: (context, settingsProvider, child) {
              return MaterialApp.router(
                title: 'TGM HydroAI Chat',
                debugShowCheckedModeBanner: false,
                theme: settingsProvider.settings.darkMode
                    ? AppTheme.darkTheme
                    : AppTheme.lightTheme,
                builder: (context, child) {
                  // ✅ VersionCheckWrapper ICI (a accès au Navigator)
                  return VersionCheckWrapper(
                    checkOnInit: true,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: TextScaler.linear(
                          MediaQuery.textScalerOf(context)
                              .scale(1.0)
                              .clamp(0.8, 1.2),
                        ),
                      ),
                      child: child!,
                    ),
                  );
                },
                routerConfig: AppRouter.router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', ''),
                  Locale('fr', ''),
                  Locale('es', ''),
                ],
                locale:
                    _getLocaleFromSettings(settingsProvider.settings.language),
              );
            },
          ),
        );
      },
    );
  }

  Locale _getLocaleFromSettings(String languageCode) {
    switch (languageCode) {
      case 'fr':
        return const Locale('fr', '');
      case 'es':
        return const Locale('es', '');
      case 'en':
      default:
        return const Locale('en', '');
    }
  }
}