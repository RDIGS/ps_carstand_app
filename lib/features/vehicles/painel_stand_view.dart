import 'package:flutter/material.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/euros.dart';
import '../finance/painel_stand.dart';

/// Os 4 números que um dono de stand quer ver ao abrir a app (só owner):
/// quanto tem em stock, quanto dinheiro lá está empatado, quanto conta ganhar
/// com ele e como vai o mês. 2×2 no telemóvel, 4 numa linha a partir de 600 px.
class PainelStandView extends StatelessWidget {
  const PainelStandView({super.key, required this.painel});

  final PainelStand painel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cartoes = [
      _Indicador(
        icone: Icons.directions_car_outlined,
        cor: AppColors.teal,
        fundo: AppColors.teal100,
        titulo: l10n.painelEmStock,
        valor: '${painel.emStock}',
        nota: l10n.painelEmStockDesc,
      ),
      _Indicador(
        icone: Icons.account_balance_wallet_outlined,
        cor: AppColors.orangeInk,
        fundo: AppColors.orange100,
        titulo: l10n.painelInvestido,
        valor: euros(painel.investido),
        nota: l10n.painelInvestidoDesc,
      ),
      _Indicador(
        icone: Icons.trending_up,
        cor: painel.margemPrevista < 0 ? AppColors.red : AppColors.teal,
        fundo: painel.margemPrevista < 0 ? AppColors.red100 : AppColors.teal100,
        titulo: l10n.painelMargemPrevista,
        valor: euros(painel.margemPrevista, sinal: true),
        corValor: painel.margemPrevista < 0 ? AppColors.red : AppColors.teal,
        nota: painel.semPreco > 0 ? l10n.painelSemPreco(painel.semPreco) : l10n.painelTudoComPreco,
      ),
      _Indicador(
        icone: Icons.calendar_month_outlined,
        cor: AppColors.lilacInk,
        fundo: AppColors.lilac100,
        titulo: l10n.painelLucroMes,
        valor: euros(painel.lucroMes, sinal: true),
        corValor: painel.lucroMes < 0 ? AppColors.red : null,
        nota: l10n.painelVendasMes(painel.vendasMes),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final porLinha = constraints.maxWidth < 600 ? 2 : 4;
        const espaco = 12.0;
        final largura = (constraints.maxWidth - espaco * (porLinha - 1)) / porLinha;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [for (final c in cartoes) SizedBox(width: largura, child: c)],
        );
      },
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icone,
    required this.cor,
    required this.fundo,
    required this.titulo,
    required this.valor,
    this.corValor,
    this.nota,
  });

  final IconData icone;
  final Color cor;
  final Color fundo;
  final String titulo;
  final String valor;
  final Color? corValor;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icone, size: 18, color: cor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    titulo,
                    style: tema.textTheme.bodyMedium?.copyWith(color: AppColors.inkMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                valor,
                style: AppTypography.numero(fontSize: 22, color: corValor ?? tema.colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              nota ?? '',
              style: const TextStyle(fontSize: 12, color: AppColors.inkFaint),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
