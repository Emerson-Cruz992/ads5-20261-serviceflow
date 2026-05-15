import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:sqflite/sqflite.dart';

/**
 * A classe OrdemServicoRepository utiliza o padrão de Transações do SQLite para assegurar que 
 * a Ordem de Serviço e seus respectivos itens sejam armazenados de forma atômica (conceito de "tudo ou nada"),
 * ou grava tudo com sucesso ou não grava nada em caso de erro
 */
class OrdemServicoRepository extends BaseRepository<OrdemServico> {
  @override
  String get tableName => 'ordens_servico';

  @override
  OrdemServico fromMap(Map<String, dynamic> map) {    
    return OrdemServico.fromMap(map); 
  }

  /// Insere uma O.S. e todos os seus itens vinculados usando uma Transação [cite: 933]
  @override
  Future<int> insert(OrdemServico model) async {
    final db = await getConnection();

    return await db.transaction((txn) async {
      // 1. Inserir o cabeçalho da O.S.
      final osId = await txn.insert(tableName, model.toMap());

      // 2. Inserir cada item na tabela os_itens com snapshots [cite: 708-717]
      for (final item in model.itens) {
        await txn.insert('os_itens', {
          'os_id': osId,
          'servico_id': item.id,
          'descricao_snapshot': item.descricao, 
          'preco_snapshot': item.preco,
          'ativo': 1,
          'is_sync': 0,
        });
      }

      return osId;
    });
  }

  /// Busca O.S. por cliente
  Future<List<OrdemServico>> findByCliente(int clienteId) async {
    final db = await getConnection();
    final result = await db.query(
      tableName,
      where: 'cliente_id = ?',
      whereArgs: [clienteId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => fromMap(map)).toList();
  }
}