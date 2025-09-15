import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsChartsWidget extends StatelessWidget {
  final Map<String, int> totalRazas;
  final Map<String, int> totalSexos;
  final Map<String, int> totalRangosEdad;

  const StatisticsChartsWidget({
    super.key,
    required this.totalRazas,
    required this.totalSexos,
    required this.totalRangosEdad,
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay datos, no mostrar las gráficas
    if (totalRazas.isEmpty && totalSexos.isEmpty && totalRangosEdad.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'Distribución de Bovinos',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ),

        // Gráfica de Razas
        if (totalRazas.isNotEmpty) ...[
          _buildChartContainer(
            context,
            title: 'Distribución por Razas',
            icon: Icons.category,
            chart: _buildRazasChart(context),
          ),
          const SizedBox(height: 24),
        ],

        // Gráfica de Sexos
        if (totalSexos.isNotEmpty) ...[
          _buildChartContainer(
            context,
            title: 'Distribución por Sexos',
            icon: Icons.male,
            chart: _buildSexosChart(context),
          ),
          const SizedBox(height: 24),
        ],

        // Gráfica de Rangos de Edad
        if (totalRangosEdad.isNotEmpty) ...[
          _buildChartContainer(
            context,
            title: 'Distribución por Rangos de Edad',
            icon: Icons.schedule,
            chart: _buildRangosEdadChart(context),
          ),
        ],
      ],
    );
  }

  Widget _buildChartContainer(
    BuildContext context, {
    required String title,
    required IconData icon,
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
                child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
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
          SizedBox(height: 300, child: chart),
        ],
      ),
    );
  }

  Widget _buildRazasChart(BuildContext context) {
    // Convertir los datos a una lista para el gráfico
    final entries = totalRazas.entries.toList();

    // Colores predefinidos para las barras
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
      const Color(0xFF00BCD4),
      const Color(0xFF8BC34A),
      const Color(0xFFFFEB3B),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50, // Rango fijo de 0 a 60 para razas
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${entries[group.x.toInt()].key}\n${rod.toY.round()} bovinos',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= entries.length) return const Text('');

                return Transform.rotate(
                  angle: -0.5, // Rotar -90 grados (en radianes)
                  child: Container(
                    width: 90, // Ancho fijo para el contenedor
                    padding: const EdgeInsets.only(top: 5, right: 30),
                    child: Text(
                      entries[value.toInt()].key, // Mostrar el texto completo
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
              reservedSize: 40, // Espacio suficiente para textos rotados
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 25,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.value.toDouble(),
                color: colors[index % colors.length],
                width: 30,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10, // Intervalos de 10 para el rango 0-60
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildSexosChart(BuildContext context) {
    // Para sexos usamos colores específicos
    final sexoColors = {
      'Macho': const Color(0xFF8BC34A),
      'Hembra': const Color(0xFF4CAF50),
      'Desconocido': const Color(0xFF9E9E9E),
    };

    final entries = totalSexos.entries.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50, // Rango fijo de 0 a 100 para sexos
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${entries[group.x.toInt()].key}\n${rod.toY.round()} bovinos',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= entries.length) return const Text('');

                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    entries[value.toInt()].key,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
              reservedSize: 20,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 25,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
          ),
        ),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.value.toDouble(),
                color: sexoColors[data.key] ?? const Color(0xFF9E9E9E),
                width: 100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10, // Intervalos de 20 para el rango 0-100
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRangosEdadChart(BuildContext context) {
    final entries = totalRangosEdad.entries.toList();

    // Orden específico para los rangos de edad
    final ordenRangos = [
      '0-6 meses',
      '7-12 meses',
      '13-24 meses',
      '25-36 meses',
      '37-48 meses',
      '49-60 meses',
      '+60 meses',
    ];

    // Crear entries para TODOS los rangos, incluso los que no tienen datos
    final entriesOrdenadas = <MapEntry<String, int>>[];
    for (String rango in ordenRangos) {
      final entry = entries.where((e) => e.key == rango).firstOrNull;
      if (entry != null) {
        entriesOrdenadas.add(entry);
      } else {
        // Si no hay datos para este rango, agregar con valor 0
        entriesOrdenadas.add(MapEntry(rango, 0));
      }
    }

    // Colores específicos para rangos de edad
    final coloresRangos = [
      const Color(0xFF4CAF50), // Verde claro
      const Color(0xFF8BC34A), // Verde lima
      const Color(0xFFCDDC39), // Amarillo verde
      const Color(0xFFFFC107), // Ámbar
      const Color(0xFFFF9800), // Naranja
      const Color(0xFFFF5722), // Naranja profundo
      const Color(0xFFF44336), // Rojo
      const Color(0xFF9E9E9E), // Gris para "Sin datos"
    ];

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          maxY: 20, // Rango de 0 a 20 para rangos de edad
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                if (groupIndex < entriesOrdenadas.length) {
                  final entry = entriesOrdenadas[groupIndex];
                  return BarTooltipItem(
                    '${entry.key}\n${entry.value} bovinos',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                return null;
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                interval: 5, // Intervalos de 5 para el rango 0-20
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < entriesOrdenadas.length) {
                    final text = entriesOrdenadas[index].key;
                    final parts = text.split(' ');

                    // Mostrar en dos líneas para mejor legibilidad
                    if (parts.length > 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              parts[0],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (parts.length > 1)
                              Text(
                                parts.sublist(1).join(' '),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
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
            border: Border(
              left: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
              bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
          ),
          barGroups: entriesOrdenadas.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.value.toDouble(),
                  color: index < coloresRangos.length
                      ? coloresRangos[index]
                      : const Color(0xFF9E9E9E),
                  width: 32,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5, // Intervalos de 5 para el rango 0-20
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.3),
                strokeWidth: 1,
              );
            },
          ),
        ),
      ),
    );
  }
}
