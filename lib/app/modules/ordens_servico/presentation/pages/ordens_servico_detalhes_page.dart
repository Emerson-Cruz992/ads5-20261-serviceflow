import 'package:flutter/material.dart';
import 'dart:io';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';


class OrdemServicoDetalhesPage extends StatefulWidget {
  final OrdemServicoService service;
  final OrdemServico ordem;

  const OrdemServicoDetalhesPage(this.service, {super.key, required this.ordem});

  @override
  State<OrdemServicoDetalhesPage> createState() => _OrdemServicoDetalhesPageState();
}

class _OrdemServicoDetalhesPageState extends State<OrdemServicoDetalhesPage> {
  String? _pathFotoDepois;
  final ImagePicker _picker = ImagePicker();
  late final OrdemServicoController _controller;
  late final OrdemServico _ordemAtual;

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _ordemAtual = widget.ordem;
    _pathFotoDepois = _ordemAtual.fotoDepois;
  }

  Future<void> _capturarFotoDepois() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pathFotoDepois = image.path;
        });
      }
    } catch (e) {
      _controller.showError(context, "Erro ao acessar a câmara.");
    }
  }

  Future<void> _concluirOS() async {
    if (_pathFotoDepois == null) {
      _controller.showError(context, "A foto do serviço concluído (Depois) é obrigatória para o encerramento.");
      return;
    }

    // Cria uma cópia atualizada da O.S. modificando o status e injetando a evidência final
    final ordemFinalizada = OrdemServico(
      id: _ordemAtual.id,
      clienteId: _ordemAtual.clienteId,
      tecnicoId: _ordemAtual.tecnicoId,
      itens: _ordemAtual.itens,
      observacao: _ordemAtual.observacao,
      pecasAplicadas: _ordemAtual.pecasAplicadas,
      valorPecas: _ordemAtual.valorPecas,
      fotoAntes: _ordemAtual.fotoAntes,
      fotoDepois: _pathFotoDepois,
      assinatura: _ordemAtual.assinatura,
      ativo: false, // Define como inativa/fechada após a conclusão
      isSync: 0,    // Força o agendador de sync a enviar a atualização para o servidor
    );

    final sucesso = await _controller.finalizarOrdemServico(context, ordemFinalizada);
    if (sucesso) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar O.S. #${_ordemAtual.id}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Resumo do Atendimento", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Cliente ID: ${_ordemAtual.clienteId}"),
                    const SizedBox(height: 4),
                    Text("Técnico ID: ${_ordemAtual.tecnicoId}"),
                    const SizedBox(height: 4),
                    Text("Peças: ${_ordemAtual.pecasAplicadas ?? 'Nenhuma peça informada'}"),
                    const SizedBox(height: 4),
                    Text("Valor das Peças: R\$ ${_ordemAtual.valorPecas.toStringAsFixed(2)}"),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text("Evidência Inicial (Antes)", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _ordemAtual.fotoAntes != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.file(File(_ordemAtual.fotoAntes!), fit: BoxFit.cover),
                  )
                : const Text("Nenhuma foto registrada na abertura chamado."),

            const SizedBox(height: 24),
            const Text("Conclusão do Trabalho (Depois)", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _pathFotoDepois == null
                ? ElevatedButton.icon(
                    onPressed: _capturarFotoDepois,
                    icon: const Icon(AppIcons.camera),
                    label: const Text("Registrar Entrega (Foto Depois)"),
                  )
                : Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Image.file(File(_pathFotoDepois!), fit: BoxFit.cover),
                      ),
                      if (_ordemAtual.ativo)
                        TextButton(
                          onPressed: () => setState(() => _pathFotoDepois = null),
                          child: const Text("Substituir Foto", style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),

            const SizedBox(height: 32),
            if (_ordemAtual.ativo)
              CustomPrimaryButton(
                text: 'CONCLUIR E FINALIZAR O.S.',
                icon: AppIcons.check,
                onPressed: _concluirOS,
              ),
          ],
        ),
      ),
    );
  }
}