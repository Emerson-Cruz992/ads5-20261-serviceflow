import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/presentation/controllers/tecnico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * A página TecnicoListPage é responsável por exibir todos os profissionais registrados no sistema. 
 * Ela utiliza o método executeListOperation para gerir automaticamente o estado de carregamento e a
 * exibição de mensagens caso ococrra algum erro na base de dados SQLite. A interface utiliza o
 * CustomListCard para manter a consistência visual com o restante da aplicação
 */
class TecnicosListPage extends TecnicoController {
  TecnicosListPage(super.service);

  @override
  Widget buildPage(BuildContext context, TecnicoService service) {
    return _TecnicosListView(service: service, controller: this);
  }
}

class _TecnicosListView extends StatefulWidget {
  final TecnicoService service;
  final TecnicosListPage controller;

  const _TecnicosListView({required this.service, required this.controller});

  @override
  State<_TecnicosListView> createState() => _TecnicosListViewState();
}

class _TecnicosListViewState extends State<_TecnicosListView> {
  List<Tecnico> _tecnicos = [];

  @override
  void initState() {
    super.initState();
    _carregarTecnicos();
  }

  Future<void> _carregarTecnicos() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.findAllActive(),
      loadingMessage: 'Carregando técnicos disponíveis...',
    );
    setState(() => _tecnicos = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Técnicos'),
        actions: [
          IconButton(icon: Icon(AppIcons.refresh), onPressed: _carregarTecnicos),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        onPressed: () => Navigator.pushNamed(context, '/tecnico/novo').then((value) {
          if (value == true) _carregarTecnicos();
        }),
      ),
      body: _tecnicos.isEmpty
          ? const CustomEmptyStateCard(
              icon: AppIcons.person,
              title: 'Nenhum técnico encontrado!',
              message: 'Toque no botão + para registar o primeiro técnico.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.sm),
              itemCount: _tecnicos.length,
              itemBuilder: (context, index) {
                final tecnico = _tecnicos[index];
                return CustomListCard(
                  leading: CustomAvatarCard(initials: tecnico.nome[0]),
                  title: Text(tecnico.nome, style: AppTextStyles.h4),
                  subtitle: Text(tecnico.especialidade ?? 'Geral'),
                  trailing: CrudPopupMenuButton<Tecnico>(
                    item: tecnico,
                    isActive: tecnico.ativo,
                    onSelected: (action) => _handleAction(action, tecnico),
                  ),
                );
              },
            ),
    );
  }

  void _handleAction(String action, Tecnico tecnico) {
  if (action == 'editar') {
    Navigator.pushNamed(
      context, 
      '/tecnico/editar', 
      arguments: tecnico,
    ).then((value) {
      // Usando chaves para permitir instruções como o 'if'
      if (value == true) {
        _carregarTecnicos();
      }
    });
  }
}
}