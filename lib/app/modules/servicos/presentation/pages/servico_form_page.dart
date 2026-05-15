import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.service.dart';
import 'package:serviceflow/app/modules/servicos/servico.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * A função desta classe é processar a gravação com confirmação e,
 * mensagens amigáveis de sucesso ou erro. (Em suma, uma página de 
 * Formulário ou Erro)
 */
class ServicoController extends BaseController<Servico, ServicoRepository,
    ServicoValidation, ServicoService> {
  ServicoController(super.service, {super.model});

  @override
  Widget buildPage(BuildContext context, ServicoService service) {
    return const SizedBox.shrink();
  }
}

class ServicoFormPage extends StatefulWidget {
  final ServicoService service;
  final Servico? servicoParaEdicao;

  const ServicoFormPage(this.service, {super.key, this.servicoParaEdicao});

  @override
  State<ServicoFormPage> createState() => _ServicoFormPageState();
}

class _ServicoFormPageState extends State<ServicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  
  late final ServicoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServicoController(widget.service);
    
    if (widget.servicoParaEdicao != null) {
      _descricaoController.text = widget.servicoParaEdicao!.descricao;
      _precoController.text = widget.servicoParaEdicao!.preco.toString();
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final precoConvertido = double.tryParse(_precoController.text) ?? 0.0;

    final servico = Servico(
      id: widget.servicoParaEdicao?.id,
      descricao: _descricaoController.text,
      preco: precoConvertido,
      ativo: widget.servicoParaEdicao?.ativo ?? true,
      isSync: 0,
    );

    final isUpdate = widget.servicoParaEdicao != null;
    final operation = isUpdate ? widget.service.update(servico) : widget.service.create(servico);

    final sucesso = await _controller.executeCrudOperation(
      context,
      operation as Future<void>,
      loadingMessage: 'Salvando item no catálogo...',
      successMessage: 'Serviço salvo com sucesso!',
    );

    if (sucesso) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicoParaEdicao != null ? 'Editar Serviço' : 'Novo Serviço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _descricaoController,
                label: 'Descrição do Serviço',
                prefixIcon: AppIcons.notes,
                validator: (value) => (value == null || value.isEmpty) ? 'A descrição é obrigatória' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _precoController,
                label: 'Preço Base (R\$)',
                prefixIcon: AppIcons.money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'O preço é obrigatório';
                  if (double.tryParse(value) == null) return 'Insira um valor numérico válido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomPrimaryButton(
                text: widget.servicoParaEdicao != null ? 'Atualizar' : 'Salvar',
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