import 'package:flutter/material.dart';
import '../config/theme.dart';

enum ToastType { success, error, info }

class TallyToast {
  static void show({
    required BuildContext context,
    required String message,
    ToastType type = ToastType.info,
    IconData? customIcon,
  }) {
    IconData icon;
    Color color;

    switch (type) {
      case ToastType.success:
        icon = Icons.check_circle_outline;
        color = context.colors.optimisticYellow; // Or a green if you have one
        break;
      case ToastType.error:
        icon = Icons.error_outline;
        color = context.colors.persistentRed;
        break;
      case ToastType.info:
        icon = Icons.info_outline;
        color = context.colors.precisionBlue;
        break;
    }

    if (customIcon != null) icon = customIcon;

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.bgCardLight.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TallyTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.error);
  }

  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: ToastType.info);
  }
}
