import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../auth/auth_state.dart';
import '../vehicles/vehicle_detail.dart';
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

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
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
        foto: _foto,
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
    if (_foto != null) return true;
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Clicar na pré-visualização também abre o seletor de foto —
              // por isso esta zona TEM de participar no hit-test (ao
              // contrário do ecrã de pré-visualização final, que é só
              // leitura). O RepaintBoundary aqui é o mesmo usado por
              // "Guardar": captura sempre ao tamanho real (BannerWidget.
              // tamanho), independente da escala visual do FittedBox.
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _carregandoFoto ? null : _escolherFoto,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FittedBox(
                        fit: BoxFit.contain,
                        child: AnimatedBuilder(
                          animation: Listenable.merge(
                            [_titulo, _subtitulo, _potencia, _ano, _combustivel, _preco, _prestacao, _social, _contacto],
                          ),
                          builder: (context, _) => RepaintBoundary(
                            key: _repaintKey,
                            child: BannerWidget(content: _conteudoAtual),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), shape: BoxShape.circle),
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
          const SizedBox(height: 8),
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
                child: TextField(controller: _potencia, decoration: InputDecoration(labelText: l10n.bannerCampoPotencia)),
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
                child: TextField(controller: _prestacao, decoration: InputDecoration(labelText: l10n.bannerCampoPrestacao)),
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
                  icon: const Icon(Icons.download_outlined),
                  label: Text(l10n.guardar),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _ocupado ? null : _continuar,
                  child: Text(l10n.bannerContinuar),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
