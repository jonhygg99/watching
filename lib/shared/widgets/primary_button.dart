import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final Widget? icon;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final double borderRadius;
  final EdgeInsets? padding;
  final bool showBorder;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 36,
    this.width,
    this.borderRadius = 8,
    this.padding,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor =
        backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final effectiveForegroundColor =
        foregroundColor ?? theme.colorScheme.onSurfaceVariant;

    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsets>(
          padding ?? EdgeInsets.zero,
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          Size(fullWidth ? double.infinity : (width ?? 0), height ?? 36),
        ),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side:
                showBorder
                    ? BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    )
                    : BorderSide.none,
          ),
        ),
        backgroundColor:
            onPressed == null
                ? null
                : WidgetStateProperty.all<Color>(effectiveBackgroundColor),
        foregroundColor:
            onPressed == null
                ? null
                : WidgetStateProperty.all<Color>(effectiveForegroundColor),
        overlayColor:
            onPressed == null
                ? null
                : WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  return effectiveForegroundColor.withValues(alpha: 0.12);
                }),
        elevation: WidgetStateProperty.all<double>(0),
      ),
      child:
          icon != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color:
                          onPressed == null
                              ? theme.colorScheme.onSurface.withValues(
                                alpha: 0.38,
                              )
                              : theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
              : Text(
                text,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color:
                      onPressed == null
                          ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                          : theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
    );
  }
}
