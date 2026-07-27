class VehiclePhoto {
  VehiclePhoto({required this.id, required this.url, required this.criadoEm});

  factory VehiclePhoto.fromJson(Map<String, dynamic> json) => VehiclePhoto(
        id: json['id'] as String,
        url: json['url'] as String,
        criadoEm: json['criado_em'] as String,
      );

  final String id;
  final String url;
  final String criadoEm;
}
