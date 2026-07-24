import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/simple_bar_chart.dart';
import 'finance_repository.dart';
import 'finance_summary.dart';

/// Dashboard financeiro (secção 12.5) — owner apenas: "onde ganho dinheiro".
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<FinanceSummary> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<FinanceRepository>().summary();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _abrirNovaEntrada() async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final valorController = TextEditingController();
    final categoriaController = TextEditingController();
    final descricaoController = TextEditingController();
    String tipo = 'despesa';

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.novoMovimentoTitulo),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'despesa', label: Text(l10n.tipoDespesa)),
                    ButtonSegment(value: 'receita', label: Text(l10n.tipoReceita)),
                  ],
                  selected: {tipo},
                  onSelectionChanged: (v) => setDialogState(() => tipo = v.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.campoValor),
                  validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? l10n.validacaoValorInvalido : null,
                ),
                TextFormField(controller: categoriaController, decoration: InputDecoration(labelText: l10n.campoCategoriaFinanceira)),
                TextFormField(controller: descricaoController, decoration: InputDecoration(labelText: l10n.campoDescricao)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.of(context).pop(true);
              },
              child: Text(l10n.guardar),
            ),
          ],
        ),
      ),
    );

    if (confirmou != true || !mounted) return;
    try {
      await context.read<FinanceRepository>().createEntry(
            tipo: tipo,
            valor: double.parse(valorController.text.replaceAll(',', '.')),
            categoria: categoriaController.text.trim().isEmpty ? null : categoriaController.text.trim(),
            descricao: descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim(),
          );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.financeiroTitulo)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<FinanceSummary>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            final resumo = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('${resumo.periodoInicio} — ${resumo.periodoFim}', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                _CashflowCard(resumo: resumo),
                const SizedBox(height: 20),
                Text(l10n.margemPorMarcaModelo, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (resumo.margemPorMarcaModelo.isEmpty) Text(l10n.semVendasPeriodo),
                if (resumo.margemPorMarcaModelo.isNotEmpty) ...[
                  SimpleBarChart(
                    color: AppColors.verdeDisponivel,
                    entries: [
                      for (final linha in resumo.margemPorMarcaModelo.take(6))
                        BarChartEntry(
                          label: '${linha['marca']} ${linha['modelo']}',
                          value: parseFinanceDecimal(linha['margem_media']) ?? 0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                for (final linha in resumo.margemPorMarcaModelo)
                  Card(
                    child: ListTile(
                      title: Text('${linha['marca']} ${linha['modelo']}'),
                      subtitle: Text(l10n.numVendas(parseCount(linha['num_vendas']))),
                      trailing: Text(
                        '${(parseFinanceDecimal(linha['margem_media']) ?? 0).toStringAsFixed(0)} €',
                        style: AppTypography.numero(fontSize: 15, color: AppColors.verdeDisponivel),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(l10n.rankingVendedores, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (resumo.rankingVendedores.isEmpty) Text(l10n.semVendasPeriodo),
                if (resumo.rankingVendedores.isNotEmpty) ...[
                  SimpleBarChart(
                    entries: [
                      for (final linha in resumo.rankingVendedores.take(6))
                        BarChartEntry(
                          label: (linha['vendedor_nome'] as String?) ?? '?',
                          value: parseFinanceDecimal(linha['valor_total']) ?? 0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                for (final linha in resumo.rankingVendedores)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person, color: AppColors.azulMatricula),
                      title: Text((linha['vendedor_nome'] as String?) ?? '?'),
                      subtitle: Text(
                        '${l10n.numVendas(parseCount(linha['num_vendas']))} · '
                        '${l10n.comissaoLabel((parseFinanceDecimal(linha['comissao_total']) ?? 0).toStringAsFixed(0))}',
                      ),
                      trailing: Text(
                        '${(parseFinanceDecimal(linha['valor_total']) ?? 0).toStringAsFixed(0)} €',
                        style: AppTypography.numero(fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(l10n.margemPorVeiculo, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (resumo.margemPorVeiculo.isEmpty) Text(l10n.semVendasPeriodo),
                for (final linha in resumo.margemPorVeiculo)
                  Card(
                    child: ListTile(
                      title: Text('${linha['matricula']} · ${linha['marca']} ${linha['modelo']}'),
                      subtitle: Text(l10n.diasEmStock((linha['dias_em_stock'] as num).toInt())),
                      trailing: Text(
                        '${(parseFinanceDecimal(linha['margem_real']) ?? 0).toStringAsFixed(0)} €',
                        style: AppTypography.numero(fontSize: 15, color: AppColors.verdeDisponivel),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Tag própria (secção técnica): o HomeShell mantém todos os separadores
        // montados em simultâneo via IndexedStack, por isso os FABs de cada
        // ecrã partilhariam a mesma tag por omissão — e colidiam ao navegar.
        heroTag: 'finance-fab',
        onPressed: _abrirNovaEntrada,
        icon: const Icon(Icons.add),
        label: Text(l10n.movimento),
      ),
    );
  }
}

class _CashflowCard extends StatelessWidget {
  const _CashflowCard({required this.resumo});

  final FinanceSummary resumo;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final positivo = resumo.cashflowDoMes >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cashflowDoMes, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '${resumo.cashflowDoMes.toStringAsFixed(0)} €',
              style: AppTypography.numero(
                fontSize: 32,
                color: positivo ? AppColors.verdeDisponivel : AppColors.amberSinal,
              ),
            ),
            if (resumo.desvioPrecoRecomendadoMedio != null || resumo.comparacaoMercadoMedia != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (resumo.desvioPrecoRecomendadoMedio != null)
                    _MiniStat(
                      label: l10n.desvioVsRecomendado,
                      value: '${resumo.desvioPrecoRecomendadoMedio!.toStringAsFixed(0)} €',
                    ),
                  if (resumo.comparacaoMercadoMedia != null)
                    _MiniStat(
                      label: l10n.vsmercado,
                      value: '${resumo.comparacaoMercadoMedia!.toStringAsFixed(0)} €',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: AppTypography.numero(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
