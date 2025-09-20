import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/cattle_pens_provider.dart';
import '../widgets/corral_lines_widget.dart';

class CattlePensPage extends StatelessWidget {
  const CattlePensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Verificar si es web y ancho mayor a 700
          final isWebWide = kIsWeb && constraints.maxWidth > 700;

          if (isWebWide) {
            // Layout para web con pantalla ancha (sin scroll)
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título
                Text(
                  'Monitorea tus corrales en tiempo real.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                // Fila de contenedores (expandida para usar el espacio disponible)
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Contenedor de imagen del corral
                      Expanded(
                        flex: 1,
                        child: _buildCorralContainer(
                          context,
                          imagePath: 'assets/images/corral_transparente.png',
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Contenedor de información
                      Expanded(
                        flex: 1,
                        child: _buildContentCattlePens(context, height: 365),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Layout original para móvil y pantallas pequeñas (con scroll)
            return Column(
              children: [
                Text(
                  'Monitorea tus corrales en tiempo real.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 15),
                // Contenedores responsivos
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
            );
          }
        },
      ),
    );
  }

  Widget _buildCorralContainer(
    BuildContext context, {
    required String imagePath,
  }) {
    return Consumer2<CattlePensProvider, StatisticsProvider>(
      builder: (context, corralProvider, statisticsProvider, child) {
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Obtener las coordenadas originales (sin escalar)
              final originalLines = corralProvider.getOriginalLines();

              // Generar puntos de ganado basado en los datos de estadísticas
              final originalCattlePoints = corralProvider
                  .generateOriginalCattlePoints(
                    statisticsProvider.totalRangosEdad,
                  );

              // Obtener las puertas originales (sin escalar)
              final originalGates = corralProvider.getOriginalGates();

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CorralWithLines(
                  imagePath: imagePath,
                  lines: originalLines,
                  showLines: corralProvider.showCorralLines,
                  cattlePoints: originalCattlePoints,
                  showCattlePoints: true,
                  gates: originalGates,
                  showGates: true,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContentCattlePens(BuildContext context, {double? height}) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final rangosEdad = provider.totalRangosEdad;

        return Container(
          width: double.infinity,
          height: height, // Usar altura específica cuando se proporcione
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
          child: height != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    // Lista de corrales con scroll si es necesario
                    SingleChildScrollView(
                      child: Column(
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
                    ),
                  ],
                )
              : Column(
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

  /*   Widget _buildToggleLineControl(BuildContext context) {
    return Consumer<CattlePensProvider>(
      builder: (context, corralProvider, child) {
        return Column(
          children: [
            // Control principal para todas las líneas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timeline,
                    color: corralProvider.showCorralLines
                        ? const Color(0xFF4CAF50)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Activar monitoreo con cámaras',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: corralProvider.showCorralLines,
                    onChanged: (_) => corralProvider.toggleCorralLines(),
                    activeColor: const Color(0xFF4CAF50),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  } */
}
