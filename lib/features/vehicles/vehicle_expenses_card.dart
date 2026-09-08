import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/image_source_picker.dart';
import '../../shared/widgets/network_image_safe.dart';
import '../finance/finance_repository.dart';
import '../finance/invoice_extraction_result.dart';
import '../finance/metodo_pagamento.dart';
import '../team/team_member.dart';
import '../team/team_repository.dart';
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

class _DespesaFormResultado {
  _DespesaFormResultado({
    required this.categoria,
    required this.valor,
    this.descricao,
    this.data,
    this.metodoPagamento,
    this.pagoPor,
    this.reembolsado = false,
    this.novaFotoBytes,
    this.fornecedorNome,
    this.fornecedorNif,
    this.valorIva,
    this.taxaIva,
  });

  final String categoria;
  final double valor;
  final String? descricao;
  final String? data;
  final String? metodoPagamento;
  final String? pagoPor;
  final bool reembolsado;
  final Uint8List? novaFotoBytes;
  final String? fornecedorNome;
  final String? fornecedorNif;
  final double? valorIva;
  final double? taxaIva;
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
  Future<_DespesaFormResultado?> _formularioDespesa({
    required String tituloDialogo,
    String? categoriaInicial,
    double? valorInicial,
    String? descricaoInicial,
    String? dataInicial,
    String? metodoPagamentoInicial,
    String? pagoPorInicial,
    bool reembolsadoInicial = false,
    String? comprovativoUrlInicial,
    String? fornecedorNomeInicial,
    String? fornecedorNifInicial,
    double? valorIvaInicial,
    double? taxaIvaInicial,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final valorController = TextEditingController(text: valorInicial?.toStringAsFixed(2));
    final descricaoController = TextEditingController(text: descricaoInicial);
    final dataController = TextEditingController(text: dataInicial);
    final fornecedorNomeController = TextEditingController(text: fornecedorNomeInicial);
    final fornecedorNifController = TextEditingController(text: fornecedorNifInicial);
    final valorIvaController = TextEditingController(text: valorIvaInicial?.toStringAsFixed(2));
    final taxaIvaController = TextEditingController(text: taxaIvaInicial?.toStringAsFixed(0));
    String categoria = categoriaInicial ?? vehicleExpenseCategorias.first;
    String? metodoPagamento = metodoPagamentoInicial;
    String? pagoPor = pagoPorInicial;
    bool reembolsado = reembolsadoInicial;
    String? comprovativoUrlAtual = comprovativoUrlInicial;
    Uint8List? novaFotoBytes;
    bool carregandoFoto = false;

    List<TeamMember> equipa = [];
    try {
      equipa = await context.read<TeamRepository>().list();
    } catch (_) {
      // Seletor "pago por" é só conveniência — se a lista de equipa falhar,
      // fica só com a opção "A empresa".
    }
    if (!mounted) return null;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> escolherFoto() async {
            final fonte = await escolherFonteImagem(context);
            if (fonte == null) return;
            setDialogState(() => carregandoFoto = true);
            try {
              final ficheiro = await ImagePicker().pickImage(source: fonte, imageQuality: 90, maxWidth: 2000);
              if (ficheiro != null) {
                final bytes = await ficheiro.readAsBytes();
                setDialogState(() {
                  novaFotoBytes = bytes;
                  comprovativoUrlAtual = null;
                });
                // Lê a fatura via Gemini e pré-preenche só os campos ainda
                // vazios — mesmo padrão de finance_entries_screen.dart.
                if (!context.mounted) return;
                final financeRepo = context.read<FinanceRepository>();
                try {
                  final InvoiceExtractionResult resultado = await financeRepo.extractInvoice(bytes);
                  setDialogState(() {
                    if (valorController.text.trim().isEmpty && resultado.valorTotal != null) {
                      valorController.text = resultado.valorTotal!.toStringAsFixed(2);
                    }
                    if (descricaoController.text.trim().isEmpty && resultado.descricao != null) {
                      descricaoController.text = resultado.descricao!;
                    }
                    if (fornecedorNomeController.text.trim().isEmpty && resultado.fornecedorNome != null) {
                      fornecedorNomeController.text = resultado.fornecedorNome!;
                    }
                    if (fornecedorNifController.text.trim().isEmpty && resultado.fornecedorNif != null) {
                      fornecedorNifController.text = resultado.fornecedorNif!;
                    }
                    if (valorIvaController.text.trim().isEmpty && resultado.valorIva != null) {
                      valorIvaController.text = resultado.valorIva!.toStringAsFixed(2);
                    }
                    if (taxaIvaController.text.trim().isEmpty && resultado.taxaIva != null) {
                      taxaIvaController.text = resultado.taxaIva!.toStringAsFixed(0);
                    }
                  });
                } on ApiException {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(context.l10n.financeFaturaNaoLida)));
                  }
                }
              }
            } finally {
              setDialogState(() => carregandoFoto = false);
            }
          }

          return AlertDialog(
            title: Text(tituloDialogo),
            content: SingleChildScrollView(
              child: Form(
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
                      validator: (v) =>
                          double.tryParse((v ?? '').replaceAll(',', '.')) == null ? l10n.validacaoValorInvalido : null,
                    ),
                    TextFormField(
                        controller: descricaoController, decoration: InputDecoration(labelText: l10n.campoDescricao)),
                    TextFormField(
                      controller: fornecedorNomeController,
                      decoration: InputDecoration(labelText: l10n.financeCampoFornecedorNome),
                    ),
                    TextFormField(
                      controller: fornecedorNifController,
                      decoration: InputDecoration(labelText: l10n.financeCampoFornecedorNif),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: valorIvaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.financeCampoValorIva),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: taxaIvaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(labelText: l10n.financeCampoTaxaIva),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: dataController,
                      readOnly: true,
                      decoration: InputDecoration(labelText: l10n.campoData, suffixIcon: const Icon(Icons.event)),
                      onTap: () async {
                        final atual = DateTime.tryParse(dataController.text) ?? DateTime.now();
                        final escolhida = await showDatePicker(
                          context: context,
                          initialDate: atual,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now().add(const Duration(days: 1)),
                        );
                        if (escolhida != null) {
                          dataController.text = escolhida.toIso8601String().substring(0, 10);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      initialValue: metodoPagamento,
                      decoration: InputDecoration(labelText: l10n.financeCampoMetodoPagamento),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.financeSemCategoria)),
                        for (final m in metodosPagamento)
                          DropdownMenuItem(value: m, child: Text(metodoPagamentoLabel(l10n, m))),
                      ],
                      onChanged: (v) => setDialogState(() => metodoPagamento = v),
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: pagoPor,
                      decoration: InputDecoration(labelText: l10n.financeCampoPagoPor),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.financePagoPorEmpresa)),
                        for (final membro in equipa) DropdownMenuItem(value: membro.personId, child: Text(membro.nome)),
                      ],
                      onChanged: (v) => setDialogState(() => pagoPor = v),
                    ),
                    if (pagoPor != null)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: reembolsado,
                        onChanged: (v) => setDialogState(() => reembolsado = v),
                        title: Text(l10n.financeReembolsado),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (novaFotoBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(novaFotoBytes!, width: 48, height: 48, fit: BoxFit.cover),
                          )
                        else if (comprovativoUrlAtual != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: NetworkImageSafe(
                              imageUrl: comprovativoUrlAtual!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (novaFotoBytes != null || comprovativoUrlAtual != null) const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: carregandoFoto ? null : escolherFoto,
                            icon: carregandoFoto
                                ? const SizedBox(
                                    height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.receipt_long_outlined),
                            label: Text(novaFotoBytes != null || comprovativoUrlAtual != null
                                ? l10n.financeComprovativoTrocar
                                : l10n.financeComprovativoCarregar),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
          );
        },
      ),
    );

    if (confirmou != true) return null;
    return _DespesaFormResultado(
      categoria: categoria,
      valor: double.parse(valorController.text.replaceAll(',', '.')),
      descricao: descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim(),
      data: dataController.text.trim().isEmpty ? null : dataController.text.trim(),
      metodoPagamento: metodoPagamento,
      pagoPor: pagoPor,
      reembolsado: reembolsado,
      novaFotoBytes: novaFotoBytes,
      fornecedorNome: fornecedorNomeController.text.trim().isEmpty ? null : fornecedorNomeController.text.trim(),
      fornecedorNif: fornecedorNifController.text.trim().isEmpty ? null : fornecedorNifController.text.trim(),
      valorIva: valorIvaController.text.trim().isEmpty
          ? null
          : double.tryParse(valorIvaController.text.replaceAll(',', '.')),
      taxaIva: taxaIvaController.text.trim().isEmpty
          ? null
          : double.tryParse(taxaIvaController.text.replaceAll(',', '.')),
    );
  }

  Future<void> _adicionarDespesa() async {
    final resultado = await _formularioDespesa(
      tituloDialogo: context.l10n.despesasNovaTitulo,
      dataInicial: DateTime.now().toIso8601String().substring(0, 10),
    );
    if (resultado == null || !mounted) return;
    try {
      final repo = context.read<VehiclesRepository>();
      final criada = await repo.addExpense(
        vehicleId: widget.vehicleId,
        categoria: resultado.categoria,
        valor: resultado.valor,
        descricao: resultado.descricao,
        data: resultado.data,
        metodoPagamento: resultado.metodoPagamento,
        pagoPor: resultado.pagoPor,
        fornecedorNome: resultado.fornecedorNome,
        fornecedorNif: resultado.fornecedorNif,
        valorIva: resultado.valorIva,
        taxaIva: resultado.taxaIva,
      );
      if (resultado.novaFotoBytes != null) {
        await repo.uploadExpenseComprovativo(
          vehicleId: widget.vehicleId,
          expenseId: criada.id,
          foto: resultado.novaFotoBytes!,
        );
      }
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
      dataInicial: despesa.data,
      metodoPagamentoInicial: despesa.metodoPagamento,
      pagoPorInicial: despesa.pagoPor,
      reembolsadoInicial: despesa.reembolsado,
      comprovativoUrlInicial: despesa.comprovativoUrl,
      fornecedorNomeInicial: despesa.fornecedorNome,
      fornecedorNifInicial: despesa.fornecedorNif,
      valorIvaInicial: despesa.valorIva,
      taxaIvaInicial: despesa.taxaIva,
    );
    if (resultado == null || !mounted) return;
    try {
      final repo = context.read<VehiclesRepository>();
      await repo.updateExpense(
        vehicleId: widget.vehicleId,
        expenseId: despesa.id,
        categoria: resultado.categoria,
        valor: resultado.valor,
        descricao: resultado.descricao ?? '',
        data: resultado.data,
        metodoPagamento: resultado.metodoPagamento,
        pagoPor: resultado.pagoPor,
        reembolsado: resultado.reembolsado,
        fornecedorNome: resultado.fornecedorNome,
        fornecedorNif: resultado.fornecedorNif,
        valorIva: resultado.valorIva,
        taxaIva: resultado.taxaIva,
      );
      if (resultado.novaFotoBytes != null) {
        await repo.uploadExpenseComprovativo(
          vehicleId: widget.vehicleId,
          expenseId: despesa.id,
          foto: resultado.novaFotoBytes!,
        );
      }
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
                      leading: despesa.comprovativoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: NetworkImageSafe(
                                imageUrl: despesa.comprovativoUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.receipt_long, color: AppColors.grafiteVendido),
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(categoriaDespesaLabel(l10n, despesa.categoria)),
                          if (despesa.pagoPor != null && !despesa.reembolsado) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.hourglass_bottom, size: 14, color: AppColors.amberSinal),
                          ],
                        ],
                      ),
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
