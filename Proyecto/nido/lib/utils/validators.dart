/// Validadores reutilizables para formularios de autenticación.
class Validators {
  static String? nombreCompleto(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'El nombre completo es obligatorio';
    }
    if (texto.length < 2) {
      return 'Ingresa al menos 2 caracteres';
    }
    if (texto.length > 80) {
      return 'El nombre no puede superar 80 caracteres';
    }
    if (RegExp(r'[\d]').hasMatch(texto)) {
      return 'El nombre no debe incluir números';
    }
    return null;
  }

  static String? email(String? value) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }

    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(texto)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? value) {
    final texto = value ?? '';

    if (texto.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (texto.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(texto)) {
      return 'Debe incluir al menos una minúscula';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(texto)) {
      return 'Debe incluir al menos una mayúscula';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(texto)) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  static String? confirmarPassword(String? value, String password) {
    final texto = value?.trim() ?? '';

    if (texto.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (texto != password.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
