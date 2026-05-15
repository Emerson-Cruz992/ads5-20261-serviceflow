import 'package:flutter/material.dart';
import 'dart:typed_data'; // essencial para o Uint8List
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.validation.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

/**
 * Este controlador será responsável por carregar as opções de seleção e gerir o estado da Ordem 
 * de Serviço, que está sendo montada.
 */
class OrdemServicoController extends BaseController<
                                      OrdemServico, 
                                      OrdemServicoRepository,
                                      OrdemServicoValidation, 
                                      OrdemServicoService> {
  
  OrdemServicoController(super.service, {super.model}); 

  /*
   * Abaixo, lógica necessária para seleção de imagens - a partir do image picker
   */
  final ImagePicker _picker = ImagePicker();
  String? pathFotoAntes;
  String? pathFotoDepois;

  Future<void> capturarFoto(bool isAntes) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      // a propriedade abaixo serve para comprimir a imagem.
      imageQuality: 80,
    );
    if (image != null) {
      if (isAntes) {
        pathFotoAntes = image.path;
      } else {
        pathFotoDepois = image.path;
      }
    }
  }

  /*
   * Abaixo, lógica necessária para gerir o SignatureController.
   */
  late SignatureController signatureController;
  Uint8List? assinaturaBytes;

  void initSignature() {
    signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    ); // [cite: 497-501]
  }

  Future<void> exportarAssinatura() async {
    if (signatureController.isNotEmpty) {
      assinaturaBytes = await signatureController.toPngBytes(); // [cite: 556]
    }
  }

  void limparAssinatura() {
    signatureController.clear(); // [cite: 551]
    assinaturaBytes = null;
  }

  // Este método é essencial para liberar recursos corretamente e evitar vazamentos de memória
  void disposeSignature() {
    signatureController.dispose(); // [cite: 509]
  }

  Future<bool> salvarNovaOrdem(BuildContext context, OrdemServico novaOS) async {
    return await executeCrudOperation(
      context,
      service.create(novaOS),
      loadingMessage: 'Salvando Ordem de Serviço...',
      successMessage: 'O.S. criada com sucesso!',
      requiresConfirmation: true,
      confirmTitle: 'Confirmar Abertura',
      confirmMessage: 'Deseja abrir esta Ordem de Serviço?',
    );
  }

  // Adicione este método dentro da classe OrdemServicoController existente

  /// Orquestra a atualização e encerramento de uma O.S. em andamento.
  Future<bool> finalizarOrdemServico(BuildContext context, OrdemServico ordemModificada) async {
    return await executeCrudOperation(
      context,
      service.update(ordemModificada), // Persiste as alterações e a Foto Depois no SQLite
      loadingMessage: 'Encerrando ordem de serviço...',
      successMessage: 'O.S. finalizada com sucesso!',
      requiresConfirmation: true,
      confirmTitle: 'Concluir Serviço',
      confirmMessage: 'Deseja realmente encerrar e salvar esta Ordem de Serviço?',
    );
  }

  @override
  Widget buildPage(BuildContext context, OrdemServicoService service) {
    return const SizedBox.shrink();
  }
}