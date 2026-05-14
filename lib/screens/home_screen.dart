// ============================================================================
// MAHMOUD TECH - Home Screen
// الصفحة الرئيسية مع الأزرار الأساسية
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/connectivity_banner.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/screens/new_project_screen.dart';
import 'package:mahmoud_ai/screens/projects_screen.dart';
import 'package:mahmoud_ai/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectProvider = context.watch<ProjectProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // شريط الاتصال
              const ConnectivityBanner(),
              // المحتوى الرئيسي
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // رأس الصفحة
                          _buildHeader(isDark),
                          const SizedBox(height: 32),
                          // زر مشروع جديد
                          _buildNewProjectCard(context, isDark),
                          const SizedBox(height: 16),
                          // آخر مشروع
                          if (projectProvider.lastProject != null)
                            _buildLastProjectCard(
                                context, isDark, projectProvider),
                          const SizedBox(height: 16),
                          // الأزرار السريعة
                          _buildQuickActions(context, isDark),
                          const SizedBox(height: 24),
                          // الإحصائيات
                          _buildStats(isDark, projectProvider),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        // الشعار
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryCyan.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🎬', style: TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 16),
        // النصوص
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  AppConstants.appName,
                  style: AppTheme.headingMedium.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Text(
                AppConstants.appDescription,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? Colors.white38 : Colors.black45,
                ),
              ),
            ],
          ),
        ),
        // زر الإعدادات
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withOpacity(0.8)
                  : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Icon(
              Icons.settings_rounded,
              color: isDark ? Colors.white54 : Colors.black54,
              size: 22,
            ),
          ),
          onPressed: () => Navigator.push(
            context,
            _buildPageRoute(const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildNewProjectCard(BuildContext context, bool isDark) {
    return GradientBorderCard(
      gradient: AppTheme.primaryGradient,
      onTap: () {
        final provider = context.read<ProjectProvider>();
        provider.createNewProject();
        Navigator.push(context, _buildPageRoute(const NewProjectScreen()));
      },
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مشروع جديد',
                  style: AppTheme.headingSmall.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ابدأ بتحويل السكريبت إلى فيديو احترافي',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppTheme.primaryCyan.withOpacity(0.5),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildLastProjectCard(
      BuildContext context, bool isDark, ProjectProvider provider) {
    final project = provider.lastProject!;
    return GlassCard(
      onTap: () {
        provider.setCurrentProject(project);
        Navigator.push(context, _buildPageRoute(const NewProjectScreen()));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                color: AppTheme.primaryGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'آخر مشروع',
                style: AppTheme.labelBold.copyWith(
                  color: AppTheme.primaryGold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(project.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  project.status.nameAr,
                  style: AppTheme.bodySmall.copyWith(
                    color: _getStatusColor(project.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.name,
            style: AppTheme.headingSmall.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${project.styleIcon} ${project.styleNameAr} • ${project.aspectRatio} • ${project.scenes.length} مشاهد',
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => Navigator.push(
              context,
              _buildPageRoute(const ProjectsScreen()),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: AppTheme.primaryPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'المشاريع السابقة',
                  style: AppTheme.labelBold.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            onTap: () => Navigator.push(
              context,
              _buildPageRoute(const SettingsScreen()),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppTheme.primaryGold,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'الإعدادات',
                  style: AppTheme.labelBold.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(bool isDark, ProjectProvider provider) {
    final total = provider.projects.length;
    final completed =
        provider.projects.where((p) => p.isCompleted).length;

    return GlassCard(
      child: Row(
        children: [
          _buildStatItem('إجمالي', '$total', AppTheme.primaryCyan, isDark),
          _buildDivider(isDark),
          _buildStatItem('مكتمل', '$completed', AppTheme.success, isDark),
          _buildDivider(isDark),
          _buildStatItem(
            'جارٍ',
            '${total - completed}',
            AppTheme.primaryGold,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(
              color: color,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return AppTheme.success;
      case ProjectStatus.generating:
      case ProjectStatus.analyzing:
        return AppTheme.primaryCyan;
      case ProjectStatus.failed:
        return AppTheme.error;
      case ProjectStatus.draft:
        return AppTheme.primaryGold;
    }
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.15, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
    );
  }
}
