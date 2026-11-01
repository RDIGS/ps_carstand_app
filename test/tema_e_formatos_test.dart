import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ps_carstand_app/core/theme/paletas.dart';
import 'package:ps_carstand_app/core/utils/euros.dart';

void main() {
  group('euros', () {
    test('agrupa milhares com espaços e arredonda', () {
      expect(euros(19020), '19 020 €');
      expect(euros(1234567.6), '1 234 568 €');
      expect(euros(0), '0 €');
    });

    test('sinal só quando pedido; negativos com sinal de menos tipográfico', () {
      expect(euros(5970, sinal: true), '+5 970 €');
      expect(euros(-2722.68, sinal: true), '−2 723 €');
      expect(euros(-50), '−50 €');
      expect(euros(0, sinal: true), '0 €');
    });
  });

  group('temas', () {
    test('código desconhecido ou em falta cai no editorial', () {
      expect(TemaApp.deCodigo(null), TemaApp.editorial);
      expect(TemaApp.deCodigo('inexistente'), TemaApp.editorial);
      expect(TemaApp.deCodigo('luxo'), TemaApp.luxo);
    });

    test('"Escuro luxo" é sempre escuro; os outros seguem o modo', () {
      expect(Paleta.de(TemaApp.luxo, Brightness.light).brightness, Brightness.dark);
      expect(Paleta.de(TemaApp.editorial, Brightness.light).brightness, Brightness.light);
      expect(Paleta.de(TemaApp.editorial, Brightness.dark).brightness, Brightness.dark);
      expect(Paleta.de(TemaApp.minimal, Brightness.dark).brightness, Brightness.dark);
    });

    test('texto contrasta com o fundo em todas as paletas', () {
      for (final p in [
        Paleta.editorialClaro,
        Paleta.editorialEscuro,
        Paleta.luxo,
        Paleta.minimalClaro,
        Paleta.minimalEscuro,
      ]) {
        final contraste = (p.ink.computeLuminance() + 0.05) / (p.surface.computeLuminance() + 0.05);
        final razao = contraste >= 1 ? contraste : 1 / contraste;
        expect(razao, greaterThan(7), reason: 'contraste texto/fundo insuficiente');
      }
    });
  });
}
