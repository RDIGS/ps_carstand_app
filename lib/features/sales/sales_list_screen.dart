import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/detalhe_linha.dart';
import '../../shared/widgets/max_width_body.dart';
import '../auth/auth_state.dart';
import 'sale_row.dart';
import 'sales_repository.dart';

/// V7 / O13: vendedor vê "as minhas vendas", owner vê todas as vendas do stand.
class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  late Future<List<SaleRow>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<SalesRepository>().list();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _abrirDocumento(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Pedido do utilizador, 2026-09-07: a lista só mostrava
  /// comprador/data/preço — o resto (contacto do comprador, veículo,
  /// vendedor, comissão) só existia na BD, sem forma de ver na app.
  Future<void> _verDetalhes(SaleRow venda) async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(venda.compradorNome),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (venda.matricula != null)
                DetalheLinha(
                  label: l10n.campoVeiculo,
                  valor: '${venda.matricula} — ${venda.marca ?? ''} ${venda.modelo ?? ''}'.trim(),
                ),
              DetalheLinha(label: l10n.campoData, valor: venda.dataVenda.split('T').first),
              DetalheLinha(label: l10n.campoPreco, valor: '${venda.precoFinal.toStringAsFixed(2)} €'),
              if (venda.comissaoVendedor != null)
                DetalheLinha(label: l10n.campoComissao, valor: '${venda.comissaoVendedor!.toStringAsFixed(2)} €'),
              if (venda.vendedorNome != null) DetalheLinha(label: l10n.campoVendedor, valor: venda.vendedorNome!),
              DetalheLinha(
                label: l10n.campoEstado,
                valor: venda.estado == 'revertida' ? l10n.vendaEstadoRevertida : l10n.vendaEstadoConcluida,
              ),
              const SizedBox(height: 8),
              Text(l10n.compradorTitulo, style: Theme.of(context).textTheme.titleSmall),
              DetalheLinha(label: l10n.campoNif, valor: venda.compradorNif ?? '-'),
              if (venda.compradorMorada != null) DetalheLinha(label: l10n.campoMorada, valor: venda.compradorMorada!),
              if (venda.compradorCp != null) DetalheLinha(label: l10n.campoCodigoPostal, valor: venda.compradorCp!),
              if (venda.compradorLocalidade != null)
                DetalheLinha(label: l10n.campoLocalidade, valor: venda.compradorLocalidade!),
              if (venda.compradorTelefone != null)
                DetalheLinha(label: l10n.campoTelefone, valor: venda.compradorTelefone!),
              if (venda.compradorEmail != null) DetalheLinha(label: l10n.campoEmail, valor: venda.compradorEmail!),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fechar)),
        ],
      ),
    );
  }

  Future<void> _reverterVenda(SaleRow venda) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reverterVendaTitulo),
        content: Text(l10n.reverterVendaTexto(venda.compradorNome)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.reverterVendaTitulo)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      await context.read<SalesRepository>().revert(venda.id);
      if (mounted) setState(_load);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthState>().userRole == 'owner';
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(isOwner ? l10n.vendasTitulo : l10n.minhasVendasTitulo)),
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<SaleRow>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              final vendas = snapshot.data!;
              if (vendas.isEmpty) {
                return Center(child: Text(l10n.semVendasRegistadas));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vendas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final venda = vendas[index];
                  final revertida = venda.estado == 'revertida';
                  final podeReverter = isOwner && !revertida;
                  final temDocumento = venda.docRegistoCompraUrl != null;
                  final temDuaFinal = venda.docDuaFinalUrl != null;
                  return Card(
                    child: ListTile(
                      onTap: () => _verDetalhes(venda),
                      leading: Icon(
                        revertida ? Icons.undo : Icons.receipt_long,
                        color: revertida ? AppColors.inkMuted : AppColors.teal,
                      ),
                      title: Text(venda.compradorNome),
                      subtitle: Text(
                        venda.matricula != null
                            ? '${venda.dataVenda.split('T').first} · ${venda.matricula}'
                            : venda.dataVenda.split('T').first,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${venda.precoFinal.toStringAsFixed(0)} €',
                            style: AppTypography.numero(
                              fontSize: 16,
                              color: revertida ? AppColors.inkMuted : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (temDocumento || temDuaFinal || podeReverter)
                            PopupMenuButton<String>(
                              onSelected: (opcao) {
                                if (opcao == 'documento') _abrirDocumento(venda.docRegistoCompraUrl!);
                                if (opcao == 'dua_final') _abrirDocumento(venda.docDuaFinalUrl!);
                                if (opcao == 'reverter') _reverterVenda(venda);
                              },
                              itemBuilder: (context) => [
                                if (temDocumento)
                                  PopupMenuItem(
                                    value: 'documento',
                                    child: Text(l10n.verRegistoCompra),
                                  ),
                                if (temDuaFinal)
                                  PopupMenuItem(
                                    value: 'dua_final',
                                    child: Text(l10n.verDuaFinal),
                                  ),
                                if (podeReverter)
                                  PopupMenuItem(
                                    value: 'reverter',
                                    child: Text(l10n.reverterVendaTitulo),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
