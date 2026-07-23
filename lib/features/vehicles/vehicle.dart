// Colunas NUMERIC/DECIMAL do Postgres chegam como String via node-pg (ex.:
// "8900.00"), não como número JSON — confirmado em testes reais contra o
// backend. Nunca fazer `as num` diretamente nestes campos.
double? parseDecimal(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value as String);
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.matricula,
    required this.marca,
    required this.modelo,
    required this.kms,
    required this.estado,
    this.precoVendaRecomendado,
    this.fotoCapa,
    this.diasEmStock,
    this.checklistTotal,
    this.checklistConcluidos,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        matricula: json['matricula'] as String,
        marca: json['marca'] as String,
        modelo: json['modelo'] as String,
        kms: (json['kms'] as num).toInt(),
        estado: json['estado'] as String,
        precoVendaRecomendado: parseDecimal(json['preco_venda_recomendado']),
        fotoCapa: json['foto_capa'] as String?,
        diasEmStock: json['dias_em_stock'] != null ? (json['dias_em_stock'] as num).toInt() : null,
        checklistTotal: json['checklist_total'] != null ? (json['checklist_total'] as num).toInt() : null,
        checklistConcluidos:
            json['checklist_concluidos'] != null ? (json['checklist_concluidos'] as num).toInt() : null,
      );

  final String id;
  final String matricula;
  final String marca;
  final String modelo;
  final int kms;
  final String estado;
  final double? precoVendaRecomendado;
  final String? fotoCapa;
  final int? diasEmStock;
  // Percentagem informativa (secção 25) — nunca bloqueia nada, só aparece no
  // cartão do veículo quando já existe pelo menos 1 item de checklist.
  final int? checklistTotal;
  final int? checklistConcluidos;
}

class VehicleListPage {
  VehicleListPage({required this.data, required this.page, required this.totalPages, required this.totalItems});

  factory VehicleListPage.fromJson(Map<String, dynamic> json) => VehicleListPage(
        data: (json['data'] as List<dynamic>).map((e) => Vehicle.fromJson(e as Map<String, dynamic>)).toList(),
        page: json['page'] as int,
        totalPages: json['total_pages'] as int,
        totalItems: json['total_items'] as int,
      );

  final List<Vehicle> data;
  final int page;
  final int totalPages;
  final int totalItems;
}
