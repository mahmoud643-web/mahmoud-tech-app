// ============================================================================
// MAHMOUD TECH - Settings Screen
// شاشة الإعدادات - مفاتيح API، الثيم، اللغة، الكاش
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mahmoud_ai/constants/app_constants.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/providers/app_provider.dart';
import 'package:mahmoud_ai/services/storage_service.dart';
import 'package:mahmoud_ai/services/groq_service.dart';
import 'package:mahmoud_ai/services/image_generation_service.dart';
import 'package:mahmoud_ai/services/audio_service.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';
import 'package:mahmoud_ai/widgets/gradient_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late TextEditingController _groqKeyController;
  late TextEditingController _imageKeyController;
  late TextEditingController _audioKeyController;
  bool _groqKeyVisible = false;
  bool _imageKeyVisible = false;
  bool _audioKeyVisible = false;
  bool _testingGroq = false;
  bool _testingImage = false;
  bool _testingAudio = false;
  String? _groqTestResult;
  String? _imageTestResult;
  String? _audioTestResult;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();

    _groqKeyController = TextEditingController();
    _imageKeyController = TextEditingController();
    _audioKeyController = TextEditingController();
    _loadKeys();
  }

  Future<void> _loadKeys() async {
    final storage = await StorageService.getInstance();
    _groqKeyController.text = storage.getGroqApiKey();
    _imageKeyController.text = storage.getImageApiKey();
    _audioKeyController.text = storage.getAudioApiKey();
  }

  @override
  void dispose() {
    _animController.dispose();
    _groqKeyController.dispose();
    _imageKeyController.dispose();
    _audioKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                        // مفاتيح API
                        _buildSectionTitle('مفاتيح API', '🔑', isDark),
                        const SizedBox(height: 12),
                        _buildGroqApiCard(isDark),
                        const SizedBox(height: 12),
                        _buildImageApiCard(isDark),
                        const SizedBox(height: 12),
                        _buildAudioApiCard(isDark),
                        const SizedBox(height: 28),
                        // المظهر
                        _buildSectionTitle('المظهر', '🎨', isDark),
                        const SizedBox(height: 12),
                        _buildThemeCard(isDark, appProvider),
                        const SizedBox(height: 28),
                        // اللغة
                        _buildSectionTitle('اللغة', '🌐', isDark),
                        const SizedBox(height: 12),
                        _buildLanguageCard(isDark, appProvider),
                        const SizedBox(height: 28),
                        // الاتصال
                        _buildSectionTitle('الاتصال', '📡', isDark),
                        const SizedBox(height: 12),
                        _buildConnectionCard(isDark, appProvider),
                        const SizedBox(height: 28),
                        // الكاش
                        _buildSectionTitle('البيانات', '🗄️', isDark),
                        const SizedBox(height: 12),
                        _buildCacheCard(isDark),
                        const SizedBox(height: 28),
                        // معلومات التطبيق
                        _buildAboutCard(isDark),
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
              'الإعدادات',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji, bool isDark) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.headingSmall.copyWith(
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  // ==================== مفاتيح API ====================

  Widget _buildGroqApiCard(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.psychology_rounded,
                    color: AppTheme.primaryCyan, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Groq API - تحليل النص',
                      style: AppTheme.labelBold.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'لفهم وتحليل السكريبت وتقسيمه إلى مشاهد',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _groqKeyController,
            obscureText: !_groqKeyVisible,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'أدخل مفتاح Groq API...',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _groqKeyVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                    onPressed: () =>
                        setState(() => _groqKeyVisible = !_groqKeyVisible),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_rounded,
                        size: 20, color: AppTheme.primaryCyan),
                    onPressed: () => _saveGroqKey(),
                  ),
                ],
              ),
            ),
          ),
          // نتيجة الاختبار
          if (_groqTestResult != null) ...[
            const SizedBox(height: 8),
            _buildTestResult(_groqTestResult!),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'اختبار الاتصال',
              icon: Icons.wifi_tethering_rounded,
              height: 42,
              isLoading: _testingGroq,
              onPressed: _testingGroq ? null : () => _testGroqConnection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageApiCard(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image_rounded,
                    color: AppTheme.primaryPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image API - توليد الصور',
                      style: AppTheme.labelBold.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'لإنتاج صور المشاهد من الأوصاف البصرية',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _imageKeyController,
            obscureText: !_imageKeyVisible,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'أدخل مفتاح Image API...',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _imageKeyVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: isDark ? Colors.white30 : Colors.black38,
                    ),
                    onPressed: () =>
                        setState(() => _imageKeyVisible = !_imageKeyVisible),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_rounded,
                        size: 20, color: AppTheme.primaryPurple),
                    onPressed: () => _saveImageKey(),
                  ),
                ],
              ),
            ),
          ),
          if (_imageTestResult != null) ...[
            const SizedBox(height: 8),
            _buildTestResult(_imageTestResult!),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'اختبار الاتصال',
              icon: Icons.wifi_tethering_rounded,
              height: 42,
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.accentPurple]),
              isLoading: _testingImage,
              onPressed: _testingImage ? null : () => _testImageConnection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioApiCard(bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.record_voice_over_rounded,
                    color: AppTheme.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ElevenLabs API - توليد الصوت',
                      style: AppTheme.labelBold.copyWith(
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      'لتحويل السكريبت إلى تعليق صوتي احترافي',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _audioKeyController,
            obscureText: !_audioKeyVisible,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'أدخل مفتاح ElevenLabs API...',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _audioKeyVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    onPressed: () =>
                        setState(() => _audioKeyVisible = !_audioKeyVisible),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_rounded,
                        size: 20, color: AppTheme.success),
                    onPressed: () => _saveAudioKey(),
                  ),
                ],
              ),
            ),
          ),
          if (_audioTestResult != null) ...[
            const SizedBox(height: 8),
            _buildTestResult(_audioTestResult!),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: GradientButton(
              text: 'اختبار الاتصال',
              icon: Icons.wifi_tethering_rounded,
              height: 42,
              gradient: const LinearGradient(
                  colors: [AppTheme.success, Color(0xFF00C853)]),
              isLoading: _testingAudio,
              onPressed: _testingAudio ? null : () => _testAudioConnection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestResult(String result) {
    final isSuccess = result.contains('نجح');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isSuccess ? AppTheme.success : AppTheme.error).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error_outline,
            size: 16,
            color: isSuccess ? AppTheme.success : AppTheme.error,
          ),
          const SizedBox(width: 6),
          Text(
            result,
            style: AppTheme.bodySmall.copyWith(
              color: isSuccess ? AppTheme.success : AppTheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== المظهر ====================

  Widget _buildThemeCard(bool isDark, AppProvider appProvider) {
    return GlassCard(
      child: Row(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            color: isDark ? AppTheme.primaryGold : AppTheme.primaryCyan,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
              style: AppTheme.labelBold.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) => appProvider.toggleDarkMode(),
            activeColor: AppTheme.primaryCyan,
          ),
        ],
      ),
    );
  }

  // ==================== اللغة ====================

  Widget _buildLanguageCard(bool isDark, AppProvider appProvider) {
    return GlassCard(
      child: Column(
        children: AppConstants.supportedLanguages.map((lang) {
          final isSelected = appProvider.language == lang['code'];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryCyan.withOpacity(0.15)
                      : (isDark ? AppTheme.darkCardLight : AppTheme.lightCard),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    lang['code'] == 'ar' ? '🇸🇦' : '🇺🇸',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              title: Text(
                lang['name']!,
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: AppTheme.primaryCyan, size: 22)
                  : null,
              onTap: () => appProvider.setLanguage(lang['code']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==================== الاتصال ====================

  Widget _buildConnectionCard(bool isDark, AppProvider appProvider) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (appProvider.isConnected
                      ? AppTheme.success
                      : AppTheme.error)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              appProvider.isConnected
                  ? Icons.wifi_rounded
                  : Icons.wifi_off_rounded,
              color: appProvider.isConnected
                  ? AppTheme.success
                  : AppTheme.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appProvider.isConnected ? 'متصل بالإنترنت' : 'غير متصل',
                  style: AppTheme.labelBold.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  appProvider.isConnected
                      ? 'جميع الخدمات متاحة'
                      : 'تحقق من اتصالك بالإنترنت',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark ? Colors.white30 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTheme.primaryCyan),
            onPressed: () => appProvider.checkConnection(),
          ),
        ],
      ),
    );
  }

  // ==================== الكاش ====================

  Widget _buildCacheCard(bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cleaning_services_rounded,
                  color: AppTheme.warning, size: 20),
            ),
            title: Text(
              'مسح الكاش',
              style: AppTheme.bodyMedium.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            subtitle: Text(
              'حذف الملفات المؤقتة مع الحفاظ على الإعدادات',
              style: AppTheme.bodySmall.copyWith(
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isDark ? Colors.white24 : Colors.black26),
            onTap: () => _clearCache(),
          ),
          Divider(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
            height: 1,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  color: AppTheme.error, size: 20),
            ),
            title: Text(
              'مسح جميع البيانات',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.error,
              ),
            ),
            subtitle: Text(
              'حذف كل البيانات بما فيها المشاريع والإعدادات',
              style: AppTheme.bodySmall.copyWith(
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
            onTap: () => _clearAll(),
          ),
        ],
      ),
    );
  }

  // ==================== معلومات التطبيق ====================

  Widget _buildAboutCard(bool isDark) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('🎬', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: Text(
                        AppConstants.appName,
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      'الإصدار ${AppConstants.appVersion}',
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.appDescription,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== الإجراءات ====================

  Future<void> _saveGroqKey() async {
    final storage = await StorageService.getInstance();
    await storage.saveGroqApiKey(_groqKeyController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ مفتاح Groq API ✓',
            style: AppTheme.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.success.withOpacity(0.9),
      ),
    );
  }

  Future<void> _saveImageKey() async {
    final storage = await StorageService.getInstance();
    await storage.saveImageApiKey(_imageKeyController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ مفتاح Image API ✓',
            style: AppTheme.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.success.withOpacity(0.9),
      ),
    );
  }

  Future<void> _saveAudioKey() async {
    final storage = await StorageService.getInstance();
    await storage.saveAudioApiKey(_audioKeyController.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ مفتاح Audio API ✓',
            style: AppTheme.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.success.withOpacity(0.9),
      ),
    );
  }

  Future<void> _testGroqConnection() async {
    await _saveGroqKey();
    setState(() {
      _testingGroq = true;
      _groqTestResult = null;
    });

    final success =
        await GroqService().testConnection(_groqKeyController.text.trim());

    setState(() {
      _testingGroq = false;
      _groqTestResult = success ? 'نجح الاتصال ✓' : 'فشل الاتصال ✗';
    });
  }

  Future<void> _testImageConnection() async {
    await _saveImageKey();
    setState(() {
      _testingImage = true;
      _imageTestResult = null;
    });

    final success = await ImageGenerationService()
        .testConnection(_imageKeyController.text.trim());

    setState(() {
      _testingImage = false;
      _imageTestResult = success ? 'نجح الاتصال ✓' : 'فشل الاتصال ✗';
    });
  }

  Future<void> _testAudioConnection() async {
    await _saveAudioKey();
    setState(() {
      _testingAudio = true;
      _audioTestResult = null;
    });

    final success = await AudioService()
        .testConnection(_audioKeyController.text.trim());

    setState(() {
      _testingAudio = false;
      _audioTestResult = success ? 'نجح الاتصال ✓' : 'فشل الاتصال ✗';
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('مسح الكاش', style: AppTheme.headingSmall),
        content: const Text('سيتم حذف الملفات المؤقتة. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('مسح', style: TextStyle(color: AppTheme.warning)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = await StorageService.getInstance();
      await storage.clearCache();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم مسح الكاش ✓',
              style: AppTheme.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.success.withOpacity(0.9),
        ),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('مسح جميع البيانات', style: AppTheme.headingSmall),
        content: const Text(
            'سيتم حذف جميع البيانات بما فيها المشاريع والإعدادات.\nلا يمكن التراجع عن هذا الإجراء.\n\nهل أنت متأكد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف الكل', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final storage = await StorageService.getInstance();
      await storage.clearAll();
      _groqKeyController.clear();
      _imageKeyController.clear();
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم مسح جميع البيانات',
              style: AppTheme.bodySmall.copyWith(color: Colors.white)),
          backgroundColor: AppTheme.error.withOpacity(0.9),
        ),
      );
    }
  }
}
