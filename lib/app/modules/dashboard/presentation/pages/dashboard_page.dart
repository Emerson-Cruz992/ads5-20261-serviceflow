import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/dashboard/presentation/controllers/dashboard.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:serviceflow/app/core/services/sync_system_initializer.dart';

class DashboardPage extends StatefulWidget {
  final OrdemServicoService service;
  const DashboardPage(this.service, {super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardController _controller;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _controller = DashboardController(widget.service);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final result = await _controller.executeOperation(
      context,
      widget.service.obterMetricasDashboard(),
      loadingMessage: 'Calculando métricas...',
    );
    if (result != null) setState(() => _stats = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Gerencial')),
      body: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.md),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildMetricCard(
                'Faturamento Total',
                'R\$ ${(_stats['faturamento_total'] ?? 0.0).toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total de O.S.',
                      '${_stats['total_os'] ?? 0}',
                      AppIcons.build,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      'Pendentes Sync',
                      '${_stats['pendentes_sync'] ?? 0}',
                      AppIcons.cloudOff,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CustomQuickActionsPanel(
                actions: [
                  CustomQuickActionButton(
                    icon: AppIcons.refresh,
                    label: 'Sincronizar Agora',
                    onTap: SyncSystemInitializer.forceSyncAll, //
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySmall),
                Text(value, style: AppTextStyles.h2.copyWith(color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}