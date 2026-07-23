import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import 'audit_entry.dart';
import 'audit_repository.dart';

/// Ecrã de auditoria (O15, só owner) — histórico de alterações: quem mudou
/// o quê, quando. Backend já devolve os últimos 200 registos do stand.
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  late Future<List<AuditEntry>> _future;
  String? _filtroEntidade;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<AuditRepository>().list(entidade: _filtroEntidade);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final filtros = <_Filtro>[
      _Filtro(null, l10n.auditoriaFiltroTodos),
      _Filtro('vehicle', l10n.auditoriaEntidadeVehicle),
      _Filtro('vehicle_expense', l10n.auditoriaEntidadeVehicleExpense),
      _Filtro('sale', l10n.auditoriaEntidadeSale),
      _Filtro('finance_entry', l10n.auditoriaEntidadeFinanceEntry),
      _Filtro('stand_member', l10n.auditoriaEntidadeStandMember),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.auditoriaTitulo)),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                for (final f in filtros)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(f.label),
                      selected: _filtroEntidade == f.entidade,
                      onSelected: (_) => setState(() {
                        _filtroEntidade = f.entidade;
                        _load();
                      }),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<AuditEntry>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('${snapshot.error}'));
                  }
                  final entradas = snapshot.data!;
                  if (entradas.isEmpty) {
                    return ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(child: Text(l10n.auditoriaSemRegistos)),
                        ),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: entradas.length,
                    itemBuilder: (context, i) => _AuditTile(entrada: entradas[i]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Filtro {
  const _Filtro(this.entidade, this.label);
  final String? entidade;
  final String label;
}

IconData _iconePorEntidade(String entidade) {
  switch (entidade) {
    case 'vehicle':
      return Icons.directions_car;
    case 'vehicle_expense':
      return Icons.receipt_long;
    case 'sale':
      return Icons.sell;
    case 'finance_entry':
      return Icons.bar_chart;
    case 'stand_member':
      return Icons.person;
    default:
      return Icons.history;
  }
}

String _labelEntidade(String entidade, AppLocalizations l10n) {
  switch (entidade) {
    case 'vehicle':
      return l10n.auditoriaEntidadeVehicle;
    case 'vehicle_expense':
      return l10n.auditoriaEntidadeVehicleExpense;
    case 'sale':
      return l10n.auditoriaEntidadeSale;
    case 'finance_entry':
      return l10n.auditoriaEntidadeFinanceEntry;
    case 'stand_member':
      return l10n.auditoriaEntidadeStandMember;
    default:
      return entidade;
  }
}

String _labelAcao(String acao, AppLocalizations l10n) {
  switch (acao) {
    case 'criado':
      return l10n.auditoriaAcaoCriado;
    case 'atualizado':
      return l10n.auditoriaAcaoAtualizado;
    case 'aprovado':
      return l10n.auditoriaAcaoAprovado;
    case 'rejeitado':
      return l10n.auditoriaAcaoRejeitado;
    case 'estado_alterado':
      return l10n.auditoriaAcaoEstadoAlterado;
    case 'revertida':
      return l10n.auditoriaAcaoRevertida;
    case 'convidado':
      return l10n.auditoriaAcaoConvidado;
    case 'removido':
      return l10n.auditoriaAcaoRemovido;
    default:
      return acao;
  }
}

class _AuditTile extends StatelessWidget {
  const _AuditTile({required this.entrada});

  final AuditEntry entrada;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final data = DateFormat('dd/MM/yyyy HH:mm').format(entrada.criadoEm.toLocal());
    final temDetalhe = entrada.valorAnterior != null || entrada.valorNovo != null;

    final titulo = Row(
      children: [
        Icon(_iconePorEntidade(entrada.entidade), size: 20, color: AppColors.azulMatricula),
        const SizedBox(width: 10),
        Text(_labelEntidade(entrada.entidade, l10n)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.grafiteVendido.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
          child: Text(_labelAcao(entrada.acao, l10n), style: Theme.of(context).textTheme.bodySmall),
        ),
      ],
    );

    final subtitulo = Text(
      l10n.auditoriaFeitoPor(entrada.feitoPorNome ?? '—', data),
      style: Theme.of(context).textTheme.bodySmall,
    );

    if (!temDetalhe) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titulo, const SizedBox(height: 4), subtitulo]),
      );
    }

    return ExpansionTile(
      title: titulo,
      subtitle: subtitulo,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entrada.valorAnterior != null) ...[
                Text(l10n.auditoriaValorAnterior, style: Theme.of(context).textTheme.labelMedium),
                _JsonBox(valor: entrada.valorAnterior!),
                const SizedBox(height: 8),
              ],
              if (entrada.valorNovo != null) ...[
                Text(l10n.auditoriaValorNovo, style: Theme.of(context).textTheme.labelMedium),
                _JsonBox(valor: entrada.valorNovo!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _JsonBox extends StatelessWidget {
  const _JsonBox({required this.valor});

  final Map<String, dynamic> valor;

  @override
  Widget build(BuildContext context) {
    final texto = const JsonEncoder.withIndent('  ').convert(valor);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(color: AppColors.cinzaChapa, borderRadius: BorderRadius.circular(6)),
      child: SelectableText(texto, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
    );
  }
}
