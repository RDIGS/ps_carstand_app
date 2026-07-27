import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/max_width_body.dart';
import 'finance_categoria.dart';
import 'finance_entry.dart';
import 'finance_repository.dart';

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
      WidgetsBinding.instance.addPostFrameCallback((_) => _abrirFormulario());
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

  Future<void> _abrirFormulario({FinanceEntry? existente}) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final valorController = TextEditingController(text: existente?.valor.toStringAsFixed(2));
    final descricaoController = TextEditingController(text: existente?.descricao);
    String tipo = existente?.tipo ?? 'despesa';
    String? categoria = existente?.categoria;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existente == null ? l10n.novoMovimentoTitulo : l10n.lancamentosEditarTitulo),
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
      final repo = context.read<FinanceRepository>();
      final valor = double.parse(valorController.text.replaceAll(',', '.'));
      final descricao = descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim();
      if (existente == null) {
        await repo.createEntry(tipo: tipo, categoria: categoria, valor: valor, descricao: descricao);
      } else {
        await repo.updateEntry(existente.id,
            tipo: tipo, categoria: categoria ?? '', valor: valor, descricao: descricao ?? '');
      }
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
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
                          _EntryTile(entry: entry, onEdit: _abrirFormulario, onDelete: _apagar),
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
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: Text(l10n.movimento),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, required this.onEdit, required this.onDelete});

  final FinanceEntry entry;
  final void Function({FinanceEntry existente}) onEdit;
  final void Function(FinanceEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final positivo = entry.tipo == 'receita';
    return Card(
      child: ListTile(
        leading: Icon(
          positivo ? Icons.arrow_upward : Icons.arrow_downward,
          color: positivo ? AppColors.verdeDisponivel : AppColors.amberSinal,
        ),
        title: Text(financeCategoriaLabel(l10n, entry.categoria)),
        subtitle: Text('${entry.data}${entry.descricao != null ? ' · ${entry.descricao}' : ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${positivo ? '+' : '-'}${entry.valor.toStringAsFixed(0)} €',
              style: AppTypography.numero(
                fontSize: 15,
                color: positivo ? AppColors.verdeDisponivel : AppColors.amberSinal,
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
