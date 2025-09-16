import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';

class CattlePensPage extends StatelessWidget {
  const CattlePensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Text(
            'Monitorea tus corrales en tiempo real.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 25),

          // Contenedores en columna
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCorralContainer(
                    context,
                    imagePath: 'assets/images/corral_transparente.png',
                  ),
                  const SizedBox(height: 20),

                  _buildContentCattlePens(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorralContainer(
    BuildContext context, {
    required String imagePath,
  }) {
    return Container(
      width: double.infinity,
      height: 365,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildContentCattlePens(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final rangosEdad = provider.totalRangosEdad;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Título centrado
              Text(
                'Cantidad de bovinos en corrales',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Lista de corrales
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCorralRow(
                    context,
                    'Corral 1 (0-6 meses):',
                    '${rangosEdad['0-6 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 2 (7-12 meses):',
                    '${rangosEdad['7-12 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 3 (13-24 meses):',
                    '${rangosEdad['13-24 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 4 (25-36 meses):',
                    '${rangosEdad['25-36 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 5 (37-48 meses):',
                    '${rangosEdad['37-48 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 6 (49-60 meses):',
                    '${rangosEdad['49-60 meses'] ?? 0}',
                  ),
                  const SizedBox(height: 12),
                  _buildCorralRow(
                    context,
                    'Corral 7 (mas de 5 años):',
                    '${rangosEdad['Mayores a 60 meses'] ?? 0}',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCorralRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }
}
