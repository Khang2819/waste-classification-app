import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "OK",
    this.cancelText,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title),
      content: Text(message),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText!),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm?.call();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
