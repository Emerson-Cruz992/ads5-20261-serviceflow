import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';

/**
 * A OrdemServicoValidation atua como um filtro de qualidade, impedindo que dados não validados
 * sejam propagados para a persistência. Para uma O.S, as regras fundamentais incluem a obrigatoriedade
 * de um cliente e de um técnico, além da exigência de que pelos menos um serviço tenha sido selecionado
 * para a execução.
 */
class OrdemServicoValidation extends BaseValidation<OrdemServico, OrdemServicoRepository> {
  OrdemServicoValidation(OrdemServicoRepository repository) : super(repository);

  @override
  void validateFields(OrdemServico? model) {
    if (model == null) {
      throw Exception("Os dados da Ordem de Serviço não podem estar vazios.");
    }
    
    // Validação de chaves estrangeiras obrigatórias
    if (model.clienteId <= 0) {
      throw Exception("Selecione um cliente para prosseguir.");
    }
    if (model.tecnicoId <= 0) {
      throw Exception("Selecione um técnico responsável.");
    }

    // Regra de negócio: O.S. deve ter obrigatoriamente item(ns) de serviço
    if (model.itens.isEmpty) {
      throw Exception("A Ordem de Serviço deve conter pelo menos um serviço.");
    }
  }

  @override
  Future<void> validateRulesCreate(OrdemServico model) async {
    // Aqui poderiam ser adicionadas verificações extras, como se o cliente
    // já possui uma O.S. aberta no mesmo dia.
    //TO-DO
  }
}