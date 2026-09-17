import 'vehicle_photo.dart';

/// Documentos do veículo (seguro/inspeção/DUA) — cada tipo é a sua própria
/// mini-galeria, ver VehiclesRepository.listDocuments. DUA juntou-se aqui em
/// 2026-09-17 (antes só se via no ato da criação, via OCR).
class VehicleDocuments {
  VehicleDocuments({
    required this.seguro,
    required this.inspecao,
    required this.duaFrente,
    required this.duaVerso,
  });

  factory VehicleDocuments.fromJson(Map<String, dynamic> json) {
    List<VehiclePhoto> parse(String chave) =>
        (json[chave] as List<dynamic>).map((e) => VehiclePhoto.fromJson(e as Map<String, dynamic>)).toList();

    return VehicleDocuments(
      seguro: parse('seguro'),
      inspecao: parse('inspecao'),
      duaFrente: parse('dua_frente'),
      duaVerso: parse('dua_verso'),
    );
  }

  final List<VehiclePhoto> seguro;
  final List<VehiclePhoto> inspecao;
  final List<VehiclePhoto> duaFrente;
  final List<VehiclePhoto> duaVerso;
}
