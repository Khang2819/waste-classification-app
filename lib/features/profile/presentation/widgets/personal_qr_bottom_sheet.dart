import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../auth/domain/entities/user.dart';

class PersonalQrBottomSheet extends StatelessWidget {
  final User? user;

  const PersonalQrBottomSheet({super.key, required this.user});

  static Future<void> show(BuildContext context, User? user) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PersonalQrBottomSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = user?.id ?? '';
    final displayName =
        (user?.fullName.isNotEmpty == true)
            ? user!.fullName
            : ((user?.email.isNotEmpty == true)
                ? user!.email
                : "Thành viên SmartWaste");
    final qrData = 'SMARTWASTE_USER:$userId';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Mã QR Nhận Điểm",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Đưa mã này trước camera thùng rác thông minh hoặc trạm thu gom để nhận điểm thưởng tích lũy.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE8F5E9), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                userId.isEmpty
                    ? const SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: Text(
                          "Chưa đăng nhập",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                    : QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 210.0,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF2E7D32),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF1B5E20),
                      ),
                    ),
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "ID: ${userId.isNotEmpty ? (userId.length > 10 ? '${userId.substring(0, 10)}...' : userId) : '---'}",
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Đóng",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
