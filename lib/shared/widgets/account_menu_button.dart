import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/theme_state.dart';
import '../../features/audit/audit_screen.dart';
import '../../features/auth/auth_state.dart';
import '../../features/suggestions/suggestions_screen.dart';

/// Menu de conta (idioma, tema, auditoria, sugestões, sessão) — extraído do
/// AppBar de Veículos para também ficar acessível a partir do cartão de
/// utilizador da sidebar desktop (mockup "PS CarStand Redesign"). Antes só
/// vivia no separador Veículos, o que o tornava impossível de encontrar a
/// partir de qualquer outro ecrã.
class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final l10n = context.l10n;

    return PopupMenuButton<String>(
      onSelected: (value) => _onSelected(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(enabled: false, child: Text('${auth.userNome ?? ''} · ${auth.userRole ?? ''}')),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(value: 'idioma_pt', checked: auth.userIdioma == 'pt', child: const Text('Português')),
        CheckedPopupMenuItem(value: 'idioma_en', checked: auth.userIdioma == 'en', child: const Text('English')),
        const PopupMenuDivider(),
        CheckedPopupMenuItem(
          value: 'tema_escuro',
          checked: context.watch<ThemeState>().mode == ThemeMode.dark,
          child: Text(l10n.menuModoEscuro),
        ),
        const PopupMenuDivider(),
        // Só owner (secção 4/O15) — auditoria é um assunto administrativo
        // do stand, tal como Equipa/Financeiro.
        if (auth.userRole == 'owner') PopupMenuItem(value: 'auditoria', child: Text(l10n.menuAuditoria)),
        PopupMenuItem(value: 'sugestoes', child: Text(l10n.menuSugestoes)),
        PopupMenuItem(value: 'logout', child: Text(l10n.terminarSessao)),
        PopupMenuItem(value: 'logout_completo', child: Text(l10n.trocarDeStandTitulo)),
      ],
      child: child,
    );
  }

  Future<void> _onSelected(BuildContext context, String value) async {
    final auth = context.read<AuthState>();
    switch (value) {
      case 'logout':
        auth.logout();
      case 'logout_completo':
        await _logoutCompleto(context);
      case 'idioma_pt':
        auth.changeIdioma('pt');
      case 'idioma_en':
        auth.changeIdioma('en');
      case 'tema_escuro':
        context.read<ThemeState>().toggle();
      case 'auditoria':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AuditScreen()));
      case 'sugestoes':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SuggestionsScreen()));
    }
  }

  Future<void> _logoutCompleto(BuildContext context) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.trocarDeStandTitulo),
        content: Text(l10n.trocarDeStandTexto),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.trocarDeStandTitulo)),
        ],
      ),
    );
    if (confirmou == true && context.mounted) await context.read<AuthState>().logoutCompleto();
  }
}
