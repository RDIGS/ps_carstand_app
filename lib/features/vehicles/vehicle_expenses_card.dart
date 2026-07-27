import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import 'vehicle_expense.dart';
import 'vehicles_repository.dart';

String categoriaDespesaLabel(AppLocalizations l10n, String categoria) {
  switch (categoria) {
    case 'reparacao':
      return l10n.despesaCategoriaReparacao;
    case 'transporte':
      return l10n.despesaCategoriaTransporte;
    case 'legalizacao':
      return l10n.despesaCategoriaLegalizacao;
    case 'limpeza_detalhe':
      return l10n.despesaCategoriaLimpezaDetalhe;
    default:
      return l10n.despesaCategoriaOutro;
  }
}

/// Despesas por veículo (usadas no cálculo de margem real do Financeiro,
/// secção 12.5) — só owner vê/regista, tal como o preço de compra.
class VehicleExpensesCard extends StatefulWidget {
  const VehicleExpensesCard({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleExpensesCard> createState() => _VehicleExpensesCardState();
}

class _VehicleExpensesCardState extends State<VehicleExpensesCard> {
  late Future<List<VehicleExpense>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<VehiclesRepository>().listExpenses(widget.vehicleId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  /// Formulário partilhado por adicionar e editar — devolve os valores
  /// escolhidos, ou `null` se cancelado.
  Future<(String categoria, double valor, String? descricao)?> _formularioDespesa({
    required String tituloDialogo,
    String? categoriaInicial,
    double? valorInicial,
    String? descricaoInicial,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final valorController = TextEditingController(text: valorInicial?.toStringAsFixed(2));
    final descricaoController = TextEditingController(text: descricaoInicial);
    String categoria = categoriaInicial ?? vehicleExpenseCategorias.first;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(tituloDialogo),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: InputDecoration(labelText: l10n.campoCategoria),
                  items: [
                    for (final c in vehicleExpenseCategorias)
                      DropdownMenuItem(value: c, child: Text(categoriaDespesaLabel(l10n, c))),
                  ],
                  onChanged: (v) => setDialogState(() => categoria = v ?? categoria),
                ),
                TextFormField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: l10n.campoValor),
                  validator: (v) => double.tryParse((v ?? '').replaceAll(',', '.')) == null ? l10n.validacaoValorInvalido : null,
                ),
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

    if (confirmou != true) return null;
    return (
      categoria,
      double.parse(valorController.text.replaceAll(',', '.')),
      descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim(),
    );
  }

  Future<void> _adicionarDespesa() async {
    final resultado = await _formularioDespesa(tituloDialogo: context.l10n.despesasNovaTitulo);
    if (resultado == null || !mounted) return;
    try {
      await context.read<VehiclesRepository>().addExpense(
            vehicleId: widget.vehicleId,
            categoria: resultado.$1,
            valor: resultado.$2,
            descricao: resultado.$3,
          );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _editarDespesa(VehicleExpense despesa) async {
    final resultado = await _formularioDespesa(
      tituloDialogo: context.l10n.despesasEditarTitulo,
      categoriaInicial: despesa.categoria,
      valorInicial: despesa.valor,
      descricaoInicial: despesa.descricao,
    );
    if (resultado == null || !mounted) return;
    try {
      await context.read<VehiclesRepository>().updateExpense(
            vehicleId: widget.vehicleId,
            expenseId: despesa.id,
            categoria: resultado.$1,
            valor: resultado.$2,
            descricao: resultado.$3 ?? '',
          );
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _apagarDespesa(VehicleExpense despesa) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.despesasApagarTitulo),
        content: Text(l10n.despesasApagarConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await context.read<VehiclesRepository>().removeExpense(vehicleId: widget.vehicleId, expenseId: despesa.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<VehicleExpense>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            final despesas = snapshot.data!;
            final total = despesas.fold<double>(0, (soma, d) => soma + d.valor);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.despesasTitulo, style: Theme.of(context).textTheme.titleLarge),
                    if (despesas.isNotEmpty)
                      Text(
                        '${total.toStringAsFixed(0)} €',
                        style: AppTypography.numero(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
                      ),
                  ],
                ),
                if (despesas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.despesasVazio, style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  for (final despesa in despesas)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: const Icon(Icons.receipt_long, color: AppColors.grafiteVendido),
                      title: Text(categoriaDespesaLabel(l10n, despesa.categoria)),
                      subtitle: despesa.descricao != null ? Text(despesa.descricao!) : Text(despesa.data),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${despesa.valor.toStringAsFixed(0)} €',
                            style: AppTypography.numero(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'editar') _editarDespesa(despesa);
                              if (value == 'apagar') _apagarDespesa(despesa);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'editar', child: Text(l10n.editar)),
                              PopupMenuItem(value: 'apagar', child: Text(l10n.remover)),
                            ],
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _adicionarDespesa,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.despesasAdicionar),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
