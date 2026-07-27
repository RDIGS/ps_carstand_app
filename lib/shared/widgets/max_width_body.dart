import 'package:flutter/material.dart';

/// Envolve o corpo de um ecrã para não esticar para a largura toda da
/// janela em browsers de PC largos — em telemóvel/janela estreita
/// comporta-se exatamente como antes (só entra em jogo acima de [maxWidth]).
/// Usar sempre em `Scaffold.body`, nunca à volta do `Scaffold` inteiro
/// (a AppBar/NavigationBar continuam a ocupar a largura toda de propósito).
class MaxWidthBody extends StatelessWidget {
  const MaxWidthBody({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
