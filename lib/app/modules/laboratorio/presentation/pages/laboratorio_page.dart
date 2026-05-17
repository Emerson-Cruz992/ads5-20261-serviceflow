import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class LaboratorioPage extends StatefulWidget {
  const LaboratorioPage({super.key});

  @override
  State<LaboratorioPage> createState() => _LaboratorioPageState();
}

class _LaboratorioPageState extends State<LaboratorioPage> {
  // Estado dos testes de Câmera preservado integralmente
  String? _pathFotoTeste;
  final ImagePicker _picker = ImagePicker();

  // Estado dos testes de Assinatura preservado integralmente
  late SignatureController _signatureController;
  Uint8List? _assinaturaBytes;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: AppColors.primary, // Ajustado para usar o token de cor padrão
      exportBackgroundColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _testarCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      setState(() {
        _pathFotoTeste = image.path;
      });
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
            
            // Componente homologado da biblioteca para seleção e navegação
            CustomMenuCard(
              title: 'Tabela de Usuários',
              description: 'Listar credenciais gravadas no SQLite',
              icon: Icons.supervised_user_circle,
              color: AppColors.primary, // Ajustado para token de design consistente
              onTap: () => Navigator.pushNamed(context, '/laboratorio/usuarios'),
            ),
            
            const SizedBox(height: 32),
            const Text("Testes Nativos de Hardware", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            
            // Seção de Câmera - Refatorada sem Card nativo e com botões homologados
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
            
            // Seção de Assinatura - Refatorada removendo decorações manuais e botões nativos
            Text("Módulo de Assinatura (Canvas)", style: AppTextStyles.h4),
            const SizedBox(height: 4),
            const Text("Conversão de entrada gestual em stream binária PNG", style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                color: AppColors.light, // Uso obrigatório de token de cor de fundo
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
                      final bytes = await _signatureController.toPngBytes();
                      setState(() => _assinaturaBytes = bytes);
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
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}