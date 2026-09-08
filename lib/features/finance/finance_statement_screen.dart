import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import 'finance_repository.dart';
import 'finance_statement.dart';

const _mesesPt = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// Extrato financeiro mensal (PDF + CSV) — secção nova, 2026-09-07: gerar
/// um relatório completo (despesas gerais, despesas de veículos e vendas)
/// pronto a dar ao contabilista, sem ter de recolher tudo à mão do
/// dashboard.
class FinanceStatementScreen extends StatefulWidget {
  const FinanceStatementScreen({super.key});

  @override
  State<FinanceStatementScreen> createState() => _FinanceStatementScreenState();
}

class _FinanceStatementScreenState extends State<FinanceStatementScreen> {
  late int _ano;
  late int _mes;
  bool _aGerar = false;
  FinanceStatement? _resultado;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _ano = agora.year;
    _mes = agora.month;
  }

  Future<void> _gerar() async {
    setState(() {
      _aGerar = true;
      _resultado = null;
    });
    try {
      final resultado = await context.read<FinanceRepository>().statement(ano: _ano, mes: _mes);
      if (mounted) setState(() => _resultado = resultado);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _aGerar = false);
    }
  }

  Future<void> _abrir(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final anoAtual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.financeExtratoTitulo)),
      body: MaxWidthBody(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.financeExtratoDescricao, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _mes,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        for (var m = 1; m <= 12; m++) DropdownMenuItem(value: m, child: Text(_mesesPt[m - 1])),
                      ],
                      onChanged: (v) => setState(() => _mes = v ?? _mes),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _ano,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: [
                        for (var a = anoAtual - 5; a <= anoAtual; a++) DropdownMenuItem(value: a, child: Text('$a')),
                      ],
                      onChanged: (v) => setState(() => _ano = v ?? _ano),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _aGerar ? null : _gerar,
                icon: _aGerar
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.description_outlined),
                label: Text(l10n.financeExtratoGerar),
              ),
              if (_resultado != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _abrir(_resultado!.pdfUrl),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(l10n.financeExtratoAbrirPdf),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => _abrir(_resultado!.csvUrl),
                          icon: const Icon(Icons.table_chart_outlined),
                          label: Text(l10n.financeExtratoAbrirCsv),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
