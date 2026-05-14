// ============================================================================
// MAHMOUD TECH - Scene Card Widget
// بطاقة عرض المشهد مع إمكانية التعديل
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';
import 'package:mahmoud_ai/models/scene_model.dart';
import 'package:mahmoud_ai/widgets/glass_card.dart';

class SceneCard extends StatelessWidget {
  final SceneModel scene;
  final int index;
  final Uint8List? imageBytes;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isEditable;

  const SceneCard({
    super.key,
    required this.scene,
    required this.index,
    this.imageBytes,
    this.onEdit,
    this.onDelete,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة
          Row(
            children: [
              // رقم المشهد
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.labelBold.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // عنوان المشهد
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      style: AppTheme.headingSmall.copyWith(
                        fontSize: 15,
                        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: AppTheme.primaryCyan.withOpacity(0.8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${scene.duration.toStringAsFixed(1)} ث',
                          style: AppTheme.bodySmall.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // نجوم الأهمية
                        ...List.generate(5, (i) => Icon(
                          i < scene.importance
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 13,
                          color: i < scene.importance
                              ? AppTheme.primaryGold
                              : (isDark ? Colors.white24 : Colors.black26),
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              // أزرار التعديل والحذف
              if (isEditable) ...[
                IconButton(
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: AppTheme.primaryCyan.withOpacity(0.7),
                  ),
                  onPressed: onEdit,
                  tooltip: 'تعديل',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppTheme.error.withOpacity(0.7),
                  ),
                  onPressed: onDelete,
                  tooltip: 'حذف',
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // وصف المشهد
          Text(
            scene.description,
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          // صورة المشهد إذا تم توليدها
          if (imageBytes != null && imageBytes!.length > 100) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(
                imageBytes!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(isDark),
              ),
            ),
          ],
          // حالة الصورة
          if (scene.imageFailed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warning.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 14, color: AppTheme.warning),
                  const SizedBox(width: 6),
                  Text(
                    'فشل توليد الصورة - تم استخدام صورة بديلة',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (scene.imageGenerated && !scene.imageFailed) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: AppTheme.success),
                  const SizedBox(width: 6),
                  Text(
                    'تم التوليد بنجاح',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.darkCardLight.withOpacity(0.5)
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 40,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
            const SizedBox(height: 8),
            Text(
              'في انتظار التوليد',
              style: AppTheme.bodySmall.copyWith(
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
