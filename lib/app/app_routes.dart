import 'package:flutter/material.dart';
import 'package:serviceflow/demo_camera_page.dart';
import 'package:serviceflow/demo_signature_page.dart';
import 'package:serviceflow/menu_laboratorio_page.dart';
import 'package:serviceflow/test_icons_page.dart';

import 'modules/splash/presentation/pages/splash_page.dart';
import 'modules/auth/presentation/pages/login_page.dart';
import 'modules/home/presentation/pages/home_page.dart';
import 'modules/clientes/presentation/pages/clientes_list_page.dart';
import 'modules/ordens_servico/presentation/pages/ordens_servico_page.dart';
import 'modules/relatorios/presentation/pages/relatorios_page.dart';
import 'shared/pages/em_desenvolvimento_page.dart';

//importacoes das classes relacionadas aos clientes
import 'modules/clientes/client.repository.dart';
import 'modules/clientes/cliente.service.dart';
import 'modules/clientes/cliente.validation.dart';

//importacoes das classes relacionados ao servico.model
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'modules/servicos/servico.service.dart';
import 'modules/servicos/servico.validation.dart';
import 'modules/servicos/servico.repository.dart';
import 'modules/servicos/presentation/pages/servicos_list_page.dart';
import 'modules/servicos/presentation/pages/servico_form_page.dart';

//importacoes das classes relacionadas ao tecnico.model
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'modules/tecnicos/tecnico.service.dart';
import 'modules/tecnicos/tecnico.validation.dart';
import 'modules/tecnicos/tecnico.repository.dart';
import 'modules/tecnicos/presentation/pages/tecnicos_list_page.dart';
import 'modules/tecnicos/presentation/pages/tecnico_form_page.dart';

class AppRoutes {
  static const splash = '/splash';
  static const login = '/auth/login';
  static const home = '/home';
  static const clientes = '/clientes';
  static const ordensServico = '/ordens-servico';
  static const relatorios = '/relatorios';
  static const novaOs = '/nova-os';
  static const buscar = '/buscar';
  static const pendentes = '/pendentes';
  static const configuracoes = '/configuracoes';
  static const estoque = '/estoque';
  static const fornecedores = '/fornecedores';
  static const menuLab = '/menu-lab';
  static const demoCamera = '/demo-camera';
  static const demoSignature = '/demo-signature';
  static const testIcons = '/test-icons';
  static const servicos = '/servicos';
  static const servicoNovo = '/servico/novo';
  static const servicoEditar = '/servico/editar';
  static const tecnicos = '/tecnicos';
  static const tecnicoNovo = '/tecnico/novo';
  static const tecnicoEditar = '/tecnico/editar';

  static Map<String, WidgetBuilder> get routes => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        home: (_) => const HomePage(),
        clientes: (_) {
          final repository = ClienteRepository();
          final validation = ClienteValidation(repository);
          final service = ClienteService(validation, repository);
          return ClientesListPage(service);
        },
        ordensServico: (_) => const OrdensServicoPage(),
        relatorios: (_) => const RelatoriosPage(),
        novaOs: (_) => const EmDesenvolvimentoPage(
              titulo: 'Nova Ordem de Serviço',
              icone: Icons.add_business,
              cor: Colors.blue,
              descricao: 'Funcionalidade de criar nova OS em desenvolvimento',
            ),
        buscar: (_) => const EmDesenvolvimentoPage(
              titulo: 'Buscar',
              icone: Icons.search,
              cor: Colors.teal,
              descricao: 'Funcionalidade de busca em desenvolvimento',
            ),
        pendentes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Pendências',
              icone: Icons.pending_actions,
              cor: Colors.amber,
              descricao: 'Visualização de pendências em desenvolvimento',
            ),
        configuracoes: (_) => const EmDesenvolvimentoPage(
              titulo: 'Configurações',
              icone: Icons.settings,
              cor: Colors.grey,
              descricao: 'Configurações do sistema em desenvolvimento',
            ),
        estoque: (_) => const EmDesenvolvimentoPage(
              titulo: 'Estoque',
              icone: Icons.inventory,
              cor: Colors.teal,
              descricao: 'Funcionalidade de controle de estoque.\n'
                  'Gerencie produtos, peças e materiais\n'
                  'utilizados nas ordens de serviço.',
            ),
        fornecedores: (_) => const EmDesenvolvimentoPage(
              titulo: 'Fornecedores',
              icone: Icons.business,
              cor: Colors.indigo,
              descricao: 'Funcionalidade para cadastro de fornecedores.\n'
                  'Gerencie contatos e produtos\n'
                  'de seus parceiros comerciais.',
            ),
        menuLab: (context) => const MenuLaboratorioPage(),
        demoCamera: (context) => const DemoCameraPage(),
        demoSignature: (context) => const DemoSignaturePage(),
        testIcons: (context) => const TestIconsPage(),

        //rotas relacionados aos servicos
        servicos: (_) {
          final repo = ServicoRepository();
          final service = ServicoService(ServicoValidation(repo), repo);
          return ServicosListPage(service);
        },
        servicoNovo: (_) {
          final repo = ServicoRepository();
          return ServicoFormPage(ServicoService(ServicoValidation(repo), repo));
        },
        servicoEditar: (context) {
          final repo = ServicoRepository();
          final servico = ModalRoute.of(context)!.settings.arguments as Servico;
          return ServicoFormPage(ServicoService(ServicoValidation(repo), repo), servicoParaEdicao: servico);
        },
        
        //rotas relacionadas aos técnicos
        tecnicos: (_) {
          final repo = TecnicoRepository();
          return TecnicosListPage(TecnicoService(TecnicoValidation(repo), repo));
        },
        tecnicoNovo: (_) {
          final repo = TecnicoRepository();
          return TecnicoFormPage(TecnicoService(TecnicoValidation(repo), repo));
        },
        tecnicoEditar: (context) {
          final repo = TecnicoRepository();
          final tecnico = ModalRoute.of(context)!.settings.arguments as Tecnico;
          return TecnicoFormPage(TecnicoService(TecnicoValidation(repo), repo), tecnicoParaEdicao: tecnico);
        },
      };
}
