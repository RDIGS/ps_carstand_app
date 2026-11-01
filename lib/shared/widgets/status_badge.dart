import 'package:flutter/material.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/app_localizations.dart';

String rotuloEstado(AppLocalizations l10n, String estado) {
  switch (estado) {
    case 'disponivel':
      return l10n.statusDisponivel;
    case 'reservado':
      return l10n.statusReservado;
    case 'vendido':
      return l10n.statusVendido;
    case 'pendente_aprovacao':
      return l10n.statusPendenteAprovacao;
    case 'rejeitado':
      return l10n.statusRejeitado;
    default:
      return estado;
  }
}

/// Etiqueta de estado: ponto na cor do estado + texto em versaletes (mesmo
/// estilo dos cartões de veículo — sem pílula colorida).
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final cor = AppColors.paraEstado(estado);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text(
          rotuloEstado(context.l10n, estado).toUpperCase(),
          style: AppTypography.etiqueta(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10.5),
        ),
      ],
    );
  }
}
