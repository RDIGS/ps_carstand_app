import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../shared/widgets/max_width_body.dart';
import '../../shared/widgets/network_image_safe.dart';
import '../banner/stand_profile.dart';
import '../banner/stand_profile_repository.dart';

/// Domínio onde o site público é mostrado (regra de rewrite do Static Site
/// no Render → `/site/:slug` do backend).
const String siteBaseUrl = String.fromEnvironment('SITE_BASE_URL', defaultValue: 'https://ps-carstand-app.onrender.com');

final _slugValido = RegExp(r'^[a-z0-9](?:[a-z0-9-]{1,38})[a-z0-9]$');

/// Sugestão de endereço a partir do nome do stand ("Auto Silva, Lda" →
/// "auto-silva-lda").
String sugerirSlug(String nome) {
  const acentos = {'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'é': 'e', 'ê': 'e', 'í': 'i', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ú': 'u', 'ç': 'c'};
  final base = nome.toLowerCase().split('').map((c) => acentos[c] ?? c).join();
  final s = base.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return s.length > 40 ? s.substring(0, 40).replaceAll(RegExp(r'-+$'), '') : s;
}

/// Definições do stand (owner): perfil público, site e permissões.
class StandSettingsScreen extends StatefulWidget {
  const StandSettingsScreen({super.key});

  @override
  State<StandSettingsScreen> createState() => _StandSettingsScreenState();
}

class _StandSettingsScreenState extends State<StandSettingsScreen> {
  final _contacto = TextEditingController();
  final _morada = TextEditingController();
  final _redes = TextEditingController();
  final _slug = TextEditingController();
  StandProfile? _perfil;
  bool _siteAtivo = false;
  bool _colabAprovam = false;
  bool _aGuardar = false;
  bool _aMudarLogo = false;
  ApiException? _erroCarregar;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    for (final c in [_contacto, _morada, _redes, _slug]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final p = await context.read<StandProfileRepository>().getProfile();
      if (!mounted) return;
      setState(() {
        _aplicar(p);
        _erroCarregar = null;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _erroCarregar = e);
    }
  }

  void _aplicar(StandProfile p) {
    _perfil = p;
    _contacto.text = p.contacto ?? '';
    _morada.text = p.morada ?? '';
    _redes.text = p.redesSociais ?? '';
    _slug.text = p.slug ?? sugerirSlug(p.nome);
    _siteAtivo = p.siteAtivo;
    _colabAprovam = p.vendedorPodeAprovarVisitas;
  }

  String? _ouNull(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  String get _enderecoCompleto => '$siteBaseUrl/${_slug.text.trim()}';

  bool get _slugOk => _slugValido.hasMatch(_slug.text.trim());

  Future<void> _guardar() async {
    final l10n = context.l10n;
    final slug = _slug.text.trim();
    if (slug.isNotEmpty && !_slugOk) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.definicoesSiteEnderecoInvalido)));
      return;
    }
    if (_siteAtivo && slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.definicoesSiteSemEndereco)));
      return;
    }
    setState(() => _aGuardar = true);
    try {
      final p = await context.read<StandProfileRepository>().saveSettings(
            contacto: _ouNull(_contacto),
            redesSociais: _ouNull(_redes),
            morada: _ouNull(_morada),
            slug: slug.isEmpty ? null : slug,
            siteAtivo: _siteAtivo,
            vendedorPodeAprovarVisitas: _colabAprovam,
          );
      if (!mounted) return;
      setState(() => _aplicar(p));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.definicoesGuardado)));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _aGuardar = false);
    }
  }

  Future<void> _mudarLogo() async {
    final ficheiro = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 90, maxWidth: 1000);
    if (ficheiro == null || !mounted) return;
    final bytes = await ficheiro.readAsBytes();
    if (!mounted) return;
    setState(() => _aMudarLogo = true);
    try {
      final p = await context.read<StandProfileRepository>().uploadLogo(bytes);
      if (mounted) setState(() => _perfil = p);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _aMudarLogo = false);
    }
  }

  Future<void> _removerLogo() async {
    setState(() => _aMudarLogo = true);
    try {
      final p = await context.read<StandProfileRepository>().removeLogo();
      if (mounted) setState(() => _perfil = p);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) setState(() => _aMudarLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final perfil = _perfil;
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuDefinicoes)),
      body: MaxWidthBody(
        child: _erroCarregar != null
            ? Center(child: Text(_erroCarregar!.localizado(context)))
            : perfil == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(l10n.definicoesSecaoPerfil, style: tema.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(perfil.nome, style: tema.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: perfil.logoUrl != null
                                  ? NetworkImageSafe(imageUrl: perfil.logoUrl!, fit: BoxFit.contain)
                                  : ColoredBox(
                                      color: tema.colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.storefront_outlined),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                OutlinedButton(
                                  onPressed: _aMudarLogo ? null : _mudarLogo,
                                  child: Text(l10n.definicoesLogoAlterar),
                                ),
                                if (perfil.logoUrl != null)
                                  TextButton(
                                    onPressed: _aMudarLogo ? null : _removerLogo,
                                    child: Text(l10n.definicoesLogoRemover),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contacto,
                        keyboardType: TextInputType.phone,
                        maxLength: 120,
                        decoration: InputDecoration(labelText: l10n.definicoesCampoContacto),
                      ),
                      TextField(
                        controller: _morada,
                        maxLength: 200,
                        decoration: InputDecoration(labelText: l10n.definicoesCampoMorada),
                      ),
                      TextField(
                        controller: _redes,
                        maxLength: 120,
                        decoration: InputDecoration(labelText: l10n.definicoesCampoRedes),
                      ),
                      const Divider(height: 32),
                      Text(l10n.definicoesSecaoSite, style: tema.textTheme.titleMedium),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.definicoesSiteAtivo),
                        subtitle: Text(l10n.definicoesSiteAtivoDesc),
                        value: _siteAtivo,
                        onChanged: (v) => setState(() => _siteAtivo = v),
                      ),
                      TextField(
                        controller: _slug,
                        maxLength: 40,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n.definicoesSiteEndereco,
                          prefixText: '${Uri.parse(siteBaseUrl).host}/',
                          helperText: l10n.definicoesSiteEnderecoAjuda,
                          errorText: _slug.text.trim().isNotEmpty && !_slugOk ? l10n.definicoesSiteEnderecoInvalido : null,
                        ),
                      ),
                      // Só depois de gravado: o endereço novo ainda não existe no servidor.
                      if (perfil.siteAtivo && perfil.slug != null)
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: Text(l10n.definicoesSiteAbrir),
                              onPressed: () => launchUrl(
                                Uri.parse('$siteBaseUrl/${perfil.slug}'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.copy),
                              label: Text(l10n.definicoesSiteCopiar),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: '$siteBaseUrl/${perfil.slug}'));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.definicoesSiteCopiado)));
                                }
                              },
                            ),
                          ],
                        ),
                      if (_slugOk)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: SelectableText(_enderecoCompleto, style: tema.textTheme.bodySmall),
                        ),
                      const Divider(height: 32),
                      Text(l10n.definicoesSecaoPermissoes, style: tema.textTheme.titleMedium),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.definicoesColabAprovam),
                        subtitle: Text(l10n.definicoesColabAprovamDesc),
                        value: _colabAprovam,
                        onChanged: (v) => setState(() => _colabAprovam = v),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _aGuardar ? null : _guardar,
                        child: _aGuardar
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.definicoesGuardar),
                      ),
                    ],
                  ),
      ),
    );
  }
}
