import 'package:flutter/material.dart';
import 'dart:io';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/presentation/controllers/ordem_servico.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:signature/signature.dart';

/**
 *  Preservação da Arquitetura proposta pela atividade:
 *  Na OrdemServicoFormPage, utilizaremos um operador ternário para substituir o botão de captura 
 *  por uma miniatura (thumbnail) da foto assim que ela for tirada. Para exibir imagens locais a 
 *  partir do caminho (path), utilizamos o widget Image.file().
 */
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
  
  late final OrdemServicoController _controller;
  
  // IDs selecionados (em um cenário real, viriam de um Dropdown ou Busca)
  int? _clienteId;
  int? _tecnicoId;

  @override
  void initState() {
    super.initState();
    _controller = OrdemServicoController(widget.service);
    _controller.initSignature(); // inicializa o canvas da assinatura
  }

  //chama o método dispose para fazer a liberação de memória
  @override
  void dispose(){
    _controller.disposeSignature();
    super.dispose();
  }

  Future<void> _salvarOS() async {
    if (_clienteId == null || _tecnicoId == null) {
      _controller.showError(context, "Selecione o Cliente e o Técnico.");
      return;
    }

    final novaOS = OrdemServico(
      clienteId: _clienteId!,
      tecnicoId: _tecnicoId!,
      itens: _controller.itensSelecionados,
      observacao: _obsController.text,
      pecasAplicadas: _pecasController.text,
      valorPecas: double.tryParse(_valorPecasController.text) ?? 0.0,
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
                
                // Placeholder para Seleção de Cliente/Técnico
                // Em implementação real, usar CustomDropdown ou campos de busca
                ListTile(
                  title: Text(_clienteId == null ? "Selecionar Cliente" : "Cliente ID: $_clienteId"),
                  leading: const Icon(AppIcons.person),
                  onTap: () => setState(() => _clienteId = 1), // Simulação
                  tileColor: Colors.grey[100],
                ),

                const SizedBox(height: 8),

                ListTile(
                  title: Text(_tecnicoId == null ? "Selecionar Técnico" : "Técnico ID: $_tecnicoId"),
                  leading: const Icon(AppIcons.handyman),
                  onTap: () => setState(() => _tecnicoId = 1), // Simulação
                  tileColor: Colors.grey[100],
                ),

                const SizedBox(height: 24),

                const Text("Serviços Realizados", style: AppTextStyles.h3),
                
                // Lista dinâmica de itens selecionado
                ..._controller.itensSelecionados.asMap().entries.map((entry) {
                  return CustomListCard(
                    title: Text(entry.value.descricao),
                    subtitle: Text("R\$ ${entry.value.preco}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => setState(() => _controller.removerServico(entry.key)),
                    ),
                  );
                }),
                
                TextButton.icon(
                  onPressed: () {
                    // Simulação de adição de serviço
                    setState(() => _controller.adicionarServico(
                      Servico(id: 1, descricao: "Manutenção Preventiva", preco: 150.0)
                    ));
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar Serviço"),
                ),

                const SizedBox(height: 24),

                CustomTextField(
                  controller: _obsController,
                  label: "Observações Gerais",
                  prefixIcon: AppIcons.notes,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _pecasController,
                  label: "Peças Aplicadas",
                  prefixIcon: AppIcons.build,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _valorPecasController,
                  label: "Valor Total das Peças",
                  prefixIcon: AppIcons.money,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                //WIDGET PARA TIRAR FOTOS ANTES E DEPOIS
                const SizedBox(height: 24),
                const Text("Evidências Fotográficas", style: AppTextStyles.h3),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Foto Antes
                    Expanded(
                      child: _controller.pathFotoAntes == null 
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              await _controller.capturarFoto(true);
                              setState(() {}); // Atualiza para mostrar o preview
                            },
                            icon: const Icon(AppIcons.camera),
                            label: const Text("Foto Antes"),
                          )
                        : Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.file(File(_controller.pathFotoAntes!), fit: BoxFit.cover),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _controller.pathFotoAntes = null),
                                child: const Text("Remover", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(width: 16),
                    // Foto Depois
                    Expanded(
                      child: _controller.pathFotoDepois == null 
                        ? ElevatedButton.icon(
                            onPressed: () async {
                              await _controller.capturarFoto(false);
                              setState(() {});
                            },
                            icon: const Icon(AppIcons.camera),
                            label: const Text("Foto Depois"),
                          )
                        : Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Image.file(File(_controller.pathFotoDepois!), fit: BoxFit.cover),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _controller.pathFotoDepois = null),
                                child: const Text("Remover", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                    ),
                  ],
                ),

                //WIDGET DA ASSINATURA
                const SizedBox(height: 24),
                const Text("Assinatura do Cliente", style: AppTextStyles.h3),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    color: AppColors.light, // [cite: 549]
                  ),
                  child: Signature(
                    controller: _controller.signatureController,
                    height: 150,
                    backgroundColor: AppColors.light,
                  ), // [cite: 512-515]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _controller.limparAssinatura()),
                      icon: const Icon(AppIcons.clear, color: AppColors.danger),
                      label: const Text("Limpar", style: TextStyle(color: AppColors.danger)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await _controller.exportarAssinatura();
                        setState(() {}); // Bloqueia ou mostra preview se desejar
                      },
                      icon: const Icon(AppIcons.check, color: AppColors.success),
                      label: const Text("Confirmar Assinatura", style: TextStyle(color: AppColors.success)),
                    ),
                  ],
                ),

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