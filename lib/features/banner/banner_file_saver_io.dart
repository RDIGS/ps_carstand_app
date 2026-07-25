import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Windows/desktop: grava diretamente na pasta de transferências do
/// utilizador. Devolve o caminho completo do ficheiro gravado.
Future<String> salvarBannerNoDisco(Uint8List bytes, String nomeFicheiro) async {
  final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
  final ficheiro = File('${dir.path}${Platform.pathSeparator}$nomeFicheiro');
  await ficheiro.writeAsBytes(bytes);
  return ficheiro.path;
}
