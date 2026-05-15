import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.validation.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';

/**
 * Este controlador será responsável por carregar as opções de seleção e gerir o estado da Ordem 
 * de Serviço, que está sendo montada.
 */
class OrdemServicoController extends BaseController<OrdemServico, OrdemServicoRepository,
    OrdemServicoValidation, OrdemServicoService> {
  
  OrdemServicoController(super.service, {super.model});

  // Estado temporário para a criação da O.S.
  final List<Servico> itensSelecionados = [];

  void adicionarServico(Servico servico) {
    itensSelecionados.add(servico);
  }

  void removerServico(int index) {
    itensSelecionados.removeAt(index);
  }

  @override
  Widget buildPage(BuildContext context, OrdemServicoService service) {
    return const SizedBox.shrink();
  }
}