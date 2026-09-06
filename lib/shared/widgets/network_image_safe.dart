import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Substituto de `CachedNetworkImage` — na Web usa `Image.network` puro em
/// vez do cache próprio em IndexedDB (`flutter_cache_manager`), que entra em
/// conflito consigo mesmo depois de um refresh do browser (bug real
/// reportado 2026-09-06: fotos em toda a app — cartões de veículo, galeria,
/// banners — desapareciam ao dar refresh na PWA, só voltavam depois de
/// fechar e reabrir; o browser já tem o seu próprio cache HTTP nativo, por
/// isso não há perda real de desempenho). No mobile/desktop mantém
/// `CachedNetworkImage` normal — aí o cache em disco continua a fazer
/// sentido, não há cache de browser para aproveitar.
///
/// Mesma assinatura de `CachedNetworkImage` (só os parâmetros usados nesta
/// app) para a troca em cada sítio ser só o nome do widget.
class NetworkImageSafe extends StatelessWidget {
  const NetworkImageSafe({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, dynamic)? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: placeholder == null
            ? null
            : (context, child, progress) => progress == null ? child : placeholder!(context, imageUrl),
        errorBuilder: errorWidget == null ? null : (context, error, _) => errorWidget!(context, imageUrl, error),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
