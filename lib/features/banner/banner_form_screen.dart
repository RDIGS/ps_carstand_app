import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import '../../shared/widgets/network_image_safe.dart';
import '../auth/auth_state.dart';
import '../vehicles/vehicle_detail.dart';
import '../vehicles/vehicle_photo.dart';
import '../vehicles/vehicles_repository.dart';
import 'banner_calculo.dart';
import 'banner_capture.dart';
import 'banner_content.dart';
import 'banner_preview_screen.dart';
import 'banner_widget.dart';
import 'stand_profile_repository.dart';
import 'templates/banner_template.dart';

/// Ecrã de confirmação do banner de venda: tudo vem pré-preenchido a partir
/// do veículo e do perfil da loja, mas cada campo é editável — nada é
/// gerado sem o utilizador ver e poder corrigir os valores primeiro.
class BannerFormScreen extends StatefulWidget {
  const BannerFormScreen({super.key, required this.vehicle, required this.templateId});

  final VehicleDetail vehicle;
  final BannerTemplateId templateId;

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  static const _corPorOmissao = Color(0xFFE50914);

  final _repaintKey = GlobalKey();

  late final TextEditingController _titulo;
  late final TextEditingController _subtitulo;
  late final TextEditingController _potencia;
  late final TextEditingController _ano;
  late final TextEditingController _combustivel;
  late final TextEditingController _preco;
  late final TextEditingController _prestacao;
  late final TextEditingController _social;
  late final TextEditingController _contacto;

  Color _corDestaque = _corPorOmissao;
  Uint8List? _foto;
  bool _carregandoFoto = false;
  bool _ocupado = false;
  String _socialInicial = '';
  String _contactoInicial = '';

  // Só usado pelo template "Galeria de Fotos" (BannerTemplateId.galeriaFotos)
  // — fotos vêm da galeria já guardada do veículo, não de uma escolha nova.
  // Primeira posição de `_galeriaSelecionada` = foto principal; o utilizador
  // reorganiza por drag, o que também decide qual é a principal.
  bool get _isGaleriaFotos => widget.templateId == BannerTemplateId.galeriaFotos;
  Future<List<VehiclePhoto>>? _galeriaFuture;
  final List<VehiclePhoto> _galeriaSelecionada = [];
  final Map<String, Uint8List> _galeriaBytesCache = {};
  bool _baixandoFoto = false;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (_isGaleriaFotos) {
      _galeriaFuture = context.read<VehiclesRepository>().listPhotos(v.id);
    }
    final cv = BannerCalculo.potenciaCv(v.potenciaKw);
    final preco = BannerCalculo.precoBase(v);
    final prestacao = BannerCalculo.prestacaoMensal(preco);
    final ano = BannerCalculo.ano(v.dataPrimeiraMatriculaReal);

    _titulo = TextEditingController(text: '${v.marca} ${v.modelo}');
    _subtitulo = TextEditingController(text: v.versao ?? v.combustivel ?? '');
    _potencia = TextEditingController(text: cv != null ? '$cv CV' : '');
    _ano = TextEditingController(text: ano ?? '');
    _combustivel = TextEditingController(text: v.combustivel?.toUpperCase() ?? '');
    _preco = TextEditingController(text: preco != null ? '${preco.toStringAsFixed(0)} €' : '');
    _prestacao = TextEditingController(text: prestacao != null ? '${prestacao.toStringAsFixed(0)} € / MÊS' : '');
    _social = TextEditingController();
    _contacto = TextEditingController();

    _carregarPerfilLoja();
  }

  Future<void> _carregarPerfilLoja() async {
    try {
      final perfil = await context.read<StandProfileRepository>().getProfile();
      if (!mounted) return;
      setState(() {
        _socialInicial = perfil.redesSociais ?? '';
        _contactoInicial = perfil.contacto ?? '';
        _social.text = _socialInicial;
        _contacto.text = _contactoInicial;
      });
    } catch (_) {
      // Perfil da loja é só conveniência de pré-preenchimento — se falhar,
      // os campos ficam em branco e o utilizador escreve à mão.
    }
  }

  @override
  void dispose() {
    for (final c in [_titulo, _subtitulo, _potencia, _ano, _combustivel, _preco, _prestacao, _social, _contacto]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    setState(() => _carregandoFoto = true);
    try {
      final ficheiro = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90, maxWidth: 2000);
      if (ficheiro == null) return;
      final bytes = await ficheiro.readAsBytes();
      if (!mounted) return;
      setState(() => _foto = bytes);
    } finally {
      if (mounted) setState(() => _carregandoFoto = false);
    }
  }

  Future<Uint8List> _baixarBytes(String url) async {
    final resposta = await Dio().get<List<int>>(url, options: Options(responseType: ResponseType.bytes));
    return Uint8List.fromList(resposta.data!);
  }

  Future<void> _alternarSelecaoGaleria(VehiclePhoto foto) async {
    if (_galeriaSelecionada.any((f) => f.id == foto.id)) {
      setState(() => _galeriaSelecionada.removeWhere((f) => f.id == foto.id));
      return;
    }
    setState(() {
      _galeriaSelecionada.add(foto);
      _baixandoFoto = true;
    });
    try {
      _galeriaBytesCache[foto.id] ??= await _baixarBytes(foto.url);
    } catch (_) {
      // Falha a descarregar esta foto em concreto — tira-a da seleção em vez
      // de deixar um espaço vazio na grelha.
      if (mounted) setState(() => _galeriaSelecionada.removeWhere((f) => f.id == foto.id));
    } finally {
      if (mounted) setState(() => _baixandoFoto = false);
    }
  }

  void _reordenarGaleria(int origem, int destino) {
    setState(() {
      if (destino > origem) destino -= 1;
      final item = _galeriaSelecionada.removeAt(origem);
      _galeriaSelecionada.insert(destino, item);
    });
  }

  Uint8List? get _fotoPrincipalGaleria =>
      _galeriaSelecionada.isEmpty ? null : _galeriaBytesCache[_galeriaSelecionada.first.id];

  List<Uint8List> get _fotosGaleriaRestantes =>
      _galeriaSelecionada.skip(1).map((f) => _galeriaBytesCache[f.id]).whereType<Uint8List>().toList();

  Future<void> _escolherCor() async {
    final cor = await showDialog<Color>(
      context: context,
      builder: (context) {
        var corTemp = _corDestaque;
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.bannerEscolherCor),
          content: SingleChildScrollView(
            child: ColorPicker(pickerColor: _corDestaque, onColorChanged: (c) => corTemp = c),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.cancelar)),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(corTemp), child: Text(l10n.ok)),
          ],
        );
      },
    );
    if (cor != null) setState(() => _corDestaque = cor);
  }

  BannerContent get _conteudoAtual => BannerContent(
        templateId: widget.templateId,
        titulo: _titulo.text,
        subtitulo: _subtitulo.text,
        potencia: _potencia.text,
        ano: _ano.text,
        combustivel: _combustivel.text,
        preco: _preco.text,
        prestacao: _prestacao.text,
        social: _social.text,
        contacto: _contacto.text,
        corDestaque: _corDestaque,
        foto: _isGaleriaFotos ? _fotoPrincipalGaleria : _foto,
        fotosGaleria: _isGaleriaFotos ? _fotosGaleriaRestantes : const [],
      );

  /// Guarda contacto/@handle no perfil da loja para os próximos banners já
  /// virem pré-preenchidos — só o owner tem permissão para editar o perfil
  /// (backend rejeita o vendedor), por isso só tenta se for ele e algo
  /// mudou de facto face ao que veio do servidor. Nunca bloqueia a ação
  /// principal (guardar/pré-visualizar) se a persistência falhar.
  Future<void> _persistirPerfilSeNecessario() async {
    final role = context.read<AuthState>().userRole;
    final socialMudou = _social.text != _socialInicial;
    final contactoMudou = _contacto.text != _contactoInicial;
    if (role != 'owner' || (!socialMudou && !contactoMudou)) return;
    try {
      await context.read<StandProfileRepository>().updateProfile(
            contacto: contactoMudou ? _contacto.text : null,
            redesSociais: socialMudou ? _social.text : null,
          );
    } catch (_) {
      // Ignorado de propósito — ver docstring acima.
    }
  }

  bool _validarFoto() {
    if (_isGaleriaFotos ? _galeriaSelecionada.isNotEmpty : _foto != null) return true;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bannerFotoObrigatoria)));
    return false;
  }

  Future<void> _guardarAgora() async {
    if (!_validarFoto()) return;
    setState(() => _ocupado = true);
    await _persistirPerfilSeNecessario();
    if (!mounted) return;
    await guardarBanner(context, _repaintKey);
    if (mounted) setState(() => _ocupado = false);
  }

  Future<void> _continuar() async {
    if (!_validarFoto()) return;
    setState(() => _ocupado = true);
    await _persistirPerfilSeNecessario();
    if (!mounted) return;
    setState(() => _ocupado = false);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BannerPreviewScreen(content: _conteudoAtual)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.bannerTitulo)),
      body: MaxWidthBody(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: bannerTemplateInfo(widget.templateId).formato.restricaoPreview,
                child: AspectRatio(
                  aspectRatio: bannerTemplateInfo(widget.templateId).formato.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // Clicar na pré-visualização também abre o seletor de foto —
                    // por isso esta zona TEM de participar no hit-test (ao
                    // contrário do ecrã de pré-visualização final, que é só
                    // leitura). O RepaintBoundary aqui é o mesmo usado por
                    // "Guardar": captura sempre ao tamanho real (BannerWidget.
                    // tamanho), independente da escala visual do FittedBox.
                    child: MouseRegion(
                      cursor: _isGaleriaFotos ? MouseCursor.defer : SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _isGaleriaFotos || _carregandoFoto ? null : _escolherFoto,
                        // No template Galeria de Fotos, tocar na pré-visualização
                        // não faz nada (a escolha é toda feita no seletor
                        // abaixo) — por isso esta zona pode ficar fora do
                        // hit-test aqui também. Sem isto, o RepaintBoundary
                        // dentro do FittedBox chegou a receber eventos de rato
                        // diretamente e rebentou com "Cannot hit test a render
                        // box with no size" em repetição (bug real reportado
                        // 2026-09-02) — mesmo problema que o comentário abaixo já
                        // descrevia, só que aqui nunca estava protegido por
                        // IgnorePointer como está no ecrã de Pré-visualização.
                        child: IgnorePointer(
                          ignoring: _isGaleriaFotos,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              FittedBox(
                                fit: BoxFit.contain,
                                child: AnimatedBuilder(
                                  animation: Listenable.merge(
                                    [
                                      _titulo,
                                      _subtitulo,
                                      _potencia,
                                      _ano,
                                      _combustivel,
                                      _preco,
                                      _prestacao,
                                      _social,
                                      _contacto
                                    ],
                                  ),
                                  builder: (context, _) => RepaintBoundary(
                                    key: _repaintKey,
                                    child: BannerWidget(content: _conteudoAtual),
                                  ),
                                ),
                              ),
                              if (!_isGaleriaFotos)
                                Positioned(
                                  right: 12,
                                  bottom: 12,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
                                    child: const Padding(
                                      padding: EdgeInsets.all(8),
                                      child: Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_isGaleriaFotos) ...[
              _SeletorGaleriaFotos(
                future: _galeriaFuture,
                selecionadas: _galeriaSelecionada,
                bytesCache: _galeriaBytesCache,
                baixando: _baixandoFoto,
                onToggle: _alternarSelecaoGaleria,
                onReorder: _reordenarGaleria,
              ),
              const SizedBox(height: 8),
            ] else ...[
              if (_foto == null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.bannerAvisoExemplo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _carregandoFoto ? null : _escolherFoto,
                icon: const Icon(Icons.add_a_photo_outlined),
                label: Text(_foto == null ? l10n.bannerCarregarFoto : l10n.bannerTrocarFoto),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _escolherCor,
              icon: Icon(Icons.palette_outlined, color: _corDestaque),
              label: Text(l10n.bannerEscolherCor),
            ),
            const SizedBox(height: 24),
            TextField(controller: _titulo, decoration: InputDecoration(labelText: l10n.bannerCampoTitulo)),
            const SizedBox(height: 12),
            TextField(controller: _subtitulo, decoration: InputDecoration(labelText: l10n.bannerCampoSubtitulo)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                      controller: _potencia, decoration: InputDecoration(labelText: l10n.bannerCampoPotencia)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: _ano, decoration: InputDecoration(labelText: l10n.bannerCampoAno)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(controller: _combustivel, decoration: InputDecoration(labelText: l10n.bannerCampoCombustivel)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _preco, decoration: InputDecoration(labelText: l10n.bannerCampoPreco)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                      controller: _prestacao, decoration: InputDecoration(labelText: l10n.bannerCampoPrestacao)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(l10n.bannerPerfilLojaSecao, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(controller: _social, decoration: InputDecoration(labelText: l10n.bannerCampoSocial)),
            const SizedBox(height: 12),
            TextField(controller: _contacto, decoration: InputDecoration(labelText: l10n.bannerCampoContacto)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _ocupado ? null : _guardarAgora,
                    icon: _ocupado
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.download_outlined),
                    label: Text(l10n.guardar),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _ocupado ? null : _continuar,
                    child: _ocupado
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.bannerContinuar),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Escolha + reorganização das fotos do template "Galeria de Fotos" — vêm
/// sempre da galeria já guardada do veículo (`VehiclesRepository.listPhotos`),
/// nunca de uma escolha nova no dispositivo. A ordem da lista reorganizável
/// decide tudo: a 1ª é sempre a foto principal do banner.
class _SeletorGaleriaFotos extends StatelessWidget {
  const _SeletorGaleriaFotos({
    required this.future,
    required this.selecionadas,
    required this.bytesCache,
    required this.baixando,
    required this.onToggle,
    required this.onReorder,
  });

  final Future<List<VehiclePhoto>>? future;
  final List<VehiclePhoto> selecionadas;
  final Map<String, Uint8List> bytesCache;
  final bool baixando;
  final Future<void> Function(VehiclePhoto) onToggle;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.bannerGaleriaEscolherTitulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.bannerGaleriaEscolherTexto, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        FutureBuilder<List<VehiclePhoto>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            }
            final fotos = snapshot.data ?? const [];
            if (fotos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(l10n.bannerGaleriaVazia, style: Theme.of(context).textTheme.bodyMedium),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: fotos.map((foto) {
                final indice = selecionadas.indexWhere((f) => f.id == foto.id);
                final selecionada = indice != -1;
                return GestureDetector(
                  onTap: baixando ? null : () => onToggle(foto),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: NetworkImageSafe(
                          imageUrl: foto.url,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          placeholder: (context, _) => Container(
                            width: 84,
                            height: 84,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (context, _, __) => Container(
                            width: 84,
                            height: 84,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      if (selecionada)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 3),
                            ),
                          ),
                        ),
                      if (selecionada)
                        Positioned(
                          left: 4,
                          top: 4,
                          child: CircleAvatar(
                            radius: 11,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${indice + 1}',
                              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        if (selecionadas.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(l10n.bannerGaleriaSelecionadasTitulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              buildDefaultDragHandles: false,
              itemCount: selecionadas.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final foto = selecionadas[index];
                final bytes = bytesCache[foto.id];
                return ReorderableDragStartListener(
                  key: ValueKey(foto.id),
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: bytes != null
                              ? Image.memory(bytes, width: 84, height: 84, fit: BoxFit.cover)
                              : Container(
                                  width: 84,
                                  height: 84,
                                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                        ),
                        if (index == 0)
                          Positioned(
                            left: 4,
                            bottom: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Text(
                                  l10n.bannerGaleriaPrincipalEtiqueta,
                                  style:
                                      const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: GestureDetector(
                            onTap: () => onToggle(foto),
                            child: const DecoratedBox(
                              decoration: BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
