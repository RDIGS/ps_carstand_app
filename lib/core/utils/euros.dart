/// "19020" → "19 020 €" (mesmo agrupamento por espaços dos kms nos cartões).
/// `sinal: true` acrescenta "+" aos positivos — para margens/lucros.
String euros(double valor, {bool sinal = false}) {
  final inteiro = valor.round();
  final digitos = inteiro.abs().toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  final prefixo = inteiro < 0 ? '−' : (sinal && inteiro > 0 ? '+' : '');
  return '$prefixo$digitos €';
}
