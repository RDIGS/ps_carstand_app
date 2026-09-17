import 'package:flutter/material.dart';

import '../../features/vehicles/vehicle.dart';
import '../../features/vehicles/vehicles_repository.dart';

/// Seletor de veículo por matrícula/marca/modelo (secção nova, 2026-09-17,
/// "fatura para várias despesas") — não existia nenhum seletor de veículo
/// reutilizável no projeto. Usa `Autocomplete`, widget standard do Flutter,
/// para não adicionar uma dependência nova só para isto (mesma filosofia já
/// usada para não instalar um pacote de calendário visual). Carrega a lista
/// de veículos uma vez (até 500 — cobre o caso de uso atual de um stand) e
/// filtra localmente, sem pedir de novo a cada letra.
class VehiclePickerField extends StatefulWidget {
  const VehiclePickerField({
    super.key,
    required this.repository,
    required this.onSelected,
    this.veiculoInicial,
    this.label,
  });

  final VehiclesRepository repository;
  final ValueChanged<Vehicle?> onSelected;
  final Vehicle? veiculoInicial;
  final String? label;

  @override
  State<VehiclePickerField> createState() => _VehiclePickerFieldState();
}

class _VehiclePickerFieldState extends State<VehiclePickerField> {
  late Future<List<Vehicle>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.list(limit: 500).then((page) => page.data);
  }

  String _rotulo(Vehicle v) => '${v.matricula} · ${v.marca} ${v.modelo}';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vehicle>>(
      future: _future,
      builder: (context, snapshot) {
        final veiculos = snapshot.data ?? const <Vehicle>[];
        return Autocomplete<Vehicle>(
          displayStringForOption: _rotulo,
          initialValue: TextEditingValue(text: widget.veiculoInicial != null ? _rotulo(widget.veiculoInicial!) : ''),
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) return veiculos;
            final termo = textEditingValue.text.toLowerCase();
            return veiculos.where((v) => _rotulo(v).toLowerCase().contains(termo));
          },
          onSelected: widget.onSelected,
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: snapshot.connectionState == ConnectionState.waiting
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
