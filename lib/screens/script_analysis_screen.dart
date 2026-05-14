// ============================================================================
// MAHMOUD TECH - Script Analysis Screen
// شاشة عرض تحليل السكريبت والمشاهد المستخرجة
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:mahmoud_ai/providers/app_provider.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';
import 'package:mahmoud_ai/widgets/scene_card.dart';
import 'package:mahmoud_ai/screens/generation_screen.dart';

class ScriptAnalysisScreen extends StatefulWidget {
  const ScriptAnalysisScreen({super.key});

  @override
  State<ScriptAnalysisScreen> createState() => _ScriptAnalysisScreenState();
}

class _ScriptAnalysisScreenState extends State<ScriptAnalysisScreen>
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
    final appProvider = context.watch<AppProvider>();
    final project = projectProvider.currentProject;

    if (project == null) {
      return const Scaffold(
        body: Center(child: Text('لا يوجد مشروع محدد')),
      );
    }

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ملخص التحليل
                        _buildSummaryCard(isDark, project.summary ?? ''),
                        const SizedBox(height: 20),
                        // معلومات المشروع
                        _buildProjectInfo(isDark, project),
                        const SizedBox(height: 24),
                        // عنوان المشاهد
                        Row(
                          children: [
                            const Text('🎬', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Text(
                              'المشاهد (${project.scenes.length})',
                              style: AppTheme.headingSmall.copyWith(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${project.totalDuration.toStringAsFixed(1)} ث',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.primaryCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // قائمة المشاهد
                        ...List.generate(project.scenes.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SceneCard(
                              scene: project.scenes[index],
                              index: index,
                              isEditable: true,
                              onEdit: () =>
                                  _editScene(context, index, project.scenes[index]),
                              onDelete: () {
                                projectProvider.removeScene(index);
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                        // زر بدء التوليد
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            text: 'بدء التوليد',
                            emoji: '🚀',
                            gradient: AppTheme.goldGradient,
                            onPressed: !appProvider.isConnected ||
                                    project.scenes.isEmpty
                                ? null
                                : () => _startGeneration(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // زر إعادة التحليل
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            text: 'إعادة التحليل',
                            icon: Icons.refresh_rounded,
                            isOutlined: true,
                            onPressed: projectProvider.isLoading
                                ? null
                                : () async {
                                    await projectProvider.analyzeScript();
                                  },
                            isLoading: projectProvider.isLoading,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
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
              'تحليل السكريبت',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark, String summary) {
    return GlassCard(
      borderColor: AppTheme.primaryCyan.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppTheme.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'ملخص التحليل',
                style: AppTheme.labelBold.copyWith(
                  color: AppTheme.primaryCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.isNotEmpty ? summary : 'تم تحليل السكريبت بنجاح',
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfo(bool isDark, dynamic project) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _buildInfoChip(
            project.styleIcon,
            project.styleNameAr,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildInfoChip(
            '📐',
            project.aspectRatio,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildInfoChip(
            '📝',
            '${project.wordCount} كلمة',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String emoji, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTheme.bodySmall.copyWith(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  void _editScene(BuildContext context, int index, SceneModel scene) {
    final titleController = TextEditingController(text: scene.title);
    final descController = TextEditingController(text: scene.description);
    final durationController =
        TextEditingController(text: scene.duration.toString());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // مقبض السحب
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تعديل المشهد ${index + 1}',
                style: AppTheme.headingSmall.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'عنوان المشهد'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'وصف المشهد'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'المدة (بالثواني)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GradientButton(
                  text: 'حفظ التعديلات',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    final provider = context.read<ProjectProvider>();
                    provider.updateScene(
                      index,
                      scene.copyWith(
                        title: titleController.text,
                        description: descController.text,
                        duration: double.tryParse(durationController.text) ??
                            scene.duration,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _startGeneration(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GenerationScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
