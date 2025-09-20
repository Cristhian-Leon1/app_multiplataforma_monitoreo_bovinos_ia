import 'package:flutter/material.dart';

/// Widget wrapper que maneja el unfocus automático de los TextFields
/// cuando el usuario toca fuera de ellos.
///
/// Implementa una funcionalidad común que mejora la experiencia de usuario
/// en formularios y pantallas con campos de texto.
///
/// Uso:
/// ```dart
/// UnfocusWrapper(
///   child: YourFormWidget(),
/// )
/// ```
class UnfocusWrapper extends StatelessWidget {
  /// Widget hijo que será envuelto con la funcionalidad de unfocus
  final Widget child;

  /// Callback opcional que se ejecuta cuando se detecta un tap fuera de los TextFields
  final VoidCallback? onUnfocus;

  /// Controla si el wrapper debe consumir el tap o permitir que se propague
  /// Por defecto es false para permitir que otros gestos funcionen normalmente
  final bool behavior;

  const UnfocusWrapper({
    super.key,
    required this.child,
    this.onUnfocus,
    this.behavior = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Quitar el foco de cualquier TextField cuando se toque fuera de ellos
        FocusScope.of(context).unfocus();

        // Ejecutar callback opcional si se proporciona
        onUnfocus?.call();
      },
      behavior: behavior
          ? HitTestBehavior.opaque
          : HitTestBehavior.deferToChild,
      child: child,
    );
  }
}

/// Extension para facilitar el uso del UnfocusWrapper en cualquier Widget
extension UnfocusExtension on Widget {
  /// Envuelve el widget actual con funcionalidad de unfocus automático
  ///
  /// Parámetros:
  /// - [onUnfocus]: Callback opcional que se ejecuta al hacer unfocus
  /// - [behavior]: Controla el comportamiento del hit testing
  ///
  /// Ejemplo:
  /// ```dart
  /// MyFormWidget().withUnfocus()
  /// ```
  Widget withUnfocus({VoidCallback? onUnfocus, bool behavior = false}) {
    return UnfocusWrapper(
      onUnfocus: onUnfocus,
      behavior: behavior,
      child: this,
    );
  }
}
