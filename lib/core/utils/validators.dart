class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    if (!RegExp(emailRegex).hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value, int? minLength) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < (minLength ?? 6)) {
      return 'Password must be at least ${minLength ?? 6} characters long';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }

    return null;
  }

  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'This field'} cannot exceed $maxLength characters';
    }

    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    const phoneRegex = r'^\+?[\d\s\-\(\)]{10,}$';
    if (!RegExp(phoneRegex).hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    const urlRegex =
        r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$';
    if (!RegExp(urlRegex).hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  static String? number(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    return null;
  }

  static String? integer(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (int.tryParse(value) == null) {
      return '${fieldName ?? 'This field'} must be a valid integer';
    }

    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    final numberValidation = number(value, fieldName);
    if (numberValidation != null) return numberValidation;

    final num = double.parse(value!);
    if (num <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }

    return null;
  }

  static String? age(String? value) {
    final numberValidation = integer(value, 'Age');
    if (numberValidation != null) return numberValidation;

    final ageValue = int.parse(value!);
    if (ageValue < 0 || ageValue > 150) {
      return 'Please enter a valid age';
    }

    return null;
  }

  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }

    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }

    const usernameRegex = r'^[a-zA-Z0-9_]+$';
    if (!RegExp(usernameRegex).hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? name(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    if (value.length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }

    const nameRegex = r'^[a-zA-Z\s]+$';
    if (!RegExp(nameRegex).hasMatch(value)) {
      return '${fieldName ?? 'Name'} can only contain letters and spaces';
    }

    return null;
  }

  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) return result;
    }
    return null;
  }
}
