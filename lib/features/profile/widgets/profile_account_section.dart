import 'package:flutter/material.dart';

class ProfileAccountSection extends StatelessWidget {
  const ProfileAccountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildCard(
      items: [
        _buildList(
          icon: Icons.person_outline_rounded,
          title: "Thông tin cá nhân",
          subtitle: "Chỉnh sửa họ tên, email, SĐT",
          onTap: () {},
        ),
        _buildList(
          icon: Icons.security_rounded,
          title: "Bảo mật tài khoản",
          subtitle: "Đổi mật khẩu, xác thực 2 lớp",
          onTap: () {},
        ),
        _buildList(
          icon: Icons.location_on_outlined,
          title: "Địa chỉ của tôi",
          subtitle: "Quản lý địa chỉ giao hàng / gom rác",
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 4, bottom: 8),
            child: Text(
              "Tài khoản & Địa chỉ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            int id = entry.key;
            Widget widget = entry.value;
            return Column(
              children: [
                widget,
                if (id < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Colors.grey.shade200,
                    indent: 44,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildList({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2E7D32), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Color(0xFF263238),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey,
        size: 22,
      ),
      onTap: onTap,
    );
  }
}
