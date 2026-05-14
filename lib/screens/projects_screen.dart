// ============================================================================
// MAHMOUD TECH - Projects Screen
// شاشة المشاريع السابقة
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/models/project_model.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/screens/new_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
              _buildAppBar(isDark),
              Expanded(
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: Curves.easeOut,
                  ),
                  child: projectProvider.projects.isEmpty
                      ? _buildEmptyState(isDark)
                      : _buildProjectsList(
                          isDark, projectProvider),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'المشاريع السابقة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withOpacity(0.5)
                  : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Center(
              child: Text('📂', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مشاريع بعد',
            style: AppTheme.headingSmall.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإنشاء مشروع جديد لتحويل\nالسكريبت إلى فيديو احترافي',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? Colors.white38 : Colors.black45,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<ProjectProvider>().createNewProject();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const NewProjectScreen()),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('مشروع جديد'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(bool isDark, ProjectProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.projects.length,
      itemBuilder: (context, index) {
        final project = provider.projects[index];
        return _buildProjectCard(isDark, project, provider, index);
      },
    );
  }

  Widget _buildProjectCard(
      bool isDark, ProjectModel project, ProjectProvider provider, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          provider.setCurrentProject(project);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NewProjectScreen()),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // أيقونة النمط
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: _getStatusGradient(project.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      project.styleIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTheme.labelBold.copyWith(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A2E),
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(project.updatedAt),
                        style: AppTheme.bodySmall.copyWith(
                          color: isDark ? Colors.white30 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
                // حالة المشروع
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        _getStatusColor(project.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        project.status.icon,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        project.status.nameAr,
                        style: AppTheme.bodySmall.copyWith(
                          color: _getStatusColor(project.status),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // معلومات إضافية
            Row(
              children: [
                _buildTag(project.styleNameAr, isDark),
                const SizedBox(width: 8),
                _buildTag(project.aspectRatio, isDark),
                const SizedBox(width: 8),
                _buildTag('${project.scenes.length} مشاهد', isDark),
                const Spacer(),
                // زر حذف
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppTheme.error.withOpacity(0.5),
                  ),
                  onPressed: () => _confirmDelete(context, provider, project),
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            // شريط التقدم
            if (project.status == ProjectStatus.generating) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: project.progress,
                  backgroundColor:
                      isDark ? AppTheme.darkCardLight : AppTheme.lightBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryCyan),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCardLight.withOpacity(0.5)
            : AppTheme.lightBorder.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: isDark ? Colors.white38 : Colors.black38,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(date);
    } catch (_) {
      return '${date.year}/${date.month}/${date.day}';
    }
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

  LinearGradient _getStatusGradient(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.completed:
        return const LinearGradient(
            colors: [AppTheme.success, Color(0xFF00C853)]);
      case ProjectStatus.generating:
      case ProjectStatus.analyzing:
        return AppTheme.primaryGradient;
      case ProjectStatus.failed:
        return const LinearGradient(
            colors: [AppTheme.error, Color(0xFFFF7043)]);
      case ProjectStatus.draft:
        return AppTheme.goldGradient;
    }
  }

  void _confirmDelete(
      BuildContext context, ProjectProvider provider, ProjectModel project) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('حذف المشروع', style: AppTheme.headingSmall),
        content: Text(
          'هل أنت متأكد من حذف "${project.name}"؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteProject(project.id);
              Navigator.pop(ctx);
            },
            child: const Text('حذف', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
