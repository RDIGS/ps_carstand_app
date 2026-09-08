import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_state.dart';
import '../../shared/widgets/account_menu_button.dart';
import '../../shared/widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';
import 'dua_capture_screen.dart';
import 'vehicle.dart';
import 'vehicle_detail_screen.dart';
import 'vehicles_repository.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  // Antes disto a lista chamava .list() sem paginação nenhuma — qualquer
  // stand com mais de 20 veículos (limite por omissão do repositório) nunca
  // conseguia ver os restantes, sem sinal nenhum de que faltava algo. Scroll
  // infinito em vez de um Future único, para carregar a página seguinte
  // perto do fim sem o utilizador ter de fazer nada.
  final _scrollController = ScrollController();
  final List<Vehicle> _vehicles = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore || _loading || _page >= _totalPages) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final resultado = await context.read<VehiclesRepository>().list();
      setState(() {
        _vehicles
          ..clear()
          ..addAll(resultado.data);
        _page = resultado.page;
        _totalPages = resultado.totalPages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final resultado = await context.read<VehiclesRepository>().list(page: _page + 1);
      setState(() {
        _vehicles.addAll(resultado.data);
        _page = resultado.page;
        _totalPages = resultado.totalPages;
        _loadingMore = false;
      });
    } catch (_) {
      // Best-effort: continuar a fazer scroll tenta de novo naturalmente, e
      // puxar para atualizar recomeça do zero — nunca bloqueia a lista já
      // carregada por causa de 1 página falhada.
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() => _load();

  Future<void> _abrirOpcoesAdicionar() async {
    final l10n = context.l10n;
    final opcao = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: Text(l10n.adicionarManualmente),
              onTap: () => Navigator.of(context).pop('manual'),
            ),
            ListTile(
              leading: const Icon(Icons.document_scanner_outlined),
              title: Text(l10n.adicionarPorDua),
              onTap: () => Navigator.of(context).pop('dua'),
            ),
          ],
        ),
      ),
    );
    if (opcao == null || !mounted) return;

    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => opcao == 'manual' ? const AddVehicleScreen() : const DuaCaptureScreen(),
      ),
    );
    if (resultado == true && mounted) _refresh();
  }

  // Breakpoints da secção 20: <600 1 coluna, 600–1024 2 colunas, >1024 3–4 colunas.
  int _colunas(double largura) {
    if (largura < 600) return 1;
    if (largura < 1024) return 2;
    if (largura < 1440) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Secção 19: nome + ícone da app sempre visíveis no cabeçalho.
            Image.asset('assets/images/app_icon.png', width: 28, height: 28),
            const SizedBox(width: 8),
            Text(l10n.appBarStandNome(auth.standNome ?? ''), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: AccountMenuButton(
              child: CircleAvatar(
                backgroundColor: AppColors.teal,
                child: Text(
                  (auth.userNome?.isNotEmpty ?? false) ? auth.userNome![0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Builder(
          builder: (context) {
            if (_loading) {
              return _LoadingSkeleton(colunas: _colunas(MediaQuery.of(context).size.width));
            }
            if (_error != null) {
              return _ErrorState(message: _error.toString(), onRetry: _refresh);
            }
            if (_vehicles.isEmpty) {
              return _EmptyState(onAdd: _abrirOpcoesAdicionar);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final colunas = _colunas(constraints.maxWidth);
                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _vehicles.length + (_loadingMore ? 1 : 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: colunas,
                    mainAxisExtent: 320, // cartão vertical (foto + ficha técnica) do redesign
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= _vehicles.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final vehicle = _vehicles[index];
                    return VehicleCard(
                      vehicle: vehicle,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicleId: vehicle.id)),
                        );
                        if (context.mounted) _refresh();
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'vehicles-fab',
        onPressed: _abrirOpcoesAdicionar,
        icon: const Icon(Icons.add),
        label: Text(l10n.adicionarVeiculo),
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.colunas});

  final int colunas;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: colunas,
        mainAxisExtent: 320,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// Vazio é convite, não pedido de desculpa (secção 20).
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.directions_car_outlined, size: 56, color: AppColors.inkMuted),
            const SizedBox(height: 16),
            Text(l10n.vehiclesEmptyTitulo, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.vehiclesEmptySubtitulo),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAdd, child: Text(l10n.vehiclesEmptyBotao)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.orange),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(context.l10n.tentarNovamente)),
          ],
        ),
      ),
    );
  }
}
