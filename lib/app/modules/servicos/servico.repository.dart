import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';

/**
 * O Repositório é o especialista em SQLite, isolando as instruções SQL do restante
 * do código. Ele utilizará o DbHelper para administrar a ligação com a tabela 
 * serviços.
 */
class ServicoRepository extends BaseRepository<Servico> {
  @override
  String get tableName => 'servicos';

  @override
  Servico fromMap(Map<String, dynamic> map) {
    return Servico.fromMap(map);
  }

  Future<bool> existsByDescricao(String descricao) async {
    return await exists('descricao = ?', [descricao]);
  }
}