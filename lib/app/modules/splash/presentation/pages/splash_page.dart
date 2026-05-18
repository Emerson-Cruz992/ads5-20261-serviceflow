import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/helpers/database_helper.dart';
import 'package:serviceflow/app/shared/widgets/app_logo.dart';
import 'package:serviceflow/app/core/services/auth.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.schedule.dart';

import '../../../../app_routes.dart';

class SplashPage extends StatefulWidget {
  final int maxSeconds;
  const SplashPage({super.key, this.maxSeconds = 3});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

/// Inclusão do SingleTickerProviderStateMixin para fornecer o VSync necessário ao controlador de animação
class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Configura o controlador para gerenciar a progressão do esmaecimento lentamente por 2.5 segundos
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 2. Mapeia a interpolação linear para transicionar a opacidade de 0.0 (invisível) para 1.0 (visível)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // 3. Inicia o gatilho visual de esmaecimento do logotipo
    _animationController.forward();

    // 4. Executa a rotina nativa original de preparação do banco de dados local
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await DbHelper.instance.database;
      if (!mounted) return;
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Erro ao inicializar banco de dados: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => _closeApp(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _closeApp() {
    Navigator.of(context).pop();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: widget.maxSeconds), () {
      if (!mounted) return;
      _checkAuthAndNavigate();
    });
  }

  void _checkAuthAndNavigate() async {
    final authService = AuthService();
    
    try {
      // Verificar se há sessão válida (Supabase + cache local)
      final hasSession = await authService.hasValidSession();
      
      if (hasSession) {
        // Usuário logado - iniciar agendador e ir para menu principal
        final UsuarioSchedule schedule = UsuarioSchedule();
        schedule.start(); // Iniciar sincronização em background
        
        Navigator.of(context).pushReplacementNamed(AppRoutes.menuLab);
      } else {
        // Usuário não logado - ir para login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      print("❌ Erro ao verificar autenticação: $e");
      // Em caso de erro, ir para login
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose(); // Libera os recursos do ticker de animação da memória
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Customização 1: Plano de fundo alterado estritamente para a cor preta
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // Customizações 2 e 3: Envolve o logo no widget de transição controlado pela animação lenta
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const AppLogo(width: double.infinity, height: 250),
            ),
          ),
        ),
      ),
    );
  }
}