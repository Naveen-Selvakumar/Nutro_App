bool isValidEmail(String? s) {
  if (s == null) return false;
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(s);
}

bool isValidPassword(String? s) {
  if (s == null) return false;
  return s.trim().length >= 6;
}
