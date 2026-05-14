import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.validation.dart';

/**
 * O ServicoService orquestra o fluxo entre a validação e o repositório, sendo o local 
 * onde o processo de negócio acontece de forma independente da interface.
 */
class ServicoService extends BaseService<Servico, ServicoRepository, ServicoValidation> {
  ServicoService(ServicoValidation validation, ServicoRepository repository)
      : super(validation, repository);

  @override
  Servico cloneModelWithId(Servico model, int id) {
    return model.copyWith(id: id, createdAt: DateTime.now());
  }

  Future<List<Servico>> listar() async {
    return await findAllActive();
  }
}