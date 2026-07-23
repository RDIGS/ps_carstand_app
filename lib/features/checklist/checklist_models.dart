class ChecklistTemplate {
  ChecklistTemplate({required this.id, required this.nome});

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) =>
      ChecklistTemplate(id: json['id'] as String, nome: json['nome'] as String);

  final String id;
  final String nome;
}

class VehicleChecklistItem {
  VehicleChecklistItem({required this.id, required this.descricao, required this.concluido});

  factory VehicleChecklistItem.fromJson(Map<String, dynamic> json) => VehicleChecklistItem(
        id: json['id'] as String,
        descricao: json['descricao'] as String,
        concluido: json['concluido'] as bool,
      );

  final String id;
  final String descricao;
  final bool concluido;
}
