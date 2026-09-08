import 'package:flutter/material.dart';

/// Linha "rótulo: valor" reutilizada nos diálogos de detalhe (lançamentos
/// financeiros, vendas) — evita repetir o mesmo `Padding`/`Row` a cada campo.
class DetalheLinha extends StatelessWidget {
  const DetalheLinha({super.key, required this.label, required this.valor});

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(valor)),
        ],
      ),
    );
  }
}
