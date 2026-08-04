class Validators {
  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập Email hoặc SĐT';
    }

    final input = value.trim();

    final isEmail = RegExp(r'\S+@\S+\.\S+').hasMatch(input);
    final isPhone = RegExp(r'^\d{9,11}$').hasMatch(input);

    if (!isEmail && !isPhone) {
      return 'Email hoặc SĐT không hợp lệ';
    }

    return null;
  }
}
