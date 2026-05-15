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
  // Estado dos testes de Câmera
  String? _pathFotoTeste;
  final ImagePicker _picker = ImagePicker();

  // Estado dos testes de Assinatura
  late SignatureController _signatureController;
  Uint8List? _assinaturaBytes;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.purple,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Inspeção de Dados Locais", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            
            // Custom Card solicitado para selecionar e navegar até a listagem de usuários
            CustomMenuCard(
              title: 'Tabela de Usuários',
              description: 'Listar credenciais gravadas no SQLite',
              icon: Icons.supervised_user_circle,
              color: Colors.purple,
              onTap: () => Navigator.pushNamed(context, '/laboratorio/usuarios'),
            ),
            
            const SizedBox(height: 28),
            const Text("Testes Nativos de Hardware", style: AppTextStyles.h3),
            const SizedBox(height: 16),
            
            // Preservação do Bloco Original de Câmera
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(AppIcons.camera, color: Colors.purple),
                      title: Text("Módulo de Captura (Câmera)"),
                      subtitle: Text("Validação de Platform Channels e permissões"),
                    ),
                    if (_pathFotoTeste != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.file(File(_pathFotoTeste!), height: 120, fit: BoxFit.cover),
                      ),
                    ElevatedButton(
                      onPressed: _testarCamera,
                      child: const Text("Disparar Câmera de Testes"),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preservação do Bloco Original de Assinatura por Gesto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.gesture, color: Colors.purple),
                      title: Text("Módulo de Assinatura (Canvas)"),
                      subtitle: Text("Conversão de entrada gestual em stream PNG"),
                    ),
                    Container(
                      color: Colors.grey[200],
                      child: Signature(controller: _signatureController, height: 100),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => _signatureController.clear(),
                          child: const Text("Limpar"),
                        ),
                        TextButton(
                          onPressed: () async {
                            final bytes = await _signatureController.toPngBytes();
                            setState(() => _assinaturaBytes = bytes);
                          },
                          child: const Text("Capturar Bytes"),
                        ),
                      ],
                    ),
                    if (_assinaturaBytes != null)
                      const Text("✔ Stream de bytes gerada com sucesso!", style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}