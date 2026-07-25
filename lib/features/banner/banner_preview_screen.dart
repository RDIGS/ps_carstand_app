import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n_extension.dart';
import 'banner_content.dart';
import 'banner_file_saver.dart';
import 'banner_widget.dart';

class BannerPreviewScreen extends StatefulWidget {
  const BannerPreviewScreen({super.key, required this.content});

  final BannerContent content;

  @override
  State<BannerPreviewScreen> createState() => _BannerPreviewScreenState();
}

class _BannerPreviewScreenState extends State<BannerPreviewScreen> {
  final _repaintKey = GlobalKey();
  bool _ocupado = false;

  String get _nomeFicheiro => 'ps_carstand_banner_${DateTime.now().millisecondsSinceEpoch}.png';

  Future<Uint8List> _capturar() async {
    final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // pixelRatio 3 ≈ exportação 3000x3000 a partir do desenho base 1000x1000
    // (mesma escala que o protótipo original usava com html2canvas).
    final imagem = await boundary.toImage(pixelRatio: 3.0);
    final bytesData = await imagem.toByteData(format: ui.ImageByteFormat.png);
    return bytesData!.buffer.asUint8List();
  }

  Future<void> _guardar() async {
    final l10n = context.l10n;
    setState(() => _ocupado = true);
    try {
      final bytes = await _capturar();
      final destino = await salvarBannerNoDisco(bytes, _nomeFicheiro);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bannerGuardadoSucesso(destino))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bannerErroGuardar)));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _partilhar() async {
    final l10n = context.l10n;
    setState(() => _ocupado = true);
    try {
      final bytes = await _capturar();
      await Share.shareXFiles([XFile.fromData(bytes, name: _nomeFicheiro, mimeType: 'image/png')]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bannerErroGuardar)));
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bannerPreviewTitulo)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480, maxHeight: 480),
                child: AspectRatio(
                  aspectRatio: 1,
                  // FittedBox só escala a pré-visualização no ecrã — o
                  // RepaintBoundary fica sempre com o tamanho real
                  // (BannerWidget.tamanho), por isso a captura sai sempre
                  // à mesma resolução independentemente do tamanho da janela.
                  //
                  // IgnorePointer é necessário: um RepaintBoundary dentro de
                  // um FittedBox recebendo eventos de rato (hover) antes do
                  // layout estabilizar despoleta "Cannot hit test a render
                  // box with no size" no Flutter desktop — bug conhecido da
                  // combinação FittedBox+hitTest. Esta zona é só uma
                  // pré-visualização, nunca precisa de ser interativa.
                  child: IgnorePointer(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: RepaintBoundary(
                        key: _repaintKey,
                        child: BannerWidget(content: widget.content),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _ocupado ? null : _guardar,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.guardar),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _ocupado ? null : _partilhar,
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.bannerPartilhar),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
