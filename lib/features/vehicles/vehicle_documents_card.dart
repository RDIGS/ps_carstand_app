import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/image_source_picker.dart';
import '../../shared/widgets/network_image_safe.dart';
import 'vehicle_documents.dart';
import 'vehicle_photo.dart';
import 'vehicles_repository.dart';

/// Documentos do veículo — seguro e inspeção (secção nova, 2026-09-16),
/// anexáveis no ato da compra (`AddVehicleScreen`) ou a qualquer momento
/// depois, aqui. Distinto da galeria geral (`VehiclePhotoGalleryCard`) e do
/// DUA: cada tipo é a sua própria mini-galeria, sem data de validade (pedido
/// explícito do utilizador — só arquivo, sem avisos de expiração).
class VehicleDocumentsCard extends StatefulWidget {
  const VehicleDocumentsCard({super.key, required this.vehicleId});

  final String vehicleId;

  @override
  State<VehicleDocumentsCard> createState() => _VehicleDocumentsCardState();
}

class _VehicleDocumentsCardState extends State<VehicleDocumentsCard> {
  late Future<VehicleDocuments> _future;
  final Set<String> _carregando = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<VehiclesRepository>().listDocuments(widget.vehicleId);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _adicionar(String tipo) async {
    final fonte = await escolherFonteImagem(context);
    if (fonte == null || !mounted) return;
    final ficheiro = await ImagePicker().pickImage(source: fonte, imageQuality: 85, maxWidth: 2000);
    if (ficheiro == null || !mounted) return;

    setState(() => _carregando.add(tipo));
    try {
      final bytes = await ficheiro.readAsBytes();
      if (!mounted) return;
      await context.read<VehiclesRepository>().addDocument(widget.vehicleId, tipo, bytes);
      if (mounted) await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _carregando.remove(tipo));
    }
  }

  Future<void> _remover(VehiclePhoto foto) async {
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
      await context.read<VehiclesRepository>().removeDocument(widget.vehicleId, foto.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  void _verEmEcraCompleto(List<VehiclePhoto> fotos, int indiceInicial) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _DocumentoEcraCompleto(fotos: fotos, indiceInicial: indiceInicial)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<VehicleDocuments>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()));
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            final docs = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.documentosTitulo, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _SecaoDocumento(
                  titulo: l10n.documentoTipoSeguro,
                  fotos: docs.seguro,
                  carregando: _carregando.contains('seguro'),
                  onAdicionar: () => _adicionar('seguro'),
                  onTapFoto: (i) => _verEmEcraCompleto(docs.seguro, i),
                  onRemoverFoto: _remover,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),
                _SecaoDocumento(
                  titulo: l10n.documentoTipoInspecao,
                  fotos: docs.inspecao,
                  carregando: _carregando.contains('inspecao'),
                  onAdicionar: () => _adicionar('inspecao'),
                  onTapFoto: (i) => _verEmEcraCompleto(docs.inspecao, i),
                  onRemoverFoto: _remover,
                  l10n: l10n,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SecaoDocumento extends StatelessWidget {
  const _SecaoDocumento({
    required this.titulo,
    required this.fotos,
    required this.carregando,
    required this.onAdicionar,
    required this.onTapFoto,
    required this.onRemoverFoto,
    required this.l10n,
  });

  final String titulo;
  final List<VehiclePhoto> fotos;
  final bool carregando;
  final VoidCallback onAdicionar;
  final void Function(int indice) onTapFoto;
  final void Function(VehiclePhoto foto) onRemoverFoto;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (fotos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(l10n.documentoSemFotos, style: Theme.of(context).textTheme.bodySmall),
          )
        else
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: fotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final foto = fotos[index];
                return GestureDetector(
                  onTap: () => onTapFoto(index),
                  onLongPress: () => onRemoverFoto(foto),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: NetworkImageSafe(
                      imageUrl: foto.url,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (context, _) =>
                          Container(width: 80, height: 80, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                      errorWidget: (context, _, __) => Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: carregando ? null : onAdicionar,
          icon: carregando
              ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.add_a_photo_outlined),
          label: Text(l10n.documentoAdicionarFoto),
        ),
      ],
    );
  }
}

class _DocumentoEcraCompleto extends StatelessWidget {
  const _DocumentoEcraCompleto({required this.fotos, required this.indiceInicial});

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
          child: InteractiveViewer(
            child: NetworkImageSafe(
              imageUrl: fotos[index].url,
              placeholder: (context, _) => const CircularProgressIndicator(),
              errorWidget: (context, _, __) => const Icon(Icons.broken_image_outlined, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
