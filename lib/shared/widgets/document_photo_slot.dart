import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Slot de foto (frente/verso) usado nos fluxos de captura de documento —
/// DUA (secção 5) e identificação do comprador, CC/Título de Residência
/// (secção 23). Extraído para aqui porque os dois fluxos são visualmente
/// idênticos.
///
/// Usa bytes (`Uint8List`) em vez de `dart:io File` de propósito — `File`
/// não existe em Flutter Web (crasha em runtime no browser), e a app corre
/// também como PWA (secção 2).
class DocumentPhotoSlot extends StatelessWidget {
  const DocumentPhotoSlot({super.key, required this.label, required this.bytes, required this.onTap});

  final String label;
  final Uint8List? bytes;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: bytes != null
                ? AppColors.verdeDisponivel
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: bytes != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(bytes!, fit: BoxFit.cover),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.verdeDisponivel,
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.grafiteVendido),
                  const SizedBox(height: 8),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
