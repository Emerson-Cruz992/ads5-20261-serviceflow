import 'package:flutter/material.dart';
import 'dart:io';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

// Inclusão dos repositórios para consulta dos nomes reais
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.repository.dart';

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

  // Repositórios locais para busca de dados de apoio
  final ClienteRepository _clienteRepo = ClienteRepository();
  final TecnicoRepository _tecnicoRepo = TecnicoRepository();

  // Variáveis de estado para armazenar os nomes amigáveis
  String _clienteExibicao = "Carregando...";
  String _tecnicoExibicao = "Carregando...";

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _ordemAtual = widget.ordem;
    _pathFotoDepois = _ordemAtual.fotoDepois;

    // Agendamento pós-frame para buscar os nomes com total segurança
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buscarNomesDeApoio();
    });
  }

  /// Método assíncrono para resolver as chaves estrangeiras e capturar os nomes reais
  Future<void> _buscarNomesDeApoio() async {
    try {
      final clientes = await _clienteRepo.findAll();
      final tecnicos = await _tecnicoRepo.findAll();

      // Encontra as entidades correspondentes pelos IDs da O.S.
      final clienteAlvo = clientes.firstWhere((c) => c.id == _ordemAtual.clienteId);
      final tecnicoAlvo = tecnicos.firstWhere((t) => t.id == _ordemAtual.tecnicoId);

      setState(() {
        // Formatação solicitada: Primeiro o Nome e depois o ID entre parênteses
        _clienteExibicao = "${clienteAlvo.nome} (ID: ${clienteAlvo.id})";
        _tecnicoExibicao = "${tecnicoAlvo.nome} (ID: ${tecnicoAlvo.id})";
      });
    } catch (e) {
      setState(() {
        // Fallback de segurança caso o registro tenha sido removido
        _clienteExibicao = "Cliente Desconhecido (ID: ${_ordemAtual.clienteId})";
        _tecnicoExibicao = "Técnico Desconhecido (ID: ${_ordemAtual.tecnicoId})";
      });
    }
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

    // CORREÇÃO: Alinhamento de propriedades e manutenção estável do tipo de status ativo
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
      ativo: _ordemAtual.ativo, // Mantém compatibilidade com o tipo primitivo original
      isSync: 0, // Indica modificação offline pendente de envio para a nuvem
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
                    // Exibição amigável e dinâmica dos nomes de apoio processados
                    Text("Cliente: $_clienteExibicao"),
                    const SizedBox(height: 6),
                    Text("Técnico: $_tecnicoExibicao"),
                    const SizedBox(height: 6),
                    Text("Peças: ${_ordemAtual.pecasAplicadas ?? 'Nenhuma peça informada'}"),
                    const SizedBox(height: 6),
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