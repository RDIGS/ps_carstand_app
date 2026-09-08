import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/max_width_body.dart';
import '../vehicles/vehicle_expenses_card.dart' show categoriaDespesaLabel;
import '../vehicles/vehicles_repository.dart';
import 'conta_pendente.dart';
import 'finance_categoria.dart';
import 'finance_repository.dart';

String _tituloItem(AppLocalizations l10n, ContaPendente item) {
  if (item.origem == 'veiculo') return categoriaDespesaLabel(l10n, item.categoria ?? 'outro');
  return financeCategoriaLabel(l10n, item.categoria);
}

/// Contas a pagar/receber (secção nova, 2026-09-08) — tudo o que ainda não
/// foi pago/recebido (lançamentos gerais e despesas de veículo com
/// `pago = false`), separado em "em atraso" e "a vencer", com atalho para
/// marcar como pago sem ter de abrir o formulário de edição completo.
class ContasPendentesScreen extends StatefulWidget {
  const ContasPendentesScreen({super.key});

  @override
  State<ContasPendentesScreen> createState() => _ContasPendentesScreenState();
}

class _ContasPendentesScreenState extends State<ContasPendentesScreen> {
  late Future<ContasPendentesResumo> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<FinanceRepository>().contasPendentes();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _marcarComoPago(ContaPendente item) async {
    final hoje = DateTime.now().toIso8601String().substring(0, 10);
    try {
      if (item.origem == 'veiculo') {
        await context.read<VehiclesRepository>().updateExpense(
              vehicleId: item.veiculoId!,
              expenseId: item.id,
              pago: true,
              data: hoje,
              limparDataVencimento: true,
            );
      } else {
        await context.read<FinanceRepository>().updateEntry(
              item.id,
              pago: true,
              data: hoje,
              limparDataVencimento: true,
            );
      }
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.financeContasPendentesTitulo)),
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<ContasPendentesResumo>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final erro = snapshot.error;
                return Center(child: Text(erro is ApiException ? erro.localizado(context) : '$erro'));
              }
              final dados = snapshot.data!;
              final emAtraso = dados.itens.where((i) => i.atrasado).toList();
              final aVencer = dados.itens.where((i) => !i.atrasado).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(l10n.financeContasPendentesDescricao, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ResumoCard(
                          label: l10n.financeContasTotalPendente,
                          valor: dados.totalPendente,
                          cor: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ResumoCard(
                          label: l10n.financeContasTotalAtraso,
                          valor: dados.totalEmAtraso,
                          cor: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ResumoCard(
                          label: l10n.financeContasTotalAVencer7Dias,
                          valor: dados.totalAVencerEm7Dias,
                          cor: AppColors.amberSinal,
                        ),
                      ),
                    ],
                  ),
                  if (dados.itens.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(l10n.financeContasPendentesVazio)),
                    ),
                  if (emAtraso.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.financeContasEmAtraso, style: Theme.of(context).textTheme.titleMedium),
                    for (final item in emAtraso)
                      _ContaPendenteTile(item: item, onMarcarComoPago: () => _marcarComoPago(item)),
                  ],
                  if (aVencer.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(l10n.financeContasAVencer, style: Theme.of(context).textTheme.titleMedium),
                    for (final item in aVencer)
                      _ContaPendenteTile(item: item, onMarcarComoPago: () => _marcarComoPago(item)),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ResumoCard extends StatelessWidget {
  const _ResumoCard({required this.label, required this.valor, required this.cor});

  final String label;
  final double valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('${valor.toStringAsFixed(0)} €', style: AppTypography.numero(fontSize: 16, color: cor)),
          ],
        ),
      ),
    );
  }
}

class _ContaPendenteTile extends StatelessWidget {
  const _ContaPendenteTile({required this.item, required this.onMarcarComoPago});

  final ContaPendente item;
  final VoidCallback onMarcarComoPago;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final positivo = item.tipo == 'receita';
    return Card(
      child: ListTile(
        leading: Icon(
          positivo ? Icons.arrow_upward : Icons.arrow_downward,
          color: positivo ? AppColors.verdeDisponivel : AppColors.amberSinal,
        ),
        title: Text(item.origem == 'veiculo' ? item.veiculo ?? _tituloItem(l10n, item) : _tituloItem(l10n, item)),
        subtitle: Text([
          if (item.descricao != null) item.descricao!,
          if (item.dataVencimento != null) l10n.financeVenceEm(item.dataVencimento!),
        ].join(' · ')),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${positivo ? '+' : '-'}${item.valor.toStringAsFixed(0)} €',
              style: AppTypography.numero(
                fontSize: 15,
                color: item.atrasado ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: l10n.financeMarcarComoPago,
              onPressed: onMarcarComoPago,
            ),
          ],
        ),
      ),
    );
  }
}
