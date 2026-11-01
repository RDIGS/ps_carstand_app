import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/euros.dart';
import '../../shared/widgets/network_image_safe.dart';
import '../../shared/widgets/status_badge.dart';
import 'vehicle_detail.dart';
import 'vehicle_photo.dart';
import 'vehicles_repository.dart';

/// Topo da ficha do veículo ("Claro editorial", 2026-11): foto de capa grande
/// e, ao lado (ou por baixo, em ecrãs estreitos), o estado em versaletes, o
/// nome em serifa, a versão e os preços. Compra/despesas/margem só chegam
/// preenchidos para owners (o backend não os envia a vendedores).
class VehicleApresentacao extends StatefulWidget {
  const VehicleApresentacao({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  @override
  State<VehicleApresentacao> createState() => _VehicleApresentacaoState();
}

class _VehicleApresentacaoState extends State<VehicleApresentacao> {
  late Future<List<VehiclePhoto>> _fotos;

  @override
  void initState() {
    super.initState();
    _fotos = context.read<VehiclesRepository>().listPhotos(widget.vehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    final foto = AspectRatio(
      aspectRatio: 3 / 2,
      child: FutureBuilder<List<VehiclePhoto>>(
        future: _fotos,
        builder: (context, snapshot) {
          final fundo = ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.directions_car_outlined,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
          );
          final lista = snapshot.data ?? const <VehiclePhoto>[];
          if (lista.isEmpty) return fundo;
          return ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: NetworkImageSafe(
              imageUrl: lista.first.url,
              fit: BoxFit.cover,
              placeholder: (context, _) => fundo,
              errorWidget: (context, _, __) => fundo,
            ),
          );
        },
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final info = _Info(vehicle: widget.vehicle);
        if (constraints.maxWidth < 820) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [foto, const SizedBox(height: 24), info]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 11, child: foto),
            const SizedBox(width: 40),
            Expanded(flex: 8, child: info),
          ],
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.vehicle});

  final VehicleDetail vehicle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tema = Theme.of(context);
    final tinta = tema.colorScheme.onSurface;
    final suave = tema.colorScheme.onSurfaceVariant;
    final vendido = vehicle.estado == 'vendido';
    final preco = vehicle.precoVendaFinal ?? vehicle.precoVendaRecomendado;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: AppColors.paraEstado(vehicle.estado), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              [rotuloEstado(l10n, vehicle.estado).toUpperCase(), vehicle.matricula].join('  ·  '),
              style: AppTypography.etiqueta(color: suave),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('${vehicle.marca} ${vehicle.modelo}', style: AppTypography.serifa(fontSize: 38, color: tinta)),
        if (vehicle.versao != null) ...[
          const SizedBox(height: 6),
          Text(vehicle.versao!, style: tema.textTheme.bodyLarge?.copyWith(color: suave)),
        ],
        const SizedBox(height: 24),
        Divider(color: tema.dividerColor),
        const SizedBox(height: 18),
        Text(
          (vendido && vehicle.precoVendaFinal != null ? l10n.precoVendaFinal : l10n.precoVendaRecomendado).toUpperCase(),
          style: AppTypography.etiqueta(color: suave),
        ),
        const SizedBox(height: 6),
        Text(preco != null ? euros(preco) : '—', style: AppTypography.serifa(fontSize: 34, color: tinta)),
        if (vehicle.precoCompra != null || vehicle.margemPrevista != null) ...[
          const SizedBox(height: 18),
          if (vehicle.precoCompra != null) _Linha(rotulo: l10n.precoCompra, valor: euros(vehicle.precoCompra!)),
          if ((vehicle.despesasTotal ?? 0) > 0) _Linha(rotulo: l10n.precoDespesas, valor: euros(vehicle.despesasTotal!)),
          if (vehicle.margemPrevista != null && !vendido)
            _Linha(
              rotulo: l10n.painelMargemPrevista,
              valor: euros(vehicle.margemPrevista!, sinal: true),
              cor: vehicle.margemPrevista! < 0 ? AppColors.red : AppColors.teal,
              forte: true,
            ),
        ],
      ],
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({required this.rotulo, required this.valor, this.cor, this.forte = false});

  final String rotulo;
  final String valor;
  final Color? cor;
  final bool forte;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: tema.dividerColor))),
      child: Row(
        children: [
          Expanded(child: Text(rotulo, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant))),
          Text(
            valor,
            style: AppTypography.numero(
              fontSize: 14.5,
              fontWeight: forte ? FontWeight.w800 : FontWeight.w600,
              color: cor ?? tema.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ficha técnica em duas colunas de linhas "rótulo … valor", separadas por
/// linhas finas (uma coluna em ecrãs estreitos).
class VehicleFichaTecnica extends StatelessWidget {
  const VehicleFichaTecnica({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  String _data(String iso) {
    final p = iso.split('T').first.split('-');
    return p.length == 3 ? '${p[2]}/${p[1]}/${p[0]}' : iso;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tema = Theme.of(context);
    final kms = vehicle.kms.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    final linhas = <(String, String)>[
      (l10n.specKms, '$kms km'),
      if (vehicle.dataPrimeiraMatriculaReal != null) (l10n.specPrimeiraMatricula, _data(vehicle.dataPrimeiraMatriculaReal!)),
      if (vehicle.combustivel != null) (l10n.specCombustivel, vehicle.combustivel!),
      if (vehicle.cilindrada != null) (l10n.specCilindrada, '${vehicle.cilindrada} cm³'),
      if (vehicle.potenciaKw != null) (l10n.specPotencia, '${vehicle.potenciaKw} kW'),
      if (vehicle.cor != null) (l10n.specCor, vehicle.cor!),
      if (vehicle.numLugares != null) (l10n.specLugares, '${vehicle.numLugares}'),
      if (vehicle.categoria != null) (l10n.specCategoria, vehicle.categoria!),
      if (vehicle.pesoTara != null) (l10n.specTara, '${vehicle.pesoTara} kg'),
      if (vehicle.pesoBruto != null) (l10n.specPesoBruto, '${vehicle.pesoBruto} kg'),
      if (vehicle.chassis != null) (l10n.specChassis, vehicle.chassis!),
    ];

    Widget linha((String, String) l) => Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: tema.dividerColor))),
          child: Row(
            children: [
              Expanded(child: Text(l.$1, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant))),
              Flexible(
                child: Text(
                  l.$2,
                  textAlign: TextAlign.right,
                  style: AppTypography.numero(fontSize: 14, fontWeight: FontWeight.w600, color: tema.colorScheme.onSurface),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.fichaTecnicaTitulo, style: tema.textTheme.headlineMedium),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 640) return Column(children: [for (final l in linhas) linha(l)]);
            final meio = (linhas.length / 2).ceil();
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Column(children: [for (final l in linhas.take(meio)) linha(l)])),
                const SizedBox(width: 40),
                Expanded(child: Column(children: [for (final l in linhas.skip(meio)) linha(l)])),
              ],
            );
          },
        ),
      ],
    );
  }
}
