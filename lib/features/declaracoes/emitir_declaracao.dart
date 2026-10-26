import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/max_width_body.dart';
import '../sales/identity_capture_screen.dart';
import 'declaracao.dart';
import 'declaracoes_repository.dart';

String tituloDeclaracao(AppLocalizations l10n, String tipo) {
  switch (tipo) {
    case 'compra':
      return l10n.declaracaoCompra;
    case 'venda':
      return l10n.declaracaoVenda;
    case 'circulacao':
      return l10n.declaracaoCirculacao;
    default:
      return l10n.declaracaoCaracteristicas;
  }
}

/// Pede os dados do cliente (CC ou à mão), emite a declaração no backend e
/// abre o PDF. Devolve a declaração emitida, ou `null` se o utilizador desistiu.
Future<Declaracao?> emitirDeclaracao(BuildContext context, {required String vehicleId, required String tipo}) async {
  final dados = await Navigator.of(context).push<DadosCliente>(
    MaterialPageRoute(builder: (_) => DadosClienteScreen(tipo: tipo)),
  );
  if (dados == null || !context.mounted) return null;

  final l10n = context.l10n;
  final repo = context.read<DeclaracoesRepository>();
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final declaracao = await repo.emitir(vehicleId, tipo, dados);
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.declaracaoEmitida)));
    }
    await launchUrl(Uri.parse(declaracao.url), mode: LaunchMode.externalApplication);
    return declaracao;
  } on ApiException catch (e) {
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
    return null;
  }
}

/// Dados do cliente para uma declaração: botão para ler o Cartão de Cidadão
/// (preenche os campos) ou escrita à mão. Na de características pede também
/// os pneus; na de características não há morada no modelo.
class DadosClienteScreen extends StatefulWidget {
  const DadosClienteScreen({super.key, required this.tipo});

  final String tipo;

  @override
  State<DadosClienteScreen> createState() => _DadosClienteScreenState();
}

class _DadosClienteScreenState extends State<DadosClienteScreen> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _morada = TextEditingController();
  final _nif = TextEditingController();
  final _pneusFrente = TextEditingController();
  final _pneusTras = TextEditingController();

  bool get _caracteristicas => widget.tipo == 'caracteristicas';

  @override
  void dispose() {
    for (final c in [_nome, _morada, _nif, _pneusFrente, _pneusTras]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _lerCartao() async {
    final outcome = await Navigator.of(context).push<IdentityCaptureOutcome>(
      MaterialPageRoute(builder: (_) => const IdentityCaptureScreen()),
    );
    if (outcome == null || !mounted) return;
    final r = outcome.result;
    setState(() {
      if (r.nomeCompleto != null) _nome.text = r.nomeCompleto!;
      if (r.nif != null) _nif.text = r.nif!;
      if (r.morada != null) _morada.text = r.morada!;
    });
  }

  String? _ouNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  void _confirmar() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      DadosCliente(
        nome: _nome.text.trim(),
        morada: _caracteristicas ? null : _ouNull(_morada),
        nif: _ouNull(_nif),
        pneusDianteiros: _caracteristicas ? _ouNull(_pneusFrente) : null,
        pneusTraseiros: _caracteristicas ? _ouNull(_pneusTras) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(tituloDeclaracao(l10n, widget.tipo))),
      body: MaxWidthBody(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                widget.tipo == 'compra' ? l10n.dadosVendedorTitulo : l10n.dadosClienteTitulo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.badge_outlined),
                label: Text(l10n.lerCartaoCidadao),
                onPressed: _lerCartao,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 8),
                child: Text(l10n.lerCartaoCidadaoAjuda, style: Theme.of(context).textTheme.bodySmall),
              ),
              TextFormField(
                controller: _nome,
                maxLength: 150,
                decoration: InputDecoration(labelText: l10n.campoNome),
                validator: (v) => (v ?? '').trim().length < 2 ? l10n.validacaoCampoObrigatorio : null,
              ),
              if (!_caracteristicas)
                TextFormField(
                  controller: _morada,
                  maxLength: 300,
                  decoration: InputDecoration(labelText: l10n.campoMorada),
                ),
              TextFormField(
                controller: _nif,
                maxLength: 20,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.campoNifOpcional),
              ),
              if (_caracteristicas) ...[
                TextFormField(
                  controller: _pneusFrente,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: l10n.campoPneusDianteiros),
                ),
                TextFormField(
                  controller: _pneusTras,
                  maxLength: 40,
                  decoration: InputDecoration(labelText: l10n.campoPneusTraseiros),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l10n.declaracaoEmitir),
                onPressed: _confirmar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
