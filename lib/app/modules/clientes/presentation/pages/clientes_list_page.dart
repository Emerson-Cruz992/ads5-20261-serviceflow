import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.service.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';
import 'package:serviceflow/app/shared/widgets/custom_buttons.dart';
import 'package:serviceflow/app/shared/widgets/custom_dialogs.dart';
import 'package:serviceflow/app/shared/widgets/custom_cards.dart';
import 'package:serviceflow/app/shared/widgets/custom_popup_menu.dart';
import 'package:serviceflow/app/shared/constants/app_icons.dart';

class ClientesListPage extends BaseController<Cliente, ClienteRepository,
    ClienteValidation, ClienteService> {
  ClientesListPage(super.service);

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return _ClientesListView(
      service: service,
      controller: this, // Passa o controller para acessar os mixins
    );
  }
}

class _ClientesListView extends StatefulWidget {
  final ClienteService service;
  final ClientesListPage controller;

  const _ClientesListView({
    required this.service,
    required this.controller,
  });

  @override
  State<_ClientesListView> createState() => _ClientesListViewState();
}

class _ClientesListViewState extends State<_ClientesListView> {
  List<Cliente> _clientes = [];
  bool _mostrarInativos = true;

  // Getter para filtrar clientes baseado no estado
  List<Cliente> get _clientesFiltrados {
    if (_mostrarInativos) {
      return _clientes;
    } else {
      return _clientes.where((cliente) => cliente.ativo).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    // Agendamento seguro para executar a carga de dados e o loading 
    // somente após a construção completa da árvore de widgets da página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarClientes();
    });
  }

  Future<void> _carregarClientes() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.listar(),
      loadingMessage: 'Carregando clientes...',
      errorMessage: 'Erro ao carregar lista de clientes',
    );

    setState(() {
      _clientes = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          FilterPopupMenuButton(
            showInactive: _mostrarInativos,
            onChanged: (showInactive) {
              setState(() {
                _mostrarInativos = showInactive;
              });
            },
          ),
          IconButton(
            icon: Icon(AppIcons.refresh),
            tooltip: 'Atualizar lista',
            onPressed: _carregarClientes,
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: AppIcons.add,
        tooltip: 'Adicionar Cliente',
        onPressed: () => Navigator.pushNamed(context, '/cliente/novo'),
      ),
      body: _clientesFiltrados.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _carregarClientes,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _clientesFiltrados.length,
                itemBuilder: (context, index) {
                  final cliente = _clientesFiltrados[index];
                  return _buildClienteCard(cliente);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final isEmpty = _clientes.isEmpty;
    final hasInactiveOnly =
        !isEmpty && _clientesFiltrados.isEmpty && !_mostrarInativos;

    return CustomEmptyStateCard(
      icon: isEmpty ? AppIcons.peopleOutline : AppIcons.visibilityOffOutlined,
      title: isEmpty
          ? 'Nenhum cliente cadastrado'
          : hasInactiveOnly
              ? 'Nenhum cliente ativo encontrado'
              : 'Nenhum cliente encontrado',
      message: isEmpty
          ? 'Toque no botão + para adicionar o primeiro cliente'
          : hasInactiveOnly
              ? 'Ative "Mostrar Inativos" para ver todos os clientes'
              : '',
      action: isEmpty
          ? CustomPrimaryButton(
              text: 'Adicionar Cliente',
              icon: AppIcons.add,
              onPressed: () => Navigator.pushNamed(context, '/cliente/novo'),
              width: null,
            )
          : null,
    );
  }

  Widget _buildClienteCard(Cliente cliente) {
    return CustomListCard(
      isActive: cliente.ativo,
      leading: CustomAvatarCard(
        initials: cliente.nome.isNotEmpty ? cliente.nome[0] : 'C',
        isActive: cliente.ativo,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              cliente.nome,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: cliente.ativo ? null : Colors.grey[600],
                decoration: cliente.ativo ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
          if (!cliente.ativo)
            CustomStatusCard(
              label: 'INATIVO',
              isActive: false,
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cliente.email.isNotEmpty)
            Text(
              cliente.email,
              style: TextStyle(
                  color: cliente.ativo ? Colors.grey[600] : Colors.grey[400]),
            ),
          if (cliente.telefone.isNotEmpty)
            Text(
              cliente.telefone,
              style: TextStyle(
                  color: cliente.ativo ? Colors.grey[600] : Colors.grey[400]),
            ),
        ],
      ),
      trailing: CrudPopupMenuButton<Cliente>(
        item: cliente,
        isActive: cliente.ativo,
        onSelected: (action) => _handleAction(action, cliente),
        showDetails: true,
      ),
      onTap: () => _mostrarDetalhesCliente(cliente),
    );
  }

  void _handleAction(String action, Cliente cliente) {
    switch (action) {
      case 'editar':
        Navigator.pushNamed(context, '/cliente/editar', arguments: cliente);
        break;
      case 'desativar':
        _confirmarDesativacao(cliente);
        break;
      case 'ativar':
        _reativarCliente(cliente);
        break;
      case 'excluir':
        _confirmarExclusao(cliente);
        break;
      case 'detalhes':
        _mostrarDetalhesCliente(cliente);
        break;
    }
  }

  void _mostrarDetalhesCliente(Cliente cliente) {
    showDialog(
      context: context,
      builder: (context) => CustomInfoDialog(
        title: cliente.nome,
        icon: AppIcons.person,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (cliente.email.isNotEmpty)
              CustomInfoCard(
                icon: AppIcons.email,
                title: 'E-mail',
                value: cliente.email,
                showDivider: cliente.telefone.isNotEmpty || cliente.id != null,
              ),
            if (cliente.telefone.isNotEmpty)
              CustomInfoCard(
                icon: AppIcons.phone,
                title: 'Telefone',
                value: cliente.telefone,
                showDivider: cliente.id != null,
              ),
            if (cliente.id != null)
              CustomInfoCard(
                icon: AppIcons.info,
                title: 'ID',
                value: cliente.id.toString(),
                showDivider: false,
              ),
          ],
        ),
        actions: [
          CustomSecondaryButton(
            text: 'Fechar',
            onPressed: () => Navigator.of(context).pop(),
            width: null,
          ),
          CustomActionButton(
            text: 'Editar',
            icon: AppIcons.edit,
            variant: CustomButtonVariant.primary,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/cliente/editar',
                  arguments: cliente);
            },
            width: null,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    // A confirmação agora é feita automaticamente no executeCrudOperation
    await _excluirCliente(cliente);
  }

  Future<void> _confirmarDesativacao(Cliente cliente) async {
    // A confirmação agora é feita automaticamente no executeCrudOperation
    await _desativarCliente(cliente);
  }

  Future<void> _excluirCliente(Cliente cliente) async {
    final sucesso = await widget.controller.executeCrudOperation(
      context,
      widget.service.delete(cliente.id!),
      confirmTitle: 'Confirmar Exclusão',
      confirmMessage:
          'Tem certeza que deseja excluir o cliente ${cliente.nome}? Esta ação não pode ser desfeita.',
      loadingMessage: 'Excluindo cliente...',
      successMessage: 'Cliente excluído com sucesso',
      requiresConfirmation: true,
    );

    if (sucesso) {
      _carregarClientes();
    }
  }

  Future<void> _desativarCliente(Cliente cliente) async {
    final sucesso = await widget.controller.executeCrudOperation(
      context,
      widget.service.softDelete(cliente.id!),
      confirmTitle: 'Confirmar Desativação',
      confirmMessage:
          'Tem certeza que deseja desativar o cliente ${cliente.nome}?',
      loadingMessage: 'Desativando cliente...',
      successMessage: 'Cliente desativado com sucesso',
      requiresConfirmation: true,
    );

    if (sucesso) {
      _carregarClientes();
    }
  }

  Future<void> _reativarCliente(Cliente cliente) async {
    await widget.controller.executeOperation(
      context,
      widget.service.reactivate(cliente.id!),
      loadingMessage: 'Reativando cliente...',
      successMessage: 'Cliente reativado com sucesso',
      showSuccessMessage: true,
    );

    if (true) {
      _carregarClientes();
    }
  }
}
