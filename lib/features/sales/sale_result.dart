class SaleResult {
  SaleResult({
    required this.id,
    required this.docRegistoCompraUrl,
    required this.docDuaFinalUrl,
    required this.vehicleEstado,
  });

  factory SaleResult.fromJson(Map<String, dynamic> json) => SaleResult(
        id: json['id'] as String,
        docRegistoCompraUrl: json['doc_registo_compra_url'] as String?,
        docDuaFinalUrl: json['doc_dua_final_url'] as String?,
        vehicleEstado: json['vehicle_estado'] as String,
      );

  final String id;
  final String? docRegistoCompraUrl;
  final String? docDuaFinalUrl;
  final String vehicleEstado;
}
