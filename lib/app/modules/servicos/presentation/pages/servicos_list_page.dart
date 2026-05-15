import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.service.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class ServicosListPage extends BaseController<Servico, ServicoRepository,
    ServicoValidation, ServicoService> {
  ServicosListPage(super.service);

  @override
  Widget buildPage(BuildContext context, ServicoService service) {
    return _ServicosListView(service: service, controller: this);
  }
}

class _ServicosListView extends StatefulWidget {
  final ServicoService service;
  final ServicosListPage controller;

  const _ServicosListView({required this.service, required this.controller});

  @override
  State<_ServicosListView> createState() => _ServicosListViewState();
}

class _ServicosListViewState extends State<_ServicosListView> {
  List<Servico> _servicos = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarServicos();
    });
  }

  Future<void> _carregarServicos() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.findAll(),
      loadingMessage: 'Carregando catálogo de serviços...',
    );
    setState(() => _servicos = result);
  }

  Future<void> _excluirServico(Servico servico) async {
    if (servico.id == null) return;

    final sucesso = await widget.controller.executeCrudOperation(
      context,
      widget.service.delete(servico.id!),
      loadingMessage: 'Removendo serviço do catálogo...',
      successMessage: 'Serviço removido com sucesso!',
    );

    if (sucesso) _carregarServicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Serviços'),
        actions: [
          IconButton(icon: const Icon(AppIcons.refresh), onPressed: _carregarServicos),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        tooltip: 'Novo Serviço',
        onPressed: () => Navigator.pushNamed(context, '/servico/novo').then((value) {
          if (value == true) _carregarServicos();
        }),
      ),
      body: _servicos.isEmpty
          ? const CustomEmptyStateCard(
              icon: AppIcons.build,
              title: 'Nenhum serviço cadastrado',
              message: 'Toque no botão + para alimentar a tabela de preços.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _servicos.length,
              itemBuilder: (context, index) {
                final servico = _servicos[index];
                
                return CustomListCard(
                  // Modificação B e C: Estado ativo e exibição clara de metadados
                  isActive: servico.ativo,
                  title: Text(
                    '#${servico.id} - ${servico.descricao}',
                    style: AppTextStyles.h4.copyWith(
                      color: servico.ativo ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: Text(
                    'Preço base: R\$ ${servico.preco.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: servico.ativo ? AppColors.success : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: CrudPopupMenuButton<Servico>(
                    item: servico,
                    isActive: servico.ativo,
                    onSelected: (action) {
                      if (action == 'editar') {
                        Navigator.pushNamed(context, '/servico/editar', arguments: servico).then((value) {
                          if (value == true) _carregarServicos();
                        });
                      } else if (action == 'excluir') {
                        _excluirServico(servico);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}