import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/clientes/cliente.service.dart';
import 'package:serviceflow/app/modules/clientes/cliente.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 *  Reestruturação da página de formulário de clientes. Transformaremos o arquivo antigo em um 
 *  StatefulWidget unificado e type-safe que herda do nosso ecossistema base, permitindo carregar 
 *  os dados se for uma edição ou iniciar um formulário limpo se for um novo cadastro.
 */
class ClienteController extends BaseController<Cliente, ClienteRepository,
    ClienteValidation, ClienteService> {
  ClienteController(super.service, {super.model});

  @override
  Widget buildPage(BuildContext context, ClienteService service) {
    return const SizedBox.shrink();
  }
}

class ClienteFormPage extends StatefulWidget {
  final ClienteService service;
  final Cliente? clienteParaEdicao;

  const ClienteFormPage(this.service, {super.key, this.clienteParaEdicao});

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _documentoController = TextEditingController();
  
  late final ClienteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ClienteController(widget.service);
    
    // Se receber um cliente para edição, popula os text fields imediatamente
    if (widget.clienteParaEdicao != null) {
      final c = widget.clienteParaEdicao!;
      _nomeController.text = c.nome;
      _emailController.text = c.email;
      _telefoneController.text = c.telefone;
      _enderecoController.text = c.endereco ?? '';
      _cidadeController.text = c.cidade ?? '';
      _estadoController.text = c.estado ?? '';
      _cepController.text = c.cep ?? '';
      _documentoController.text = c.documento ?? '';
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _documentoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final cliente = Cliente(
      id: widget.clienteParaEdicao?.id,
      nome: _nomeController.text,
      email: _emailController.text,
      telefone: _telefoneController.text,
      documento: _documentoController.text.isEmpty ? null : _documentoController.text,
      endereco: _enderecoController.text.isEmpty ? null : _enderecoController.text,
      cidade: _cidadeController.text.isEmpty ? null : _cidadeController.text,
      estado: _estadoController.text.isEmpty ? null : _estadoController.text,
      cep: _cepController.text.isEmpty ? null : _cepController.text,
      ativo: widget.clienteParaEdicao?.ativo ?? true,
      isSync: 0, // Inicia como pendente de sincronização
    );

    final isUpdate = widget.clienteParaEdicao != null;
    final operation = isUpdate ? widget.service.update(cliente) : widget.service.create(cliente);

    final sucesso = await _controller.executeCrudOperation(
      context,
      operation as Future<void>,
      loadingMessage: 'Gravando dados do cliente...',
      successMessage: 'Cliente salvo com sucesso!',
    );

    if (sucesso) {
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.clienteParaEdicao != null ? 'Editar Cliente' : 'Novo Cliente'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nomeController,
                label: 'Nome',
                prefixIcon: AppIcons.person,
                validator: (value) => (value == null || value.isEmpty) ? 'Nome é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                prefixIcon: AppIcons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? 'Email é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _telefoneController,
                label: 'Telefone',
                prefixIcon: AppIcons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => (value == null || value.isEmpty) ? 'Telefone é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _documentoController,
                label: 'Documento (CPF/CNPJ)',
                prefixIcon: AppIcons.document,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _enderecoController,
                label: 'Endereço',
                prefixIcon: AppIcons.location,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cidadeController,
                label: 'Cidade',
                prefixIcon: AppIcons.location,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _estadoController,
                label: 'Estado',
                prefixIcon: AppIcons.map,
                maxLength: 2,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cepController,
                label: 'CEP',
                prefixIcon: AppIcons.location,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              CustomPrimaryButton(
                text: widget.clienteParaEdicao != null ? 'Atualizar' : 'Salvar',
                icon: AppIcons.save,
                onPressed: _salvar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}