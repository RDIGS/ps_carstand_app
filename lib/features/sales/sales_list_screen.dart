import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
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

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthState>().userRole == 'owner';
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(isOwner ? l10n.vendasTitulo : l10n.minhasVendasTitulo)),
      body: RefreshIndicator(
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
                return Card(
                  child: ListTile(
                    leading: Icon(
                      revertida ? Icons.undo : Icons.receipt_long,
                      color: revertida ? AppColors.grafiteVendido : AppColors.verdeDisponivel,
                    ),
                    title: Text(venda.compradorNome),
                    subtitle: Text(venda.dataVenda.split('T').first),
                    trailing: Text(
                      '${venda.precoFinal.toStringAsFixed(0)} €',
                      style: AppTypography.numero(
                        fontSize: 16,
                        color: revertida ? AppColors.grafiteVendido : AppColors.grafiteAsfalto,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
