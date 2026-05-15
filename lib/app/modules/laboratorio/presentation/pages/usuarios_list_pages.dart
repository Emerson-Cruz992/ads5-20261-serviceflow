import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.model.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.service.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.repository.dart';
import 'package:serviceflow/app/modules/usuarios/usuario.validation.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

/**
 *  A página de testes consumirá o repositório ou serviço de usuários para listar os registros 
 *  na tela dentro de um layout simplificado. Utilizaremos o componente CustomListCard configurado 
 *  com ícones que remetam a credenciais de acesso, exibindo explicitamente o ID, nome e email de 
 *  cada conta cadastrada na base local.
 */
class UsuariosListPage extends BaseController<Usuario, UsuarioRepository,
    UsuarioValidation, UsuarioService> {
  UsuariosListPage(super.service);

  @override
  Widget buildPage(BuildContext context, UsuarioService service) {
    return _UsuariosListView(service: service, controller: this);
  }
}

class _UsuariosListView extends StatefulWidget {
  final UsuarioService service;
  final UsuariosListPage controller;

  const _UsuariosListView({required this.service, required this.controller});

  @override
  State<_UsuariosListView> createState() => _UsuariosListViewState();
}

class _UsuariosListViewState extends State<_UsuariosListView> {
  List<Usuario> _usuarios = [];

  @override
  void initState() {
    super.initState();
    // Agendamento pós-frame para carregar os dados de teste com segurança
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarUsuarios();
    });
  }

  Future<void> _carregarUsuarios() async {
    final result = await widget.controller.executeListOperation(
      context,
      widget.service.findAll(),
      loadingMessage: 'Inspecionando tabela de usuários...',
    );
    setState(() => _usuarios = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratório - Usuários'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.refresh),
            onPressed: _carregarUsuarios,
          ),
        ],
      ),
      body: _usuarios.isEmpty
          ? const CustomEmptyStateCard(
              icon: Icons.fingerprint,
              title: 'Nenhum usuário local',
              message: 'A tabela de usuários está vazia no SQLite do dispositivo.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _usuarios.length,
              itemBuilder: (context, index) {
                final usuario = _usuarios[index];
                
                return CustomListCard(
                  isActive: usuario.ativo,
                  title: Text('#${usuario.id} - ${usuario.nomeCompleto}', style: AppTextStyles.h4),
                  subtitle: Text('Email: ${usuario.email}'),
                  trailing: Icon(
                    usuario.ativo ? Icons.verified_user : Icons.gpp_bad,
                    color: usuario.ativo ? AppColors.success : Colors.grey,
                  ),
                );
              },
            ),
    );
  }
}