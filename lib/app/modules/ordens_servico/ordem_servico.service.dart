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

  // Cria uma nova instância preservando os dados e injetando o ID gerado
  @override
  OrdemServico cloneModelWithId(OrdemServico model, int id) {    
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

  //Método que será responsável pela extração de métricas, diretamente do repositório
  Future<Map<String, dynamic>> obterMetricasDashboard() async {
    final todas = await repository.findAll();
    
    // Cálculo de faturamento total
    double faturamento = todas.fold(0, (sum, os) => sum + os.valorTotal);
    
    // Contagem por status de sincronização
    int pendentesSync = todas.where((os) => os.isSync == 0).length;
    int sincronizadas = todas.where((os) => os.isSync == 1).length;

    return {
      'total_os': todas.length,
      'faturamento_total': faturamento,
      'pendentes_sync': pendentesSync,
      'sincronizadas': sincronizadas,
    };
}
}