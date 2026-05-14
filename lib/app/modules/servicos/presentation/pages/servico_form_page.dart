import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.service.dart';
import 'package:serviceflow/app/modules/servicos/presentation/controllers/servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * A função desta classe é processar a gravação com confirmação e,
 * mensagens amigáveis de sucesso ou erro. (Em suma, uma página de 
 * Formulário ou Erro)
 */
class ServicoFormPage extends StatefulWidget {
  final ServicoService service;
  final Servico? servicoParaEdicao;

  const ServicoFormPage(this.service, {super.key, this.servicoParaEdicao});

  @override
  State<ServicoFormPage> createState() => _ServicoFormPageState();
}

class _ServicoFormPageState extends State<ServicoFormPage> {
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _tempoController = TextEditingController();
  late final ServicoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ServicoController(widget.service);
    if (widget.servicoParaEdicao != null) {
      _descricaoController.text = widget.servicoParaEdicao!.descricao;
      _precoController.text = widget.servicoParaEdicao!.preco.toString();
      _tempoController.text = widget.servicoParaEdicao!.tempoEstimado ?? '';
    }
  }

  Future<void> _salvar() async {
    final servico = Servico(
      id: widget.servicoParaEdicao?.id,
      descricao: _descricaoController.text,
      preco: double.tryParse(_precoController.text) ?? 0.0,
      tempoEstimado: _tempoController.text,
    );

    final isUpdate = widget.servicoParaEdicao != null;
    final operation = isUpdate 
        ? widget.service.update(servico) 
        : widget.service.create(servico);

    final sucesso = await _controller.executeCrudOperation(
      context,
      operation as Future<void>,
      loadingMessage: 'Guardando serviço...',
      successMessage: 'Serviço guardado com sucesso!',
    );

    if (sucesso) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servicoParaEdicao == null ? 'Novo Serviço' : 'Editar Serviço'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            CustomTextField(
              controller: _descricaoController,
              label: 'Descrição do Serviço',
              prefixIcon: AppIcons.build,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _precoController,
              label: 'Preço (R\$)',
              prefixIcon: AppIcons.money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _tempoController,
              label: 'Tempo Estimado (ex: 2h)',
              prefixIcon: AppIcons.time,
            ),
            const SizedBox(height: AppSizes.xl),
            CustomPrimaryButton(
              text: 'Guardar Serviço',
              icon: AppIcons.save,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}