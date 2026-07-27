import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/simple_bar_chart.dart';
import '../../shared/widgets/simple_line_chart.dart';
import '../team/team_member.dart';
import '../team/team_repository.dart';
import '../vehicles/vehicle_expenses_card.dart';
import 'finance_categoria.dart';
import 'finance_entries_screen.dart';
import 'finance_evolution.dart';
import 'finance_repository.dart';
import 'finance_summary.dart';
import 'stock_potencial.dart';

final _dataApiFormat = DateFormat('yyyy-MM-dd');
final _dataExibicaoFormat = DateFormat('dd/MM/yyyy');

/// Dashboard financeiro (secção 12.5) — owner apenas: "onde ganho dinheiro".
/// Reformulado em 2026-07-27 com filtros (intervalo de datas livre,
/// vendedor, marca/modelo), despesas gerais vs. de veículo sempre em
/// separado, evolução mensal e margem potencial do stock — antes disto a
/// app nunca sequer usava o filtro de período que o backend já suportava.
class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  late Future<FinanceSummary> _futureSummary;
  late Future<List<FinanceEvolutionPoint>> _futureEvolution;
  late Future<StockPotencial> _futureStockPotencial;
  late Future<List<TeamMember>> _futureVendedores;

  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _vendedorId;
  String? _vendedorNome;
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _aplicarPreset('esteMes');
    _load();
    _futureEvolution = context.read<FinanceRepository>().evolution();
    _futureStockPotencial = context.read<FinanceRepository>().stockPotencial();
    _futureVendedores = context
        .read<TeamRepository>()
        .list()
        .then((membros) => membros.where((m) => m.role == 'vendedor').toList());
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    super.dispose();
  }

  bool get _temFiltrosAtivos =>
      _vendedorId != null || _marcaController.text.isNotEmpty || _modeloController.text.isNotEmpty;

  void _aplicarPreset(String preset) {
    final agora = DateTime.now();
    switch (preset) {
      case 'ultimos90':
        _dataInicio = agora.subtract(const Duration(days: 90));
        _dataFim = agora;
        break;
      case 'esteAno':
        _dataInicio = DateTime(agora.year, 1, 1);
        _dataFim = agora;
        break;
      case 'esteMes':
      default:
        _dataInicio = DateTime(agora.year, agora.month, 1);
        _dataFim = DateTime(agora.year, agora.month + 1, 0);
    }
  }

  void _load() {
    _futureSummary = context.read<FinanceRepository>().summary(
          dataInicio: _dataInicio != null ? _dataApiFormat.format(_dataInicio!) : null,
          dataFim: _dataFim != null ? _dataApiFormat.format(_dataFim!) : null,
          vendedorId: _vendedorId,
          marca: _marcaController.text.trim(),
          modelo: _modeloController.text.trim(),
        );
  }

  Future<void> _refresh() async {
    setState(_load);
    await _futureSummary;
  }

  Future<void> _abrirFiltros() async {
    final l10n = context.l10n;
    DateTime? dataInicioTemp = _dataInicio;
    DateTime? dataFimTemp = _dataFim;
    String? vendedorIdTemp = _vendedorId;
    String? vendedorNomeTemp = _vendedorNome;
    final marcaTemp = TextEditingController(text: _marcaController.text);
    final modeloTemp = TextEditingController(text: _modeloController.text);

    final vendedores = await _futureVendedores;
    if (!mounted) return;

    final aplicou = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.filtrosTitulo, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.filtroEsteMes),
                    selected: false,
                    onSelected: (_) => setSheetState(() {
                      final agora = DateTime.now();
                      dataInicioTemp = DateTime(agora.year, agora.month, 1);
                      dataFimTemp = DateTime(agora.year, agora.month + 1, 0);
                    }),
                  ),
                  ChoiceChip(
                    label: Text(l10n.filtroUltimos90Dias),
                    selected: false,
                    onSelected: (_) => setSheetState(() {
                      final agora = DateTime.now();
                      dataInicioTemp = agora.subtract(const Duration(days: 90));
                      dataFimTemp = agora;
                    }),
                  ),
                  ChoiceChip(
                    label: Text(l10n.filtroEsteAno),
                    selected: false,
                    onSelected: (_) => setSheetState(() {
                      final agora = DateTime.now();
                      dataInicioTemp = DateTime(agora.year, 1, 1);
                      dataFimTemp = agora;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final escolhida = await showDatePicker(
                          context: context,
                          initialDate: dataInicioTemp ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (escolhida != null) setSheetState(() => dataInicioTemp = escolhida);
                      },
                      child: Text(
                        dataInicioTemp != null ? _dataExibicaoFormat.format(dataInicioTemp!) : l10n.filtroDataInicio,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final escolhida = await showDatePicker(
                          context: context,
                          initialDate: dataFimTemp ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (escolhida != null) setSheetState(() => dataFimTemp = escolhida);
                      },
                      child: Text(dataFimTemp != null ? _dataExibicaoFormat.format(dataFimTemp!) : l10n.filtroDataFim),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: vendedorIdTemp,
                decoration: InputDecoration(labelText: l10n.filtroVendedor),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.filtroTodos)),
                  for (final v in vendedores) DropdownMenuItem(value: v.personId, child: Text(v.nome)),
                ],
                onChanged: (v) => setSheetState(() {
                  vendedorIdTemp = v;
                  vendedorNomeTemp = v == null ? null : vendedores.firstWhere((m) => m.personId == v).nome;
                }),
              ),
              const SizedBox(height: 12),
              TextField(controller: marcaTemp, decoration: InputDecoration(labelText: l10n.filtroMarca)),
              const SizedBox(height: 12),
              TextField(controller: modeloTemp, decoration: InputDecoration(labelText: l10n.filtroModelo)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setSheetState(() {
                          dataInicioTemp = null;
                          dataFimTemp = null;
                          vendedorIdTemp = null;
                          vendedorNomeTemp = null;
                          marcaTemp.clear();
                          modeloTemp.clear();
                        });
                      },
                      child: Text(l10n.filtroLimpar),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _dataInicio = dataInicioTemp;
                        _dataFim = dataFimTemp;
                        _vendedorId = vendedorIdTemp;
                        _vendedorNome = vendedorNomeTemp;
                        _marcaController.text = marcaTemp.text;
                        _modeloController.text = modeloTemp.text;
                        Navigator.of(context).pop(true);
                      },
                      child: Text(l10n.filtroAplicar),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (aplicou == true) {
      // Sem período definido (limpou tudo), volta ao mês corrente por
      // omissão — o backend exige sempre algum intervalo.
      if (_dataInicio == null || _dataFim == null) _aplicarPreset('esteMes');
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financeiroTitulo),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _temFiltrosAtivos,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _abrirFiltros,
            tooltip: l10n.filtrosTitulo,
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: l10n.lancamentosVerTodos,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FinanceEntriesScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<FinanceSummary>(
          future: _futureSummary,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final erro = snapshot.error;
              return Center(child: Text(erro is ApiException ? erro.localizado(context) : '$erro'));
            }
            final resumo = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${_dataExibicaoFormat.format(DateTime.parse(resumo.periodoInicio))} — '
                  '${_dataExibicaoFormat.format(DateTime.parse(resumo.periodoFim))}'
                  '${_vendedorNome != null ? ' · $_vendedorNome' : ''}'
                  '${_marcaController.text.isNotEmpty ? ' · ${_marcaController.text}' : ''}'
                  '${_modeloController.text.isNotEmpty ? ' ${_modeloController.text}' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                _CashflowCard(resumo: resumo),
                const SizedBox(height: 20),

                _EvolucaoSection(future: _futureEvolution),
                const SizedBox(height: 20),

                _DespesasCategoriaSection(
                  titulo: l10n.despesasGeraisPorCategoriaTitulo,
                  itens: resumo.despesasGeraisPorCategoria,
                  cor: AppColors.amberSinal,
                  // Despesas gerais da empresa usam as categorias de
                  // finance_entries (renda, salários, marketing, ...).
                  label: financeCategoriaLabel,
                ),
                const SizedBox(height: 20),
                _DespesasCategoriaSection(
                  titulo: l10n.despesasVeiculosPorCategoriaTitulo,
                  itens: resumo.despesasVeiculosPorCategoria,
                  cor: AppColors.grafiteVendido,
                  // Despesas por veículo usam um enum totalmente diferente
                  // (reparação, transporte, legalização, ...) — bug real
                  // apanhado ao testar visualmente: usar financeCategoriaLabel
                  // aqui mostrava sempre "Sem categoria".
                  label: (l10n, cat) => cat == null ? l10n.financeSemCategoria : categoriaDespesaLabel(l10n, cat),
                ),
                const SizedBox(height: 20),

                _StockPotencialSection(future: _futureStockPotencial),
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
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const FinanceEntriesScreen(abrirNovoAoEntrar: true)))
            .then((_) => _refresh()),
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

class _EvolucaoSection extends StatelessWidget {
  const _EvolucaoSection({required this.future});

  final Future<List<FinanceEvolutionPoint>> future;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<List<FinanceEvolutionPoint>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final pontos = snapshot.data!;
        if (pontos.every((p) => p.cashflow == 0 && p.vendas == 0)) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.evolucaoTitulo, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            SimpleLineChart(
              color: AppColors.azulMatricula,
              entries: [
                for (final p in pontos) LineChartEntry(label: p.periodo.substring(5), value: p.cashflow),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DespesasCategoriaSection extends StatelessWidget {
  const _DespesasCategoriaSection({required this.titulo, required this.itens, required this.cor, required this.label});

  final String titulo;
  final List<CategoriaTotal> itens;
  final Color cor;
  final String Function(AppLocalizations l10n, String? categoria) label;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (itens.isEmpty)
          Text(l10n.despesasSemLancamentos)
        else
          Card(
            child: Column(
              children: [
                for (final item in itens)
                  ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 10, color: cor),
                    title: Text(label(l10n, item.categoria)),
                    trailing: Text(
                      '${item.total.toStringAsFixed(0)} €',
                      style: AppTypography.numero(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StockPotencialSection extends StatelessWidget {
  const _StockPotencialSection({required this.future});

  final Future<StockPotencial> future;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FutureBuilder<StockPotencial>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final stock = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.margemPotencialTitulo, style: Theme.of(context).textTheme.titleLarge),
                if (stock.veiculos.isNotEmpty)
                  Text(
                    '${l10n.margemPotencialTotal}: ${stock.totalMargemPotencial.toStringAsFixed(0)} €',
                    style: AppTypography.numero(fontSize: 14, color: AppColors.verdeDisponivel),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (stock.veiculos.isEmpty)
              Text(l10n.margemPotencialVazio)
            else
              for (final v in stock.veiculos)
                Card(
                  child: ListTile(
                    title: Text('${v.matricula} · ${v.marca} ${v.modelo}'),
                    subtitle: Text(l10n.diasEmStock(v.diasEmStock)),
                    trailing: Text(
                      '${v.margemPotencial.toStringAsFixed(0)} €',
                      style: AppTypography.numero(fontSize: 15, color: AppColors.verdeDisponivel),
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}
