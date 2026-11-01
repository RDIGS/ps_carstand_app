import 'package:flutter/material.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/euros.dart';
import '../../features/vehicles/vehicle.dart';
import 'network_image_safe.dart';
import 'status_badge.dart';

/// Proporção da foto nos cartões (3:2, como uma fotografia de catálogo).
const kFotoCartaoProporcao = 3 / 2;

/// Altura do bloco de texto por baixo da foto — a grelha soma isto à altura
/// da foto para saber o tamanho de cada cartão.
const kTextoCartaoAltura = 132.0;

/// Cartão de veículo "Claro editorial" (2026-11): a foto manda, sem etiquetas
/// por cima; por baixo, uma linha em versaletes com o estado, o nome do carro
/// em serifa, os dados numa linha discreta e o preço. Sem caixa nem sombra —
/// só a foto e o texto, como num catálogo.
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tema = Theme.of(context);
    final tinta = tema.colorScheme.onSurface;
    final corEstado = AppColors.paraEstado(vehicle.estado);
    final vendido = vehicle.estado == 'vendido';
    // Só chega preenchida para owners; num vendido já não é "prevista".
    final margem = vendido ? null : vehicle.margemPrevista;

    final kms = vehicle.kms.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    final dados = [if (vehicle.ano != null) '${vehicle.ano}', '$kms km', vehicle.matricula].join('  ·  ');

    return Opacity(
      opacity: vendido ? 0.6 : 1,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: kFotoCartaoProporcao, child: _Foto(url: vehicle.fotoCapa)),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: corEstado, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    [
                      rotuloEstado(l10n, vehicle.estado).toUpperCase(),
                      if (vehicle.diasEmStock != null && !vendido) '${vehicle.diasEmStock} DIAS',
                    ].join('  ·  '),
                    style: AppTypography.etiqueta(color: tema.colorScheme.onSurfaceVariant, fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    '${vehicle.marca} ${vehicle.modelo}',
                    style: AppTypography.serifa(fontSize: 21, color: tinta),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  vehicle.precoVendaRecomendado != null ? euros(vehicle.precoVendaRecomendado!) : '—',
                  style: AppTypography.numero(fontSize: 17, fontWeight: FontWeight.w700, color: tinta),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    dados,
                    style: AppTypography.numero(fontSize: 12.5, fontWeight: FontWeight.w500, color: tema.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (margem != null)
                  Text(
                    euros(margem, sinal: true),
                    style: AppTypography.numero(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: margem < 0 ? AppColors.red : AppColors.teal,
                    ),
                  ),
              ],
            ),
            if ((vehicle.checklistTotal ?? 0) > 0) ...[
              const SizedBox(height: 10),
              _ChecklistProgress(total: vehicle.checklistTotal!, concluidos: vehicle.checklistConcluidos ?? 0),
            ],
          ],
        ),
      ),
    );
  }
}

/// Foto de capa; sem foto, um fundo neutro liso com o contorno de um carro —
/// nada de degradês coloridos.
class _Foto extends StatelessWidget {
  const _Foto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(Icons.directions_car_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.35)),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: url == null
          ? placeholder
          : NetworkImageSafe(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, _) => placeholder,
              errorWidget: (context, _, __) => placeholder,
            ),
    );
  }
}

/// Checklist de preparação (secção 25) — só informativo: uma linha fina e a
/// contagem, sem cores de aviso.
class _ChecklistProgress extends StatelessWidget {
  const _ChecklistProgress({required this.total, required this.concluidos});

  final int total;
  final int concluidos;

  @override
  Widget build(BuildContext context) {
    final tinta = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: total == 0 ? 0 : concluidos / total,
            minHeight: 2,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation(concluidos >= total ? AppColors.teal : tinta.withValues(alpha: 0.55)),
          ),
        ),
        const SizedBox(width: 10),
        Text('$concluidos/$total', style: AppTypography.numero(fontSize: 11, fontWeight: FontWeight.w600, color: tinta.withValues(alpha: 0.55))),
      ],
    );
  }
}
