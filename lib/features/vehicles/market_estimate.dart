import 'vehicle.dart';

/// Um anúncio real usado no cálculo — só vem preenchido numa pesquisa fresca
/// (o backend não guarda a amostra em cache, só o agregado), para o
/// utilizador poder confirmar a estimativa sem sair da app.
class MarketEstimateListagem {
  MarketEstimateListagem({required this.titulo, required this.preco, this.ano, this.kms, required this.url, this.foto});

  factory MarketEstimateListagem.fromJson(Map<String, dynamic> json) => MarketEstimateListagem(
        titulo: json['titulo'] as String,
        preco: (json['preco'] as num).toDouble(),
        ano: (json['ano'] as num?)?.toInt(),
        kms: (json['kms'] as num?)?.toInt(),
        url: json['url'] as String,
        foto: json['foto'] as String?,
      );

  final String titulo;
  final double preco;
  final int? ano;
  final int? kms;
  final String url;
  final String? foto;
}

class MarketEstimateSource {
  MarketEstimateSource({
    required this.fonte,
    this.precoMedio,
    this.precoMin,
    this.precoMax,
    this.numAnuncios,
    this.amostra = const [],
  });

  factory MarketEstimateSource.fromJson(Map<String, dynamic> json) => MarketEstimateSource(
        fonte: json['fonte'] as String,
        precoMedio: parseDecimal(json['preco_medio']),
        precoMin: parseDecimal(json['preco_min']),
        precoMax: parseDecimal(json['preco_max']),
        numAnuncios: (json['num_anuncios_comparados'] as num?)?.toInt(),
        amostra: (json['amostra'] as List<dynamic>? ?? const [])
            .map((e) => MarketEstimateListagem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String fonte;
  final double? precoMedio;
  final double? precoMin;
  final double? precoMax;
  final int? numAnuncios;
  final List<MarketEstimateListagem> amostra;
}

class MarketEstimate {
  MarketEstimate({required this.sources, this.precoMedio, this.precoMin, this.precoMax, required this.numFontes});

  factory MarketEstimate.fromJson(Map<String, dynamic> json) {
    final agregado = json['agregado'] as Map<String, dynamic>;
    return MarketEstimate(
      sources: (json['estimates'] as List<dynamic>)
          .map((e) => MarketEstimateSource.fromJson(e as Map<String, dynamic>))
          .toList(),
      // agregado vem já calculado em JS no backend, chega como número (não String).
      precoMedio: (agregado['preco_medio'] as num?)?.toDouble(),
      precoMin: (agregado['preco_min'] as num?)?.toDouble(),
      precoMax: (agregado['preco_max'] as num?)?.toDouble(),
      numFontes: (agregado['num_fontes'] as num?)?.toInt() ?? 0,
    );
  }

  final List<MarketEstimateSource> sources;
  final double? precoMedio;
  final double? precoMin;
  final double? precoMax;
  final int numFontes;
}
