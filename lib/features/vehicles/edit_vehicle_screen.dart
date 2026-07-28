import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import '../auth/auth_state.dart';
import 'vehicle_detail.dart';
import 'vehicles_repository.dart';

final _dataFormat = DateFormat('dd/MM/yyyy');

/// Edição de um veículo já criado. Só os campos que o backend aceita no
/// `PATCH /vehicles/:id` são editáveis aqui — matrícula/marca/modelo/chassis
/// e os campos só preenchidos via DUA (peso, matrícula anterior, etc.) não o
/// são, de propósito (decisão do utilizador: "são os únicos a ser editados").
/// Um vendedor com permissão só vê preço/kms (mesma restrição do backend,
/// `CAMPOS_EDITAVEIS_POR_VENDEDOR`).
class EditVehicleScreen extends StatefulWidget {
  const EditVehicleScreen({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _versao;
  late final TextEditingController _cor;
  late final TextEditingController _kms;
  late final TextEditingController _precoCompra;
  late final TextEditingController _precoVendaRecomendado;
  late final TextEditingController _numLugares;
  DateTime? _dataPrimeiraMatricula;
  late bool _importado;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _versao = TextEditingController(text: v.versao ?? '');
    _cor = TextEditingController(text: v.cor ?? '');
    _kms = TextEditingController(text: v.kms.toString());
    _precoCompra = TextEditingController(text: v.precoCompra?.toString() ?? '');
    _precoVendaRecomendado = TextEditingController(text: v.precoVendaRecomendado?.toString() ?? '');
    _numLugares = TextEditingController(text: v.numLugares?.toString() ?? '');
    _dataPrimeiraMatricula = v.dataPrimeiraMatricula != null ? DateTime.tryParse(v.dataPrimeiraMatricula!) : null;
    _importado = v.importado;
  }

  @override
  void dispose() {
    for (final c in [_versao, _cor, _kms, _precoCompra, _precoVendaRecomendado, _numLugares]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _isOwner => context.read<AuthState>().userRole == 'owner';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final owner = _isOwner;
    final repo = context.read<VehiclesRepository>();
    try {
      await repo.update(
        widget.vehicle.id,
        kms: int.tryParse(_kms.text.trim()),
        precoCompra: double.tryParse(_precoCompra.text.replaceAll(',', '.')),
        precoVendaRecomendado: double.tryParse(_precoVendaRecomendado.text.replaceAll(',', '.')),
        versao: owner ? (_versao.text.trim().isEmpty ? null : _versao.text.trim()) : null,
        cor: owner ? (_cor.text.trim().isEmpty ? null : _cor.text.trim()) : null,
        dataPrimeiraMatricula: owner ? _dataPrimeiraMatricula?.toIso8601String().split('T').first : null,
        numLugares: owner ? int.tryParse(_numLugares.text.trim()) : null,
        importado: owner ? _importado : null,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final owner = _isOwner;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editarVeiculoTitulo)),
      body: MaxWidthBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (owner) ...[
                TextFormField(controller: _versao, decoration: InputDecoration(labelText: l10n.campoVersao)),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _kms,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoQuilometros),
                validator: (v) => int.tryParse(v?.trim() ?? '') == null ? l10n.validacaoNumeroInvalido : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoCompra,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.campoPrecoCompra),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoVendaRecomendado,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.campoPrecoVendaRecomendado),
              ),
              if (owner) ...[
                const SizedBox(height: 12),
                TextFormField(controller: _cor, decoration: InputDecoration(labelText: l10n.campoCor)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _numLugares,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.campoNumLugares),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final escolhida = await showDatePicker(
                      context: context,
                      initialDate: _dataPrimeiraMatricula ?? DateTime.now(),
                      firstDate: DateTime(1980),
                      lastDate: DateTime.now(),
                    );
                    if (escolhida != null) setState(() => _dataPrimeiraMatricula = escolhida);
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    _dataPrimeiraMatricula != null
                        ? '${l10n.campoPrimeiraMatricula}: ${_dataFormat.format(_dataPrimeiraMatricula!)}'
                        : l10n.campoPrimeiraMatricula,
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _importado,
                  onChanged: (v) => setState(() => _importado = v),
                  title: Text(l10n.campoImportado),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.guardar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
