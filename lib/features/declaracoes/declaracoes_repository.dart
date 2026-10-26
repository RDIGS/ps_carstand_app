import '../../core/api/api_client.dart';
import 'declaracao.dart';

class DeclaracoesRepository {
  DeclaracoesRepository(this._api);

  final ApiClient _api;

  Future<List<Declaracao>> listar(String vehicleId) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId/declaracoes',
      parse: (data) => (data as List<dynamic>).map((e) => Declaracao.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// `tipo`: 'compra' | 'circulacao' | 'caracteristicas' (a de venda é
  /// gerada pelo próprio fluxo de venda).
  Future<Declaracao> emitir(String vehicleId, String tipo, DadosCliente dados) {
    return _api.request(
      'POST',
      '/vehicles/$vehicleId/declaracoes/$tipo',
      data: {
        'nome': dados.nome,
        if (dados.morada != null) 'morada': dados.morada,
        if (dados.nif != null) 'nif': dados.nif,
        if (dados.pneusDianteiros != null) 'pneusDianteiros': dados.pneusDianteiros,
        if (dados.pneusTraseiros != null) 'pneusTraseiros': dados.pneusTraseiros,
      },
      parse: (data) => Declaracao.fromJson(data as Map<String, dynamic>),
    );
  }
}
