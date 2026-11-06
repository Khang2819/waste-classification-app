import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/change_password_cubit.dart';
import '../cubit/change_password_state.dart';

class AccountSecurityScreen extends StatefulWidget {
  const AccountSecurityScreen({super.key});

  @override
  State<AccountSecurityScreen> createState() => _AccountSecurityScreenState();
}

class _AccountSecurityScreenState extends State<AccountSecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  double _strength = 0.0;
  String _strengthText = 'Chưa nhập';
  Color _strengthColor = Colors.grey;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateStrength(String text) {
    if (text.isEmpty) {
      setState(() {
        _strength = 0.0;
        _strengthText = 'Chưa nhập';
        _strengthColor = Colors.grey;
      });
    } else if (text.length < 6) {
      setState(() {
        _strength = 0.3;
        _strengthText = 'Quá yếu (tối thiểu 6 ký tự)';
        _strengthColor = Colors.red;
      });
    } else if (text.length >= 6 &&
        (!text.contains(RegExp(r'[A-Z]')) ||
            !text.contains(RegExp(r'[0-9]')))) {
      setState(() {
        _strength = 0.65;
        _strengthText = 'Trung bình (nên thêm chữ in hoa & số)';
        _strengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _strength = 1.0;
        _strengthText = 'Rất mạnh & an toàn';
        _strengthColor = const Color(0xFF2E7D32);
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ChangePasswordCubit>().changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );
  }

  void _sendPasswordResetEmail() {
    context.read<ChangePasswordCubit>().sendPasswordResetEmail();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChangePasswordCubit>();
    final isPasswordLinked = cubit.isPasswordLinked;
    final email = cubit.currentUserEmail ?? '';

    final screenTitle = isPasswordLinked ? 'Đổi mật khẩu' : 'Bảo mật tài khoản';

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
        title: Text(
          screenTitle,
          style: const TextStyle(
            color: Color(0xFF1B5E20),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangePasswordSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            );
            context.pop();
          } else if (state is PasswordResetEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF2E7D32),
              ),
            );
          } else if (state is ChangePasswordFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ChangePasswordLoading;

          // TRƯỜNG HỢP 1: Tài khoản đăng nhập qua Google (không dùng mật khẩu)
          if (!isPasswordLinked) {
            return _buildGoogleAccountView(email);
          }

          // TRƯỜNG HỢP 2: Tài khoản có mật khẩu -> Cho phép đổi mật khẩu
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner đầu trang
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8F5E9),
                            border: Border.all(
                              color: const Color(0xFFC8E6C9),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: Color(0xFF2E7D32),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Bảo mật tài khoản của bạn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            email.isNotEmpty
                                ? 'Cập nhật mật khẩu mới cho tài khoản $email'
                                : 'Mật khẩu phải từ 6 ký tự trở lên để đảm bảo an toàn.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form nhập mật khẩu trong Card trắng
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mật khẩu hiện tại',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2E3E33),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _currentPasswordController,
                          hintText: 'Nhập mật khẩu đang dùng',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: _obscureCurrent,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập mật khẩu hiện tại';
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                                isLoading ? null : _sendPasswordResetEmail,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              isLoading
                                  ? 'Đang gửi link...'
                                  : 'Quên mật khẩu hiện tại?',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mật khẩu mới
                        const Text(
                          'Mật khẩu mới',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2E3E33),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _newPasswordController,
                          hintText: 'Nhập mật khẩu mới (tối thiểu 6 ký tự)',
                          prefixIcon: Icons.lock_rounded,
                          obscureText: _obscureNew,
                          onChanged: _updateStrength,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed:
                                () =>
                                    setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng nhập mật khẩu mới';
                            }
                            if (val.trim().length < 6) {
                              return 'Mật khẩu phải từ 6 ký tự trở lên';
                            }
                            if (val.trim() ==
                                _currentPasswordController.text.trim()) {
                              return 'Mật khẩu mới phải khác mật khẩu hiện tại';
                            }
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
                                  value: _strength,
                                  minHeight: 5,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _strengthColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _strengthText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _strengthColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Xác nhận mật khẩu mới
                        const Text(
                          'Xác nhận mật khẩu mới',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2E3E33),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Nhập lại mật khẩu mới',
                          prefixIcon: Icons.check_circle_outline_rounded,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed:
                                () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Vui lòng xác nhận mật khẩu mới';
                            }
                            if (val.trim() !=
                                _newPasswordController.text.trim()) {
                              return 'Mật khẩu xác nhận không trùng khớp';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nút lưu thay đổi
                  CustomButton(
                    isLoading: isLoading,
                    text: 'Cập nhật mật khẩu',
                    onPressed: isLoading ? null : _handleSubmit,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Giao diện dành riêng cho tài khoản đăng nhập Google
  Widget _buildGoogleAccountView(String email) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon Google & Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.g_mobiledata_rounded,
                    color: Color(0xFF4285F4),
                    size: 52,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tài khoản đăng nhập qua Google',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD2E3FC)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1967D2),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        email.isNotEmpty ? email : 'Đã liên kết Google',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1967D2),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Giải thích chi tiết
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF2E7D32),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tài khoản của bạn được bảo mật trực tiếp bởi Google. Vì vậy bạn không cần và không thể đổi mật khẩu trên ứng dụng này.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF0288D1),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Để thay đổi mật khẩu hoặc cài đặt bảo mật cho tài khoản, vui lòng truy cập trang Quản lý Tài khoản Google (myaccount.google.com).',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Nút quay lại
          CustomButton(
            text: 'Đã hiểu & Quay lại',
            onPressed: () => context.pop(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
