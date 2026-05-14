// ============================================================================
// MAHMOUD TECH - New Project Screen
// شاشة إنشاء مشروع جديد - كتابة السكريبت واختيار الإعدادات
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/app_provider.dart';
import 'package:mahmoud_ai/providers/project_provider.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';
import 'package:mahmoud_ai/screens/script_analysis_screen.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _scriptController;
  late TextEditingController _nameController;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  String _selectedAspectRatio = '9:16';
  String _selectedStyle = 'cinematic';
  String _selectedVoiceId = 'pNInz6OB8ntYPLMCSXT6';
  String _selectedCaptionStyle = 'dynamic';

  @override
  void initState() {
    super.initState();
    final project = context.read<ProjectProvider>().currentProject;
    _scriptController = TextEditingController(text: project?.script ?? '');
    _nameController = TextEditingController(text: project?.name ?? 'مشروع جديد');
    _selectedAspectRatio = project?.aspectRatio ?? '9:16';
    _selectedStyle = project?.style ?? 'cinematic';
    _selectedVoiceId = project?.voiceId ?? 'pNInz6OB8ntYPLMCSXT6';
    _selectedCaptionStyle = project?.captionStyle ?? 'dynamic';

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _scriptController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  int get _wordCount {
    final text = _scriptController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get _estimatedScenes {
    final wc = _wordCount;
    if (wc < 20) return 0;
    return (wc / 30).ceil().clamp(AppConstants.minScenes, AppConstants.maxScenes);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectProvider = context.watch<ProjectProvider>();
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : null,
          color: isDark ? null : AppTheme.lightBg,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // الشريط العلوي
              _buildAppBar(isDark),
              // المحتوى
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // اسم المشروع
                        _buildProjectName(isDark),
                        const SizedBox(height: 20),
                        // منطقة كتابة السكريبت
                        _buildScriptArea(isDark),
                        const SizedBox(height: 20),
                        // إحصائيات النص
                        _buildTextStats(isDark),
                        const SizedBox(height: 24),
                        // اختيار الأبعاد
                        _buildSectionTitle('أبعاد الفيديو', '📐', isDark),
                        const SizedBox(height: 12),
                        _buildAspectRatioSelector(isDark),
                        const SizedBox(height: 24),
                        // اختيار النمط
                        _buildSectionTitle('أسلوب الفيديو', '🎨', isDark),
                        const SizedBox(height: 12),
                        _buildStyleSelector(isDark),
                        const SizedBox(height: 24),
                        // التعليق الصوتي
                        _buildSectionTitle('التعليق الصوتي', '🎙️', isDark),
                        const SizedBox(height: 12),
                        _buildVoiceSelector(isDark),
                        const SizedBox(height: 24),
                        // الكابشنز
                        _buildSectionTitle('الكابشنز (Subtitles)', '💬', isDark),
                        const SizedBox(height: 12),
                        _buildCaptionSelector(isDark),
                        const SizedBox(height: 32),
                        // الأزرار
                        _buildActionButtons(
                            context, isDark, projectProvider, appProvider),
                        const SizedBox(height: 32),
                        // رسالة الخطأ
                        if (projectProvider.error != null)
                          _buildErrorMessage(projectProvider.error!, isDark),
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
            onPressed: () {
              // حفظ كمسودة قبل الرجوع
              _saveState();
              Navigator.pop(context);
            },
          ),
          const Expanded(
            child: Text(
              'مشروع جديد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          // زر حفظ مسودة
          TextButton.icon(
            onPressed: () async {
              _saveState();
              await context.read<ProjectProvider>().saveDraft();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ المسودة',
                      style: AppTheme.bodySmall),
                  backgroundColor: AppTheme.success.withOpacity(0.9),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.save_outlined,
                size: 18, color: AppTheme.primaryCyan),
            label: Text(
              'حفظ',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectName(bool isDark) {
    return TextField(
      controller: _nameController,
      style: AppTheme.headingSmall.copyWith(
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
      decoration: InputDecoration(
        hintText: 'اسم المشروع...',
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Text('🎬', style: TextStyle(fontSize: 20)),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: isDark
            ? AppTheme.darkCard.withOpacity(0.5)
            : AppTheme.lightCard,
      ),
      onChanged: (_) => _saveState(),
    );
  }

  Widget _buildScriptArea(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildSectionTitle('السكريبت', '📝', isDark),
            const Spacer(),
            // زر لصق
            TextButton.icon(
              onPressed: () async {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (data?.text != null) {
                  _scriptController.text = data!.text!;
                  setState(() {});
                  _saveState();
                }
              },
              icon: const Icon(Icons.paste_rounded,
                  size: 16, color: AppTheme.primaryCyan),
              label: Text(
                'لصق',
                style: AppTheme.bodySmall
                    .copyWith(color: AppTheme.primaryCyan),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkCard.withOpacity(0.5)
                : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppTheme.darkBorder.withOpacity(0.5)
                  : AppTheme.lightBorder,
            ),
          ),
          child: TextField(
            controller: _scriptController,
            maxLines: 10,
            minLines: 6,
            style: AppTheme.bodyLarge.copyWith(
              color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              height: 1.8,
            ),
            decoration: const InputDecoration(
              hintText: 'اكتب السكريبت هنا...\n\nمثال: في قلب الصحراء العربية، حيث تلتقي الرمال الذهبية بالسماء الزرقاء، تقع مدينة قديمة نسيها الزمن...',
              hintMaxLines: 5,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(20),
            ),
            onChanged: (_) {
              setState(() {});
              _saveState();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextStats(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          _buildStatChip(
            Icons.text_fields_rounded,
            '$_wordCount كلمة',
            _wordCount >= AppConstants.minScriptWords
                ? AppTheme.success
                : AppTheme.warning,
            isDark,
          ),
          const SizedBox(width: 16),
          _buildStatChip(
            Icons.movie_creation_outlined,
            '$_estimatedScenes مشاهد متوقعة',
            AppTheme.primaryCyan,
            isDark,
          ),
          const Spacer(),
          // نسبة الاكتمال
          if (_wordCount > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _wordCount >= AppConstants.minScriptWords
                    ? AppTheme.success.withOpacity(0.15)
                    : AppTheme.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _wordCount >= AppConstants.minScriptWords ? 'جاهز ✓' : 'قصير',
                style: AppTheme.bodySmall.copyWith(
                  color: _wordCount >= AppConstants.minScriptWords
                      ? AppTheme.success
                      : AppTheme.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      IconData icon, String text, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
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

  Widget _buildAspectRatioSelector(bool isDark) {
    final ratios = ['9:16', '16:9', '1:1'];
    final labels = ['طولي', 'عرضي', 'مربع'];
    final icons = [Icons.stay_current_portrait, Icons.stay_current_landscape, Icons.crop_square];

    return Row(
      children: List.generate(ratios.length, (i) {
        final isSelected = _selectedAspectRatio == ratios[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i < ratios.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedAspectRatio = ratios[i]);
                _saveState();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? AppTheme.darkCard.withOpacity(0.5)
                          : AppTheme.lightCard),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark
                            ? AppTheme.darkBorder.withOpacity(0.5)
                            : AppTheme.lightBorder),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryCyan.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      icons[i],
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white38 : Colors.black38),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: AppTheme.labelBold.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white54 : Colors.black54),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ratios[i],
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected
                            ? Colors.white70
                            : (isDark ? Colors.white24 : Colors.black26),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVoiceSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.voiceOptions.map((voice) {
        final isSelected = _selectedVoiceId == voice['id'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedVoiceId = voice['id']!);
            _saveState();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? AppTheme.darkCard.withOpacity(0.5)
                      : AppTheme.lightCard),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                        ? AppTheme.darkBorder.withOpacity(0.5)
                        : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(voice['icon']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  voice['name']!,
                  style: AppTheme.labelBold.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCaptionSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.captionStyles.map((style) {
        final isSelected = _selectedCaptionStyle == style['id'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedCaptionStyle = style['id']!);
            _saveState();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? AppTheme.darkCard.withOpacity(0.5)
                      : AppTheme.lightCard),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                        ? AppTheme.darkBorder.withOpacity(0.5)
                        : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(style['icon']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  style['name']!,
                  style: AppTheme.labelBold.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStyleSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.videoStyles.map((style) {
        final isSelected = _selectedStyle == style['id'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedStyle = style['id']!);
            _saveState();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isSelected ? AppTheme.primaryGradient : null,
              color: isSelected
                  ? null
                  : (isDark
                      ? AppTheme.darkCard.withOpacity(0.5)
                      : AppTheme.lightCard),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                        ? AppTheme.darkBorder.withOpacity(0.5)
                        : AppTheme.lightBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(style['icon']!, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  style['name']!,
                  style: AppTheme.labelBold.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white60 : Colors.black54),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark,
      ProjectProvider projectProvider, AppProvider appProvider) {
    return Column(
      children: [
        // زر تحليل السكريبت
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'تحليل السكريبت',
            icon: Icons.psychology_rounded,
            isLoading: projectProvider.isLoading,
            onPressed: !appProvider.isConnected ||
                    _wordCount < AppConstants.minScriptWords ||
                    projectProvider.isLoading
                ? null
                : () => _analyzeScript(context),
          ),
        ),
        const SizedBox(height: 12),
        // زر حفظ مسودة
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            text: 'حفظ كمسودة',
            icon: Icons.save_outlined,
            isOutlined: true,
            onPressed: () async {
              _saveState();
              await context.read<ProjectProvider>().saveDraft();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حفظ المسودة بنجاح ✓',
                      style: AppTheme.bodySmall.copyWith(color: Colors.white)),
                  backgroundColor: AppTheme.success.withOpacity(0.9),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error, bool isDark) {
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
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppTheme.error),
            onPressed: () => context.read<ProjectProvider>().clearError(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.headingSmall.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  void _saveState() {
    final provider = context.read<ProjectProvider>();
    provider.updateCurrentProject(
      script: _scriptController.text.trim(),
      name: _nameController.text.trim(),
      aspectRatio: _selectedAspectRatio,
      style: _selectedStyle,
      voiceId: _selectedVoiceId,
      captionStyle: _selectedCaptionStyle,
    );
  }

  Future<void> _analyzeScript(BuildContext context) async {
    _saveState();
    final provider = context.read<ProjectProvider>();
    final success = await provider.analyzeScript();

    if (success && context.mounted) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ScriptAnalysisScreen(),
          transitionDuration: const Duration(milliseconds: 400),
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
        ),
      );
    }
  }
}
