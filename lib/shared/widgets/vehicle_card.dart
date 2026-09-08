import 'package:flutter/material.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/vehicles/vehicle.dart';
import 'network_image_safe.dart';
import 'status_badge.dart';

/// Elemento assinatura da app (mockup "PS CarStand Redesign"): cartão
/// "ficha técnica" vertical — foto no topo com o pill de estado sobreposto
/// (em vez da faixa lateral colorida da versão anterior), matrícula em
/// destaque em fonte mono e kms/preço alinhados como um mini-conta-quilómetros.
/// Repete-se em toda a app (lista, dashboard, pesquisa).
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final corEstado = AppColors.paraEstado(vehicle.estado);
    final vendido = vehicle.estado == 'vendido';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: vendido ? 0.72 : 1,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Photo(url: vehicle.fotoCapa, corEstado: corEstado, estado: vehicle.estado),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MatriculaChip(matricula: vehicle.matricula),
                        if (vehicle.diasEmStock != null) _DiasEmStock(dias: vehicle.diasEmStock!),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${vehicle.marca} ${vehicle.modelo}',
                      style: Theme.of(context).textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _KmsReading(kms: vehicle.kms),
                        if (vehicle.precoVendaRecomendado != null)
                          Text(
                            '${vehicle.precoVendaRecomendado!.toStringAsFixed(0)} €',
                            style: AppTypography.numero(fontSize: 18, color: AppColors.teal),
                          ),
                      ],
                    ),
                    if ((vehicle.checklistTotal ?? 0) > 0) ...[
                      const SizedBox(height: 10),
                      _ChecklistProgress(
                        total: vehicle.checklistTotal!,
                        concluidos: vehicle.checklistConcluidos ?? 0,
                        corEstado: corEstado,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fundo em degradê tingido pela cor do estado (mockup "PS CarStand
/// Redesign") — nunca uma faixa colorida sólida, é só um tom de fundo atrás
/// do ícone/foto do veículo.
class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.corEstado, required this.estado});

  final String? url;
  final Color corEstado;
  final String estado;

  @override
  Widget build(BuildContext context) {
    const altura = 150.0;
    return SizedBox(
      height: altura,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null)
            NetworkImageSafe(
              imageUrl: url!,
              fit: BoxFit.cover,
              placeholder: (context, _) => _placeholder(context),
              errorWidget: (context, _, __) => _placeholder(context),
            )
          else
            _placeholder(context),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: corEstado, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(
                    rotuloEstado(context.l10n, estado),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: corEstado),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [corEstado.withValues(alpha: 0.22), Theme.of(context).colorScheme.surfaceContainerHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.directions_car_outlined, size: 52, color: corEstado.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _MatriculaChip extends StatelessWidget {
  const _MatriculaChip({required this.matricula});

  final String matricula;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(6)),
      child: Text(matricula, style: AppTypography.numero(fontSize: 13, color: AppColors.ink)),
    );
  }
}

class _DiasEmStock extends StatelessWidget {
  const _DiasEmStock({required this.dias});

  final int dias;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 14, color: AppColors.inkFaint),
        const SizedBox(width: 4),
        Text('$dias dias', style: const TextStyle(fontSize: 12, color: AppColors.inkFaint)),
      ],
    );
  }
}

/// Percentagem de checklist concluída (secção 25) — só informativo, nunca
/// bloqueia nada. Cor do estado quando completo, cinza neutro no resto
/// (nunca âmbar nem vermelho: não é um aviso, é só progresso).
class _ChecklistProgress extends StatelessWidget {
  const _ChecklistProgress({required this.total, required this.concluidos, required this.corEstado});

  final int total;
  final int concluidos;
  final Color corEstado;

  @override
  Widget build(BuildContext context) {
    final completo = concluidos >= total;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : concluidos / total,
              minHeight: 5,
              backgroundColor: AppColors.gray100,
              valueColor: AlwaysStoppedAnimation(completo ? AppColors.teal : corEstado),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$concluidos/$total', style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint)),
      ],
    );
  }
}

class _KmsReading extends StatelessWidget {
  const _KmsReading({required this.kms});

  final int kms;

  @override
  Widget build(BuildContext context) {
    final formatted = kms.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.speed, size: 16, color: AppColors.inkMuted),
        const SizedBox(width: 4),
        Text('$formatted km', style: AppTypography.numero(fontSize: 13, color: AppColors.inkMuted)),
      ],
    );
  }
}
