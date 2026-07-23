import '../../core/api/api_client.dart';
import 'checklist_models.dart';

class ChecklistRepository {
  ChecklistRepository(this._api);

  final ApiClient _api;

  Future<List<ChecklistTemplate>> listTemplates() {
    return _api.request(
      'GET',
      '/checklist-templates',
      parse: (data) =>
          (data as List<dynamic>).map((e) => ChecklistTemplate.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<ChecklistTemplate> createTemplate({required String nome, required List<String> itens}) {
    return _api.request(
      'POST',
      '/checklist-templates',
      data: {'nome': nome, 'itens': itens},
      parse: (data) => ChecklistTemplate.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<VehicleChecklistItem>> listVehicleChecklist(String vehicleId) {
    return _api.request(
      'GET',
      '/vehicles/$vehicleId/checklist',
      parse: (data) =>
          (data as List<dynamic>).map((e) => VehicleChecklistItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Future<void> applyTemplate({required String vehicleId, required String templateId}) {
    return _api.request(
      'POST',
      '/vehicles/$vehicleId/checklist/apply-template',
      data: {'templateId': templateId},
      parse: (_) {},
    );
  }

  Future<void> addItem({required String vehicleId, required String descricao}) {
    return _api.request(
      'POST',
      '/vehicles/$vehicleId/checklist/items',
      data: {'descricao': descricao},
      parse: (_) {},
    );
  }

  Future<void> setConcluido({required String vehicleId, required String itemId, required bool concluido}) {
    return _api.request(
      'PATCH',
      '/vehicles/$vehicleId/checklist/$itemId',
      data: {'concluido': concluido},
      parse: (_) {},
    );
  }
}
