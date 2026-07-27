import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_state.dart';
import 'checklist_models.dart';
import 'checklist_repository.dart';

/// Checklist de preparação do veículo (secção 25) — nunca bloqueante, só
/// informativo (a percentagem também aparece no cartão da lista).
class ChecklistCard extends StatefulWidget {
  const ChecklistCard({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<ChecklistCard> createState() => _ChecklistCardState();
}

class _ChecklistCardState extends State<ChecklistCard> {
  late Future<List<VehicleChecklistItem>> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<ChecklistRepository>().listVehicleChecklist(widget.vehicleId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggle(VehicleChecklistItem item) {
    return _runAction(
      () => context
          .read<ChecklistRepository>()
          .setConcluido(vehicleId: widget.vehicleId, itemId: item.id, concluido: !item.concluido),
    );
  }

  Future<void> _removerItem(VehicleChecklistItem item) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.checklistRemoverItemTitulo),
        content: Text(l10n.checklistRemoverItemConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    await _runAction(
      () => context.read<ChecklistRepository>().removeItem(vehicleId: widget.vehicleId, itemId: item.id),
    );
  }

  Future<void> _addItem() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final descricao = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.checklistNovoItemTitulo),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.checklistNovoItemHint),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelar)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.guardar),
          ),
        ],
      ),
    );
    if (descricao == null || descricao.isEmpty || !mounted) return;
    await _runAction(() => context.read<ChecklistRepository>().addItem(vehicleId: widget.vehicleId, descricao: descricao));
  }

  Future<void> _applyTemplate() async {
    final repo = context.read<ChecklistRepository>();
    final isOwner = context.read<AuthState>().userRole == 'owner';
    List<ChecklistTemplate> templates;
    try {
      templates = await repo.listTemplates();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
      return;
    }
    if (!mounted) return;

    final l10n = context.l10n;
    final templateId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l10n.checklistEscolherModeloTitulo, style: Theme.of(context).textTheme.titleLarge),
            ),
            if (templates.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.checklistSemModelos),
              ),
            for (final template in templates)
              ListTile(
                leading: const Icon(Icons.checklist),
                title: Text(template.nome),
                onTap: () => Navigator.of(context).pop(template.id),
              ),
            if (isOwner)
              ListTile(
                leading: const Icon(Icons.add),
                title: Text(l10n.checklistCriarModelo),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _createTemplateThenApply();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (templateId == null || !mounted) return;
    await _runAction(() => repo.applyTemplate(vehicleId: widget.vehicleId, templateId: templateId));
  }

  Future<void> _createTemplateThenApply() async {
    final result = await showDialog<({String nome, List<String> itens})>(
      context: context,
      builder: (context) => const _CreateTemplateDialog(),
    );
    if (result == null || !mounted) return;

    final repo = context.read<ChecklistRepository>();
    await _runAction(() async {
      final created = await repo.createTemplate(nome: result.nome, itens: result.itens);
      await repo.applyTemplate(vehicleId: widget.vehicleId, templateId: created.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<VehicleChecklistItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            final itens = snapshot.data!;
            final concluidos = itens.where((i) => i.concluido).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.checklistTitulo, style: Theme.of(context).textTheme.titleLarge),
                    if (itens.isNotEmpty)
                      Text(
                        '$concluidos/${itens.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: concluidos == itens.length ? AppColors.verdeDisponivel : AppColors.grafiteVendido,
                            ),
                      ),
                  ],
                ),
                if (itens.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.checklistVazio, style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  for (final item in itens)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      value: item.concluido,
                      onChanged: _busy ? null : (_) => _toggle(item),
                      title: Text(
                        item.descricao,
                        style: item.concluido
                            ? const TextStyle(decoration: TextDecoration.lineThrough, color: AppColors.grafiteVendido)
                            : null,
                      ),
                      secondary: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: _busy ? null : () => _removerItem(item),
                      ),
                    ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _applyTemplate,
                      icon: const Icon(Icons.playlist_add_check),
                      label: Text(l10n.checklistAplicarModelo),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _addItem,
                      icon: const Icon(Icons.add),
                      label: Text(l10n.checklistAdicionarItem),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CreateTemplateDialog extends StatefulWidget {
  const _CreateTemplateDialog();

  @override
  State<_CreateTemplateDialog> createState() => _CreateTemplateDialogState();
}

class _CreateTemplateDialogState extends State<_CreateTemplateDialog> {
  final _nomeController = TextEditingController();
  final _itemControllers = <TextEditingController>[TextEditingController()];

  @override
  void dispose() {
    _nomeController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _confirmar() {
    final nome = _nomeController.text.trim();
    final itens = _itemControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (nome.isEmpty || itens.isEmpty) return;
    Navigator.of(context).pop((nome: nome, itens: itens));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.checklistCriarModelo),
      content: StatefulBuilder(
        builder: (context, setDialogState) => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomeController,
                autofocus: true,
                decoration: InputDecoration(labelText: l10n.checklistNomeModelo, hintText: l10n.checklistNomeModeloHint),
              ),
              const SizedBox(height: 12),
              Text(l10n.checklistItensModelo, style: Theme.of(context).textTheme.bodyMedium),
              for (final controller in _itemControllers)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextField(controller: controller, decoration: const InputDecoration(isDense: true)),
                ),
              TextButton.icon(
                onPressed: () => setDialogState(() => _itemControllers.add(TextEditingController())),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.checklistAdicionarItemModelo),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelar)),
        ElevatedButton(onPressed: _confirmar, child: Text(l10n.guardar)),
      ],
    );
  }
}
