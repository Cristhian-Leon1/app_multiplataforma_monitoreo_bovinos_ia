import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frase descriptiva
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            'Visualiza reportes y estadísticas detalladas de tu ganado para tomar mejores decisiones.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Contenido principal - Cards de estadísticas
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildStatsCard(
                context,
                icon: Icons.pets,
                title: 'Total Bovinos',
                value: '0',
                color: const Color(0xFF4CAF50),
              ),
              _buildStatsCard(
                context,
                icon: Icons.health_and_safety,
                title: 'Sanos',
                value: '0',
                color: const Color(0xFF2E7D32),
              ),
              _buildStatsCard(
                context,
                icon: Icons.warning,
                title: 'En Alerta',
                value: '0',
                color: const Color(0xFF81C784),
              ),
              _buildStatsCard(
                context,
                icon: Icons.trending_up,
                title: 'Análisis IA',
                value: '0',
                color: const Color(0xFF1B5E20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
