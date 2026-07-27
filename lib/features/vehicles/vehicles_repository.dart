import '../../core/api/api_client.dart';
import 'vehicle.dart';
import 'vehicle_detail.dart';
import 'vehicle_expense.dart';
import 'vehicle_photo.dart';
import 'stock_alerts.dart';
import 'market_estimate.dart';
import 'create_vehicle_data.dart';
import 'dua_extraction_result.dart';

class VehiclesRepository {
  VehiclesRepository(this._api);

  final ApiClient _api;

  Future<VehicleListPage> list({String? estado, int page = 1, int limit = 20}) {
    return _api.request(
      'GET',
      '/vehicles',
      queryParameters: {if (estado != null) 'estado': estado, 'page': page, 'limit': limit},
      parse: (data) => VehicleListPage.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> create(CreateVehicleData data) {
    return _api.request('POST', '/vehicles', data: data.toJson(), parse: (_) {});
  }

  /// :id é gerado no cliente — torna o ecrã de confirmação pós-DUA
  /// idempotente em caso de retry numa ligação instável (secção 5/11).
  Future<void> confirm(String id, CreateVehicleData data) {
    return _api.request('POST', '/vehicles/$id/confirm', data: data.toJson(), parse: (_) {});
  }

  Future<DuaExtractionResult> extractFromDua({required List<int> fotoFrente, required List<int> fotoVerso}) {
    return _api.uploadMultipart(
      '/vehicles/from-dua',
      files: {'foto_frente': fotoFrente, 'foto_verso': fotoVerso},
      parse: (data) => DuaExtractionResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Só chamado quando o utilizador confirma que as fotos já estavam
  /// cortadas/prontas (secção 23, aplicado também ao DUA) — caso contrário
  /// nunca é chamado e as fotos nunca chegam a ser guardadas.
  Future<void> uploadDuaPhotos(String vehicleId, {required List<int> fotoFrente, required List<int> fotoVerso}) {
    return _api.uploadMultipart(
      '/vehicles/$vehicleId/dua-photos',
      files: {'foto_frente': fotoFrente, 'foto_verso': fotoVerso},
      parse: (_) {},
    );
  }

  Future<VehicleDetail> getById(String vehicleId) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId',
      parse: (data) => VehicleDetail.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> reserve(String vehicleId, bool reservado) {
    return _api.request(
      'PATCH',
      '/vehicles/$vehicleId/reserve',
      data: {'reservado': reservado},
      parse: (_) {},
    );
  }

  Future<void> approve(String vehicleId) {
    return _api.request('PATCH', '/vehicles/$vehicleId/approve', parse: (_) {});
  }

  Future<void> reject(String vehicleId) {
    return _api.request('PATCH', '/vehicles/$vehicleId/reject', parse: (_) {});
  }

  /// Owner only — elimina o veículo (ex.: adicionado por engano). O backend
  /// recusa se já houver histórico de vendas associado.
  Future<void> remove(String vehicleId) {
    return _api.request('DELETE', '/vehicles/$vehicleId', parse: (_) {});
  }

  Future<void> update(
    String vehicleId, {
    String? versao,
    String? cor,
    int? kms,
    double? precoCompra,
    double? precoVendaRecomendado,
  }) {
    return _api.request(
      'PATCH',
      '/vehicles/$vehicleId',
      data: {
        if (versao != null) 'versao': versao,
        if (cor != null) 'cor': cor,
        if (kms != null) 'kms': kms,
        if (precoCompra != null) 'precoCompra': precoCompra,
        if (precoVendaRecomendado != null) 'precoVendaRecomendado': precoVendaRecomendado,
      },
      parse: (_) {},
    );
  }

  Future<void> addExpense({
    required String vehicleId,
    required String categoria,
    String? descricao,
    required double valor,
  }) {
    return _api.request(
      'POST',
      '/vehicles/$vehicleId/expenses',
      data: {'categoria': categoria, if (descricao != null) 'descricao': descricao, 'valor': valor},
      parse: (_) {},
    );
  }

  Future<List<VehicleExpense>> listExpenses(String vehicleId) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId/expenses',
      parse: (data) => (data as List<dynamic>).map((e) => VehicleExpense.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> updateExpense({
    required String vehicleId,
    required String expenseId,
    String? categoria,
    String? descricao,
    double? valor,
  }) {
    return _api.request(
      'PATCH',
      '/vehicles/$vehicleId/expenses/$expenseId',
      data: {
        if (categoria != null) 'categoria': categoria,
        if (descricao != null) 'descricao': descricao,
        if (valor != null) 'valor': valor,
      },
      parse: (_) {},
    );
  }

  Future<void> removeExpense({required String vehicleId, required String expenseId}) {
    return _api.request('DELETE', '/vehicles/$vehicleId/expenses/$expenseId', parse: (_) {});
  }

  /// Aviso proativo, não-bloqueante (mesmo padrão da subscrição/versão):
  /// quantos veículos estão parados em stock há muito tempo.
  Future<StockAlerts> getStockAlerts() {
    return _api.request('GET', '/vehicles/alerts', parse: (data) => StockAlerts.fromJson(data as Map<String, dynamic>));
  }

  Future<List<VehiclePhoto>> listPhotos(String vehicleId) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId/photos',
      parse: (data) => (data as List<dynamic>).map((e) => VehiclePhoto.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<VehiclePhoto> addPhoto(String vehicleId, List<int> foto) {
    return _api.uploadMultipart(
      '/vehicles/$vehicleId/photos',
      files: {'foto': foto},
      parse: (data) => VehiclePhoto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> removePhoto(String vehicleId, String photoId) {
    return _api.request('DELETE', '/vehicles/$vehicleId/photos/$photoId', parse: (_) {});
  }

  Future<MarketEstimate> marketEstimate(
    String vehicleId, {
    bool janelaAmpliada = false,
    bool forcarAtualizacao = false,
  }) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId/market-estimate',
      queryParameters: {
        if (janelaAmpliada) 'janela': 'ampliada',
        if (forcarAtualizacao) 'atualizar': 'true',
      },
      parse: (data) => MarketEstimate.fromJson(data as Map<String, dynamic>),
    );
  }
}
