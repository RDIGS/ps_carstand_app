import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/matricula_validator.dart';
import '../../shared/widgets/max_width_body.dart';
import 'create_vehicle_data.dart';
import 'vehicles_repository.dart';

/// Formulário único para adicionar veículo — serve os dois caminhos da
/// secção 5: "Opção A — Manual" (sem `initial`/`confirmId`) e "Opção B — via
/// DUA" (pré-preenchido a partir do OCR, `confirmId` gerado no cliente para
/// POST /vehicles/:id/confirm). O utilizador revê/corrige sempre antes de
/// submeter — nada é gravado sem passar por aqui.
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({
    super.key,
    this.initial,
    this.confirmId,
    this.duaAvisos = const [],
    this.duaFrenteBytes,
    this.duaVersoBytes,
  });

  final CreateVehicleData? initial;
  final String? confirmId;
  final List<String> duaAvisos;
  // Só não-null se o utilizador confirmou no ecrã de captura que as fotos já
  // estavam cortadas/prontas (secção 23) — guardadas só depois de o veículo
  // ser confirmado com sucesso.
  final List<int>? duaFrenteBytes;
  final List<int>? duaVersoBytes;

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _matricula;
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _versao;
  late final TextEditingController _kms;
  late final TextEditingController _precoCompra;
  late final TextEditingController _precoVendaRecomendado;
  late final TextEditingController _cor;
  late final TextEditingController _combustivel;
  late final TextEditingController _categoria;
  late final TextEditingController _cilindrada;
  late final TextEditingController _potenciaKw;
  late final TextEditingController _chassis;

  bool _submitting = false;

  bool get _isDuaFlow => widget.confirmId != null;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _matricula = TextEditingController(text: i?.matricula ?? '');
    _marca = TextEditingController(text: i?.marca ?? '');
    _modelo = TextEditingController(text: i?.modelo ?? '');
    _versao = TextEditingController(text: i?.versao ?? '');
    _kms = TextEditingController();
    _precoCompra = TextEditingController();
    _precoVendaRecomendado = TextEditingController();
    _cor = TextEditingController(text: i?.cor ?? '');
    _combustivel = TextEditingController(text: i?.combustivel ?? '');
    _categoria = TextEditingController(text: i?.categoria ?? '');
    _cilindrada = TextEditingController(text: i?.cilindrada?.toString() ?? '');
    _potenciaKw = TextEditingController(text: i?.potenciaKw?.toString() ?? '');
    _chassis = TextEditingController(text: i?.chassis ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _matricula,
      _marca,
      _modelo,
      _versao,
      _kms,
      _precoCompra,
      _precoVendaRecomendado,
      _cor,
      _combustivel,
      _categoria,
      _cilindrada,
      _potenciaKw,
      _chassis,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final i = widget.initial;
    final data = CreateVehicleData(
      matricula: _matricula.text.trim().toUpperCase(),
      marca: _marca.text.trim(),
      modelo: _modelo.text.trim(),
      kms: int.parse(_kms.text.trim()),
      origem: _isDuaFlow ? 'dua_ocr' : 'manual',
      versao: _versao.text.trim().isEmpty ? null : _versao.text.trim(),
      precoCompra: double.tryParse(_precoCompra.text.replaceAll(',', '.')),
      precoVendaRecomendado: double.tryParse(_precoVendaRecomendado.text.replaceAll(',', '.')),
      cor: _cor.text.trim().isEmpty ? null : _cor.text.trim(),
      combustivel: _combustivel.text.trim().isEmpty ? null : _combustivel.text.trim(),
      categoria: _categoria.text.trim().isEmpty ? null : _categoria.text.trim(),
      cilindrada: int.tryParse(_cilindrada.text.trim()),
      potenciaKw: int.tryParse(_potenciaKw.text.trim()),
      chassis: _chassis.text.trim().isEmpty ? null : _chassis.text.trim(),
      dataPrimeiraMatricula: i?.dataPrimeiraMatricula,
      pesoTara: i?.pesoTara,
      pesoBruto: i?.pesoBruto,
      numLugares: i?.numLugares,
      importado: i?.importado ?? false,
      matriculaAnterior: i?.matriculaAnterior,
      paisOrigemAnterior: i?.paisOrigemAnterior,
      dataPrimeiraMatriculaOriginal: i?.dataPrimeiraMatriculaOriginal,
      possivelImportado: i?.possivelImportado ?? false,
    );

    final repo = context.read<VehiclesRepository>();
    try {
      if (_isDuaFlow) {
        await repo.confirm(widget.confirmId!, data);
        if (widget.duaFrenteBytes != null && widget.duaVersoBytes != null) {
          try {
            await repo.uploadDuaPhotos(
              widget.confirmId!,
              fotoFrente: widget.duaFrenteBytes!,
              fotoVerso: widget.duaVersoBytes!,
            );
          } on ApiException {
            // Best-effort: o veículo já ficou gravado com sucesso — não vale
            // a pena falhar o fluxo todo só porque o anexo das fotos falhou.
          }
        }
      } else {
        await repo.create(data);
      }
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
    final i = widget.initial;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(_isDuaFlow ? l10n.confirmarDuaTitulo : l10n.adicionarVeiculo)),
      body: MaxWidthBody(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isDuaFlow)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(l10n.duaRevisaoAviso),
                ),
              if (i?.possivelImportado ?? false) _AvisoBanner(text: l10n.possivelImportadoAviso),
              if (i?.importado ?? false)
                _AvisoBanner(
                  cor: AppColors.azulMatricula,
                  text: i?.paisOrigemAnterior != null
                      ? l10n.importadoComPais(i!.paisOrigemAnterior!, i.matriculaAnterior ?? '-')
                      : l10n.importadoSemPais(i?.matriculaAnterior ?? '-'),
                ),
              for (final aviso in widget.duaAvisos) _AvisoBanner(text: aviso),
              const SizedBox(height: 8),
              _SectionTitle(l10n.seccaoIdentificacao),
              TextFormField(
                controller: _matricula,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l10n.campoMatricula, hintText: l10n.campoMatriculaHint),
                validator: (v) => isValidMatricula(v?.trim() ?? '') ? null : l10n.validacaoMatriculaInvalida,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _marca,
                decoration: InputDecoration(labelText: l10n.campoMarca),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelo,
                decoration: InputDecoration(labelText: l10n.campoModelo),
                validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _versao, decoration: InputDecoration(labelText: l10n.campoVersao)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kms,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoQuilometros),
                validator: (v) => int.tryParse(v?.trim() ?? '') == null ? l10n.validacaoNumeroInvalido : null,
              ),
              const SizedBox(height: 24),
              _SectionTitle(l10n.seccaoEspecificacoes),
              TextFormField(controller: _categoria, decoration: InputDecoration(labelText: l10n.campoCategoria)),
              const SizedBox(height: 12),
              TextFormField(controller: _combustivel, decoration: InputDecoration(labelText: l10n.campoCombustivel)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cilindrada,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoCilindrada),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _potenciaKw,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoPotencia),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _cor, decoration: InputDecoration(labelText: l10n.campoCor)),
              const SizedBox(height: 12),
              TextFormField(controller: _chassis, decoration: InputDecoration(labelText: l10n.campoChassis)),
              const SizedBox(height: 24),
              _SectionTitle(l10n.seccaoPrecos),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_isDuaFlow ? l10n.confirmarEGuardar : l10n.adicionarVeiculo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _AvisoBanner extends StatelessWidget {
  const _AvisoBanner({required this.text, this.cor = AppColors.amberSinal});

  final String text;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cor, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
