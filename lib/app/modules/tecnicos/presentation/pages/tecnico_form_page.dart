import 'package:flutter/material.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.service.dart';
import 'package:serviceflow/app/modules/tecnicos/presentation/controllers/tecnico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 * O TecnicoFormPage permite a criação de novos perfis ou atualização de existentes. A lógica de gravação
 * é encapsulada pelo executeCrudOperation, que solicita uma confirmação ao utilizador se configurado
 * e apresenta o indicador de progresso durante a persistência. Para a entrada de dados, são utilizados
 * os campos de texto padronizados CustomTextField
 */
class TecnicoFormPage extends StatefulWidget {
  final TecnicoService service;
  final Tecnico? tecnicoParaEdicao;

  const TecnicoFormPage(this.service, {super.key, this.tecnicoParaEdicao});

  @override
  State<TecnicoFormPage> createState() => _TecnicoFormPageState();
}

class _TecnicoFormPageState extends State<TecnicoFormPage> {
  final _nomeController = TextEditingController();
  final _especialidadeController = TextEditingController();
  late final TecnicoController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TecnicoController(widget.service);
    if (widget.tecnicoParaEdicao != null) {
      _nomeController.text = widget.tecnicoParaEdicao!.nome;
      _especialidadeController.text = widget.tecnicoParaEdicao!.especialidade ?? '';
    }
  }

  Future<void> _salvar() async {
    final tecnico = Tecnico(
      id: widget.tecnicoParaEdicao?.id,
      nome: _nomeController.text,
      especialidade: _especialidadeController.text,
    );

    final isUpdate = widget.tecnicoParaEdicao != null;
    final operation = isUpdate 
        ? widget.service.update(tecnico) 
        : widget.service.create(tecnico);

    final sucesso = await _controller.executeCrudOperation(
      context,
      operation as Future<void>,
      loadingMessage: 'Salvandos dados do técnico...',
      successMessage: 'Profissional salvo com sucesso!',
    );

    if (sucesso) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tecnicoParaEdicao == null ? 'Novo Técnico' : 'Editar Técnico'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            CustomTextField(
              controller: _nomeController,
              label: 'Nome Completo',
              prefixIcon: AppIcons.person,
            ),
            const SizedBox(height: AppSizes.md),
            CustomTextField(
              controller: _especialidadeController,
              label: 'Especialidade (ex: Automação Industrial)',
              prefixIcon: AppIcons.build,
            ),
            const SizedBox(height: AppSizes.xl),
            CustomPrimaryButton(
              text: 'Guardar Técnico',
              icon: AppIcons.save,
              onPressed: _salvar,
            ),
          ],
        ),
      ),
    );
  }
}