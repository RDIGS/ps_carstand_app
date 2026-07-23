import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../features/vehicles/vehicle.dart';
import 'status_badge.dart';

/// Elemento assinatura da app (secção 11): cartão "ficha técnica" — faixa
/// lateral fina na cor do estado, matrícula em destaque em fonte mono, e
/// kms/preço alinhados como um mini-conta-quilómetros. Repete-se em toda a
/// app (lista, dashboard, pesquisa).
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final corEstado = AppColors.paraEstado(vehicle.estado);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: corEstado), // faixa lateral do estado
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(vehicle.matricula, style: AppTypography.numero(fontSize: 15)),
                          StatusBadge(estado: vehicle.estado),
                        ],
                      ),
                      const SizedBox(height: 6),
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
                              style: AppTypography.numero(fontSize: 18, color: AppColors.azulMatricula),
                            ),
                        ],
                      ),
                      if (vehicle.diasEmStock != null || (vehicle.checklistTotal ?? 0) > 0) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (vehicle.diasEmStock != null)
                              Text(
                                '${vehicle.diasEmStock} dias em stock',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grafiteVendido),
                              ),
                            if ((vehicle.checklistTotal ?? 0) > 0)
                              _ChecklistProgress(total: vehicle.checklistTotal!, concluidos: vehicle.checklistConcluidos ?? 0),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Percentagem de checklist concluída (secção 25) — só informativo, nunca
/// bloqueia nada. Verde quando completo, cinza neutro no resto (nunca âmbar
/// nem vermelho: não é um aviso, é só progresso).
class _ChecklistProgress extends StatelessWidget {
  const _ChecklistProgress({required this.total, required this.concluidos});

  final int total;
  final int concluidos;

  @override
  Widget build(BuildContext context) {
    final completo = concluidos >= total;
    final cor = completo ? AppColors.verdeDisponivel : AppColors.grafiteVendido;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(completo ? Icons.check_circle : Icons.checklist, size: 15, color: cor),
        const SizedBox(width: 4),
        Text('$concluidos/$total', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cor)),
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
        const Icon(Icons.speed, size: 16, color: AppColors.grafiteVendido),
        const SizedBox(width: 4),
        Text('$formatted km', style: AppTypography.numero(fontSize: 14, color: AppColors.grafiteAsfalto)),
      ],
    );
  }
}
