import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_error_l10n.dart';
import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/max_width_body.dart';
import '../auth/auth_state.dart';
import '../leads/leads_repository.dart';
import '../team/team_member.dart';
import '../team/team_repository.dart';
import '../vehicles/vehicles_repository.dart';
import 'calendar_event.dart';
import 'calendar_repository.dart';

const _janelaDias = 60;

/// Calendário de equipa (secção nova, 2026-09-08) — dentro de UM stand só
/// (nunca entre stands diferentes, quebraria o isolamento entre tenants).
/// Vista tipo agenda (lista agrupada por dia), não uma grelha de mês — este
/// projeto não tinha nenhum pacote de calendário instalado, e uma lista
/// cobre o essencial (criar, convidar, aceitar/recusar, tarefas do stand)
/// sem trazer uma dependência nova só para um componente visual.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  String _escopo = 'stand';
  late Future<List<CalendarEvent>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final hoje = DateTime.now();
    _future = context.read<CalendarRepository>().list(
          inicio: DateTime(hoje.year, hoje.month, hoje.day),
          fim: DateTime(hoje.year, hoje.month, hoje.day).add(const Duration(days: _janelaDias)),
          escopo: _escopo,
        );
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Map<DateTime, List<CalendarEvent>> _agruparPorDia(List<CalendarEvent> eventos) {
    final grupos = <DateTime, List<CalendarEvent>>{};
    for (final e in eventos) {
      final dia = DateTime(e.dataHoraInicio.year, e.dataHoraInicio.month, e.dataHoraInicio.day);
      (grupos[dia] ??= []).add(e);
    }
    return grupos;
  }

  Future<void> _abrirFormulario({CalendarEvent? existente}) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final tituloController = TextEditingController(text: existente?.titulo);
    final descricaoController = TextEditingController(text: existente?.descricao);
    DateTime dataHoraInicio = existente?.dataHoraInicio ?? DateTime.now().add(const Duration(hours: 1));
    DateTime? dataHoraFim = existente?.dataHoraFim;
    String? veiculoId = existente?.veiculoId;
    String? leadId = existente?.leadId;
    final meuId = context.read<AuthState>().userId;
    Set<String> convidadosIds = existente?.participantes.map((p) => p.personId).toSet() ?? {};

    List<TeamMember> equipa = [];
    List<dynamic> veiculos = [];
    List<dynamic> leads = [];
    try {
      equipa = (await context.read<TeamRepository>().list()).where((m) => m.personId != meuId).toList();
    } catch (_) {
      // Seletor de convidados é só conveniência — se falhar, fica vazio.
    }
    if (!mounted) return;
    try {
      veiculos = (await context.read<VehiclesRepository>().list(limit: 200)).data;
    } catch (_) {}
    if (!mounted) return;
    try {
      leads = (await context.read<LeadsRepository>().list(limit: 200)).data;
    } catch (_) {}
    if (!mounted) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> escolherDataHora(bool inicio) async {
            final atual = (inicio ? dataHoraInicio : dataHoraFim) ?? DateTime.now();
            final data = await showDatePicker(
              context: context,
              initialDate: atual,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (data == null || !context.mounted) return;
            final hora = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(atual));
            if (hora == null) return;
            final escolhida = DateTime(data.year, data.month, data.day, hora.hour, hora.minute);
            setDialogState(() {
              if (inicio) {
                dataHoraInicio = escolhida;
              } else {
                dataHoraFim = escolhida;
              }
            });
          }

          return AlertDialog(
            title: Text(existente == null ? l10n.calendarioNovoEvento : l10n.calendarioEditarEvento),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: tituloController,
                      decoration: InputDecoration(labelText: l10n.calendarioCampoTitulo),
                      validator: (v) => (v ?? '').trim().isEmpty ? l10n.validacaoCampoObrigatorio : null,
                    ),
                    TextFormField(
                      controller: descricaoController,
                      decoration: InputDecoration(labelText: l10n.campoDescricao),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.calendarioCampoInicio),
                      subtitle: Text('${dataHoraInicio.toLocal()}'.substring(0, 16)),
                      trailing: const Icon(Icons.event),
                      onTap: () => escolherDataHora(true),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.calendarioCampoFim),
                      subtitle: Text(dataHoraFim != null ? '${dataHoraFim!.toLocal()}'.substring(0, 16) : '—'),
                      trailing: dataHoraFim != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setDialogState(() => dataHoraFim = null),
                            )
                          : const Icon(Icons.event),
                      onTap: () => escolherDataHora(false),
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: veiculoId,
                      decoration: InputDecoration(labelText: l10n.calendarioCampoVeiculo),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.calendarioSemVeiculo)),
                        for (final v in veiculos)
                          DropdownMenuItem(value: v.id as String, child: Text('${v.matricula} — ${v.marca} ${v.modelo}')),
                      ],
                      onChanged: (v) => setDialogState(() => veiculoId = v),
                    ),
                    DropdownButtonFormField<String?>(
                      initialValue: leadId,
                      decoration: InputDecoration(labelText: l10n.calendarioCampoLead),
                      isExpanded: true,
                      items: [
                        DropdownMenuItem(value: null, child: Text(l10n.calendarioSemLead)),
                        for (final ld in leads) DropdownMenuItem(value: ld.id as String, child: Text(ld.nome as String)),
                      ],
                      onChanged: (v) => setDialogState(() => leadId = v),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.calendarioCampoConvidados, style: Theme.of(context).textTheme.labelLarge),
                    if (equipa.isEmpty) Text(l10n.calendarioSemConvidados, style: Theme.of(context).textTheme.bodySmall),
                    for (final membro in equipa)
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: convidadosIds.contains(membro.personId),
                        title: Text(membro.nome),
                        onChanged: (marcado) => setDialogState(() {
                          if (marcado ?? false) {
                            convidadosIds = {...convidadosIds, membro.personId};
                          } else {
                            convidadosIds = {...convidadosIds}..remove(membro.personId);
                          }
                        }),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) Navigator.of(context).pop(true);
                },
                child: Text(l10n.guardar),
              ),
            ],
          );
        },
      ),
    );

    if (confirmou != true || !mounted) return;
    try {
      final repo = context.read<CalendarRepository>();
      if (existente == null) {
        await repo.create(
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim().isEmpty ? null : descricaoController.text.trim(),
          dataHoraInicio: dataHoraInicio,
          dataHoraFim: dataHoraFim,
          veiculoId: veiculoId,
          leadId: leadId,
          participantesIds: convidadosIds.toList(),
        );
      } else {
        await repo.update(
          id: existente.id,
          titulo: tituloController.text.trim(),
          descricao: descricaoController.text.trim(),
          dataHoraInicio: dataHoraInicio,
          dataHoraFim: dataHoraFim,
          veiculoId: veiculoId,
          leadId: leadId,
          participantesIds: convidadosIds.toList(),
        );
      }
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _apagar(CalendarEvent evento) async {
    final l10n = context.l10n;
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.calendarioApagarTitulo),
        content: Text(l10n.calendarioApagarConfirmacao),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancelar)),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.remover)),
        ],
      ),
    );
    if (confirmou != true || !mounted) return;
    try {
      await context.read<CalendarRepository>().remove(evento.id);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _responder(CalendarEvent evento, String estado) async {
    try {
      await context.read<CalendarRepository>().responder(evento.id, estado);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _toggleConcluido(CalendarEvent evento) async {
    try {
      await context.read<CalendarRepository>().toggleConcluido(evento.id, !evento.concluido);
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  Future<void> _abrirDetalhe(CalendarEvent evento) async {
    final l10n = context.l10n;
    final auth = context.read<AuthState>();
    final meuId = auth.userId;
    final souOrganizador = evento.criadoPor == meuId;
    final souOwner = auth.userRole == 'owner';
    final meuEstado = meuId != null ? evento.meuEstado(meuId) : null;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evento.titulo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${evento.dataHoraInicio}'.substring(0, 16)),
              if (evento.descricao != null) ...[const SizedBox(height: 8), Text(evento.descricao!)],
              const SizedBox(height: 8),
              Text(l10n.calendarioOrganizadoPor(evento.criadoPorNome), style: Theme.of(context).textTheme.bodySmall),
              if (evento.veiculoLabel != null) Text(evento.veiculoLabel!),
              if (evento.leadNome != null) Text(evento.leadNome!),
              if (evento.participantes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(l10n.calendarioConvidados, style: Theme.of(context).textTheme.labelLarge),
                for (final p in evento.participantes)
                  Text('${p.nome} — ${_estadoLabel(l10n, p.estado)}'),
              ],
            ],
          ),
        ),
        actions: [
          if (meuEstado == 'pendente') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _responder(evento, 'recusado');
              },
              child: Text(l10n.calendarioRecusar),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _responder(evento, 'aceite');
              },
              child: Text(l10n.calendarioAceitar),
            ),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleConcluido(evento);
            },
            child: Text(evento.concluido ? l10n.calendarioDesmarcarConcluido : l10n.calendarioMarcarConcluido),
          ),
          if (souOrganizador || souOwner) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _abrirFormulario(existente: evento);
              },
              child: Text(l10n.editar),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _apagar(evento);
              },
              child: Text(l10n.remover),
            ),
          ],
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fechar)),
        ],
      ),
    );
  }

  // Link .ics subscritível — sem sincronização bidirecional a sério
  // (CalDAV/Google Calendar API), só um link que Google/iOS/Outlook sabem
  // subscrever sozinhos (ver memória do calendário).
  Future<void> _exportar() async {
    final l10n = context.l10n;
    try {
      final links = await context.read<CalendarRepository>().getFeedLinks();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.calendarioExportarTitulo),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.calendarioExportarTexto, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                Text(l10n.calendarioExportarMeu, style: Theme.of(context).textTheme.labelLarge),
                SelectableText(links.meuUrl, style: Theme.of(context).textTheme.bodySmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Clipboard.setData(ClipboardData(text: links.meuUrl)),
                    child: Text(l10n.copiarLink),
                  ),
                ),
                const Divider(),
                Text(l10n.calendarioExportarStand, style: Theme.of(context).textTheme.labelLarge),
                SelectableText(links.standUrl, style: Theme.of(context).textTheme.bodySmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Clipboard.setData(ClipboardData(text: links.standUrl)),
                    child: Text(l10n.copiarLink),
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.fechar))],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  // Upload manual e pontual de um ficheiro .ics — sem duplicar eventos já
  // importados antes (dedup por UID feito no backend).
  Future<void> _importar() async {
    final l10n = context.l10n;
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
      withData: true,
    );
    final arquivo = (resultado != null && resultado.files.isNotEmpty) ? resultado.files.first : null;
    final bytes = arquivo?.bytes;
    if (arquivo == null || bytes == null || !mounted) return;

    try {
      final r = await context.read<CalendarRepository>().importIcs(bytes, arquivo.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.calendarioImportarSucesso(r.importados, r.total))));
      await _refresh();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.localizado(context))));
    }
  }

  String _estadoLabel(dynamic l10n, String estado) {
    switch (estado) {
      case 'aceite':
        return l10n.calendarioConviteEstadoAceite;
      case 'recusado':
        return l10n.calendarioConviteEstadoRecusado;
      default:
        return l10n.calendarioConviteEstadoPendente;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meuId = context.watch<AuthState>().userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCalendario),
        actions: [
          IconButton(icon: const Icon(Icons.ios_share), tooltip: l10n.calendarioExportarTitulo, onPressed: _exportar),
          IconButton(icon: const Icon(Icons.upload_file), tooltip: l10n.calendarioImportarTitulo, onPressed: _importar),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'stand', label: Text(l10n.calendarioEscopoStand)),
                ButtonSegment(value: 'meu', label: Text(l10n.calendarioEscopoMeu)),
              ],
              selected: {_escopo},
              onSelectionChanged: (v) => setState(() {
                _escopo = v.first;
                _load();
              }),
            ),
          ),
        ),
      ),
      body: MaxWidthBody(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<CalendarEvent>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                final erro = snapshot.error;
                return Center(child: Text(erro is ApiException ? erro.localizado(context) : '$erro'));
              }
              final eventos = snapshot.data!;
              if (eventos.isEmpty) {
                return ListView(
                  children: [
                    Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(l10n.calendarioVazio))),
                  ],
                );
              }
              final grupos = _agruparPorDia(eventos);
              final dias = grupos.keys.toList()..sort();
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final dia in dias) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Text('$dia'.substring(0, 10), style: Theme.of(context).textTheme.titleSmall),
                    ),
                    for (final evento in grupos[dia]!)
                      Card(
                        child: ListTile(
                          onTap: () => _abrirDetalhe(evento),
                          leading: Icon(
                            evento.participantes.isEmpty ? Icons.task_alt : Icons.event,
                            color: evento.concluido ? AppColors.teal : null,
                          ),
                          title: Text(
                            evento.titulo,
                            style: evento.concluido ? const TextStyle(decoration: TextDecoration.lineThrough) : null,
                          ),
                          subtitle: Text(
                            [
                              '${evento.dataHoraInicio}'.substring(11, 16),
                              if (evento.veiculoLabel != null) evento.veiculoLabel!,
                              if (evento.leadNome != null) evento.leadNome!,
                            ].join(' · '),
                          ),
                          trailing: meuId != null && evento.meuEstado(meuId) == 'pendente'
                              ? Badge(label: Text(l10n.calendarioConviteEstadoPendente))
                              : null,
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'calendar-fab',
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: Text(l10n.calendarioNovoEvento),
      ),
    );
  }
}
