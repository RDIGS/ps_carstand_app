import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import 'visit_request.dart';
import 'visits_repository.dart';

final _fmt = DateFormat('dd/MM/yyyy HH:mm');

/// Número para o wa.me: só dígitos, com 351 à frente num número português de
/// 9 dígitos sem indicativo.
String? numeroWhatsapp(String? telefone) {
  if (telefone == null) return null;
  final digitos = telefone.replaceAll(RegExp(r'\D'), '');
  if (digitos.length == 9 && RegExp(r'^[29]').hasMatch(digitos)) return '351$digitos';
  return digitos.length >= 9 ? digitos : null;
}

/// Pedidos de visita feitos no site público — pendentes primeiro, com
/// contacto rápido (ligar/WhatsApp/email) e aprovar/rejeitar.
class VisitRequestsView extends StatefulWidget {
  const VisitRequestsView({super.key, required this.onAlterado});

  /// Chamado depois de aprovar/rejeitar (a agenda e o contador mudam).
  final VoidCallback onAlterado;

  @override
  State<VisitRequestsView> createState() => _VisitRequestsViewState();
}

class _VisitRequestsViewState extends State<VisitRequestsView> {
  late Future<List<VisitRequest>> _future;
  final Set<String> _aResponder = {};

  @override
  void initState() {
    super.initState();
    _future = context.read<VisitsRepository>().list();
  }

  Future<void> _refresh() async {
    setState(() => _future = context.read<VisitsRepository>().list());
    await _future;
  }

  Future<void> _abrir(Uri uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  Future<void> _responder(VisitRequest p, {required bool aprovar}) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(aprovar ? l10n.pedidoAprovarTitulo : l10n.pedidoRejeitarTitulo),
        content: Text(aprovar ? l10n.pedidoAprovarTexto(_fmt.format(p.dataHora)) : l10n.pedidoRejeitarTexto),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancelar)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(aprovar ? l10n.pedidoAprovar : l10n.pedidoRejeitar),
          ),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    setState(() => _aResponder.add(p.id));
    final repo = context.read<VisitsRepository>();
    try {
      if (aprovar) {
        await repo.aprovar(p.id);
      } else {
        await repo.rejeitar(p.id);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aprovar ? l10n.pedidoAprovado : l10n.pedidoRejeitado)),
      );
      widget.onAlterado();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    } finally {
      if (mounted) {
        _aResponder.remove(p.id);
        await _refresh();
      }
    }
  }

  Widget _cartaoPendente(VisitRequest p) {
    final l10n = context.l10n;
    final whatsapp = numeroWhatsapp(p.telefone);
    final ocupado = _aResponder.contains(p.id);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_available, color: AppColors.teal),
                const SizedBox(width: 10),
                Expanded(child: Text(p.nome, style: Theme.of(context).textTheme.titleMedium)),
                Text(_fmt.format(p.dataHora), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            if (p.veiculo != null) Text('${p.veiculo}${p.matricula != null ? ' · ${p.matricula}' : ''}'),
            if (p.telefone != null) SelectableText(p.telefone!),
            if (p.email != null) SelectableText(p.email!),
            if (p.mensagem != null) ...[
              const SizedBox(height: 6),
              Text('“${p.mensagem}”', style: const TextStyle(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 4),
            Text(l10n.pedidoFeitoEm(_fmt.format(p.criadoEm)), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (p.telefone != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.call, size: 18),
                    label: Text(l10n.pedidoLigar),
                    onPressed: () => _abrir(Uri(scheme: 'tel', path: p.telefone!.replaceAll(RegExp(r'[^\d+]'), ''))),
                  ),
                if (whatsapp != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat, size: 18),
                    label: Text(l10n.pedidoWhatsapp),
                    onPressed: () => _abrir(Uri.parse('https://wa.me/$whatsapp')),
                  ),
                if (p.email != null)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.mail_outline, size: 18),
                    label: Text(l10n.pedidoEmail),
                    onPressed: () => _abrir(Uri(scheme: 'mailto', path: p.email)),
                  ),
                TextButton(
                  onPressed: ocupado ? null : () => _responder(p, aprovar: false),
                  child: Text(l10n.pedidoRejeitar),
                ),
                FilledButton(
                  onPressed: ocupado ? null : () => _responder(p, aprovar: true),
                  child: Text(l10n.pedidoAprovar),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<VisitRequest>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final erro = snapshot.error;
            return ListView(children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(erro is ApiException ? erro.localizado(context) : '$erro')),
              ),
            ]);
          }
          final todos = snapshot.data!;
          final pendentes = todos.where((p) => p.pendente).toList();
          final respondidos = todos.where((p) => !p.pendente).take(20).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pendentes.isEmpty)
                Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l10n.pedidosVazio)))
              else
                for (final p in pendentes) _cartaoPendente(p),
              if (respondidos.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 4),
                  child: Text(l10n.pedidosRespondidos, style: Theme.of(context).textTheme.titleSmall),
                ),
                for (final p in respondidos)
                  ListTile(
                    dense: true,
                    title: Text(p.nome),
                    subtitle: Text([_fmt.format(p.dataHora), if (p.veiculo != null) p.veiculo!].join(' · ')),
                    trailing: Chip(
                      label: Text(p.estado == 'aprovado' ? l10n.pedidoEstadoAprovado : l10n.pedidoEstadoRejeitado),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
