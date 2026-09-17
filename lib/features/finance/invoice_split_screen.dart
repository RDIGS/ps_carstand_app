import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import '../../shared/widgets/vehicle_picker_field.dart';
import '../vehicles/vehicle.dart';
import '../vehicles/vehicle_expense.dart';
import '../vehicles/vehicle_expenses_card.dart' show categoriaDespesaLabel;
import '../vehicles/vehicles_repository.dart';
import 'finance_categoria.dart';
import 'finance_repository.dart';
import 'invoice_capture.dart';
import 'invoice_extraction_result.dart';

enum _DestinoLinha { geral, veiculo }

class _LinhaDraft {
  _LinhaDraft({required String descricao, required double valor, this.destinoInicial, this.veiculoInicial}) {
    descricaoController.text = descricao;
    valorController.text = valor > 0 ? valor.toStringAsFixed(2) : '';
    destino = destinoInicial ?? _DestinoLinha.geral;
    veiculo = veiculoInicial;
  }

  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final _DestinoLinha? destinoInicial;
  final Vehicle? veiculoInicial;
  late _DestinoLinha destino;
  Vehicle? veiculo;
  String? categoria;
  String? erro;

  double get valor => double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0;

  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
  }
}

/// Ecrã de divisão de 1 fatura em N despesas (secção nova, 2026-09-17,
/// "fatura para várias despesas") — só é aberto quando a IA identificou 2+
/// linhas na fatura (ver `InvoiceExtractionResult.itens`); com 0 ou 1 linha
/// o fluxo de sempre (diálogo único) continua inalterado.
class InvoiceSplitScreen extends StatefulWidget {
  const InvoiceSplitScreen({
    super.key,
    required this.fotoBytes,
    required this.extracao,
    this.veiculoInicial,
  });

  final Uint8List fotoBytes;
  final InvoiceExtractionResult extracao;
  // Quando aberto a partir da ficha de um veículo, todas as linhas arrancam
  // com esse veículo pré-selecionado — conveniência, não uma tentativa da IA
  // (o utilizador continua livre para mudar cada linha).
  final Vehicle? veiculoInicial;

  @override
  State<InvoiceSplitScreen> createState() => _InvoiceSplitScreenState();
}

class _InvoiceSplitScreenState extends State<InvoiceSplitScreen> {
  late final TextEditingController fornecedorNomeController;
  late final TextEditingController fornecedorNifController;
  late final TextEditingController dataController;
  late final TextEditingController valorTotalController;
  late final TextEditingController valorIvaController;
  late final TextEditingController taxaIvaController;
  final List<_LinhaDraft> linhas = [];
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final e = widget.extracao;
    fornecedorNomeController = TextEditingController(text: e.fornecedorNome ?? '');
    fornecedorNifController = TextEditingController(text: e.fornecedorNif ?? '');
    dataController = TextEditingController(text: e.data ?? DateTime.now().toIso8601String().substring(0, 10));
    valorTotalController = TextEditingController(text: e.valorTotal != null ? e.valorTotal!.toStringAsFixed(2) : '');
    valorIvaController = TextEditingController(text: e.valorIva != null ? e.valorIva!.toStringAsFixed(2) : '');
    taxaIvaController = TextEditingController(text: e.taxaIva != null ? e.taxaIva!.toStringAsFixed(2) : '');

    final destinoInicial = widget.veiculoInicial != null ? _DestinoLinha.veiculo : _DestinoLinha.geral;
    for (final item in e.itens) {
      linhas.add(_LinhaDraft(
        descricao: item.descricao,
        valor: item.valor,
        destinoInicial: destinoInicial,
        veiculoInicial: widget.veiculoInicial,
      ));
    }
  }

  @override
  void dispose() {
    fornecedorNomeController.dispose();
    fornecedorNifController.dispose();
    dataController.dispose();
    valorTotalController.dispose();
    valorIvaController.dispose();
    taxaIvaController.dispose();
    for (final l in linhas) {
      l.dispose();
    }
    super.dispose();
  }

  void _adicionarLinha() {
    setState(() {
      linhas.add(_LinhaDraft(
        descricao: '',
        valor: 0,
        destinoInicial: widget.veiculoInicial != null ? _DestinoLinha.veiculo : _DestinoLinha.geral,
        veiculoInicial: widget.veiculoInicial,
      ));
    });
  }

  void _removerLinha(_LinhaDraft linha) {
    setState(() {
      linhas.remove(linha);
      linha.dispose();
    });
  }

  double get _somaLinhas => linhas.fold(0, (soma, l) => soma + l.valor);
  double? get _valorTotal => double.tryParse(valorTotalController.text.replaceAll(',', '.'));

  bool _validarLinhas() {
    var ok = true;
    for (final l in linhas) {
      if (l.descricaoController.text.trim().isEmpty || l.valor <= 0) {
        ok = false;
      }
      if (l.destino == _DestinoLinha.veiculo && l.veiculo == null) {
        l.erro = context.l10n.faturaVeiculoObrigatorio;
        ok = false;
      } else {
        l.erro = null;
      }
    }
    return ok;
  }

  Future<void> _guardar() async {
    if (linhas.isEmpty) return;
    if (!_validarLinhas()) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.faturaCamposObrigatorios)));
      return;
    }

    setState(() => _guardando = true);
    final financeRepo = context.read<FinanceRepository>();
    final vehiclesRepo = context.read<VehiclesRepository>();
    try {
      final invoice = await financeRepo.createInvoice(
        fornecedorNome: fornecedorNomeController.text.trim().isEmpty ? null : fornecedorNomeController.text.trim(),
        fornecedorNif: fornecedorNifController.text.trim().isEmpty ? null : fornecedorNifController.text.trim(),
        data: dataController.text.trim().isEmpty ? null : dataController.text.trim(),
        valorTotal: _valorTotal ?? _somaLinhas,
        valorIva: double.tryParse(valorIvaController.text.replaceAll(',', '.')),
        taxaIva: double.tryParse(taxaIvaController.text.replaceAll(',', '.')),
      );
      await financeRepo.uploadInvoiceComprovativo(invoice.id, widget.fotoBytes);

      final concluidas = <_LinhaDraft>[];
      for (final l in linhas) {
        try {
          if (l.destino == _DestinoLinha.geral) {
            await financeRepo.createEntry(
              tipo: 'despesa',
              categoria: l.categoria,
              valor: l.valor,
              descricao: l.descricaoController.text.trim(),
              data: dataController.text.trim().isEmpty ? null : dataController.text.trim(),
              invoiceId: invoice.id,
            );
          } else {
            await vehiclesRepo.addExpense(
              vehicleId: l.veiculo!.id,
              categoria: l.categoria ?? vehicleExpenseCategorias.last,
              valor: l.valor,
              descricao: l.descricaoController.text.trim(),
              data: dataController.text.trim().isEmpty ? null : dataController.text.trim(),
              invoiceId: invoice.id,
            );
          }
          concluidas.add(l);
        } on ApiException catch (e) {
          if (mounted) l.erro = e.localizado(context);
        }
      }

      for (final l in concluidas) {
        linhas.remove(l);
        l.dispose();
      }

      if (!mounted) return;
      if (linhas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.faturaGuardadaComSucesso)));
        Navigator.of(context).pop(true);
      } else {
        setState(() {});
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nifInvalido = fornecedorNifController.text.trim().isNotEmpty && !nifValido(fornecedorNifController.text);
    final somaLinhas = _somaLinhas;
    final valorTotal = _valorTotal;
    final somaNaoBate = valorTotal != null && (somaLinhas - valorTotal).abs() > 0.01;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.faturaDividirTitulo)),
      body: MaxWidthBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(widget.fotoBytes, height: 160, fit: BoxFit.cover, width: double.infinity),
            ),
            const SizedBox(height: 16),
            AvisosExtracaoFatura(avisos: widget.extracao.avisos, nifInvalido: nifInvalido),
            Text(l10n.faturaCabecalhoTitulo, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: fornecedorNomeController, decoration: InputDecoration(labelText: l10n.financeCampoFornecedorNome)),
            const SizedBox(height: 8),
            TextField(controller: fornecedorNifController, decoration: InputDecoration(labelText: l10n.financeCampoFornecedorNif)),
            const SizedBox(height: 8),
            TextField(controller: dataController, decoration: InputDecoration(labelText: l10n.campoData)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: valorTotalController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.campoValor),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: valorIvaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.financeCampoValorIva),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: taxaIvaController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.financeCampoTaxaIva),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < linhas.length; i++) _linhaCard(context, i, linhas[i]),
            OutlinedButton.icon(
              onPressed: _adicionarLinha,
              icon: const Icon(Icons.add),
              label: Text(l10n.faturaAdicionarLinha),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.faturaTotalLinhas, style: Theme.of(context).textTheme.titleSmall),
                Text('${somaLinhas.toStringAsFixed(2)} €', style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            if (somaNaoBate)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.faturaSomaNaoBate,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: linhas.isEmpty || _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(l10n.faturaGuardarDespesas),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linhaCard(BuildContext context, int index, _LinhaDraft linha) {
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.faturaLinhaTitulo(index + 1), style: Theme.of(context).textTheme.titleSmall),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.faturaRemoverLinha,
                  onPressed: () => _removerLinha(linha),
                ),
              ],
            ),
            TextField(controller: linha.descricaoController, decoration: InputDecoration(labelText: l10n.campoDescricao)),
            const SizedBox(height: 8),
            TextField(
              controller: linha.valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: l10n.campoValor),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            SegmentedButton<_DestinoLinha>(
              segments: [
                ButtonSegment(value: _DestinoLinha.geral, label: Text(l10n.faturaDestinoGeral)),
                ButtonSegment(value: _DestinoLinha.veiculo, label: Text(l10n.faturaDestinoVeiculo)),
              ],
              selected: {linha.destino},
              onSelectionChanged: (v) => setState(() {
                linha.destino = v.first;
                linha.categoria = null;
              }),
            ),
            const SizedBox(height: 8),
            if (linha.destino == _DestinoLinha.geral)
              DropdownButtonFormField<String>(
                initialValue: linha.categoria,
                decoration: InputDecoration(labelText: l10n.campoCategoriaFinanceira),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.financeSemCategoria)),
                  for (final c in financeCategorias) DropdownMenuItem(value: c, child: Text(financeCategoriaLabel(l10n, c))),
                ],
                onChanged: (v) => setState(() => linha.categoria = v),
              )
            else ...[
              VehiclePickerField(
                repository: context.read<VehiclesRepository>(),
                label: l10n.campoVeiculo,
                veiculoInicial: linha.veiculo,
                onSelected: (v) => setState(() => linha.veiculo = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: linha.categoria,
                decoration: InputDecoration(labelText: l10n.campoCategoria),
                items: [
                  for (final c in vehicleExpenseCategorias) DropdownMenuItem(value: c, child: Text(categoriaDespesaLabel(l10n, c))),
                ],
                onChanged: (v) => setState(() => linha.categoria = v),
              ),
            ],
            if (linha.erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(linha.erro!, style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}
