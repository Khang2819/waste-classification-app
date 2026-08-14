import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final IconData? icon;
  final Widget? customIcon;
  final double height;
  final double? width;
  final double borderRadius;
  final double fontSize;
  final FontWeight fontWeight;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.customIcon,
    this.height = 54.0,
    this.width = double.infinity,
    this.borderRadius = 16.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBgColor = widget.backgroundColor ?? AppColors.primary;
    final effectiveTextColor =
        widget.textColor ??
        (widget.isOutlined ? effectiveBgColor : Colors.white);
    final effectiveBorderColor = widget.borderColor ?? effectiveBgColor;

    final Widget buttonContent =
        widget.isLoading
            ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: effectiveTextColor,
                strokeWidth: 2.5,
              ),
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.customIcon != null) ...[
                  widget.customIcon!,
                  const SizedBox(width: 8),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, color: effectiveTextColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            );

    final bool isEnabled = widget.onPressed != null && !widget.isLoading;

    return Listener(
      onPointerDown:
          isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onPointerUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onPointerCancel:
          isEnabled ? (_) => setState(() => _isPressed = false) : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child:
              widget.isOutlined
                  ? OutlinedButton(
                    onPressed: widget.isLoading ? null : widget.onPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: effectiveBorderColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                      ),
                    ),
                    child: buttonContent,
                  )
                  : ElevatedButton(
                    onPressed: widget.isLoading ? null : widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: effectiveBgColor,
                      disabledBackgroundColor: effectiveBgColor.withValues(
                        alpha: 0.6,
                      ),
                      foregroundColor: effectiveTextColor,
                      elevation: 2,
                      shadowColor: effectiveBgColor.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          widget.borderRadius,
                        ),
                      ),
                    ),
                    child: buttonContent,
                  ),
        ),
      ),
    );
  }
}
