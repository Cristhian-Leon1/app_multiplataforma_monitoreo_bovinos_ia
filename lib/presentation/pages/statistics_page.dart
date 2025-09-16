import 'package:app_multiplataforma_monitoreo_bovinos_ia/presentation/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/finca_registration_widget.dart';
import '../widgets/statistics_charts_widget.dart';
import '../widgets/breed_filter_charts_widget.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  Future<void> _handleFincaRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(
      context,
      listen: false,
    );

    if (authProvider.userToken != null) {
      final success = await statisticsProvider.createFinca(
        authProvider.userToken!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Finca registrada exitosamente!'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleFincaDeletion() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(
      context,
      listen: false,
    );

    if (authProvider.userToken != null) {
      final success = await statisticsProvider.deleteFinca(
        authProvider.userToken!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Finca eliminada exitosamente'),
            backgroundColor: Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              statisticsProvider.errorMessage ?? 'Error al eliminar la finca',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(
      context,
      listen: false,
    );

    if (authProvider.userToken != null) {
      await statisticsProvider.refreshData(authProvider.userToken!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StatisticsProvider, AuthProvider>(
      builder: (context, statisticsProvider, authProvider, child) {
        return Column(
          children: [
            // Texto descriptivo fijo (siempre visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 7, right: 7),
              child: Text(
                'Visualiza información relevante de los bovinos de tu finca para tomar mejores decisiones.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Contenido variable según el estado
            Expanded(
              child: _buildVariableContent(
                context,
                statisticsProvider,
                authProvider,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVariableContent(
    BuildContext context,
    StatisticsProvider statisticsProvider,
    AuthProvider authProvider,
  ) {
    // Si está cargando, mostrar loading centrado
    if (statisticsProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            SizedBox(height: 16),
            Text(
              'Cargando datos...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Si no hay fincas registradas, mostrar formulario centrado
    if (!statisticsProvider.hasFincas) {
      return _buildNoFincaContent(context, statisticsProvider);
    }

    // Si hay fincas, mostrar contenido con scroll
    return _buildFincaStatsContent(context, statisticsProvider);
  }

  Widget _buildNoFincaContent(
    BuildContext context,
    StatisticsProvider statisticsProvider,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 7),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar errores si los hay
            if (statisticsProvider.errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        statisticsProvider.errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      onPressed: statisticsProvider.clearError,
                      icon: Icon(Icons.close, color: Colors.red[600]),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),

            // Formulario de registro de finca centrado
            FincaRegistrationWidget(
              controller: statisticsProvider.fincaNameController,
              validator: statisticsProvider.validateFincaName,
              onChanged: statisticsProvider.onFincaNameChanged,
              onRegister: _handleFincaRegistration,
              isLoading: statisticsProvider.isCreatingFinca,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFincaStatsContent(
    BuildContext context,
    StatisticsProvider statisticsProvider,
  ) {
    return Column(
      children: [
        // Información de la finca fija (no hace scroll)
        if (statisticsProvider.selectedFinca != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(left: 7, right: 7, bottom: 24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icono de la finca
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 32,
                  ),
                ),

                const SizedBox(width: 16),

                // Información de la finca
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finca:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statisticsProvider.selectedFinca!.nombre,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),

                // Botón de eliminar finca
                IconButton(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  tooltip: 'Eliminar finca',
                ),
              ],
            ),
          ),

        // Contenido con scroll (estadísticas)
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF4CAF50),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                children: [
                  // Mostrar errores si los hay
                  if (statisticsProvider.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statisticsProvider.errorMessage!,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            onPressed: statisticsProvider.clearError,
                            icon: Icon(Icons.close, color: Colors.red[600]),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: CardHorizontal(
                      iconWidget: SvgPicture.asset(
                        'assets/icons/icono_vaca.svg',
                        width: 40,
                        height: 40,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      title: 'Cantidad de bovinos en la finca',
                      value: statisticsProvider.totalBovinos.toString(),
                      color: const Color(0xFF4CAF50),
                    ),
                  ),

                  // Gráficas de distribución
                  StatisticsChartsWidget(
                    totalRazas: statisticsProvider.totalRazas,
                    totalSexos: statisticsProvider.totalSexos,
                    totalRangosEdad: statisticsProvider.totalRangosEdad,
                  ),

                  // Filtro y gráficas por raza
                  BreedFilterChartsWidget(
                    availableRazas: statisticsProvider.availableRazas,
                    selectedRaza: statisticsProvider.selectedRazaFilter,
                    pesoPromedioByRangoEdad:
                        statisticsProvider.pesoPromedioByRangoEdad,
                    alturaPromedioByRangoEdad:
                        statisticsProvider.alturaPromedioByRangoEdad,
                    onRazaChanged: (raza) {
                      statisticsProvider.setRazaFilter(raza);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar esta finca?\n\n'
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleFincaDeletion();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
