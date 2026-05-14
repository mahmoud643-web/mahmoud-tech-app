// ============================================================================
// MAHMOUD TECH - Gradient Button Widget
// زر متدرج احترافي مع تأثيرات
// ============================================================================

import 'package:flutter/material.dart';
import 'package:mahmoud_ai/constants/app_theme.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? emoji;
  final LinearGradient? gradient;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final double borderRadius;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.emoji,
    this.gradient,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grad = widget.gradient ?? AppTheme.primaryGradient;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => _controller.forward(),
        onTapUp: isDisabled
            ? null
            : (_) {
                _controller.reverse();
                widget.onPressed?.call();
              },
        onTapCancel: isDisabled ? null : () => _controller.reverse(),
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.5 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: widget.isOutlined ? null : grad,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.isOutlined
                  ? Border.all(color: AppTheme.primaryCyan, width: 2)
                  : null,
              boxShadow: widget.isOutlined
                  ? null
                  : [
                      BoxShadow(
                        color: (grad.colors.first).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? AppTheme.primaryCyan
                                : Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.emoji != null) ...[
                            Text(
                              widget.emoji!,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: widget.isOutlined
                                  ? AppTheme.primaryCyan
                                  : Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: AppTheme.labelBold.copyWith(
                              color: widget.isOutlined
                                  ? AppTheme.primaryCyan
                                  : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر بسيط بنفس الطابع ولكن أصغر
class MiniGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const MiniGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, size: 18, color: color ?? AppTheme.primaryCyan)
          : const SizedBox.shrink(),
      label: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: color ?? AppTheme.primaryCyan,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
