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

// Inclusão dos repositórios e modelos necessários para as consultas reais do banco
import 'package:serviceflow/app/modules/clientes/client.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';

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

  // Instanciação dos repositórios para acesso direto aos dados locais
  final ClienteRepository _clienteRepo = ClienteRepository();
  final TecnicoRepository _tecnicoRepo = TecnicoRepository();
  final ServicoRepository _servicoRepo = ServicoRepository();

  // Coleções dinâmicas que alimentarão os seletores da interface
  List<Cliente> _clientesDisponiveis = [];
  List<Tecnico> _tecnicosDisponiveis = [];
  List<Servico> _servicosDisponiveis = [];

  final List<Servico> _itensSelecionados = [];
  String? _pathFotoAntes; 
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

    // Dispara a carga assíncrona dos registros reais logo após o desenho do layout básico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosDeApoio();
    });
  }

  @override
  void dispose() {
    _obsController.dispose();
    _pecasController.dispose();
    _valorPecasController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  /// Consulta as tabelas do SQLite filtrando apenas as entidades ativas no sistema
  Future<void> _carregarDadosDeApoio() async {
    try {
      final clientes = await _clienteRepo.findAll();
      final tecnicos = await _tecnicoRepo.findAll();
      final servicos = await _servicoRepo.findAll();

      setState(() {
        _clientesDisponiveis = clientes.where((c) => c.ativo).toList();
        _tecnicosDisponiveis = tecnicos.where((t) => t.ativo).toList();
        _servicosDisponiveis = servicos.where((s) => s.ativo).toList();
      });
    } catch (e) {
      _controller.showError(context, "Erro ao carregar dados dos cadastros de apoio.");
    }
  }

  /// Apresenta uma caixa de diálogo contendo os serviços ativos do catálogo de preços
  void _exibirSeletorServicos() {
    if (_servicosDisponiveis.isEmpty) {
      _controller.showError(context, "Nenhum serviço ativo encontrado no catálogo.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        Servico? servicoSelecionado = _servicosDisponiveis.first;
        
        return AlertDialog(
          title: const Text("Selecionar Serviço"),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButtonFormField<Servico>(
                value: servicoSelecionado,
                decoration: const InputDecoration(labelText: 'Serviço disponível'),
                items: _servicosDisponiveis.map((s) {
                  return DropdownMenuItem<Servico>(
                    value: s,
                    child: Text("${s.descricao} (R\$ ${s.preco.toStringAsFixed(2)})"),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() {
                    servicoSelecionado = value;
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (servicoSelecionado != null) {
                  setState(() {
                    _itensSelecionados.add(servicoSelecionado!);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _capturarFoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _pathFotoAntes = image.path;
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

    await _exportarAssinatura();

    final novaOS = OrdemServico(
      clienteId: _clienteId!,
      tecnicoId: _tecnicoId!,
      itens: _itensSelecionados,
      observacao: _obsController.text,
      pecasAplicadas: _pecasController.text,
      valorPecas: double.tryParse(_valorPecasController.text) ?? 0.0,
      fotoAntes: _pathFotoAntes,
      fotoDepois: null, 
      assinatura: _assinaturaBytes != null ? _assinaturaBytes.hashCode.toString() : null,
    );

    final sucesso = await _controller.salvarNovaOrdem(context, novaOS);

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
                
                // Campo dinâmico e real para seleção do Cliente cadastrado
                DropdownButtonFormField<int>(
                  value: _clienteId,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Cliente',
                    prefixIcon: Icon(AppIcons.person),
                  ),
                  items: _clientesDisponiveis.map((cliente) {
                    return DropdownMenuItem<int>(
                      value: cliente.id,
                      child: Text(cliente.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _clienteId = value),
                  validator: (value) => value == null ? 'Por favor, selecione um cliente' : null,
                ),
                
                const SizedBox(height: 16),

                // Campo dinâmico e real para seleção do Técnico cadastrado
                DropdownButtonFormField<int>(
                  value: _tecnicoId,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Técnico',
                    prefixIcon: Icon(AppIcons.handyman),
                  ),
                  items: _tecnicosDisponiveis.map((tecnico) {
                    return DropdownMenuItem<int>(
                      value: tecnico.id,
                      child: Text(tecnico.nome),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _tecnicoId = value),
                  validator: (value) => value == null ? 'Por favor, selecione um técnico' : null,
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
                
                // Botão reconfigurado para acionar a busca real de serviços ativos no catálogo
                TextButton.icon(
                  onPressed: _exibirSeletorServicos,
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
                const Text("Evidência Fotográfica Inicial", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                
                _pathFotoAntes == null 
                  ? ElevatedButton.icon(
                      onPressed: _capturarFoto,
                      icon: const Icon(AppIcons.camera),
                      label: const Text("Registrar Estado Inicial (Antes)"),
                    )
                  : Column(
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.file(File(_pathFotoAntes!), fit: BoxFit.cover),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _pathFotoAntes = null),
                          child: const Text("Remover Foto", style: TextStyle(color: Colors.red)),
                        ),
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