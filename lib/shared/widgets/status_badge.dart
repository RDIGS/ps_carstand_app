import 'package:flutter/material.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
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

/// Etiqueta de estado inspirada nos indicadores do tablier (secção 11):
/// verde/âmbar/cinza, nunca vermelho-choque.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.estado});

  final String estado;

  @override
  Widget build(BuildContext context) {
    final cor = AppColors.paraEstado(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: cor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(
            rotuloEstado(context.l10n, estado),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
