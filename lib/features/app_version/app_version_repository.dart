import '../../core/api/api_client.dart';

/// Resposta de `/app/version-check` (secção 22).
class VersionCheckResult {
  VersionCheckResult({
    required this.obrigatoria,
    this.versaoMinimaObrigatoria,
    this.versaoRecomendada,
    this.changelogUrl,
  });

  factory VersionCheckResult.fromJson(Map<String, dynamic> json) => VersionCheckResult(
        obrigatoria: json['obrigatoria'] as bool,
        versaoMinimaObrigatoria: json['versao_minima_obrigatoria'] as String?,
        versaoRecomendada: json['versao_recomendada'] as String?,
        changelogUrl: json['changelog_url'] as String?,
      );

  final bool obrigatoria;
  final String? versaoMinimaObrigatoria;
  final String? versaoRecomendada;
  final String? changelogUrl;
}

class AppVersionRepository {
  AppVersionRepository(this._api);

  final ApiClient _api;

  Future<VersionCheckResult> versionCheck({required String plataforma, required String versaoAtual}) {
    return _api.request(
      'GET',
      '/app/version-check',
      queryParameters: {'plataforma': plataforma, 'versao_atual': versaoAtual},
      parse: (data) => VersionCheckResult.fromJson(data as Map<String, dynamic>),
    );
  }
}
