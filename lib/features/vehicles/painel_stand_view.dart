import 'package:flutter/material.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/euros.dart';
import '../finance/painel_stand.dart';

/// Os 4 números que um dono de stand quer ver ao abrir a app (só owner):
/// quanto tem em stock, quanto dinheiro lá está empatado, quanto conta ganhar
/// com ele e como vai o mês. Estilo "Claro editorial": texto grande entre
/// linhas finas, sem caixas nem ícones. 2×2 no telemóvel, 4 numa linha a
/// partir de 600 px.
class PainelStandView extends StatelessWidget {
  const PainelStandView({super.key, required this.painel});

  final PainelStand painel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linha = Theme.of(context).dividerColor;
    final indicadores = [
      _Indicador(titulo: l10n.painelEmStock, valor: '${painel.emStock}', nota: l10n.painelEmStockDesc),
      _Indicador(titulo: l10n.painelInvestido, valor: euros(painel.investido), nota: l10n.painelInvestidoDesc),
      _Indicador(
        titulo: l10n.painelMargemPrevista,
        valor: euros(painel.margemPrevista, sinal: true),
        corValor: painel.margemPrevista < 0 ? AppColors.red : AppColors.teal,
        nota: painel.semPreco > 0 ? l10n.painelSemPreco(painel.semPreco) : l10n.painelTudoComPreco,
      ),
      _Indicador(
        titulo: l10n.painelLucroMes,
        valor: euros(painel.lucroMes, sinal: true),
        corValor: painel.lucroMes < 0 ? AppColors.red : null,
        nota: l10n.painelVendasMes(painel.vendasMes),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final porLinha = constraints.maxWidth < 600 ? 2 : 4;
        final linhas = <List<_Indicador>>[
          for (var i = 0; i < indicadores.length; i += porLinha) indicadores.sublist(i, i + porLinha),
        ];
        return Container(
          decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: linha))),
          child: Column(
            children: [
              for (var l = 0; l < linhas.length; l++)
                Container(
                  decoration: BoxDecoration(border: l > 0 ? Border(top: BorderSide(color: linha)) : null),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < linhas[l].length; i++) ...[
                          if (i > 0) VerticalDivider(width: 1, thickness: 1, color: linha),
                          Expanded(child: linhas[l][i]),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({required this.titulo, required this.valor, this.corValor, this.nota});

  final String titulo;
  final String valor;
  final Color? corValor;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo.toUpperCase(), style: AppTypography.etiqueta(color: tema.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(valor, style: AppTypography.serifa(fontSize: 30, color: corValor ?? tema.colorScheme.onSurface)),
          ),
          const SizedBox(height: 4),
          Text(
            nota ?? '',
            style: tema.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
