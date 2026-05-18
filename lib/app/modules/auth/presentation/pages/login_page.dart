import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/mixins/loader.mixin.dart';
import 'package:serviceflow/app/core/mixins/messages.mixin.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with MessagesMixin, LoaderMixin {
  late TextEditingController emailController;
  late TextEditingController senhaController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    senhaController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  void _realizarLogin() {
    // Validação básica dos campos
    if (emailController.text.trim().isEmpty) {
      showError(context, "Por favor, informe o e-mail");
      return;
    }

    if (senhaController.text.trim().isEmpty) {
      showError(context, "Por favor, informe a senha");
      return;
    }

    // Aqui você pode implementar a lógica de autenticação
    // Por exemplo: chamar um service, validar no Supabase, etc.
    showLoading(context);

    // Simulação de delay de autenticação (remover em produção)
    Future.delayed(const Duration(seconds: 2), () {
      hideLoading(context);
      // TODO: Implementar lógica real de login
      // Se login for bem-sucedido, navegar para tela principal
      Navigator.pushReplacementNamed(context, '/home');
      showSuccess(context, "Login realizado com sucesso!");
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usando Scaffold e Padding para estruturar a tela
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para manter a identidade visual escura
      body: Center(
        child: SingleChildScrollView(
          // Evita quebra de layout com teclado
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- INSERÇÃO DO LOGO ---
              // Usando o widget reutilizável que criamos
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: AppLogo(width: double.infinity, height: 250),
              ),

              const SizedBox(height: 48), // Espaçamento entre logo e campos

              // Campos de texto e botão (reaproveitando exemplo anterior)
              CustomTextField(label: "E-mail", controller: emailController),
              const SizedBox(height: 16),
              CustomTextField(
                  label: "Senha",
                  isPassword: true,
                  controller: senhaController),
              const SizedBox(height: 32),
              CustomPrimaryButton(
                text: 'Entrar',
                icon: AppIcons.login,
                onPressed: _realizarLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
