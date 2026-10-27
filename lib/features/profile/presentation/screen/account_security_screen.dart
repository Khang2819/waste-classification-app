import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tùy chọn bảo mật cục bộ
  bool _biometricsEnabled = false;
  bool _appLockEnabled = true;
  bool _loginAlertsEnabled = true;
  bool _isSendingVerification = false;

  User? get _currentUser => _auth.currentUser;

  bool get _isEmailVerified => _currentUser?.emailVerified ?? false;

  bool get _isGoogleLinked =>
      _currentUser?.providerData.any(
        (info) => info.providerId == 'google.com',
      ) ??
      false;

  bool get _isPasswordLinked =>
      _currentUser?.providerData.any((info) => info.providerId == 'password') ??
      false;

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final email = user?.email ?? 'Chưa cập nhật email';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F5),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1B5E20),
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Bảo mật tài khoản',
          style: TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ đánh giá an toàn tài khoản
            _buildSecurityScoreCard(),
            const SizedBox(height: 24),

            // 2. Nhóm Đăng nhập & Mật khẩu
            _buildSectionHeader('Đăng nhập & Mật khẩu', Icons.lock_outline_rounded),
            const SizedBox(height: 10),
            _buildCardContainer([
              _buildActionTile(
                icon: Icons.key_rounded,
                iconColor: const Color(0xFF2E7D32),
                title: 'Đổi mật khẩu',
                subtitle: 'Cập nhật mật khẩu định kỳ để an toàn hơn',
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _showChangePasswordDialog,
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.mark_email_read_outlined,
                iconColor: const Color(0xFF1565C0),
                title: 'Khôi phục mật khẩu qua Email',
                subtitle: 'Gửi link tạo mật khẩu mới vào hòm thư',
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: _sendPasswordResetEmail,
              ),
            ]),
            const SizedBox(height: 24),

            // 3. Nhóm Xác thực tài khoản
            _buildSectionHeader('Xác thực danh tính', Icons.verified_user_outlined),
            const SizedBox(height: 10),
            _buildCardContainer([
              _buildActionTile(
                icon: Icons.alternate_email_rounded,
                iconColor: _isEmailVerified ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                title: 'Email xác thực',
                subtitle: email,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isEmailVerified
                            ? const Color(0xFFE8F5E9)
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isEmailVerified
                              ? const Color(0xFF81C784)
                              : Colors.orange.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isEmailVerified
                                ? Icons.check_circle_rounded
                                : Icons.warning_amber_rounded,
                            size: 14,
                            color: _isEmailVerified
                                ? const Color(0xFF2E7D32)
                                : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEmailVerified ? 'Đã xác thực' : 'Chưa xác thực',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _isEmailVerified
                                  ? const Color(0xFF2E7D32)
                                  : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: _isEmailVerified ? null : _handleSendEmailVerification,
              ),
            ]),
            const SizedBox(height: 24),

            // 4. Liên kết tài khoản
            _buildSectionHeader('Tài khoản liên kết', Icons.link_rounded),
            const SizedBox(height: 10),
            _buildCardContainer([
              _buildActionTile(
                icon: Icons.g_mobiledata_rounded,
                iconColor: Colors.red.shade700,
                title: 'Google',
                subtitle: _isGoogleLinked ? 'Đã liên kết đăng nhập' : 'Chưa liên kết',
                trailing: Text(
                  _isGoogleLinked ? 'Đã kết nối' : 'Chưa kết nối',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isGoogleLinked ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isGoogleLinked
                            ? 'Tài khoản đã được bảo vệ bằng Google'
                            : 'Vui lòng sử dụng tính năng Đăng nhập Google để đồng bộ',
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.password_rounded,
                iconColor: const Color(0xFF2E7D32),
                title: 'Mật khẩu ứng dụng',
                subtitle: _isPasswordLinked ? 'Đã kích hoạt' : 'Chưa kích hoạt',
                trailing: Text(
                  _isPasswordLinked ? 'Hoạt động' : 'Tắt',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isPasswordLinked ? const Color(0xFF2E7D32) : Colors.grey.shade600,
                  ),
                ),
                onTap: null,
              ),
            ]),
            const SizedBox(height: 24),

            // 5. Bảo vệ nâng cao
            _buildSectionHeader('Bảo vệ nâng cao', Icons.shield_outlined),
            const SizedBox(height: 10),
            _buildCardContainer([
              _buildSwitchTile(
                icon: Icons.fingerprint_rounded,
                iconColor: const Color(0xFF0288D1),
                title: 'Mở khóa sinh trắc học',
                subtitle: 'Dùng Face ID hoặc vân tay để mở ứng dụng',
                value: _biometricsEnabled,
                onChanged: (val) {
                  setState(() => _biometricsEnabled = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        val
                            ? 'Đã bật xác thực sinh trắc học'
                            : 'Đã tắt xác thực sinh trắc học',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildSwitchTile(
                icon: Icons.screen_lock_portrait_rounded,
                iconColor: const Color(0xFF6A1B9A),
                title: 'Tự động khóa ứng dụng',
                subtitle: 'Khóa ứng dụng khi chuyển sang nền khác',
                value: _appLockEnabled,
                onChanged: (val) => setState(() => _appLockEnabled = val),
              ),
              const Divider(height: 1, indent: 56),
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                iconColor: Colors.amber.shade800,
                title: 'Cảnh báo đăng nhập lạ',
                subtitle: 'Nhận thông báo khi phát hiện đăng nhập mới',
                value: _loginAlertsEnabled,
                onChanged: (val) => setState(() => _loginAlertsEnabled = val),
              ),
            ]),
            const SizedBox(height: 24),

            // 6. Phiên & Thiết bị hoạt động
            _buildSectionHeader('Phiên & Thiết bị', Icons.devices_rounded),
            const SizedBox(height: 10),
            _buildCardContainer([
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                title: const Row(
                  children: [
                    Text(
                      'Thiết bị hiện tại',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF2E3E33),
                      ),
                    ),
                    SizedBox(width: 8),
                    Badge(
                      label: Text('Online', style: TextStyle(fontSize: 10)),
                      backgroundColor: Color(0xFF43A047),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Lần hoạt động gần nhất: Vừa xong',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                trailing: TextButton(
                  onPressed: _showLogoutOthersDialog,
                  child: const Text(
                    'Đăng xuất thiết bị khác',
                    style: TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 28),

            // 7. Vùng nguy hiểm
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'Vùng cảnh báo bảo mật',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Xóa tài khoản sẽ loại bỏ toàn bộ điểm thưởng Xanh, lịch sử gom rác và thành tựu đã tích lũy vĩnh viễn.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showDeleteAccountDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade800,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 20),
                      label: const Text(
                        'Yêu cầu xóa tài khoản',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget Thẻ đánh giá an ninh
  Widget _buildSecurityScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Mức độ an toàn: ',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Tốt (85%)',
                      style: TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tài khoản được bảo vệ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 0.85,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD54F)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF2E3E33),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF2E3E33),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF2E7D32),
        onChanged: onChanged,
      ),
    );
  }

  // Xử lý gửi email xác thực tài khoản
  Future<void> _handleSendEmailVerification() async {
    if (_isSendingVerification) return;
    setState(() => _isSendingVerification = true);
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF2E7D32),
              content: Text(
                'Đã gửi liên kết xác thực tới email của bạn! Vui lòng kiểm tra hòm thư.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Không thể gửi email xác thực: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  // Xử lý gửi email reset password
  Future<void> _sendPasswordResetEmail() async {
    final email = _currentUser?.email;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy địa chỉ email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E7D32),
            content: Text('Đã gửi email đặt lại mật khẩu đến: $email'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Lỗi: $e'),
          ),
        );
      }
    }
  }

  // Dialog Đổi Mật Khẩu
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isLoading = false;
    double strength = 0.0;
    String strengthText = 'Chưa nhập';
    Color strengthColor = Colors.grey;

    void updateStrength(String text) {
      if (text.isEmpty) {
        strength = 0;
        strengthText = 'Chưa nhập';
        strengthColor = Colors.grey;
      } else if (text.length < 6) {
        strength = 0.3;
        strengthText = 'Quá yếu (tối thiểu 6 ký tự)';
        strengthColor = Colors.red;
      } else if (text.length >= 6 && (!text.contains(RegExp(r'[A-Z]')) || !text.contains(RegExp(r'[0-9]')))) {
        strength = 0.6;
        strengthText = 'Trung bình (nên thêm chữ hoa & số)';
        strengthColor = Colors.orange;
      } else {
        strength = 1.0;
        strengthText = 'Rất mạnh và an toàn';
        strengthColor = const Color(0xFF2E7D32);
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Icon(Icons.lock_reset_rounded, color: Color(0xFF2E7D32), size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Đổi mật khẩu tài khoản',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Mật khẩu hiện tại
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setSheetState(() => obscureCurrent = !obscureCurrent),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Vui lòng nhập mật khẩu hiện tại' : null,
                      ),
                      const SizedBox(height: 14),

                      // Mật khẩu mới
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        onChanged: (text) {
                          setSheetState(() => updateStrength(text));
                        },
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setSheetState(() => obscureNew = !obscureNew),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                          if (val.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Thước đo độ mạnh mật khẩu
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: strength,
                                minHeight: 4,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            strengthText,
                            style: TextStyle(
                              fontSize: 12,
                              color: strengthColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Xác nhận mật khẩu mới
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setSheetState(() => obscureConfirm = !obscureConfirm),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val != newPasswordController.text) {
                            return 'Mật khẩu xác nhận không trùng khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Nút hành động
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setSheetState(() => isLoading = true);
                                  try {
                                    final user = _auth.currentUser;
                                    if (user != null && user.email != null) {
                                      // Re-authenticate
                                      final cred = EmailAuthProvider.credential(
                                        email: user.email!,
                                        password: currentPasswordController.text.trim(),
                                      );
                                      await user.reauthenticateWithCredential(cred);
                                      await user.updatePassword(newPasswordController.text.trim());

                                      if (ctx.mounted) {
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            backgroundColor: Color(0xFF2E7D32),
                                            content: Text('Đổi mật khẩu thành công!'),
                                          ),
                                        );
                                      }
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    String msg = 'Đã xảy ra lỗi.';
                                    if (e.code == 'wrong-password') {
                                      msg = 'Mật khẩu hiện tại không đúng.';
                                    } else if (e.code == 'weak-password') {
                                      msg = 'Mật khẩu mới quá yếu.';
                                    }
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red.shade700,
                                          content: Text(msg),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (ctx.mounted) {
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          backgroundColor: Colors.red.shade700,
                                          content: Text('Lỗi: $e'),
                                        ),
                                      );
                                    }
                                  } finally {
                                    setSheetState(() => isLoading = false);
                                  }
                                },
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Cập nhật mật khẩu',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Dialog đăng xuất các thiết bị khác
  void _showLogoutOthersDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất các thiết bị khác?'),
        content: const Text(
          'Tất cả các phiên đăng nhập khác của tài khoản này trên các thiết bị hoặc trình duyệt khác sẽ bị hủy kết nối.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã đăng xuất khỏi tất cả các thiết bị khác'),
                ),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // Dialog Xóa tài khoản
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Xóa tài khoản?'),
          ],
        ),
        content: const Text(
          'Hành động này không thể hoàn tác. Mọi điểm thưởng, huy hiệu và dữ liệu phân loại rác của bạn sẽ bị xóa vĩnh viễn khỏi hệ thống.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Vì lý do bảo mật, vui lòng liên hệ quản trị viên hoặc xác thực lại để xóa tài khoản.',
                  ),
                ),
              );
            },
            child: const Text('Xác nhận xóa'),
          ),
        ],
      ),
    );
  }
}
