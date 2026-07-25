import 'vehicle.dart';

class VehicleExpense {
  VehicleExpense({
    required this.id,
    required this.categoria,
    required this.valor,
    required this.data,
    this.descricao,
  });

  factory VehicleExpense.fromJson(Map<String, dynamic> json) => VehicleExpense(
        id: json['id'] as String,
        categoria: json['categoria'] as String,
        valor: parseDecimal(json['valor']) ?? 0,
        data: json['data'] as String,
        descricao: json['descricao'] as String?,
      );

  final String id;
  final String categoria;
  final double valor;
  final String data;
  final String? descricao;
}

const vehicleExpenseCategorias = ['reparacao', 'transporte', 'legalizacao', 'limpeza_detalhe', 'outro'];
