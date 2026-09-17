import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/detalhe_linha.dart';
import '../../shared/widgets/max_width_body.dart';
import '../../shared/widgets/network_image_safe.dart';
import '../team/team_member.dart';
import '../team/team_repository.dart';
import 'finance_categoria.dart';
import 'finance_entry.dart';
import 'finance_repository.dart';
import 'invoice_capture.dart';
import 'invoice_extraction_result.dart';
import 'invoice_split_screen.dart';
import 'metodo_pagamento.dart';

/// Lista de lançamentos financeiros gerais (receitas/despesas da empresa,
/// não de veículo) — antes só existia o formulário de criar, sem forma
/// nenhuma de ver, editar ou apagar o que já tinha sido lançado.
class FinanceEntriesScreen extends StatefulWidget {
  const FinanceEntriesScreen({super.key, this.abrirNovoAoEntrar = false});

  final bool abrirNovoAoEntrar;

  @override
  State<FinanceEntriesScreen> createState() => _FinanceEntriesScreenState();
}

class _FinanceEntriesScreenState extends State<FinanceEntriesScreen> {
  late Future<FinanceEntriesPage> _future;
  String? _tipoFiltro;
  String? _categoriaFiltro;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.abrirNovoAoEntrar) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarNovoLancamento());
    }
  }

  void _load() {
    _future = context.read<FinanceRepository>().entries(tipo: _tipoFiltro, categoria: _categoriaFiltro, page: _page);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  void _mudarPagina(int delta) {
    setState(() {
      _page += delta;
      _load();
    });
  }

  /// Ponto de entrada do FAB — pergunta primeiro a origem (secção despesas,
  /// 2026-09-09) em vez de abrir logo o formulário manual como antes.
  Future<void> _iniciarNovoLancamento() async {
    final origem = await escolherOrigemDespesa(context);
    if (origem == null || !mounted) return;
    if (origem == OrigemDespesa.manual) {
      await _abrirFormulario();
      return;
    }
    final captura = await capturarEExtrairFatura(context, context.read<FinanceRepository>());
    if (captura == null || !mounted) return;
    if (captura.resultado == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.financeFaturaNaoLida)));
      await _abrirFormulario(fotoInicial: captura.bytes, extracaoInicial: captura.resultado);
      return;
    }
    // Fatura com 2+ linhas identificadas (secção nova, 2026-09-17) — divide
    // em várias despesas em vez do diálogo único de sempre.
    if (captura.resultado!.itens.length > 1) {
      final guardou = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => InvoiceSplitScreen(fotoBytes: captura.bytes, extracao: captura.resultado!),
        ),
      );
      if (guardou == true && mounted) setState(_load);
      return;
    }
    await _abrirFormulario(fotoInicial: captura.bytes, extracaoInicial: captura.resultado);
  }

  Future<void> _abrirFormulario({
    FinanceEntry? existente,
    Uint8List? fotoInicial,
    InvoiceExtractionResult? extracaoInicial,
  }) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final valorController =
        TextEditingController(text: existente?.valor.toStringAsFixed(2) ?? extracaoInicial?.valorTotal?.toStringAsFixed(2));
    final descricaoController = TextEditingController(text: existente?.descricao ?? extracaoInicial?.descricao);
    final fornecedorNomeController =
        TextEditingController(text: existente?.fornecedorNome ?? extracaoInicial?.fornecedorNome);
    final fornecedorNifController =
        TextEditingController(text: existente?.fornecedorNif ?? extracaoInicial?.fornecedorNif);
    final valorIvaController =
        TextEditingController(text: existente?.valorIva?.toStringAsFixed(2) ?? extracaoInicial?.valorIva?.toStringAsFixed(2));
    final taxaIvaController =
        TextEditingController(text: existente?.taxaIva?.toStringAsFixed(0) ?? extracaoInicial?.taxaIva?.toStringAsFixed(0));
    String tipo = existente?.tipo ?? 'despesa';
    String? categoria = existente?.categoria;
    String? metodoPagamento = existente?.metodoPagamento;
    String? pagoPor = existente?.pagoPor;
    bool recorrente = existente?.recorrente ?? false;
    bool reembolsado = existente?.reembolsado ?? false;
    bool pago = existente?.pago ?? true;
    final dataVencimentoController = TextEditingController(text: existente?.dataVencimento);
    String? comprovativoUrlAtual = existente?.comprovativoUrl;
    Uint8List? novaFotoBytes = fotoInicial;
    InvoiceExtractionResult? extracaoAtual = extracaoInicial;
    bool carregandoFoto = false;

    List<TeamMember> equipa = [];
    try {
      equipa = await context.read<TeamRepository>().list();
    } catch (_) {
      // Seletor "pago por" é só conveniência — se a lista de equipa falhar,
      // fica só com a opção "A empresa".
    }
    if (!mounted) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Trocar a foto depois de já estar no formulário (ex. o utilizador
          // entrou por "manual" mas decidiu anexar a fatura a meio) — usa a
          // mesma extração partilhada, e atualiza os avisos/confiança.
          Future<void> escolherFoto() async {
            setDialogState(() => carregandoFoto = true);
            try {
              final captura = await capturarEExtrairFatura(context, context.read<FinanceRepository>());
              if (captura == null) return;
              setDialogState(() {
                novaFotoBytes = captura.bytes;
                comprovativoUrlAtual = null;
                extracaoAtual = captura.resultado;
                final resultado = captura.resultado;
                if (resultado == null) return;
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
              if (captura.resultado == null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.financeFaturaNaoLida)));
              }
            } finally {
              setDialogState(() => carregandoFoto = false);
            }
          }

          return AlertDialog(
            title: Text(existente == null ? l10n.novoMovimentoTitulo : l10n.lancamentosEditarTitulo),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvisosExtracaoFatura(
                      avisos: extracaoAtual?.avisos ?? const [],
                      nifInvalido:
                          fornecedorNifController.text.trim().isNotEmpty && !nifValido(fornecedorNifController.text),
                    ),
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
                      decoration: InputDecoration(
                        labelText: l10n.campoValor,
                        helperText: avisoConfiancaBaixa(context, extracaoAtual, 'valor_total'),
                      ),
                      validator: (v) =>
                          double.tryParse((v ?? '').replaceAll(',', '.')) == null ? l10n.validacaoValorInvalido : null,
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: categoria,
                      decoration: InputDecoration(labelText: l10n.campoCategoriaFinanceira),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.financeSemCategoria)),
                        for (final c in financeCategorias)
                          DropdownMenuItem(value: c, child: Text(financeCategoriaLabel(l10n, c))),
                      ],
                      onChanged: (v) => setDialogState(() => categoria = v),
                    ),
                    TextFormField(
                        controller: descricaoController, decoration: InputDecoration(labelText: l10n.campoDescricao)),
                    TextFormField(
                      controller: fornecedorNomeController,
                      decoration: InputDecoration(
                        labelText: l10n.financeCampoFornecedorNome,
                        helperText: avisoConfiancaBaixa(context, extracaoAtual, 'fornecedor_nome'),
                      ),
                    ),
                    TextFormField(
                      controller: fornecedorNifController,
                      onChanged: (_) => setDialogState(() {}),
                      decoration: InputDecoration(
                        labelText: l10n.financeCampoFornecedorNif,
                        helperText: avisoConfiancaBaixa(context, extracaoAtual, 'fornecedor_nif'),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: valorIvaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.financeCampoValorIva,
                              helperText: avisoConfiancaBaixa(context, extracaoAtual, 'valor_iva'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: taxaIvaController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.financeCampoTaxaIva,
                              helperText: avisoConfiancaBaixa(context, extracaoAtual, 'taxa_iva'),
                            ),
                          ),
                        ),
                      ],
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
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: pago,
                      onChanged: (v) => setDialogState(() => pago = v),
                      title: Text(l10n.financeCampoJaPago),
                    ),
                    if (!pago)
                      TextFormField(
                        controller: dataVencimentoController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: l10n.financeCampoDataVencimento,
                          suffixIcon: const Icon(Icons.event),
                        ),
                        validator: (v) => (v ?? '').trim().isEmpty ? l10n.validacaoDataVencimentoObrigatoria : null,
                        onTap: () async {
                          final atual = DateTime.tryParse(dataVencimentoController.text) ?? DateTime.now();
                          final escolhida = await showDatePicker(
                            context: context,
                            initialDate: atual,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (escolhida != null) {
                            dataVencimentoController.text = escolhida.toIso8601String().substring(0, 10);
                          }
                        },
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: recorrente,
                      onChanged: (v) => setDialogState(() => recorrente = v),
                      title: Text(l10n.financeRecorrente),
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

    if (confirmou != true || !mounted) return;
    try {
      final repo = context.read<FinanceRepository>();
      final valor = double.parse(valorController.text.replaceAll(',', '.'));
      final descricao = descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim();
      final fornecedorNome = fornecedorNomeController.text.trim().isEmpty ? null : fornecedorNomeController.text.trim();
      final fornecedorNif = fornecedorNifController.text.trim().isEmpty ? null : fornecedorNifController.text.trim();
      final valorIva = valorIvaController.text.trim().isEmpty
          ? null
          : double.tryParse(valorIvaController.text.replaceAll(',', '.'));
      final taxaIva = taxaIvaController.text.trim().isEmpty
          ? null
          : double.tryParse(taxaIvaController.text.replaceAll(',', '.'));
      final dataVencimento = pago || dataVencimentoController.text.trim().isEmpty
          ? null
          : dataVencimentoController.text.trim();
      String entryId;
      if (existente == null) {
        final criado = await repo.createEntry(
          tipo: tipo,
          categoria: categoria,
          valor: valor,
          descricao: descricao,
          metodoPagamento: metodoPagamento,
          pagoPor: pagoPor,
          recorrente: recorrente,
          fornecedorNome: fornecedorNome,
          fornecedorNif: fornecedorNif,
          valorIva: valorIva,
          taxaIva: taxaIva,
          pago: pago,
          dataVencimento: dataVencimento,
        );
        entryId = criado.id;
      } else {
        entryId = existente.id;
        await repo.updateEntry(
          entryId,
          tipo: tipo,
          categoria: categoria,
          valor: valor,
          descricao: descricao ?? '',
          metodoPagamento: metodoPagamento,
          pagoPor: pagoPor,
          recorrente: recorrente,
          reembolsado: reembolsado,
          fornecedorNome: fornecedorNome,
          fornecedorNif: fornecedorNif,
          valorIva: valorIva,
          taxaIva: taxaIva,
          pago: pago,
          dataVencimento: dataVencimento,
          limparDataVencimento: pago,
        );
      }
      if (novaFotoBytes != null) {
        await repo.uploadComprovativo(entryId, novaFotoBytes!);
      }
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  /// Pedido do utilizador, 2026-09-07: os cartões da lista só mostravam
  /// categoria/data/valor — os campos novos (método, pago por, foto) só
  /// apareciam se abrisses o formulário de edição. Isto mostra tudo de
  /// forma só de leitura, com atalhos para editar/apagar.
  Future<void> _verDetalhes(FinanceEntry entry) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(financeCategoriaLabel(l10n, entry.categoria)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry.comprovativoUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: NetworkImageSafe(
                    imageUrl: entry.comprovativoUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              DetalheLinha(
                label: l10n.campoValor,
                valor: '${entry.tipo == 'receita' ? '+' : '-'}${entry.valor.toStringAsFixed(2)} €',
              ),
              DetalheLinha(label: l10n.campoData, valor: entry.data),
              if (entry.descricao != null) DetalheLinha(label: l10n.campoDescricao, valor: entry.descricao!),
              if (entry.fornecedorNome != null)
                DetalheLinha(label: l10n.financeCampoFornecedorNome, valor: entry.fornecedorNome!),
              if (entry.fornecedorNif != null)
                DetalheLinha(label: l10n.financeCampoFornecedorNif, valor: entry.fornecedorNif!),
              if (entry.valorIva != null)
                DetalheLinha(
                  label: l10n.financeCampoValorIva,
                  valor:
                      '${entry.valorIva!.toStringAsFixed(2)} €${entry.taxaIva != null ? ' (${entry.taxaIva!.toStringAsFixed(0)}%)' : ''}',
                ),
              if (entry.metodoPagamento != null)
                DetalheLinha(
                  label: l10n.financeCampoMetodoPagamento,
                  valor: metodoPagamentoLabel(l10n, entry.metodoPagamento),
                ),
              DetalheLinha(
                label: l10n.financeCampoPagoPor,
                valor: entry.pagoPorNome ?? l10n.financePagoPorEmpresa,
              ),
              if (entry.pagoPor != null)
                DetalheLinha(
                  label: l10n.financeReembolsado,
                  valor: entry.reembolsado ? l10n.sim : l10n.nao,
                ),
              if (entry.recorrente) DetalheLinha(label: l10n.financeRecorrente, valor: l10n.sim),
              if (!entry.pago)
                DetalheLinha(
                  label: l10n.financeCampoJaPago,
                  valor: l10n.financeVenceEm(entry.dataVencimento ?? '?'),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fechar)),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _abrirFormulario(existente: entry);
            },
            child: Text(l10n.editar),
          ),
        ],
      ),
    );
  }

  Future<void> _apagar(FinanceEntry entry) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lancamentosApagarTitulo),
        content: Text(l10n.lancamentosApagarConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await context.read<FinanceRepository>().removeEntry(entry.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.lancamentosTitulo)),
      // Mesmo motivo do finance_screen.dart: sem isto esticava para a
      // largura toda da janela no browser de PC.
      body: MaxWidthBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _tipoFiltro,
                      decoration: InputDecoration(labelText: l10n.campoTipo, isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.filtroTodos)),
                        DropdownMenuItem(value: 'despesa', child: Text(l10n.tipoDespesa)),
                        DropdownMenuItem(value: 'receita', child: Text(l10n.tipoReceita)),
                      ],
                      onChanged: (v) => setState(() {
                        _tipoFiltro = v;
                        _page = 1;
                        _load();
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String?>(
                      initialValue: _categoriaFiltro,
                      decoration: InputDecoration(labelText: l10n.campoCategoriaFinanceira, isDense: true),
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.filtroTodos)),
                        for (final c in financeCategorias)
                          DropdownMenuItem(value: c, child: Text(financeCategoriaLabel(l10n, c))),
                      ],
                      onChanged: (v) => setState(() {
                        _categoriaFiltro = v;
                        _page = 1;
                        _load();
                      }),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<FinanceEntriesPage>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      final erro = snapshot.error;
                      return Center(child: Text(erro is ApiException ? erro.localizado(context) : '$erro'));
                    }
                    final pagina = snapshot.data!;
                    if (pagina.entries.isEmpty) {
                      return ListView(
                        children: [
                          Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.lancamentosVazio))),
                        ],
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        for (final entry in pagina.entries)
                          _EntryTile(
                            entry: entry,
                            onTap: _verDetalhes,
                            onEdit: _abrirFormulario,
                            onDelete: _apagar,
                          ),
                        if (pagina.total > pagina.limit)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: _page > 1 ? () => _mudarPagina(-1) : null,
                                  icon: const Icon(Icons.chevron_left),
                                ),
                                Text('$_page / ${(pagina.total / pagina.limit).ceil()}'),
                                IconButton(
                                  onPressed: pagina.temMaisPaginas ? () => _mudarPagina(1) : null,
                                  icon: const Icon(Icons.chevron_right),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'finance-entries-fab',
        onPressed: _iniciarNovoLancamento,
        icon: const Icon(Icons.add),
        label: Text(l10n.movimento),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onTap, required this.onEdit, required this.onDelete});

  final FinanceEntry entry;
  final void Function(FinanceEntry entry) onTap;
  final void Function({FinanceEntry existente}) onEdit;
  final void Function(FinanceEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final positivo = entry.tipo == 'receita';
    return Card(
      child: ListTile(
        onTap: () => onTap(entry),
        leading: Icon(
          positivo ? Icons.arrow_upward : Icons.arrow_downward,
          color: positivo ? AppColors.teal : AppColors.red,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(financeCategoriaLabel(l10n, entry.categoria)),
            if (entry.pagoPor != null && !entry.reembolsado) ...[
              const SizedBox(width: 8),
              const Icon(Icons.hourglass_bottom, size: 14, color: AppColors.orange),
            ],
            if (entry.recorrente) ...[
              const SizedBox(width: 6),
              const Icon(Icons.repeat, size: 14, color: Colors.grey),
            ],
          ],
        ),
        subtitle: Text('${entry.data}${entry.descricao != null ? ' · ${entry.descricao}' : ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${positivo ? '+' : '-'}${entry.valor.toStringAsFixed(0)} €',
              style: AppTypography.numero(
                fontSize: 15,
                color: positivo ? AppColors.teal : AppColors.red,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'editar') onEdit(existente: entry);
                if (value == 'apagar') onDelete(entry);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'editar', child: Text(l10n.editar)),
                PopupMenuItem(value: 'apagar', child: Text(l10n.remover)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
