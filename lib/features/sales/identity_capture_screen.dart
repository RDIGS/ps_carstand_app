import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/document_photo_slot.dart';
import '../../shared/widgets/image_source_picker.dart';
import '../../shared/widgets/max_width_body.dart';
import 'identity_extraction_result.dart';
import 'sales_repository.dart';

/// Resultado devolvido ao `SaleScreen`: os dados extraídos, e — só se o
/// utilizador confirmou que as fotos já estavam cortadas/prontas — os bytes
/// para anexar à venda depois de esta ser criada com sucesso (secção 23).
class IdentityCaptureOutcome {
  IdentityCaptureOutcome({required this.result, this.frenteBytes, this.versoBytes});

  final IdentityExtractionResult result;
  final List<int>? frenteBytes;
  final List<int>? versoBytes;
}

/// Captura frente/verso do documento de identificação do comprador — CC ou
/// Título de Residência, o backend deteta qual dos dois é (secção 23).
class IdentityCaptureScreen extends StatefulWidget {
  const IdentityCaptureScreen({super.key});

  @override
  State<IdentityCaptureScreen> createState() => _IdentityCaptureScreenState();
}

class _IdentityCaptureScreenState extends State<IdentityCaptureScreen> {
  final _picker = ImagePicker();
  Uint8List? _frente;
  Uint8List? _verso;
  bool _fotosProntas = false;
  bool _extraindo = false;
  String? _erro;

  bool get _prontoParaExtrair => _frente != null && _verso != null;

  Future<void> _capturar({required bool isFrente}) async {
    final fonte = await escolherFonteImagem(context);
    if (fonte == null || !mounted) return;
    final foto = await _picker.pickImage(source: fonte, imageQuality: 90, maxWidth: 2000);
    if (foto == null) return;
    // XFile.readAsBytes() funciona em todas as plataformas, incluindo Web —
    // ao contrário de `File(foto.path)`, que não existe no browser.
    final bytes = await foto.readAsBytes();
    if (!mounted) return;
    setState(() {
      if (isFrente) {
        _frente = bytes;
      } else {
        _verso = bytes;
      }
      _erro = null;
    });
  }

  Future<void> _extrair() async {
    setState(() {
      _extraindo = true;
      _erro = null;
    });

    try {
      final frenteBytes = _frente!;
      final versoBytes = _verso!;
      final repo = context.read<SalesRepository>();
      final resultado = await repo.extractIdentity(fotoFrente: frenteBytes, fotoVerso: versoBytes);

      if (!mounted) return;
      Navigator.of(context).pop(
        IdentityCaptureOutcome(
          result: resultado,
          frenteBytes: _fotosProntas ? frenteBytes : null,
          versoBytes: _fotosProntas ? versoBytes : null,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _extraindo = false;
        _erro = e.localizado(context);
      });
    } finally {
      if (mounted && _extraindo) setState(() => _extraindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.identidadeCaptureTitulo)),
      body: MaxWidthBody(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.identidadeCaptureInstrucoes),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: DocumentPhotoSlot(
                        label: l10n.duaFrente,
                        bytes: _frente,
                        onTap: _extraindo ? null : () => _capturar(isFrente: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DocumentPhotoSlot(
                        label: l10n.duaVerso,
                        bytes: _verso,
                        onTap: _extraindo ? null : () => _capturar(isFrente: false),
                      ),
                    ),
                  ],
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(_erro!, style: const TextStyle(color: AppColors.amberSinal)),
              ],
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _fotosProntas,
                onChanged: _extraindo ? null : (v) => setState(() => _fotosProntas = v ?? false),
                title: Text(l10n.fotosJaProntasTitulo),
                subtitle: Text(l10n.fotosJaProntasSubtitulo),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: (_prontoParaExtrair && !_extraindo) ? _extrair : null,
                child: _extraindo
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.extrairDados),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
