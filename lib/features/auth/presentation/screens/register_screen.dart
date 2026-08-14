import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../cubit/register/register_cubit.dart';
import '../cubit/register/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = true;
  bool _isConfirmPasswordVisible = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.go('/login'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1B5E20),
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: Color(0xFF2E7D32),
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'SmartWaste',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Tạo tài khoản mới 🌱',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tham gia cộng đồng phân loại và xử lý rác thải vì môi trường xanh',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                BlocConsumer<RegisterCubit, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đăng ký tài khoản thành công! Chào mừng ${state.user.fullName} 🎉',
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.go('/main');
                    } else if (state is RegisterFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: const Color(0xFFD32F2F),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is RegisterLoading;

                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _fullNameController,
                            labelText: 'Họ và tên',
                            hintText: 'Nguyễn Văn A',
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) => Validators.fullName(value),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Địa chỉ Email',
                            hintText: 'nguyenvanA@gmail.com',
                            prefixIcon: Icons.email_outlined,
                            validator:
                                (value) => Validators.emailOrPhone(value),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _phoneController,
                            labelText: 'Số điện thoại',
                            hintText: '0301234567',
                            prefixIcon: Icons.phone_outlined,
                            validator: (value) => Validators.numberPhone(value),
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Mật khẩu',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _isPasswordVisible,
                            validator: (value) => Validators.passWord(value),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Xác nhận mật khẩu',
                            prefixIcon: Icons.lock_reset_rounded,
                            obscureText: _isConfirmPasswordVisible,
                            validator:
                                (value) => Validators.confirmPassword(
                                  value,
                                  _passwordController.text,
                                ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _acceptTerms,
                                activeColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                              ),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Tôi đồng ý với ',
                                    style: const TextStyle(fontSize: 13),
                                    children: [
                                      const TextSpan(
                                        text: 'Điều khoản dịch vụ',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(text: ' & '),
                                      const TextSpan(
                                        text: 'Chính sách bảo mật',
                                        style: TextStyle(
                                          color: Color(0xFF2E7D32),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () {
                                        if (!_acceptTerms) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Vui lòng đồng ý với Điều khoản dịch vụ',
                                              ),
                                              backgroundColor: Colors.orange,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<RegisterCubit>()
                                              .register(
                                                email:
                                                    _emailController.text
                                                        .trim(),
                                                password:
                                                    _passwordController.text,
                                                fullName:
                                                    _fullNameController.text
                                                        .trim(),
                                              );
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                disabledBackgroundColor: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.6),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shadowColor: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child:
                                  isLoading
                                      ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                      : const Text(
                                        'Đăng ký tài khoản',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Đăng nhập ngay',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
