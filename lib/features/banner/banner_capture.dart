import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n_extension.dart';
import 'banner_file_saver.dart';

/// Captura/guarda/partilha o banner — partilhado entre o ecrã de
/// formulário (pré-visualização ao vivo) e o ecrã de pré-visualização
/// dedicado, para não duplicar a lógica em dois sítios.
String nomeFicheiroBanner() => 'ps_carstand_banner_${DateTime.now().millisecondsSinceEpoch}.png';

Future<Uint8List> capturarBanner(GlobalKey repaintKey) async {
  final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  // pixelRatio 3 ≈ exportação 3000x3000 a partir do desenho base 1000x1000
  // (mesma escala que o protótipo original usava com html2canvas).
  final imagem = await boundary.toImage(pixelRatio: 3.0);
  final bytesData = await imagem.toByteData(format: ui.ImageByteFormat.png);
  return bytesData!.buffer.asUint8List();
}

Future<void> guardarBanner(BuildContext context, GlobalKey repaintKey) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await capturarBanner(repaintKey);
    final destino = await salvarBannerNoDisco(bytes, nomeFicheiroBanner());
    messenger.showSnackBar(SnackBar(content: Text(l10n.bannerGuardadoSucesso(destino))));
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.bannerErroGuardar)));
  }
}

Future<void> partilharBanner(BuildContext context, GlobalKey repaintKey) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await capturarBanner(repaintKey);
    await Share.shareXFiles([XFile.fromData(bytes, name: nomeFicheiroBanner(), mimeType: 'image/png')]);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.bannerErroGuardar)));
  }
}
