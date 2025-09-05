import 'package:flutter/material.dart';
import 'custom_textfield.dart';

/// Widget para registrar una nueva finca cuando el usuario no tiene ninguna
class FincaRegistrationWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;
  final Function(String) onChanged;
  final VoidCallback onRegister;
  final bool isLoading;

  const FincaRegistrationWidget({
    super.key,
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.onRegister,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono y título
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.agriculture,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Text(
            'Registra tu finca',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Descripción
          Text(
            'Para comenzar a monitorear tu ganado, necesitas registrar tu finca.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Campo de texto para nombre de finca
          CustomTextField(
            controller: controller,
            label: 'Nombre de la finca',
            hint: 'Ej: La Esperanza',
            validator: validator,
            onChanged: onChanged,
            enabled: !isLoading,
            prefixIcon: const Icon(Icons.terrain, color: Color(0xFF4CAF50)),
          ),

          const SizedBox(height: 24),

          // Botón de registro
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : onRegister,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.add_location),
              label: Text(isLoading ? 'Registrando...' : 'Registrar Finca'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
