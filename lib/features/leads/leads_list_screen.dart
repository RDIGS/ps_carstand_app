import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/max_width_body.dart';
import 'lead.dart';
import 'lead_form_screen.dart';
import 'leads_repository.dart';

/// CRM básico de interessados (secção não prevista na arquitetura original,
/// pedido do utilizador) — qualquer role vê e gere todos os leads do stand.
class LeadsListScreen extends StatefulWidget {
  const LeadsListScreen({super.key});

  @override
  State<LeadsListScreen> createState() => _LeadsListScreenState();
}

class _LeadsListScreenState extends State<LeadsListScreen> {
  late Future<List<Lead>> _future;
  String? _filtroEstado;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<LeadsRepository>().list(estado: _filtroEstado);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _abrirFormulario({Lead? lead}) async {
    final alterado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => LeadFormScreen(lead: lead)),
    );
    if (alterado == true && mounted) _refresh();
  }

  Color _corEstado(String estado) {
    switch (estado) {
      case 'convertido':
        return AppColors.verdeDisponivel;
      case 'perdido':
        return AppColors.grafiteVendido;
      case 'agendado':
        return AppColors.azulMatricula;
      default:
        return AppColors.amberSinal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navLeads)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: MaxWidthBody(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FiltroChip(label: l10n.leadFiltroTodos, selecionado: _filtroEstado == null, onTap: () {
                      setState(() => _filtroEstado = null);
                      _refresh();
                    }),
                    for (final estado in leadEstados)
                      _FiltroChip(
                        label: leadEstadoLabel(context, estado),
                        selecionado: _filtroEstado == estado,
                        onTap: () {
                          setState(() => _filtroEstado = estado);
                          _refresh();
                        },
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<Lead>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    }
                    final leads = snapshot.data!;
                    if (leads.isEmpty) {
                      return Center(child: Text(l10n.leadSemResultados));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: leads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final lead = leads[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _corEstado(lead.estado).withValues(alpha: 0.16),
                              child: Icon(Icons.person_outline, color: _corEstado(lead.estado)),
                            ),
                            title: Text(lead.nome),
                            subtitle: Text(
                              [
                                leadEstadoLabel(context, lead.estado),
                                if (lead.telefone != null) lead.telefone!,
                              ].join(' · '),
                            ),
                            onTap: () => _abrirFormulario(lead: lead),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  const _FiltroChip({required this.label, required this.selecionado, required this.onTap});

  final String label;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: selecionado, onSelected: (_) => onTap()),
    );
  }
}
