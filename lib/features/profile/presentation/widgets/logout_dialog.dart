import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(context: context, builder: (_) => const LogoutDialog());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: Colors.red),
          SizedBox(width: 10),
          Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?',
        style: TextStyle(fontSize: 15),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            context.read<AuthBloc>().add(LoggedOut());
          },
          child: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
