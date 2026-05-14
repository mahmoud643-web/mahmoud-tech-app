// ============================================================================
// MAHMOUD TECH - Editor Screen
// شاشة المونتاج المصغرة - التايم لاين وتعديل المشاهد
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/models/project_model.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';
import 'package:mahmoud_ai/screens/preview_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  int _selectedSceneIndex = 0;
  final ScrollController _timelineController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectProvider = context.watch<ProjectProvider>();
    final project = projectProvider.currentProject;

    if (project == null) return const Scaffold();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isDark),
              _buildPreviewArea(project, isDark),
              const Divider(height: 1, color: Colors.white10),
              _buildTimeline(project, isDark),
              _buildSceneEditor(project, isDark, projectProvider),
              _buildBottomActions(context, projectProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'استوديو المونتاج الذكي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildPreviewArea(ProjectModel project, bool isDark) {
    final currentScene = project.scenes[_selectedSceneIndex];
    final imageBytes = context.read<ProjectProvider>().generatedImages[currentScene.id];

    return Expanded(
      flex: 5,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryCyan.withOpacity(0.1),
              blurRadius: 30,
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (imageBytes != null)
                Image.memory(imageBytes, fit: BoxFit.contain, width: double.infinity)
              else
                const Icon(Icons.image_outlined, size: 50, color: Colors.white24),
              
              // كابشن تجريبي (Preview)
              if (project.captions.isNotEmpty)
                const Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: _CaptionPreview(),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTimeline(ProjectModel project, bool isDark) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.white24,
      ),
      child: ListView.builder(
        controller: _timelineController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: project.scenes.length,
        itemBuilder: (context, index) {
          final scene = project.scenes[index];
          final isSelected = _selectedSceneIndex == index;
          final img = context.read<ProjectProvider>().generatedImages[scene.id];

          return GestureDetector(
            onTap: () => setState(() => _selectedSceneIndex = index),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryCyan : Colors.white10,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primaryCyan.withOpacity(0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: img != null
                        ? Image.memory(img, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 20, color: Colors.white24),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${scene.duration} ث',
                  style: AppTheme.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSceneEditor(ProjectModel project, bool isDark, ProjectProvider provider) {
    final scene = project.scenes[_selectedSceneIndex];

    return Expanded(
      flex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text('تعديل المشهد رقم ${_selectedSceneIndex + 1}',
                    style: AppTheme.headingSmall.copyWith(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTransitionSelector(scene, provider),
            const SizedBox(height: 16),
            _buildDurationSlider(scene, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionSelector(SceneModel scene, ProjectProvider provider) {
    final transitions = [
      {'id': 'fade', 'name': 'Fade', 'icon': '🌫️'},
      {'id': 'slide', 'name': 'Slide', 'icon': '➡️'},
      {'id': 'zoom', 'name': 'Zoom', 'icon': '🔍'},
      {'id': 'none', 'name': 'None', 'icon': '🚫'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الانتقال (Transition)', style: AppTheme.labelBold.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: transitions.map((t) {
            final isSelected = scene.transition == t['id'];
            return ChoiceChip(
              label: Text(t['name']!),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  provider.updateScene(_selectedSceneIndex, scene.copyWith(transition: t['id']!));
                }
              },
              selectedColor: AppTheme.primaryCyan.withOpacity(0.2),
              labelStyle: TextStyle(color: isSelected ? AppTheme.primaryCyan : Colors.white70),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDurationSlider(SceneModel scene, ProjectProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('مدة المشهد', style: AppTheme.labelBold.copyWith(fontSize: 13)),
            Text('${scene.duration.toStringAsFixed(1)} ثانية',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryCyan)),
          ],
        ),
        Slider(
          value: scene.duration,
          min: 2.0,
          max: 10.0,
          divisions: 16,
          activeColor: AppTheme.primaryCyan,
          onChanged: (val) {
            provider.updateScene(_selectedSceneIndex, scene.copyWith(duration: val));
          },
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, ProjectProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: GradientButton(
          text: 'معاينة وتصدير الفيديو النهائي',
          icon: Icons.auto_fix_high_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreviewScreen()),
            );
          },
        ),
      ),
    );
  }
}

class _CaptionPreview extends StatelessWidget {
  const _CaptionPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'نص الكابشن يظهر هنا بشكل احترافي',
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
