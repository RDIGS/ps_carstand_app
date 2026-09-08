class EventParticipant {
  EventParticipant({required this.personId, required this.nome, required this.estado, this.respondidoEm});

  factory EventParticipant.fromJson(Map<String, dynamic> json) => EventParticipant(
        personId: json['person_id'] as String,
        nome: json['nome'] as String? ?? '?',
        estado: json['estado'] as String,
        respondidoEm: json['respondido_em'] as String?,
      );

  final String personId;
  final String nome;
  final String estado; // 'pendente' | 'aceite' | 'recusado'
  final String? respondidoEm;
}

class CalendarEvent {
  CalendarEvent({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.dataHoraInicio,
    this.dataHoraFim,
    this.veiculoId,
    this.veiculoLabel,
    this.leadId,
    this.leadNome,
    required this.criadoPor,
    required this.criadoPorNome,
    required this.concluido,
    required this.participantes,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    final matricula = json['matricula'] as String?;
    return CalendarEvent(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      dataHoraInicio: DateTime.parse(json['data_hora_inicio'] as String).toLocal(),
      dataHoraFim:
          json['data_hora_fim'] != null ? DateTime.parse(json['data_hora_fim'] as String).toLocal() : null,
      veiculoId: json['vehicle_id'] as String?,
      veiculoLabel: matricula != null ? '$matricula — ${json['marca']} ${json['modelo']}' : null,
      leadId: json['lead_id'] as String?,
      leadNome: json['lead_nome'] as String?,
      criadoPor: json['criado_por'] as String,
      criadoPorNome: json['criado_por_nome'] as String? ?? '?',
      concluido: json['concluido'] as bool,
      participantes:
          (json['participantes'] as List<dynamic>).map((e) => EventParticipant.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String id;
  final String titulo;
  final String? descricao;
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final String? veiculoId;
  final String? veiculoLabel;
  final String? leadId;
  final String? leadNome;
  final String criadoPor;
  final String criadoPorNome;
  final bool concluido;
  final List<EventParticipant> participantes;

  /// Estado do convite do próprio utilizador neste evento, `null` se não
  /// foi convidado (ex.: é o organizador, ou é uma tarefa do stand).
  String? meuEstado(String meuPersonId) =>
      participantes.where((p) => p.personId == meuPersonId).map((p) => p.estado).firstOrNull;
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
