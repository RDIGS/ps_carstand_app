import 'vehicle_photo.dart';

/// Documentos do veículo (seguro/inspeção) — cada tipo é a sua própria
/// mini-galeria, ver VehiclesRepository.listDocuments.
class VehicleDocuments {
  VehicleDocuments({required this.seguro, required this.inspecao});

  factory VehicleDocuments.fromJson(Map<String, dynamic> json) => VehicleDocuments(
        seguro: (json['seguro'] as List<dynamic>).map((e) => VehiclePhoto.fromJson(e as Map<String, dynamic>)).toList(),
        inspecao:
            (json['inspecao'] as List<dynamic>).map((e) => VehiclePhoto.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final List<VehiclePhoto> seguro;
  final List<VehiclePhoto> inspecao;
}
