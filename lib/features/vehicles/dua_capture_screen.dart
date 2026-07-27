import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/document_photo_slot.dart';
import '../../shared/widgets/image_source_picker.dart';
import '../../shared/widgets/max_width_body.dart';
import 'add_vehicle_screen.dart';
import 'vehicles_repository.dart';

/// Captura frente/verso do DUA (secção 5, Opção B) e envia para OCR.
///
/// Simplificação face à secção 20 (moldura-guia + deteção de imagem
/// desfocada client-side): fica por implementar — precisa do pacote
/// `camera` com overlay em tempo real e um cálculo de variância de
/// Laplaciano, um esforço à parte. A rede de segurança real (o ecrã de
/// confirmação humana obrigatório a seguir a esta captura) já cobre o caso
/// de uma foto de má qualidade, por isso isto não bloqueia o fluxo.
class DuaCaptureScreen extends StatefulWidget {
  const DuaCaptureScreen({super.key});

  @override
  State<DuaCaptureScreen> createState() => _DuaCaptureScreenState();
}

class _DuaCaptureScreenState extends State<DuaCaptureScreen> {
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
      final repo = context.read<VehiclesRepository>();
      final resultado = await repo.extractFromDua(fotoFrente: frenteBytes, fotoVerso: versoBytes);

      if (!mounted) return;
      final confirmId = const Uuid().v4();
      // Push normal (não pushReplacement): assim, quando o AddVehicleScreen
      // guardar com sucesso, este ecrã consegue propagar esse resultado para
      // trás até à lista de veículos, que só assim sabe que deve atualizar.
      final guardado = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddVehicleScreen(
            initial: resultado.toCreateVehicleData(),
            confirmId: confirmId,
            duaAvisos: resultado.avisos,
            // Secção 23 (aplicado também ao DUA, por decisão do utilizador):
            // só se as fotos já estavam cortadas/prontas é que chegam a ser
            // guardadas — caso contrário só serviram para preencher o
            // formulário, tal como já acontecia antes desta funcionalidade.
            duaFrenteBytes: _fotosProntas ? frenteBytes : null,
            duaVersoBytes: _fotosProntas ? versoBytes : null,
          ),
        ),
      );
      if (!mounted) return;
      if (guardado == true) {
        Navigator.of(context).pop(true);
        return;
      }
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
      appBar: AppBar(title: Text(l10n.duaCaptureTitulo)),
      body: MaxWidthBody(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.duaCaptureInstrucoes),
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
