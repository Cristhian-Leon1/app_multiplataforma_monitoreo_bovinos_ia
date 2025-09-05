import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/finca_registration_widget.dart';
import '../widgets/finca_stats_widget.dart';

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
        // Mostrar loading mientras se inicializa
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

        return RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF4CAF50),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Frase descriptiva
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Visualiza información relevante de tu ganado para tomar mejores decisiones.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

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

                // Contenido principal
                if (!statisticsProvider.hasFincas)
                  // Mostrar formulario de registro de finca
                  FincaRegistrationWidget(
                    controller: statisticsProvider.fincaNameController,
                    validator: statisticsProvider.validateFincaName,
                    onChanged: statisticsProvider.onFincaNameChanged,
                    onRegister: _handleFincaRegistration,
                    isLoading: statisticsProvider.isCreatingFinca,
                  )
                else
                  // Mostrar estadísticas de la finca
                  FincaStatsWidget(
                    finca: statisticsProvider.selectedFinca!,
                    totalBovinos: statisticsProvider.totalBovinos,
                    bovinosSanos: statisticsProvider.bovinosSanos,
                    bovinosAlerta: statisticsProvider.bovinosAlerta,
                    analisisRealizados: statisticsProvider.analisisRealizados,
                    onDeleteFinca: _handleFincaDeletion,
                  ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
