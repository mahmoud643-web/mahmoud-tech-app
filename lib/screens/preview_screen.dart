// ============================================================================
// MAHMOUD TECH - Preview Screen
// شاشة معاينة الفيديو النهائي مع خيارات التصدير
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';
import 'package:mahmoud_ai/widgets/scene_card.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentSceneIndex = 0;
  bool _isPlaying = false;
  bool _audioReady = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animController.forward();
    
    // إعداد الصوت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupAudio();
    });
  }

  Future<void> _setupAudio() async {
    final provider = context.read<ProjectProvider>();
    final audioBytes = provider.projectAudio;
    if (audioBytes != null && audioBytes.isNotEmpty) {
      await _audioPlayer.setSourceBytes(audioBytes);
      _audioReady = true;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectProvider = context.watch<ProjectProvider>();
    final project = projectProvider.currentProject;

    if (project == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد مشروع')));
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
                        // شارة النجاح
                        _buildSuccessBanner(isDark),
                        const SizedBox(height: 20),
                        // عرض الفيديو / الصور
                        _buildVideoPreview(isDark, projectProvider),
                        const SizedBox(height: 16),
                        // أزرار التحكم
                        _buildPlaybackControls(isDark, projectProvider),
                        const SizedBox(height: 24),
                        // معلومات الفيديو
                        _buildVideoInfo(isDark, project),
                        const SizedBox(height: 24),
                        // أزرار التصدير
                        _buildExportButtons(isDark),
                        const SizedBox(height: 24),
                        // قائمة المشاهد
                        Row(
                          children: [
                            const Text('🎬', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'المشاهد المُنتجة (${project.scenes.length})',
                              style: AppTheme.headingSmall.copyWith(
                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(project.scenes.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SceneCard(
                              scene: project.scenes[index],
                              index: index,
                              imageBytes: projectProvider.getSceneImage(
                                  project.scenes[index].id),
                              isEditable: false,
                            ),
                          );
                        }),
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
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
          ),
          const Expanded(
            child: Text(
              'معاينة الفيديو',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.success.withOpacity(0.1),
            AppTheme.primaryCyan.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.success,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تم إنتاج الفيديو بنجاح! 🎉',
                  style: AppTheme.labelBold.copyWith(
                    color: AppTheme.success,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'يمكنك مراجعة المشاهد وتصدير الفيديو',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white38 : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview(bool isDark, ProjectProvider provider) {
    final project = provider.currentProject!;
    Uint8List? currentImage;

    if (project.scenes.isNotEmpty && _currentSceneIndex < project.scenes.length) {
      currentImage =
          provider.getSceneImage(project.scenes[_currentSceneIndex].id);
    }

    final isVertical = project.aspectRatio == '9:16';
    final previewHeight = isVertical ? 420.0 : 240.0;

    return Container(
      width: double.infinity,
      height: previewHeight,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة الحالية
            if (currentImage != null && currentImage.length > 100)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.memory(
                  currentImage,
                  key: ValueKey(_currentSceneIndex),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderPreview(isDark),
                ),
              )
            else
              _buildPlaceholderPreview(isDark),
            // رقم المشهد
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'المشهد ${_currentSceneIndex + 1}/${project.scenes.length}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // عنوان المشهد
            if (project.scenes.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Text(
                    project.scenes[_currentSceneIndex].title,
                    style: AppTheme.labelBold.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            // زر التشغيل
            Center(
              child: GestureDetector(
                onTap: _togglePlayback,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderPreview(bool isDark) {
    return Container(
      color: isDark ? AppTheme.darkCardLight : AppTheme.lightCard,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'معاينة الفيديو',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls(bool isDark, ProjectProvider provider) {
    final scenesCount = provider.currentProject?.scenes.length ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.skip_previous_rounded,
              color: isDark ? Colors.white54 : Colors.black54, size: 32),
          onPressed: _currentSceneIndex > 0
              ? () => setState(() => _currentSceneIndex--)
              : null,
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryCyan.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(Icons.skip_next_rounded,
              color: isDark ? Colors.white54 : Colors.black54, size: 32),
          onPressed: _currentSceneIndex < scenesCount - 1
              ? () => setState(() => _currentSceneIndex++)
              : null,
        ),
      ],
    );
  }

  Widget _buildVideoInfo(bool isDark, dynamic project) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('المشاهد', '${project.scenes.length}',
              AppTheme.primaryCyan, isDark),
          _buildInfoItem('المدة', '${project.totalDuration.toStringAsFixed(1)} ث',
              AppTheme.primaryGold, isDark),
          _buildInfoItem('الأبعاد', project.aspectRatio,
              AppTheme.primaryPurple, isDark),
          _buildInfoItem('النمط', project.styleIcon,
              AppTheme.success, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.labelBold.copyWith(color: color, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: isDark ? Colors.white38 : Colors.black45,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButtons(bool isDark) {
    return Column(
      children: [
        // زر حفظ
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'حفظ الفيديو',
            icon: Icons.save_alt_rounded,
            gradient: AppTheme.goldGradient,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سيتم دعم تصدير الفيديو في الإصدار القادم',
                      style: AppTheme.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppTheme.info.withOpacity(0.9),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GradientButton(
                text: 'مشاركة',
                icon: Icons.share_rounded,
                isOutlined: true,
                height: 48,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('المشاركة ستكون متاحة قريباً',
                          style: AppTheme.bodySmall.copyWith(color: Colors.white)),
                      backgroundColor: AppTheme.info.withOpacity(0.9),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GradientButton(
                text: 'إعادة التوليد',
                icon: Icons.refresh_rounded,
                isOutlined: true,
                height: 48,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _togglePlayback() {
    final provider = context.read<ProjectProvider>();
    final scenesCount = provider.currentProject?.scenes.length ?? 0;

    if (_isPlaying) {
      setState(() => _isPlaying = false);
      if (_audioReady) _audioPlayer.pause();
    } else {
      setState(() => _isPlaying = true);
      if (_currentSceneIndex >= scenesCount - 1) {
        _currentSceneIndex = 0;
        if (_audioReady) _audioPlayer.seek(Duration.zero);
      }
      if (_audioReady) _audioPlayer.resume();
      _autoPlay(scenesCount);
    }
  }

  void _autoPlay(int total) async {
    for (int i = _currentSceneIndex; i < total && _isPlaying; i++) {
      if (!mounted) return;
      setState(() => _currentSceneIndex = i);
      final project = context.read<ProjectProvider>().currentProject;
      final duration = project?.scenes[i].duration ?? 4.0;
      await Future.delayed(Duration(milliseconds: (duration * 1000).toInt()));
    }
    if (mounted) {
      setState(() => _isPlaying = false);
      if (_audioReady) _audioPlayer.stop();
    }
  }
}
