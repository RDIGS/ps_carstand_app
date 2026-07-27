import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import 'lead.dart';
import 'leads_repository.dart';

final _dataFormat = DateFormat('dd/MM/yyyy');

String leadOrigemLabel(BuildContext context, String? origem) {
  final l10n = context.l10n;
  switch (origem) {
    case 'telefone':
      return l10n.leadOrigemTelefone;
    case 'whatsapp':
      return l10n.leadOrigemWhatsapp;
    case 'presencial':
      return l10n.leadOrigemPresencial;
    case 'standvirtual':
      return l10n.leadOrigemStandvirtual;
    case 'olx':
      return l10n.leadOrigemOlx;
    case 'custojusto':
      return l10n.leadOrigemCustojusto;
    default:
      return l10n.leadOrigemOutro;
  }
}

String leadEstadoLabel(BuildContext context, String estado) {
  final l10n = context.l10n;
  switch (estado) {
    case 'novo':
      return l10n.leadEstadoNovo;
    case 'contactado':
      return l10n.leadEstadoContactado;
    case 'agendado':
      return l10n.leadEstadoAgendado;
    case 'convertido':
      return l10n.leadEstadoConvertido;
    default:
      return l10n.leadEstadoPerdido;
  }
}

/// Criar (lead == null) ou editar um lead do CRM básico de interessados.
class LeadFormScreen extends StatefulWidget {
  const LeadFormScreen({super.key, this.lead});

  final Lead? lead;

  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.lead?.nome);
  late final _telefoneController = TextEditingController(text: widget.lead?.telefone);
  late final _emailController = TextEditingController(text: widget.lead?.email);
  late final _notasController = TextEditingController(text: widget.lead?.notas);
  late String _origem = widget.lead?.origem ?? 'telefone';
  late String _estado = widget.lead?.estado ?? 'novo';
  late DateTime? _proximoContacto =
      widget.lead?.proximoContacto != null ? DateTime.tryParse(widget.lead!.proximoContacto!) : null;
  bool _submitting = false;

  bool get _aEditar => widget.lead != null;

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final repo = context.read<LeadsRepository>();
    try {
      if (_aEditar) {
        await repo.update(
          widget.lead!.id,
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          origem: _origem,
          estado: _estado,
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
          proximoContacto: _proximoContacto?.toIso8601String().split('T').first,
        );
      } else {
        await repo.create(
          nome: _nomeController.text.trim(),
          telefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
          email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
          origem: _origem,
          notas: _notasController.text.trim().isEmpty ? null : _notasController.text.trim(),
          proximoContacto: _proximoContacto?.toIso8601String().split('T').first,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
      }
    }
  }

  Future<void> _eliminar() async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leadEliminarTitulo),
        content: Text(l10n.leadEliminarConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      await context.read<LeadsRepository>().remove(widget.lead!.id);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_aEditar ? l10n.leadEditarTitulo : l10n.leadNovoTitulo),
        actions: [
          if (_aEditar) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _eliminar),
        ],
      ),
      body: MaxWidthBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: l10n.campoNome),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.campoTelefone),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _origem,
                decoration: InputDecoration(labelText: l10n.leadCampoOrigem),
                items: [
                  for (final origem in leadOrigens)
                    DropdownMenuItem(value: origem, child: Text(leadOrigemLabel(context, origem))),
                ],
                onChanged: (v) => setState(() => _origem = v ?? _origem),
              ),
              if (_aEditar) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _estado,
                  decoration: InputDecoration(labelText: l10n.leadCampoEstado),
                  items: [
                    for (final estado in leadEstados)
                      DropdownMenuItem(value: estado, child: Text(leadEstadoLabel(context, estado))),
                  ],
                  onChanged: (v) => setState(() => _estado = v ?? _estado),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final escolhida = await showDatePicker(
                    context: context,
                    initialDate: _proximoContacto ?? DateTime.now(),
                    firstDate: DateTime.now().subtract(const Duration(days: 1)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (escolhida != null) setState(() => _proximoContacto = escolhida);
                },
                child: Text(
                  _proximoContacto != null
                      ? l10n.leadProximoContactoData(_dataFormat.format(_proximoContacto!))
                      : l10n.leadCampoProximoContacto,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notasController,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.leadCampoNotas),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _guardar,
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
