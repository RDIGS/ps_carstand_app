/// Pedido de visita feito por um visitante no site público do stand.
class VisitRequest {
  VisitRequest({
    required this.id,
    required this.nome,
    required this.dataHora,
    required this.estado,
    required this.criadoEm,
    this.telefone,
    this.email,
    this.mensagem,
    this.vehicleId,
    this.veiculo,
    this.matricula,
  });

  factory VisitRequest.fromJson(Map<String, dynamic> json) {
    final marca = json['marca'] as String?;
    final modelo = json['modelo'] as String?;
    return VisitRequest(
      id: json['id'] as String,
      nome: json['nome'] as String,
      telefone: json['telefone'] as String?,
      email: json['email'] as String?,
      mensagem: json['mensagem'] as String?,
      dataHora: DateTime.parse(json['data_hora'] as String).toLocal(),
      estado: json['estado'] as String,
      criadoEm: DateTime.parse(json['criado_em'] as String).toLocal(),
      vehicleId: json['vehicle_id'] as String?,
      veiculo: marca != null ? '$marca ${modelo ?? ''}'.trim() : null,
      matricula: json['matricula'] as String?,
    );
  }

  final String id;
  final String nome;
  final String? telefone;
  final String? email;
  final String? mensagem;
  final DateTime dataHora;

  /// 'pendente' | 'aprovado' | 'rejeitado'
  final String estado;
  final DateTime criadoEm;
  final String? vehicleId;
  final String? veiculo;
  final String? matricula;

  bool get pendente => estado == 'pendente';
}
