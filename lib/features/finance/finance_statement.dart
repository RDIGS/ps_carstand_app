class FinanceStatement {
  FinanceStatement({required this.pdfUrl, required this.csvUrl});

  factory FinanceStatement.fromJson(Map<String, dynamic> json) => FinanceStatement(
        pdfUrl: json['pdfUrl'] as String,
        csvUrl: json['csvUrl'] as String,
      );

  final String pdfUrl;
  final String csvUrl;
}
