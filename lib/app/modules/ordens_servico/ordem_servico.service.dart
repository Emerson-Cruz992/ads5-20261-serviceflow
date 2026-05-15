import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.validation.dart';

/**
 * A classe OrdemServicoService tem como função principal definir o fluxo de execução que vai
 * desde a validação inicial até a persistência final no SQLite via repositório. Ele também é responsável
 * por lidar com o ciclo de vida do objeto, garantindo que o id gerado pelo banco seja corretamente
 * atribuído ao modelo após a criação.
 */
class OrdemServicoService extends BaseService<OrdemServico, OrdemServicoRepository, OrdemServicoValidation> {
  OrdemServicoService(OrdemServicoValidation validation, OrdemServicoRepository repository)
      : super(validation, repository);

  @override
  OrdemServico cloneModelWithId(OrdemServico model, int id) {
    // Cria uma nova instância preservando os dados e injetando o ID gerado
    return OrdemServico(
      id: id,
      createdAt: DateTime.now(),
      clienteId: model.clienteId,
      tecnicoId: model.tecnicoId,
      itens: model.itens,
      observacao: model.observacao,
      pecasAplicadas: model.pecasAplicadas,
      valorPecas: model.valorPecas,
      fotoAntes: model.fotoAntes,
      fotoDepois: model.fotoDepois,
      assinatura: model.assinatura,
    );
  }

  // Método específico para listar O.S. filtrando por cliente
  Future<List<OrdemServico>> listarPorCliente(int clienteId) async {
    return await repository.findByCliente(clienteId);
  }
}