// ============================================================================
// MAHMOUD TECH - Generation Screen
// شاشة التوليد مع مؤشر التقدم والمراحل
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';
import 'package:mahmoud_ai/screens/editor_screen.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _generationStarted = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // بدء التوليد تلقائياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startGeneration();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startGeneration() async {
    if (_generationStarted) return;
    _generationStarted = true;

    final provider = context.read<ProjectProvider>();
    final success = await provider.startGeneration();

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const EditorScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.lightBg,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // أيقونة متحركة
                _buildAnimatedIcon(isDark, projectProvider),
                const SizedBox(height: 32),
                // المرحلة الحالية
                _buildCurrentPhase(isDark, projectProvider),
                const SizedBox(height: 32),
                // شريط التقدم
                _buildProgressBar(isDark, projectProvider),
                const SizedBox(height: 32),
                // قائمة المراحل
                _buildPhasesList(isDark, projectProvider),
                const SizedBox(height: 24),
                // سجل الأخطاء
                if (projectProvider.currentProject?.errorLog.isNotEmpty ==
                    true)
                  _buildErrorLog(isDark, projectProvider),
                const SizedBox(height: 24),
                // رسالة الخطأ العامة
                if (projectProvider.error != null)
                  _buildErrorMessage(isDark, projectProvider.error!),
                const SizedBox(height: 24),
                // زر الإلغاء
                if (projectProvider.isGenerating)
                  GradientButton(
                    text: 'إلغاء التوليد',
                    icon: Icons.close_rounded,
                    isOutlined: true,
                    onPressed: () {
                      projectProvider.cancelGeneration();
                      Navigator.pop(context);
                    },
                  ),
                // زر إعادة المحاولة عند الفشل
                if (!projectProvider.isGenerating &&
                    projectProvider.error != null)
                  Column(
                    children: [
                      GradientButton(
                        text: 'إعادة المحاولة',
                        icon: Icons.refresh_rounded,
                        onPressed: () {
                          _generationStarted = false;
                          _startGeneration();
                        },
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        text: 'الرجوع',
                        icon: Icons.arrow_back_rounded,
                        isOutlined: true,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDark, ProjectProvider provider) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        final opacity = 0.5 + (_pulseController.value * 0.5);

        return Transform.scale(
          scale: provider.isGenerating ? scale : 1.0,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: provider.error != null
                  ? const LinearGradient(
                      colors: [AppTheme.error, Color(0xFFFF7043)])
                  : AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (provider.error != null
                          ? AppTheme.error
                          : AppTheme.primaryCyan)
                      .withOpacity(opacity * 0.3),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: provider.error != null
                  ? const Icon(Icons.error_outline_rounded,
                      color: Colors.white, size: 48)
                  : provider.currentPhase == GenerationPhase.done
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 48)
                      : const Text('⚡', style: TextStyle(fontSize: 44)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentPhase(bool isDark, ProjectProvider provider) {
    return Column(
      children: [
        Text(
          provider.isGenerating
              ? 'جارٍ التوليد...'
              : provider.error != null
                  ? 'حدث خطأ'
                  : 'اكتمل التوليد!',
          style: AppTheme.headingMedium.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          provider.currentPhase.nameAr,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryCyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(bool isDark, ProjectProvider provider) {
    final percent = (provider.progress * 100).toInt();

    return Column(
      children: [
        // النسبة المئوية
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            '$percent%',
            style: AppTheme.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // شريط التقدم
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              child: LinearProgressIndicator(
                value: provider.progress,
                backgroundColor: Colors.transparent,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                minHeight: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhasesList(bool isDark, ProjectProvider provider) {
    final phases = GenerationPhase.values
        .where((p) => p != GenerationPhase.done)
        .toList();
    final currentIndex = provider.currentPhase.index;

    return GlassCard(
      child: Column(
        children: phases.map((phase) {
          final isCompleted = phase.index < currentIndex;
          final isCurrent = phase.index == currentIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // أيقونة الحالة
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isCompleted || isCurrent
                        ? AppTheme.primaryGradient
                        : null,
                    color: isCompleted || isCurrent
                        ? null
                        : (isDark ? AppTheme.darkCardLight : AppTheme.lightCard),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 18)
                        : isCurrent
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              )
                            : Icon(Icons.circle,
                                color:
                                    isDark ? Colors.white12 : Colors.black12,
                                size: 8),
                  ),
                ),
                const SizedBox(width: 12),
                // اسم المرحلة
                Expanded(
                  child: Text(
                    phase.nameAr,
                    style: AppTheme.bodyMedium.copyWith(
                      color: isCompleted || isCurrent
                          ? (isDark ? Colors.white : const Color(0xFF1A1A2E))
                          : (isDark ? Colors.white30 : Colors.black38),
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                // حالة المرحلة
                if (isCompleted)
                  const Text(
                    '✓',
                    style: TextStyle(
                        color: AppTheme.success, fontSize: 16),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorLog(bool isDark, ProjectProvider provider) {
    final errors = provider.currentProject!.errorLog;
    return GlassCard(
      borderColor: AppTheme.warning.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppTheme.warning, size: 18),
              const SizedBox(width: 8),
              Text(
                'تنبيهات (${errors.length})',
                style: AppTheme.labelBold.copyWith(
                  color: AppTheme.warning,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...errors.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $e',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(bool isDark, String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.error, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
