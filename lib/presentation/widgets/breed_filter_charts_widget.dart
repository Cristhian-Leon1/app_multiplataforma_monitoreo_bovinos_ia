import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BreedFilterChartsWidget extends StatelessWidget {
  final List<String> availableRazas;
  final String? selectedRaza;
  final Map<String, double> pesoPromedioByRangoEdad;
  final Map<String, double> alturaPromedioByRangoEdad;
  final Function(String?) onRazaChanged;

  const BreedFilterChartsWidget({
    super.key,
    required this.availableRazas,
    required this.selectedRaza,
    required this.pesoPromedioByRangoEdad,
    required this.alturaPromedioByRangoEdad,
    required this.onRazaChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay razas disponibles, no mostrar nada
    if (availableRazas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'Análisis por Raza',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),

        // Filtro de razas
        _buildRazaFilter(context),

        // Gráficas de líneas (solo si hay una raza seleccionada)
        if (selectedRaza != null) ...[
          const SizedBox(height: 24),

          // Gráfica de peso promedio
          if (pesoPromedioByRangoEdad.isNotEmpty) ...[
            _buildLineChartContainer(
              context,
              title: 'Peso Promedio por Edad - $selectedRaza',
              iconWidget: SvgPicture.asset(
                'assets/icons/icono_peso.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF4CAF50),
                  BlendMode.srcIn,
                ),
              ),
              chart: _buildPesoChart(context),
            ),
            const SizedBox(height: 24),
          ],

          // Gráfica de altura promedio
          if (alturaPromedioByRangoEdad.isNotEmpty) ...[
            _buildLineChartContainer(
              context,
              title: 'Altura Promedio por Edad - $selectedRaza',
              icon: Icons.height,
              chart: _buildAlturaChart(context),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildRazaFilter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del filtro
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Filtrar por Raza',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRaza,
                hint: const Text('Seleccionar raza'),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF4CAF50),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Seleccionar raza'),
                  ),
                  ...availableRazas.map(
                    (raza) => DropdownMenuItem<String>(
                      value: raza,
                      child: Text(raza),
                    ),
                  ),
                ],
                onChanged: onRazaChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartContainer(
    BuildContext context, {
    required String title,
    IconData? icon,
    Widget? iconWidget,
    required Widget chart,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Título de la gráfica
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    iconWidget ??
                    Icon(
                      icon ?? Icons.help,
                      color: const Color(0xFF4CAF50),
                      size: 20,
                    ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfica
          SizedBox(height: 250, child: chart),
        ],
      ),
    );
  }

  Widget _buildPesoChart(BuildContext context) {
    // Ordenar rangos de edad estándar
    final rangosOrdenados = _getOrderedRangos();
    final spots = <FlSpot>[];

    // Crear spots para todos los rangos, incluso si no hay datos
    for (int i = 0; i < rangosOrdenados.length; i++) {
      final rango = rangosOrdenados[i];
      final peso = pesoPromedioByRangoEdad[rango];
      if (peso != null) {
        spots.add(FlSpot(i.toDouble(), peso));
      }
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (rangosOrdenados.length - 1).toDouble(),
        minY: 0,
        maxY: 700, // Rango fijo de 0 a 700 kg
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 100, // Intervalos de 100 kg
          verticalInterval: 1, // Mostrar líneas para cada rango de edad
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          // Títulos del eje Y (Peso)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: 100, // Mostrar cada 100 kg
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} kg',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          // Títulos del eje X (Rangos de edad)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < rangosOrdenados.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _truncateRango(rangosOrdenados[index]),
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        lineBarsData: spots.isNotEmpty
            ? [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  Widget _buildAlturaChart(BuildContext context) {
    // Ordenar rangos de edad estándar
    final rangosOrdenados = _getOrderedRangos();
    final spots = <FlSpot>[];

    // Crear spots para todos los rangos, incluso si no hay datos
    for (int i = 0; i < rangosOrdenados.length; i++) {
      final rango = rangosOrdenados[i];
      final altura = alturaPromedioByRangoEdad[rango];
      if (altura != null) {
        spots.add(FlSpot(i.toDouble(), altura));
      }
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (rangosOrdenados.length - 1).toDouble(),
        minY: 0,
        maxY: 200, // Rango fijo de 0 a 200 cm
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 25, // Intervalos de 25 cm
          verticalInterval: 1, // Mostrar líneas para cada rango de edad
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          // Títulos del eje Y (Altura)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              interval: 25, // Mostrar cada 25 cm
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} cm',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          // Títulos del eje X (Rangos de edad)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < rangosOrdenados.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _truncateRango(rangosOrdenados[index]),
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        lineBarsData: spots.isNotEmpty
            ? [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF4CAF50),
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  ),
                ),
              ]
            : [],
      ),
    );
  }

  List<String> _getOrderedRangos() {
    return [
      '0-6 meses',
      '7-12 meses',
      '13-24 meses',
      '25-36 meses',
      '37-48 meses',
      '49-60 meses',
      'Mayores a 60 meses',
    ];
  }

  String _truncateRango(String rango) {
    // Simplificar texto para mostrar en eje X
    if (rango.contains('0-6')) return '0-6\nmeses';
    if (rango.contains('7-12')) return '7-12\nmeses';
    if (rango.contains('13-24')) return '13-24\nmeses';
    if (rango.contains('25-36')) return '25-36\nmeses';
    if (rango.contains('37-48')) return '37-48\nmeses';
    if (rango.contains('49-60')) return '49-60\nmeses';
    if (rango.contains('Mayores')) return '+ 60\nmeses';
    return rango;
  }
}
