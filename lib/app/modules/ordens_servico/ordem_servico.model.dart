import 'package:serviceflow/app/core/base/base.model.dart';
import '../servicos/servico.model.dart';

/**
 * A OS (Ordem de Serviço) é o coração do sistema. Diferente de Cruds Simples, ela possui 
 * um relacionamento N:N com Serviços e precisa de SnapShots (Cópia do preço e descrição no
 * momento da execução) para garantir a integridade histórica.
 */
class OrdemServico extends BaseModel {
  final int clienteId;
  final int tecnicoId;
  final String? observacao;
  final String? pecasAplicadas;
  final double valorPecas;
  final List<Servico> itens; // Lista de serviços realizados
  
  // Evidências (Hardware) - Caminhos locais
  final String? fotoAntes;
  final String? fotoDepois;
  final String? assinatura;

  OrdemServico({
    super.id,
    super.createdAt,
    super.isSync = 0,
    super.ativo = true,
    required this.clienteId,
    required this.tecnicoId,
    required this.itens,
    this.observacao,
    this.pecasAplicadas,
    this.valorPecas = 0.0,
    this.fotoAntes,
    this.fotoDepois,
    this.assinatura,
  });

  // Construtor nomeado para mapear os dados da tabela 'ordens_servico'
  OrdemServico.fromMap(Map<String, dynamic> map)
      : clienteId = map['cliente_id'] as int,
        tecnicoId = map['tecnico_id'] as int,
        observacao = map['observacao'] as String?,
        pecasAplicadas = map['pecas_aplicadas'] as String?,
        valorPecas = (map['valor_pecas'] as num?)?.toDouble() ?? 0.0,
        fotoAntes = map['foto_antes'] as String?,
        fotoDepois = map['foto_depois'] as String?,
        assinatura = map['assinatura'] as String?,
        itens = [], // Inicializa vazio para ser populado pelo Service
        super.fromMap(map);

  // Regra de Negócio: Total dos Valores, obtido por meio de um somatório
  double get valorTotal {
    double totalServicos = itens.fold(0, (sum, item) => sum + item.preco);
    return totalServicos + valorPecas;
  }

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();
    map.addAll({
      'cliente_id': clienteId,
      'tecnico_id': tecnicoId,
      'observacao': observacao,
      'pecas_aplicadas': pecasAplicadas,
      'valor_pecas': valorPecas,
      'foto_antes': fotoAntes,
      'foto_depois': fotoDepois,
      'assinatura': assinatura,
    });
    return map;
  }
}