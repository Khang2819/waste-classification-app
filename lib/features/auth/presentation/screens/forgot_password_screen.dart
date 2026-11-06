import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/forgot_password/forgot_password_cubit.dart';
import '../cubit/forgot_password/forgot_password_state.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ Email đã đăng ký';
    }
    final isEmail = RegExp(r'^\S+@\S+\.\S+$').hasMatch(value.trim());
    if (!isEmail) {
      return 'Địa chỉ Email không đúng định dạng';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1B5E20),
              ),
            ),
            title: const Text(
              'Quên mật khẩu',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
              listener: (context, state) {
                if (state is ForgotPasswordFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: const Color(0xFFD32F2F),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is ForgotPasswordSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Đã gửi email đặt lại mật khẩu tới ${state.email}!',
                      ),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ForgotPasswordSuccess) {
                  return _buildSuccessView(context, state.email);
                }

                final isLoading = state is ForgotPasswordLoading;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2E7D32,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            size: 72,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Khôi phục mật khẩu',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Nhập địa chỉ Email bạn đã dùng để đăng ký tài khoản SmartWaste. Hệ thống sẽ gửi đường dẫn đặt lại mật khẩu mới tới hộp thư của bạn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email đăng ký',
                          hintText: 'nguyenvanA@gmail.com',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 28),
                        CustomButton(
                          text: 'Gửi liên kết đặt lại mật khẩu',
                          isLoading: isLoading,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              FocusScope.of(context).unfocus();
                              context
                                  .read<ForgotPasswordCubit>()
                                  .sendResetEmail(_emailController.text.trim());
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          onPressed: () => context.go('/login'),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 18,
                            color: Color(0xFF2E7D32),
                          ),
                          label: const Text(
                            'Quay lại Đăng nhập',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 72,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Kiểm tra hộp thư của bạn!',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Chúng tôi đã gửi liên kết khôi phục mật khẩu đến:\n$email',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF263238),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Vui lòng mở email (kiểm tra cả mục Thư rác / Spam nếu chưa thấy) và bấm vào đường dẫn để tạo mật khẩu mới.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Quay lại màn hình Đăng nhập',
            onPressed: () => context.go('/login'),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () {
              context.read<ForgotPasswordCubit>().sendResetEmail(email);
            },
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: Color(0xFF2E7D32),
            ),
            label: const Text(
              'Chưa nhận được? Gửi lại email',
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
