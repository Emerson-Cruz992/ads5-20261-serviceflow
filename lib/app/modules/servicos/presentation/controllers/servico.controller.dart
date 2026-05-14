import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.controller.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.service.dart';
import 'package:serviceflow/app/modules/servicos/servico.validation.dart';

/**
 * A função deste controller é capturar os dados da tela e
 * encaminhar para o ServicoService
 */
class ServicoController extends BaseController<Servico, ServicoRepository,
    ServicoValidation, ServicoService> {
  
  ServicoController(super.service, {super.model});

  @override
  Widget buildPage(BuildContext context, ServicoService service) {
    // Este método é exigido pelo BaseController, mas as páginas 
    // serão chamadas via rotas nomeadas.
    return const SizedBox.shrink();
  }
}