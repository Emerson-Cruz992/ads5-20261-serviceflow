import 'package:flutter/material.dart';
import 'package:serviceflow/app/app_routes.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Captura os tokens de design do tema escuro propagado na raiz do aplicativo
    final theme = Theme.of(context);

    return Scaffold(
      // Define o plano de fundo escuro semântico para a estrutura da página
      backgroundColor: ,
      appBar: CustomGradientAppBar(
        title: 'ServiceFlow',
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
      drawer: CustomAppDrawer.serviceFlow(
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
      // ALERTA ARQUITETURAL: Se o CustomGradientBackground ignorar o tema escuro internamente,
      // será necessário abrir o arquivo dele e adaptar o gradiente para ler o theme.colorScheme.background
      body: CustomGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomWelcomeHeader(),
                Expanded(
                  child: CustomMenuGrid(
                    crossAxisCount: 2,
                    menuItems: [
                      // CORREÇÃO: Os cartões passam a adotar a cor de superfície do tema escuro,
                      // evitando que fiquem brancos ou com cores claras chumbadas destoantes
                      CustomMenuCard(
                        title: 'Clientes',
                        description: 'Gerenciar clientes',
                        icon: Icons.people,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, '/clientes'),
                      ),
                      CustomMenuCard(
                        title: 'OS\'s',
                        description: 'Gerenciar OS',
                        icon: Icons.build,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.ordensServico),
                      ),
                      CustomMenuCard(
                        title: 'Relatórios',
                        description: 'Visualizar relatórios',
                        icon: Icons.bar_chart,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.dashboard),
                      ),
                      CustomMenuCard(
                        title: 'Laboratório',
                        description: 'Funções Experimentais',
                        icon: Icons.science,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, '/laboratorio/usuarios'),
                      ),
                      CustomMenuCard(
                        title: 'Configurações',
                        description: 'Gerencie configs.',
                        icon: Icons.settings,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                      ),
                      CustomMenuCard(
                        title: 'Técnicos',
                        description: 'Gestão de Profissionais',
                        icon: Icons.engineering,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, '/tecnicos'),
                      ),
                      CustomMenuCard(
                        title: 'Serviços',
                        description: 'Catálogo de preços',
                        icon: Icons.settings_suggest,
                        color: theme.colorScheme.surface,
                        onTap: () => Navigator.pushNamed(context, '/servicos'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                CustomQuickActionsPanel(
                  actions: [
                    CustomQuickActionButton(
                      icon: Icons.add,
                      label: 'Nova OS',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.novaOs),
                    ),
                    CustomQuickActionButton(
                      icon: Icons.search,
                      label: 'Buscar',
                      onTap: () => Navigator.pushNamed(context, '/buscar'),
                    ),
                    CustomQuickActionButton(
                      icon: Icons.pending_actions,
                      label: 'Pendentes',
                      onTap: () => Navigator.pushNamed(context, '/pendentes'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}