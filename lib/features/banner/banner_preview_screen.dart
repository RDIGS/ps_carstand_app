import 'package:flutter/material.dart';

import '../../core/l10n_extension.dart';
import 'banner_capture.dart';
import 'banner_content.dart';
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

  Future<void> _guardar() async {
    setState(() => _ocupado = true);
    await guardarBanner(context, _repaintKey);
    if (mounted) setState(() => _ocupado = false);
  }

  Future<void> _partilhar() async {
    setState(() => _ocupado = true);
    await partilharBanner(context, _repaintKey);
    if (mounted) setState(() => _ocupado = false);
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
                  // IgnorePointer: esta zona é só de leitura (para trocar a
                  // foto volta-se ao ecrã anterior) — mantém-se fora do
                  // hit-test para não arriscar o "Cannot hit test a render
                  // box with no size" que pode surgir com RepaintBoundary
                  // dentro de FittedBox a receber eventos de rato.
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
