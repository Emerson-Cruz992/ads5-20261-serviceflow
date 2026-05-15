import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data'; // Essencial para o Uint8List
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:signature/signature.dart';
import 'package:image_picker/image_picker.dart';

class OrdemServicoFormPage extends StatefulWidget {
  final OrdemServicoService service;
  const OrdemServicoFormPage(this.service, {super.key});

  @override
  State<OrdemServicoFormPage> createState() => _OrdemServicoFormPageState();
}

class _OrdemServicoFormPageState extends State<OrdemServicoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _obsController = TextEditingController();
  final _pecasController = TextEditingController();
  final _valorPecasController = TextEditingController();

  // Estado mutável movido com sucesso para o State local (Solução must_be_immutable)
  final List<Servico> _itensSelecionados = [];
  String? _pathFotoAntes;
  String? _pathFotoDepois;
  late SignatureController _signatureController;
  Uint8List? _assinaturaBytes;
  
  final ImagePicker _picker = ImagePicker();
  late final OrdemServicoController _controller;  
  
  int? _clienteId;
  int? _tecnicoId;

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _obsController.dispose();
    _pecasController.dispose();
    _valorPecasController.dispose();
    _signatureController.dispose(); // Liberação nativa de recursos local
    super.dispose();
  }

  Future<void> _capturarFoto(bool isAntes) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (isAntes) {
            _pathFotoAntes = image.path;
          } else {
            _pathFotoDepois = image.path;
          }
        });
      }
    } catch (e) {
      _controller.showError(context, "Erro ao acessar a câmara.");
    }
  }

  void _limparAssinatura() {
    _signatureController.clear();
    setState(() {
      _assinaturaBytes = null;
    });
  }

  Future<void> _exportarAssinatura() async {
    if (_signatureController.isNotEmpty) {
      final bytes = await _signatureController.toPngBytes();
      setState(() {
        _assinaturaBytes = bytes;
      });
    }
  }

  Future<void> _salvarOS() async {
    if (_clienteId == null || _tecnicoId == null) {
      _controller.showError(context, "Selecione o Cliente e o Técnico.");
      return;
    }

    // Garante a exportação dos bytes antes de enviar para persistência
    await _exportarAssinatura();

    final novaOS = OrdemServico(
      clienteId: _clienteId!,
      tecnicoId: _tecnicoId!,
      itens: _itensSelecionados,
      observacao: _obsController.text,
      pecasAplicadas: _pecasController.text,
      valorPecas: double.tryParse(_valorPecasController.text) ?? 0.0,
      fotoAntes: _pathFotoAntes,
      fotoDepois: _pathFotoDepois,
      assinatura: _assinaturaBytes != null ? _assinaturaBytes.hashCode.toString() : null, // Simulação de hash/string do path
    );

    final sucesso = await _controller.executeCrudOperation(
      context,
      widget.service.create(novaOS),
      loadingMessage: 'Salvando Ordem de Serviço...',
      successMessage: 'O.S. criada com sucesso!',
      requiresConfirmation: true,
      confirmTitle: 'Confirmar Abertura',
      confirmMessage: 'Deseja abrir esta Ordem de Serviço?',
    );

    if (sucesso) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar(title: const Text('Nova O.S.')),
      body: SafeArea( 
        child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0), 
          child: Form( 
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Dados Principais", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                
                ListTile(
                  title: Text(_clienteId == null ? "Selecionar Cliente" : "Cliente ID: $_clienteId"),
                  leading: const Icon(AppIcons.person),
                  onTap: () => setState(() => _clienteId = 1),
                  tileColor: Colors.grey[100],
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(_tecnicoId == null ? "Selecionar Técnico" : "Técnico ID: $_tecnicoId"),
                  leading: const Icon(AppIcons.handyman),
                  onTap: () => setState(() => _tecnicoId = 1),
                  tileColor: Colors.grey[100],
                ),

                const SizedBox(height: 24),
                const Text("Serviços Realizados", style: AppTextStyles.h3),
                
                ..._itensSelecionados.asMap().entries.map((entry) {
                  return CustomListCard(
                    title: Text(entry.value.descricao),
                    subtitle: Text("R\$ ${entry.value.preco}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => setState(() => _itensSelecionados.removeAt(entry.key)),
                    ),
                  );
                }),
                
                TextButton.icon(
                  onPressed: () {
                    setState(() => _itensSelecionados.add(
                      Servico(id: 1, descricao: "Manutenção Preventiva", preco: 150.0)
                    ));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar Serviço"),
                ),

                const SizedBox(height: 24),
                CustomTextField(controller: _obsController, label: "Observações Gerais", prefixIcon: AppIcons.notes),
                const SizedBox(height: 16),
                CustomTextField(controller: _pecasController, label: "Peças Aplicadas", prefixIcon: AppIcons.build),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _valorPecasController, 
                  label: "Valor Total das Peças", 
                  prefixIcon: AppIcons.money,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),
                const Text("Evidências Fotográficas", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _pathFotoAntes == null 
                        ? ElevatedButton.icon(
                            onPressed: () => _capturarFoto(true),
                            icon: const Icon(AppIcons.camera),
                            label: const Text("Foto Antes"),
                          )
                        : Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.file(File(_pathFotoAntes!), fit: BoxFit.cover),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _pathFotoAntes = null),
                                child: const Text("Remover", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(width: 16),                    
                  ],
                ),

                const SizedBox(height: 24),
                const Text("Assinatura do Cliente", style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    color: AppColors.light,
                  ),
                  child: Signature(
                    controller: _signatureController,
                    height: 150,
                    backgroundColor: AppColors.light,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: _limparAssinatura,
                      icon: const Icon(AppIcons.clear, color: AppColors.danger),
                      label: const Text("Limpar", style: TextStyle(color: AppColors.danger)),
                    ),
                    TextButton.icon(
                      onPressed: _exportarAssinatura,
                      icon: const Icon(AppIcons.check, color: AppColors.success),
                      label: const Text("Confirmar Assinatura", style: TextStyle(color: AppColors.success)),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                CustomPrimaryButton(
                  text: 'FINALIZAR E SALVAR',
                  icon: AppIcons.save,
                  onPressed: _salvarOS,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}