import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/nif_validator.dart';
import '../../shared/widgets/max_width_body.dart';
import '../vehicles/vehicle_detail.dart';
import 'identity_capture_screen.dart';
import 'sales_repository.dart';

/// Ecrã de venda (secção 7 / O8 / V5): preenche dados do comprador, gera o
/// Registo de Compra em PDF, marca o veículo como vendido. Confirmação
/// explícita antes de submeter — é uma ação irreversível (secção 11).
class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nifController = TextEditingController();
  final _moradaController = TextEditingController();
  final _cpController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _identificacaoNumeroController = TextEditingController();
  final _precoFinalController = TextEditingController();
  final _comissaoController = TextEditingController();
  final _transmitenteNomeController = TextEditingController();
  final _transmitenteNifController = TextEditingController();
  final _transmitenteMoradaController = TextEditingController();
  final _transmitenteCpController = TextEditingController();
  final _transmitenteIdentificacaoNumeroController = TextEditingController();
  String _identificacaoTipo = 'cc';
  String _transmitenteIdentificacaoTipo = 'cc';
  bool _transmitenteEStand = true;
  bool _submitting = false;
  // Só não-null se o utilizador confirmou no ecrã de captura que as fotos já
  // estavam cortadas/prontas (secção 23) — anexadas só depois de a venda ser
  // criada com sucesso.
  List<int>? _identityFrenteBytes;
  List<int>? _identityVersoBytes;

  @override
  void initState() {
    super.initState();
    if (widget.vehicle.precoVendaRecomendado != null) {
      _precoFinalController.text = widget.vehicle.precoVendaRecomendado!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nomeController,
      _nifController,
      _moradaController,
      _cpController,
      _telefoneController,
      _identificacaoNumeroController,
      _precoFinalController,
      _comissaoController,
      _transmitenteNomeController,
      _transmitenteNifController,
      _transmitenteMoradaController,
      _transmitenteCpController,
      _transmitenteIdentificacaoNumeroController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _digitalizarDocumento() async {
    final outcome = await Navigator.of(context).push<IdentityCaptureOutcome>(
      MaterialPageRoute(builder: (_) => const IdentityCaptureScreen()),
    );
    if (outcome == null || !mounted) return;

    final r = outcome.result;
    setState(() {
      if (r.nomeCompleto != null) _nomeController.text = r.nomeCompleto!;
      if (r.nif != null) _nifController.text = r.nif!;
      if (r.morada != null) _moradaController.text = r.morada!;
      if (r.numeroDocumento != null) _identificacaoNumeroController.text = r.numeroDocumento!;
      if (r.tipoDocumento != null) _identificacaoTipo = r.tipoDocumento!;
      _identityFrenteBytes = outcome.frenteBytes;
      _identityVersoBytes = outcome.versoBytes;
    });

    if (r.avisos.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.avisos.join(' '))));
    }
  }

  Future<void> _confirmarEVender() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = context.l10n;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmarVendaTitulo),
        content: Text(
          l10n.confirmarVendaTexto(widget.vehicle.matricula, _nomeController.text.trim(), _precoFinalController.text),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.confirmarVendaTitulo)),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    setState(() => _submitting = true);
    try {
      final resultado = await context.read<SalesRepository>().create(
            vehicleId: widget.vehicle.id,
            compradorNome: _nomeController.text.trim(),
            compradorNif: _nifController.text.trim(),
            compradorMorada: _moradaController.text.trim().isEmpty ? null : _moradaController.text.trim(),
            compradorCp: _cpController.text.trim().isEmpty ? null : _cpController.text.trim(),
            compradorTelefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
            compradorIdentificacaoTipo: _identificacaoTipo,
            compradorIdentificacaoNumero:
                _identificacaoNumeroController.text.trim().isEmpty ? null : _identificacaoNumeroController.text.trim(),
            precoFinal: double.parse(_precoFinalController.text.replaceAll(',', '.')),
            comissaoVendedor: double.tryParse(_comissaoController.text.replaceAll(',', '.')),
            transmitenteEStand: _transmitenteEStand,
            transmitenteNome: _transmitenteEStand ? null : _transmitenteNomeController.text.trim(),
            transmitenteNif: _transmitenteEStand ? null : _transmitenteNifController.text.trim(),
            transmitenteMorada: _transmitenteEStand || _transmitenteMoradaController.text.trim().isEmpty
                ? null
                : _transmitenteMoradaController.text.trim(),
            transmitenteCp: _transmitenteEStand || _transmitenteCpController.text.trim().isEmpty
                ? null
                : _transmitenteCpController.text.trim(),
            transmitenteIdentificacaoTipo: _transmitenteEStand ? null : _transmitenteIdentificacaoTipo,
            transmitenteIdentificacaoNumero:
                _transmitenteEStand || _transmitenteIdentificacaoNumeroController.text.trim().isEmpty
                    ? null
                    : _transmitenteIdentificacaoNumeroController.text.trim(),
          );

      if (!mounted) return;
      if (_identityFrenteBytes != null && _identityVersoBytes != null) {
        try {
          await context.read<SalesRepository>().attachIdentityDocuments(
                resultado.id,
                tipoDocumento: _identificacaoTipo,
                fotoFrente: _identityFrenteBytes!,
                fotoVerso: _identityVersoBytes!,
              );
        } on ApiException {
          // Best-effort: a venda já ficou registada com sucesso — não vale a
          // pena falhar o fluxo todo só porque o anexo das fotos falhou.
        }
      }

      if (!mounted) return;
      // Sucesso silencioso com o essencial (secção 20: nada de "A sua
      // viatura foi vendida com sucesso!"), mas o link do PDF fica visível
      // porque é a próxima ação óbvia do utilizador.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(l10n.vendaRegistadaTitulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.vendaRegistadaTexto),
              if (resultado.docRegistoCompraUrl != null) ...[
                const SizedBox(height: 12),
                Text(l10n.registoCompraLabel),
                SelectableText(resultado.docRegistoCompraUrl!, style: const TextStyle(color: AppColors.azulMatricula)),
              ],
              if (resultado.docDuaFinalUrl != null) ...[
                const SizedBox(height: 12),
                Text(l10n.duaFinalLabel),
                SelectableText(resultado.docDuaFinalUrl!, style: const TextStyle(color: AppColors.azulMatricula)),
              ],
            ],
          ),
          actions: [
            if (resultado.docRegistoCompraUrl != null)
              TextButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: resultado.docRegistoCompraUrl!)),
                child: Text(l10n.copiarLink),
              ),
            if (resultado.docDuaFinalUrl != null)
              TextButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: resultado.docDuaFinalUrl!)),
                child: Text(l10n.duaFinalCopiarLink),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // fecha o diálogo
                Navigator.of(context).pop(true); // fecha o SaleScreen, sinaliza sucesso
              },
              child: Text(l10n.concluir),
            ),
          ],
        ),
      );
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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.venderTitulo(widget.vehicle.matricula))),
      body: MaxWidthBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(l10n.dadosComprador, style: Theme.of(context).textTheme.titleLarge)),
                  OutlinedButton.icon(
                    onPressed: _submitting ? null : _digitalizarDocumento,
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: Text(l10n.digitalizarDocumento),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(labelText: l10n.campoNome),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nifController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoNif),
                validator: (v) => isValidNif(v?.trim() ?? '') ? null : l10n.validacaoNifInvalido,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _moradaController, decoration: InputDecoration(labelText: l10n.campoMorada)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpController,
                decoration: InputDecoration(labelText: l10n.campoCodigoPostal, hintText: '0000-000'),
                inputFormatters: [_CodigoPostalFormatter()],
                validator: (v) {
                  final texto = (v ?? '').trim();
                  if (texto.isEmpty) return null;
                  return RegExp(r'^\d{4}-\d{3}$').hasMatch(texto) ? null : l10n.validacaoCodigoPostalInvalido;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.campoTelefone),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _identificacaoTipo,
                decoration: InputDecoration(labelText: l10n.campoDocumentoIdentificacao),
                items: [
                  DropdownMenuItem(value: 'cc', child: Text(l10n.documentoCC)),
                  DropdownMenuItem(value: 'bi', child: Text(l10n.documentoBI)),
                  DropdownMenuItem(value: 'titulo_residencia', child: Text(l10n.documentoTituloResidencia)),
                  DropdownMenuItem(value: 'outro', child: Text(l10n.documentoOutro)),
                ],
                onChanged: (v) => setState(() => _identificacaoTipo = v ?? 'cc'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _identificacaoNumeroController,
                decoration: InputDecoration(labelText: l10n.campoNumeroDocumento),
              ),
              const SizedBox(height: 24),
              Text(l10n.duaFinalVendedorLegalTitulo, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(l10n.duaFinalVendedorLegalTexto, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _transmitenteEStand,
                title: Text(_transmitenteEStand ? l10n.duaFinalVendedorEStand : l10n.duaFinalVendedorOutro),
                onChanged: (v) => setState(() => _transmitenteEStand = v),
              ),
              if (!_transmitenteEStand) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _transmitenteNomeController,
                  decoration: InputDecoration(labelText: l10n.campoNome),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _transmitenteNifController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.campoNif),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _transmitenteMoradaController,
                  decoration: InputDecoration(labelText: l10n.campoMorada),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _transmitenteCpController,
                  decoration: InputDecoration(labelText: l10n.campoCodigoPostal, hintText: '0000-000'),
                  inputFormatters: [_CodigoPostalFormatter()],
                  validator: (v) {
                    final texto = (v ?? '').trim();
                    if (texto.isEmpty) return null;
                    return RegExp(r'^\d{4}-\d{3}$').hasMatch(texto) ? null : l10n.validacaoCodigoPostalInvalido;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _transmitenteIdentificacaoTipo,
                  decoration: InputDecoration(labelText: l10n.campoDocumentoIdentificacao),
                  items: [
                    DropdownMenuItem(value: 'cc', child: Text(l10n.documentoCC)),
                    DropdownMenuItem(value: 'bi', child: Text(l10n.documentoBI)),
                    DropdownMenuItem(value: 'titulo_residencia', child: Text(l10n.documentoTituloResidencia)),
                    DropdownMenuItem(value: 'outro', child: Text(l10n.documentoOutro)),
                  ],
                  onChanged: (v) => setState(() => _transmitenteIdentificacaoTipo = v ?? 'cc'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _transmitenteIdentificacaoNumeroController,
                  decoration: InputDecoration(labelText: l10n.campoNumeroDocumento),
                ),
              ],
              const SizedBox(height: 24),
              Text(l10n.condicoesVenda, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precoFinalController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.campoPrecoFinal),
                validator: (v) =>
                    double.tryParse((v ?? '').replaceAll(',', '.')) == null ? l10n.validacaoValorInvalido : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _comissaoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: l10n.campoComissaoVendedor),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitting ? null : _confirmarEVender,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.registarVenda),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Formata código postal português enquanto se escreve: ####-###.
class _CodigoPostalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final todosDigitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final digitos = todosDigitos.substring(0, todosDigitos.length.clamp(0, 7));
    final formatado = digitos.length > 4 ? '${digitos.substring(0, 4)}-${digitos.substring(4)}' : digitos;
    return TextEditingValue(text: formatado, selection: TextSelection.collapsed(offset: formatado.length));
  }
}
