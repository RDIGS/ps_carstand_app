// Espelha src/common/utils/nif.util.ts do backend — algoritmo de checksum
// oficial do NIF português (secção 21). Validação client-side é só
// feedback imediato; o backend valida sempre outra vez antes de gravar.
bool isValidNif(String nif) {
  if (!RegExp(r'^\d{9}$').hasMatch(nif)) return false;

  final digits = nif.split('').map(int.parse).toList();
  final checkDigit = digits[8];

  var sum = 0;
  for (var i = 0; i < 8; i++) {
    sum += digits[i] * (9 - i);
  }

  final remainder = sum % 11;
  final expected = remainder < 2 ? 0 : 11 - remainder;

  return expected == checkDigit;
}
