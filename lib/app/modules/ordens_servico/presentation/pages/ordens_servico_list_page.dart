import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class OrdensServicoListPage extends OrdemServicoController {
  OrdensServicoListPage(super.service);

  @override
  Widget buildPage(BuildContext context, OrdemServicoService service) {
    return _OrdensServicoListView(service: service, controller: this);
  }
}

class _OrdensServicoListView extends StatefulWidget {
  final OrdemServicoService service;
  final OrdensServicoListPage controller;

  const _OrdensServicoListView({required this.service, required this.controller});

  @override
  State<_OrdensServicoListView> createState() => _OrdensServicoListViewState();
}

class _OrdensServicoListViewState extends State<_OrdensServicoListView> {
  List<OrdemServico> _ordens = [];

  @override
  void initState() {
    super.initState();
    _carregarOrdens();
  }

  Future<void> _carregarOrdens() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.findAll(), // Busca todas do SQLite 
      loadingMessage: 'A carregar ordens de serviço...',
    );
    setState(() => _ordens = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(icon: const Icon(AppIcons.refresh), onPressed: _carregarOrdens),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        tooltip: 'Nova O.S.',
        onPressed: () => Navigator.pushNamed(context, '/ordem-servico/novo').then((value) {
          if (value == true) _carregarOrdens();
        }),
      ),
      body: _ordens.isEmpty
          ? const CustomEmptyStateCard(
              icon: AppIcons.build,
              title: 'Nenhuma O.S. encontrada',
              message: 'Toque no botão + para abrir uma nova ordem de serviço.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.sm),
              itemCount: _ordens.length,
              itemBuilder: (context, index) {
                final os = _ordens[index];
                return CustomListCard(
                  isActive: os.ativo,
                  title: Text('O.S. #${os.id}', style: AppTextStyles.h4),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente ID: ${os.clienteId}'),
                      Text('Total: R\$ ${os.valorTotal.toStringAsFixed(2)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicador visual de sincronização
                      Icon(
                        os.isSync == 1 ? AppIcons.cloud : AppIcons.cloudOff,
                        size: 16,
                        color: os.isSync == 1 ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      CrudPopupMenuButton<OrdemServico>(
                        item: os,
                        isActive: os.ativo,
                        onSelected: (action) {
                          // Lógica de detalhes ou edição
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}