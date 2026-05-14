import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';

/**
 * Esta camada contém as regras de negócio que impedem a entrada dos dados inválidos
 * no sistema, como garantir que a descrição não esteja vazia e o prazço seja superior
 * a 0(zero)
 */
class ServicoValidation extends BaseValidation<Servico, ServicoRepository> {
  ServicoValidation(ServicoRepository repository) : super(repository);

  @override
  void validateFields(Servico? model) {
    if (model == null || model.descricao.trim().isEmpty) {
      throw Exception("A descrição do serviço é obrigatória");
    }
    if (model.preco <= 0) {
      throw Exception("O preço do serviço deve ser maior que zero");
    }
  }

  @override
  Future<void> validateRulesCreate(Servico model) async {
    if (await repository.existsByDescricao(model.descricao)) {
      throw Exception("Já existe um serviço cadastrado com esta descrição");
    }
  }
}