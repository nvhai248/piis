class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static bool isValidImageSize(int sizeInBytes) {
    const maxSizeInBytes = 5 * 1024 * 1024; // 5MB
    return sizeInBytes <= maxSizeInBytes;
  }

  static bool isValidImageDimensions(int width, int height) {
    const maxDimension = 2048;
    return width <= maxDimension && height <= maxDimension;
  }
} 