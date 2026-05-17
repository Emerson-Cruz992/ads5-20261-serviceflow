import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Obrigatório para interceptar PlatformException de hardware
import 'dart:developer' as developer; // Obrigatório para o registro de logs técnicos sem silenciar falhas
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';
import 'package:serviceflow/app/core/mixins/messages.mixin.dart'; // Mixin para exibição padronizada de mensagens

class LaboratorioPage extends StatefulWidget {
  const LaboratorioPage({super.key});

  @override
  State<LaboratorioPage> createState() => _LaboratorioPageState();
}

// CORREÇÃO: Inclusão do MessagesMixin para padronizar os alertas visuais de erro na interface
class _LaboratorioPageState extends State<LaboratorioPage> with MessagesMixin {
  String? _pathFotoTeste;
  final ImagePicker _picker = ImagePicker();

  late SignatureController _signatureController;
  Uint8List? _assinaturaBytes;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primary, 
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  /// Executa o teste do sensor de captura tratando especificamente as exceções de plataforma
  Future<void> _testarCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      if (image != null) {
        setState(() {
          _pathFotoTeste = image.path;
        });
      }
    } on PlatformException catch (e, stackTrace) {
      // REGRA: Tratamento especializado para falhas nativas de barramento ou permissões negadas
      developer.log(
        'Negação de permissão ou falha de inicialização no hardware da câmera',
        error: e,
        stackTrace: stackTrace,
        name: 'ServiceFlow.Laboratorio',
      );
      showError(context, "Permissão de acesso à câmera negada pelo sistema operacional.");
    } catch (e, stackTrace) {
      // REGRA: Captura genérica obrigatória acompanhada de logging adequado para depuração
      developer.log(
        'Exceção imprevista detectada durante a execução do seletor de imagens',
        error: e,
        stackTrace: stackTrace,
        name: 'ServiceFlow.Laboratorio',
      );
      showError(context, "Não foi possível carregar o componente nativo da câmera.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laboratório de Hardware & Dados')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Inspeção de Dados Locais", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            
            CustomMenuCard(
              title: 'Tabela de Usuários',
              description: 'Listar credenciais gravadas no SQLite',
              icon: Icons.supervised_user_circle,
              color: AppColors.primary, 
              onTap: () => Navigator.pushNamed(context, '/laboratorio/usuarios'),
            ),
            
            const SizedBox(height: 32),
            const Text("Testes Nativos de Hardware", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            
            Text("Módulo de Captura (Câmera)", style: AppTextStyles.h4),
            const SizedBox(height: 4),
            const Text("Validação de Platform Channels e permissões do sistema", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            if (_pathFotoTeste != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.file(File(_pathFotoTeste!), fit: BoxFit.cover),
                ),
              ),
            CustomPrimaryButton(
              text: "Disparar Câmera de Testes",
              icon: AppIcons.camera,
              onPressed: _testarCamera,
            ),
            
            const SizedBox(height: 32),
            
            Text("Módulo de Assinatura (Canvas)", style: AppTextStyles.h4),
            const SizedBox(height: 4),
            const Text("Conversão de entrada gestual em stream binária PNG", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                color: AppColors.light, 
              ),
              child: Signature(
                controller: _signatureController, 
                height: 120,
                backgroundColor: AppColors.light,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomPrimaryButton(
                    text: "Limpar Canvas",
                    icon: AppIcons.clear,
                    onPressed: () => _signatureController.clear(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomPrimaryButton(
                    text: "Capturar Bytes",
                    icon: AppIcons.check,
                    onPressed: () async {
                      // CORREÇÃO: Tratamento de exceções com rastro de log ao exportar a imagem do canvas
                      try {
                        final bytes = await _signatureController.toPngBytes();
                        setState(() {
                          _assinaturaBytes = bytes;
                        });
                      } catch (e, stackTrace) {
                        developer.log(
                          'Falha crítica ao converter a entrada gestual em stream de bytes PNG',
                          error: e,
                          stackTrace: stackTrace,
                          name: 'ServiceFlow.Laboratorio',
                        );
                        showError(context, "Erro interno ao processar os dados binários da assinatura.");
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_assinaturaBytes != null)
              const Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Text(
                  "✔ Stream de bytes gerada com sucesso!", 
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}