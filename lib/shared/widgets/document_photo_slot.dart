import 'dart:io';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Slot de foto (frente/verso) usado nos fluxos de captura de documento —
/// DUA (secção 5) e identificação do comprador, CC/Título de Residência
/// (secção 23). Extraído para aqui porque os dois fluxos são visualmente
/// idênticos.
class DocumentPhotoSlot extends StatelessWidget {
  const DocumentPhotoSlot({super.key, required this.label, required this.file, required this.onTap});

  final String label;
  final File? file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: file != null ? AppColors.verdeDisponivel : AppColors.grafiteAsfalto.withValues(alpha: 0.2),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: file != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(file!, fit: BoxFit.cover),
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
