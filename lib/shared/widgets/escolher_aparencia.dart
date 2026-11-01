import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/paletas.dart';
import '../../core/theme/theme_state.dart';
import '../../features/auth/auth_state.dart';
import '../../l10n/app_localizations.dart';

/// Diálogo "Aparência" (menu da conta): cada pessoa escolhe o seu tema — fica
/// na conta (como o idioma), por isso segue-a em qualquer dispositivo — e o
/// modo claro/escuro deste dispositivo.
Future<void> mostrarEscolherAparencia(BuildContext context) {
  return showDialog<void>(context: context, builder: (_) => const _EscolherAparencia());
}

class _EscolherAparencia extends StatelessWidget {
  const _EscolherAparencia();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeState = context.watch<ThemeState>();

    Future<void> escolher(TemaApp t) async {
      await themeState.definirTema(t);
      if (context.mounted) await context.read<AuthState>().changeTema(t.name);
    }

    return AlertDialog(
      title: Text(l10n.aparenciaTitulo),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.aparenciaAjuda, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, c) {
                  final largura = c.maxWidth < 520 ? c.maxWidth : (c.maxWidth - 24) / 3;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final t in TemaApp.values)
                        SizedBox(
                          width: largura,
                          child: AmostraTema(tema: t, escolhido: themeState.tema == t, onTap: () => escolher(t)),
                        ),
                    ],
                  );
                },
              ),
              if (!themeState.tema.soEscuro) ...[
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.menuModoEscuro),
                  value: themeState.mode == ThemeMode.dark,
                  onChanged: (_) => themeState.toggle(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fechar))],
    );
  }
}

/// Amostra de um tema: o fundo, a letra dos títulos e as cores principais
/// desse tema, com o nome e uma linha a descrevê-lo.
class AmostraTema extends StatelessWidget {
  const AmostraTema({super.key, required this.tema, required this.escolhido, required this.onTap});

  final TemaApp tema;
  final bool escolhido;
  final VoidCallback onTap;

  static (String, String) _textos(AppLocalizations l10n, TemaApp t) => switch (t) {
        TemaApp.editorial => (l10n.temaEditorial, l10n.temaEditorialDesc),
        TemaApp.luxo => (l10n.temaLuxo, l10n.temaLuxoDesc),
        TemaApp.minimal => (l10n.temaMinimal, l10n.temaMinimalDesc),
      };

  @override
  Widget build(BuildContext context) {
    final p = Paleta.de(tema, tema.soEscuro ? Brightness.dark : Brightness.light);
    final (nome, descricao) = _textos(context.l10n, tema);
    final linhaAtual = Theme.of(context).colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: escolhido ? linhaAtual : Theme.of(context).dividerColor, width: escolhido ? 2 : 1),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 96,
              color: p.surface,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aa', style: AppTypography.amostraTitulo(tema, fontSize: 30, color: p.ink)),
                  const Spacer(),
                  Row(
                    children: [
                      for (final c in [p.ink, p.teal, p.orange, p.border])
                        Container(
                          width: 14,
                          height: 14,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: p.border)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(nome, style: Theme.of(context).textTheme.titleMedium)),
                      if (escolhido) Icon(Icons.check, size: 18, color: linhaAtual),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(descricao, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
