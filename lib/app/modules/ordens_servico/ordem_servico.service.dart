import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.model.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.repository.dart';
import 'package:serviceflow/app/modules/ordens_servico/ordem_servico.validation.dart';

/// DTO para encapsular os indicadores consolidados do painel gerencial
class DashboardMetrics {
  final int totalAbertas;
  final double faturamentoConcluido;
  final int pendentesSincronizacao;

  DashboardMetrics({
    required this.totalAbertas,
    required this.faturamentoConcluido,
    required this.pendentesSincronizacao,
  });
}

/// OrdemServicoService - Orquestrador de Regras de Negócio de O.S.
/// 
/// Herança corrigida para se adequar ao contrato BaseService<E, R, V> do projeto.
class OrdemServicoService extends BaseService<OrdemServico, OrdemServicoRepository, OrdemServicoValidation> {
  
  // O construtor utiliza super parâmetros para alimentar os componentes da classe abstrata
  OrdemServicoService(super.validation, super.repository);

  /// Realiza a busca física no SQLite e realiza as agregações lógicas em memória
  Future<DashboardMetrics> obterMetricasDashboard() async {
    // repository já está acessível nativamente através da herança da classe base
    final List<OrdemServico> todasAsOrdens = await repository.findAll();

    // 1. Filtra e conta quantas ordens operacionais estão com o status ativo
    final quantidadeAbertas = todasAsOrdens.where((os) => os.ativo).length;

    // 2. Filtra as ordens fechadas e acumula o somatório financeiro do valor total
    final receitaAcumulada = todasAsOrdens.where((os) => !os.ativo).fold<double>(
          0.0,
          (sum, os) => sum + os.valorTotal,
        );

    // 3. Filtra e conta os registros modificados localmente com o sinalizador de sync pendente
    final quantidadePendentesSync = todasAsOrdens.where((os) => os.isSync == 0).length;

    return DashboardMetrics(
      totalAbertas: quantidadeAbertas,
      faturamentoConcluido: receitaAcumulada,
      pendentesSincronizacao: quantidadePendentesSync,
    );
  }
  
  @override
  OrdemServico cloneModelWithId(OrdemServico model, int id) {
    // Retorna uma nova instância imutável acoplando o ID gerado pelo SQLite
    return OrdemServico(
      id: id,
      clienteId: model.clienteId,
      tecnicoId: model.tecnicoId,
      itens: model.itens,
      observacao: model.observacao,
      pecasAplicadas: model.pecasAplicadas,
      valorPecas: model.valorPecas,
      fotoAntes: model.fotoAntes,
      fotoDepois: model.fotoDepois,
      assinatura: model.assinatura,
      ativo: model.ativo,
      isSync: model.isSync,
    );
  }
}