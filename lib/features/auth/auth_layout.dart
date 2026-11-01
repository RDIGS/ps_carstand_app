import 'package:flutter/material.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_typography.dart';

/// Moldura dos ecrãs de entrada (código do stand, login): no computador, um
/// painel de marca à esquerda (cores invertidas, frase em serifa) e o
/// formulário à direita; no telemóvel, a marca em cima e o formulário por
/// baixo. É a primeira coisa que um cliente vê — tem de parecer premium.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.kicker, required this.titulo, this.subtitulo, required this.children});

  /// Linha em versaletes por cima do título (ex.: nome do stand).
  final String kicker;
  final String titulo;
  final String? subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.of(context).size.width >= 900;
    final formulario = _Formulario(kicker: kicker, titulo: titulo, subtitulo: subtitulo, children: children);

    if (!largo) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [const _Marca(compacta: true), const SizedBox(height: 48), formulario],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 11, child: _PainelMarca()),
          Expanded(
            flex: 9,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 40),
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 400), child: formulario),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Marca extends StatelessWidget {
  const _Marca({this.compacta = false, this.cor});

  final bool compacta;
  final Color? cor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset('assets/images/app_icon.png', width: compacta ? 26 : 30, height: compacta ? 26 : 30),
        const SizedBox(width: 10),
        Text(
          'PS CarStand',
          style: AppTypography.serifa(fontSize: compacta ? 20 : 22, color: cor ?? Theme.of(context).colorScheme.onSurface),
        ),
      ],
    );
  }
}

/// Painel da esquerda (computador): fundo na cor do texto e texto na cor do
/// fundo — preto e marfim no tema claro, invertido nos escuros.
class _PainelMarca extends StatelessWidget {
  const _PainelMarca();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final esquema = Theme.of(context).colorScheme;
    final fundo = esquema.onSurface;
    final texto = esquema.surface;
    return ColoredBox(
      color: fundo,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(64, 56, 64, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Marca(cor: texto),
            const Spacer(),
            Text(l10n.loginKicker.toUpperCase(), style: AppTypography.etiqueta(color: texto.withValues(alpha: 0.6))),
            const SizedBox(height: 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(l10n.loginSlogan, style: AppTypography.serifa(fontSize: 52, color: texto)),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                l10n.loginSloganSub,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: texto.withValues(alpha: 0.72), height: 1.5),
              ),
            ),
            const Spacer(),
            Container(height: 1, color: texto.withValues(alpha: 0.18)),
            const SizedBox(height: 16),
            Text('© PS CarStand', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: texto.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _Formulario extends StatelessWidget {
  const _Formulario({required this.kicker, required this.titulo, this.subtitulo, required this.children});

  final String kicker;
  final String titulo;
  final String? subtitulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(kicker.toUpperCase(), style: AppTypography.etiqueta(color: tema.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 10),
        Text(titulo, style: tema.textTheme.displayMedium),
        if (subtitulo != null) ...[
          const SizedBox(height: 10),
          Text(subtitulo!, style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant, height: 1.5)),
        ],
        const SizedBox(height: 32),
        ...children,
      ],
    );
  }
}
