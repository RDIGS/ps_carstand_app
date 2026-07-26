import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n_extension.dart';

/// Escolha entre câmara e galeria antes de abrir o `image_picker` —
/// necessário porque `ImageSource.camera` não tem implementação no Windows
/// desktop (`image_picker_windows` lança "Bad state: ... requires a
/// cameraDelegate"), por isso a app nunca pode assumir que a câmara está
/// disponível e tem de deixar sempre a galeria/ficheiro como alternativa.
Future<ImageSource?> escolherFonteImagem(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.fonteImagemCamara),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.fonteImagemGaleria),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
}
