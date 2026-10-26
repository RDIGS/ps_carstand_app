/// Declaração do veículo já emitida (histórico da ficha do veículo).
class Declaracao {
  Declaracao({required this.id, required this.tipo, required this.url, required this.criadoEm, this.clienteNome, this.saleId});

  factory Declaracao.fromJson(Map<String, dynamic> json) => Declaracao(
        id: json['id'] as String,
        tipo: json['tipo'] as String,
        url: json['url'] as String,
        clienteNome: json['cliente_nome'] as String?,
        saleId: json['sale_id'] as String?,
        criadoEm: DateTime.parse(json['criado_em'] as String).toLocal(),
      );

  final String id;

  /// 'compra' | 'venda' | 'circulacao' | 'caracteristicas'
  final String tipo;
  final String url;
  final String? clienteNome;
  final String? saleId;
  final DateTime criadoEm;
}

/// Dados do cliente para a declaração — lidos do CC ou escritos à mão.
class DadosCliente {
  DadosCliente({required this.nome, this.morada, this.nif, this.pneusDianteiros, this.pneusTraseiros});

  final String nome;
  final String? morada;
  final String? nif;
  final String? pneusDianteiros;
  final String? pneusTraseiros;
}
