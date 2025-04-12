import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';

class MessageUtils {
  static void showMessage(
    BuildContext context, {
    required String message,
    MessageType type = MessageType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);

    // Remove any existing snackbars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    // Show the new snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            _getIcon(type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTitle(type),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: _getBackgroundColor(type),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        dismissDirection: DismissDirection.horizontal,
        margin: const EdgeInsets.all(16),
        elevation: 4,
      ),
    );
  }

  static Widget _getIcon(MessageType type) {
    IconData iconData;
    switch (type) {
      case MessageType.success:
        iconData = Icons.check_circle_outline;
        break;
      case MessageType.error:
        iconData = Icons.error_outline;
        break;
      case MessageType.warning:
        iconData = Icons.warning_amber_rounded;
        break;
      case MessageType.info:
        iconData = Icons.info_outline;
        break;
    }
    return Icon(iconData, color: Colors.white, size: 28);
  }

  static String _getTitle(MessageType type) {
    switch (type) {
      case MessageType.success:
        return 'Success';
      case MessageType.error:
        return 'Error';
      case MessageType.warning:
        return 'Warning';
      case MessageType.info:
        return 'Information';
    }
  }

  static Color _getBackgroundColor(MessageType type) {
    switch (type) {
      case MessageType.success:
        return AppTheme.success;
      case MessageType.error:
        return AppTheme.error;
      case MessageType.warning:
        return AppTheme.warning;
      case MessageType.info:
        return AppTheme.info;
    }
  }
}

enum MessageType {
  success,
  error,
  warning,
  info,
} 