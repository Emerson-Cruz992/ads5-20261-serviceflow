import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.validation.dart';

class DashboardController extends BaseController<OrdemServico, OrdemServicoRepository,
    OrdemServicoValidation, OrdemServicoService> {
  
  DashboardController(super.service);

  @override
  Widget buildPage(BuildContext context, OrdemServicoService service) {
    return const SizedBox.shrink();
  }
}