// ============================================================================
// MAHMOUD TECH - Splash Screen
// شاشة البداية مع شعار التطبيق وتأثيرات حركية
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();

    // الانتقال إلى الصفحة الرئيسية
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0E17),
              Color(0xFF0F1520),
              Color(0xFF0A0E17),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AnimatedBuilder(
          animation: _logoController,
          builder: (context, child) {
            return Stack(
              children: [
                // الدوائر الزخرفية في الخلفية
                Positioned(
                  top: -80,
                  right: -80,
                  child: _buildGlowCircle(
                    AppTheme.primaryCyan.withOpacity(0.05),
                    250,
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -60,
                  child: _buildGlowCircle(
                    AppTheme.primaryPurple.withOpacity(0.05),
                    300,
                  ),
                ),
                // المحتوى الرئيسي
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // أيقونة التطبيق
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryCyan.withOpacity(0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '🎬',
                                style: TextStyle(fontSize: 56),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // اسم التطبيق
                      Opacity(
                        opacity: _textOpacity.value,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: Text(
                            'MAHMOUD TECH',
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontSize: 32,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // الوصف
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          'استوديو إنشاء فيديوهات Shorts الذكي',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white38,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // مؤشر التحميل
                      Opacity(
                        opacity: _loaderOpacity.value,
                        child: SizedBox(
                          width: 180,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              backgroundColor: AppTheme.darkCard,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryCyan,
                              ),
                              minHeight: 3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Opacity(
                        opacity: _loaderOpacity.value,
                        child: Text(
                          'جارٍ التحميل...',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.white24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // النسخة في الأسفل
                Positioned(
                  bottom: 32,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _loaderOpacity.value,
                    child: Text(
                      'v1.0.0',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white12,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGlowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
