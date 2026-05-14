import 'package:flutter/material.dart';
import 'package:serviceflow/app/shared/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(
        title: 'ServiceFlow',
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
      drawer: CustomAppDrawer.serviceFlow(
        onLogout: () => Navigator.pushReplacementNamed(context, '/auth/login'),
      ),
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
                      CustomMenuCard(
                        title: 'Clientes',
                        description: 'Gerenciar clientes',
                        icon: Icons.people,
                        color: AppColors.primary,
                        onTap: () => Navigator.pushNamed(context, '/clientes'),
                      ),
                      CustomMenuCard(
                        title: 'Ordens de\nServiço',
                        description: 'Criar e gerenciar OS',
                        icon: Icons.build,
                        color: AppColors.success,
                        onTap: () =>
                            Navigator.pushNamed(context, '/ordens-servico'),
                      ),
                      CustomMenuCard(
                        title: 'Relatórios',
                        description: 'Visualizar relatórios',
                        icon: Icons.bar_chart,
                        color: AppColors.warning,
                        onTap: () =>
                            Navigator.pushNamed(context, '/relatorios'),
                      ),
                      CustomMenuCard(
                        title: 'Laboratório',
                        description: 'Testes de hardware',
                        icon: Icons.science,
                        color: Colors.purple,
                        onTap: () => Navigator.pushNamed(context, '/menu-lab'),
                      ),
                      CustomMenuCard(
                        title: 'Estoque',
                        description: 'Controle de produtos',
                        icon: Icons.inventory,
                        color: Colors.teal,
                        onTap: () => Navigator.pushNamed(context, '/estoque'),
                      ),
                      CustomMenuCard(
                        title: 'Configurações',
                        description: 'Configurações do sistema',
                        icon: Icons.settings,
                        color: Colors.grey,
                        onTap: () =>
                            Navigator.pushNamed(context, '/configuracoes'),
                      ),
                      CustomMenuCard(
                        title: 'Técnicos',
                        description: 'Gestão de Técnicos/Profissionais',
                        icon: Icons.engineering, // Ou AppIcons.person
                        color: Colors.orange,
                        onTap: () => Navigator.pushNamed(context, '/tecnicos'),
                      ),
                      CustomMenuCard(
                        title: 'Serviços',
                        description: 'Catálogo de preços',
                        icon: Icons.settings_suggest, // Ou AppIcons.build
                        color: Colors.blueGrey,
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
                      onTap: () => Navigator.pushNamed(context, '/nova-os'),
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
