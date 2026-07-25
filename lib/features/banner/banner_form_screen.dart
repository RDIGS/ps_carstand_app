import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../auth/auth_state.dart';
import '../vehicles/vehicle_detail.dart';
import 'banner_calculo.dart';
import 'banner_content.dart';
import 'banner_preview_screen.dart';
import 'banner_widget.dart';
import 'stand_profile_repository.dart';

/// Ecrã de confirmação do banner de venda: tudo vem pré-preenchido a partir
/// do veículo e do perfil da loja, mas cada campo é editável — nada é
/// gerado sem o utilizador ver e poder corrigir os valores primeiro.
class BannerFormScreen extends StatefulWidget {
  const BannerFormScreen({super.key, required this.vehicle});

  final VehicleDetail vehicle;

  @override
  State<BannerFormScreen> createState() => _BannerFormScreenState();
}

class _BannerFormScreenState extends State<BannerFormScreen> {
  static const _corPorOmissao = Color(0xFFE50914);

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

  Future<void> _continuar() async {
    if (_foto == null) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.bannerFotoObrigatoria)));
      return;
    }

    // Guarda contacto/@handle no perfil da loja para os próximos banners já
    // virem pré-preenchidos — só o owner tem permissão para editar o
    // perfil (backend rejeita o vendedor), por isso só tentamos se for ele
    // e algo mudou de facto face ao que veio do servidor.
    final role = context.read<AuthState>().userRole;
    final socialMudou = _social.text != _socialInicial;
    final contactoMudou = _contacto.text != _contactoInicial;
    if (role == 'owner' && (socialMudou || contactoMudou)) {
      try {
        await context.read<StandProfileRepository>().updateProfile(
              contacto: contactoMudou ? _contacto.text : null,
              redesSociais: socialMudou ? _social.text : null,
            );
      } catch (_) {
        // Não bloqueia a geração do banner por causa disto — o valor
        // editado continua a ser usado neste banner mesmo que a
        // persistência para os próximos falhe.
      }
    }

    if (!mounted) return;
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
              // IgnorePointer evita o "Cannot hit test a render box with no
              // size" do Flutter desktop quando um FittedBox recebe eventos
              // de rato entre rebuilds — esta pré-visualização nunca precisa
              // de ser interativa (ver nota igual em banner_preview_screen.dart).
              child: IgnorePointer(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                      [_titulo, _subtitulo, _potencia, _ano, _combustivel, _preco, _prestacao, _social, _contacto],
                    ),
                    builder: (context, _) => BannerWidget(content: _conteudoAtual),
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
          ElevatedButton(onPressed: _continuar, child: Text(l10n.bannerContinuar)),
        ],
      ),
    );
  }
}
