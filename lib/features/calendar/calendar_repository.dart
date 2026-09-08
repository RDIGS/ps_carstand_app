import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'calendar_event.dart';

class CalendarFeedLinks {
  const CalendarFeedLinks({required this.meuUrl, required this.standUrl});

  final String meuUrl;
  final String standUrl;
}

class CalendarImportResult {
  const CalendarImportResult({required this.importados, required this.total});

  final int importados;
  final int total;
}

class CalendarRepository {
  CalendarRepository(this._api);

  final ApiClient _api;

  Future<List<CalendarEvent>> list({required DateTime inicio, required DateTime fim, String escopo = 'stand'}) {
    return _api.request(
      'GET',
      '/calendar/events',
      queryParameters: {
        'inicio': inicio.toIso8601String(),
        'fim': fim.toIso8601String(),
        'escopo': escopo,
      },
      parse: (data) => (data as List<dynamic>).map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<CalendarEvent> create({
    required String titulo,
    String? descricao,
    required DateTime dataHoraInicio,
    DateTime? dataHoraFim,
    String? veiculoId,
    String? leadId,
    List<String> participantesIds = const [],
  }) {
    return _api.request(
      'POST',
      '/calendar/events',
      data: {
        'titulo': titulo,
        if (descricao != null && descricao.isNotEmpty) 'descricao': descricao,
        'dataHoraInicio': dataHoraInicio.toIso8601String(),
        if (dataHoraFim != null) 'dataHoraFim': dataHoraFim.toIso8601String(),
        if (veiculoId != null) 'veiculoId': veiculoId,
        if (leadId != null) 'leadId': leadId,
        if (participantesIds.isNotEmpty) 'participantesIds': participantesIds,
      },
      parse: (data) => CalendarEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<CalendarEvent> update({
    required String id,
    String? titulo,
    String? descricao,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
    String? veiculoId,
    String? leadId,
    List<String>? participantesIds,
  }) {
    return _api.request(
      'PATCH',
      '/calendar/events/$id',
      data: {
        if (titulo != null) 'titulo': titulo,
        if (descricao != null) 'descricao': descricao,
        if (dataHoraInicio != null) 'dataHoraInicio': dataHoraInicio.toIso8601String(),
        if (dataHoraFim != null) 'dataHoraFim': dataHoraFim.toIso8601String(),
        if (veiculoId != null) 'veiculoId': veiculoId,
        if (leadId != null) 'leadId': leadId,
        if (participantesIds != null) 'participantesIds': participantesIds,
      },
      parse: (data) => CalendarEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<CalendarEvent> toggleConcluido(String id, bool concluido) {
    return _api.request(
      'PATCH',
      '/calendar/events/$id/concluido',
      data: {'concluido': concluido},
      parse: (data) => CalendarEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<CalendarEvent> responder(String id, String estado) {
    return _api.request(
      'POST',
      '/calendar/events/$id/responder',
      data: {'estado': estado},
      parse: (data) => CalendarEvent.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> remove(String id) {
    return _api.request('DELETE', '/calendar/events/$id', parse: (_) {});
  }

  // Link .ics subscritível (Google Calendar/iOS/Outlook fazem polling
  // sozinhos) — gerado sob pedido no backend, nunca ao criar a conta.
  Future<CalendarFeedLinks> getFeedLinks() {
    return _api.request(
      'GET',
      '/calendar/feed-links',
      parse: (data) => CalendarFeedLinks(meuUrl: data['meuUrl'] as String, standUrl: data['standUrl'] as String),
    );
  }

  // Upload manual e pontual de um ficheiro .ics — usa `_api.raw` porque
  // `uploadMultipart` assume sempre extensão .jpg (fotos), não serve aqui.
  Future<CalendarImportResult> importIcs(List<int> bytes, String nomeFicheiro) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: nomeFicheiro),
      });
      final response = await _api.raw.post<dynamic>('/calendar/import', data: formData);
      return CalendarImportResult(
        importados: response.data['importados'] as int,
        total: response.data['total'] as int,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
