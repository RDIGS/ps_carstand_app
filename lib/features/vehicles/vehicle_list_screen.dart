import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../auth/auth_state.dart';
import '../../shared/widgets/account_menu_button.dart';
import '../../shared/widgets/vehicle_card.dart';
import '../finance/finance_repository.dart';
import '../finance/painel_stand.dart';
import 'painel_stand_view.dart';
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
  // Só para owner; se falhar a lista aparece na mesma, só sem o painel.
  PainelStand? _painel;

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
      if (!mounted) return;
      _carregarPainel();
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

  Future<void> _carregarPainel() async {
    if (context.read<AuthState>().userRole != 'owner') return;
    try {
      final painel = await context.read<FinanceRepository>().painel();
      if (mounted) setState(() => _painel = painel);
    } catch (_) {
      // Best-effort — ver comentário em _painel.
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

  // Breakpoints da secção 20, mais largos no "Claro editorial": fotos
  // grandes pedem menos colunas (3 num ecrã normal de computador).
  int _colunas(double largura) {
    if (largura < 600) return 1;
    if (largura < 1000) return 2;
    if (largura < 1700) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final l10n = context.l10n;
    final largura = MediaQuery.of(context).size.width;
    // Acima de 1024 há a barra lateral (HomeShell) — o botão de adicionar vai
    // para o cabeçalho e não há botão flutuante.
    final computador = largura >= 1024;
    final margem = computador ? 40.0 : 20.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Cabecalho(
              margem: margem,
              standNome: auth.standNome ?? '',
              titulo: l10n.navVeiculos,
              acao: computador
                  ? FilledButton.icon(
                      onPressed: _abrirOpcoesAdicionar,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(l10n.adicionarVeiculo),
                    )
                  : AccountMenuButton(
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(context).colorScheme.onSurface,
                        child: Text(
                          (auth.userNome?.isNotEmpty ?? false) ? auth.userNome![0].toUpperCase() : '?',
                          style: TextStyle(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: Builder(
                  builder: (context) {
                    if (_loading) return _LoadingSkeleton(colunas: _colunas(largura), margem: margem);
                    if (_error != null) return _ErrorState(message: _error.toString(), onRetry: _refresh);
                    if (_vehicles.isEmpty) return _EmptyState(onAdd: _abrirOpcoesAdicionar);

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final colunas = _colunas(constraints.maxWidth);
                        return CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            if (_painel != null)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(margem, 8, margem, 8),
                                sliver: SliverToBoxAdapter(child: PainelStandView(painel: _painel!)),
                              ),
                            SliverPadding(
                              // Fundo extra para o último cartão não ficar atrás do botão flutuante.
                              padding: EdgeInsets.fromLTRB(margem, 28, margem, computador ? 48 : 96),
                              sliver: SliverGrid.builder(
                                itemCount: _vehicles.length + (_loadingMore ? 1 : 0),
                                gridDelegate: _grelha(constraints.maxWidth, colunas, margem),
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
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: computador
          ? null
          : FloatingActionButton.extended(
              heroTag: 'vehicles-fab',
              onPressed: _abrirOpcoesAdicionar,
              icon: const Icon(Icons.add),
              label: Text(l10n.adicionarVeiculo),
            ),
    );
  }
}

const _espacoColunas = 28.0;
const _espacoLinhas = 40.0;

/// Altura de cada cartão = foto 3:2 da largura da coluna + bloco de texto.
SliverGridDelegate _grelha(double larguraTotal, int colunas, double margem) {
  final largura = (larguraTotal - margem * 2 - _espacoColunas * (colunas - 1)) / colunas;
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: colunas,
    mainAxisExtent: largura / kFotoCartaoProporcao + kTextoCartaoAltura,
    crossAxisSpacing: _espacoColunas,
    mainAxisSpacing: _espacoLinhas,
  );
}

/// Cabeçalho da página: nome do stand em versaletes por cima do título
/// serifado, ação à direita.
class _Cabecalho extends StatelessWidget {
  const _Cabecalho({required this.margem, required this.standNome, required this.titulo, required this.acao});

  final double margem;
  final String standNome;
  final String titulo;
  final Widget acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(margem, 28, margem, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  standNome.toUpperCase(),
                  style: AppTypography.etiqueta(color: tema.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(titulo, style: tema.textTheme.displayMedium),
              ],
            ),
          ),
          acao,
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton({required this.colunas, required this.margem});

  final int colunas;
  final double margem;

  @override
  Widget build(BuildContext context) {
    final cor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05);
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        padding: EdgeInsets.fromLTRB(margem, 28, margem, 28),
        itemCount: 6,
        gridDelegate: _grelha(constraints.maxWidth, colunas, margem),
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: kFotoCartaoProporcao, child: ColoredBox(color: cor)),
            const SizedBox(height: 16),
            Container(width: 160, height: 14, color: cor),
          ],
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
            Icon(Icons.directions_car_outlined, size: 56, color: AppColors.inkMuted),
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
            Icon(Icons.error_outline, size: 48, color: AppColors.orange),
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
