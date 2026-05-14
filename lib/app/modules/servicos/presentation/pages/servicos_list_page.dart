import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.service.dart';
import 'package:serviceflow/app/modules/servicos/presentation/controllers/servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class ServicosListPage extends StatefulWidget {
  final ServicoService service;
  late final ServicoController controller;

  ServicosListPage(this.service, {super.key}) {
    controller = ServicoController(service);
  }

  @override
  State<ServicosListPage> createState() => _ServicosListPageState();
}

class _ServicosListPageState extends State<ServicosListPage> {
  List<Servico> _servicos = [];

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.listar(),
      loadingMessage: 'Carregando serviços...',
    );

    setState(() {
      _servicos = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: _carregarServicos,
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        onPressed: () => Navigator.pushNamed(context, '/servico/novo'),
      ),
      body: _servicos.isEmpty
          ? const CustomEmptyStateCard(
              icon: AppIcons.build,
              title: 'Nenhum serviço cadastrado',
              message: 'Toque no botão + para adicionar um novo serviço.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _servicos.length,
              itemBuilder: (context, index) {
                final servico = _servicos[index];
                return CustomListCard(
                  title: Text(servico.descricao),
                  subtitle: Text('Preço: R\$ ${servico.preco.toStringAsFixed(2)}'),
                  trailing: CrudPopupMenuButton<Servico>(
                    item: servico,
                    isActive: servico.ativo,
                    onSelected: (action) => _handleAction(action, servico),
                  ),
                );
              },
            ),
    );
  }

  void _handleAction(String action, Servico servico) {
    if (action == 'editar') {
      Navigator.pushNamed(context, '/servico/editar', arguments: servico);
    }
    // Outras ações: excluir, desativar...
  }
}