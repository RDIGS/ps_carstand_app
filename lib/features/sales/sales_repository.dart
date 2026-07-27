import '../../core/api/api_client.dart';
import 'identity_extraction_result.dart';
import 'sale_result.dart';
import 'sale_row.dart';

class SalesRepository {
  SalesRepository(this._api);

  final ApiClient _api;

  /// Sem `vendedorId`, o backend decide sozinho o que devolver por role
  /// (secção 12.4: vendedor só vê as suas, owner vê todas).
  Future<List<SaleRow>> list({String? vendedorId}) {
    return _api.request(
      'GET',
      '/sales',
      queryParameters: {if (vendedorId != null) 'vendedor_id': vendedorId},
      parse: (data) => (data as List<dynamic>).map((e) => SaleRow.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<SaleResult> create({
    required String vehicleId,
    required String compradorNome,
    required String compradorNif,
    String? compradorMorada,
    String? compradorCp,
    String? compradorTelefone,
    String? compradorIdentificacaoTipo,
    String? compradorIdentificacaoNumero,
    required double precoFinal,
    double? comissaoVendedor,
  }) {
    return _api.request(
      'POST',
      '/sales',
      data: {
        'vehicleId': vehicleId,
        'compradorNome': compradorNome,
        'compradorNif': compradorNif,
        if (compradorMorada != null) 'compradorMorada': compradorMorada,
        if (compradorCp != null) 'compradorCp': compradorCp,
        if (compradorTelefone != null) 'compradorTelefone': compradorTelefone,
        if (compradorIdentificacaoTipo != null) 'compradorIdentificacaoTipo': compradorIdentificacaoTipo,
        if (compradorIdentificacaoNumero != null) 'compradorIdentificacaoNumero': compradorIdentificacaoNumero,
        'precoFinal': precoFinal,
        if (comissaoVendedor != null) 'comissaoVendedor': comissaoVendedor,
      },
      parse: (data) => SaleResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Owner only (O9): reverte a venda, liberta o veículo e invalida os
  /// documentos gerados no backend.
  Future<void> revert(String saleId) {
    return _api.request('POST', '/sales/$saleId/revert', parse: (_) {});
  }

  /// Transitório, nunca grava (secção 23) — só pré-preenche o formulário.
  Future<IdentityExtractionResult> extractIdentity({required List<int> fotoFrente, required List<int> fotoVerso}) {
    return _api.uploadMultipart(
      '/sales/extract-identity',
      files: {'foto_frente': fotoFrente, 'foto_verso': fotoVerso},
      parse: (data) => IdentityExtractionResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Só chamado quando o utilizador confirma que as fotos já estavam
  /// cortadas/prontas (secção 23) — caso contrário nunca é chamado.
  Future<void> attachIdentityDocuments(
    String saleId, {
    required String tipoDocumento,
    required List<int> fotoFrente,
    required List<int> fotoVerso,
  }) {
    return _api.uploadMultipart(
      '/sales/$saleId/identity-documents',
      files: {'foto_frente': fotoFrente, 'foto_verso': fotoVerso},
      fields: {'tipoDocumento': tipoDocumento},
      parse: (_) {},
    );
  }
}
