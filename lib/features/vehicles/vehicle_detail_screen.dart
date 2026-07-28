import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/widgets/max_width_body.dart';
import '../../shared/widgets/status_badge.dart';
import '../auth/auth_state.dart';
import '../banner/banner_template_picker_screen.dart';
import '../checklist/vehicle_checklist_card.dart';
import '../sales/sale_screen.dart';
import 'edit_vehicle_screen.dart';
import 'market_estimate.dart';
import 'vehicle_detail.dart';
import 'vehicle_expenses_card.dart';
import 'vehicle_photo_gallery_card.dart';
import 'vehicles_repository.dart';

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Future<VehicleDetail> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<VehiclesRepository>().getById(widget.vehicleId);
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

  Future<void> _eliminarVeiculo(VehicleDetail vehicle) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eliminarVeiculoTitulo),
        content: Text(l10n.eliminarVeiculoTexto(vehicle.matricula)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.eliminarVeiculoTitulo)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await context.read<VehiclesRepository>().remove(vehicle.id);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthState>().userRole;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.fichaVeiculoTitulo),
        actions: [
          FutureBuilder<VehicleDetail>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final vehicle = snapshot.data!;
              return IconButton(
                tooltip: context.l10n.editar,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final editado = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => EditVehicleScreen(vehicle: vehicle)),
                  );
                  if (editado == true) await _refresh();
                },
              );
            },
          ),
        ],
      ),
      body: MaxWidthBody(
        child: FutureBuilder<VehicleDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            final vehicle = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _FichaTecnicaCard(vehicle: vehicle),
                  const SizedBox(height: 16),
                  VehiclePhotoGalleryCard(vehicleId: vehicle.id),
                  const SizedBox(height: 16),
                  _PrecosCard(vehicle: vehicle),
                  const SizedBox(height: 16),
                  if (vehicle.importado) _ImportadoCard(vehicle: vehicle),
                  if (vehicle.importado) const SizedBox(height: 16),
                  _ActionsCard(
                    vehicle: vehicle,
                    busy: _busy,
                    onAction: _runAction,
                    onRefresh: _refresh,
                    onDelete: () => _eliminarVeiculo(vehicle),
                  ),
                  const SizedBox(height: 16),
                  if (vehicle.estado == 'disponivel' || vehicle.estado == 'reservado') ...[
                    _GerarBannerButton(vehicle: vehicle),
                    const SizedBox(height: 16),
                  ],
                  ChecklistCard(vehicleId: vehicle.id),
                  const SizedBox(height: 16),
                  if (role == 'owner') ...[
                    VehicleExpensesCard(vehicleId: vehicle.id),
                    const SizedBox(height: 16),
                  ],
                  _MarketEstimateCard(vehicle: vehicle, onRefresh: _refresh),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FichaTecnicaCard extends StatelessWidget {
  const _FichaTecnicaCard({required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final corEstado = AppColors.paraEstado(vehicle.estado);
    return Card(
      clipBehavior: Clip.antiAlias,
      // IntrinsicHeight é necessário porque o Row usa stretch dentro de um
      // ListView (altura não limitada) — sem isto o layout falha em
      // silêncio numa build de release e o cartão nunca chega a aparecer.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: corEstado),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vehicle.matricula,
                          style: AppTypography.numero(fontSize: 20, color: Theme.of(context).colorScheme.onSurface),
                        ),
                        StatusBadge(estado: vehicle.estado),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${vehicle.marca} ${vehicle.modelo}', style: Theme.of(context).textTheme.headlineLarge),
                    if (vehicle.versao != null) Text(vehicle.versao!, style: Theme.of(context).textTheme.bodyMedium),
                    const Divider(height: 28),
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        _Spec(label: l10n.specKms, value: '${vehicle.kms} km', mono: true),
                        if (vehicle.dataPrimeiraMatriculaReal != null)
                          _Spec(
                              label: l10n.specPrimeiraMatricula, value: vehicle.dataPrimeiraMatriculaReal!, mono: true),
                        if (vehicle.categoria != null) _Spec(label: l10n.specCategoria, value: vehicle.categoria!),
                        if (vehicle.combustivel != null)
                          _Spec(label: l10n.specCombustivel, value: vehicle.combustivel!),
                        if (vehicle.cilindrada != null)
                          _Spec(label: l10n.specCilindrada, value: '${vehicle.cilindrada} cm³'),
                        if (vehicle.potenciaKw != null)
                          _Spec(label: l10n.specPotencia, value: '${vehicle.potenciaKw} kW'),
                        if (vehicle.cor != null) _Spec(label: l10n.specCor, value: vehicle.cor!),
                        if (vehicle.numLugares != null) _Spec(label: l10n.specLugares, value: '${vehicle.numLugares}'),
                        if (vehicle.pesoTara != null) _Spec(label: l10n.specTara, value: '${vehicle.pesoTara} kg'),
                        if (vehicle.pesoBruto != null)
                          _Spec(label: l10n.specPesoBruto, value: '${vehicle.pesoBruto} kg'),
                      ],
                    ),
                    if (vehicle.chassis != null) ...[
                      const SizedBox(height: 12),
                      Text(l10n.specChassis, style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        vehicle.chassis!,
                        style: AppTypography.numero(fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({required this.label, required this.value, this.mono = false});

  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grafiteVendido)),
        Text(
          value,
          style: mono
              ? AppTypography.numero(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)
              : Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _PrecosCard extends StatelessWidget {
  const _PrecosCard({required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthState>().userRole;
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (role == 'owner' && vehicle.precoCompra != null)
              _PrecoColuna(label: l10n.precoCompra, valor: vehicle.precoCompra!),
            if (vehicle.precoVendaRecomendado != null)
              _PrecoColuna(label: l10n.precoVendaRecomendado, valor: vehicle.precoVendaRecomendado!, destaque: true),
            if (vehicle.precoVendaFinal != null)
              _PrecoColuna(label: l10n.precoVendaFinal, valor: vehicle.precoVendaFinal!),
          ],
        ),
      ),
    );
  }
}

class _PrecoColuna extends StatelessWidget {
  const _PrecoColuna({required this.label, required this.valor, this.destaque = false});

  final String label;
  final double valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          '${valor.toStringAsFixed(0)} €',
          style: AppTypography.numero(
            fontSize: destaque ? 22 : 18,
            color: destaque ? AppColors.azulMatricula : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ImportadoCard extends StatelessWidget {
  const _ImportadoCard({required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      color: AppColors.amberSinal.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.public, color: AppColors.amberSinal),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.veiculoImportado, style: Theme.of(context).textTheme.titleLarge),
                  if (vehicle.matriculaAnterior != null) Text(l10n.matriculaAnteriorLabel(vehicle.matriculaAnterior!)),
                  if (vehicle.paisOrigemAnterior != null) Text(l10n.paisOrigemLabel(vehicle.paisOrigemAnterior!)),
                  if (vehicle.possivelImportado)
                    Text(l10n.confiancaBaixaAviso, style: const TextStyle(color: AppColors.amberSinal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({
    required this.vehicle,
    required this.busy,
    required this.onAction,
    required this.onRefresh,
    required this.onDelete,
  });

  final VehicleDetail vehicle;
  final bool busy;
  final Future<void> Function(Future<void> Function()) onAction;
  final Future<void> Function() onRefresh;
  final VoidCallback onDelete;

  Future<void> _venderEAtualizar(BuildContext context) async {
    final vendido = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SaleScreen(vehicle: vehicle)),
    );
    if (vendido == true) await onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<VehiclesRepository>();
    final role = context.watch<AuthState>().userRole;
    final l10n = context.l10n;
    final buttons = <Widget>[];

    if (vehicle.estado == 'pendente_aprovacao' && role == 'owner') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: busy ? null : () => onAction(() => repo.approve(vehicle.id)),
          icon: const Icon(Icons.check),
          label: Text(l10n.aprovarVeiculo),
        ),
      );
      buttons.add(
        OutlinedButton.icon(
          onPressed: busy ? null : () => onAction(() => repo.reject(vehicle.id)),
          icon: const Icon(Icons.close),
          label: Text(l10n.rejeitar),
        ),
      );
    }

    if (vehicle.estado == 'disponivel') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: busy ? null : () => onAction(() => repo.reserve(vehicle.id, true)),
          icon: const Icon(Icons.event_available),
          label: Text(l10n.reservar),
        ),
      );
      buttons.add(
        ElevatedButton.icon(
          onPressed: busy ? null : () => _venderEAtualizar(context),
          icon: const Icon(Icons.sell),
          label: Text(l10n.vender),
        ),
      );
    }

    if (vehicle.estado == 'reservado') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: busy ? null : () => onAction(() => repo.reserve(vehicle.id, false)),
          icon: const Icon(Icons.event_busy),
          label: Text(l10n.cancelarReserva),
        ),
      );
      buttons.add(
        ElevatedButton.icon(
          onPressed: busy ? null : () => _venderEAtualizar(context),
          icon: const Icon(Icons.sell),
          label: Text(l10n.vender),
        ),
      );
    }

    // Owner only (mesmo padrão de aprovar/rejeitar) — escondido para veículos
    // vendidos porque o backend recusa sempre (histórico de vendas associado).
    if (role == 'owner' && vehicle.estado != 'vendido') {
      buttons.add(
        OutlinedButton.icon(
          onPressed: busy ? null : onDelete,
          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
          label: Text(l10n.eliminarVeiculoTitulo, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          style: OutlinedButton.styleFrom(side: BorderSide(color: Theme.of(context).colorScheme.error)),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 12, runSpacing: 12, children: buttons);
  }
}

class _GerarBannerButton extends StatelessWidget {
  const _GerarBannerButton({required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BannerTemplatePickerScreen(vehicle: vehicle)),
        ),
        icon: const Icon(Icons.campaign_outlined),
        label: Text(context.l10n.bannerGerarBotao),
      ),
    );
  }
}

class _MarketEstimateCard extends StatefulWidget {
  const _MarketEstimateCard({required this.vehicle, required this.onRefresh});

  final VehicleDetail vehicle;
  final Future<void> Function() onRefresh;

  @override
  State<_MarketEstimateCard> createState() => _MarketEstimateCardState();
}

class _MarketEstimateCardState extends State<_MarketEstimateCard> {
  Future<MarketEstimate>? _future;
  bool _janelaAmpliada = false;
  bool _aplicandoPreco = false;

  void _consultar({bool forcarAtualizacao = false}) {
    setState(() {
      _future = context.read<VehiclesRepository>().marketEstimate(
            widget.vehicle.id,
            janelaAmpliada: _janelaAmpliada,
            forcarAtualizacao: forcarAtualizacao,
          );
    });
  }

  Future<void> _usarComoRecomendado(double valor) async {
    setState(() => _aplicandoPreco = true);
    try {
      await context.read<VehiclesRepository>().update(widget.vehicle.id, precoVendaRecomendado: valor);
      await widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.guardado)));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _aplicandoPreco = false);
    }
  }

  Future<void> _abrirAnuncio(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_future == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.trending_up, color: AppColors.azulMatricula),
          title: Text(l10n.estimativaMercadoTitulo),
          subtitle: Text(l10n.estimativaMercadoSubtitulo),
          trailing: TextButton(onPressed: _consultar, child: Text(l10n.consultar)),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<MarketEstimate>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text(l10n.estimativaMercadoErro('${snapshot.error}'));
            }
            final estimate = snapshot.data!;
            if (estimate.numFontes == 0) {
              return Text(l10n.estimativaMercadoSemDados);
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.estimativaMercadoTitulo, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      tooltip: l10n.estimativaMercadoAtualizar,
                      icon: const Icon(Icons.refresh),
                      onPressed: () => _consultar(forcarAtualizacao: true),
                    ),
                  ],
                ),
                Text(
                  l10n.estimativaMercadoIntervalo(
                    estimate.precoMin?.toStringAsFixed(0) ?? '-',
                    estimate.precoMax?.toStringAsFixed(0) ?? '-',
                    estimate.precoMedio?.toStringAsFixed(0) ?? '-',
                  ),
                  style: AppTypography.numero(fontSize: 16, color: AppColors.azulMatricula),
                ),
                Text(l10n.estimativaMercadoFontes(estimate.numFontes), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                // Janela ±1 (padrão) vs ±2 anos — amostra maior quando o
                // owner suspeita de mudança de geração do modelo a enviesar
                // a estimativa (secção 6 do documento de arquitetura).
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: false, label: Text(l10n.estimativaMercadoJanelaNormal)),
                    ButtonSegment(value: true, label: Text(l10n.estimativaMercadoJanelaAmpliada)),
                  ],
                  selected: {_janelaAmpliada},
                  onSelectionChanged: (v) {
                    setState(() => _janelaAmpliada = v.first);
                    _consultar();
                  },
                ),
                const SizedBox(height: 12),
                for (final fonte in estimate.sources)
                  if (fonte.precoMedio != null) _FonteEstimativa(fonte: fonte, onAbrirAnuncio: _abrirAnuncio),
                if (estimate.sources.every((f) => f.amostra.isEmpty))
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: Text(
                      l10n.estimativaMercadoSemAmostra,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grafiteVendido),
                    ),
                  ),
                if (estimate.precoMedio != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _aplicandoPreco ? null : () => _usarComoRecomendado(estimate.precoMedio!),
                      icon: _aplicandoPreco
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline),
                      label: Text(l10n.estimativaMercadoUsarComoRecomendado(estimate.precoMedio!.toStringAsFixed(0))),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FonteEstimativa extends StatelessWidget {
  const _FonteEstimativa({required this.fonte, required this.onAbrirAnuncio});

  final MarketEstimateSource fonte;
  final Future<void> Function(String url) onAbrirAnuncio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (fonte.amostra.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(fonte.fonte),
        trailing: Text(l10n.estimativaMercadoNumAnuncios(fonte.numAnuncios ?? 0)),
      );
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(fonte.fonte),
      subtitle: Text(l10n.estimativaMercadoVerAnuncios(fonte.amostra.length)),
      children: [
        for (final anuncio in fonte.amostra)
          ListTile(
            dense: true,
            leading: anuncio.foto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: anuncio.foto!,
                      width: 48,
                      height: 36,
                      fit: BoxFit.cover,
                      errorWidget: (context, _, __) =>
                          const Icon(Icons.directions_car, color: AppColors.grafiteVendido),
                    ),
                  )
                : const Icon(Icons.directions_car, color: AppColors.grafiteVendido),
            title: Text(anuncio.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text([
              if (anuncio.ano != null) '${anuncio.ano}',
              if (anuncio.kms != null) '${anuncio.kms} km',
            ].join(' · ')),
            trailing: Text(
              '${anuncio.preco.toStringAsFixed(0)} €',
              style: AppTypography.numero(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
            ),
            onTap: () => onAbrirAnuncio(anuncio.url),
          ),
      ],
    );
  }
}
