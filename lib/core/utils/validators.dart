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

  static String? numberPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final isPhone = RegExp(r'^\d{9,11}$').hasMatch(value);
    if (!isPhone) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }

    final input = value.trim();

    final parts = input.split(' ');
    if (parts.length < 2) {
      return 'Hãy nhập đầy đủ họ và tên';
    }

    final isValid = RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(input);
    if (!isValid) {
      return 'Tên không được chứa số hoặc ký tự đặc biệt';
    }

    return null;
  }

  static String? passWord(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);

    if (!hasUpper || !hasLower || !hasNumber) {
      return 'Mật khẩu phải gồm chữ hoa, chữ thường và số';
    }

    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }

    if (value != password) {
      return 'Mật khẩu không khớp';
    }

    return null;
  }
}
