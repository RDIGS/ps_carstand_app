import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_state.dart';
import '../finance/finance_screen.dart';
import '../leads/leads_list_screen.dart';
import '../sales/sales_list_screen.dart';
import '../team/team_screen.dart';
import '../vehicles/stock_alerts.dart';
import '../vehicles/vehicle_list_screen.dart';
import '../vehicles/vehicles_repository.dart';

/// Navegação principal pós-login. Equipa/Financeiro só aparecem para o
/// owner (secção 4) — o vendedor só vê Veículos e "as minhas vendas".
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  StockAlerts? _stockAlerts;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStockAlerts());
  }

  Future<void> _loadStockAlerts() async {
    try {
      final alerts = await context.read<VehiclesRepository>().getStockAlerts();
      if (mounted) setState(() => _stockAlerts = alerts);
    } catch (_) {
      // Best-effort, mesmo padrão dos outros avisos: nunca bloqueia a app.
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = context.watch<AuthState>().userRole == 'owner';
    final l10n = context.l10n;

    final destinations = <_Destino>[
      _Destino(icon: Icons.directions_car, label: l10n.navVeiculos, screen: const VehicleListScreen()),
      _Destino(icon: Icons.receipt_long, label: l10n.navVendas, screen: const SalesListScreen()),
      _Destino(icon: Icons.person_search, label: l10n.navLeads, screen: const LeadsListScreen()),
      if (isOwner) _Destino(icon: Icons.groups, label: l10n.navEquipa, screen: const TeamScreen()),
      if (isOwner) _Destino(icon: Icons.bar_chart, label: l10n.navFinanceiro, screen: const FinanceScreen()),
    ];

    final index = _index < destinations.length ? _index : 0;
    final auth = context.watch<AuthState>();
    final subscricao = auth.subscriptionStatus;
    final versaoRecomendada = auth.updateRecomendadaVersao;

    return Scaffold(
      body: Column(
        children: [
          // Só o owner — é um assunto financeiro/administrativo do stand,
          // tal como Equipa/Financeiro (o vendedor não precisa de saber).
          if (isOwner && subscricao != null && subscricao.mostrarAviso) _SubscriptionBanner(subscricao: subscricao),
          // Não-bloqueante (secção 22) — qualquer role, não é assunto
          // administrativo como a subscrição.
          if (versaoRecomendada != null)
            _UpdateRecomendadaBanner(versao: versaoRecomendada, changelogUrl: auth.updateRecomendadaChangelogUrl),
          // Operacional, não administrativo — qualquer role vê, ao contrário
          // da subscrição.
          if (_stockAlerts != null && _stockAlerts!.veiculosParados > 0)
            _StockParadoBanner(alerts: _stockAlerts!, onTap: () => setState(() => _index = 0)),
          Expanded(
            child: IndexedStack(
              index: index,
              children: [for (final d in destinations) d.screen],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: AppColors.azulMatricula.withValues(alpha: 0.14),
        destinations: [
          for (final d in destinations) NavigationDestination(icon: Icon(d.icon), label: d.label),
        ],
      ),
    );
  }
}

class _Destino {
  const _Destino({required this.icon, required this.label, required this.screen});

  final IconData icon;
  final String label;
  final Widget screen;
}

/// Aviso persistente de subscrição (secção 3.4, O14): contagem decrescente
/// antes de expirar (aviso prévio) ou período de carência já em curso.
/// Usa âmbar em ambos os casos — nunca vermelho-choque (secção 11).
class _SubscriptionBanner extends StatelessWidget {
  const _SubscriptionBanner({required this.subscricao});

  final SubscriptionStatus subscricao;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final texto = subscricao.tokenEstado == 'em_carencia'
        ? l10n.subscricaoAvisoCarencia(subscricao.diasCarenciaRestantes ?? 0)
        : l10n.subscricaoAvisoExpira(subscricao.diasParaExpirar ?? 0);

    return Container(
      width: double.infinity,
      color: AppColors.amberSinal.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.amberSinal, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(texto, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// Aviso não-bloqueante de atualização recomendada (secção 22) — a
/// diferença face ao ecrã de bloqueio é que aqui a versão instalada ainda
/// passa no mínimo obrigatório, só há uma mais recente disponível.
class _UpdateRecomendadaBanner extends StatelessWidget {
  const _UpdateRecomendadaBanner({required this.versao, this.changelogUrl});

  final String versao;
  final String? changelogUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.amberSinal.withValues(alpha: 0.16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.system_update, color: AppColors.amberSinal, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(l10n.atualizacaoRecomendadaAviso(versao), style: Theme.of(context).textTheme.bodyMedium)),
          if (changelogUrl != null)
            TextButton(
              onPressed: () => launchUrl(Uri.parse(changelogUrl!), mode: LaunchMode.externalApplication),
              child: Text(l10n.atualizacaoRecomendadaBotao),
            ),
        ],
      ),
    );
  }
}

/// Aviso de stock parado (pedido do utilizador, "melhor app do mercado") —
/// não bloqueante, só um sinal de que vale a pena rever preço/promoção.
class _StockParadoBanner extends StatelessWidget {
  const _StockParadoBanner({required this.alerts, required this.onTap});

  final StockAlerts alerts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: AppColors.amberSinal.withValues(alpha: 0.16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.hourglass_bottom, color: AppColors.amberSinal, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.avisoStockParado(alerts.veiculosParados, alerts.limiteDias),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
