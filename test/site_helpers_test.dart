import 'package:flutter_test/flutter_test.dart';
import 'package:ps_carstand_app/features/settings/stand_settings_screen.dart';
import 'package:ps_carstand_app/features/visits/visit_requests_view.dart';

void main() {
  test('sugerirSlug cria um endereço válido a partir do nome do stand', () {
    expect(sugerirSlug('PS CARSTAND'), 'ps-carstand');
    expect(sugerirSlug('Auto Silva, Lda.'), 'auto-silva-lda');
    expect(sugerirSlug('Automóveis Conceição & Filhos'), 'automoveis-conceicao-filhos');
    expect(sugerirSlug('  --Stand--  '), 'stand');
    expect(sugerirSlug('a' * 60).length, 40);
  });

  test('numeroWhatsapp acrescenta 351 a números portugueses de 9 dígitos', () {
    expect(numeroWhatsapp('912 345 678'), '351912345678');
    expect(numeroWhatsapp('+351 924874907'), '351924874907');
    expect(numeroWhatsapp('211234567'), '351211234567');
    expect(numeroWhatsapp('+44 7700 900123'), '447700900123');
    expect(numeroWhatsapp('123'), isNull);
    expect(numeroWhatsapp(null), isNull);
  });
}
