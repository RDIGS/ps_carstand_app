// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Ficheiro só é compilado no alvo Web (ver import condicional em
// banner_file_saver.dart) — dart:html é a via suportada nesta versão do
// Flutter para o download direto do browser.
import 'dart:html' as html;
import 'dart:typed_data';

/// Web: dispara o download do browser (não há "pasta de transferências"
/// acessível a partir do sandbox da página).
Future<String> salvarBannerNoDisco(Uint8List bytes, String nomeFicheiro) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', nomeFicheiro)
    ..click();
  html.Url.revokeObjectUrl(url);
  return nomeFicheiro;
}
