import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/image_source_picker.dart';
import 'vehicle_photo.dart';
import 'vehicles_repository.dart';

/// Galeria de fotos do veículo em si (distinta das fotos do DUA) — usada
/// para anúncios/banners. Qualquer role pode gerir, tal como a checklist.
class VehiclePhotoGalleryCard extends StatefulWidget {
  const VehiclePhotoGalleryCard({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehiclePhotoGalleryCard> createState() => _VehiclePhotoGalleryCardState();
}

class _VehiclePhotoGalleryCardState extends State<VehiclePhotoGalleryCard> {
  late Future<List<VehiclePhoto>> _future;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<VehiclesRepository>().listPhotos(widget.vehicleId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _adicionarFotos() async {
    final fonte = await escolherFonteImagem(context);
    if (fonte == null || !mounted) return;

    final picker = ImagePicker();
    final List<XFile> ficheiros;
    if (fonte == ImageSource.gallery) {
      ficheiros = await picker.pickMultiImage(imageQuality: 85, maxWidth: 2000);
    } else {
      final foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2000);
      ficheiros = foto == null ? [] : [foto];
    }
    if (ficheiros.isEmpty || !mounted) return;

    setState(() => _uploading = true);
    final repo = context.read<VehiclesRepository>();
    try {
      for (final ficheiro in ficheiros) {
        final bytes = await ficheiro.readAsBytes();
        await repo.addPhoto(widget.vehicleId, bytes);
      }
      if (mounted) await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _removerFoto(VehiclePhoto foto) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.galeriaRemoverFotoTitulo),
        content: Text(l10n.galeriaRemoverFotoConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;

    try {
      await context.read<VehiclesRepository>().removePhoto(widget.vehicleId, foto.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  void _verEmEcraCompleto(List<VehiclePhoto> fotos, int indiceInicial) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GaleriaEcraCompleto(fotos: fotos, indiceInicial: indiceInicial),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<VehiclePhoto>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            final fotos = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.galeriaTitulo, style: Theme.of(context).textTheme.titleLarge),
                    if (fotos.isNotEmpty) Text('${fotos.length}'),
                  ],
                ),
                const SizedBox(height: 8),
                if (fotos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(l10n.galeriaVazia, style: Theme.of(context).textTheme.bodyMedium),
                  )
                else
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: fotos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final foto = fotos[index];
                        return GestureDetector(
                          onTap: () => _verEmEcraCompleto(fotos, index),
                          onLongPress: () => _removerFoto(foto),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(foto.url, width: 96, height: 96, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _uploading ? null : _adicionarFotos,
                  icon: _uploading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(l10n.galeriaAdicionarFotos),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GaleriaEcraCompleto extends StatelessWidget {
  const _GaleriaEcraCompleto({required this.fotos, required this.indiceInicial});

  final List<VehiclePhoto> fotos;
  final int indiceInicial;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: PageView.builder(
        controller: PageController(initialPage: indiceInicial),
        itemCount: fotos.length,
        itemBuilder: (context, index) => Center(
          child: InteractiveViewer(child: Image.network(fotos[index].url)),
        ),
      ),
    );
  }
}
