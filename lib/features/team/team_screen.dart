import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'team_member.dart';
import 'team_repository.dart';

/// Gestão de equipa (secção 4/O10) — owner apenas: convidar, mudar role,
/// ativar/desativar, remover acesso.
class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  late Future<List<TeamMember>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<TeamRepository>().list();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _abrirConvite() async {
    final l10n = context.l10n;
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    String role = 'vendedor';
    final formKey = GlobalKey<FormState>();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.convidarMembroTitulo),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: l10n.campoNome),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.validacaoCampoObrigatorio : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: l10n.loginEmail),
                  validator: (v) => (v == null || !v.contains('@')) ? l10n.validacaoEmailInvalido : null,
                ),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: InputDecoration(labelText: l10n.campoFuncao),
                  items: [
                    DropdownMenuItem(value: 'vendedor', child: Text(l10n.funcaoVendedor)),
                    DropdownMenuItem(value: 'owner', child: Text(l10n.funcaoOwner)),
                  ],
                  onChanged: (v) => setDialogState(() => role = v ?? 'vendedor'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) Navigator.of(context).pop(true);
              },
              child: Text(l10n.convidar),
            ),
          ],
        ),
      ),
    );

    if (confirmou != true || !mounted) return;

    try {
      final resultado = await context.read<TeamRepository>().invite(
            nome: nomeController.text.trim(),
            email: emailController.text.trim(),
            role: role,
          );
      if (!mounted) return;
      await _refresh();
      if (resultado.tempPassword != null && mounted) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.contaCriadaTitulo),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.contaCriadaTexto(resultado.member.nome)),
                const SizedBox(height: 12),
                SelectableText(resultado.tempPassword!, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Clipboard.setData(ClipboardData(text: resultado.tempPassword!)),
                child: Text(l10n.copiar),
              ),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.ok)),
            ],
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _mudarRole(TeamMember member, String novoRole) async {
    try {
      await context.read<TeamRepository>().update(member.id, role: novoRole);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _alternarAtivo(TeamMember member) async {
    try {
      await context.read<TeamRepository>().update(member.id, ativo: !member.ativo);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _remover(TeamMember member) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removerAcesso),
        content: Text(l10n.removerAcessoConfirmacao(member.nome)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await context.read<TeamRepository>().remove(member.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  String _funcaoLabel(AppLocalizations l10n, String role) => role == 'owner' ? l10n.funcaoOwner : l10n.funcaoVendedor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.equipaTitulo)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<TeamMember>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            }
            final membros = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: membros.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final membro = membros[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: membro.ativo ? AppColors.azulMatricula : AppColors.grafiteVendido,
                      child: Text(membro.nome.isNotEmpty ? membro.nome[0].toUpperCase() : '?'),
                    ),
                    title: Text(membro.nome),
                    subtitle: Text(l10n.membroSubtitulo(membro.email, _funcaoLabel(l10n, membro.role))),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'toggle_role':
                            _mudarRole(membro, membro.role == 'owner' ? 'vendedor' : 'owner');
                            break;
                          case 'toggle_ativo':
                            _alternarAtivo(membro);
                            break;
                          case 'remove':
                            _remover(membro);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'toggle_role',
                          child: Text(membro.role == 'owner' ? l10n.tornarVendedor : l10n.tornarOwner),
                        ),
                        PopupMenuItem(value: 'toggle_ativo', child: Text(membro.ativo ? l10n.desativar : l10n.ativar)),
                        PopupMenuItem(value: 'remove', child: Text(l10n.removerAcesso)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'team-fab',
        onPressed: _abrirConvite,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.convidar),
      ),
    );
  }
}
