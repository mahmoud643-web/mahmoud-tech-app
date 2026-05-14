// ============================================================================
// MAHMOUD TECH - Main Entry Point
// نقطة الدخول الرئيسية للتطبيق
// استوديو إنشاء فيديوهات Shorts الذكي
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/app_provider.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تثبيت اتجاه الشاشة
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تعيين لون شريط الحالة
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.darkBg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MahmoudTechApp());
}

class MahmoudTechApp extends StatelessWidget {
  const MahmoudTechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..initialize()),
        ChangeNotifierProvider(
            create: (_) => ProjectProvider()..initialize()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'MAHMOUD TECH',
            debugShowCheckedModeBanner: false,

            // الثيم
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            // اتجاه النص - RTL للعربية
            builder: (context, child) {
              return Directionality(
                textDirection: appProvider.isArabic
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: child!,
              );
            },

            // الصفحة الأولى
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
