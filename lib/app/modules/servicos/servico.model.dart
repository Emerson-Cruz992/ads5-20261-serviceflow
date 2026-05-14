import 'package:serviceflow/app/core/base/base.model.dart';

/**
 * A entidade Servico deve herdar de BaseModel para incluir automaticamente 
 * os campos de controlo de sincronização (isSync) e data de criação . 
 * Baseando-nos no schema SQL definido, o modelo incluirá:
 * - a descrição, o preço e o tempo estimado
 */
class Servico extends BaseModel {
  final String descricao;
  final double preco;
  final String? tempoEstimado;

  Servico({
    super.id,
    super.createdAt,
    super.isSync = 0,
    super.ativo = true,
    required this.descricao,
    required this.preco,
    this.tempoEstimado,
  });

  Servico.fromMap(Map<String, dynamic> map)
      : descricao = map['descricao'] as String,
        preco = (map['preco'] as num).toDouble(),
        tempoEstimado = map['tempo_estimado'] as String?,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'descricao': descricao,
      'preco': preco,
      'tempo_estimado': tempoEstimado,
    };
  }

  Servico copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? descricao,
    double? preco,
    String? tempoEstimado,
  }) {
    return Servico(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      tempoEstimado: tempoEstimado ?? this.tempoEstimado,
    );
  }
}