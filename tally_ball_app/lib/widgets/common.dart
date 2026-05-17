import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Official Tally Ball logo widget — use instead of plain "TALLY BALL" text
class TallyLogo extends StatelessWidget {
  final double height;
  final bool useDark;

  const TallyLogo({super.key, this.height = 32, this.useDark = false});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // logo_dark.png is the dark-background version; logo.png for light bg
    final asset = (brightness == Brightness.dark || useDark)
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo.png';
    return Image.asset(asset, height: height, fit: BoxFit.contain);
  }
}

/// Glassmorphism card used across the app
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderColor,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? context.colors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

/// Primary action button
class TallyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isOutlined;
  final double? width;
  final double? height;

  const TallyButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.isOutlined = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: color ?? context.colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 10),
              ],
              Text(text, style: TallyTextStyles.button(context).copyWith(
                color: color != null && color == context.colors.optimisticYellow ? context.colors.textPrimary : null,
              )),
            ],
          ),
        ),
      );
    }

    final buttonColor = color ?? context.colors.precisionBlue;
    final textColor = (buttonColor == context.colors.optimisticYellow) 
        ? context.colors.textPrimary 
        : Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          elevation: 0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text, style: TallyTextStyles.button(context).copyWith(color: textColor)),
              if (icon != null) ...[
                const SizedBox(width: 10),
                Icon(icon, size: 20, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Styled text field
class TallyTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? errorText;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const TallyTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TallyTextStyles.label(context)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(color: context.colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: hasError
                        ? context.colors.persistentRed
                        : context.colors.textTertiary,
                    size: 20,
                  )
                : null,
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? context.colors.persistentRed.withValues(alpha: 0.7)
                    : context.colors.border,
                width: hasError ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? context.colors.persistentRed
                    : context.colors.precisionBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.persistentRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.persistentRed,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 13,
                color: context.colors.persistentRed,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  errorText!,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.persistentRed,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Bottom nav bar used across dashboard screens
class TallyBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<TallyNavItem> items;

  const TallyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgPrimary,
        border: Border(top: BorderSide(color: context.colors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isActive = i == currentIndex;
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? context.colors.precisionBlue25.withValues(alpha: 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    color: isActive ? context.colors.precisionBlue : context.colors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      color: isActive ? context.colors.precisionBlue : context.colors.textTertiary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TallyNavItem {
  final IconData icon;
  final String label;
  TallyNavItem({required this.icon, required this.label});
}

/// Selection card (for difficulty levels, game modes, etc.)
class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? selectedBorderColor;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.selectedBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol = selectedBorderColor ?? context.colors.precisionBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? borderCol.withValues(alpha: 0.08) : context.colors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderCol : context.colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? borderCol : context.colors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? borderCol : context.colors.textTertiary,
                  size: 20,
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? context.colors.textPrimary : context.colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
